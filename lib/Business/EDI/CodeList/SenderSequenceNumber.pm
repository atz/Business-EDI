package Business::EDI::CodeList::SenderSequenceNumber;

use base 'Business::EDI::CodeList';
my $VERSION     = 0.02;
sub list_number {return "0320";}
my $usage       = 'B';  # guessed value

# 0320 Sender sequence number                                    []
# Desc: 
# Repr: 
my %code_hash = (

);
sub get_codes { return \%code_hash; }

1;
