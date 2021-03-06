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
curl https://st.suckless.org/patches/scrollback/st-scrollback-20210507-4536f46.diff | patch

echo '- Mouse scrollback support'
echo "  NOTE: First hunk (config.def.h) is bound to FAIL, it's OK"
curl https://st.suckless.org/patches/scrollback/st-scrollback-mouse-altscreen-20200416-5703aa0.diff | patch

echo '- Environment variables support'
cat ../envvars.patch | patch

if [ $(uname) = OpenBSD ]; then
    echo '- OpenBSD patch'
    cat ../openbsd.patch | patch
fi

echo '# Done patching'
### Patches End ###########################################

echo '# Copying config'
cp -v config.def.h config.h

echo '# Patching config.h'
cat ../config.h.patch | patch

echo '# Patching config.mk'
cat ../config.mk.patch | patch

if test -z "$THEME"
then
    echo '# WARNING: $THEME not set. Prompting user to select one.'
    printf '%s\n%s\n%s\n%s\n' \
        '1) GRUVBOX_LIGHT'    \
        '2) GRUVBOX_DARK'     \
        '3) URXVT_LIGHT'      \
        '4) default'

    while true
    do
        printf '%s' 'Choose an option: [1] '
        read ANSWER
        test -z "$ANSWER" && export ANSWER=1
        case "$ANSWER" in
            (1) export THEME_FLAG=-DGRUVBOX_LIGHT; break;;
            (2) export THEME_FLAG=-DGRUVBOX_DARK;  break;;
            (3) export THEME_FLAG=-DURXVT_LIGHT;   break;;
            (4) export THEME_FLAG=;                break;;
        esac
    done
else
    export THEME_FLAG="-D$THEME"
fi

echo '# Building'
make || exit $?

echo '# Done building'
printf '%s' 'Install to ~/.local/bin ? [Y/n] '
read ANSWER

if test -z "$ANSWER" || echo "$ANSWER" | grep -q '^[yY]'
then
    echo '# Installing'
    make install DESTDIR='~/.local' PREFIX=''
else
    echo '# Installation skipped'
fi

echo '# All done!'
# vim: et ts=2 sts=0 sw=4 nowrap :
