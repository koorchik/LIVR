. ./common.sh
PACKAGE=ruby-livr
SOURCE=rubygems

gem install --no-document ruby-livr >gem.log 2>&1 || { cat gem.log; fail "gem install ruby-livr failed"; }
ruby harness.rb
