#!/bin/sh

echo '# Cloning repo'
cd "$(dirname "$0")"
test -d st && rm -rvf st
git clone git://git.suckless.org/st --depth 1
cd st

### Patches ###########################################
echo '# Applying patches'

## Bold is not bright
# https://st.suckless.org/patches/bold-is-not-bright
echo '- Bold is not bright'
curl https://st.suckless.org/patches/bold-is-not-bright/st-bold-is-not-bright-20190127-3be4cf1.diff | patch

## Boxdraw
# https://st.suckless.org/patches/boxdraw
echo '- Boxdraw'
curl https://st.suckless.org/patches/boxdraw/st-boxdraw_v2-0.8.3.diff | patch

## Scrollback
# https://st.suckless.org/patches/scrollback
echo '- Scrollback'
curl https://st.suckless.org/patches/scrollback/st-scrollback-0.8.4.diff | patch

echo '- Mouse scrollback support'
echo "  NOTE: First hunk (config.def.h) is bound to FAIL, it's OK"
curl https://st.suckless.org/patches/scrollback/st-scrollback-mouse-altscreen-20200416-5703aa0.diff | patch

echo '# Done patching'
### Patches End ###########################################

echo '# Copying config'
cp -v config.def.h config.h

echo '# Patching config'
cat ../config.patch | patch

echo '# Building'
make || exit $?

echo '# Done building'
echo -n 'Install to ~/.local/bin ? [Y/n] '
read ANSWER

if test -z "$ANSWER" || echo "$ANSWER" | grep -q '^[yY]'
then
    echo '# Installing'
    make install DESTDIR='~/.local' PREFIX=''
else
    echo '# Installation skipped'
fi

echo '# All done!'
# vim: et ts=4 sts=0 sw=0 :
