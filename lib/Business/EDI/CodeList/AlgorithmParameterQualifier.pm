package Business::EDI::CodeList::AlgorithmParameterQualifier;

use base 'Business::EDI::CodeList';
my $VERSION     = 0.02;
sub list_number {return "0531";}
my $usage       = 'B';

# 0531  Algorithm parameter qualifier
# Desc: Specification of the type of parameter value.
# Repr: an..3

my %code_hash = (
'1' => [ 'Initialisation value, clear text',
    'Identifies the algorithm parameter value as an unencrypted initialisation value.' ],
'2' => [ 'Initialisation value, encrypted under a symmetric key',
    'Identifies the algorithm parameter value as an initialisation value which is encrypted under the symmetric data key.' ],
'3' => [ 'Initialisation value, encrypted under a public key',
    'Identifies the algorithm parameter value as an initialisation value encrypted under the public key of the  receiving party.' ],
'4' => [ 'Initialisation value, format mutually agreed',
    'Identifies the algorithm parameter value as an initialisation value in a format agreed between the two parties.' ],
'5' => [ 'Symmetric key, encrypted under a symmetric key',
    'Identifies the algorithm parameter value as a symmetric key which is encrypted with a previously agreed algorithm under a previously exchanged symmetric key.' ],
'6' => [ 'Symmetric key, encrypted under a public key',
    'Identifies the algorithm parameter value as a symmetric key encrypted under the public key of the  receiving party.' ],
'7' => [ 'Symmetric key, signed and encrypted',
    "Identifies the algorithm parameter value as a symmetric key signed under the sender's secret key, then encrypted under the receiver's public key." ],
'8' => [ 'Symmetric key encrypted under an asymmetric key common to',
     ],
'the' => [ 'sender and the receiver',
    'Identifies the algorithm parameter value as a symmetric key encrypted under an asymmetric key common to the sender and the receiver (use of Diffie and Hellman scheme, for instance).' ],
'9' => [ 'Symmetric key name',
    'Identifies the algorithm parameter value as the name of a symmetric key. This may be used in the case where a key relationship has already been established between the sender and receiver.' ],
'10' => [ 'Key encrypting key name',
    'Identifies the parameter value as the name of a key encrypting key.' ],
'11' => [ 'Symmetric key, format mutually agreed',
    'Identifies the algorithm parameter value as a symmetric key in a format agreed between the two parties.' ],
'12' => [ 'Modulus',
    'Identifies the algorithm parameter value as the modulus of a public key which is to be used according to the function defined by the use of algorithm.' ],
'13' => [ 'Exponent',
    'Identifies the algorithm parameter value as the exponent of a public key which is to be used according to the function defined by the use of algorithm.' ],
'14' => [ 'Modulus length',
    'Identifies the algorithm parameter value as the length of the modulus (in bits) of the public key used in the algorithm. The length is independent of whatever filtering function may be in use.' ],
'15' => [ 'Generic parameter 1',
    'Identifies the algorithm parameter value as the first generic parameter.' ],
'16' => [ 'Generic parameter 2',
    'Identifies the algorithm parameter value as the second generic parameter.' ],
'17' => [ 'Generic parameter 3',
    'Identifies the algorithm parameter value as the third generic parameter.' ],
'18' => [ 'Generic parameter 4',
    'Identifies the algorithm parameter value as the fourth generic parameter.' ],
'19' => [ 'Generic parameter 5',
    'Identifies the algorithm parameter value as the fifth generic parameter.' ],
'20' => [ 'Generic parameter 6',
    'Identifies the algorithm parameter value as the sixth generic parameter.' ],
'21' => [ 'Generic parameter 7',
    'Identifies the algorithm parameter value as the seventh generic parameter.' ],
'22' => [ 'Generic parameter 8',
    'Identifies the algorithm parameter value as the eighth generic parameter.' ],
'23' => [ 'Generic parameter 9',
    'Identifies the algorithm parameter value as the ninth generic parameter.' ],
'24' => [ 'Generic parameter 10',
    'Identifies the algorithm parameter value as the tenth generic parameter.' ],
'25' => [ 'DSA parameter P',
    'Identifies the algorithm parameter value as the parameter P of DSA algorithm.' ],
'26' => [ 'DSA parameter Q',
    'Identifies the algorithm parameter value as the parameter Q of DSA algorithm.' ],
'27' => [ 'DSA parameter G',
    'Identifies the algorithm parameter value as the parameter G of DSA algorithm.' ],
'28' => [ 'DSA parameter Y',
    'Identifies the algorithm parameter value as the parameter Y of DSA algorithm.' ],
'29' => [ 'Initial value for CRC calculation',
    'Identifies the algorithm parameter value as the initial value for the CRC calculation.' ],
'30' => [ 'Initial directory tree',
    'Identifies the algorithm parameter value as the initial directory tree for the data compression algorithm specified.' ],
'31' => [ 'Integrity value offset',
    'Identifies the algorithm parameter value as the offset within the compressed text where the integrity value is located.' ],
'33' => [ 'Generator',
    'Identifies the algorithm parameter value as the generator for a secret key agreement mechanism.' ],
'34' => [ 'Symmetric key activation date/time',
    'Identifies the activation date/time of a symmetric key. The date/time format shall be CCYYMMDDHHMMSS.' ],
'35' => [ 'PKCS#1-EME-OAEP HF',
    'Identifies the algorithm parameter value as the code of the hash function used by EME-OAEP padding mechanism as defined in PKCS#1, Version 2.' ],
'36' => [ 'PKCS#1-EME-OAEP MGF',
    'Identifies the algorithm parameter value as the code of the mask generation function used by EME-OAEP padding mechanism as defined in PKCS#1, Version 2.' ],
'37' => [ 'PKCS#1-EME-OAEP P Init',
    'Identifies the algorithm parameter value as the initial octets of the encoding parameter octet string (P) used by EME-OAEP padding mechanism as defined in PKCS#1, Version 2.' ],
'38' => [ 'PKCS#1-EME-OAEP P Cont',
    'Identifies the algorithm parameter value as the additional octets of the encoding parameter octet string (P) following the initial octets, used by EME-OAEP padding mechanism as defined in PKCS#1, Version 2.' ],
'39' => [ 'PKCS#1-EME-OAEP P Final',
    'Identifies the algorithm parameter value as the final octets of the encoding parameter octet string (P) following the initial or additional octets, used by EME- OAEP padding mechanism as defined in PKCS#1, Version 2.' ],
'40' => [ 'PKCS#1-EME-OAEP HF/MGF',
    'Identifies the algorithm parameter value as the code of the hash function used by the mask generation function used by EME-OAEP padding mechanism as defined in PKCS#1, Version 2.' ],
'41' => [ 'PKCS#1-EME-OAEP LENGTH',
    'Identifies the algorithm parameter value as the intended length of the result produced by EME-OAEP padding mechanism as defined in PKCS#1, Version 2.' ],
'ZZZ' => [ 'Mutually agreed',
    'Mutually agreed between trading partners.' ],
);
sub get_codes { return \%code_hash; }

1;
