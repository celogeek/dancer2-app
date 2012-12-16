package [%APP_MODULE];
use strict;
use warnings;
use Dancer;

get '/' => sub {
    template 'index';
};

1;
