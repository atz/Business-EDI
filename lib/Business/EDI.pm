package Business::EDI;

use strict;
use warnings;
use Carp;
# use Data::Dumper;

our $VERSION = 0.02;

use UNIVERSAL::require;
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

    unless (exists $self->{_permitted}->{$name}) {
        croak "AUTOLOAD error: Cannot access '$name' field of class '$class'"; 
    }

    if (@_) {
        return $self->{$name} = shift;
    } else {
        return $self->{$name};
    }
}

sub new {
    my($class, %args) = @_;
    my $self = bless(\%args, $class);
    # $self->{args} = {};
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


sub error {
    my ($self, $msg, $quiet) = @_;
    $msg or return $self->{error};  # just an accessor
    ($debug or ! $quiet) and carp $msg;
    return $self->{error} = $msg;
}

sub carp_error {
    carp shift;
    return;     # undef: important!
}

=head2 ->unblessed($body, \@coderef)

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

