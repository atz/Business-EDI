package Business::EDI::CodeList::RecipientReferencepassword;

use base 'Business::EDI::CodeList';
my $VERSION     = 0.02;
sub list_number {return "0022";}
my $usage       = 'B';  # guessed value

# 0022 Recipient reference/password                                    []
# Desc: 
# Repr: 
my %code_hash = (

);
sub get_codes { return \%code_hash; }

1;
