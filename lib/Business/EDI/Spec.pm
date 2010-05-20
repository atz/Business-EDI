package Business::EDI::Spec;

use base qw/Business::EDI/;

use strict;
use warnings;
use Carp;

our $VERSION = 0.01;

use UNIVERSAL::require;
use Data::Dumper;
use File::Find::Rule;
use File::Spec;
our $debug = 0;

our $spec_dir;       # for the whole class
our $spec_map = {
    message   => {code => 'DMD', cache => {}, keys => [qw/code mandatory repeats    /]},
    segment   => {code => 'DSD', cache => {}, keys => [qw/pos code mandatory repeats/]},
    composite => {code => 'DCD', cache => {}, keys => [qw/pos code class def        /]},
#   codelist  => {code => 'DCL', cache => {}, keys => []},
    element   => {code => 'DED', cache => {}, },
};

my %fields = (
    spec_files      => undef,
    edi_flavor      => 'edifact',   # someday could be x12 or something...
    version_default => 'd08a',
    version         => undef,
    interactive     => 0,
);

# Constructors

sub new {
    my $class = shift;
    my %args;
    if (scalar(@_) == 1) {
        $args{version} = shift;
    } else {
        scalar(@_) % 2 and croak "Odd number of arguments to new() incorrect.  Use (name1 => value1) style.";
        %args = @_;
    }
    my $stuff = {_permitted => {(map {$_ => 1} keys %fields)}, %fields};
    foreach (keys %args) {
        $_ eq 'version' and next;  # special case
        exists ($stuff->{_permitted}->{$_}) or croak "Unrecognized argument to new: $_ => $args{$_}";
    }
    my $self = bless($stuff, $class);
    my $version = $args{version} || $self->version || $fields{version} || $self->version_default || $fields{version_default};
    $version eq 'default' and $version = $self->version_default || $fields{version_default};
    $debug and warn "### Setting version $version";
    $self->set_spec_version($version) or croak "Unrecognized spec version '$version'";
    $debug and print Dumper($self);
    return $self;
}

sub get_spec_dir {
    my $self = shift;
    $self->{spec_dir} and return $self->{spec_dir};
    $spec_dir         and return $spec_dir;
    my $target = 'Business/EDI/data/edifact/untdid';    # path relative to @INC.  Don't worry about filesystem oddities (see split below)
    my @dirs   = @INC;
    foreach (split /\//, $target) {
        @dirs = File::Find::Rule->maxdepth(1)->name($_)->directory()->in(@dirs);
    }
    # we use serial Find's so we don't have to care about OS/filesystem variations.  And we only do it once, typcially.
    $debug and print STDERR "# spec_dir() found ", scalar(@dirs), " $target dirs:\n# ", join("\n# ", @dirs), "\n";
    unless (@dirs) {
        warn "Could not locate specifications directory ($target) in \@INC";
        return;
    }
    return $spec_dir = $dirs[0];
}

sub set_spec_version {
    my $self = shift;
    my $code = shift or return $self->carp_error("set_spec_version: required version spec code argument not provided");
    my @files = $self->find_spec_files($code);
    unless (@files) {
        $self->error("set_spec_version: Unrecognized spec code '$code' (no csv files)");
        return;
    }
    $self->{spec_files} = \@files;
    return $self->{version} = $code;
}

sub find_spec_files {
    my $self = shift;
    my $code = @_ ? shift : ($self->version || $self->version_default);
    $code or return $self->carp_error("No EDI spec revision argument to spec_files().  Nothing to look for!");
    my $dir = $self->get_spec_dir or return $self->carp_error("EDI Specifications directory missing");
    $debug and warn "get_spec_dir returned '$dir'.  Looking for $dir/*.$code.csv";
    return File::Find::Rule->maxdepth(1)->name("*.$code.csv")->file()->in($dir);
}

sub get_spec_handle {
    my $self    = shift;
    my $type    = shift || '';
    my $version = @_ ? shift : $self->version;
    $version or return $self->carp_error("spec version is not set (nor passed as a parameter)");
    my $trio;
    unless ($type and $trio = $spec_map->{$type}) {
        return $self->carp_error("Type '$type' is not mapped to a spec file.  Options are: " . join(' ', keys %$spec_map));
    }
    my @files = $self->find_spec_files;
    my $name  = $self->csv_filename($trio->{code}, $version);
    $debug and print STDERR "get_spec_handle() checking " . scalar(@files) . " files for: $name\n";
    my @hits = grep {(File::Spec->splitpath($_))[2] eq $name} @files;
    scalar(@hits) or return $self->carp_error("Spec file for $type ($name) not found");
    my $file = $hits[0];
    $debug and warn "get_spec_handle opening $file";
    open (my $fh, "<$file") or carp "get_spec_handle failed to open $file";
    return $fh;
}

sub csv_filename {
    my $self = shift;
    return ($self->interactive ? 'I' : 'E') . (shift || '') . '.' . (shift || '') . ".csv";
}

sub get_spec {
    my $self = shift;
    my $type = shift   or return $self->carp_error("get_spec: required argument for spec 'type' missing.  Options are: " . join(', ', keys %$spec_map));
    $spec_map->{$type} or return $self->carp_error("Type '$type' is not mapped to a spec file.  Options are: " . join(' ', keys %$spec_map));
    my $version = @_ ? shift : $self->version;
    $version or return $self->carp_error("spec version is not set (nor passed as a parameter)");
    if ($spec_map->{$type}->{cache}->{$version}) {
        $debug and print STDERR "cache hit for spec_map->{$type}->{cache}->{$version}\n";
    } else {
        my $fh = $self->get_spec_handle($type) or return;
        $spec_map->{$type}->{cache}->{$version} = $self->parse_plexer($type, $fh);
    }
    return $spec_map->{$type}->{cache}->{$version};
}

sub parse_plexer {
    my $self = shift;
    my $type = shift or croak("parse_plexer: required argument for spec 'type' missing.  Options are: " . join(', ', keys %$spec_map));
    my $fh   = shift or croak("parse_plexer: required argument for 'filehandle' missing");
    my @slurp = <$fh>;
    chomp @slurp;
    $debug and print STDERR "parsing CSV for $type: $. lines\n";
    if ($type eq 'element') {
        # 1000;an..35;B;Document name
        return { 
            map {
                s/\s*$//;   # kill trailing spaces
                my @four = split ';', $_;
                $four[0] => {
                    code  => $four[0],
                    def   => $four[1],
                    class => $four[2],
                    label => $four[3]
                }
            } @slurp
       };
    } elsif ($type eq 'composite' or $type eq 'message' or $type eq 'segment') {
        return {
            map {
                my ($code, $label, @rest) = split ';', $_;
                my @codeparts = split ':', $code;
                $code = $codeparts[0];
                $code .= "_" . $codeparts[-1] if ($codeparts[-1] and $codeparts[-1] ne $code);  # key may include _SegmentGroup
                $debug and $debug > 1 and print STDERR "parsing CSV for $type/$code ($label)\n";
                $code => {
                    code    => $code,
                #   version => $codeparts[1] . $codeparts[2],
                    label   => $label,
                    parts   => $self->parse_array(\@rest, $spec_map->{$type}->{keys})
                }
            } @slurp
        };
    } else {
        croak "Cannot parse CSV for unknown type '$type'";
    }
}

# my $foobar = parse_array(\@elements, @keys)
sub parse_array {
    my $self = shift;
    @_ >= 2 or croak "\$self->parse_array needs two array_ref arguments";
    my @parts = @{(shift)}; # extra parens req'd
    my @keys  = @{(shift)}; # extra parens req'd

    @keys or croak "No keys passed to parse_array.  Cannot interpret spec line";
    (scalar(@parts) % scalar(@keys)) and croak sprintf "Cannot parse %s elements evenly into parts of %s for body: %s", scalar(@parts), scalar(@keys), join(';', @parts); 

    my @return;
    while (@parts) {
        my %chunk;
        foreach (@keys) {
            my $value = shift @parts;
            if ($_ eq 'mandatory') {
                next unless $value eq 'M';  # conditional is assumed
                $value = 1;
            }
            $chunk{$_} = $value;
        }
        push @return, \%chunk;
    }
    return \@return;
}

sub dump_cache {
    return Dumper($spec_map);
}
sub clear_cache {
    foreach (keys %$spec_map) {
        $spec_map->{$_}->{cache} = {};
    }
}

1;
__END__

=head1 NAME

Business::EDI::Spec - Object class for CSV-based U.N. EDI specifications

=head1 SYNOPSIS

  use Business::EDI::Spec;
  
  my $spec = Business::EDI::Spec->new('segment');

=head1 DESCRIPTION

CSV files originally from edi4r are included as part of Business::EDI.  They are used to define the many different
messages, segements, data elements, composite data elements, and codelists that are part of a given version of the 
U.N. specification.  

The CSV spec files are composed differently for the different structures defined.
So we have to oarse them differently.

==> Business/EDI/data/edifact/untdid/EDCD.d07a.csv  # Composite Elements
CompositeCode;label;pos;code;mandatory;def;[pos;code;mandatory;def;...]
C001;TRANSPORT MEANS;010;8179;C;an..8;020;1131;C;an..17;030;3055;C;an..3;040;8178;C;an..17;
C002;DOCUMENT/MESSAGE NAME;010;1001;C;an..3;020;1131;C;an..17;030;3055;C;an..3;040;1000;C;an..35;
C004;EVENT CATEGORY;010;9637;C;an..3;020;1131;C;an..17;030;3055;C;an..3;040;9636;C;an..70;

C001 => {label => 'TRANSPORT MEANS;010;8179;C;an..8;020;1131;C;an..17;030;3055;C;an..3;040;8178;C;an..17;

==> Business/EDI/data/edifact/untdid/EDED.d07a.csv  # Data Elements
code;def;class(?):label
1000;an..35;B;Document name
1001;an..3;C;Document name code
1003;an..6;B;Message type code

1000 => {label => 'an..35;B;Document name

==> Business/EDI/data/edifact/untdid/EDMD.d07a.csv  # Messages
MessageCode:x:rel:org:z:SegmentGroup;label;SegCode;mandatory;repeats;[SegCode;mandatory;repeats;...]
APERAK:D:07A:UN::;Application error and acknowledgement message;UNH;M;1;BGM;M;1;DTM;C;9;FTX;C;9;CNT;C;9;SG1;C;99;SG2;C;9;SG3;C;9;SG4;C;99999;UNT;M;1
APERAK:D:07A:UN::SG1;SG01;DOC;M;1;DTM;C;99
APERAK:D:07A:UN::SG2;SG02;RFF;M;1;DTM;C;9

APERAK:D:07A:UN:: => {label => 'Application error and acknowledgement message',
    UNH;M;1;
    BGM;M;1;
    DTM;C;9;FTX;C;9;CNT;C;9;SG1;C;99;SG2;C;9;SG3;C;9;SG4;C;99999;UNT;M;1

==> Business/EDI/data/edifact/untdid/EDSD.d07a.csv  # Segments
SegCode;label;pos;code;class;repeats[pos;code;class;repeats;...]
ADR;ADDRESS;010;C817;C;1;020;C090;C;1;030;3164;C;1;040;3251;C;1;050;3207;C;1;060;C819;C;5;070;C517;C;5;
AGR;AGREEMENT IDENTIFICATION;010;C543;C;1;020;9419;C;1;
AJT;ADJUSTMENT DETAILS;010;4465;M;1;020;1082;C;1;

ADR => {label => 'ADDRESS',
    010;C817;C;1;020;C090;C;1;030;3164;C;1;040;3251;C;1;050;3207;C;1;060;C819;C;5;070;C517;C;5;

==> Business/EDI/data/edifact/untdid/IDCD.d07a.csv   # Composites (interactive)
E001 => {label => 'ADDRESS DETAILS;010;3477;M;an..3;020;3286;M;an..70;030;3286;C;an..70;040;3286;C;an..70;050;3286;C;an..70;060;3286;C;an..70;070;3286;C;an..70;

==> Business/EDI/data/edifact/untdid/IDMD.d07a.csv   # Messages (interactive)
MsgCode:x:rel:org:z:SegmentGroup;label;SegCode;mandatory;class;repeats;;[mandatory;class;repeats;...]
IHCEBI:D:07A:UN::;Interactive health insurance eligibility and benefits inquiry and;UIH;M;1;MSD;M;1;SG1;C;9;SG2;C;1;UIT;M;1
IHCEBI:D:07A:UN::SG1;SG01;PRT;M;1;NAA;C;9;CON;C;9;FRM;C;9
IHCEBI:D:07A:UN::SG2;SG02;DTI;M;1;ICI;C;1;FRM;C;9;SG3;C;999
IHCEBI:D:07A:UN::SG3;SG03;BCD;M;1;HDS;C;9;DTI;C;1;PRT;C;9;FRM;C;9
IHCLME:D:07A:UN::;Health care claim or encounter request and response - interactive;UIH;M;1;MSD;C;1;PRT;C;9;NAA;C;9;CON;C;9;BLI;C;1;ITC;C;1;FRM;C;99;SG1;C;3;SG2;C;99;UIT;M;1
IHCLME:D:07A:UN::SG1;SG01;OTI;M;1;NAA;C;2
IHCLME:D:07A:UN::SG2;SG02;PSI;M;1;DNT;C;35


==> Business/EDI/data/edifact/untdid/IDSD.d07a.csv   # Segments (interactive)
SegCode;label;pos;code;mandatory;repeats(?)
AAI;ACCOMMODATION ALLOCATION INFORMATION;010;E997;M;20;
ADS;ADDRESS;010;E817;C;1;020;E001;C;1;030;3164;C;1;040;3251;C;1;050;3207;C;1;060;E819;C;1;070;E517;C;1;

AAI => {label => 'ACCOMMODATION ALLOCATION INFORMATION',
    pos => '010',
    E997;M;20;

=head1 TO DO

Parsing for interactive specs.

=head1 SEE ALSO

edi4r - http://edi4r.rubyforge.org

Business::EDI

=head1 AUTHOR

Joe Atzberger

