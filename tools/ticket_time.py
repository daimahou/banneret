"""Active time per ticket, from the Claude Code session transcripts.

- A ticket gets the time on main that ends in a commit carrying `Ticket: <its id>`: a note's breakdown, a leaf's spec and grill.
- A leaf also gets the time on its branch: its implementation.
- Untagged time on main just before a session moves to a ticket branch is that ticket's grill; it goes to the ticket.
- The rest is overhead (setup, docs, tracker), written on the active goal, so every ticket's hours sum to the project's active time.
- A ticket's `extra_hours`, time worked outside any session (art, playtesting), is added to its hours.
- A ticket with children also gets `total_hours`: its own hours and all its descendants'.

Run before every commit on main: main time since the last commit goes to the coming commit's ticket, or to the active goal. A gap over 15 minutes is a break. Hours are rounded to the tenth.

    python3 tools/ticket_time.py                         # every ticket's hours
    python3 tools/ticket_time.py --write                 # also writes them as `hours` in the tickets
    python3 tools/ticket_time.py --write --ticket=1.1-3  # the coming commit carries `Ticket: 1.1-3`
    python3 tools/ticket_time.py --gaps=2026-10-23        # the breaks dropped that day, to ask about; today without a date
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
# A longer gap is the end of the day, not a break worth asking about.
LONGEST_GAP = 4 * 60 * 60
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
		extra_hours = re.search(r"^extra_hours: *([\d.]+)", front[1], re.M)
		if ticket_id and ticket_id.group(1):
			tickets[ticket_id.group(1)] = {
				"path": path,
				"name": os.path.basename(path)[:-3],
				"parent": parent.group(1) if parent else None,
				"is_active_goal": os.path.basename(os.path.dirname(path)) == "goals" and is_started and not is_finished,
				"extra_hours": float(extra_hours.group(1)) if extra_hours else 0.0,
			}
	return tickets


def get_active_goal_id(tickets):
	return min(ticket_id for ticket_id, ticket in tickets.items() if ticket["is_active_goal"])


def get_parent_id(tickets, ticket_id):
	parent_name = tickets.get(ticket_id, {}).get("parent")
	return next((other_id for other_id, ticket in tickets.items() if ticket["name"] == parent_name), None)


def get_ticket_seconds(goal_id, coming_ticket_id):
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
					seconds[TICKET_BRANCH.match(next_branch).group(1)] += untagged
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


# Its own hours and all its descendants'.
def get_total_hours(tickets, hours, ticket_id):
	children = [child_id for child_id in tickets if get_parent_id(tickets, child_id) == ticket_id]
	return round(hours.get(ticket_id, 0.0) + sum(get_total_hours(tickets, hours, child_id) for child_id in children), 1)


# Sets the field, after `after_field` when it is new.
def write_field(path, field, value, after_field):
	with open(path) as file:
		front = file.read().split("---", 2)
	if re.search(r"^%s:.*$" % field, front[1], re.M):
		front[1] = re.sub(r"^%s:.*$" % field, "%s: %g" % (field, value), front[1], flags=re.M)
	else:
		front[1] = re.sub(r"^(%s:.*)$" % after_field, r"\1\n%s: %g" % (field, value), front[1], flags=re.M)
	with open(path, "w") as file:
		file.write("---".join(front))


def _has_field(path, field):
	with open(path) as file:
		return re.search(r"^%s: *\S" % field, file.read().split("---", 2)[1], re.M) is not None


# Each break dropped from the active time on the day, as its start, its end and the branch it fell on.
def get_gaps(day):
	gaps = []
	for events in get_sessions():
		for (time, branch), (next_time, _next_branch) in zip(events, events[1:]):
			gap = (next_time - time).total_seconds()
			if time.astimezone().date() == day and BREAK < gap <= LONGEST_GAP:
				gaps.append((time.astimezone(), next_time.astimezone(), branch))
	return sorted(gaps)


def print_gaps(day):
	for start, end, branch in get_gaps(day):
		print("%s-%s  %3d min  on %s" % (start.strftime("%H:%M"), end.strftime("%H:%M"), (end - start).total_seconds() // 60, branch))


def main():
	gaps_day = next((argument.partition("=")[2] for argument in sys.argv if argument.startswith("--gaps")), None)
	if gaps_day is not None:
		print_gaps(datetime.date.fromisoformat(gaps_day) if gaps_day else datetime.date.today())
		return
	is_writing = "--write" in sys.argv
	coming_ticket_id = next((argument.split("=", 1)[1] for argument in sys.argv if argument.startswith("--ticket=")), None)
	tickets = get_tickets()
	goal_id = get_active_goal_id(tickets)
	seconds = get_ticket_seconds(goal_id, coming_ticket_id)
	hours = {ticket_id: get_hours(value) for ticket_id, value in seconds.items() if ticket_id in tickets}
	# Overhead takes up the rounding, so the hours sum to the project's active time.
	hours[goal_id] = round(get_hours(sum(seconds.values())) - sum(value for ticket_id, value in hours.items() if ticket_id != goal_id), 1)
	for ticket_id, ticket in tickets.items():
		if ticket["extra_hours"]:
			hours[ticket_id] = round(hours.get(ticket_id, 0.0) + ticket["extra_hours"], 1)
	for ticket_id in sorted(tickets):
		path = tickets[ticket_id]["path"]
		own = hours.get(ticket_id, 0.0)
		has_children = any(get_parent_id(tickets, child_id) == ticket_id for child_id in tickets)
		total = get_total_hours(tickets, hours, ticket_id) if has_children else 0.0
		is_own_shown = own != 0 or _has_field(path, "hours")
		is_total_shown = total != 0 or _has_field(path, "total_hours")
		if not is_own_shown and not is_total_shown:
			continue
		if is_writing:
			if is_own_shown:
				write_field(path, "hours", own, "finished")
			if is_total_shown:
				write_field(path, "total_hours", total, "hours" if is_own_shown else "finished")
		print("%-14s %-30s %5g h%s" % (ticket_id, tickets[ticket_id]["name"], own, "   total %g h" % total if is_total_shown else ""))
	print("%-45s %5g h" % ("total", round(sum(hours.values()), 1)))


if __name__ == "__main__":
	main()
