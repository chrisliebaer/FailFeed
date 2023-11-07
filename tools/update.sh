#!/bin/bash

set -eo pipefail

# This script is called by the GitHub action workflow periodically to check for new updates to ElitismHelper.
# If an update is found, the script will commit the changes. A later step in the workflow will create a pull request, if necessary.
# If the hashes are different, there is an update and a PR needs to be updated, which will be done by the workflow.
# The workflow will ensure that commits based on the same ElitismHelper commit are resulting in the same commit hash.

EHDB_REPO="https://github.com/amki/ElitismHelper"
EHDB_FILE="db/EHDB.lua"

# redirect GIT_ENV to /dev/null on local runs
GITHUB_ENV="${GITHUB_ENV:-/dev/null}"

ehdb_git="$(mktemp -d /tmp/ehdb.XXXXXX)"
trap 'rm -rf "$ehdb_git"' EXIT
echo "Cloning ElitismHelper repository to $ehdb_git"
git clone --depth=1 "$EHDB_REPO" "$ehdb_git"

# Hash the current version database.
old_hash="$(sha256sum "$EHDB_FILE" | cut -d' ' -f1)"

# Fetch the latest version of ElitismHelper and extract the spell database.
./tools/fetchDB.sh "$ehdb_git/ElitismHelper.lua" "$EHDB_FILE"

new_hash="$(sha256sum "$EHDB_FILE" | cut -d' ' -f1)"

echo "Old hash: $old_hash"
echo "New hash: $new_hash"

# If hashes are the same, there is no update.
if [[ "$old_hash" == "$new_hash" ]]; then
	echo "No update found. ElitismHelper is up to date."
	exit 0
fi

# If new hash matches the stored hash, there is an update, but a PR has already been created and we don't need to do anything.
if [[ "$new_hash" == "$stored_hash" ]]; then
	echo "Update found, but a pull request has already been created. Nothing to do."
	exit 0
fi

# If we get here, there is an update and we need to commit the changes.
echo "Update found. Committing changes."

# At this point we need to collect some information from the ElitismHelper repository.
# Since we are already inside a git repository, we need to tell git to use the ElitismHelper repository in the $ehdb_git directory.
# Using same commit date as ElitismHelper to create the same commit hash even on multiple runs.
EHDB_GIT_COMMIT="$(git --git-dir="$ehdb_git/.git" rev-parse HEAD)"
EHDB_GIT_SHORT_COMMIT="$(git --git-dir="$ehdb_git/.git" rev-parse --short HEAD)"
GIT_AUTHOR_DATE="$(git --git-dir="$ehdb_git/.git" show -s --format=%ai "$EHDB_GIT_COMMIT")"

git config user.name "GitHub"
git config user.email "noreply@github.com"

git add "$EHDB_FILE"
git commit -m "🍱 Update ElitismHelper database to $EHDB_GIT_SHORT_COMMIT" --date="$GIT_AUTHOR_DATE"

# fix date of commit to match ElitismHelper
git rebase --committer-date-is-author-date HEAD~1

# Pass details to the GitHub action workflow.
echo "pr_title=🍱 Update ElitismHelper database to $EHDB_GIT_SHORT_COMMIT" >> "$GITHUB_OUTPUT"
echo "pr_body=This PR updates the ElitismHelper database to the latest version of ElitismHelper ($EHDB_GIT_SHORT_COMMIT)." >> "$GITHUB_OUTPUT"
