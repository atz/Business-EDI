package Business::EDI::CodeList::ListParameter;

use base 'Business::EDI::CodeList';
my $VERSION     = 0.02;
sub list_number {return "0558";}
my $usage       = 'B';  # guessed value

# 0558 List parameter                                    []
# Desc: 
# Repr: 
my %code_hash = (

);
sub get_codes { return \%code_hash; }

1;
