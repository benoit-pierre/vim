#! /bin/bash

set -x

[ -r "$HOME/.makepkg.conf" ] && . "$HOME/.makepkg.conf"

cd "$(dirname "$0")" &&
. ./PKGBUILD &&
pkgver="$(git describe --tags | sed -n '/^v\([0-9.]\+\)-\([0-9]\+\)-\([0-9a-z]\+\)$/{s//\1.\2.\3/;s/-/./g;p;Q0};Q1')" &&
src="src/$pkgbase-$pkgver" &&
rm -rf src pkg &&
mkdir -p "$src" &&
cp -l archlinux.vim gvim.desktop vimrc src/ &&
sed "s/^pkgver=.*\$/pkgver=$pkgver/" PKGBUILD >PKGBUILD.tmp &&
(cd "$OLDPWD" && git ls-files -z | xargs -0 cp -a --no-dereference --parents --target-directory="$OLDPWD/$src") &&
export PACKAGER="${PACKAGER:-`git config user.name` <`git config user.email`>}" &&
makepkg --noextract --force -p PKGBUILD.tmp &&
rm -rf src pkg PKGBUILD.tmp &&
pkgname=(vim-runtime gvim) &&
sudo pacman -U --noconfirm "${pkgname[@]/%/-$pkgver-$pkgrel-`uname -m`${PKGEXT:-.pkg.tar.xz}}"

