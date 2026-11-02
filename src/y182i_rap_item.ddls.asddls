@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface View for ITEM'
@Metadata.ignorePropagatedAnnotations: true
define view entity Y182I_RAP_ITEM as select from Y182DBT_ITEM
  association to parent Y182I_RAP_HEADER as _HEADER
    on $projection.SoId = _HEADER.SoId

{
  key item_id          as ItemId,
      so_id            as SoId,
      item_number      as ItemNumber,
      material         as Material,
      unit             as Unit,

      @Semantics.quantity.unitOfMeasure: 'Unit'
      quantity         as Quantity,

      net_price        as NetPrice,
      @Semantics.systemDateTime.lastChangedAt: true  //This field represents the last date/time when the record was changed.
      last_changed_at as LastChangedAt,

      _HEADER
}
