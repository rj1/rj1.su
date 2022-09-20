#!/bin/bash

# todo:
# - check if repos have description/url files
# - generate url file

sitewebroot=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
reposwebroot=$sitewebroot/static/repos

if [[ -d "$reposwebroot" ]]; then
    rm -rf "$reposwebroot"
    mkdir "$reposwebroot"
fi

# list of repos
declare -A repos
repos[dotfiles]=$HOME/.local/share/yadm/repo.git
repos[acro]=$HOME/playground/acro
repos[stagit]=$HOME/playground/stagit
repos[post_image]=$HOME/playground/post_image
repos[maildir]=$HOME/playground/maildir
repos[znc-oneway-relay]=$HOME/playground/znc-oneway-relay
repos[dopewars-irc]=$HOME/playground/dopewars-irc
repos[rj1.localghost.org]=$HOME/web/rj1.localghost.org
repos[recaptcha-prank]=$HOME/playground/recaptcha-prank

# generate html for each repo
args=""
for name in "${!repos[@]}"; do
    basename=$(basename ${repos[$name]})

    if [[ $name != $basename ]]; then
        mkdir -p $HOME/tmp
        cp -rf "${repos[$name]}" "$HOME/tmp/$name"
        repos[$name]=$HOME/tmp/$name
    fi

    dir="$reposwebroot/$name"
    mkdir -p "$dir"
    cd "$dir"
    stagit ${repos[$name]}

    # repo index
    if [ -f "about.html" ]; then
        ln -sf "about.html" "index.html"
    else
        ln -sf "files.html" "index.html"
    fi

    args+="${repos[$name]} "
done

cd $reposwebroot
stagit-index $args > index.html

# generate the rest of the site
cd $sitewebroot
hugo --minify

# upload
rsync -azvhP public/ rj1.localghost.org:/home/rj1/web/rj1.localghost.org/public

rm -rf public
rm -rf $reposwebroot
rm -rf $HOME/tmp

