#!/bin/sh
#mvn install:install-file -Dfile=maven-surefire-plugin-2.8.1.jar -DgroupId=org.apache.maven.surefire -DartifactId=surefire -Dversion=2.8.1 -Dpackaging=jar

#mvn install:install-file -Dfile=maven-surefire-plugin-2.8.1.jar -DpomFile=maven-surefire-plugin-2.8.1.pom
mvn install:install-file -Dfile=$1 -DpomFile=$2

#mvn install:install-file -Dfile=your-artifact-1.0.jar \
#                         [-DpomFile=your-pom.xml] \
#                         [-Dsources=src.jar] \
#                         [-Djavadoc=apidocs.jar] \
#                         [-DgroupId=org.some.group] \
#                         [-DartifactId=your-artifact] \
#                         [-Dversion=1.0] \
#                         [-Dpackaging=jar] \
#                         [-Dclassifier=sources] \
#                         [-DgeneratePom=true] \
#                         [-DcreateChecksum=true]
#mvn install:install-file -Dfile=maven-surefire-plugin-2.8.1.jar -DgroupId=org.apache.maven.surefire -DartifactId=surefire -Dversion=2.8.1 -Dpackaging=jar
#mvn plugin:download -DartifactId=maven-war-plugin -DgroupId=org.apache.maven.plugins -Dversion=2.1.1  -Dmaven.repo.remote=http://www.ibiblio.org/maven,http://maven-plugins.sourceforge.net/repository
