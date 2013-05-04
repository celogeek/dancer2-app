#!/usr/bin/env perl
# PODNAME: [%APP%]
# ABSTRACT: Launcher of [%APP%] dancer apps
use strict;
use warnings;
# VERSION

BEGIN {
    use FindBin qw/$Bin/;
    my @vendors = glob($Bin."/../vendors/*/lib");
    push @INC, @vendors;
}
use Dancer2;
use [%APP%];

start;
