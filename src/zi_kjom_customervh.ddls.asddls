@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Customer Value Help'
@ObjectModel.representativeKey: 'CustomerUUID'
@Search.searchable: true
define view entity ZI_KJOM_CustomerVH
  as select from zkj_om_customer
{
  key customer_uuid as CustomerUUID,

      @Search.defaultSearchElement: true
      @ObjectModel.text.element: [ 'CustomerName' ]
      customer_id as Customer,

      @Search.defaultSearchElement: true
      customer_name as CustomerName,

      city as City,
      country as Country,
      sales_organization as SalesOrganization,
      currency_code as Currency
}
where status = 'A'
