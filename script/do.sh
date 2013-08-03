#!/bin/bash
set -e
#set -x

HOME=/Users/viage
app=$HOME/Work/App/block_hash
carton=/Users/viage/perl5/perlbrew/perls/perl-5.14.2/bin/carton

cd $app
source /Users/viage/perl5/perlbrew/etc/bashrc

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
