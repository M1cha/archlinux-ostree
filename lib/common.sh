
# shellcheck disable=SC2059 # $1 and $2 can contain the printf modifiers
out() { printf "$1 $2\n" "${@:3}"; }
error() { out "====> ERROR:" "$@"; } >&2
warning() { out "====> WARNING:" "$@"; } >&2
msg() { out "====>" "$@"; }
die() { error "$@"; exit 1; }

arg_to_varname() {
	name="${1:2}"
	echo "${name//-/_}"
}

have_function() {
	declare -f "$1" >/dev/null
}

# This outputs code for declaring all variables to stdout. For example, if
# FOO=BAR, then running
#     declare -p FOO
# will result in the output
#     declare -- FOO="bar"
# This function may be used to re-declare all currently used variables and
# functions in a new shell.
declare_all() {
  # Remove read-only variables to avoid warnings. Unfortunately, declare +r -p
  # doesn't work like it looks like it should (declaring only read-write
  # variables). However, declare -rp will print out read-only variables, which
  # we can then use to remove those definitions.
  declare -p | grep -Fvf <(declare -rp)
  # Then declare functions
  declare -pf
}

join_by() {
	local IFS="$1"
	shift
	echo "$*"
}
