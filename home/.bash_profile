## Remember, set PATH in /etc/paths, not here.

test -f ~/bashrc && source ~/.bashrc
export JAVA_HOME=$(/usr/libexec/java_home)

## ALIASES ##
alias cassdev='ssh tess@REDACTED-HOST'
alias cassstage='ssh tess@REDACTED-HOST'
alias cassprod='ssh tess@REDACTED-HOST'

alias pgdev='ssh tess@REDACTED-HOST'
alias pgstage='ssh tess@REDACTED-HOST'
alias pgprod='ssh tess@REDACTED-HOST'

