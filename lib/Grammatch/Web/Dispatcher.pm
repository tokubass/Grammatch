package Grammatch::Web::Dispatcher;
use strict;
use warnings;
use utf8;
use Amon2::Web::Dispatcher::RouterSimple::Extended;

get '/'       => 'Root#root';
get '/logout' => 'Root#logout';

# user
get '/user'      => 'User#user';
get '/user/{id}' => 'User#user';

# dojo
get '/dojo'           => 'Dojo#my_dojo';
get '/dojo/{id}'      => 'Dojo#dojo';
get '/dojo/{id}/join' => 'Dojo#join';
get '/dojo/create'    => 'Dojo#create';

1;
