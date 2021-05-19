#!/usr/bin/env bash

java_path=$(brew --prefix openjdk@11)
echo "ln -sfn ${java_path}/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk-11.jdk" > ~/.config-java-spark.sh
echo "export PATH=${java_path}/bin:${PATH}" >> ~/.config-java-spark.sh
echo "export CPPFLAGS=-I${java_path}/include" >> ~/.config-java-spark.sh
echo "export JAVA_HOME=$(/usr/libexec/java_home)" >> ~/.config-java-spark.sh
echo "echo JAVA_HOME=$JAVA_HOME"
echo "launchctl setenv JAVA_HOME ${JAVA_HOME}" >> ~/.config-java-spark.sh

spark_home=$(brew --prefix apache-spark)
echo "export SPARK_HOME=${spark_home}" >> ~/.config-java-spark.sh 
echo "export PATH=${spark_home}/bin:$PATH" >> ~/.config-java-spark.sh

## configure
chmod +x ~/.config-java-spark.sh
COMMAND='source ~/.config-java-spark.sh'
grep -qF -- "$COMMAND" ~/.bash_profile || echo "$COMMAND" >> ~/.bash_profile

