
# ../bin/mvninstall.sh jackson-jaxrs-1.7.9.jar org.codehaus.jackson jackson-jaxrs 1.7.9
echo "file org.xx.name my-name version"
mvn install:install-file -Dfile=$1 \
  -DgroupId=$2 \
  -DartifactId=$3 \
  -Dversion=$4 \
  -Dpackaging=jar
