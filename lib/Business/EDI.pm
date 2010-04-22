package Business::EDI;

use strict;
use warnings;
use Carp;
# use Data::Dumper;

our $VERSION = 0.01;

use UNIVERSAL::require;
use Business::EDI::CodeList;
use Business::EDI::DataElement;
our $debug = 0;

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
    ref($body) =~ /^Business::EDI/ and return $body;    # it's already an EDI object, return it

    if (ref($body) eq 'ARRAY') {
        if (scalar(@$body) != 2) {
            carp "Array expected to be psuedohash with 2 elements, instead got " . scalar(@$body);
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
        } elsif ($ref) {
            $new->{$_} = $self->subelement($body->{$_})     # ELSE, break the ref down (recursively)
                or carp "Bad ref ($ref) in body for key $_.  Subelement not created.";
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

