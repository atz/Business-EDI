package Business::EDI;

use strict;
use warnings;
use Carp;
# use Data::Dumper;

our $VERSION = 0.02;

use UNIVERSAL::require;
use Data::Dumper;
use File::Find::Rule;
use File::Spec;
use Business::EDI::CodeList;
use Business::EDI::Composite;
use Business::EDI::DataElement;
use Business::EDI::Spec;
our $debug = 0;
our %debug = ();

our $AUTOLOAD;
sub DESTROY {}  #
sub AUTOLOAD {
    my $self  = shift;
    my $class = ref($self) or croak "AUTOLOAD error: $self is not an object, looking for $AUTOLOAD";
    my $name  = $AUTOLOAD;

    $name =~ s/.*://;                # strip leading package stuff
    $name =~ s/^s(eg(ment)?)?//i or  # strip segment (a prefix to avoid numerical method names)
    $name =~ s/^p(art)?//i;          # strip part -- autoload parallel like ->part4343 to ->part(4343)

    $debug and warn "AUTOLOADING '$name' for " . $class;
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

  # my @segcodes  = grep {/^SG\d+$/ } @subparts;
  # my @compcodes = grep {/^C\d{3}$/} @subparts;
  # if (@compcodes) {
  #     my $otherspec = $spec->get_spec('composite');
  #     foreach (@compcodes) {
  #         # push @subparts, map {$_->{code}} @{$otherspec->{$_}->{parts}};
  #     }
  # }

sub _deepload {
    my $pkg  = shift; # does nothing
    my $self = shift    or return;
    my $name = shift    or return;
    $self->{_permitted} or return;

    my @keys = grep {/^C\d{3}$/} keys %{$self->{_permitted}};
    my $ccount = scalar(@keys);
    $debug and warn "Looking for $name under $ccount Composites: " . join(' ', @keys);

    my @hits;
    if ($ccount) {
        my $spec = $self->spec or croak "You must set a spec version (via constructor or spec method) before EDI can autoload objects";
        my $part = $spec->get_spec('composite');
        foreach my $code (@keys) {
            $part->{$code} or croak(ref($self) . " Object _permitted composite code '$code' not found in spec version " . $spec->version);
            my @subparts = grep {$_->{code} eq $name} @{$part->{$code}->{parts}};
            @subparts and push(@hits, map {$code} @subparts);   
            # important here, we add the Cxxx code once per hit in its subparts.  Multiple hits means we cannot target cleanly.
        }
    }
    my $hitcount = scalar(@hits);
    $debug and warn "Found $name has $hitcount possible matches in $ccount Composites: " . join(' ', @hits);
    if ($hitcount == 1) {
        if (@_) {
            return $self->{$hits[0]}->{$name} = shift;
        } else {
            return $self->{$hits[0]}->{$name};
        }
    } elsif ($hitcount > 1) {
        croak "AUTOLOAD error: Cannot access '$name' field of class '" . ref($self) . "', "
            . " $hitcount indeterminate matches in collapsable subelements";
    }
    $debug and print STDERR "FAILED _deepload of '$name' in object: ", Dumper($self);
    croak "AUTOLOAD error: Cannot access '$name' field of class '" . ref($self) . "' (or $ccount collapsable subelements)"; 
}

our $error;          # for the whole class
my %fields = ();

# Constructors

sub new {
    my $class = shift;
    my %args;
    if (scalar @_ eq 1) {
        $args{version} = shift;
    } elsif (@_) {
        scalar(@_) % 2 and croak "Odd number of arguments to new() incorrect.  Use (name1 => value1) style.";
        %args = @_;
    }
    my $stuff = {_permitted => {(map {$_ => 1} keys %fields)}, %fields};
    foreach (keys %args) {
        $_ eq 'version' and next;  # special case
        exists ($stuff->{_permitted}->{$_}) or croak "Unrecognized argument to new: $_ => $args{$_}";
    }
    my $self = bless($stuff, $class);
    if ($args{version}) {
        $self->spec(version => $args{version}) or croak "Unrecognized spec version '$args{version}'";
    }
    $debug and print Dumper($self);
    return $self;
}

sub codelist {
    my $self = shift;
    # my $spec = $self->spec or croak "You must set a spec version (via constructor or spec method) before EDI can create objects";
    # my $part = $spec->get_spec('message');
    Business::EDI::CodeList->new_codelist(@_);
}

sub _common_constructor {
    my $self = shift;
    my $type = shift or die "Internal error: _common_constructor called without required argument for object type";
    my $spec = $self->spec or croak "You must set a spec version (via constructor or spec method) before EDI can create $type objects";
    my $part = $spec->get_spec($type);
    my $code = uc(shift) or croak "No $type code specified";
    $part->{$code} or return $self->carp_error("$type code '$code' is not found in spec version " . $spec->version);
    my $body = shift;
    my $normal;

    unless (ref($body)     eq 'HASH') {
        return $self->carp_error("body argument to unblessed() must be HASHREF, not '" . ref($body) . "'");
    }
    my @subparts = map {$_->{code}} @{$part->{$code}->{parts}};
    my @required = map {$_->{code}} grep {$_->{mandatory}} @{$part->{$code}->{parts}};

    my $otherspec;
    my @compcodes = grep {/^C\d{3}$/} @subparts;
    if (@compcodes) {
        $otherspec = $spec->get_spec('composite');
    }

    # Now we normalize the body according to the spec (apply wrappers)
    foreach my $key (keys %$body) {
        if (grep {$key eq $_} @subparts) {
            $normal->{$key} = $body->{$key};    # simple case
            next;
        }
        elsif (@compcodes) {
            my @hits;
            foreach my $compcode (@compcodes) {
                push @hits, map {$compcode} grep {$_->{code} eq $key} @{$otherspec->{$compcode}->{parts}};
            }
            if (scalar(@hits) == 1) {
                $normal->{$hits[0]}->{$key} = $body->{$key};    # only one place for it to go, so apply the wrapper
                next;
            } elsif (scalar(@hits) > 1) {
                return $self->carp_error("$type subpart '$key' has " . scalar(@hits)
                    . " indeterminate matches under composites: " . join(', ', @hits)
                );
            }
            return $self->carp_error("$type subpart '$key' not found in spec " . $spec->version);
        }
    }

  # my @segcodes  = grep {/^SG\d+$/ } @subparts;
  # if (@segcodes) {
  #     my $otherspec = $spec->get_spec('segment');
  #     foreach (@segcodes) {
  #         push @subparts, map {$_->{code}} @{$otherspec->{$_}->{parts}};
  #     }
  # }
    $debug and printf STDERR "creating $type/$code with %d spec subparts: %s\n", scalar(@subparts), join(' ', @subparts);
    # push @subparts,  'debug';
    my $unblessed = $self->unblessed($normal, \@subparts);
    $unblessed or return;
    my $new = bless($unblessed, __PACKAGE__ . '::' . ucfirst($type));
    $new->spec($spec);
    # $new->debug($debug{$type}) if $debug{$type};
    foreach (@required) {
        unless (defined $new->part($_)) {
            return $self->carp_error("Required field $type/$code/$_ not populated");
        }
    }
    return $new;
}

sub segment {
    my $self = shift;
    return $self->_common_constructor('segment', @_);
}

sub message {
    my $self = shift;
    return $self->_common_constructor('message', @_);
}

sub dataelement {
    my $self = shift;
    # Business::EDI::DataElement->require;
    Business::EDI::DataElement->new(@_);
}

sub get_spec {
    my $self = shift;
    @_ or return carp_error("Missing argument to get_spec()");
    return Business::EDI::Spec->new(@_);
}

# Accessor get/set methods
sub spec {        # spec(code)
    my $self = shift;
    if (@_) {                                        #  Arg(s) mean we are constructing
        ref($self) or return $self->get_spec(@_);    #  Business::EDI->spec(...) style, class method: simple constructor
        if (ref($_[0]) eq 'Business::EDI::Spec') {   # TODO: use isa or whatever the hip OO style of role-checking is
            $self->{spec} = shift;                   #  We got passed a full spec object, just set
        } else {
            $self->{spec} = $self->get_spec(@_);     #  otherwise construct and retain
        }
    }
    ref($self) or croak "Cannot use class method Business::EDI->spec as an accessor (spec is uninstantiated).  " .
        "Get a spec'd object first like: Business::EDI->new('d87a')->spec, " .
        "or specify the version you want: Business::EDI->spec('default') or Business::EDI->get_spec('default')";
    return $self->{spec};
}

sub error {
    my ($self, $msg, $quiet) = @_;
    $msg or return $self->{error} || $error;  # just an accessor
    ($debug or ! $quiet) and carp $msg;
    return $self->{error} = $msg;
}

sub carp_error {
    my $obj_or_message = shift;
    my $msg;
    if (@_) {
        $msg = (ref($obj_or_message) || $obj_or_message) . ' - ' . shift;
    } else {
        $msg = $obj_or_message;
    }
    carp $msg;
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

# similar to autoload, but by an exact argument, does get and set
sub part {
    my $self  = shift;
    my $class = ref($self) or croak "part() object method error: $self is not an object";
    my $name  = shift or return;

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
        $debug and print STDERR "subelement building from key '$_'\n";
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
            $new->{$_} = $self->subelement($body->{$_}->[0])                    # ELSE, break the ref down (recursively)
                or carp "Bad ref ($ref) in body for key $_.  Subelement not created";
        } elsif ($ref) {
            $new->{$_} = $self->subelement($body->{$_})                         # ELSE, break the ref down (recursively)
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

