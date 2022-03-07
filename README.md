# dotfiles

Configuration files for Bash, Zsh, Git, Rubygems, Sublime Text, and more.

## Bash

```bash
ln -s `pwd`/bash/bash_profile ~/.bash_profile
```

## Zsh

```zsh
ln -s `pwd`/zsh/zprofile ~/.zprofile
```

## Git

```bash
ln -s `pwd`/git/gitconfig $(brew --prefix)/etc/gitconfig
ln -s `pwd`/git/gitignore_global ~/.gitignore_global
```

## Rubygems

```bash
ln -s `pwd`/rubygems/gemrc ~/.gemrc
```

## Sublime Text

```bash
ln -s `pwd`/sublimetext/Default\ \(OSX\).sublime-keymap ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User/.
ln -s `pwd`/sublimetext/Package\ Control.sublime-settings ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User/.
ln -s `pwd`/sublimetext/Preferences.sublime-settings ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User/.
ln -s `pwd`/sublimetext/Ruby\ Haml.sublime-settings ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User/.
```
