#!/bin/bash
set -e
#set -x

HOME=/Users/viage
PERLVER=5.14.2
APP=$HOME/Work/App/block_hash
if [ `hostname` == 'dti-vps-srv85' ]; then
    HOME=/home/viage
    APP=$HOME/work/block_hash
    PERLVER=5.14.4
fi

carton=$HOME/perl5/perlbrew/perls/perl-${PERLVER}/bin/carton

cd $APP
source $HOME/perl5/perlbrew/etc/bashrc

echo '#' 
echo '# carton exec -- perl script/pull_tweet.pl' 
echo '#' 
$carton exec -- perl script/pull_tweet.pl
if [ X$? == 'X0' ]; then
    echo ok
else
    exit 1
fi

echo '#' 
echo '# carton exec -- perl script/crawle_tweet_url.pl'
echo '#' 
$carton exec -- perl script/crawle_tweet_url.pl
if [ X$? == 'X0' ]; then
    echo ok
else
    exit 1
fi

echo '#' 
echo '# carton exec -- perl script/validate_tweet_json.pl'
echo '#' 
$carton exec -- perl script/validate_tweet_json.pl
if [ X$? == 'X0' ]; then
    echo ok
else
    exit 1
fi

echo '#' 
echo '# carton exec -- perl script/analysis_tag.pl'
echo '#' 
$carton exec -- perl script/analysis_tag.pl
if [ X$? == 'X0' ]; then
    echo ok
else
    exit 1
fi

exit 0
