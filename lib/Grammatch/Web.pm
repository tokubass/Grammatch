package Grammatch::Web;
use strict;
use warnings;
use utf8;
use parent qw/Grammatch Amon2::Web/;
use File::Spec;
use Try::Tiny;
use Time::Piece;

sub session_get {
    my ($c) = @_;
    return $c->session->get('user_id') || undef;
}

# dispatcher
use Grammatch::Web::Dispatcher;
sub dispatch {
    return (Grammatch::Web::Dispatcher->dispatch($_[0]) or die "response is not generated");
}

# load plugins
__PACKAGE__->load_plugins(
    'Web::FillInFormLite',
    'Web::FormValidator::Simple',
    'Web::CSRFDefender' => {
        post_only => 1,
    },
    'Web::JSON',
    '+Grammatch::Plugin::Web::Debug',
    '+Grammatch::Plugin::Web::Profiler',
    'Web::Auth' => +{
        module      => 'Twitter',
        on_finished => sub {
            my ($c, $access_token, $access_token_secret, $user_id, $screen_name) = @_;
            my $user = $c->db->single(user => { twitter_user_id => $user_id });
            
            unless ($user) {
                my $txn = $c->db->txn_scope;
                my $current_time = localtime();
                try {
                    $user = $c->db->insert('user' => { 
                        user_name           => $screen_name,
                        twitter_screen_name => $screen_name,
                        twitter_user_id     => $user_id,
                        created_at          => $current_time,
                        updated_at          => $current_time,
                        last_logged_at      => $current_time,
                    }); 
                    $txn->commit;
                } catch {
                    $txn->rollback;
                    die $_;
                };
            }

            $c->session->set('user_id'   => $user->user_id );
            $c->session->set('user_name' => $user->user_name );
            $c->session->set('dojo_id'   => $user->dojo_id );
            return $c->redirect('/');
        },
    },
);

# setup view
use Grammatch::Web::View;
{
    my $view = Grammatch::Web::View->make_instance(__PACKAGE__);
    sub create_view { $view }
}

# for your security
__PACKAGE__->add_trigger(
    AFTER_DISPATCH => sub {
        my ( $c, $res ) = @_;

        # http://blogs.msdn.com/b/ie/archive/2008/07/02/ie8-security-part-v-comprehensive-protection.aspx
        $res->header( 'X-Content-Type-Options' => 'nosniff' );

        # http://blog.mozilla.com/security/2010/09/08/x-frame-options/
        $res->header( 'X-Frame-Options' => 'DENY' );

        # Cache control.
        $res->header( 'Cache-Control' => 'private' );
    },
);

__PACKAGE__->add_trigger(
    BEFORE_DISPATCH => sub {
        my ( $c ) = @_;
        # ...
        return;
    },
);

1;
