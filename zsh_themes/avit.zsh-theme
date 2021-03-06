# AVIT ZSH Theme

if [[ $USER == "root" ]]; then
  CARETCOLOR="$FG[196]"
else
  CARETCOLOR="$FG[007]"
fi

PROMPT='
$(_user_host)$(_user_shell $0) ${_current_dir}$(git_prompt_info) $(_kubectl_config)
%{$CARETCOLOR%}▶%{$resetcolor%} '

PROMPT2='%{$CARETCOLOR%}◀%{$reset_color%} '

RPROMPT='%{$(echotc UP 1)%}$(git_prompt_status) ${_return_status}%{$(echotc DO 1)%}'

local _current_dir="%{$fg_bold[blue]%}%3~%{$reset_color%} "
local _return_status="%{$fg_bold[red]%}%(?..⍉)%{$reset_color%}"
local _hist_no="%{$fg[grey]%}%h%{$reset_color%}"

function _current_dir() {
  local _max_pwd_length="65"
  if [[ $(echo -n $PWD | wc -c) -gt ${_max_pwd_length} ]]; then
    echo "%{$fg_bold[blue]%}%-2~ ... %3~%{$reset_color%} "
  else
    echo "%{$fg_bold[blue]%}%~%{$reset_color%} "
  fi
}

function _user_host() {
  if [[ $USER == "root" ]]; then
    UCOLOR="$FG[196]%n$FG[244]"
  else
    UCOLOR="$FG[244]%n"
  fi
  local user_ssh=''
  if [[ ! -z "$SSH_TTY" ]]; then
    user_ssh="%{$FG[196]%}SSH:%{$reset_color%}"
  fi
  echo "${user_ssh}%{$UCOLOR%}@%m%{$reset_color%}:"
}

function _user_shell() {
  s=$(sed 's/-//' <<<${1:-$SHELL})
  echo "$FG[196]$(basename $s | tr -cd '[:alnum:]')%{$reset_color%}"
}

function _kubectl_config() {
  if which kubectl &> /dev/null; then
    context=$(kubectl config current-context 2>/dev/null)
    if [[ -n "$context" ]]; then
      echo "%{$FG[213]%}$context%{$reset_color%}"
    fi
  fi
}

MODE_INDICATOR="%{$fg_bold[yellow]%}❮%{$reset_color%}%{$fg[yellow]%}❮❮%{$reset_color%}"

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[green]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"

ZSH_THEME_GIT_PROMPT_DIRTY=" %{$FG[196]%}✗%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN=" %{$fg[green]%}✔%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_ADDED="%{$fg[green]%}✚ "
ZSH_THEME_GIT_PROMPT_MODIFIED="%{$fg[yellow]%}⚑ "
ZSH_THEME_GIT_PROMPT_DELETED="%{$FG[196]%}✖ "
ZSH_THEME_GIT_PROMPT_RENAMED="%{$fg[blue]%}▴ "
ZSH_THEME_GIT_PROMPT_UNMERGED="%{$fg[cyan]%}§ "
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg[white]%}◒ "

# Colors vary depending on time lapsed.
ZSH_THEME_GIT_TIME_SINCE_COMMIT_SHORT="%{$fg[green]%}"
ZSH_THEME_GIT_TIME_SHORT_COMMIT_MEDIUM="%{$fg[yellow]%}"
ZSH_THEME_GIT_TIME_SINCE_COMMIT_LONG="%{$FG[196]%}"
ZSH_THEME_GIT_TIME_SINCE_COMMIT_NEUTRAL="%{$fg[white]%}"

export GREP_COLOR='1;33'

