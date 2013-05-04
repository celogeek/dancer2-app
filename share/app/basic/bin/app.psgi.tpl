#!/usr/bin/env perl
use strict;
use warnings;
BEGIN {
    use FindBin qw/$Bin/;
    my @vendors = glob($Bin."/../vendors/*/lib");
    push @INC, @vendors;
}
use Dancer2;
use [%APP%];

start;
