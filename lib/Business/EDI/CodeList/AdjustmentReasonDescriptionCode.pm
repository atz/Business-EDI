package Business::EDI::CodeList::AdjustmentReasonDescriptionCode;

use base 'Business::EDI::CodeList';
my $VERSION     = 0.02;
sub list_number {4465;}
my $usage       = 'C';

# 4465  Adjustment reason description code                      [C]
# Desc: Code specifying the adjustment reason.
# Repr: an..3

my %code_hash = (
'1' => [ 'Agreed settlement',
    'An adjustment made based on an agreement between partners.' ],
'2' => [ 'Below specification goods',
    'Goods of inferior quality.' ],
'3' => [ 'Damaged goods',
    'An adjustment due to the damage of goods.' ],
'4' => [ 'Short delivery',
    'An adjustment made because the delivered quantity was less than expected.' ],
'5' => [ 'Price query',
    'An adjustment due to a price query.' ],
'6' => [ 'Proof of delivery required',
    'The buyer requires that proof of delivery be made before payment.' ],
'7' => [ 'Payment on account',
    'Buyer is to make payment later.' ],
'8' => [ 'Returnable container charge included',
    'Adjustment made to deduct the returnable container charge.' ],
'9' => [ 'Invoice error',
    'Invoice not in accordance with the order.' ],
'10' => [ 'Costs for draft',
    'Cost of draft has been deducted from payment.' ],
'11' => [ 'Bank charges',
    'Bank charges have been deducted from payment.' ],
'12' => [ 'Agent commission',
    'Agent commission has been deducted from payment.' ],
'13' => [ 'Counter claim',
    'Buyer claims an existing (financial) obligation from seller which (partly) offsets the outstanding invoice(s).' ],
'14' => [ 'Wrong delivery',
    'Delivery not according to specifications.' ],
'15' => [ 'Goods returned to agent',
    'Goods returned to agent.' ],
'16' => [ 'Goods partly returned',
    'Goods partly returned.' ],
'17' => [ 'Transport damage',
    'Goods damaged in transit.' ],
'18' => [ 'Goods on consignment',
    'Buyer does not accept invoice(s) charge as it relates to goods where the ownership remains with the seller until sold.' ],
'19' => [ 'Trade discount',
    'Trade discount deducted from payment.' ],
'20' => [ 'Deduction for late delivery',
    'Penalty amount deducted for later delivery.' ],
'21' => [ 'Advertising costs',
    'Advertising costs deducted from payment.' ],
'22' => [ 'Customs duties',
    'Customs duties deducted from payment.' ],
'23' => [ 'Telephone and postal costs',
    'Telephone and postal costs deducted from payment.' ],
'24' => [ 'Repair costs',
    'Repair costs deducted from payment.' ],
'25' => [ 'Attorney fees',
    'Attorney fees deducted from payment.' ],
'26' => [ 'Taxes',
    'Taxes deducted from payment.' ],
'27' => [ 'Reclaimed deduction',
    'Buyer reclaims an unspecified deduction from the invoice(s) (to be) paid.' ],
'28' => [ 'See separate advice',
    'Buyer or seller refers to separate correspondence about a related shipment(s) and/or invoice(s) and/or a payment(s).' ],
'29' => [ 'Buyer refused to take delivery',
    'Buyer refused to take delivery.' ],
'30' => [ 'Direct payment to seller',
    'Buyer states to have paid to seller.' ],
'31' => [ 'Buyer disagrees with due date',
    'Buyer disagrees with due date.' ],
'32' => [ 'Goods not delivered',
    'Buyer has not received the goods.' ],
'33' => [ 'Late delivery',
    'Goods delivered too late.' ],
'34' => [ 'Quoted as paid to you',
    'Factor informs the seller that a certain invoice(s) was paid by the buyer directly to the seller.' ],
'35' => [ 'Goods returned',
    'Buyer returned the goods to seller.' ],
'36' => [ 'Invoice not received',
    'Buyer claims he did not receive the invoice for which payment is requested.' ],
'37' => [ 'Credit note to debtor/not to us',
    'Factor informs the seller that he did not receive copy of a credit note sent to the buyer.' ],
'38' => [ 'Deducted bonus',
    'Buyer has/will deduct a bonus he is entitled to from the payment.' ],
'39' => [ 'Deducted discount',
    'Buyer has/will deduct the discount he is entitled to from the payment.' ],
'40' => [ 'Deducted freight costs',
    'Buyer has/will deduct freight costs from the payment.' ],
'41' => [ 'Deduction against other invoices',
    'Deduction against invoices already settled.' ],
'42' => [ 'Credit balance(s)',
    'Buyer makes use of existing credit balance(s) to offset (partly) the outstanding invoice(s).' ],
'43' => [ 'Reason unknown',
    'Factor informs the seller that the reason of a commercial dispute raised by the buyer is unknown.' ],
'44' => [ 'Awaiting message from seller',
    'Buyer or factor are waiting for a (reply) message from the seller before a commercial dispute can be settled.' ],
'45' => [ 'Debit note to seller',
    'Buyer issued debit note to seller.' ],
'46' => [ 'Discount beyond terms',
    'Buyer has taken a discount larger than the discount terms agreed with the seller.' ],
'47' => [ "See buyer's letter",
    'See correspondence from buyer.' ],
'48' => [ 'Allowance/charge error',
    'Error made by seller in the amount of allowance/charge.' ],
'49' => [ 'Substitute product',
    'Product delivered not fully according to specification.' ],
'50' => [ 'Terms of sale error',
    'Terms of sale not according to purchase order.' ],
'51' => [ 'Required data missing',
    'A message sent by buyer to seller or by seller to buyer did not contain data required to take action/decision.' ],
'52' => [ 'Wrong invoice',
    'Invoice issued to wrong party.' ],
'53' => [ 'Duplicate invoice',
    'Invoice sent twice.' ],
'54' => [ 'Weight error',
    'Weight not in accordance with the order.' ],
'55' => [ 'Additional charge not authorized',
    'Additional charge not authorised.' ],
'56' => [ 'Incorrect discount',
    'Buyer states that calculated discount on the invoice(s) is wrongly calculated.' ],
'57' => [ 'Price change',
    'Price has been changed.' ],
'58' => [ 'Variation',
    'The adjustment is a variation from an agreed value.' ],
'59' => [ 'Chargeback',
    'Balance of one or more items charged back to seller.' ],
'60' => [ 'Offset',
    'Allocation of one or more debit items to one or more credit items or vice-versa.' ],
'61' => [ 'Indirect payment',
    'Payment in settlement of an invoice has been made to a party other than the designated creditor.' ],
'62' => [ 'Financial reassignment',
    'Previously assigned invoice/credit note is being reassigned.' ],
'63' => [ 'Reinstatement of chargeback/offset',
    'Reversal or cancellation of a chargeback and/or offset relating to an incorrect balance.' ],
'64' => [ 'Expecting new terms',
    'Buyer expects that seller revises the terms of payment of an invoice.' ],
'65' => [ 'Settlement to agent',
    "Invoice has been/to be paid to seller's agent." ],
'66' => [ 'Cash discount',
    'An adjustment has been made due to the application of a cash discount.' ],
'67' => [ 'Delcredere costs',
    'Costs deducted from a total amount to pay for the services of central payment.' ],
'68' => [ 'Early payment allowance adjustment',
    'Adjustment results from the application of an early payment allowance.' ],
'69' => [ 'Incorrect due date for monetary amount',
    'Adjustment has been made because an incorrect due date was referred to with regard to the monetary amount.' ],
'70' => [ 'Wrong monetary amount resulting from incorrect free goods',
    'quantity Adjustment has been made because of a wrong monetary amount resulting from an incorrect free goods quantity.' ],
'71' => [ 'Rack or shelf replenishment service by a supplier',
    'Adjustment due to the replenishment of the racks or shelves by a supplier.' ],
'72' => [ 'Temporary special promotion',
    'Adjustment due to a temporary special promotion.' ],
'73' => [ 'Difference in tax rate',
    'Adjustment due to a difference in tax rate.' ],
'74' => [ 'Quantity discount',
    'Adjustment due to a quantity discount.' ],
'75' => [ 'Promotion discount',
    'Adjustment due to a promotion discount.' ],
'76' => [ 'Cancellation deadline passed',
    'The cancellation has occurred after the deadline.' ],
'77' => [ 'Pricing discount',
    'An adjustment has been made due to the application of a pricing discount.' ],
'78' => [ 'Volume discount',
    'Discount for reaching or exceeding an agreed accumulated volume.' ],
'79' => [ 'Sundry discount',
    'Adjustment has been made due to the application of a sundry discount.' ],
'80' => [ 'Card holder signature missing',
    'The adjustment was made due to the card holder not signing the filing document.' ],
'81' => [ 'Card expiry date missing',
    'The adjustment was made due to the card acceptor not specifying the expiry date within the filing document.' ],
'82' => [ 'Card number error',
    'The adjustment was made due to the card acceptor specifying an erroneous card number within the filing document.' ],
'83' => [ 'Card expired',
    'The adjustment was made due to the card acceptor specifying an expired expiry date within the filing document or electronic data.' ],
'84' => [ 'Test card transaction',
    'The adjustment was made due to a test card transaction, used for installing, maintaining or debugging purposes.' ],
'85' => [ 'Permission limit exceeded',
    'The adjustment was made due to the permission limit defined by card issuer or card company was exceeded without prior authorisation. Synonym: Floor limit.' ],
'86' => [ 'Wrong authorisation code',
    'The adjustment was made due to the authorisation code provided did not fit to the specified transaction.' ],
'87' => [ 'Wrong authorised amount',
    'The adjustment was made due to the specified amount not meeting the authorised amount for the transaction.' ],
'88' => [ 'Authorisation failed',
    'The adjustment was made due to the authorisation needed had failed.' ],
'89' => [ 'Card acceptor data error',
    'The adjustment was made due to the data regarding the card acceptor is erroneous.' ],
'90' => [ 'Treasury management service charge',
    'Charge for the service of treasury management.' ],
'91' => [ 'Agreed discount',
    'The reason for the adjustment is that a mutually agreed discount has been applied.' ],
'92' => [ 'Expediting fee',
    'The reason for the adjustment is that a fee for expediting has been applied.' ],
'93' => [ 'Invoicing fee',
    'The reason for the adjustment is that a fee for invoicing has been applied.' ],
'94' => [ 'Freight charge',
    'The reason for the adjustment is that freight charges has been applied.' ],
'95' => [ 'Small order processing service charge',
    'The reason for the adjustment is that a fee for processing of a small order (an order below a defined threshold) has been applied.' ],
'96' => [ 'Currency exchange differences',
    'An adjustment made due to a change in a currency exchange rate.' ],
'97' => [ 'Insolvency',
    "An adjustment made due to the partner's inability to pay open debts." ],
'ZZZ' => [ 'Mutually defined',
    'A code assigned within a code list to be used on an interim basis and as defined among trading partners until a precise code can be assigned to the code list.' ],
);
sub get_codes { return \%code_hash; }

1;
