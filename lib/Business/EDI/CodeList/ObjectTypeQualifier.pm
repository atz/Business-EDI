package Business::EDI::CodeList::ObjectTypeQualifier;

use base 'Business::EDI::CodeList';
my $VERSION     = 0.02;
sub list_number {return "0805";}
my $usage       = 'B';

# 0805  Object type qualifier
# Desc: Qualifier referring to the type of object.
# Repr: an..3

my %code_hash = (
'1' => [ 'Computer environment type',
    'Specification of the type of computer environment for which the object is intended.' ],
'2' => [ 'Computer environment version',
    'Specification of the version of the computer environment for which the object is intended.' ],
'3' => [ 'Computer environment release',
    'Specification of the release of the computer environment for which the object is intended.' ],
'5' => [ 'Computer environment name',
    'Specification of the name of the computer environment for which the object is intended.' ],
'6' => [ 'Non-EDIFACT security level code',
    'Specification of the level such as interchange, group or message at which non-EDIFACT security is applied to the data constituting the object.' ],
'7' => [ 'Non-EDIFACT security version',
    'Specification of the version of the non-EDIFACT security technique applied to the data constituting the object.' ],
'8' => [ 'Non-EDIFACT security release',
    'Specification of the release of the non-EDIFACT security technique applied to the data constituting the object.' ],
'9' => [ 'Non-EDIFACT security technique',
    'Specification of the non-EDIFACT security technique applied to the data constituting the object.' ],
'10' => [ 'Non-EDIFACT security free text information',
    'Free form description of the non-EDIFACT security technique applied to the data constituting the object.' ],
'11' => [ 'File identification by number',
    'Identification number assigned to the file constituting the object.' ],
'12' => [ 'File identification by name',
    'Name assigned to the file constituting the object.' ],
'13' => [ 'File format',
    'Specification of the format of the file constituting the object.' ],
'14' => [ 'File version',
    'Specification of the version of the file constituting the object.' ],
'15' => [ 'File release',
    'Specification of the release of the file constituting the object.' ],
'16' => [ 'File status',
    'Specification of the status of the file constituting the object.' ],
'17' => [ 'File size',
    'Specification of the size of the file constituting the object in bytes.' ],
'18' => [ 'File description',
    'Free form description of the file constituting the object.' ],
'19' => [ 'File block type',
    'Specification of the type of blocking used to partition the file constituting the object.' ],
'20' => [ 'File block length',
    'Specification of the length of the blocks used to partition the file constituting the object.' ],
'21' => [ 'File record length',
    'Specification of the length of the records contained in the file constituting the object expressed as the number of character positions.' ],
'22' => [ 'Program identification by number',
    'Identification number assigned to the program constituting the object.' ],
'23' => [ 'Program identification by name',
    'Name assigned to the program constituting the object.' ],
'24' => [ 'Program type',
    'Specification of the type of program constituting the object.' ],
'25' => [ 'Program version',
    'Specification of the version of the program constituting the object.' ],
'26' => [ 'Program release',
    'Specification of the release of the program constituting the object.' ],
'27' => [ 'Program status',
    'Specification of the status of the program constituting the object.' ],
'28' => [ 'Program description',
    'Free form description of the program constituting the object.' ],
'29' => [ 'Program size',
    'Specification of the size of the program constituting the object in bytes.' ],
'30' => [ 'Interchange format',
    'Specification of the format of the interchange constituting the object.' ],
'31' => [ 'Interchange version',
    'Specification of the version of the interchange constituting the object.' ],
'32' => [ 'Interchange release',
    'Specification of the release of the interchange constituting the object.' ],
'33' => [ 'Interchange status',
    'Specification of the status of the interchange constituting the object.' ],
'34' => [ 'Interchange identification',
    'Identification number assigned to the interchange constituting the object.' ],
'35' => [ 'Compression technique identification',
    'An identification assigned to the compression technique applied to the object.' ],
'36' => [ 'Compression technique version',
    'Specification of the version of the compression technique applied to the object.' ],
'37' => [ 'Compression technique release',
    'Specification of the release of the compression technique applied to the object.' ],
'38' => [ 'Drawing identification by name',
    'Name assigned to the drawing constituting the object.' ],
'39' => [ 'Drawing identification by number',
    'Identification number assigned to the drawing constituting the object.' ],
'40' => [ 'Drawing type',
    'Specification of the type of drawing constituting the object.' ],
'41' => [ 'Drawing format',
    'Specification of the format of the drawing constituting the object.' ],
'42' => [ 'Drawing version',
    'Specification of the version of the drawing constituting the object.' ],
'43' => [ 'Drawing release',
    'Specification of the release of the drawing constituting the object.' ],
'44' => [ 'Drawing status',
    'Specification of the status of the drawing constituting the object.' ],
'45' => [ 'Drawing size',
    'Specification of the size of the drawing constituting the object in bytes.' ],
'46' => [ 'Drawing description',
    'Free form description of the drawing constituting the object.' ],
'48' => [ 'Filter type',
    'Specification of the type of filtering technique applied to the object.' ],
'49' => [ 'Filter version',
    'Specification of the version of the filtering technique applied to the object.' ],
'50' => [ 'Filter code page',
    'Specification of the code page used for the filtering technique applied to the object.' ],
'51' => [ 'Filter technique',
    'Specification of the filtering technique applied to the object.' ],
'52' => [ 'Character set repertoire identification',
    'Identification of the character set repertoire used for the object.' ],
'53' => [ 'Character set encoding technique',
    'Specification of the character set encoding technique used for the object.' ],
'54' => [ 'Character set encoding technique code page',
    'Specification of the code page used for the character set encoding technique used for the object.' ],
'55' => [ 'Certificate type',
    'Specification of the type of certificate constituting the object.' ],
'56' => [ 'Certificate version',
    'Specification of the version of the certificate constituting the object.' ],
'57' => [ 'Certificate release',
    'Specification of the release of the certificate constituting the object.' ],
'58' => [ 'Certificate status',
    'Specification of the status of the certificate constituting the object.' ],
'60' => [ 'Certificate identification by name',
    'Name assigned to the certificate constituting the object.' ],
'61' => [ 'Certificate identification by number',
    'Identification number assigned to the certificate constituting the object.' ],
'62' => [ 'Certificate format',
    'Specification of the format of the certificate constituting the object.' ],
'63' => [ 'Certificate code page',
    'Specification of the code page used when generating the certificate constituting the object.' ],
);
sub get_codes { return \%code_hash; }

1;
