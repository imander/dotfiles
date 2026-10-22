#!/usr/bin/env python3
"""Watch GitLab MRs and print one line per event worth acting on.

Events: new comments (humans and GitLab Duo), failed or canceled head
pipelines, new merge conflicts, approvals lost (usually reset by a push), MRs
that are fully approved without auto-merge set, and merged/closed MRs (which
are then dropped from the watch list). Run it under the Monitor tool; each stdout line is a
notification.

Usage: watch.py --state-dir DIR [--project gitlab-org/gitlab] [--interval 90]

The MR list lives in DIR/mrs.txt (space- or newline-separated IIDs). Edit it
at any time to add MRs; the script re-reads it every pass. Seen notes and
pipeline states persist in DIR/state.json, so restarts don't repeat events.
"""
import argparse
import json
import os
import subprocess
import time
import urllib.parse

# Bots whose notes are status noise. GitLabDuo is deliberately not here.
SKIP_AUTHORS = {"gitlab-bot", "ai-mr-approval-action-labeler-gitlab-org"}


def api(project, path):
    r = subprocess.run(["glab", "api", f"projects/{project}/{path}"], capture_output=True, text=True)
    if r.returncode != 0 or not r.stdout.strip():
        return None
    try:
        return json.loads(r.stdout)
    except json.JSONDecodeError:
        return None


def current_user():
    r = subprocess.run(["glab", "api", "user"], capture_output=True, text=True)
    try:
        return json.loads(r.stdout)["username"]
    except (json.JSONDecodeError, KeyError):
        return None


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--state-dir", required=True)
    ap.add_argument("--project", default="gitlab-org/gitlab")
    ap.add_argument("--interval", type=int, default=90)
    args = ap.parse_args()

    project = urllib.parse.quote(args.project, safe="")
    mrs_file = os.path.join(args.state_dir, "mrs.txt")
    state_file = os.path.join(args.state_dir, "state.json")
    me = current_user()
    skip = SKIP_AUTHORS | ({me} if me else set())

    first_run = not os.path.exists(state_file)
    state = json.load(open(state_file)) if not first_run else {"notes": [], "seen": {}}
    seen_notes = set(state["notes"])
    seen = state["seen"]

    while True:
        mrs = [int(x) for x in open(mrs_file).read().split()] if os.path.exists(mrs_file) else []
        for iid in mrs:
            for n in api(project, f"merge_requests/{iid}/notes?per_page=100&sort=desc") or []:
                if n["id"] in seen_notes:
                    continue
                seen_notes.add(n["id"])
                author = n["author"]["username"]
                if first_run or n["system"] or author in skip or author.startswith("project_"):
                    continue
                body = " ".join(n["body"].split())[:300]
                print(f"!{iid} {author}: {body} "
                      f"https://gitlab.com/{args.project}/-/merge_requests/{iid}#note_{n['id']}", flush=True)

            m = api(project, f"merge_requests/{iid}")
            if not m:
                continue
            if m["state"] in ("merged", "closed"):
                print(f"!{iid} {m['state'].upper()}, no longer watching", flush=True)
                left = [x for x in open(mrs_file).read().split() if int(x) != iid]
                open(mrs_file, "w").write(" ".join(left))
                continue

            ck = f"conflict:{iid}"
            if m.get("has_conflicts") and seen.get(ck) != m["sha"]:
                seen[ck] = m["sha"]
                print(f"!{iid} HAS CONFLICTS ({m['source_branch']})", flush=True)

            # Auto-merge waits forever on unresolved threads, so report them.
            if m.get("merge_when_pipeline_succeeds"):
                ds = api(project, f"merge_requests/{iid}/discussions?per_page=100") or []
                open_threads = sorted(
                    d["notes"][0]["author"]["username"] for d in ds
                    if any(n.get("resolvable") and not n.get("resolved") for n in d["notes"])
                )
                tk = f"threads:{iid}"
                sig = f"{m['sha']}:{','.join(open_threads)}"
                if open_threads and seen.get(tk) != sig:
                    seen[tk] = sig
                    print(f"!{iid} AUTO-MERGE BLOCKED by {len(open_threads)} unresolved thread(s) "
                          f"started by: {', '.join(open_threads)}", flush=True)
                elif not open_threads:
                    seen.pop(tk, None)

            # A push can reset approvals; report who dropped off so their review is re-requested.
            appr = api(project, f"merge_requests/{iid}/approvals")
            if appr is not None:
                ak = f"approvers:{iid}"
                now = sorted(a["user"]["username"] for a in appr.get("approved_by", []))
                lost = [u for u in seen.get(ak, []) if u not in now]
                if lost and not first_run:
                    print(f"!{iid} APPROVAL RESET for: {', '.join(lost)} "
                          f"(re-request their review and tag them)", flush=True)
                seen[ak] = now

                # Reported once per commit, so a push that resets and regains approval reports again.
                fk = f"approved:{iid}"
                if (appr.get("approvals_left") == 0 and not m.get("merge_when_pipeline_succeeds")
                        and seen.get(fk) != m["sha"] and not first_run):
                    seen[fk] = m["sha"]
                    print(f"!{iid} FULLY APPROVED by {', '.join(now) or 'rules'}, auto-merge not set", flush=True)

            p = m.get("head_pipeline") or {}
            key = f"{p.get('id')}:{p.get('status')}"
            if p and seen.get(str(iid)) != key:
                seen[str(iid)] = key
                if p.get("status") in ("failed", "canceled"):
                    print(f"!{iid} PIPELINE {p['status']}: {p.get('web_url')}", flush=True)

        first_run = False
        json.dump({"notes": sorted(seen_notes), "seen": seen}, open(state_file, "w"))
        time.sleep(args.interval)


if __name__ == "__main__":
    main()
