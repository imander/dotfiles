#!/usr/bin/env python3
"""Print issues and MRs with a label updated since a time, with the human activity in that window."""
import argparse
import json
import re
import subprocess
from concurrent.futures import ThreadPoolExecutor

BOT = re.compile(r"(bot|gitlabduo|^duo-|^service_account_|^project_\d+_|^group_\d+_)", re.I)


def api(path, paginate=True):
    cmd = ["glab", "api", *(["--paginate"] if paginate else []), path]
    for attempt in range(3):
        proc = subprocess.run(cmd, capture_output=True, text=True)
        if proc.returncode == 0:
            break
    else:
        raise RuntimeError(f"{path}: {proc.stderr.strip()}")
    out = proc.stdout
    # --paginate concatenates one JSON array per page
    items, i, dec = [], 0, json.JSONDecoder()
    out = out.strip()
    while i < len(out):
        page, i = dec.raw_decode(out, i)
        items.extend(page)
        while i < len(out) and out[i].isspace():
            i += 1
    return items


def activity(kind, item, since, me):
    # Newest 100 notes is enough for one catch-up window
    notes = api(f"projects/{item['project_id']}/{kind}/{item['iid']}/notes?sort=desc&order_by=created_at&per_page=100", paginate=False)
    out = []
    for n in reversed(notes):
        if n["created_at"] < since or BOT.search(n["author"]["username"]):
            continue
        if n["system"] and f"@{me}" not in n["body"] and not re.match(r"(approved|merged|closed|reopened)", n["body"]):
            continue
        out.append({"by": n["author"]["username"], "at": n["created_at"], "system": n["system"], "body": n["body"][:400]})
    return out


def safe_activity(kind, item, since, me):
    try:
        return activity(kind, item, since, me)
    except RuntimeError as e:
        return [{"by": "catchup", "at": since, "system": True, "body": f"could not read notes: {e}"}]


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--since", required=True, help="ISO 8601 UTC, e.g. 2026-10-15T09:00:00Z")
    p.add_argument("--group", default="gitlab-org")
    p.add_argument("--label", default="group::authorization")
    p.add_argument("--me", default="imand3r")
    a = p.parse_args()

    jobs = []
    for kind in ("issues", "merge_requests"):
        for item in api(f"groups/{a.group}/{kind}?labels={a.label}&updated_after={a.since}&scope=all&per_page=100"):
            jobs.append((kind, item))

    with ThreadPoolExecutor(8) as pool:
        notes = list(pool.map(lambda j: safe_activity(*j, a.since, a.me), jobs))

    result = []
    for (kind, item), acts in zip(jobs, notes):
        new = item["created_at"] >= a.since
        changed = any(item.get(k) and item[k] >= a.since for k in ("merged_at", "closed_at"))
        if not (new or changed or acts):
            continue  # only label/bot churn in the window
        result.append({
            "type": "mr" if kind == "merge_requests" else "issue",
            "title": item["title"],
            "url": item["web_url"],
            "state": item["state"],
            "author": item["author"]["username"],
            "draft": item.get("draft"),
            "new": new,
            "merged_at": item.get("merged_at"),
            "closed_at": item.get("closed_at"),
            "mentions_me": any(f"@{a.me}" in n["body"] and n["by"] != a.me for n in acts),
            "activity": acts,
        })
    print(json.dumps(result, indent=1))


if __name__ == "__main__":
    main()
