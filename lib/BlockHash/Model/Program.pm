package BlockHash::Model::Program;
use strict;
use warnings;
use utf8;

use base 'BlockHash::Model';

sub new { shift->SUPER::new(@_); };

sub get_tweets {
    my $self = shift;
    #my $args = shift || croak;    

    #my $validator = $self->check($args);
    #return $validator if $validator->has_error;

    #my $result = $self->schema('Program')->search({ prog_name => $args->{prog_name} });
    my $result = [
        {
            id => 'inu',
            display_name => 'いぬ',
            tweet_date => '2013-07-25 12:00:00 JST',
            tweet => 'その他にFormValidator::Liteを呼び出すためのMyApp::Formと個別のルールが書かれたMyApp::Form::Entryなどが存在する。以下がMyApp::Formで親クラス。FormValidator::Liteに渡す際、パラメータ系の互換にするめにMojo::Parametersを暫定的に使ってます。',
            profile_img => 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQzDCbOUi-2c1TbUlYXs5Qav3aH7zyLAz12xTB-XDNqmEQgicCT',
            is_large => '1',
        },
        {
            id => 'neko',
            display_name => 'ねこ',
            tweet_date => '2013-07-25 12:00:00 JST',
            tweet => 'IO::File::AtomicChangeを思い出しました。

    https://metacpan.org/module/IO::File::AtomicChange
    https://github.com/hirose31/IO-File-AtomicChange

件の記事と同じように、',
            profile_img => 'https://encrypted-tbn3.gstatic.com/images?q=tbn:ANd9GcT8M9sC2AP2iRLGCaIXrZ_e0qY_Z9PT1L2iXFI-8z51L3R5bbYX',
            is_large => '1',
        },
        {
            id => 'inu',
            display_name => 'いぬ',
            tweet_date => '2013-07-25 12:00:00 JST',
            tweet => 'いぬいぬ',
            profile_img => 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQzDCbOUi-2c1TbUlYXs5Qav3aH7zyLAz12xTB-XDNqmEQgicCT',
            is_large => '1',
            media => 'youtube',
            media_url => 'http://www.youtube.com/embed/aA34fWlbb4c',
        },
        {
            id => 'neko',
            display_name => 'ねこ',
            tweet_date => '2013-07-25 12:00:00 JST',
            tweet => 'ねこねこ',
            profile_img => 'https://encrypted-tbn3.gstatic.com/images?q=tbn:ANd9GcT8M9sC2AP2iRLGCaIXrZ_e0qY_Z9PT1L2iXFI-8z51L3R5bbYX',
            is_large => '1',
            media => 'soundcloud',
            media_url => '31707950',
        },
        {
            id => 'inu',
            display_name => 'いぬinuいぬいぬinuinuいぬいぬ',
            tweet_date => '2013-07-25 12:00:00 JST',
            tweet => 'その他にFormValidator::Liteを呼び出すためのMyApp::Formと個別のルールが書かれたMyApp::Form::Entryなどが存在する。以下がMyApp::Formで親クラス。FormValidator::Liteに渡す際、パラメータ系の互換にするめにMojo::Parametersを暫定的に使ってます。',
            profile_img => 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQzDCbOUi-2c1TbUlYXs5Qav3aH7zyLAz12xTB-XDNqmEQgicCT',
            is_large => '1',
        },
        {
            id => 'neko',
            display_name => 'ねこ',
            tweet_date => '2013-07-25 12:00:00 JST',
            tweet => 'http://p.tl/893u以下がMyApp::Formで親クラス。FormValidator::Liteに渡す際、パラメータ系の互換にするめにMojo::Parametersを暫定的に使ってます。',
            profile_img => 'https://encrypted-tbn3.gstatic.com/images?q=tbn:ANd9GcT8M9sC2AP2iRLGCaIXrZ_e0qY_Z9PT1L2iXFI-8z51L3R5bbYX',
            is_large => '1',
            media => 'image',
            media_url => 'https://encrypted-tbn1.gstatic.com/images?q=tbn:ANd9GcQWKl6RYk-RplS3RzyKiaiFq1R-mkVW6OfK4Zw7hhRhMNQbIzh4',
        },
        {
            id => 'inu',
            display_name => 'いぬ',
            tweet_date => '2013-07-25 12:00:00 JST',
            tweet => 'いぬいぬ',
            profile_img => 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQzDCbOUi-2c1TbUlYXs5Qav3aH7zyLAz12xTB-XDNqmEQgicCT',
            is_large => '0',
        },
        {
            id => 'neko',
            display_name => 'ねこ',
            tweet_date => '2013-07-25 12:00:00 JST',
            tweet => 'RT @inu:ねこねこ',
            profile_img => 'https://encrypted-tbn3.gstatic.com/images?q=tbn:ANd9GcT8M9sC2AP2iRLGCaIXrZ_e0qY_Z9PT1L2iXFI-8z51L3R5bbYX',
            is_large => '0',
        },
        {
            id => 'inu',
            display_name => 'いぬ',
            tweet_date => '2013-07-25 12:00:00 JST',
            tweet => 'その他にFormValidator::Liteを呼び出すためのMyApp::Formと個別のルールが書かれたMyApp::Form::Entryなどが存在する。以下がMyApp::Formで親クラス。FormValidator::Liteに渡す際、パラメータ系の互換にするめにMojo::Parametersを暫定的に使ってます。',
            profile_img => 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQzDCbOUi-2c1TbUlYXs5Qav3aH7zyLAz12xTB-XDNqmEQgicCT',
            is_large => '1',
        },
        {
            id => 'neko',
            display_name => 'ねこ',
            tweet_date => '2013-07-25 12:00:00 JST',
            tweet => 'IO::File::AtomicChangeを思い出しました。

    https://metacpan.org/module/IO::File::AtomicChange
    https://github.com/hirose31/IO-File-AtomicChange

件の記事と同じように、',
            profile_img => 'https://encrypted-tbn3.gstatic.com/images?q=tbn:ANd9GcT8M9sC2AP2iRLGCaIXrZ_e0qY_Z9PT1L2iXFI-8z51L3R5bbYX',
            is_large => '1',
        },
        {
            id => 'inu',
            display_name => 'いぬ',
            tweet_date => '2013-07-25 12:00:00 JST',
            tweet => 'いぬいぬ',
            profile_img => 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQzDCbOUi-2c1TbUlYXs5Qav3aH7zyLAz12xTB-XDNqmEQgicCT',
            is_large => '0',
        },
        {
            id => 'neko',
            display_name => 'ねこ',
            tweet_date => '2013-07-25 12:00:00 JST',
            tweet => 'ねこねこ',
            profile_img => 'https://encrypted-tbn3.gstatic.com/images?q=tbn:ANd9GcT8M9sC2AP2iRLGCaIXrZ_e0qY_Z9PT1L2iXFI-8z51L3R5bbYX',
            is_large => '0',
        },
        {
            id => 'inu',
            display_name => 'いぬ',
            tweet_date => '2013-07-25 12:00:00 JST',
            tweet => 'その他にFormValidator::Liteを呼び出すためのMyApp::Formと個別のルールが書かれたMyApp::Form::Entryなどが存在する。以下がMyApp::Formで親クラス。FormValidator::Liteに渡す際、パラメータ系の互換にするめにMojo::Parametersを暫定的に使ってます。',
            profile_img => 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQzDCbOUi-2c1TbUlYXs5Qav3aH7zyLAz12xTB-XDNqmEQgicCT',
            is_large => '1',
        },
        {
            id => 'neko',
            display_name => 'ねこ',
            tweet_date => '2013-07-25 12:00:00 JST',
            tweet => 'http://p.tl/893u以下がMyApp::Formで親クラス。FormValidator::Liteに渡す際、パラメータ系の互換にするめにMojo::Parametersを暫定的に使ってます。',
            profile_img => 'https://encrypted-tbn3.gstatic.com/images?q=tbn:ANd9GcT8M9sC2AP2iRLGCaIXrZ_e0qY_Z9PT1L2iXFI-8z51L3R5bbYX',
            is_large => '1',
        },
        {
            id => 'inu',
            display_name => 'いぬ',
            tweet_date => '2013-07-25 12:00:00 JST',
            tweet => 'いぬいぬ',
            profile_img => 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQzDCbOUi-2c1TbUlYXs5Qav3aH7zyLAz12xTB-XDNqmEQgicCT',
            is_large => '0',
        },
        {
            id => 'neko',
            display_name => 'ねこ',
            tweet_date => '2013-07-25 12:00:00 JST',
            tweet => 'RT @inu:ねこねこ',
            profile_img => 'https://encrypted-tbn3.gstatic.com/images?q=tbn:ANd9GcT8M9sC2AP2iRLGCaIXrZ_e0qY_Z9PT1L2iXFI-8z51L3R5bbYX',
            is_large => '0',
        },
    ];
    return $result;
}

1;

