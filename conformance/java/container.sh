. ./common.sh
PACKAGE=io.github.vlbaluk:validator-livr
SOURCE=maven

mvn -q -B dependency:copy-dependencies -DoutputDirectory=lib >mvn.log 2>&1 \
    || { cat mvn.log; fail "maven could not resolve io.github.vlbaluk:validator-livr"; }
VERSION=$(ls lib | sed -n 's/^validator-livr-\(.*\)\.jar$/\1/p')
export LIVR_VERSION="$VERSION"
java -cp "lib/*" Harness.java
