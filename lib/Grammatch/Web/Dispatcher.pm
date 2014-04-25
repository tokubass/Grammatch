package Grammatch::Web::Dispatcher;
use strict;
use warnings;
use utf8;
use Amon2::Web::Dispatcher::RouterSimple::Extended;

get '/'       => 'Root#root';
get '/logout' => 'Root#logout';

# user
get '/user' => 'User#profile';

1;
