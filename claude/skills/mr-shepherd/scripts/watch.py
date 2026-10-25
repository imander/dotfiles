#!/usr/bin/env python3
"""Watch GitLab MRs and print one line per event worth acting on.

Events: new comments (humans, GitLab Duo and other bots), failed or canceled head
pipelines, new merge conflicts, approvals lost (usually reset by a push), MRs
that are fully approved without auto-merge set, and merged/closed MRs (which
are then dropped from the watch list). Run it under the Monitor tool; each stdout line is a
notification.

Usage: watch.py [--state-dir DIR] [--project gitlab-org/gitlab] [--interval 90] [--max-seconds 1740]
       watch.py add IID [IID...]

DIR defaults to ~/.claude/mr-shepherd, shared by all sessions. Only one watcher
can run per DIR; a second one prints "! WATCHER ALREADY RUNNING" and exits.
The MR list lives in DIR/mrs.txt; `add` appends to it from any session, and the
watcher re-reads it every pass. Seen notes and pipeline states persist in
DIR/state.json, so restarts don't repeat events.
"""
import argparse
import fcntl
import json
import os
import subprocess
import sys
import time
import urllib.parse

DEFAULT_DIR = os.path.expanduser("~/.claude/mr-shepherd")


class list_lock:
    """Serializes edits to mrs.txt between `add` and the watcher dropping merged MRs."""

    def __init__(self, state_dir):
        self.path = os.path.join(state_dir, "mrs.lock")

    def __enter__(self):
        self.f = open(self.path, "w")
        fcntl.flock(self.f, fcntl.LOCK_EX)

    def __exit__(self, *_):
        self.f.close()


def read_mrs(mrs_file):
    return [int(x) for x in open(mrs_file).read().split()] if os.path.exists(mrs_file) else []


def add(state_dir, iids):
    os.makedirs(os.path.join(state_dir, "notes"), exist_ok=True)
    mrs_file = os.path.join(state_dir, "mrs.txt")
    with list_lock(state_dir):
        mrs = read_mrs(mrs_file)
        new = [i for i in iids if i not in mrs]
        open(mrs_file, "w").write(" ".join(str(i) for i in mrs + new))
    for i in iids:
        print(f"!{i} {'added' if i in new else 'already watched'}; "
              f"handoff note: {os.path.join(state_dir, 'notes', f'{i}.md')}")
    print(f"watcher running: {'yes' if watcher_running(state_dir) else 'no'}")


def watcher_running(state_dir):
    lock_file = os.path.join(state_dir, "watch.lock")
    if not os.path.exists(lock_file):
        return False
    with open(lock_file) as f:
        try:
            fcntl.flock(f, fcntl.LOCK_SH | fcntl.LOCK_NB)
            return False
        except BlockingIOError:
            return True


def is_bot(author):
    username = author["username"]
    return author.get("bot") or username.startswith("project_") or username.endswith("-bot") or "_bot_" in username


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
    if sys.argv[1:2] == ["add"]:
        ap = argparse.ArgumentParser(prog="watch.py add")
        ap.add_argument("iids", type=int, nargs="+")
        ap.add_argument("--state-dir", default=DEFAULT_DIR)
        args = ap.parse_args(sys.argv[2:])
        add(args.state_dir, args.iids)
        return

    ap = argparse.ArgumentParser()
    ap.add_argument("--state-dir", default=DEFAULT_DIR)
    ap.add_argument("--project", default="gitlab-org/gitlab")
    ap.add_argument("--interval", type=int, default=90)
    # Exit before the Monitor's 30 minute timeout, so a killed Monitor never leaves a watcher holding the lock.
    ap.add_argument("--max-seconds", type=int, default=1740)
    args = ap.parse_args()
    os.makedirs(os.path.join(args.state_dir, "notes"), exist_ok=True)

    lock = open(os.path.join(args.state_dir, "watch.lock"), "a+")
    try:
        fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
    except BlockingIOError:
        lock.seek(0)
        print(f"! WATCHER ALREADY RUNNING ({lock.read().strip()}); add MRs with `watch.py add` instead", flush=True)
        sys.exit(1)
    lock.truncate(0)
    lock.write(f"pid {os.getpid()}, cwd {os.getcwd()}, since {time.strftime('%Y-%m-%d %H:%M:%S')}\n")
    lock.flush()

    project = urllib.parse.quote(args.project, safe="")
    mrs_file = os.path.join(args.state_dir, "mrs.txt")
    state_file = os.path.join(args.state_dir, "state.json")
    me = current_user()
    deadline = time.time() + args.max_seconds

    first_run = not os.path.exists(state_file)
    state = json.load(open(state_file)) if not first_run else {"notes": [], "seen": {}}
    seen_notes = set(state["notes"])
    seen = state["seen"]
    # MRs already baselined. State files from before this field count their current MRs as known.
    known = set(state.get("known", [] if first_run else read_mrs(mrs_file)))

    while True:
        for iid in read_mrs(mrs_file):
            # The first pass over a newly added MR only records what's already there.
            baseline = first_run or iid not in known
            if iid not in known and not first_run:
                print(f"!{iid} ADDED to watch; handoff note: "
                      f"{os.path.join(args.state_dir, 'notes', f'{iid}.md')}", flush=True)
            known.add(iid)
            for n in api(project, f"merge_requests/{iid}/notes?per_page=100&sort=desc") or []:
                if n["id"] in seen_notes:
                    continue
                seen_notes.add(n["id"])
                author = n["author"]["username"]
                if baseline or n["system"] or author == me:
                    continue
                # Bot notes are reported too: Danger suggestions open resolvable threads that block merging.
                tag = "BOT " if is_bot(n["author"]) else ""
                if n.get("resolvable") and not n.get("resolved"):
                    tag += "OPEN THREAD "
                body = " ".join(n["body"].split())[:300]
                print(f"!{iid} {tag}{author}: {body} "
                      f"https://gitlab.com/{args.project}/-/merge_requests/{iid}#note_{n['id']}", flush=True)

            m = api(project, f"merge_requests/{iid}")
            if not m:
                continue
            if m["state"] in ("merged", "closed"):
                print(f"!{iid} {m['state'].upper()}, no longer watching", flush=True)
                with list_lock(args.state_dir):
                    left = [str(x) for x in read_mrs(mrs_file) if x != iid]
                    open(mrs_file, "w").write(" ".join(left))
                known.discard(iid)
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
                if lost and not baseline:
                    print(f"!{iid} APPROVAL RESET for: {', '.join(lost)} "
                          f"(re-request their review and tag them)", flush=True)
                seen[ak] = now

                # Reported once per commit, so a push that resets and regains approval reports again.
                fk = f"approved:{iid}"
                if (appr.get("approvals_left") == 0 and not m.get("merge_when_pipeline_succeeds")
                        and seen.get(fk) != m["sha"] and not baseline):
                    seen[fk] = m["sha"]
                    print(f"!{iid} FULLY APPROVED by {', '.join(now) or 'rules'}, auto-merge not set", flush=True)

            p = m.get("head_pipeline") or {}
            key = f"{p.get('id')}:{p.get('status')}"
            if p and seen.get(str(iid)) != key:
                seen[str(iid)] = key
                if p.get("status") in ("failed", "canceled"):
                    print(f"!{iid} PIPELINE {p['status']}: {p.get('web_url')}", flush=True)

        first_run = False
        json.dump({"notes": sorted(seen_notes), "seen": seen, "known": sorted(known)}, open(state_file, "w"))
        if time.time() + args.interval > deadline:
            print("! WATCH WINDOW ENDED, re-arm the Monitor", flush=True)
            return
        time.sleep(args.interval)


if __name__ == "__main__":
    main()
