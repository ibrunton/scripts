#!/bin/sh

GIT_DIR=$HOME/build/git

# directory locations
echo -n "Linking data locations..."
ln -s /mnt/data/Dropbox $HOME/Dropbox
ln -s /mnt/data/docs $HOME/docs
ln -s /mnt/data/pics $HOME/pics
echo "done."

# config files
mkdir -p $HOME/.config
mkdir -p $HOME/.local/share

echo -n "Linking config files..."
ln -s $HOME/Dropbox/config/dots/_Xmodmap $HOME/.Xmodmap
ln -s $HOME/Dropbox/config/dots/_Xresources $HOME/.Xresources
ln -s $HOME/Dropbox/config/emacs $HOME/.emacs.d
ln -s $HOME/Dropbox/config/dots/_pentadactylrc $HOME/.pentadactylrc
ln -s $HOME/Dropbox/config/dots/_tmux.conf $HOME/.tmux.conf
ln -s $HOME/Dropbox/config/dots/_vimrc $HOME/.vimrc
ln -s $HOME/Dropbox/config/vim $HOME/.vim
ln -s $HOME/Dropbox/config/zsh/_zshenv $HOME/.zshenv
ln -s /mnt/data/themes $HOME/.themes
ln -s $HOME/Dropbox/config/bash $HOME/.config/bash
ln -s $HOME/Dropbox/config/logrc $HOME/.config/logrc
ln -s $HOME/Dropbox/.userdata/netrc_iandbrunton $HOME/.config/netrc_iandbrunton
ln -s $HOME/Dropbox/.userdata/netrc_wolfshift $HOME/.config/netrc_wolfshift
ln -s $HOME/Dropbox/.userdata/netrc $HOME/.netrc
ln -s /mnt/data/config/openbox $HOME/.config/openbox
ln -s $HOME/Dropbox/config/zsh $HOME/.config/zsh
echo "done."

# essentials from github
echo "Cloning essential GIT repos..."
mkdir -p $GIT_DIR
cd $GIT_DIR

git clone https://github.com/ibrunton/log.git
ln -s $GIT_DIR/log/log.pl $HOME/bin/llg
ln -s $GIT_DIR/log/clog.pl $HOME/bin/clog
ln -s $GIT_DIR/log/editlog.pl $HOME/bin/editlog
ln -s $GIT_DIR/log/tag.pl $HOME/bin/log-tag

git clone https://github.com/muennich/urxvt-perls.git

git clone https://github.com/KittyKatt/screenFetch.git
ln -s $GIT_DIR/screenFetch/screenfetch-dev $HOME/bin/screenfetch

echo "done."

echo "Don't forget to install log system libs!"
echo "Don't forget to install urxvt perls in system directory!"
