BLUE='\033[0;34m'
GREEN='\033[0;32m'
MAGENTA='\033[0;95m'
RED='\033[0;31m'
NC='\033[0m' # No Color

function _ssh_connection() {
  [ -z ${SSH_TTY+x} ] || echo -n "${RED}SSH:${NC}"
}

function _user_shell() {
  s=${1:-$SHELL}
  echo -n "${RED}$(basename "$s" | tr -cd '[:alnum:]')${NC}"
}

function _prompt_caret() {
  if [[ $USER == "root" ]]; then
    echo "\n${RED}▶${NC} "
  else
    echo "\n▶ "
  fi
}

function _kubectl_config() {
  if which kubectl &> /dev/null; then
    context=$(kubectl config current-context 2>/dev/null)
    if [[ -n "$context" ]]; then
      echo " ${MAGENTA}$context${NC} "
    fi
  fi
}

PS1="
$(_ssh_connection)${GREEN}\u@\h:$(_user_shell $0) ${BLUE}\w${NC}$(_kubectl_config)$(_prompt_caret)"

test -s ~/.env && source ~/.env || true
test -f ~/.fzf.bash && source ~/.fzf.bash || true

# hook mise into shell
test -f ~/.local/bin/mise && eval "$(~/.local/bin/mise activate bash)" || true

