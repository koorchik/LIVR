. ./common.sh
PACKAGE=ruby-livr
SOURCE=rubygems

# ruby-livr 2.0.0 depends on activesupport ~> 5, which needs Ruby 2.x.
# Pin transitive deps to the last releases that still work there.
gem install --no-document --silent i18n -v 1.14.8 || fail "gem install i18n failed"
gem install --no-document --silent concurrent-ruby -v 1.3.4 || fail "gem install concurrent-ruby failed"
gem install --no-document --silent ruby-livr || fail "gem install ruby-livr failed"
ruby harness.rb
