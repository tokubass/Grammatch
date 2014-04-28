package Grammatch::Web::Dispatcher;
use strict;
use warnings;
use utf8;
use Amon2::Web::Dispatcher::RouterSimple::Extended;

get '/'       => 'Root#root';
get '/logout' => 'Root#logout';

# user
get '/user/{id:[0-9]+}' => 'User#user';
get '/user/edit'        => 'User#edit';
post '/user/edit'       => 'User#commit';

# dojo
get '/dojo/{id:[0-9]+}'          => 'Dojo#dojo';
post '/dojo/{id:[0-9]+}/join'    => 'Dojo#join';
post '/dojo/{id:[0-9]+}/dropout' => 'Dojo#dropout';

get '/dojo/motion'  => 'Dojo#motion';
post '/dojo/accept' => 'Dojo#accept';
post '/dojo/create' => 'Dojo#create';
get '/dojo'         => 'Dojo#dojo_root';

get '/dojo/edit'  => 'Dojo#edit';
post '/dojo/edit' => 'Dojo#commit';

get '/search/dojo'  => 'Search#dojo';

# event
get '/event/create'  => 'Event#create';
post '/event/create' => 'Event#create_commit';

1;
