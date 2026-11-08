. ./common.sh
PACKAGE=io.github.vlbaluk:validator-livr
SOURCE=maven

mvn -q -B dependency:copy-dependencies -DoutputDirectory=lib >mvn.log 2>&1 \
    || { cat mvn.log; fail "maven could not resolve io.github.vlbaluk:validator-livr"; }
VERSION=$(ls lib | sed -n 's/^validator-livr-\(.*\)\.jar$/\1/p')
if [ -n "${JAVA_LIVR_DIR:-}" ]; then
    # A local checkout instead of the released jar, e.g. an unreleased branch: its sources are
    # compiled against the dependencies of the released jar (the project builds with Gradle).
    rm -f lib/validator-livr-*.jar
    find "$JAVA_LIVR_DIR/src/main/java" -name '*.java' >sources.txt
    javac -nowarn -encoding UTF-8 -cp "lib/*" -d lib/local-classes @sources.txt >javac.log 2>&1 \
        || { cat javac.log; fail "javac of $JAVA_LIVR_DIR failed"; }
    VERSION=local
    export LIVR_VERSION="$VERSION"
    exec java -cp "lib/local-classes:lib/*" Harness.java
fi
export LIVR_VERSION="$VERSION"
java -cp "lib/*" Harness.java
