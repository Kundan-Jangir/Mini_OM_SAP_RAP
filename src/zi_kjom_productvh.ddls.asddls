@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Product Value Help'
@ObjectModel.representativeKey: 'ProductUUID'
@Search.searchable: true
define view entity ZI_KJOM_ProductVH
  as select from zkj_om_product
{
      @EndUserText.label: 'Product UUID'
  key product_uuid    as ProductUUID,

      @EndUserText.label: 'Product ID'
      @Search.defaultSearchElement: true
      @ObjectModel.text.element: [ 'ProductName' ]
      product_id      as Product,

      @EndUserText.label: 'Product Name'
      @Search.defaultSearchElement: true
      product_name    as ProductName,

      @EndUserText.label: 'Product Group'
      product_group   as ProductGroup,

      @EndUserText.label: 'Base Unit'
      base_unit       as BaseUnit,

      @EndUserText.label: 'Standard Price'
      @Semantics.amount.currencyCode: 'Currency'
      standard_price  as StandardPrice,

      @EndUserText.label: 'Currency'
      currency_code   as Currency,

      @EndUserText.label: 'Available Stock'
      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      available_stock as AvailableStock,

      @EndUserText.label: 'Default Plant'
      default_plant   as DefaultPlant
}
where
  status = 'A'
