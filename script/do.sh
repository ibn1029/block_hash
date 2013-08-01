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

echo '#' 
echo '# carton exec -- perl script/crawle_tweet_url.pl'
echo '#' 
$carton exec -- perl script/crawle_tweet_url.pl

echo '#' 
echo '# carton exec -- perl script/validate_tweet_json.pl'
echo '#' 
$carton exec -- perl script/validate_tweet_json.pl

exit
