"""Active time per ticket, from the Claude Code session transcripts.

- A leaf gets the time on its branch: its implementation.
- A note gets the time on main that ends in a commit carrying `Ticket: <its id>`: its breakdown, or the grills of its children.
- Untagged time on main just before a session moves to a ticket branch is that ticket's grill; it goes to the ticket's parent.
- The rest is overhead (setup, docs, tracker), written on the active goal, so every ticket's hours sum to the project's active time.

Run before every commit on main: main time since the last commit goes to the coming commit's ticket, or to the active goal. A gap over 15 minutes is a break. Hours are rounded to the tenth.

    python3 tools/ticket_time.py                         # every ticket's hours
    python3 tools/ticket_time.py --write                 # also writes them as `hours` in the tickets
    python3 tools/ticket_time.py --write --ticket=1.1-3  # the coming commit carries `Ticket: 1.1-3`
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
REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TICKETS = os.path.join(REPO, "docs/tickets")
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


# Main's commits, oldest first, as (time, ticket id or None).
def get_main_commits():
	log = subprocess.check_output(["git", "-C", REPO, "log", "main", "--first-parent", "--reverse", "--format=%cI%x00%(trailers:key=Ticket,valueonly,separator=)%x1e"], text=True)
	commits = []
	for record in log.split("\x1e"):
		if record.strip():
			time, ticket_id = record.strip("\n").split("\x00")
			commits.append((datetime.datetime.fromisoformat(time), ticket_id.strip() or None))
	return commits


def get_tickets():
	tickets = {}
	for path in glob.glob(os.path.join(TICKETS, "*/*.md")):
		with open(path) as file:
			front = file.read().split("---", 2)
		if len(front) < 3:
			continue
		ticket_id = re.search(r"^id: \"?([^\"\n]*)\"?$", front[1], re.M)
		parent = re.search(r"^parent: \"?\[\[([^\]]+)\]\]\"?$", front[1], re.M)
		is_started = re.search(r"^started: *\S", front[1], re.M) is not None
		is_finished = re.search(r"^finished: *\S", front[1], re.M) is not None
		if ticket_id and ticket_id.group(1):
			tickets[ticket_id.group(1)] = {
				"path": path,
				"name": os.path.basename(path)[:-3],
				"parent": parent.group(1) if parent else None,
				"is_active_goal": os.path.basename(os.path.dirname(path)) == "goals" and is_started and not is_finished,
			}
	return tickets


def get_active_goal_id(tickets):
	return min(ticket_id for ticket_id, ticket in tickets.items() if ticket["is_active_goal"])


def get_parent_id(tickets, ticket_id):
	parent_name = tickets.get(ticket_id, {}).get("parent")
	return next((other_id for other_id, ticket in tickets.items() if ticket["name"] == parent_name), None)


def get_ticket_seconds(tickets, goal_id, coming_ticket_id):
	commits = get_main_commits()
	birth = commits[0][0]
	seconds = collections.Counter()
	for events in get_sessions():
		# Untagged main time since the last commit; it becomes a grill if the session then moves to a ticket branch.
		untagged = 0.0
		untagged_commit = None
		for (time, branch), (next_time, next_branch) in zip(events, events[1:]):
			gap = (next_time - time).total_seconds()
			if time < birth or not 0 <= gap <= BREAK:
				gap = 0.0
			if TICKET_BRANCH.match(branch):
				seconds[TICKET_BRANCH.match(branch).group(1)] += gap
			elif branch == "main":
				commit_index = _get_next_commit_index(commits, time)
				ticket_id = commits[commit_index][1] if commit_index is not None else coming_ticket_id
				if ticket_id:
					seconds[ticket_id] += gap
				else:
					if commit_index != untagged_commit:
						seconds[goal_id] += untagged
						untagged = 0.0
						untagged_commit = commit_index
					untagged += gap
			else:
				seconds[goal_id] += gap
			if next_branch != branch:
				if branch == "main" and TICKET_BRANCH.match(next_branch):
					grilled_id = TICKET_BRANCH.match(next_branch).group(1)
					seconds[get_parent_id(tickets, grilled_id) or goal_id] += untagged
				else:
					seconds[goal_id] += untagged
				untagged = 0.0
		seconds[goal_id] += untagged
	return seconds


# The first main commit at or after the time, or None while its work is uncommitted.
def _get_next_commit_index(commits, time):
	for index, (commit_time, _ticket_id) in enumerate(commits):
		if commit_time >= time:
			return index
	return None


def get_hours(seconds):
	return round(seconds / 360) / 10


def write_hours(path, hours):
	with open(path) as file:
		front = file.read().split("---", 2)
	if re.search(r"^hours:.*$", front[1], re.M):
		front[1] = re.sub(r"^hours:.*$", "hours: %g" % hours, front[1], flags=re.M)
	else:
		front[1] = re.sub(r"^(finished:.*)$", r"\1\nhours: %g" % hours, front[1], flags=re.M)
	with open(path, "w") as file:
		file.write("---".join(front))


def _has_hours(path):
	with open(path) as file:
		return re.search(r"^hours: *\S", file.read().split("---", 2)[1], re.M) is not None


def main():
	is_writing = "--write" in sys.argv
	coming_ticket_id = next((argument.split("=", 1)[1] for argument in sys.argv if argument.startswith("--ticket=")), None)
	tickets = get_tickets()
	goal_id = get_active_goal_id(tickets)
	seconds = get_ticket_seconds(tickets, goal_id, coming_ticket_id)
	hours = {ticket_id: get_hours(value) for ticket_id, value in seconds.items() if ticket_id in tickets}
	# Overhead takes up the rounding, so the hours sum to the project's active time.
	hours[goal_id] = round(get_hours(sum(seconds.values())) - sum(value for ticket_id, value in hours.items() if ticket_id != goal_id), 1)
	for ticket_id in sorted(hours):
		if hours[ticket_id] == 0 and not _has_hours(tickets[ticket_id]["path"]):
			continue
		if is_writing:
			write_hours(tickets[ticket_id]["path"], hours[ticket_id])
		print("%-14s %-30s %4g h" % (ticket_id, tickets[ticket_id]["name"], hours[ticket_id]))
	print("%-45s %4g h" % ("total", sum(hours.values())))


if __name__ == "__main__":
	main()
