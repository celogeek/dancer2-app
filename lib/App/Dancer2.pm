package App::Dancer2;
use strict;
use warnings;
use Moo;
use MooX::Options;
use feature 'say';

option 'app' => (
    is => 'ro',
    doc => 'Create a new apps',
    format => 's',
    trigger => sub {
        shift->create_app;
    }
);

sub create_app {
    my $self = shift;
    say "Creating app : ", $self->app;
}

1;
