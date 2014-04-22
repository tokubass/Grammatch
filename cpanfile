requires 'perl', '5.008001';
requires 'Amon2', '3.87';
requires 'Text::Xslate', '1.6001';
requires 'Amon2::DBI'                     , '0.30';
requires 'DBD::mysql';
requires 'HTML::FillInForm::Lite'         , '1.11';
requires 'JSON'                           , '2.50';
requires 'Module::Functions'              , '2';
requires 'Plack::Middleware::ReverseProxy', '0.09';
requires 'Plack::Middleware::Session'     , '0';
requires 'Plack::Session'                 , '0.14';
requires 'Test::WWW::Mechanize::PSGI'     , '0';
requires 'Time::Piece'                    , '1.20';

requires 'Text::UnicodeTable::Simple';
requires 'Module::Pluggable::Object';
requires 'Data::Dumper';
requires 'Log::Dispatch::Config';
requires 'Log::Dispatch::Configurator::Any';

requires 'Teng';
requires 'Amon2::Web::Dispatcher::RouterSimple::Extended';

on 'configure' => sub {
   requires 'Module::Build', '0.38';
   requires 'Module::CPANfile', '0.9010';
};

on 'test' => sub {
   requires 'Test::More', '0.98';
};
