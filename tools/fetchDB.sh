#!/bin/bash

# This script is used to check and fetch updates from the ElitismHelper repository.
# It is intended to be run from the GitHub action workflow to check for new updates to the spell data.
# Arguments:
# 	$1: The path to the ElitismHelper file, containing the spell tables.
# 	$2: The path to the file to write the spell tables to.

set -eo pipefail

# Check arguments.
if [ $# -ne 2 ]; then
	echo "Usage: $0 <ElitismHelper.lua> <output.lua>"
	exit 1
fi

workdir="$(mktemp -d /tmp/ehdb.XXXXXX)"
trap 'rm -rf "$workdir"' EXIT

# Download the latest version of ElitismHelper
ehdb="$1"


# This function extracts a Lua table from a file and writes it to a new file.
# Arguments:
# 	$1: The file to extract the table from.
# 	$2: The name of the table to extract.
# 	$3: The file to write the table to.
#
# The table is extracted by assuming the following format:
# 
# local <name> = {
# 	<key> = <value>,
# 	...
# }
#
# Note that the table will end with a single closing brace on its own line.
function extractTable() {
	file="$1"
	name="$2"
	output="$3"

	# Extract the table.
	# workaround for tables with just `{}` (empty table)
	if grep -q "local $name = {.*}$" "$file"; then
		# Table is empty (both braces on same line)
		echo "local $name = {}" > "$output"
	else
		# Normal table extraction
		sed -n "/local $name = {/,/}/p" "$file" > "$output"
	fi
}

# list of tables to extract
tables=(
	"Spells"
	"SpellsNoTank"
	"Auras"
	"AurasNoTank"
	"Swings"
)

mkdir -p "$workdir/tables"
for table in "${tables[@]}"; do
	extractTable "$ehdb" "$table" "$workdir/tables/$table.lua"
done

# Write preambles to the output file.
cat << EOF > "$2"
-- This file is automatically generated by the update.sh script.
-- Do not edit this file directly, as it will be overwritten.
-- If you want to make changes, use the Overrides.lua file instead.

local _, ns = ...


EOF

# Write the extracted tables to the output file.
for table in "${tables[@]}"; do
	echo "-- Start of $table" >> "$2"
	cat "$workdir/tables/$table.lua" >> "$2"
	echo "-- End of $table" >> "$2"
done

# Write the postamble to the output file.
cat << EOF >> "$2"

ns.ehdb = {}
ns.ehdb.Spells = Spells or {}
ns.ehdb.SpellsNoTank = SpellsNoTank or {}
ns.ehdb.Auras = Auras or {}
ns.ehdb.AurasNoTank = AurasNoTank or {}
ns.ehdb.MeleeHitters = Swings or {}
EOF

