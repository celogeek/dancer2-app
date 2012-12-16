package App::Dancer2;
use strict;
use warnings;
use Moo;
use MooX::Options;
use feature 'say';
use Git::Raw;
use File::Spec;

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

    my $url = 'git://gitorious.celogeek.com/perl-dancer2/basic.git';
    my $path = File::Spec->catfile($ENV{PWD}, $self->app);
    my $repo = Git::Raw::Repository->init($path, 0);
    my $remote = Git::Raw::Remote->add($repo, 'origin', $url);
    $remote->connect('fetch');
    $remote->download;
    $remote->update_tips;
    $remote->disconnect;
    $repo->checkout($repo->head, {
            'update_missing'  => 1,
            'update_modified' => 1
        });
    return;
}

1;
