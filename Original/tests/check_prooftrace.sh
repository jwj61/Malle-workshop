#!/bin/sh

set -u

SCRIPT_DIR=$(CDPATH= cd "$(dirname "$0")" 2>/dev/null && pwd)
ROOT=$(CDPATH= cd "$SCRIPT_DIR/.." 2>/dev/null && pwd)

cd "$ROOT" || exit 2

failures=0

ok() {
	printf '%s\n' "ok - $1"
}

fail() {
	printf '%s\n' "not ok - $1" >&2
	failures=$((failures + 1))
}

require_file() {
	if [ ! -f "$1" ]; then
		fail "missing required file $1"
		return 1
	fi
	return 0
}

require_compact_contains() {
	file=$1
	needle=$2
	label=$3

	if awk -v needle="$needle" '
		{
			line = $0
			gsub(/[[:space:]]/, "", line)
			buffer = buffer line
			if (index(buffer, needle) != 0) {
				found = 1
				exit
			}
			if (length(buffer) > 2048) {
				buffer = substr(buffer, length(buffer) - 2047)
			}
		}
		END { exit found ? 0 : 1 }
	' "$file"; then
		ok "$label"
	else
		fail "$label: expected $file to contain $needle after whitespace normalization"
	fi
}

require_function_first_string() {
	file=$1
	fn_name=$2
	expected=$3
	label=$4

	if awk -v fn_name="$fn_name" -v expected="$expected" '
		BEGIN {
			function_start = fn_name "[[:space:]]*:=[[:space:]]*function"
		}
		$0 ~ function_start {
			in_function = 1
		}
		in_function && $0 ~ /return[[:space:]]*\[/ {
			after_return = 1
		}
		in_function && after_return {
			if (match($0, /"[^"]*"/)) {
				first = substr($0, RSTART + 1, RLENGTH - 2)
				status = (first == expected ? 0 : 1)
				done = 1
				exit
			}
		}
		in_function && $0 ~ /end[[:space:]]+function/ {
			done = 1
			status = 1
			exit
		}
		END {
			if (!done) {
				status = 1
			}
			exit status
		}
	' "$file"; then
		ok "$label"
	else
		fail "$label: $fn_name does not have first prooftrace entry \"$expected\""
	fi
}

require_function_contains() {
	file=$1
	fn_name=$2
	needle=$3
	label=$4

	if awk -v fn_name="$fn_name" -v needle="$needle" '
		BEGIN {
			function_start = fn_name "[[:space:]]*:=[[:space:]]*function"
		}
		$0 ~ function_start {
			in_function = 1
		}
		in_function && index($0, needle) != 0 {
			found = 1
			exit
		}
		in_function && $0 ~ /end[[:space:]]+function/ {
			exit
		}
		END { exit found ? 0 : 1 }
	' "$file"; then
		ok "$label"
	else
		fail "$label: $fn_name does not contain $needle"
	fi
}

check_conjecture_true_has_prooftrace() {
	file=$1
	window=4

	if awk -v window="$window" -v file="$file" '
		function is_conjecture_true(s) {
			return s ~ /`conjecture[[:space:]]*:=[[:space:]]*true/ ||
				s ~ /(^|[^[:alnum:]_])conjecture[[:space:]]*:=[[:space:]]*true/
		}
		function is_prooftrace_assignment(s) {
			return s ~ /`prooftrace[[:space:]]*:=/ ||
				s ~ /(^|[^[:alnum:]_])prooftrace[[:space:]]*:=/
		}
		{
			lines[NR] = $0
			if (is_conjecture_true($0)) {
				true_lines[++true_count] = NR
			}
		}
		END {
			status = 0
			for (i = 1; i <= true_count; i++) {
				start = true_lines[i] - window
				stop = true_lines[i] + window
				if (start < 1) {
					start = 1
				}
				if (stop > NR) {
					stop = NR
				}

				found = 0
				for (j = start; j <= stop; j++) {
					if (is_prooftrace_assignment(lines[j])) {
						found = 1
					}
				}

				if (!found) {
					printf "%s:%d: conjecture true assignment has no prooftrace assignment within %d lines\n", file, true_lines[i], window > "/dev/stderr"
					status = 1
				}
			}
			exit status
		}
	' "$file"; then
		ok "$file conjecture true assignments have nearby prooftrace assignments"
	else
		fail "$file has conjecture true assignments without nearby prooftrace assignments"
	fi
}

require_file "utils/InitializeDatabase.mag"
require_file "CreateDatabase.mag"

require_compact_contains "utils/InitializeDatabase.mag" "prooftrace:SeqEnum" "record format includes prooftrace:SeqEnum"
require_compact_contains "CreateDatabase.mag" "prooftrace:SeqEnum" "saved-file schema includes prooftrace:SeqEnum"

require_function_first_string "utils/InitializeDatabase.mag" "DirectProofTrace" "Direct reference" "DirectProofTrace first entry"
require_function_first_string "utils/InitializeDatabase.mag" "ALOWWAbelianProofTrace" "ALOWW abelian" "ALOWWAbelianProofTrace first entry"
require_function_first_string "utils/InitializeDatabase.mag" "ALOWWS3ProofTrace" "ALOWW S3" "ALOWWS3ProofTrace first entry"

require_function_contains "utils/InitializeDatabase.mag" "ALOWWAbelianProofTrace" '"ALOWW Thm 1.11"' "ALOWW abelian theorem reference"
require_function_contains "utils/InitializeDatabase.mag" "ALOWWS3ProofTrace" '"ALOWW Thm 1.9"' "ALOWW S3 theorem reference"

for source_file in CreateDatabase.mag utils/*.mag; do
	check_conjecture_true_has_prooftrace "$source_file"
done

if [ "$failures" -ne 0 ]; then
	printf '%s\n' "prooftrace static checks failed: $failures failure(s)" >&2
	exit 1
fi

printf '%s\n' "prooftrace static checks passed"
