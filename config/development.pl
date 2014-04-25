use File::Spec;
use File::Basename qw(dirname);
my $basedir = File::Spec->rel2abs(File::Spec->catdir(dirname(__FILE__), '..'));
my $dbpath  = File::Spec->catfile($basedir, 'db', 'development.db');
my $auth    = do File::Spec->catfile($basedir, 'config', 'auth.pl');
my $pref    = do File::Spec->catfile($basedir, 'config', 'pref.pl');
+{
    'DBI' => [
        'dbi:mysql:database=grammatch;host=localhost',
        'root',
        '',
    ],
    
    'Web::Validator' => {},
   
    Auth => $auth,
    pref => $pref,

    'Plugin::Logger' => {
        dispatchers => [qw/screen/],
        screen => {
            class     => 'Log::Dispatch::Screen::Color',
            min_level => 'debug',
            newline   => 1,
            format    => '[%d{%Y-%m-%d %H:%M:%S}] [%p] %m at %F line %L',
            color     => {
                info    => { text => 'green' },
                debug   => { text => 'magenta' },
                warning => { text => 'yellow' },
                error   => { text => 'red' },
                alert   => { text => 'red', bold => 1 },
            },
        },
    },
    
    'Plack::Session::State::Cookie' => {
        session_key => 'grammatch',
        expires     => 60 * 60 * 24 * 14,
    },

    'Plack::Session::Store::Redis' => {
        prefix  => 'grammatch_session',
        host    => 'localhost',
        port    => '6379',
    },
};
