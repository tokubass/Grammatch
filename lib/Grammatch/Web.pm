package Grammatch::Web;
use strict;
use warnings;
use utf8;
use parent qw/Grammatch Amon2::Web/;
use File::Spec;
use Grammatch::Model::Login;

# Authentication
sub auth {
    my ($c) = @_;
    my $user_id   = $c->session->get('user_id');
    my $user_name = $c->session->get('user_name');

    if ($user_id && $user_name) {
        return { user_id => $user_id, user_name => $user_name }; 
    }
    return undef;
}

# dispatcher
use Grammatch::Web::Dispatcher;
sub dispatch {
    return (Grammatch::Web::Dispatcher->dispatch($_[0]) or die "response is not generated");
}

# load plugins
__PACKAGE__->load_plugins(
    'Web::FillInFormLite',
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
            my $user = Grammatch::Model::Login->login($user_id);
  
            if ($user) {
                $c->session->set('user_id'   => $user->user_id);
                $c->session->set('user_name' => $user->user_name);
                return $c->redirect('/');
            } 

            my $entry_user = Grammatch::Model::Login->entry($user_id, $screen_name);  
            $c->session->set('user_id'   => $entry_user->user_id);
            $c->session->set('user_name' => $entry_user->user_name);

            return $c->redirect('/user');
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
