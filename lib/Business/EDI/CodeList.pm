package Business::EDI::CodeList;

use strict;
use warnings;
use Carp;
use UNIVERSAL::require;

=head1 Business::EDI::CodeList

Abstract object class for UN/EDIFACT objects that do not have further descendant objects.

=cut

our $VERSION = 0.01;
our $verbose = 0;

sub new_codelist {      # constructor: NOT to be overridden, first argument is string name like 'ResponseTypeCode'
    my $class = shift;  # note: we don't return objects of this class
    my $type  = shift or carp "No CodeList object type specified";
    $type or return;
    my $realtype = ($type =~ /^Business::EDI::CodeList::./) ? $type : "Business::EDI::CodeList::$type";
    unless ($realtype->require()) {
        carp "require failed! Unrecognized class $realtype: $@";
        return;
    }
    return $realtype->new(@_);
}

# this is the default constructor for subclasses, e.g. Business::EDI::CodeList::InventoryTypeCode->new()
sub new {       # override me if you want,
    my $class = shift;
    my $code  = shift or carp "No code argument for CodeList type '$class' specified";
    $code or return;
    my $self = bless({}, $class);
    unless ($self->init($code, @_)) {
        carp "init() failed for code '$code'";
        return;
    }
    return $self;
}

sub init {
    my $self = shift;
    my $code = shift or return;
    my $codes = $self->get_codes();
    warn "get_codes got " . scalar(keys %$codes) . " codes for $code";
    $codes->{$code} or return;
    $self->{code } = $code;
    $self->{label} = $codes->{$code}->[0];
    $self->{desc}  = $codes->{$code}->[1];
    $self->{value} = shift if @_;
    return $self;
}

# sub get_codes {
#     my $self  = shift;
#     my $class = ref($self) || $self;
#     warn "trying to get_codes for class $class";
#     no strict 'refs';
#     return \%{$class . "::code_hash"};
# }

sub code  { my $self = shift; @_ and $self->{code } = shift; return $self->{code }; }
sub label { my $self = shift; @_ and $self->{label} = shift; return $self->{label}; }
sub desc  { my $self = shift; @_ and $self->{desc } = shift; return $self->{desc }; }
sub value { my $self = shift; @_ and $self->{value} = shift; return $self->{value}; }

1;
