package Grammatch::Plugin::Web::Debug;
use strict;
use warnings;
use utf8;
use Text::UnicodeTable::Simple;

sub init {
    my ($class, $c, $conf) = @_;

    return unless  not $ENV{HARNESS_ACTIVE} and $ENV{PLACK_ENV} ne 'production';

    $c->add_trigger(
        BEFORE_DISPATCH => sub {
            my $c = shift;

            # path
            $c->log->info(sprintf 'Path: %s', $c->req->path);

            # params
            for my $method (qw/query_parameters body_parameters uploads/) {
                next unless keys %{$c->req->$method->mixed};

                my $table = Text::UnicodeTable::Simple->new(header => [qw/field value/]);
                for my $field (sort keys %{$c->req->$method->mixed}) {
                    my $value = $c->req->$method->mixed->{$field} // '';
                    if (ref $value eq 'Plack::Request::Upload') {
                        $table->add_row('filename', $value->filename);
                        $table->add_row('tempname', $value->tempname);
                        $table->add_row('size',     $value->size);
                    }
                    elsif (ref $value eq 'ARRAY') {
                        $table->add_row($field, join ', ', @$value);
                    }
                    else {
                        $table->add_row($field, $value);
                    }
                }
                $c->log->debug(
                    sprintf "%s:\n%s",
                    join(' ', map(ucfirst($_), split(/_/, $method))),
                    $table->draw,
                );
            }
        },
        AFTER_DISPATCH => sub {
            my ($c, $res) = @_;

            # status
            $c->log->info(
                sprintf 'Response Code: %s; Content-Type: %s; Content-Length: %s',
                $res->status                   || 'unknown',
                $res->header('Content-Type')   || 'unknown',
                $res->header('Content-Length') || 'unknown',
            );

            # redirect
            if (my $location = $res->redirect) {
                $c->log->info(sprintf 'Redirecting to %s', $location);
            }
        },
    );
}

1;
