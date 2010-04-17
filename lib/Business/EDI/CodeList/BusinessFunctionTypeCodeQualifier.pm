package Business::EDI::CodeList::BusinessFunctionTypeCodeQualifier;

use base 'Business::EDI::CodeList';
my $VERSION     = 0.01;
my $list_number = 4027;
my $usage       = 'B';

# 4027  Business function type code qualifier                   [B]
# Desc: Code qualifying the type of business function.
# Repr: an..3

my %code_hash = (
'1' => [ 'Underlying business function',
    'The types of business.' ],
);
sub get_codes { return \%code_hash; }

1;
