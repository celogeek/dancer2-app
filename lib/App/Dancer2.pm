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
use LWP::Curl;
use Archive::Extract;

=attr app

The app params will create a new dancer2 apps with basic configuration.

dancer2 --app myApps

=cut

option 'app' => (
    is => 'ro',
    doc => 'Create a new apps',
    format => 's',
    isa => sub {
        croak "not a valid app name: [a-zA-Z0-9]+" unless $_[0] =~ /^[a-zA-Z0-9]+$/x;

    }
);

=attr app_mode

You can select between multiple mode.

Mode 'basic' : simple configuration without database

=cut

option 'app_mode' => (
    is => 'ro',
    doc => 'Use mode: basic',
    format => 's',
    default => sub { 'basic' },
);

=attr app_with_git

Initialize git apps. It will use the submodule mode to fetch dancer2 instead of fetching the zip file

=cut

option 'app_with_git' => (
    is => 'ro',
    doc => 'Use a pure git repository for your apps',
);

=meth create_app

    Initialize an new apps. Used inside the binary apps dancer2.

=cut

sub create_app {
    my $self = shift;

    my $path = dir($ENV{PWD}, $self->app);
    croak "$path already exist !" if -e $path;

    say "Creating app : ", $self->app;

    my $dist_dir = $self->_dist_dir('App-Dancer2')->subdir('app')->subdir($self->app_mode);
    croak "This mode doesn't exist" if ! -e $dist_dir;
    
    $self->_copy_dist($dist_dir, $path);
    if ($self->app_with_git) {
        $self->_init_git($path);
    } else {
        $self->_fetch_latest_dancer2($path);
    }

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
            $dest =~ s/\Q[%APP%]\E/$app/gx;
            if (-d $child) {
                $dest = dir($dest);
                say "Creating $dest ...";
                make_path($dest, {
                        verbose => 0,
                });
            } else {
                $dest = substr($dest, 0, -4);
                $dest = file($dest);
                say "Copying to $dest ...";
                my $content = $child->slurp;
                $content =~ s/\Q[%APP%]\E/$app/gx;
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
    say "Fetching vendors/Dancer2";
    $r->run(submodule => 'add', 'git://github.com/PerlDancer/Dancer2.git', 'vendors/Dancer2');
    $r->run(commit => '-m', 'plug git dancer2 head');
}

sub _fetch_latest_dancer2 {
    my ($self, $to) = @_;
    my $dest = $to->subdir('vendors');
    make_path($dest, { verbose => 0 });
    say "Fetching latest dancer2 archive ...";
    my $lwpc = LWP::Curl->new();
    my $content = $lwpc->get('https://github.com/PerlDancer/Dancer2/archive/master.zip');
    say "Extract archive ...";
    my $tmp = file('/tmp/dancer2.zip');
    $tmp->spew($content);
    my $ae = Archive::Extract->new(archive => $tmp);
    $ae->extract(to => $dest);
}

1;
