#!/bin/sh

echo -n "Linking data locations..."
# directory locations
ln -s /mnt/data/Dropbox ~/Dropbox
ln -s /mnt/data/docs ~/docs
ln -s /mnt/data/pics ~/pics
echo "done."

# config files
echo -n "Linking config files..."
ln -s ~/Dropbox/config/dots/_Xmodmap ~/.Xmodmap
ln -s ~/Dropbox/config/dots/_Xresources ~/.Xresources
ln -s ~/Dropbox/config/emacs ~/.emacs.d
ln -s ~/Dropbox/config/dots/_pentadactylrc ~/.pentadactylrc
ln -s ~/Dropbox/config/dots/_tmux.conf ~/.tmux.conf
ln -s ~/Dropbox/config/dots/_vimrc ~/.vimrc
ln -s ~/Dropbox/config/vim ~/.vim
ln -s ~/Dropbox/config/zsh/_zshenv ~/.zshenv
ln -s /mnt/data/themes ~/.themes
ln -s ~/Dropbox/config/bash ~/.config/bash
ln -s ~/Dropbox/config/logrc ~/.config/logrc
ln -s ~/Dropbox/.userdata/netrc_iandbrunton ~/.config/netrc_iandbrunton
ln -s ~/Dropbox/.userdata/netrc_wolfshift ~/.config/netrc_wolfshift
ln -s /mnt/data/config/openbox ~/.config/openbox
ln -s ~/Dropbox/config/zsh ~/.config/zsh
echo "done."

echo -n "Cloning essentials from github..."
mkdir -p $HOME/build/git
cd $HOME/build/git
git clone git@github:ibrunton/log.git
git clone git://github.com/muennich/urxvt-perls.git
git clone git://github.com/KittyKatt/screenFetch.git
echo "done."

