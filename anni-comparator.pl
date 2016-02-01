#!/usr/bin/perl

require UnitComparator;
require AnnihilationParser;

my ($fn1, $fn2) = @ARGV;

my ($result, $message) = UnitComparator::CompareFiles($fn1,$fn2);
if ($result == 0) {
	print($message);
} else {
	print("Success\n");
}
