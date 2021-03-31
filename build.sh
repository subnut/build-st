#!/bin/sh

echo '# Cloning repo'
cd "$(dirname "$0")"
test -d st && rm -rvf st
git clone git://git.suckless.org/st --depth 1
cd st

### Patches
echo '# Applying patches'

# Bold is not bright
# https://st.suckless.org/patches/bold-is-not-bright
echo '- Bold is not bright'
curl https://st.suckless.org/patches/bold-is-not-bright/st-bold-is-not-bright-20190127-3be4cf1.diff | patch

# Boxdraw
# https://st.suckless.org/patches/boxdraw
echo '- Boxdraw'
curl https://st.suckless.org/patches/boxdraw/st-boxdraw_v2-0.8.3.diff | patch

# Scrollback
# https://st.suckless.org/patches/scrollback
echo '- Scrollback'
curl https://st.suckless.org/patches/scrollback/st-scrollback-0.8.4.diff | patch

echo '- Mouse scrollback support'
echo "  NOTE: First hunk (config.def.h) is bound to FAIL, it's OK"
curl https://st.suckless.org/patches/scrollback/st-scrollback-mouse-altscreen-20200416-5703aa0.diff | patch

### Patches End

echo '# Copying config'
cp -v config.def.h config.h

echo '# Patching config'
cat ../config.patch | patch

echo '# Building'
make

echo '# Done building'
echo 'Run `make install DESTDIR="/" PREFIX="usr"` to install'
