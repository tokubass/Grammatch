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
get '/dojo/{id}'          => 'Dojo#dojo';
get '/dojo/{id}/motion'   => 'Dojo#motion';
post '/dojo/{id}/join'    => 'Dojo#join';
post '/dojo/{id}/dropout' => 'Dojo#dropout';
post '/dojo/{id}/accept'  => 'Dojo#accept';
post '/dojo/create'       => 'Dojo#create';

1;
