@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales Order Interface'
@Metadata.allowExtensions: true
@Search.searchable: true
define root view entity ZI_KJOM_SalesOrder
  as select from zkj_om_so_h

  composition [0..*] of ZI_KJOM_SalesOrderItem as _Items

  association [0..1] to ZI_KJOM_Customer       as _Customer on $projection.CustomerUUID = _Customer.CustomerUUID

{
      @EndUserText.label: 'Sales Order UUID'
  key sales_order_uuid        as SalesOrderUUID,

      @EndUserText.label: 'Sales Order'
      @Search.defaultSearchElement: true
      sales_order             as SalesOrder,

      @EndUserText.label: 'Sales Order Type'
      sales_order_type        as SalesOrderType,

      @EndUserText.label: 'Customer UUID'
      customer_uuid           as CustomerUUID,

      @EndUserText.label: 'Customer Reference'
      @Search.defaultSearchElement: true
      customer_reference      as CustomerReference,

      @EndUserText.label: 'Sales Organization'
      sales_organization      as SalesOrganization,

      @EndUserText.label: 'Distribution Channel'
      distribution_channel    as DistributionChannel,

      @EndUserText.label: 'Division'
      division                as Division,

      @EndUserText.label: 'Order Date'
      order_date              as OrderDate,

      @EndUserText.label: 'Requested Delivery Date'
      requested_delivery_date as RequestedDeliveryDate,

      @EndUserText.label: 'Transaction Currency'
      transaction_currency    as TransactionCurrency,

      @EndUserText.label: 'Gross Amount'
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      gross_amount            as GrossAmount,

      @EndUserText.label: 'Discount Amount'
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      discount_amount         as DiscountAmount,

      @EndUserText.label: 'Net Amount'
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      net_amount              as NetAmount,

      @EndUserText.label: 'Tax Amount'
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      tax_amount              as TaxAmount,

      @EndUserText.label: 'Total Amount'
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      total_amount            as TotalAmount,

      @EndUserText.label: 'Overall Status'
      overall_status          as OverallStatus,

      @EndUserText.label: 'Rejection Reason'
      rejection_reason        as RejectionReason,

      @EndUserText.label: 'Created By'
      @Semantics.user.createdBy: true
      created_by              as CreatedBy,

      @EndUserText.label: 'Created At'
      @Semantics.systemDateTime.createdAt: true
      created_at              as CreatedAt,

      @EndUserText.label: 'Last Changed By'
      @Semantics.user.lastChangedBy: true
      last_changed_by         as LastChangedBy,

      @EndUserText.label: 'Last Changed At'
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at         as LastChangedAt,

      @EndUserText.label: 'Local Last Changed By'
      @Semantics.user.localInstanceLastChangedBy: true
      local_last_changed_by   as LocalLastChangedBy,

      @EndUserText.label: 'Local Last Changed At'
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at   as LocalLastChangedAt,

      _Items,
      _Customer
}
