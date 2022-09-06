---
title: manage separate git identities
date: "2022-07-03"
---

if you work on a lot of different projects using git, it can be tricky to manage
identities and easy to mistakenly make commits w/ your default user information.
creating a simple git alias for managing git identities can help.

first, configure git so each repository requires its own user configuration in
order to make commits

```shell
git config --global user.useConfigOnly true
```

now, set up an `id` alias in your `.gitconfig` file

```
[alias]
    id = "!f() { \
            git config user.name \"$(git config user.$1.name)\"; \
            git config user.email \"$(git config user.$1.email)\"; \
        if [[ $(git config user.$1.signingkey) ]]; then \
            git config user.signingkey \"$(git config user.$1.signingkey)\"; \
            git config commit.gpgsign true; \
        else \
            git config --unset user.signingkey; \
            git config --unset commit.gpgsign; \
        fi; \
        if [[ $(git config user.$1.sshkey) ]]; then \
            git config core.sshCommand \"ssh -i $HOME/.ssh/$(git config user.$1.sshkey)\"; \
        else \
            git config --unset core.sshCommand; \
        fi \
        }; f"
```

now you're able to set up individual git identities, for example:

```shell
git config --global user.rj1.name "rj1"
git config --global user.rj1.email "rj1@riseup.net"
git config --global user.rj1.signingkey "F042A0B6CB41FDA2"
git config --global user.rj1.sshkey "rj1"
```

signingkey is the gpg fingerprint to be used, sshkey is the name of a private
ssh key file stored in ~/.ssh. e.g. `~/.ssh/rj1`. gpg/ssh keys are optional.

now when you're working in a git repo and try to commit something, it won't work
until you've chosen an identity to be used for that specific repository. this
can be done using the git alias we've just created:

```
git id rj1
```

now the commits you make in that repo will be using that identity.

you can add as many identities as you'd like.

have fun!

