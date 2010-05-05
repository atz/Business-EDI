package Business::EDI;

use strict;
use warnings;
use Carp;
# use Data::Dumper;

our $VERSION = 0.02;

use UNIVERSAL::require;
use File::Find::Rule;
use Business::EDI::CodeList;
use Business::EDI::Composite;
use Business::EDI::DataElement;
our $debug = 0;

our $AUTOLOAD;
sub DESTROY {}  #
sub AUTOLOAD {
    my $self  = shift;
    my $class = ref($self) or croak "AUTOLOAD error: $self is not an object, looking for $AUTOLOAD";
    my $name  = $AUTOLOAD;

    $name =~ s/.*://;                # strip leading package stuff
    $name =~ s/^s(eg(ment)?)?//i or  # strip segment (a prefix to avoid numerical method names)
    $name =~ s/^p(art)?//i;          # strip part -- autoload parallel like ->part4343 to ->part(4343)

    warn "AUTOLOADING '$name' for " . $class;
    unless (exists $self->{_permitted}->{$name}) {
        # first try to reach trhough any Cxxx Composites, if the target is unique
        return __PACKAGE__->_deepload($self, $name, @_); # not $self->_deepload - avoid recursion
    }

    if (@_) {
        return $self->{$name} = shift;
    } else {
        return $self->{$name};
    }
}

sub _deepload {
    my $pkg  = shift; # does nothing
    my $self = shift    or return;
    my $name = shift    or return;
    $self->{_permitted} or return;

    my @keys = grep {/^C\d{3}$/} keys %{$self->{_permitted}};
    my $ccount = scalar(@keys);
    warn "Looking for $name under $ccount Composites: " . join(' ', @keys);
    @keys = grep {
        $self->{$_}               and
        $self->{$_}->{_permitted} and
        $self->{$_}->{$name}
        } @keys;
    my $hitcount = scalar(@keys);
    warn "Found $name possible in $hitcount Composites: " . join(' ', @keys);
    if ($hitcount == 1) {
        if (@_) {
            return $self->{$keys[0]}->{$name} = shift;
        } else {
            return $self->{$keys[0]}->{$name};
        }
    } elsif ($hitcount > 1) {
        croak "AUTOLOAD error: Cannot access '$name' field of class '" . ref($self) . "', "
            . " $hitcount indeterminate matches in collapsable subelements";
    }
    croak "AUTOLOAD error: Cannot access '$name' field of class '" . ref($self) . "' (or $ccount collapsable subelements)"; 
}

our $error;          # for the whole class
our $spec_dir;       # for the whole class
our $spec_map = {
    message   => 'DMD',
    segment   => 'DSD',
    composite => 'DCD',
    codelist  => 'DCL',
    element   => 'DED',
};
my %fields = (
    spec_files => 1,
);

# Constructors

sub new {
    my ($class, %args) = @_;
    my $stuff = {
        _permitted => %fields,   
    };
    foreach (keys %args) {
        $_ eq 'spec' and next;  # special case
        $stuff->{_permitted}->{$_} or croak "Unrecognized argument to new: $_ => $args{$_}";
    }
    my $self = bless($stuff, $class);
    if ($args{spec}) {
        $self->spec($args{$_}) or croak "Unrecognized spec $args{$_}";
    }
    return $self;
}

sub codelist {
    my $self = shift;
    # Business::EDI::CodeList->require;
    Business::EDI::CodeList->new_codelist(@_);
}

sub segment {
    my $self = shift;
#    Business::EDI::Segment->new(@_);
}

sub message {
    my $self = shift;
#    Business::EDI::Message->new(@_);
}

sub dataelement {
    my $self = shift;
    # Business::EDI::DataElement->require;
    Business::EDI::DataElement->new(@_);
}


sub get_spec_dir {
    my $self = shift;
    $self->{spec_dir} and return $self->{spec_dir};
    $spec_dir         and return $spec_dir;
    my $target = 'Business/EDI/data/edifact/untdid';    # path relative to @INC 
    my @dirs = @INC;
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
sub spec {        # spec(code, nonfatal)
    my $self = shift;
    return $self->{spec} unless @_;
    my $code = shift;
    my @files = $self->get_spec_files($code);
    unless (@files) {
        $self->error("Unrecognized spec code $code (no csv files)");
        return;
    }
    $self->{spec_files} = \@files;
    return $self->{spec}= $code;
}
sub get_spec_files {
    my $self = shift;
    my $code = @_ ? shift : $self->spec;
    $code or return carp_error("No EDI spec revision argument to spec_files().  Nothing to look for!");
    my $dir = $self->get_spec_dir or return carp_error("EDI Specifications directory missing");
    return File::Find::Rule->maxdepth(1)->name("*.$code.csv")->file()->in($dir);
}

# Accessor get/set methods
sub error {
    my ($self, $msg, $quiet) = @_;
    $msg or return $self->{error} || $error;  # just an accessor
    ($debug or ! $quiet) and carp $msg;
    return $self->{error} = $msg;
}

sub carp_error {
    carp shift;
    return;     # undef: important!
}

=head2 ->unblessed($body, \@codes)

=cut

sub unblessed {     # call like Business::EDI->unblessed(\%hash, \@codes);
    my $class    = shift;
    my $body     = shift;
    my $codesref = shift;
    $body     or return carp_error "1st required argument to unblessed() is EMPTY";
    $codesref or return carp_error "2nd required argument to unblessed() is EMPTY";
    unless (ref($body)     eq 'HASH') {
        return carp_error "1st argument to unblessed() must be HASHREF, not '" . ref($body) . "'";
    }
    unless (ref($codesref) eq 'ARRAY') {
        return carp_error "2nd argument to unblessed() must be ARRAYREF, not '" . ref($codesref) . "'";
    }
    $debug and print STDERR "good: unblessed() got a body\n";
    my $self = {};
    foreach (@$codesref) {
        $self->{_permitted}->{$_} = 1;
        $body->{$_} or next;
        $self->{$_} = Business::EDI->subelement({$_ => $body->{$_}}) || $body->{$_};
    }
    return $self;
}

# similar to autoload, but by argument, does get and set
sub part {
    my $self  = shift;
    my $class = ref($self) or croak "part() object method error: $self is not an object";
    my $name  = shift or return;

    unless (exists $self->{_permitted}->{$name}) {
        carp "part() error: Cannot access '$name' field of class '$class'"; 
        return;     # authoload would have croaked here
    }

    if (@_) {
        return $self->{$name} = shift;
    } else {
        return $self->{$name};
    }
}


# Example data:
# 'BGM', {
#     '1004' => '582822',
#     '4343' => 'AC',
#     '1225' => '29',
#     'C002' => {
#        '1001' => '231'
#     }
# }

our $codelist_map;

# Tricky recursive constructor!
sub subelement {
    my $self = shift;
    my $body = shift;
    if (! $body) {
        carp "required argument to subelement() empty";
        return;
    }
    unless (ref $body) {
        $debug and carp "subelement() got a regular scalar argument. Returning it ('$body') as subelement";
        return $body;
    }
    ref($body) =~ /^Business::EDI/ and return $body;    # it's already an EDI object, return it

    if (ref($body) eq 'ARRAY') {
        if (scalar(@$body) != 2) {
            carp "Array expected to be psuedohash with 2 elements, or wrapper with 1, instead got " . scalar(@$body);
            return; # [(map {ref($_) ? $self->subelement($_) : $_} @$body)];     # recursion
        } else {
            $body = {$body->[0] => $body->[1]};
        }
    }
    elsif (ref($body) ne 'HASH') {
        carp "argument to subelement() should be ARRAYref or HASHref or Business::EDI subobject, not type '" . ref($body) . "'";
        return;
    }
    $debug and print STDERR "good: we got a body in class " . (ref($self) || $self) . "\n";
    $codelist_map ||= Business::EDI::CodeList->codemap;
    my $new = {};
    foreach (keys %$body) {
        my $ref = ref($body->{$_});
        if ($codelist_map->{$_}) {      # If the key is in the codelist map, it's a codelist
            $new->{$_} = Business::EDI::CodeList->new_codelist($_, $body->{$_});
        } elsif ($_ =~ /^C\d{3}$/) {
            $new->{$_} = Business::EDI::Composite->new({$_ => $body->{$_}})     # Cxxx codes are for Composite data elements
                or carp "Bad ref ($ref) in body for key $_.  Composite subelement not created";
        } elsif ($ref eq 'ARRAY') {
            my $count = scalar(@{$body->{$_}});
            $count == 1 or carp "Repeated section '$_' appears $count times.  Only handling first appearance";  # TODO: fix this
            $new->{repeats}->{$_} = -1;
            $new->{$_} = $self->subelement($body->{$_}->[0])                 # ELSE, break the ref down (recursively)
                or carp "Bad ref ($ref) in body for key $_.  Subelement not created";
        } elsif ($ref) {
            $new->{$_} = $self->subelement($body->{$_})                 # ELSE, break the ref down (recursively)
                or carp "Bad ref ($ref) in body for key $_.  Subelement not created";
        } else {
            $new->{$_} = Business::EDI::DataElement->new($_, $body->{$_});      # Otherwise, a terminal (non-ref) data node means it's a DataElement
                  # like Business::EDI::DataElement->new('1225', '582830');
        }
        (scalar(keys %$body) == 1) and return $new->{$_};   # important: if that's our only key/pair, return the object itself, no wrapper.
    }
    return $new;
}

1;
__END__

=head1 NAME

Business::EDI - Top level class for generating U.N. EDI interchange objects and subobjects.

=head1 SYNOPSIS

  use Business::EDI;
  
  my $rtc = Business::EDI->codelist('ResponseTypeCode', $json) or die "Unrecognized code!";
  printf "EDI response type: %s - %s (%s)\n", $rtc->code, $rtc->label, $rtc->value;

=head1 DESCRIPTION

At present, the EDI input processed by Business::EDI objects is JSON from the B<edi4r> ruby library.  

=head1 WARNINGS

This code is preliminary.  EDI is a big spec with many revisions, and the coverage for all 
segments, elements and message types is not yet present.  At the lowest level, all codelists from the most recent
spec (D09B) are present.  

=head1 SEE ALSO

edi4r - http://edi4r.rubyforge.org

=head1 AUTHOR

Joe Atzberger

