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
repos[rj1.su]=$HOME/web/rj1.su
repos[recaptcha-prank]=$HOME/playground/recaptcha-prank
repos[aoc]=$HOME/playground/aoc
repos[rofimpd]=$HOME/playground/rofimpd
repos[chatgpt-irc]=$HOME/playground/chatgpt-irc

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
rsync -azvhP public/ fktown:/usr/jails/http/home/rj1/web/rj1.su/public

rm -rf $HOME/tmp
