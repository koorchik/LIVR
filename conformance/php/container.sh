. ./common.sh
PACKAGE=validator/livr
SOURCE=packagist

composer install --quiet --no-interaction --no-progress || fail "composer install validator/livr failed"
php harness.php
