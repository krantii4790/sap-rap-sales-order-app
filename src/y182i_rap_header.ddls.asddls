@AccessControl.authorizationCheck: #NOT_REQUIRED    //Don't apply CDS authorization checks.
@EndUserText.label: 'Interface CDS View Header'
@Metadata.ignorePropagatedAnnotations: true

define root view entity Y182I_RAP_HEADER as select from Y182DBT_HEADER
composition [0..*] of Y182I_RAP_ITEM as _Item
//[0..*] This is the cardinality. It tells us how many Items a Header can have.
association [0..1] to I_Currency as _Currency on $projection.Currency = _Currency.Currency
{
   key so_id as SoId,
      so_number         as SoNumber,
      customer          as Customer,
      order_date        as OrderDate,
      status            as Status,
      currency          as Currency,
      unit              as Unit, 
      
      @Semantics.amount.currencyCode: 'Currency'    //UnitPrice is an amount, and its currency is stored in Currency. 500 INR
      unit_price        as UnitPrice,

      @Semantics.quantity.unitOfMeasure: 'Unit'   //Quantity uses the unit stored in Unit. 10 EA
      quantity          as Quantity,

      @Semantics.amount.currencyCode: 'Currency'
      total_amount      as TotalAmt,

      @Semantics.user.createdBy: true
      created_by        as CreatedBy,

      @Semantics.systemDateTime.createdAt: true
      created_at        as CreatedAt,

      @Semantics.user.lastChangedBy: true
      last_changed_by   as LastChangedBy,

      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at   as LastChangedAt,

      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,

      _Item,
      _Currency // <--- Expose the association here
}
