# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory nomatch
bindkey -v
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/Users/sebastian/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

# Make history awesome
setopt INC_APPEND_HISTORY

# Use zsh-compeletions
fpath=(/usr/local/share/zsh-completions $fpath)

# Set Default Editor (change 'Nano' to the editor of your choice)
export EDITOR=vim
export SHELL=/urs/local/bin/zsh

# following the INSTALL.md file from stylight-core:
    export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH
    export WORKON_HOME=$HOME/.virtualenvs
    source /usr/local/bin/virtualenvwrapper.sh


# Aliases
alias cp='cp -iv'                           # Preferred 'cp' implementation
alias mv='mv -iv'                           # Preferred 'mv' implementation
alias mkdir='mkdir -pv'                     # Preferred 'mkdir' implementation
alias ls='ls -FGlAhp'                       # Preferred 'ls' implementation
alias less='less -FSRXc'                    # Preferred 'less' implementation

alias ..='cd ..'
alias tac='tail -r'
# alias docker_init='eval "$(docker-machine env dev)"'
alias mview='mvim -R'

alias grb='git fetch && git rebase origin/master'
alias gst='git status'
alias fab="venvexec.sh ./ fab"

# plugins
# source ~/.zsh_plugins/gitfast-zsh-plugin/git-prompt.sh

autoload -Uz vcs_info

# git checker:
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git*' check-for-changes true
zstyle ':vcs_info:git*' get-revision true
zstyle ':vcs_info:git*' formats "[%b%m]%c%u" # branch % remote tracking
# zstyle ':vcs_info:*+*:*' debug true
zstyle ':vcs_info:git*+set-message:*' hooks git-st git-untracked

+vi-git-untracked(){
    if [[ $(git rev-parse --is-inside-work-tree 2> /dev/null) == 'true' ]] && \
        git status --porcelain | grep '??' &> /dev/null ; then
        # This will show the marker if there are any untracked files in repo.
        # If instead you want to show the marker only if there are untracked
        # files in $PWD, use:
        #[[ -n $(git ls-files --others --exclude-standard) ]] ; then
        hook_com[staged]+=' ?'
    fi
}


### git: Show +N/-N when your local branch is ahead-of or behind remote HEAD.
# Make sure you have added misc to your 'formats':  %m
function +vi-git-st() {
    local ahead behind
    local -a gitstatus

    # for git prior to 1.7
    # ahead=$(git rev-list origin/${hook_com[branch]}..HEAD | wc -l)
    
    ahead=$(git rev-list ${hook_com[branch]}@{upstream}..HEAD 2>/dev/null | wc -l)
    (( $ahead )) && gitstatus+=( " ⬆ ${ahead//[^[:alnum:]]/}" )

    # for git prior to 1.7
    # behind=$(git rev-list HEAD..origin/${hook_com[branch]} | wc -l)
    behind=$(git rev-list HEAD..${hook_com[branch]}@{upstream} 2>/dev/null | wc -l)
    (( $behind )) && gitstatus+=( " ⬇ ${behind[^[:alnum:]]/}" )

    hook_com[misc]+=${(j:/:)gitstatus}
}

nl='
'

autoload -U colors && colors

precmd() {
    # As always first run the system so everything is setup correctly.
    vcs_info
    # And then just set PS1, RPS1 and whatever you want to. 
    # See "man zshmisc" for details on how to
    # make this less readable. :-)

#   # are we in a virtual-env? if: show name
    if [ -n "$VIRTUAL_ENV" ]; then
        venv_name='('$(basename $VIRTUAL_ENV)') '
    else
        venv_name=''
    fi

    if [ -z "${vcs_info_msg_0_}" ]; then
        # Oh hey, nothing from vcs_info, so we got more space.
        # Let's print a longer part of $PWD...
        PS1="%{$reset_color%}%{$fg[yellow]%}%~%{$reset_color%}${nl}%{$fg_bold[white]%}${venv_name}➤➤➤ %{$reset_color%} "
        unset RPS1
    else
        # vcs_info found something
        if git diff --ignore-submodules=dirty --exit-code --quiet 2>/dev/null >&2; then
            if git diff --ignore-submodules=dirty --exit-code --cached --quiet 2>/dev/null >&2; then
                repo="%{$reset_color%}%{$fg[green]%}${vcs_info_msg_0_}%{$reset_color%}"
            else
                repo="%{$reset_color%}%{$fg[cyan]%}${vcs_info_msg_0_}%{$reset_color%}"
            fi
        else
            repo="%{$reset_color%}%{$fg[red]%}${vcs_info_msg_0_}%{$reset_color%}"
        fi

        PS1="%{$reset_color%}%{$fg[yellow]%}%~%{$reset_color%}${nl}%{$fg_bold[white]%}${venv_name}➤➤➤ %{$reset_color%} "
        RPS1=${repo}
    fi
}