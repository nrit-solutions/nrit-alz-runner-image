#!/bin/bash
#
# Tells the idle watchdog whether GitHub is leaving a job on the queue that
# this runner could have served.
# Environment variables that need to be set up:
# * ACCESS_TOKEN, a token with Actions read on the repository
# * REPO_URL, the repository the runner is registered on
# * LISTENING_SINCE, the UTC time the runner came online (YYYY-MM-DDTHH:MM:SSZ)
# Exit codes: 0 no such job, 1 at least one such job, 2 the queue could not be read.

set -o pipefail

_GITHUB_HOST=${GITHUB_HOST:-github.com}
if [[ ${_GITHUB_HOST} == "github.com" || ${_GITHUB_HOST} == *.ghe.com ]]; then
  _API="https://api.${_GITHUB_HOST}"
else
  _API="https://${_GITHUB_HOST}/api/v3"
fi

_REPO=${REPO_URL#*://*/}
_REPO=${_REPO%/}

# The header goes through stdin because jobs run as another user and can read any process's arguments.
actions_api() {
  curl -fsSL --max-time 20 \
    -H @- \
    -H "Accept: application/vnd.github+json" \
    "${_API}/repos/${_REPO}/actions/$1" <<<"Authorization: Bearer ${ACCESS_TOKEN}"
}

# A later job of a run that has already started leaves the run in_progress, so queued runs alone miss it.
for run_status in queued in_progress; do
  run_ids=$(actions_api "runs?status=${run_status}&per_page=100" | jq -r '.workflow_runs[].id') || exit 2

  for run_id in ${run_ids}; do
    servable=$(actions_api "runs/${run_id}/jobs?filter=latest&per_page=100" | jq \
      --arg since "${LISTENING_SINCE}" \
      --arg extra_labels "${LABELS:-default}" '
        (["self-hosted", "linux", "x64"] + ($extra_labels | ascii_downcase | split(","))) as $runner_labels
        | [.jobs[]
           | select(.status == "queued" and .created_at < $since)
           | select(all(.labels[]; ascii_downcase as $label | $runner_labels | index($label)))]
        | length') || exit 2
    [[ ${servable} -gt 0 ]] && exit 1
  done
done

exit 0
