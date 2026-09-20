@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales Order Application'
@Metadata.allowExtensions: true
@Search.searchable: true
define root view entity ZC_KJOM_SalesOrder
  provider contract transactional_query
  as projection on ZI_KJOM_SalesOrder
{
  key SalesOrderUUID,

      @Search.defaultSearchElement: true
      SalesOrder,

      SalesOrderType,

      @Consumption.valueHelpDefinition: [
        {
          entity: {
            name: 'ZI_KJOM_CustomerVH',
            element: 'CustomerUUID'
          }
        }
      ]
      CustomerUUID,

      CustomerReference,

      SalesOrganization,
      DistributionChannel,
      Division,

      OrderDate,
      RequestedDeliveryDate,

      TransactionCurrency,

      GrossAmount,
      DiscountAmount,
      NetAmount,
      TaxAmount,
      TotalAmount,

      OverallStatus,
      RejectionReason,

      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedBy,
      LocalLastChangedAt,

      _Items    : redirected to composition child ZC_KJOM_SalesOrderItem,

      _Customer : redirected to ZC_KJOM_Customer
}
