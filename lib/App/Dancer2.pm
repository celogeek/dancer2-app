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
use File::Path qw/make_path/;
use Path::Class;
use Git::Repository;

option 'app' => (
    is => 'ro',
    doc => 'Create a new apps',
    format => 's',
    isa => sub {
        croak "not a valid app name: [a-zA-Z0-9]+" unless $_[0] =~ /^[a-zA-Z0-9]+$/;

    }
);

option 'app_mode' => (
    is => 'ro',
    doc => 'Use mode: basic',
    format => 's',
    default => sub { 'basic' },
);

option 'app_with_git' => (
    is => 'ro',
    doc => 'initialize a git repository',
);

sub create_app {
    my $self = shift;

    my $path = dir($ENV{PWD}, $self->app);
    croak "$path already exist !" if -e $path;

    say "Creating app : ", $self->app;

    my $dist_dir = $self->_dist_dir('App-Dancer2')->subdir('app')->subdir($self->app_mode);
    croak "This mode doesn't exist" if ! -e $dist_dir;
    
    $self->_copy_dist($dist_dir, $path);
    $self->_init_git($path) if $self->app_with_git;

    return;
}

sub _dist_dir {
    if ($App::Dancer2::VERSION) {
        return dir(dist_dir('App-Dancer2'));
    } else {
        return file(__FILE__)->dir->parent->parent->subdir('share');
    }
}

sub _copy_dist {
    my ($self, $from, $to) = @_;
    my $app = $self->app;
    $from = dir($from) unless ref $from eq 'Path::Class::Dir';
    $to = dir($to) unless ref $to eq 'Path::Class::Dir';
    $from->recurse(callback => sub {
            my $child = shift;
            my $dest = dir($to, substr($child, length($from)));
            $dest =~ s/\Q[%APP%]\E/$app/g;
            if (-d $child) {
                $dest = dir($dest);
                say "Creating $dest ...";
                make_path($dest, {
                        verbose => 0,
                });
            } else {
                $dest = file($dest);
                say "Copying to $dest ...";
                my $content = $child->slurp;
                $content =~ s/\Q[%APP%]\E/$app/g;
                $dest->spew($content);
            }
    });
    return;
}

sub _init_git {
    my ($self, $to) = @_;
    $to = dir($to) unless ref $to eq 'Path::Class::Dir';

    say "Init git repository $to ...";

    Git::Repository->run(init => { cwd => $to});
    my $r = Git::Repository->new( work_tree => $to);
    $r->run(add => '.');
    $r->run(commit => '-m', 'init dancer2 project');
}

1;
