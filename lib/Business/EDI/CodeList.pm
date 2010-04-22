package Business::EDI::CodeList;

use base qw/Business::EDI/;

use strict;
use warnings;
use Carp;
use UNIVERSAL::require;

=head1 Business::EDI::CodeList

Abstract object class for UN/EDIFACT objects that do not have further descendant objects and
do have a defined list of legal values.

=cut

our $VERSION = 0.01;
our $verbose = 0;
our %codemap;

sub new_codelist {      # constructor: NOT to be overridden, first argument is string name like 'ResponseTypeCode'
    my $class = shift;  # note: we don't return objects of this class, we return an object from the subclasses
    my $type  = shift or carp "No CodeList object type specified";
    $type or return;
    if ($type =~ /^\d{4}$/) {
        my $map = $class->codemap();
        if (exists $map->{$type}) {
            $verbose and warn "Numerical CodeList $type => " . $map->{$type};
            $type = $map->{$type}; # replace 4-digit code w/ name, e.g. 1049 => 'MessageSectionCode'
        } else {
            carp "Numerical CodeList '$type' is not recognized.  Maybe you wanted a DataElement?  Constructor failure likely.";
        }
    }
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
    my $code  = shift; # or carp "No code argument for CodeList type '$class' specified";
    # $code or return;
    my $self = bless({}, $class);
    unless ($self->init($code, @_)) {
        carp $class . "->init failed for code '" . (defined($code) ? $code : '') . "'";
        return;
    }
    return $self;
}

sub init {
    my $self  = shift;
    my $value = shift;  # or return;
    defined($value) or $value = '';
    my $codes = $self->get_codes();    # from subobject
    $verbose and warn ref($self) . "->get_codes got " . scalar(keys %$codes) . ", setting value '$value'";
    $self->{value} = $value;
    $self->{listnumber} = shift if @_;
    unless (length($value) and $codes->{$value}) {
        $verbose and carp "Value '$value' is not an authorized value";
        $self->{label} = '';
        $self->{desc}  = '';
        return $self;
    }
    $self->{label} = $codes->{$value}->[0];
    $self->{desc}  = $codes->{$value}->[1];
    return $self;
}

# sub get_codes {
#     my $self  = shift;
#     my $class = ref($self) || $self;
#     warn "trying to get_codes for class $class";
#     no strict 'refs';
#     return \%{$class . "::code_hash"};
# }

sub code       { my $self = shift; return $self->listnumber(@_); }
sub listnumber { my $self = shift; @_ and $self->{listnumber} = shift; return $self->{listnumber}; }
sub label      { my $self = shift; @_ and $self->{label}      = shift; return $self->{label};      }
sub desc       { my $self = shift; @_ and $self->{desc }      = shift; return $self->{desc };      }
sub value      { my $self = shift; @_ and $self->{value}      = shift; return $self->{value};      }

sub name2number {
    my $self = shift;
    my $name = shift or return;
    my $map  = $self->codemap;
    foreach (keys %$map) {
        $map->{$_} eq $name and return $_;
    }
    return; # undef, no match
}

sub codemap {
    my $self = shift;
    %codemap or %codemap = (
        1001 => "DocumentNameCode",
        1049 => "MessageSectionCode",
        1073 => "DocumentLineActionCode",
        1153 => "ReferenceCodeQualifier",
        1159 => "SequenceIdentifierSourceCode",
        1225 => "MessageFunctionCode",
        1227 => "CalculationSequenceCode",
        1229 => "ActionRequest/notificationDescriptionCode",
        1373 => "DocumentStatusCode",
        1501 => "ComputerEnvironmentDetailsCodeQualifier",
        1503 => "DataFormatDescriptionCode",
        1505 => "ValueListTypeCode",
        1507 => "DesignatedClassCode",
        2005 => "DateOrTimeOrPeriodFunctionCodeQualifier",
        2009 => "TermsTimeRelationCode",
        2013 => "FrequencyCode",
        2015 => "DespatchPatternCode",
        2017 => "DespatchPatternTimingCode",
        2023 => "PeriodTypeCodeQualifier",
        2151 => "PeriodTypeCode",
        2155 => "ChargePeriodTypeCode",
        2379 => "DateOrTimeOrPeriodFormatCode",
        2475 => "TimeReferenceCode",
        3035 => "PartyFunctionCodeQualifier",
        3045 => "PartyNameFormatCode",
        3055 => "CodeListResponsibleAgencyCode",
        3077 => "TestMediumCode",
        3079 => "OrganisationClassificationCode",
        3083 => "OrganisationalClassNameCode",
        3131 => "AddressTypeCode",
        3139 => "ContactFunctionCode",
        3153 => "CommunicationMediumTypeCode",
        3155 => "CommunicationAddressCodeQualifier",
        3227 => "LocationFunctionCodeQualifier",
        3237 => "SampleLocationDescriptionCode",
        3279 => "GeographicAreaCode",
        3285 => "InstructionReceivingPartyIdentifier",
        3289 => "PersonCharacteristicCodeQualifier",
        3295 => "NameOriginalAlphabetCode",
        3299 => "AddressPurposeCode",
        3301 => "EnactingPartyIdentifier",
        3397 => "NameStatusCode",
        3401 => "NameComponentUsageCode",
        3403 => "NameTypeCode",
        3405 => "NameComponentTypeCodeQualifier",
        3455 => "LanguageCodeQualifier",
        3457 => "OriginatorTypeCode",
        3475 => "AddressStatusCode",
        3477 => "AddressFormatCode",
        3479 => "MaritalStatusDescriptionCode",
        3493 => "NationalityCodeQualifier",
        4017 => "DeliveryPlanCommitmentLevelCode",
        4025 => "BusinessFunctionCode",
        4027 => "BusinessFunctionTypeCodeQualifier",
        4035 => "PriorityTypeCodeQualifier",
        4037 => "PriorityDescriptionCode",
        4043 => "TradeClassCode",
        4049 => "CertaintyDescriptionCode",
        4051 => "CharacteristicRelevanceCode",
        4053 => "DeliveryOrTransportTermsDescriptionCode",
        4055 => "DeliveryOrTransportTermsFunctionCode",
        4059 => "ClauseCodeQualifier",
        4065 => "ContractAndCarriageConditionCode",
        4071 => "ProvisoCodeQualifier",
        4079 => "HandlingInstructionDescriptionCode",
        4183 => "SpecialConditionCode",
        4215 => "TransportChargesPaymentMethodCode",
        4219 => "TransportServicePriorityCode",
        4221 => "DiscrepancyNatureIdentificationCode",
        4233 => "MarkingInstructionsCode",
        4237 => "PaymentArrangementCode",
        4277 => "PaymentTermsDescriptionIdentifier",
        4279 => "PaymentTermsTypeCodeQualifier",
        4295 => "ChangeReasonDescriptionCode",
        4343 => "ResponseTypeCode",
        4347 => "ProductIdentifierCodeQualifier",
        4383 => "BankOperationCode",
        4401 => "InstructionDescriptionCode",
        4403 => "InstructionTypeCodeQualifier",
        4405 => "StatusDescriptionCode",
        4407 => "SampleProcessStepCode",
        4419 => "TestAdministrationMethodCode",
        4431 => "PaymentGuaranteeMeansCode",
        4435 => "PaymentChannelCode",
        4437 => "AccountTypeCodeQualifier",
        4439 => "PaymentConditionsCode",
        4447 => "FreeTextFormatCode",
        4451 => "TextSubjectCodeQualifier",
        4453 => "FreeTextFunctionCode",
        4455 => "BackOrderArrangementTypeCode",
        4457 => "SubstitutionConditionCode",
        4461 => "PaymentMeansCode",
        4463 => "Intra-companyPaymentIndicatorCode",
        4465 => "AdjustmentReasonDescriptionCode",
        4471 => "SettlementMeansCode",
        4475 => "AccountingEntryTypeNameCode",
        4487 => "FinancialTransactionTypeCode",
        4493 => "DeliveryInstructionCode",
        4499 => "InventoryMovementReasonCode",
        4501 => "InventoryMovementDirectionCode",
        4503 => "InventoryBalanceMethodCode",
        4505 => "CreditCoverRequestTypeCode",
        4507 => "CreditCoverResponseTypeCode",
        4509 => "CreditCoverResponseReasonCode",
        4511 => "RequestedInformationDescriptionCode",
        4513 => "MaintenanceOperationCode",
        4517 => "SealConditionCode",
        5007 => "MonetaryAmountFunctionDescriptionCode",
        5013 => "IndexCodeQualifier",
        5025 => "MonetaryAmountTypeCodeQualifier",
        5027 => "IndexTypeIdentifier",
        5039 => "IndexRepresentationCode",
        5047 => "ContributionCodeQualifier",
        5049 => "ContributionTypeDescriptionCode",
        5125 => "PriceCodeQualifier",
        5153 => "DutyOrTaxOrFeeTypeNameCode",
        5189 => "AllowanceOrChargeIdentificationCode",
        5213 => "Sub-lineItemPriceChangeOperationCode",
        5237 => "ChargeCategoryCode",
        5243 => "RateOrTariffClassDescriptionCode",
        5245 => "PercentageTypeCodeQualifier",
        5249 => "PercentageBasisIdentificationCode",
        5261 => "ChargeUnitCode",
        5267 => "ServiceTypeCode",
        5273 => "DutyOrTaxOrFeeRateBasisCode",
        5283 => "DutyOrTaxOrFeeFunctionCodeQualifier",
        5305 => "DutyOrTaxOrFeeCategoryCode",
        5315 => "RemunerationTypeNameCode",
        5375 => "PriceTypeCode",
        5379 => "ProductGroupTypeCode",
        5387 => "PriceSpecificationCode",
        5393 => "PriceMultiplierTypeCodeQualifier",
        5419 => "RateTypeCodeQualifier",
        5463 => "AllowanceOrChargeCodeQualifier",
        5495 => "Sub-lineIndicatorCode",
        5501 => "RatePlanCode",
        6029 => "GeographicalPositionCodeQualifier",
        6063 => "QuantityTypeCodeQualifier",
        6069 => "ControlTotalTypeCodeQualifier",
        6071 => "FrequencyCodeQualifier",
        6077 => "ResultRepresentationCode",
        6079 => "ResultNormalcyCode",
        6085 => "DosageAdministrationCodeQualifier",
        6087 => "ResultValueTypeCodeQualifier",
        6145 => "DimensionTypeCodeQualifier",
        6155 => "Non-discreteMeasurementNameCode",
        6167 => "RangeTypeCodeQualifier",
        6173 => "SizeTypeCodeQualifier",
        6245 => "TemperatureTypeCodeQualifier",
        6311 => "MeasurementPurposeCodeQualifier",
        6313 => "MeasuredAttributeCode",
        6321 => "MeasurementSignificanceCode",
        6331 => "StatisticTypeCodeQualifier",
        6341 => "ExchangeRateCurrencyMarketIdentifier",
        6343 => "CurrencyTypeCodeQualifier",
        6347 => "CurrencyUsageCodeQualifier",
        6353 => "UnitTypeCodeQualifier",
        6415 => "ClinicalInformationTypeCodeQualifier",
        7001 => "PhysicalOrLogicalStateTypeCodeQualifier",
        7007 => "PhysicalOrLogicalStateDescriptionCode",
        7009 => "ItemDescriptionCode",
        7011 => "ItemAvailabilityCode",
        7039 => "SampleSelectionMethodCode",
        7045 => "SampleStateCode",
        7047 => "SampleDirectionCode",
        7059 => "ClassTypeCode",
        7073 => "PackagingTermsAndConditionsCode",
        7075 => "PackagingLevelCode",
        7077 => "DescriptionFormatCode",
        7081 => "ItemCharacteristicCode",
        7083 => "ConfigurationOperationCode",
        7085 => "CargoTypeClassificationCode",
        7133 => "ProductDetailsTypeCodeQualifier",
        7143 => "ItemTypeIdentificationCode",
        7161 => "SpecialServiceDescriptionCode",
        7171 => "HierarchicalStructureRelationshipCode",
        7173 => "HierarchyObjectCodeQualifier",
        7187 => "ProcessTypeDescriptionCode",
        7233 => "PackagingRelatedDescriptionCode",
        7273 => "ServiceRequirementCode",
        7293 => "SectorAreaIdentificationCodeQualifier",
        7295 => "RequirementOrConditionDescriptionIdentifier",
        7297 => "SetTypeCodeQualifier",
        7299 => "RequirementDesignatorCode",
        7365 => "ProcessingIndicatorDescriptionCode",
        7383 => "SurfaceOrLayerCode",
        7405 => "ObjectIdentificationCodeQualifier",
        7429 => "IndexingStructureCodeQualifier",
        7431 => "AgreementTypeCodeQualifier",
        7433 => "AgreementTypeDescriptionCode",
        7449 => "MembershipTypeCodeQualifier",
        7451 => "MembershipCategoryDescriptionCode",
        7455 => "MembershipLevelCodeQualifier",
        7459 => "AttendeeCategoryDescriptionCode",
        7491 => "InventoryTypeCode",
        7493 => "DamageDetailsCodeQualifier",
        7495 => "ObjectTypeCodeQualifier",
        7497 => "StructureComponentFunctionCodeQualifier",
        7511 => "MarkingTypeCode",
        7515 => "StructureTypeCode",
        8015 => "TrafficRestrictionCode",
        8025 => "ConveyanceCallPurposeDescriptionCode",
        8035 => "TrafficRestrictionTypeCodeQualifier",
        8051 => "TransportStageCodeQualifier",
        8053 => "EquipmentTypeCodeQualifier",
        8077 => "EquipmentSupplierCode",
        8101 => "TransitDirectionIndicatorCode",
        8155 => "EquipmentSizeAndTypeDescriptionCode",
        8169 => "FullOrEmptyIndicatorCode",
        8179 => "TransportMeansDescriptionCode",
        8249 => "EquipmentStatusCode",
        8273 => "DangerousGoodsRegulationsCode",
        8275 => "ContainerOrPackageContentsIndicatorCode",
        8281 => "TransportMeansOwnershipIndicatorCode",
        8323 => "TransportMovementCode",
        8335 => "MovementTypeDescriptionCode",
        8339 => "PackagingDangerLevelCode",
        8341 => "HaulageArrangementsCode",
        8393 => "ReturnablePackageLoadContentsCode",
        8395 => "ReturnablePackageFreightPaymentResponsibilityCode",
        8457 => "ExcessTransportationReasonCode",
        8459 => "ExcessTransportationResponsibilityCode",
        9003 => "EmploymentDetailsCodeQualifier",
        9013 => "StatusReasonDescriptionCode",
        9015 => "StatusCategoryCode",
        9017 => "AttributeFunctionCodeQualifier",
        9023 => "DefinitionFunctionCode",
        9025 => "DefinitionExtentCode",
        9029 => "ValueDefinitionCodeQualifier",
        9031 => "EditMaskRepresentationCode",
        9035 => "QualificationApplicationAreaCode",
        9037 => "QualificationTypeCodeQualifier",
        9039 => "FacilityTypeDescriptionCode",
        9043 => "ReservationIdentifierCodeQualifier",
        9045 => "BasisCodeQualifier",
        9051 => "ApplicabilityCodeQualifier",
        9141 => "RelationshipTypeCodeQualifier",
        9143 => "RelationshipDescriptionCode",
        9153 => "SimpleDataElementCharacterRepresentationCode",
        9155 => "LengthTypeCode",
        9161 => "CodeSetIndicatorCode",
        9169 => "DataRepresentationTypeCode",
        9175 => "DataElementUsageTypeCode",
        9213 => "DutyRegimeTypeCode",
        9285 => "ValidationCriteriaCode",
        9303 => "SealingPartyNameCode",
        9353 => "GovernmentProcedureCode",
        9411 => "GovernmentInvolvementCode",
        9415 => "GovernmentAgencyIdentificationCode",
        9417 => "GovernmentActionCode",
        9421 => "ProcessStageCodeQualifier",
        9437 => "ClinicalInterventionDescriptionCode",
        9441 => "ClinicalInterventionTypeCodeQualifier",
        9443 => "AttendanceTypeCodeQualifier",
        9447 => "DischargeTypeDescriptionCode",
        9453 => "CodeValueSourceCode",
        9501 => "FormulaTypeCodeQualifier",
        9507 => "FormulaSequenceCodeQualifier",
        9509 => "FormulaSequenceOperandCode",
        9601 => "InformationCategoryCode",
        9623 => "DiagnosisTypeCode",
        9625 => "RelatedCauseCode",
        9633 => "InformationDetailsCodeQualifier",
        9635 => "EventDetailsCodeQualifier",
        9641 => "ServiceBasisCodeQualifier",
        9643 => "SupportingEvidenceTypeCodeQualifier",
        9645 => "PayerResponsibilityLevelCode",
        9649 => "ProcessingInformationCodeQualifier",
    );
    return \%codemap;
}

1;
__END__
