@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales Order Item Application'
@Metadata.allowExtensions: true
define view entity ZC_KJOM_SalesOrderItem
  as projection on ZI_KJOM_SalesOrderItem
{ key SalesOrderUUID,

  key SalesOrderItemUUID,
      SalesOrder,
      SalesOrderItem,

      @Consumption.valueHelpDefinition: [
        {
          entity: {
            name: 'ZI_KJOM_ProductVH',
            element: 'ProductUUID'
          }
        }
      ]
      ProductUUID,

      ProductDescription,

      OrderQuantity,
      OrderQuantityUnit,

      TransactionCurrency,
      UnitPrice,

      DiscountPercentage,
      GrossAmount,
      DiscountAmount,
      NetAmount,

      TaxPercentage,
      TaxAmount,
      TotalAmount,

      Plant,
      ItemStatus,

      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedBy,
      LocalLastChangedAt,

      _SalesOrder : redirected to parent ZC_KJOM_SalesOrder,

      _Product    : redirected to ZC_KJOM_Product
}
