package Business::EDI::CodeList::LocationFunctionCodeQualifier;

use base 'Business::EDI::CodeList';
my $VERSION     = 0.01;
my $list_number = 3227;
my $usage       = 'C';

# *    3227  Location function code qualifier                        [C]
# Desc: Code identifying the function of a location.
# Repr: an..3

my %code_hash = (
'1' => [ 'Place of terms of delivery',
    '(3018) Point or port of departure, shipment or destination, as required under the applicable terms of delivery, e.g. Incoterms.' ],
'2' => [ 'Payment location',
    '[3109] To identify the place where the payment has been or should be made.' ],
'3' => [ 'Tare check place',
    'Place where equipment tare has been or must be checked for official assessment.' ],
'4' => [ 'Goods receipt place',
    'Place at which the goods have been received.' ],
'5' => [ 'Place of departure',
    '(3214) Port, airport or other location from which a means of transport or transport equipment is scheduled to depart or has departed.' ],
'6' => [ 'Ward bed',
    'A bed in a ward.' ],
'7' => [ 'Place of delivery',
    '(3246) Place to which the goods are to be finally delivered under transport contract terms (operational term).' ],
'8' => [ 'Place of destination',
    'Port, airport or other location to which a means of transport or transport equipment is destined.' ],
'9' => [ 'Place of loading',
    '[3334] Seaport, airport, freight terminal, rail station or other place at which the goods (cargo) are loaded on to the means of transport being used for their carriage.' ],
'10' => [ 'Place of acceptance',
    '[3348] Place where the goods are taken over by the carrier.' ],
'11' => [ 'Place of discharge',
    '[3392] Seaport, airport, freight terminal, rail station or other place at which goods are unloaded from the means of transport having been used for their carriage.' ],
'12' => [ 'Port of discharge',
    'Port at which the goods are discharged from the vessel used for their transport.' ],
'13' => [ 'Place of transhipment',
    '[3424] Place where goods are to be or have been transferred from one means of transport to another during the course of one transport operation.' ],
'14' => [ 'Goods item storage location',
    '[3385] To identify the place where a goods item is located.' ],
'15' => [ 'Place of transfer responsibility',
    'Place where the responsibility is transferred.' ],
'16' => [ 'Place of transfer of ownership',
    'Place where the ownership of the goods is transferred.' ],
'17' => [ 'Border crossing place',
    'Place where goods are transported across a country border.' ],
'18' => [ 'Warehouse',
    '[3156] Warehouse where a particular consignment is to be or has been stored.' ],
'19' => [ 'Factory/plant',
    'Factory/plant relevant for a particular consignment.' ],
'20' => [ 'Place of ultimate destination of goods',
    'Place where goods will ultimately be delivered.' ],
'21' => [ 'Terms of sale place',
    'Place of departure, shipment or destination as specified in the terms of sale agreed between the parties.' ],
'22' => [ 'Customs clearance location',
    '[3080] Place at which Customs clearance should or has taken place.' ],
'23' => [ 'Port of release',
    'Port where goods are released from Customs custody.' ],
'24' => [ 'Port of entry',
    'Port where final documentation is filed for Customs Entry processing.' ],
'25' => [ 'Country',
    'Country relevant for a particular transaction.' ],
'26' => [ 'City',
    'City or town relevant for a particular transaction or consignment.' ],
'27' => [ 'Country of origin',
    '[3239] To identify the country in which the goods have been produced or manufactured, according to criteria laid down for the application of the Customs tariff or quantitative restrictions, or any measure related to trade.' ],
'28' => [ 'Country of destination of goods',
    'Country to which the goods are to be delivered.' ],
'29' => [ 'Railway station',
    'Name or identification of a railway station/yard relevant to a particular consignment.' ],
'30' => [ 'Country of source',
    'Country in which raw material or components were originally produced prior to manufacture or assembly in another country.' ],
'31' => [ 'Building',
    'A building or part thereof relevant to a particular consignment or transaction.' ],
'32' => [ 'Beginning of chargeable section',
    'First rail station in a predefined section of the chargeable voyage. A complete voyage may be divided in sections, even within one country, that are separately chargeable using different tariff rules (split tariffs).' ],
'33' => [ 'Baseport of discharge',
    '[3356] Place at which the cargo is discharged or unloaded from a means of transport according to the transport contract. The goods may or may not be discharged from the main means of transport at this place or port.' ],
'34' => [ 'Baseport of loading',
    '[3322] Place at which the cargo is loaded on a means of transport according to the transport contract. The goods may or may not be loaded on the main means of transport at this place or port.' ],
'35' => [ 'Exportation country',
    '[3220] Country from which the goods were initially exported to the importing country without any commercial transaction taking place in intermediate countries. Synonym: Country whence consigned. Country of despatch: Country from which goods are despatched between countries of a Customs union.' ],
'36' => [ 'Country of ultimate destination',
    '(3216) Country known to the consignor or his agent at the time of despatch to be the final country to which the goods are to be delivered.' ],
'37' => [ 'Consignment final exportation country',
    '[3331] To identify the country from which goods have been or will be consigned prior to final importation.' ],
'38' => [ 'Consignment first destination country',
    '[3219] To identify the country where a consignment is off-loaded from the means of transport used for the original exportation.' ],
'39' => [ 'Country of production',
    'Country where item has been or will be produced.' ],
'40' => [ 'Country of trading',
    'Country where item has been or will be traded.' ],
'41' => [ 'Consignment entry customs office location',
    '[3089] To identify the customs office at which the goods enter the customs territory of destination.' ],
'42' => [ 'Consignment exit customs office location',
    '[3097] To identify the customs office at which the goods leave or are intended to leave the customs territory of despatch.' ],
'43' => [ 'Place of Customs examination',
    "Place where Customs undertakes a physical inspection of goods to satisfy themselves that the goods' nature, origin, condition, quantity and value are in accordance with the particulars furnished on the goods declaration (CCC)." ],
'44' => [ 'Place of authentication of document',
    '(3410) Place where document is signed or otherwise authenticated. Synonym: Place of issue of document.' ],
'45' => [ 'Customs office of destination (transit)',
    '(3086) Customs office at which a transit operation is terminated. Synonym: Customs office of transit termination.' ],
'46' => [ 'Region of despatch',
    'Region from which goods are despatched between countries of a Customs union.' ],
'47' => [ 'Region of destination',
    'Region known to the consignor or his agent at the time of despatch to be the final region to which the goods are to be delivered.' ],
'48' => [ 'Region of production',
    'Region where item has been or will be produced.' ],
'49' => [ 'Transit country',
    '[3263] Country through which a goods or passengers are routed between the country of original departure and final destination.' ],
'50' => [ 'Transit customs office location',
    '[3107] To identify the customs office which is responsible for transit formalities en-route.' ],
'51' => [ 'Country of invalid transit guarantee',
    'Country in which the security or guarantee for the movement of goods under a transit procedure is not valid.' ],
'52' => [ 'Country of destination (transit)',
    'Country at which a Customs transit operation is terminated. Synonym: Country of transit termination.' ],
'53' => [ 'Charge and freight due from',
    'Place or point from which charges and freight are charged.' ],
'54' => [ 'Manufacturing department',
    'A department within the manufacturing area (e.g. lacquering, assembly).' ],
'55' => [ 'Freight charge payable to location',
    '[3102] Name of a place to which a transport charges tariff applies or where freight and other related charges are to be or have been incurred.' ],
'56' => [ 'End of chargeable section',
    'Last rail station in a predefined section of the chargeable voyage. A complete voyage may be divided in sections, even within one country, that are separately chargeable using different tariff rules (split tariffs).' ],
'57' => [ 'Place of payment',
    'Name of the location at which freight and charges for main transport are payable.' ],
'58' => [ 'Full track loading or unloading',
    'Identification of the station proceeding to the loading or unloading of a rail wagon on a full track site. (Used only when a rail station is obliged to transfer the load on another wagon for technical reasons - e.g. damage).' ],
'59' => [ 'Place of loss',
    'To identify the location where the loss occurred.' ],
'60' => [ 'Place of arrival',
    'Place at which the transport means arrives.' ],
'61' => [ 'Next port of call',
    'Next port which the vessel is going to call upon.' ],
'62' => [ 'On-carriage port',
    'Port of discharge at which the cargo is discharged from the vessel, used for transport after the main transport (transit port).' ],
'63' => [ 'Sub-project location',
    'A place at which works occur referring to a sub-project.' ],
'64' => [ 'First optional place of discharge',
    'The first optional place or port of discharge as mentioned on the transport document where cargo can be discharged at the option of the shipper.' ],
'65' => [ 'Final port or place of discharge',
    'Name of the seaport, airport, freight terminal, rail station or other place at which the goods (cargo) are finally (to be) unloaded from the means of transport used for their carriage according to the transport contract.' ],
'66' => [ 'Express railway station',
    'Railway station offering express transportation services.' ],
'67' => [ 'Mixed cargo railway station',
    'Railway station offering mixed cargo transportation services .' ],
'68' => [ 'Second optional place of discharge',
    'The second optional place or port of discharge as mentioned on the transport document where cargo can be discharged at the option of shipper.' ],
'69' => [ 'Next non-discharge port of call',
    'A code to identify the next port of call for a vessel where no cargo will be discharged.' ],
'70' => [ 'Third optional place of discharge',
    'The third optional place or port of discharge as mentioned on the transport document where cargo can be discharged at the option of the shipper.' ],
'71' => [ 'Reconsolidation point',
    'A place where cargo is reconsolidated.' ],
'72' => [ 'Fourth optional place of discharge',
    'The fourth optional place or port of discharge as mentioned on the transport document where cargo can be discharged at the option of the shipper.' ],
'73' => [ 'Bill of lading release office',
    'A location where bills of lading are released to customers.' ],
'74' => [ 'Transhipment excluding this place',
    'Place/location where a transhipment from a means of transport to another means of transport is not authorised.' ],
'75' => [ 'Transhipment limited to this place',
    'Only place/location where a transhipment from a means of transport to another means of transport is authorised.' ],
'76' => [ 'Original port of loading',
    'The port where the goods were first loaded on a vessel.' ],
'77' => [ 'First port of call - non-discharging',
    "Port in the country of destination where the conveyance initially arrives from the 'last place/port of call of conveyance' and where a conveyance will not be discharging cargoes." ],
'78' => [ 'First port of call - discharging',
    "Port in the country of destination where the conveyance initially arrives from the 'last place/port of call of conveyance' and where a conveyance will be discharging cargoes." ],
'79' => [ 'Place/port of first entry',
    'Place or port where final documentation is filed for Customs entry processing.' ],
'80' => [ 'Place of despatch',
    'Place at which the goods are taken over for carriage (operational term), if different from the transport contract place of acceptance (see: 10). Synonym: Place of origin of carriage.' ],
'81' => [ 'Fifth optional place of discharge',
    'The fifth optional place or port of discharge as mentioned on the transport document where cargo can be discharged at the option of the shipper.' ],
'82' => [ 'Pre-carriage port',
    'Port of loading at which the cargo is loaded on the pre- carriage vessel used for the transport prior to the main transport.' ],
'83' => [ 'Place of delivery (by on carriage)',
    'Place to which the goods are to be finally delivered.' ],
'84' => [ 'Transport contract place of acceptance',
    'Place at which the goods are taken over by the carrier according to the contract of carriage.' ],
'85' => [ 'Transport contract place of destination',
    'Place to which the goods are destined.' ],
'86' => [ 'Country of valid transit guarantee',
    'Country in which the security or guarantee for the movement of goods under a transit procedure is valid.' ],
'87' => [ 'Place/port of conveyance initial arrival',
    'Place/port in the country of destination where the conveyance initially arrives from the "Last place/port of call of conveyance" (125).' ],
'88' => [ 'Place of receipt',
    'Identification of the location at which the cargo is actually received.' ],
'89' => [ 'Place of registration',
    'Place where the registration occurs.' ],
'90' => [ 'Special treatment place',
    'Place where one or more special treatments have happened or must happen.' ],
'91' => [ 'Place of document issue',
    'The place or location where a document is issued.' ],
'92' => [ 'Routing',
    'Indication of a routing place.' ],
'93' => [ 'Station of application of additional costs',
    'Rail station where, according to the transport contract, some chargeable operations must happen (re-weighting, re-fixing of the load, control on equipment and on consignment, etc.).' ],
'94' => [ 'Previous port of call',
    'Previous port which the vessel has called upon.' ],
'95' => [ 'Sailing destination area',
    "Geographical area to which the vessel's trip is destined." ],
'96' => [ 'Place of lodgement of documents',
    'Customs station where, required documents for Customs declarations, have been lodged.' ],
'97' => [ 'Optional place of discharge',
    'The optional place or port of discharge as mentioned on the bill of lading where cargo is discharged at the option of the shipper.' ],
'98' => [ 'Place of empty equipment despatch',
    'The location from which empty equipment is despatched.' ],
'99' => [ 'Place of empty equipment return',
    'The location to which empty equipment is returned.' ],
'100' => [ 'Place/port of warehouse entry',
    'Location (e.g. district) within a Customs territory where a warehouse entry was filed to enter merchandise into a Customs bonded warehouse.' ],
'101' => [ 'Country of first sale',
    'Name of country where firstly a sale took place.' ],
'103' => [ 'Place of transfer',
    'Place at which goods are transferred from one carrier to another (contractual term).' ],
'104' => [ 'Place of deconsolidation',
    'Place where a large consignment is de-grouped into smaller consignments.' ],
'105' => [ 'Place of consumption',
    'Place/location where goods enter the marketplace (commerce) of the importing country.' ],
'106' => [ 'Region of origin',
    'Region in which the goods have been produced or manufactured according to the criteria laid down for the purposes of the application of the Customs tariff, of quantitative restrictions or of any other measures related to trade (see: 3238).' ],
'107' => [ 'Place of consolidation',
    'Place where smaller consignments of goods are grouped together into a large consignment to be transported as a larger unit.' ],
'108' => [ 'Rate combination point',
    'Point over which sector rates are combined.' ],
'109' => [ 'Place of prolongation decision of delivery delay',
    'Place where it has been decided to prolong the delivery delay.' ],
'110' => [ 'Recharging place/location',
    'Place/location where a consignment has been changed of destination and is subject to a recharge note. (Complementary orders to modify the routing of the transport may be given, upon which a new charge calculation may be applied by the carrier).' ],
'111' => [ 'Customs office of despatch',
    'Customs office from which goods are despatched between countries of a Customs union.' ],
'112' => [ 'Region of equipment availability',
    'Region in which a piece of equipment is requested to be made available for on-hire.' ],
'113' => [ 'Country of despatch',
    'Country from which goods are despatched within a Customs union.' ],
'114' => [ 'Customs office of export',
    'Customs office from which goods are taken out of the Customs territory (CCC).' ],
'115' => [ 'Free zone of export',
    'Foreign free zone (desc: see 1131 = 131) from which goods are exported to the country of importation.' ],
'116' => [ 'Region of export/despatch',
    'Region from which the goods were initially exported to the importing country without any commercial transaction taking place in intermediate countries. Region of despatch: region from which goods are despatched between countries of a Customs union.' ],
'117' => [ 'Place of collection',
    'Place where goods are to be or could be picked up (collected).' ],
'118' => [ 'Customs office of departure',
    'Customs office at which a Customs transit operation commences (CCC).' ],
'119' => [ 'Transit guarantee customs office location',
    '[3111] To identify the Customs office at which a security or guarantee for the movement of goods under a transit procedure is lodged.' ],
'120' => [ 'Country of transhipment',
    'Country where goods are transferred under Customs control from the importing means of transport to the exporting means of transport within the area of one Customs office which is the office of both importation and exportation (CCC).' ],
'122' => [ 'Customs office of destination',
    'Customs office where the goods are to be cleared (CCC).' ],
'123' => [ 'Wagon-load railway station',
    'A railway station where rail wagons are loaded.' ],
'124' => [ 'Siding',
    'A short railway track for loading or unloading rail wagons, or bypassing of trains, connected with a main track by switch.' ],
'125' => [ 'Last place/port of call of conveyance',
    'Conveyance departed from this last foreign place/port of call to go to "Place/port of conveyance initial arrival" (87).' ],
'126' => [ 'Country of previous Customs procedure',
    'Country in which the Customs declaration for the previous Customs procedure has been lodged.' ],
'127' => [ 'Customs office of registration of previous Customs',
    'declaration Customs office where the previous Customs declaration has been lodged.' ],
'128' => [ 'Participant sender location',
    'Place where a participant in the movement of goods is located and can be contacted.' ],
'129' => [ 'Wage negotiation district',
    'The district to which workers belong for the purposes of union wage negotiation.' ],
'130' => [ 'Place of ultimate destination of conveyance',
    'Seaport, airport, freight terminal, rail station or other place to which a means of transport is ultimately destined.' ],
'131' => [ 'Place of loading of empty equipment',
    'Seaport, airport, freight terminal, rail station or other place where empty equipment (e.g. containers) was loaded onto means of transport.' ],
'132' => [ 'Place of discharge of empty equipment',
    'Seaport, airport, freight terminal, rail station or other place where empty equipment (e.g. containers) was unloaded from means of transport.' ],
'133' => [ 'Region of delivery',
    '(3246) Region to which the goods are to be finally delivered under transport contract terms (operational term).' ],
'134' => [ 'Petroleum warehouse',
    'Bonded petroleum warehouse or the supplier source.' ],
'135' => [ 'Place of entry (Customs)',
    'Place at which the goods enter the Customs territory.' ],
'136' => [ 'Living animals care place',
    'Place where living animal cares are provided.' ],
'137' => [ 'Re-icing place',
    'Place where re-icing must be executed.' ],
'138' => [ 'Weighting place',
    'Place where weight can be ascertained.' ],
'139' => [ 'Marshalling yard',
    'Station where the wagons are disconnected and reconnected to form a new train.' ],
'140' => [ 'Stopping station',
    'Station where the train must stop or is stopped for unexpected handling.' ],
'141' => [ 'Loading dock',
    'Platform specially equipped for loading and unloading of rail wagons.' ],
'142' => [ 'Port connection',
    'Track connecting a rail station to a dock.' ],
'143' => [ 'Place of expiry',
    'Place where the documentary credit expires for presentation of required documents.' ],
'144' => [ 'Place of negotiation',
    'Place where the documentary credit is to be presented for negotiation.' ],
'145' => [ 'Claims payable place',
    'Place where insurance claims are payable.' ],
'146' => [ 'Documentary credit available in',
    'Place where the documentary credit is available with any bank.' ],
'147' => [ 'Transport means stowage location',
    '[8043] To identify a location on board a means of transport where specified goods or transport equipment has been or are to be stowed.' ],
'148' => [ 'For transportation to',
    'Place/country where goods are to be transported to.' ],
'149' => [ 'Loading on board/despatch/taking in charge at/from',
    'Place/country where goods have to be loaded on board, despatched or taken in charge.' ],
'150' => [ 'Container stack position',
    'Stack position of a container at a terminal, depot or freight station.' ],
'151' => [ 'Private box',
    'A private box used for pick-up and delivery of packages, e.g. of express packages.' ],
'152' => [ 'Next port of discharge',
    'Next port at which goods are discharged from the vessel used for their transport.' ],
'153' => [ 'Port of call',
    'Port where a vessel has called upon or will call upon.' ],
'154' => [ 'Place/location of on-hire',
    'Place/location where an object is contracted for use.' ],
'155' => [ 'Place/location of off-hire',
    "Place/location where an object's contract for use ends." ],
'156' => [ 'Other carriers terminal',
    'A carrier terminal belonging to a carrier other than the original carrier.' ],
'157' => [ 'Country of Value Added Tax (VAT) jurisdiction',
    'The country governing the VAT regulation to which the transaction is subject.' ],
'158' => [ 'Contact location',
    'The site where a contact is located.' ],
'159' => [ 'Additional internal destination',
    "Any location within the consignee's premises where the goods are moved to." ],
'160' => [ 'Foreign port of call',
    'A code to identify the foreign port where the vessel calls at or will call at.' ],
'161' => [ 'Maintenance location',
    'A location where maintenance has been or will be performed.' ],
'162' => [ 'Place or location of sale',
    'Place or location at which the sale takes place.' ],
'163' => [ 'Direct investment country',
    'Country in which a direct investment is made or withdrawn.' ],
'164' => [ 'Berth',
    'Location in port where the vessel is berthed or moored.' ],
'165' => [ 'Construction country',
    'Country in which the construction work is made.' ],
'166' => [ 'Donation acting country',
    'Country acting in the donation of aid.' ],
'167' => [ 'Payment transaction country',
    'Country of the foreign counterpart of the payment transaction.' ],
'168' => [ 'Physical place of return of item',
    'Physical place at which the item is returned, i.e. the location where the supplier receives the item form the customer.' ],
'169' => [ 'Relay port',
    'A location where cargo is transferred from one means of transport to another means of transport owned or operated by the same carrier under the same bill of lading.' ],
'170' => [ 'Final port of discharge',
    'Last port at which cargo is unloaded from a vessel before the cargo is moved to a place of delivery or destination.' ],
'171' => [ 'Place of destination for pre-stacking prior to stowage',
    'The destination location for which items are to be pre- stacked prior to being stowed together on a means of transport.' ],
'172' => [ 'Reporting location',
    'The location to which the information being reported is applicable.' ],
'173' => [ 'Transport contract place of despatch',
    'A place from which goods are despatched as per transport contract.' ],
'174' => [ 'Place of residence',
    'A place where a party lives.' ],
'175' => [ 'Activity location',
    'A place at which the activity occurs.' ],
'176' => [ 'Pick-up location',
    'Location for pick up.' ],
'177' => [ 'Construction site',
    'A place at which construction works occur.' ],
'178' => [ 'Place of embarkation',
    'Place where the object is put, or goes, on board the conveyance.' ],
'179' => [ 'Place of disembarkation',
    'Place where the object or person disembarks from the conveyance.' ],
'180' => [ 'Person birth location',
    '[3486] Name of the place where a person was born.' ],
'181' => [ 'Registered office',
    'Identifies the place or location of a registered office.' ],
'182' => [ 'Place of incorporation',
    'Identifies the location of incorporation.' ],
'183' => [ 'Place of business',
    'Identifies the place or location of a business.' ],
'184' => [ 'Physical location',
    'Identifies the physical location.' ],
'185' => [ 'Location to send mail',
    'Identifies the location to which mail is sent.' ],
'186' => [ 'Foreign registration location',
    'Identifies the place or location of foreign registration.' ],
'187' => [ 'Tax filed from location',
    'Identifies the location from which taxes are filed.' ],
'188' => [ 'Filing location',
    'Identifies the location of the filing entity.' ],
'189' => [ 'Former location',
    'Identifies an earlier or previous place or location.' ],
'190' => [ 'Head office',
    'Identifies the place or location of a head office.' ],
'191' => [ 'Property',
    'Identifies the place or location of property.' ],
'192' => [ 'Correct location',
    'Identifies the correct place or location.' ],
'193' => [ 'Branch location',
    'Identifies the place or location of a branch.' ],
'194' => [ 'Former registered location',
    'Identifies the former registered location of an entity.' ],
'195' => [ 'Future location',
    'Location to be used in the future.' ],
'196' => [ 'Changed to location',
    'Identifies the change to location.' ],
'197' => [ 'Place of inquiry',
    'Place to which an inquiry is made.' ],
'198' => [ 'Original location',
    'Identifies the original location.' ],
'199' => [ 'Country of last source',
    'The country where a product or service was last sourced.' ],
'200' => [ 'Place of handling',
    'Place where a handling operation is to be, or has been, performed.' ],
'201' => [ 'Country of origin as defined by transportation agency',
    'Country of origin as defined by the transportation agency.' ],
'202' => [ 'Terminal',
    'A terminus for transport vehicles.' ],
'203' => [ 'Sample location',
    'Code identifying the location from which a sample is taken.' ],
'204' => [ 'Hospital Advanced Dependency Unit (ADU)',
    'A designated unit in a hospital for advanced dependency nursing care.' ],
'205' => [ 'Hospital Neonatal Intensive Care Unit (NICU)',
    'A designated unit in a hospital for the provision of intensive care to neonates.' ],
'206' => [ 'Hospital Paediatric Care Unit (PCU)',
    'A designated unit in a hospital for the provision of care to paediatric patients.' ],
'207' => [ 'Hospital Intensive Care Unit (ICU)',
    'An intensive care unit in a hospital.' ],
'208' => [ 'Hospital luxury room',
    'A room in a hospital for patient accommodation of superior standard.' ],
'209' => [ 'Hospital shared room',
    'A room in a hospital for shared accommodation of patients.' ],
'210' => [ 'Hospital private room',
    'A room in a hospital for private accommodation of a patient.' ],
'211' => [ 'Bidding area',
    'An area for which bids can be made with the same price applicable to the whole area.' ],
'212' => [ 'Price area',
    'An area for which the same price is applicable to the whole area.' ],
'213' => [ 'Country of destination of equipment',
    'Country of the last place where the equipment will stop.' ],
'214' => [ 'Aircraft airport stand',
    'Code used to specify the airport stand allocated to the aircraft.' ],
'215' => [ 'Airport passenger terminal',
    'Code used to specify the airport terminal used for the embarking or disembarking of passengers.' ],
'216' => [ 'Previous berth',
    'Place or location in a port where a vessel was previously moored.' ],
'217' => [ 'Next berth',
    'Place or location in a port where a vessel will be moored, after moving from the current location.' ],
'218' => [ 'Entity location',
    'Identifies the place or location of the entity.' ],
'219' => [ 'Goods depot',
    'Depot where goods are received and are available for pick-up.' ],
'220' => [ 'Disinfecting place',
    'Place where disinfection has been or must be performed.' ],
'221' => [ 'Harbour rail station',
    'Rail station servicing a harbour.' ],
'222' => [ 'Place of live animal care',
    'Place where live animal care has been or must be provided.' ],
'223' => [ 'Phytosanitary control place',
    'Place where phytosanitary control has been or must be performed.' ],
'224' => [ 'Place for re-icing or de-icing',
    'Place where re-icing or de-icing has been or must be performed.' ],
'225' => [ 'Place of refuelling',
    'Place where refuelling has been or must be performed.' ],
'226' => [ 'Place of provision of an unexpected service',
    'Place where an unexpected service has been or must be provided.' ],
'227' => [ 'Private container terminal',
    'Container terminal managed or owned by a private company.' ],
'228' => [ 'Railway container terminal',
    'Container terminal managed or owned by a railway company.' ],
'229' => [ 'Inspection site',
    'The site where an inspection takes or took place.' ],
'230' => [ 'Request only stop',
    'A location where a stop is only made on request.' ],
'231' => [ 'Grid area',
    'A section of a grid.' ],
'232' => [ 'Source power area',
    'The area that is the source of power.' ],
'233' => [ 'Sink power area',
    'The area that is the destination of power.' ],
'234' => [ 'Scheduled berth',
    'Place or location in a port where a vessel is scheduled to be moored.' ],
'235' => [ 'Scheduled berth, bow',
    'Place or location in a port where the bow of a vessel is scheduled to berth.' ],
'236' => [ 'Scheduled berth, stern',
    'Place or location in a port where the stern of a vessel is scheduled to berth.' ],
'237' => [ 'Balance settlement area',
    'An area where common rules for balance settlement applies.' ],
'238' => [ 'Market area',
    'An  area with common trading rules.' ],
'239' => [ 'Metering grid area',
    'A physical area where consumption, production and exchange can be metered.' ],
'240' => [ 'Climate zone',
    'A geographical area where the climate has common characteristics.' ],
'241' => [ 'Country of birth',
    'Country where a person or an animal was born.' ],
'242' => [ 'Country of fattening',
    'Country where an animal has been fattened.' ],
'243' => [ 'Country of slaughter',
    'Country where an animal has been slaughtered.' ],
'244' => [ 'Country of meat cutting',
    'Country where the meat is cut into pieces.' ],
'245' => [ 'Meat cutting location',
    'A location where the meat is cut into pieces.' ],
'246' => [ 'Slaughterhouse',
    'Place for the slaughter of animals as food.' ],
'247' => [ 'Country of meat mincing',
    'Country where meat has been cut into very small pieces using a meat grinder.' ],
'248' => [ 'Place of discharge and loading',
    'Place at which a means of transport is performing both discharge and loading operations, e.g. seaport, airport, freight terminal, rail station.' ],
'249' => [ 'Cargo facility location',
    'Name of the terminal, warehouse or yard where the goods are to be on or offloaded.' ],
'250' => [ 'Tourist point of interest',
    'Code to specify that the location is a tourist point of interest.' ],
'251' => [ 'Customs office of payment',
    'Place where Customs duties/taxes/fees have to be paid.' ],
'252' => [ 'Conveyance facility location at departure',
    'Name of the location of the last facility (e.g. terminal, warehouse or yard) from which the conveyance will depart.' ],
'253' => [ 'Conveyance facility location at arrival',
    'Name of the location of the initial facility (e.g. terminal, warehouse or yard) where the conveyance will arrive.' ],
'254' => [ 'Bus station',
    'Name or identification of a bus station.' ],
'255' => [ 'Ferry terminal',
    'Name or identification of a ferry terminal.' ],
'256' => [ 'Place of packing',
    'Place where goods are packaged.' ],
'257' => [ 'Country of assembly',
    'Country where product is assembled.' ],
'258' => [ 'Town sales office',
    'The location is a town sales office.' ],
'259' => [ 'Travel agency',
    'The location is a travel agency.' ],
'260' => [ 'Inland clearance depot',
    'Depot where goods are cleared by the customs authorities or other governmental authorities in the interior of a country.' ],
'261' => [ 'Place of final production',
    'Place where the production of the item was finalised.' ],
'262' => [ 'Place of growth',
    'Place where the product was grown.' ],
'263' => [ 'Place of intermediate production',
    'Place of any processing prior to final production.' ],
'264' => [ 'Place of nutrient origin',
    'Place where the nutrient, or item of nourishing food, originated.' ],
'265' => [ 'Place of package material production',
    'Place where the material used for packaging was produced.' ],
'266' => [ 'Place of processing',
    'The place where the commodity was processed.' ],
'267' => [ 'Place of species origin',
    'The place where the species was taken from the wild, or the place where the species was born, artificially propagated, grown or harvested.' ],
'268' => [ 'Place of catch',
    'Place where the animal was caught, e.g. area of the ocean where the fish was harvested.' ],
'269' => [ 'Government appeal office',
    'The location of a government office at which an appeal can be lodged.' ],
'270' => [ 'Regulatory office of cross-border goods entry',
    'To identify the regulatory office at which the goods enter or are intended to enter the customs territory of destination.' ],
'271' => [ 'Regulatory office of cross-border goods exit',
    'To identify the regulatory office at which the goods leave or are intended to leave the customs territory of dispatch.' ],
'272' => [ 'Government approved establishment',
    'Facility approved for a specific purpose by a government authority.' ],
'273' => [ 'Free trade zone',
    'A special area of a country where some normal trade barriers (e.g. tariffs and quotas) are eliminated, a.k.a. foreign free zone.' ],
'274' => [ 'Place of physical examination',
    'A place where goods are to be examined.' ],
'275' => [ 'Permitted location',
    'The location at which goods identified on the license, permit, certificate or other document are allowed to be moved or otherwise handled.' ],
'276' => [ 'Landing location',
    'The place where a means of transport may be parked or tied up, e.g. wharf, quay, railyard, parking lot.' ],
'277' => [ 'Place of loading on final means of transport',
    'Place where a consignment is placed aboard the means of transport which enters the destination customs territory.' ],
'278' => [ 'Place of regulatory declaration review',
    'Location where the declaration is reviewed by appropriate government agency.' ],
'279' => [ 'Travel document issuing country or political entity',
    'The country or political entity issuing the travel document.' ],
'280' => [ 'Compliant facility, registered',
    'A facility that has been formally documented as compliant with regulations or statutes by a regulatory authority.' ],
'281' => [ 'Bonded warehouse',
    'A building or other secured area in which dutiable goods may be stored, manipulated, or undergo manufacturing operations without payment of duty.' ],
'282' => [ 'Goods destruction site, designated',
    'A place designated for the destruction of goods.' ],
'283' => [ 'Goods disposal location, designated',
    'A place designated for the disposal of goods.' ],
'284' => [ 'Incineration facility',
    'Facility with a furnace or apparatus for consuming materials completely or reducing materials to ash by burning.' ],
'285' => [ 'Laboratory',
    'A facility equipped for scientific experimentation, research, testing or determination.' ],
'286' => [ 'Place of assembly',
    'Facility where product is assembled.' ],
'287' => [ 'Processing site',
    'Place where an operation or a series of operations are performed in the making or treatment of a product.' ],
'288' => [ 'Quarantine facility',
    'A place or station where isolation is carried out.' ],
'289' => [ 'Reclamation facility',
    'A facility where desired substances are recovered from materials or goods.' ],
'290' => [ 'Refinery',
    'An industrial plant for refining a substance, such as petroleum or sugar.' ],
'291' => [ 'Smelter',
    'A facility where ores are fused or melted in order to separate the metal contained in them.' ],
'292' => [ 'Prescribed treatment facility',
    'A facility where goods are subjected to a prescribed treatment.' ],
'293' => [ 'Embassy',
    'The official headquarters of an ambassador or official diplomat sent by one sovereign or state to another as its resident representative.' ],
'294' => [ 'Region of source',
    'Region where goods were originally produced.' ],
'295' => [ 'Region of storage',
    'Region where products have been stored.' ],
'296' => [ 'Ship security incident location',
    'Location for reporting any security related matter to indicate where the safety/security incident has taken place.' ],
'297' => [ 'Ship-to-ship activity location',
    'Location where the ship-to-ship activity has taken place.' ],
'298' => [ 'Country of last processing',
    'The country where the trade item was last processed.' ],
'ZZZ' => [ 'Mutually defined',
    'Place or location as agreed between the relevant parties.' ],
);
sub get_codes { return \%code_hash; }

1;
