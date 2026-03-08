#!/usr/bin/env bash

# Only source bash_functions.sh if pathadd is not already defined
if ! declare -f pathadd &>/dev/null; then
  source "${HOME}/bash_functions.sh"
fi

java_path="$(brew --prefix openjdk)"
jdk_link_path=/Library/Java/JavaVirtualMachines/openjdk.jdk

# For the system Java wrappers to find this JDK, symlink it
! test -h "$jdk_link_path" && sudo ln -sfn "$java_path/libexec/openjdk.jdk" "$jdk_link_path"

# Add to PATH
pathadd "$java_path/bin"

java_home="$(/usr/libexec/java_home)"
export JAVA_HOME="$java_home"
launchctl setenv JAVA_HOME "$java_home"
