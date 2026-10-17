. ./common.sh
PACKAGE=lua-livr
SOURCE=luarocks

apk add --no-cache --quiet lua5.4 lua5.4-dev luarocks5.4 build-base pcre2-dev >/dev/null \
    || fail "apk add lua toolchain failed"
# lrexlib-pcre2 and luautf8 are optional for lua-LIVR: without them the "like" rule
# is unavailable and to_lc/to_uc are not Unicode-aware (see lua-LIVR docs).
for rock in lua-livr dkjson luafilesystem lrexlib-pcre2 luautf8; do
    luarocks-5.4 install "$rock" >/dev/null || fail "luarocks install $rock failed"
done
lua5.4 harness.lua
