#!/usr/bin/perl

package AnnihilationParser;
require Exporter;
use Marpa::R2;

@EXPORT = qw(AnnihilationParser::readBuf);

my $defn = <<'END_DEFN';
:default ::= action => [name,values]
lexeme default = latm => 1

Body ::= ('return') TopBlock action => ::first

TopBlock ::= ('{') UnitName ('=') Block  ('}') action => parseKeyValue
   |   ('{') UnitName ('=') Block (',') ('}') action => parseKeyValue

UnitName ::= Identifier action => ::first

Block ::= ('{' '}')
 | ('{') StatementList ('}') action => parseBlock

StatementList ::= Statement+ separator => comma

Statement ::= Key ('=') Expression action => parseKeyValue

Key ::= Identifier action => ::first
   | ('[') Index (']') action => ::first

Index ::= WholeNumber action => ::first
    | Quote action => ::first

Expression ::= RealNumber action => ::first
    | Boolean action => ::first
    | Quote action => ::first
    | Block action => ::first
    | Identifier action => ::first
    | Weird action => ::first

Identifier ~ Letter WordChars

Letter ~ [A-Za-z]

WordChars ~ [\w]*

Quote ::= '""' 
    | '"' String '"' action => joinEm

String ~ [^\"]+

RealNumber ~ Number period Number
    | Number
    | '-' Number period Number
    | '-' Number

Weird ~ '[[' [^\]] ']]'

WholeNumber ~ Number

Number ~ [\d]+

Boolean ~ 'true' | 'false' | 'on' | 'off'

comma ~ [,]

period ~ [.]

:discard ~ whitespace
whitespace ~ [\s]+

END_DEFN

my $grammar = Marpa::R2::Scanless::G->new( { source => \$defn } );

sub print_tiered 
{
    my ($level, $r) = @_;
    if (ref($r) eq 'ARRAY') { # It's either a production expansion
		my @arr = @$r;
		my $name = $arr[0];
		my $x = $arr[1];
		my @rest = @arr[1..$#arr];
		print(' ' x $level . $name . " = ");
		for my $i (1..$#arr) {
			print_tiered($level+1,$arr[$i]);
		}
    } elsif (ref($r) eq 'HASH') {
		my %h = %$r;
		print("{\n");
		my @sortedkeys = sort { $a cmp $b  } keys %h;
		for my $k (@sortedkeys) {
			next unless $k;
			my $v = $h{$k};
			if (ref($v) eq 'HASH') {
				print(' ' x ($level+2) . "$k = ");
				print_tiered($level+2,$v);
			} elsif ($v) {
				print(' ' x ($level+2) . "$k = $v\n");
			}
		}
		print(' ' x $level . "}\n");
    } else { # Or a terminal
		print(' ' x $level . $r . "\n")
    }
}

sub parseBlock {
    my($h,$stmts) = @_;
    my %tbl;
    my @lst = @$stmts;
    for $pair (@lst) {
#	printf("key[%s] = value[%s]\n", $$pair[0], $$pair[1]);
		$tbl{$$pair[0]} = $$pair[1];
    }
    return \%tbl;
}

sub parseKeyValue {
    my($h,$key,$value) = @_;
    my %h = %$h;
    my $vtype = ref($value);
    my @result = ($key, $value);
    #print(join(' ', @result) . "\n");
    return \@result;
}

sub joinEm {
    my($h,$q1,$s,$q2) = @_;
    my $r = "$q1$s$q2";
    #print($r);
    return $r;    
}


# my $input = <<'END_INPUT';
# return {
#     armpw = {
# 	name = "Pee Wee",
# 	unit = true,
# 	maxvelocity = 340,
# 	weapondefs =  {
# 	    [1] = "blah",
# 	    [2] = true
# 	}
#     }
# }
# END_INPUT

# Idea: read stdin until eof into a string and then read the string

sub AnnihilationParser::readBuf 
{
    my($buff,$print) = @_;
	my $recce = Marpa::R2::Scanless::R->new( { grammar => $grammar, semantics_package => 'AnnihilationParser' } );
    $recce->read(\$buff);
    my $result = $recce->value();
    $print //= 0;
    if ($print) {
		print_tiered(0,$$result);
    }
    return $$result;
}

