#!/usr/bin/perl

use AnnihilationParser;

# Idea: read stdin until eof into a string and then read the string
my $buff;
while (<>) {
    $buff .= $_
}

my $result = AnnihilationParser::readBuf($buff,1);

1;
