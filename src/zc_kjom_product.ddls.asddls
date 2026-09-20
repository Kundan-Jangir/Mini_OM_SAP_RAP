@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Product Application'
@Metadata.allowExtensions: true
@Search.searchable: true
define root view entity ZC_KJOM_Product
  provider contract transactional_query
  as projection on ZI_KJOM_Product
{
  key ProductUUID,

      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      Product,

      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      ProductName,

      ProductGroup,
      BaseUnit,

      Currency,
      StandardPrice,
      TaxPercentage,

      AvailableStock,
      ReorderLevel,
      DefaultPlant,

      Status,
      StatusText,
      StatusCriticality,
      StockCriticality,

      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedBy,
      LocalLastChangedAt
}
