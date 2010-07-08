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
my @fields = qw/ code value label desc /;

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
        carp $class . "->init('" . (defined($code) ? $code : '') . "', " . join(", ",@_), ") FAILED\n";
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
    $self->{code } = @_ ? shift : $self->list_number;
    $self->{_permitted} = {(map {$_ => 1} @fields)};
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
sub listnumber { my $self = shift; @_ and $self->{code } = shift; return $self->{code }; }
sub label      { my $self = shift; @_ and $self->{label} = shift; return $self->{label}; }
sub desc       { my $self = shift; @_ and $self->{desc } = shift; return $self->{desc }; }
sub value      { my $self = shift; @_ and $self->{value} = shift; return $self->{value}; }

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
# These (0xxx) are from SYNTAX spec
        '0001' => q(Syntax identifier),
        '0002' => q(Syntax version number),
        '0004' => q(Interchange sender identification),
        '0007' => q(Identification code qualifier),
        '0008' => q(Interchange sender internal identification),
        '0010' => q(Interchange recipient identification),
        '0014' => q(Interchange recipient internal identification),
        '0017' => q(Date),
        '0019' => q(Time),
        '0020' => q(Interchange control reference),
        '0022' => q(Recipient reference/password),
        '0025' => q(Recipient reference/password qualifier),
        '0026' => q(Application reference),
        '0029' => q(Processing priority code),
        '0031' => q(Acknowledgement request),
        '0032' => q(Interchange agreement identifier),
        '0035' => q(Test indicator),
        '0036' => q(Interchange control count),
        '0038' => q(Message group identification),
        '0040' => q(Application sender identification),
        '0042' => q(Interchange sender internal sub-identification),
        '0044' => q(Application recipient identification),
        '0046' => q(Interchange recipient internal sub-identification),
        '0048' => q(Group reference number),
        '0051' => q(Controlling agency, coded),
        '0052' => q(Message version number),
        '0054' => q(Message release number),
        '0057' => q(Association assigned code),
        '0058' => q(Application password),
        '0060' => q(Group control count),
        '0062' => q(Message reference number),
        '0065' => q(Message type),
        '0068' => q(Common access reference),
        '0070' => q(Sequence of transfers),
        '0073' => q(First and last transfer),
        '0074' => q(Number of segments in a message),
        '0076' => q(Syntax release number),
        '0080' => q(Service code list directory version number),
        '0081' => q(Section identification),
        '0083' => q(Action, coded),
        '0085' => q(Syntax error, coded),
        '0087' => q(Anti-collision segment group identification),
        '0096' => q(Segment position in message body),
        '0098' => q(Erroneous data element position in segment),
        '0104' => q(Erroneous component data element position),
        '0110' => q(Code list directory version number),
        '0113' => q(Message type sub-function identification),
        '0115' => q(Message subset identification),
        '0116' => q(Message subset version number),
        '0118' => q(Message subset release number),
        '0121' => q(Message implementation guideline identification),
        '0122' => q(Message implementation guideline version number),
        '0124' => q(Message implementation guideline release number),
        '0127' => q(Scenario identification),
        '0128' => q(Scenario version number),
        '0130' => q(Scenario release number),
        '0133' => q(Character encoding, coded),
        '0135' => q(Service segment tag, coded),
        '0136' => q(Erroneous data element occurrence),
        '0138' => q(Security segment position),
        '0300' => q(Initiator control reference),
        '0303' => q(Initiator reference identification),
        '0304' => q(Responder control reference),
        '0306' => q(Transaction control reference),
        '0311' => q(Dialogue identification),
        '0314' => q(Event time),
        '0320' => q(Sender sequence number),
        '0323' => q(Transfer position, coded),
        '0325' => q(Duplicate Indicator),
        '0331' => q(Report function, coded),
        '0332' => q(Status),
        '0333' => q(Status, coded),
        '0335' => q(Language, coded),
        '0336' => q(Time offset),
        '0338' => q(Event date),
        '0340' => q(Interactive message reference number),
        '0342' => q(Dialogue version number),
        '0344' => q(Dialogue release number),
        '0501' => q(Security service, coded),
        '0503' => q(Response type, coded),
        '0505' => q(Filter function, coded),
        '0507' => q(Original character set encoding, coded),
        '0509' => q(Role of security provider, coded),
        '0511' => q(Security party identification),
        '0513' => q(Security party code list qualifier),
        '0515' => q(Security party code list responsible agency, coded),
        '0517' => q(Date and time qualifier),
        '0518' => q(Encryption reference number),
        '0520' => q(Security sequence number),
        '0523' => q(Use of algorithm, coded),
        '0525' => q(Cryptographic mode of operation, coded),
        '0527' => q(Algorithm, coded),
        '0529' => q(Algorithm code list identifier),
        '0531' => q(Algorithm parameter qualifier),
        '0533' => q(Mode of operation code list identifier),
        '0534' => q(Security reference number),
        '0536' => q(Certificate reference),
        '0538' => q(Key name),
        '0541' => q(Scope of security application, coded),
        '0543' => q(Certificate original character set repertoire, coded),
        '0545' => q(Certificate syntax and version, coded),
        '0546' => q(User authorisation level),
        '0548' => q(Service character for signature),
        '0551' => q(Service character for signature qualifier),
        '0554' => q(Algorithm parameter value),
        '0556' => q(Length of data in octets of bits),
        '0558' => q(List parameter),
        '0560' => q(Validation value),
        '0563' => q(Validation value qualifier),
        '0565' => q(Message relation, coded),
        '0567' => q(Security status, coded),
        '0569' => q(Revocation reason, coded),
        '0571' => q(Security error, coded),
        '0572' => q(Certificate sequence number),
        '0575' => q(List parameter qualifier),
        '0577' => q(Security party qualifier),
        '0579' => q(Key management function qualifier),
        '0582' => q(Number of padding bytes),
        '0586' => q(Security party name),
        '0588' => q(Number of security segments),
        '0591' => q(Padding mechanism, coded),
        '0601' => q(Padding mechanism code list identifier),
        '0800' => q(Package reference number),
        '0802' => q(Reference identification number),
        '0805' => q(Object type qualifier),
        '0808' => q(Object type attribute),
        '0809' => q(Object type attribute identification),
        '0810' => q(Length of object in octets of bits),
        '0813' => q(Reference qualifier),
        '0814' => q(Number of segments before object),

# The rest are from regular EDI spec
        1001 => "DocumentNameCode",
        1049 => "MessageSectionCode",
        1073 => "DocumentLineActionCode",
        1153 => "ReferenceCodeQualifier",
        1159 => "SequenceIdentifierSourceCode",
        1225 => "MessageFunctionCode",
        1227 => "CalculationSequenceCode",
        1229 => "ActionRequestNotificationDescriptionCode",
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
