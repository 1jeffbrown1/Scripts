# to make these system wide, add them to the /etc/bash.bachrc file

alias ls="ls -Cahgl --group-directories-first --color=auto"
alias cls="clear"
alias grep='grep --color=auto'
alias kgap='k get pods -A -o='custom-columns=Name:{.metadata.name},Namespace:{.metadata.namespace},Node:{.spec.nodeName},Status:{.status.phase}' --sort-by=.metadata.namespace'

