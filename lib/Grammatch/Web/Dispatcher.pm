package Grammatch::Web::Dispatcher;
use strict;
use warnings;
use utf8;
use Amon2::Web::Dispatcher::RouterSimple::Extended;

get '/'       => 'Root#root';
get '/logout' => 'Root#logout';

# user
get  '/user/{user_id:[0-9]+}' => 'User#user';
get  '/user/edit'             => 'User#edit_form';
post '/user/edit'             => 'User#edit';

# dojo
get  '/dojo'                          => 'Dojo#dojo_root';
get  '/dojo/{dojo_id:[0-9]+}'         => 'Dojo#dojo';
post '/dojo/{dojo_id:[0-9]+}/post'    => 'Comment#dojo_post';
get  '/dojo/edit'                     => 'Dojo#edit_form';
post '/dojo/edit'                     => 'Dojo#edit';
post '/dojo/{dojo_id:[0-9]+}/request' => 'Dojo#request';
post '/dojo/{dojo_id:[0-9]+}/dropout' => 'Dojo#dropout';
get  '/dojo/request'                  => 'Dojo#request_list';
post '/dojo/accept'                   => 'Dojo#accept';
post '/dojo/create'                   => 'Dojo#create';
get  '/search/dojo'                   => 'Search#dojo';
get  '/dojo/{dojo_id:[0-9]+}/event'   => 'Dojo#event';

# event
get  '/event/{event_id:[0-9]+}'        => 'Event#event';
get  '/event/{event_id:[0-9]+}/join'   => 'Event#join';
get  '/event/{event_id:[0-9]+}/resign' => 'Event#resign';
get  '/event/{event_id:[0-9]+}/edit'   => 'Event#edit_form';
post '/event/{event_id:[0-9]+}/edit'   => 'Event#edit';
get  '/event/create'                   => 'Event#create_form';
post '/event/create'                   => 'Event#create';
post '/event/{event_id:[0-9]+}/post'   => 'Comment#event_post';
get  '/search/event'                   => 'Search#event';

1;
