PS1='
\[\033[01;32m\]\u@\h:\[\033[00m\]\[\033[01;31m\]$0\[\033[00m\] \[\033[01;34m\]\w\[\033[00m\]\n▶ '

test -s ~/.env && . ~/.env || true


# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/imander/anaconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/imander/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/home/imander/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/home/imander/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

