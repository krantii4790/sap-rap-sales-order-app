@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales Order Item - Projection View'
@Metadata.ignorePropagatedAnnotations: true

@UI.headerInfo : { 
    typeNamePlural : 'Sales Header Data'  ,  // it is used for Heading object page
    title :{ value : 'Material' },
    typeName : 'Sales Header',
    description : { value : 'ItemNumber' }
}

define view entity Y182C_RAP_ITEM
  as projection on Y182I_RAP_ITEM
{

@UI.facet: [{ 
        purpose : #STANDARD,
        type : #IDENTIFICATION_REFERENCE,
        label : 'Item Details',
        position :10
 }]
  @EndUserText.label: 'Item Id'
  @UI.lineItem: [{ position: 10 }]
  @UI.identification: [{ position: 10 }]
  key ItemId,

  @EndUserText.label: 'Sales Order'
  @UI.lineItem: [{ position: 20 }]
  @UI.identification: [{ position: 20 }]
  SoId,

  @EndUserText.label: 'Item Number'
  @UI.lineItem: [{ position: 30 }]
  @UI.identification: [{ position: 30 }]
  ItemNumber,

  @EndUserText.label: 'Material'
  @UI.lineItem: [{ position: 40 }]
  @UI.identification: [{ position: 40 }]
  Material,

  @EndUserText.label: 'Unit'
  @UI.lineItem: [{ position: 50 }]
  @UI.identification: [{ position: 50 }]
  @Consumption.valueHelpDefinition: [{ entity: { name: 'I_UnitOfMeasure', element: 'UnitOfMeasure' } }]
  Unit,

  @EndUserText.label: 'Quantity'
  @UI.lineItem: [{ position: 60 }]
  @UI.identification: [{ position: 60 }]
  @Semantics.quantity.unitOfMeasure: 'Unit'
  Quantity,

  @EndUserText.label: 'Net Price'
  @UI.lineItem: [{ position: 70 }]
  @UI.identification: [{ position: 70 }]
  NetPrice,

  LastChangedAt,

  _HEADER : redirected to parent Y182C_RAP_HEADER
}
