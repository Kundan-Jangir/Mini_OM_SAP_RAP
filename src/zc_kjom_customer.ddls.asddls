@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Customer Application'
@Metadata.allowExtensions: true
@Search.searchable: true
define root view entity ZC_KJOM_Customer
  provider contract transactional_query
  as projection on ZI_KJOM_Customer
{
  key CustomerUUID,
  
      @EndUserText.label: 'Customer ID'
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      Customer,

      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      CustomerName,

      CustomerGroup,

      Street,
      PostalCode,
      City,
      Country,
      Region,

      EmailAddress,
      PhoneNumber,

      SalesOrganization,
      DistributionChannel,
      Division,

      Currency,
      CreditLimit,

      Status,
      StatusText,
      StatusCriticality,

      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedBy,
      LocalLastChangedAt
}
