#!/bin/sh

GIT_DIR=$HOME/build/git

# directory locations
echo -n "Linking data locations..."
ln -s /mnt/data/Dropbox $HOME/Dropbox
ln -s /mnt/data/build $HOME/build
ln -s /mnt/data/docs $HOME/docs
ln -s /mnt/data/pics $HOME/pics
ln -s /mnt/data/scripts $HOME/scripts
ln -s /mnt/data/videos $HOME/videos
ln -s /mnt/data/music $HOME/music
echo "done."

# config files
mkdir -p $HOME/.config
mkdir -p $HOME/.local/share

echo -n "Linking config files..."
ln -s $HOME/Dropbox/config/dots/_Xmodmap $HOME/.Xmodmap
ln -s $HOME/Dropbox/config/dots/_Xresources $HOME/.Xresources
ln -s $HOME/Dropbox/config/emacs $HOME/.emacs.d
ln -s $HOME/Dropbox/config/dots/_pentadactylrc $HOME/.pentadactylrc
#ln -s $HOME/Dropbox/config/dots/_vimperatorrc $HOME/.vimperatorrc
ln -s $HOME/Dropbox/config/dots/_tmux.conf $HOME/.tmux.conf
ln -s $HOME/Dropbox/config/dots/_vimrc $HOME/.vimrc
ln -s $HOME/Dropbox/config/vim $HOME/.vim
#ln -s $HOME/Dropbox/config/dwb $HOME/.config/dwb
ln -s $HOME/Dropbox/config/zsh/_zshenv $HOME/.zshenv
ln -s /mnt/data/themes $HOME/.themes
ln -s $HOME/Dropbox/config/bash $HOME/.config/bash
ln -s $HOME/Dropbox/config/logrc $HOME/.config/logrc
ln -s $HOME/Dropbox/.userdata/netrc_iandbrunton $HOME/.config/netrc_iandbrunton
ln -s $HOME/Dropbox/.userdata/netrc_wolfshift $HOME/.config/netrc_wolfshift
ln -s $HOME/Dropbox/.userdata/netrc $HOME/.netrc
#ln -s /mnt/data/config/openbox $HOME/.config/openbox
ln -s /mnt/data/config/herbstluftwm $HOME/.config/herbstluftwm
#ln -s /mnt/data/Dropbox/config/luakit $HOME/.config/luakit
#ln -s /mnt/data/Dropbox/share/luakit $HOME/.local/share/luakit
ln -s /mnt/data/config/ncmpcpp $HOME/.ncmpcpp
ln -s $HOME/Dropbox/config/zsh $HOME/.config/zsh
ln -s $HOME/Dropboxconfig/conky $HOME/.config/conky
echo "done."

# essentials from github
#echo "Cloning essential GIT repos..."
#mkdir -p $GIT_DIR
mkdir -p $HOME/bin
#cd $GIT_DIR

if [ -x /mnt/data/docs/programming/perl/log/log.pl ] ; then
	ln -s /mnt/data/docs/programming/perl/log/log.pl $HOME/bin/llg
	ln -s /mnt/data/docs/programming/perl/log/clog.pl $HOME/bin/clog
	ln -s /mnt/data/docs/programming/perl/log/editlog.pl $HOME/bin/editlog
	ln -s /mnt/data/docs/programming/perl/log/tag $HOME/bin/log-tag
	ln -s /mnt/data/docs/programming/perl/log/switch_last_2_lines.pl $HOME/bin/switchlog
elif
	git clone git@github.com:ibrunton/log.git
	ln -s $GIT_DIR/log/log.pl $HOME/bin/llg
	ln -s $GIT_DIR/log/clog.pl $HOME/bin/clog
	ln -s $GIT_DIR/log/editlog.pl $HOME/bin/editlog
	ln -s $GIT_DIR/log/tag.pl $HOME/bin/log-tag
fi

#git clone https://github.com/muennich/urxvt-perls.git

#git clone https://github.com/KittyKatt/screenFetch.git
#ln -s $GIT_DIR/screenFetch/screenfetch-dev $HOME/bin/screenfetch

#git clone https://github.com/graysky2/modprobed_db.git

#git clone https://github.com/capitaomorte/yasnippet.git

#git clone https://github.com/kohler/gifsicle.git

echo "done."

echo "Don't forget to install log system libs!"
echo "Don't forget to install urxvt perls in system directory!"
echo "Don't forget to install modprobe_db!"
