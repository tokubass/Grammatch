package Grammatch::Web::C::Search;
use strict;
use warnings;
use Grammatch::App::Search;

sub dojo {
    my ($class, $c) = @_;
    my $pref_id = $c->req->param('pref_id');
    my $keyword = $c->req->param('keyword');
  
    my $dojo_list = $pref_id || $keyword
        ? Grammatch::App::Search->dojo($pref_id, $keyword)
        : undef;
    return $c->render('dojo/search.tx', {
        pref_id   => $c->req->param('pref_id') || 0,
        keyword   => $c->req->param('keyword') || '',
        dojo_list => $dojo_list,
    });
}

1;
