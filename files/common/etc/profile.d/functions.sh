# Restart bash
function restart() {
	exec $SHELL $SHELL_ARGS "$@"
}

# cd to ~, clear screen, and restart bash
function rsrc() {
	cd && clear && restart
}

# Create new directory and enter it.
function mkd() { mkdir -p "$@" && cd "$_" || exit; }

# Display pids of commands.
function pids() { pgrep -a "$@"; }

# Do an ls after cd.
function cd() { builtin cd "$@" && ls; }
