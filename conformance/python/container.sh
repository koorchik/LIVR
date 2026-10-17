. ./common.sh
PACKAGE=LIVR
SOURCE=pypi

pip install --quiet --disable-pip-version-check --root-user-action=ignore LIVR || fail "pip install LIVR failed"
python harness.py
