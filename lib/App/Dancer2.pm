package App::Dancer2;
use strict;
use warnings;
use Moo;
use MooX::Options;
use feature 'say';
use Git::Repository;
use File::Spec;
use Carp;

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

    my $path = File::Spec->catfile($ENV{PWD}, $self->app);
    croak "$path already exist !" if -e $path;

    my $url = 'git://gitorious.celogeek.com/perl-dancer2/basic.git';
    say "Creating app : ", $self->app;
    Git::Repository->run(init => $path);
    my $repo = Git::Repository->new(work_tree => $path);
    $repo->run(remote => 'add', 'origin', $url);
    $repo->run(pull => '-u', 'origin', 'master');
    $repo->run(remote => 'remove', 'origin');
    return;
}

1;
