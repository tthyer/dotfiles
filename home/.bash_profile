## Remember, set PATH in /etc/paths, not here.

test -f ~/bashrc && source ~/.bashrc
export JAVA_HOME=$(/usr/libexec/java_home)

## ALIASES ##
alias cassdev='ssh tess@cassandra_titan1.dev0.aro.com'
alias cassstage='ssh tess@cassandra1.stage0.aro.com'
alias cassprod='ssh tess@cassandra1.prod0.aro.com'

alias pgdev='ssh tess@postgres1.dev0.aro.com'
alias pgstage='ssh tess@postgres1.stage0.aro.com'
alias pgprod='ssh tess@postgres1.prod0.aro.com'

