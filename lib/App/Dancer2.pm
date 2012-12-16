package App::Dancer2;

# ABSTRACT: App to use dancer2 in your project

use strict;
use warnings;
# VERSION
use Carp;
use feature 'say';
use Moo;
use MooX::Options;
use File::ShareDir ':ALL';
use Path::Class;
use Git::Repository;

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

    my $path = dir($ENV{PWD}, $self->app);
    croak "$path already exist !" if -e $path;

    say "Creating app : ", $self->app;

    my $dist_dir = _dist_dir('App-Dancer2');
    croak $dist_dir;
    

    return;
}

sub _dist_dir {
    if ($App::Dancer2::VERSION) {
        return dist_dir('App-Dancer2');
    } else {
        return file(__FILE__)->dir->parent->parent->subdir('share');
    }

}

1;
