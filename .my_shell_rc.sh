alias lc='. ranger'
alias cc='clear'
alias grep='grep --color=auto'
alias ll='exa -ahl --sort modified'
alias lt='exa --tree --sort modified'
alias ls='exa --sort modified'

alias cp="cp -i"                                                # Confirm before overwriting something
alias mv="mv -i"
alias df='df -h'                                                # Human-readable sizes
alias free='free -m'                                            # Show sizes in MB

# bare repository management alias
alias bare-config='/usr/bin/git --git-dir=$HOME/dotfiles/ --work-tree=$HOME'

jar () {
python3 /run/media/saurav/Programming/GIthub/dev/voice-assitant-python/run.py $PWD -arg $@
}

dev (){
source /run/media/saurav/Programming/GIthub/dev/bin/activate
echo "dev activated successfully"
}
# alias ls='ls --color'
LS_COLORS+=':ow=01;34'

export VISUAL=nvim;
export EDITOR=nvim;


# devour

alias mpv='devour mpv'
alias vi='nvim'
alias lg='lazygit'


# terminal rickroll!
alias rr='curl -s -L https://raw.githubusercontent.com/keroserene/rickrollrc/master/roll.sh | bash'

