package Business::EDI::CodeList::DialogueReleaseNumber;

use base 'Business::EDI::CodeList';
my $VERSION     = 0.02;
sub list_number {return "0344";}
my $usage       = 'B';  # guessed value

# 0344 Dialogue release number                                    []
# Desc: 
# Repr: 
my %code_hash = (

);
sub get_codes { return \%code_hash; }

1;
