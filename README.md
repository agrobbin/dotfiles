# dotfiles

Configuration files for Zsh, Git, Rubygems, Sublime Text, and more.

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
ln -s `pwd`/sublimetext/Default\ \(OSX\).sublime-keymap ~/Library/Application\ Support/Sublime\ Text/Packages/User/.
ln -s `pwd`/sublimetext/Package\ Control.sublime-settings ~/Library/Application\ Support/Sublime\ Text/Packages/User/.
ln -s `pwd`/sublimetext/Preferences.sublime-settings ~/Library/Application\ Support/Sublime\ Text/Packages/User/.
ln -s `pwd`/sublimetext/Ruby\ Haml.sublime-settings ~/Library/Application\ Support/Sublime\ Text/Packages/User/.
```
