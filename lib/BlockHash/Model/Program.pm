package BlockHash::Model::Program;
use BlockHash::DB;
use Time::Piece;
use Time::Seconds;
use Data::Dumper;

sub get_tweets {
    my $self = shift;
    my $args = shift || croak;    

    my $db = BlockHash::DB->new;
    $args->{date} =~ /^(\d{4})(\d{2})(\d{2})$/;
    my $t1 = Time::Piece->strptime("$1-$2-$3 00:00:00", '%Y-%m-%d %H:%M:%S');
    my $t2 = Time::Piece->strptime("$1-$2-$3 23:59:59", '%Y-%m-%d %H:%M:%S');
    $t1 = $t1 - 9*60*60;
    $t2 = $t2 - 9*60*60;
    my $where = {
        hashtags => { like => '%'.$args->{tag}.'%' },
        created_at => { between => [$t1->ymd.' '.$t1->hms, $t2->ymd.' '.$t2->hms] },
    };
    my ($rows, $pager) = $db->search_with_pager('tweet',
        $where,
        {
            order_by => 'created_at',
            page => $args->{page} || 1, 
            rows => 30,
        }
    );
    my @tweets;
    for my $row (@$rows) {
        my $t = $row->created_at;
        my $t_str = $t->ymd.' '.$t->hms;
        push @tweets, {
            tweet =>$row->tweet_json,
            date => $t_str,
            media_type => $row->media_type,
            media_data => $row->media_data,
        };
    }

    my $count = $db->count('tweet', '*', $where);

    return \@tweets, $pager, $count;
}

=pod
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
=cut

1;

