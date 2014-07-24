## Remember, set PATH in /etc/paths, not here.

test -f ~/.bashrc && source ~/.bashrc

## ENVIRONMENT VARIABLES ##
export PATH=/usr/local/bin:$PATH
export JAVA_HOME=$(/usr/libexec/java_home)
export GROOVY_HOME=/usr/local/opt/groovy/libexec

## ALIASES ##
alias hidden='ls -a | grep "^\."'
alias hiddenl='ls -l -a | grep ".*\."'

