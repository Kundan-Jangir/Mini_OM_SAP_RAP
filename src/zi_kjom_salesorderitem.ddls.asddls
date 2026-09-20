@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales Order Item Interface'
@Metadata.allowExtensions: true
define view entity ZI_KJOM_SalesOrderItem
  as select from zkj_om_so_i

  association to parent ZI_KJOM_SalesOrder as _SalesOrder
    on $projection.SalesOrderUUID = _SalesOrder.SalesOrderUUID

  association [0..1] to ZI_KJOM_Product as _Product
    on $projection.ProductUUID = _Product.ProductUUID

{     @EndUserText.label: 'Sales Order UUID'
  key parent_uuid as SalesOrderUUID,
      
      @EndUserText.label: 'Sales Order Item UUID'
  key sales_order_item_uuid as SalesOrderItemUUID,

      @EndUserText.label: 'Sales Order'
      sales_order as SalesOrder,

      @EndUserText.label: 'Sales Order Item'
      sales_order_item as SalesOrderItem,

      @EndUserText.label: 'Product UUID'
      product_uuid as ProductUUID,

      @EndUserText.label: 'Product Description'
      product_description as ProductDescription,

      @EndUserText.label: 'Order Quantity'
      @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
      order_quantity as OrderQuantity,

      @EndUserText.label: 'Order Quantity Unit'
      order_quantity_unit as OrderQuantityUnit,

      @EndUserText.label: 'Transaction Currency'
      transaction_currency as TransactionCurrency,

      @EndUserText.label: 'Unit Price'
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      unit_price as UnitPrice,

      @EndUserText.label: 'Discount Percentage'
      discount_percentage as DiscountPercentage,

      @EndUserText.label: 'Gross Amount'
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      gross_amount as GrossAmount,

      @EndUserText.label: 'Discount Amount'
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      discount_amount as DiscountAmount,

      @EndUserText.label: 'Net Amount'
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      net_amount as NetAmount,

      @EndUserText.label: 'Tax Percentage'
      tax_percentage as TaxPercentage,

      @EndUserText.label: 'Tax Amount'
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      tax_amount as TaxAmount,

      @EndUserText.label: 'Total Amount'
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      total_amount as TotalAmount,

      @EndUserText.label: 'Plant'
      plant as Plant,

      @EndUserText.label: 'Item Status'
      item_status as ItemStatus,

      @EndUserText.label: 'Created By'
      @Semantics.user.createdBy: true
      created_by as CreatedBy,

      @EndUserText.label: 'Created At'
      @Semantics.systemDateTime.createdAt: true
      created_at as CreatedAt,

      @EndUserText.label: 'Last Changed By'
      @Semantics.user.lastChangedBy: true
      last_changed_by as LastChangedBy,

      @EndUserText.label: 'Last Changed At'
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at as LastChangedAt,

      @EndUserText.label: 'Local Last Changed By'
      @Semantics.user.localInstanceLastChangedBy: true
      local_last_changed_by as LocalLastChangedBy,

      @EndUserText.label: 'Local Last Changed At'
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,

      _SalesOrder,
      _Product
}
