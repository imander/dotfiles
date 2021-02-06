BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

function _ssh_connection() {
  [ -z ${SSH_TTY+x} ] || echo -n "${RED}SSH:${NC}"
}

function _user_shell() {
  s=${1:-$SHELL}
  echo -n "${RED}$(tr -cd '[:alnum:]' <<<$s)${NC}"
}

PS1="
$(_ssh_connection)${GREEN}\u@\h:$(_user_shell $0) ${BLUE}\w${NC}\n▶ "

test -s ~/.env && source ~/.env || true
test -f ~/.fzf.bash && source ~/.fzf.bash
