#!/bin/bash
set -e
#set -x


# for DTI VPS
if [ `hostname` == 'dti-vps-srv85' ]; then
    HOME=/home/viage
    source $HOME/.bash_profile
    APP=$HOME/work/block_hash
    PERLVER=5.14.4
    carton=$HOME/.plenv/versions/$PERLVER/bin/carton

# for local mac
else
    HOME=/Users/viage
    PERLVER=5.14.2
    APP=$HOME/Work/App/block_hash
    carton=$HOME/perl5/perlbrew/perls/perl-${PERLVER}/bin/carton
    source $HOME/perl5/perlbrew/etc/bashrc
fi

cd $APP

echo '#' 
echo '# carton exec -- perl script/service/get_blockfm_friends.pl' 
echo '#' 
$carton exec -- perl script/service/get_blockfm_friends.pl
if [ X$? == 'X0' ]; then
    echo ok
else
    exit 1
fi

exit 0
