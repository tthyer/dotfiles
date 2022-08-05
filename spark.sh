#!/usr/bin/env bash

java_path=$(brew --prefix openjdk@11)
jdk_link_path=/Library/Java/JavaVirtualMachines/openjdk-11.jdk
echo "! test -h ${jdk_link_path} && sudo ln -sfn ${java_path}/libexec/openjdk.jdk ${jdk_link_path}" > ~/.config-java-spark.sh
echo "export PATH=${java_path}/bin:${PATH}" >> ~/.config-java-spark.sh
echo "export CPPFLAGS=-I${java_path}/include" >> ~/.config-java-spark.sh
java_home=$(/usr/libexec/java_home)
echo "export JAVA_HOME=${java_home}" >> ~/.config-java-spark.sh
echo "launchctl setenv JAVA_HOME ${java_home}" >> ~/.config-java-spark.sh

## configure
chmod +x ~/.config-java-spark.sh
COMMAND='source ~/.config-java-spark.sh'
grep -qF -- "$COMMAND" ~/.bash_profile || echo "$COMMAND" >> ~/.bash_profile
