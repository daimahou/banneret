"""Active time per ticket, from the Claude Code session transcripts.

A ticket's time is the time on its branch, plus its grill: the session's time on main before it moved to the branch. A gap over 15 minutes is a break. A grill under 5 minutes ran in another session; the ticket gets a flat half-hour for it. Over an hour, the session did other work on main first; the grill counts as an hour. Hours are rounded to the half-hour.

The work in no ticket (setup, docs, tracker, time on main outside grills) is overhead: all active time since the repo's first commit, less the tickets' hours. It is written as `hours` on the overhead goal, so leaves and goal sum to the project's active time.

    python3 tools/ticket_time.py                     # every ticket branch, and the overhead
    python3 tools/ticket_time.py 1.1-3.4-fight-on-stage --write   # also sets `hours` in the ticket and the overhead goal
"""
import collections
import datetime
import glob
import json
import os
import re
import subprocess
import sys

BREAK = 15 * 60
GRILL_MIN = 5 * 60
GRILL_DEFAULT = 30 * 60
GRILL_MAX = 60 * 60
REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LEAF_FOLDERS = ["docs/tickets/tasks", "docs/tickets/bugs"]
GOAL_FOLDER = "docs/tickets/goals"
OVERHEAD_ID = "1"
TICKET_BRANCH = re.compile(r"^(\d[\w.]*-[\d.]+)-[a-z]")


def get_sessions():
	project = os.path.expanduser("~/.claude/projects/" + REPO.replace("/", "-"))
	for path in glob.glob(project + "*/*.jsonl"):
		events = []
		with open(path, errors="ignore") as file:
			for line in file:
				try:
					event = json.loads(line)
				except json.JSONDecodeError:
					continue
				if event.get("timestamp") and event.get("gitBranch"):
					time = datetime.datetime.fromisoformat(event["timestamp"].replace("Z", "+00:00"))
					events.append((time, event["gitBranch"]))
		events.sort()
		yield events


def get_ticket_seconds():
	branch_seconds = collections.Counter()
	grill_seconds = collections.Counter()
	for events in get_sessions():
		main_run = 0.0
		for (time, branch), (next_time, next_branch) in zip(events, events[1:]):
			gap = (next_time - time).total_seconds()
			is_active = 0 <= gap <= BREAK
			if is_active:
				branch_seconds[branch] += gap
			if branch == "main" and is_active:
				main_run += gap
			if next_branch != branch:
				if branch == "main" and TICKET_BRANCH.match(next_branch):
					grill_seconds[next_branch] += main_run
				main_run = 0.0
	return {
		branch: seconds + get_grill_seconds(grill_seconds[branch])
		for branch, seconds in branch_seconds.items() if TICKET_BRANCH.match(branch)
	}


def get_grill_seconds(found_seconds):
	return min(found_seconds, GRILL_MAX) if found_seconds >= GRILL_MIN else GRILL_DEFAULT


def get_hours(seconds):
	return max(0.5, round(seconds / 1800) / 2)


def get_birth():
	first_commit = subprocess.check_output(["git", "-C", REPO, "log", "--reverse", "--format=%aI"], text=True).split()[0]
	return datetime.datetime.fromisoformat(first_commit)


def get_project_seconds():
	birth = get_birth()
	seconds = 0.0
	for events in get_sessions():
		for (time, _branch), (next_time, _next_branch) in zip(events, events[1:]):
			gap = (next_time - time).total_seconds()
			if time >= birth and 0 <= gap <= BREAK:
				seconds += gap
	return seconds


def get_written_ticket_hours():
	hours = 0.0
	for folder in LEAF_FOLDERS:
		for path in glob.glob(os.path.join(REPO, folder, "*.md")):
			with open(path) as file:
				match = re.search(r"^hours: ([\d.]+)$", file.read().split("---", 2)[1], re.M)
			if match:
				hours += float(match.group(1))
	return hours


def write_hours(ticket_id, hours):
	for folder in LEAF_FOLDERS + [GOAL_FOLDER]:
		for path in glob.glob(os.path.join(REPO, folder, "*.md")):
			with open(path) as file:
				text = file.read()
			front = text.split("---", 2)
			if len(front) < 3 or not re.search(r"^id: \"?%s\"?$" % re.escape(ticket_id), front[1], re.M):
				continue
			if re.search(r"^hours:.*$", front[1], re.M):
				front[1] = re.sub(r"^hours:.*$", "hours: %g" % hours, front[1], flags=re.M)
			else:
				front[1] = re.sub(r"^(finished:.*)$", r"\1\nhours: %g" % hours, front[1], flags=re.M)
			with open(path, "w") as file:
				file.write("---".join(front))
			return path
	return None


def main():
	arguments = [argument for argument in sys.argv[1:] if not argument.startswith("--")]
	is_writing = "--write" in sys.argv
	for branch, seconds in sorted(get_ticket_seconds().items()):
		if arguments and branch not in arguments:
			continue
		hours = get_hours(seconds)
		path = write_hours(TICKET_BRANCH.match(branch).group(1), hours) if is_writing else None
		print("%-40s %4g h%s" % (branch, hours, "  -> " + os.path.relpath(path, REPO) if path else ""))
	overhead = get_hours(get_project_seconds() - get_written_ticket_hours() * 3600)
	path = write_hours(OVERHEAD_ID, overhead) if is_writing else None
	print("%-40s %4g h%s" % ("overhead", overhead, "  -> " + os.path.relpath(path, REPO) if path else ""))


if __name__ == "__main__":
	main()
