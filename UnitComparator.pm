
package UnitComparator;

require AnnihilationParser;

sub UnitComparator::CompareFiles
{
	my ($filename1, $filename2) = @_;
	
	open(FILE1, "<", $filename1) or return (0, "Couldn't open " . $filename1);
	open(FILE2, "<", $filename2) or return (0, "Couldn't open " . $filename2);
	
	printf("Comparing $filename1 $filename2\n");

	my $buff = "";
	while (<FILE1>) {
		$buff .= $_;
	}
	my $unit1 = AnnihilationParser::readBuf($buff);
	
	$buff = "";
	while (<FILE2>) {
		$buff .= $_;
	}
	my $unit2 = AnnihilationParser::readBuf($buff);
	
	close FILE1;
	close FILE2;
	
	return UnitComparator::CompareObjects($unit1, $unit2);
	
	
}


sub UnitComparator::CompareObjects ()
{
	my ($obj1, $obj2) = @_;
	
	my ($name1, $hash1) = @$obj1;
	my ($name2, $hash2) = @$obj2;
	
	if ($name1 ne $name2) {
		return (false, sprintf("Unit objects have different names! (%s != %s)", $name1, $name2));
	}
	
	my $level = 0;
	printf("### Comparing $name1");
	$$hash1{"name"} and printf(" " .$$hash1{'name'});
	printf("\n");
	
	CompareHashRecursive($hash1, $hash2, $level);
	
	return (true, "");
	
}

sub UnitComparator::CompareHashRecursive ()
{
	my ($hr1, $hr2, $level) = @_;
	$level = $level + 1;
	
    # Sort all keys into a master hash
	my %keyset;
	@keyset{keys %$hr1} = 1;
	@keyset{keys %$hr2} = 1;
	
	while ( my($k, $v) = sort { $a <=> $b } each %keyset ) {
		
		my ($e1, $e2) = (exists $$hr1{$k}, exists $$hr2{$k});
		
		if ($e1 xor $e2) {
			printf(" " x ($level * 4 - 2));
			$e1 and printf("- $k: $$hr1{$k}\n") or printf("+ $k $$hr2{$k}\n"); 
		} else {
			my ($r1, $r2) = (ref($$hr1{$k}), ref($$hr2{$k}));
			my ($v1, $v2) = ($$hr1{$k}, $$hr2{$k});
			if ($r1 xor $r2) {
				printf("$k: $v1 <now> $v2\n");
			} else {
				if ($r1 == "SCALAR") {
					if ($v1 =~ /^-?\d+\.?\d*$/ and $v2 =~ /^-?\d+\.?\d*$/) {
						if ($v1 > $v2) {
							printf(" " x ($level * 4));
							printf("$k: $v1 > $v2\n");
						} elsif ($v1 < $v2) {
							printf(" " x ($level * 4));
							printf("$k: $v1 < $v2\n");
						}
					} else {
						if ($v1 ne $v2) {
							printf(" " x ($level * 4));
							printf("$k: $v1 <> $v2\n");
						}
					}
				} elsif ($r1 == "HASH") {
					print(" " x ($level * 4) . "$k = {\n");
					CompareHashRecursive($v1,$v2,$level+1);
					print(" " x ($level * 4) . "}");
				}
			}
		}
	}
	
}
