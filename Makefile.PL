

use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME         => 'Business::EDI',
    VERSION_FROM => 'lib/Business/EDI.pm', # finds \$VERSION
    AUTHOR       => 'Joe Atzberger (atz@esilibrary.com)',
    ABSTRACT     => 'Top level generator of U.N. EDI objects',
    PREREQ_PM    => {
                     'Test::Simple' => 0.88,
                     'Exporter::Easy' => 0.14,
                     'UNIVERSAL::require' => 0.10,
                     'JSON::XS' => 2.01,
                    },
);
