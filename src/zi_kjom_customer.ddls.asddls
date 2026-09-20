@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Customer Interface'
@Metadata.allowExtensions: true
@Search.searchable: true
define root view entity ZI_KJOM_Customer
  as select from zkj_om_customer
{
      @EndUserText.label: 'Customer UUID'
  key customer_uuid         as CustomerUUID,

      @EndUserText.label: 'Customer ID'
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      customer_id           as Customer,

      @EndUserText.label: 'Customer Name'
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      customer_name         as CustomerName,

      @EndUserText.label: 'Customer Group'
      customer_group        as CustomerGroup,

      @EndUserText.label: 'Street'
      street                as Street,

      @EndUserText.label: 'Postal Code'
      postal_code           as PostalCode,

      @EndUserText.label: 'City'
      city                  as City,

      @EndUserText.label: 'Country/Region'
      country               as Country,

      @EndUserText.label: 'Region'
      region                as Region,

      @EndUserText.label: 'Email Address'
      email_address         as EmailAddress,

      @EndUserText.label: 'Phone Number'
      phone_number          as PhoneNumber,

      @EndUserText.label: 'Sales Organization'
      sales_organization    as SalesOrganization,

      @EndUserText.label: 'Distribution Channel'
      distribution_channel  as DistributionChannel,

      @EndUserText.label: 'Division'
      division              as Division,

      @EndUserText.label: 'Currency'
      currency_code         as Currency,

      @EndUserText.label: 'Credit Limit'
      @Semantics.amount.currencyCode: 'Currency'
      credit_limit          as CreditLimit,

      @EndUserText.label: 'Status'
      status                as Status,

      @EndUserText.label: 'Status'
      cast(
        case status
          when 'A' then 'Active'
          when 'B' then 'Blocked'
          when 'I' then 'Inactive'
          else 'Unknown'
        end as abap.char(10)
      )                     as StatusText,

      @EndUserText.label: 'Status Criticality'
      cast(
        case status
          when 'A' then 3
          when 'B' then 1
          when 'I' then 2
          else 0
        end as abap.int1
      )                     as StatusCriticality,

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
