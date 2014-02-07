# dotfiles

Configuration files for Bash, Git, Rubygems, Sublime Text, and more.

## Bash

```bash
ln -s `pwd`/bash/bash_profile ~/.bash_profile
```

## Git

```bash
sudo mkdir -p /Applications/Xcode.app/Contents/Developer/usr/etc
sudo ln -s `pwd`/git/gitconfig /Applications/Xcode.app/Contents/Developer/usr/etc/gitconfig
ln -s `pwd`/git/gitignore_global ~/.gitignore_global
```

## Rubygems

```bash
ln -s `pwd`/rubygems/gemrc ~/.gemrc
```

## Sublime Text

```bash
ln -s `pwd`/sublimetext/packages ~/Library/Application\ Support/Sublime\ Text\ 3/Installed\ Packages
ln -s `pwd`/sublimetext/user ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User
```
