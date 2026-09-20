@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Product Interface'
@Metadata.allowExtensions: true
@Search.searchable: true
define root view entity ZI_KJOM_Product
  as select from zkj_om_product
{
      @EndUserText.label: 'Product UUID'
  key product_uuid          as ProductUUID,

      @EndUserText.label: 'Product ID'
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      product_id            as Product,

      @EndUserText.label: 'Product Name'
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      product_name          as ProductName,

      @EndUserText.label: 'Product Group'
      product_group         as ProductGroup,

      @EndUserText.label: 'Base Unit'
      base_unit             as BaseUnit,

      @EndUserText.label: 'Currency'
      currency_code         as Currency,

      @EndUserText.label: 'Standard Price'
      @Semantics.amount.currencyCode: 'Currency'
      standard_price        as StandardPrice,

      @EndUserText.label: 'Tax Percentage'
      tax_percentage        as TaxPercentage,

      @EndUserText.label: 'Available Stock'
      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      available_stock       as AvailableStock,

      @EndUserText.label: 'Reorder Level'
      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      reorder_level         as ReorderLevel,

      @EndUserText.label: 'Default Plant'
      default_plant         as DefaultPlant,

      @EndUserText.label: 'Status'
      status                as Status,

      @EndUserText.label: 'Status'
      cast(
        case status
          when 'A' then 'Active'
          when 'B' then 'Blocked'
          when 'D' then 'Discontinued'
          else 'Unknown'
        end as abap.char(12)
      )                     as StatusText,

      @EndUserText.label: 'Status Criticality'
      cast(
        case status
          when 'A' then 3
          when 'B' then 1
          when 'D' then 2
          else 0
        end as abap.int1
      )                     as StatusCriticality,

      @EndUserText.label: 'Stock Criticality'
      cast(
        case
          when available_stock <= 0 then 1
          when available_stock <= reorder_level then 2
          else 3
        end as abap.int1
      )                     as StockCriticality,

      @EndUserText.label: 'Created By'
      @Semantics.user.createdBy: true
      created_by            as CreatedBy,

      @EndUserText.label: 'Created At'
      @Semantics.systemDateTime.createdAt: true
      created_at            as CreatedAt,

      @EndUserText.label: 'Last Changed By'
      @Semantics.user.lastChangedBy: true
      last_changed_by       as LastChangedBy,

      @EndUserText.label: 'Last Changed At'
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,

      @EndUserText.label: 'Local Last Changed By'
      @Semantics.user.localInstanceLastChangedBy: true
      local_last_changed_by as LocalLastChangedBy,

      @EndUserText.label: 'Local Last Changed At'
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt
}
