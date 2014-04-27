package Grammatch::Web::Dispatcher;
use strict;
use warnings;
use utf8;
use Amon2::Web::Dispatcher::RouterSimple::Extended;

get '/'       => 'Root#root';
get '/logout' => 'Root#logout';

# user
get '/user/{id}' => 'User#user';

# dojo
get '/dojo/{id}'        => 'Dojo#dojo';

get '/dojo/create'      => 'Dojo#create';
get '/dojo/{id}/join'   => 'Dojo#join';
get '/dojo/{id}/p'      => 'Dojo#pending';
get '/dojo/{id}/accept' => 'Dojo#accept';

1;
