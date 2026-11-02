@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales Order Header - Projection View'
@Metadata.ignorePropagatedAnnotations: true

@UI.headerInfo : { 
    typeNamePlural : 'Sales Header Data'  ,  // it is used for Heading object page
    title :{ value : 'Customer' },
    typeName : 'Sales Header',
    description : { value : 'Status' }
}

define root view entity Y182C_RAP_HEADER
  provider contract transactional_query
  as projection on Y182I_RAP_HEADER
{
  @UI.facet: [
  {
    id: 'Items',
    purpose: #STANDARD,
    type: #LINEITEM_REFERENCE,
    label: 'Sales Order Items',
    position: 20,
    targetElement: '_Item'
  },
  { id : 'super',
      purpose : #STANDARD,
      type : #COLLECTION,
      position : 10,
      label : 'Sales Header Info' 
    },
    {  parentId: 'super',
       purpose : #STANDARD,
       type : #IDENTIFICATION_REFERENCE,
       position : 10,
       label : 'Sales Info Details'
    }
]

  @EndUserText.label: 'Unique Id'
  @UI.lineItem: [
    { position: 10 },
    { type: #FOR_ACTION, dataAction: 'ApprovedStatus', label: 'Approve Order' },
    { type: #FOR_ACTION, dataAction: 'copyCustomer', label: 'Copy Customer' }
  ]
  @UI.identification: [
    { position: 10 },
    { type: #FOR_ACTION, dataAction: 'ApprovedStatus', label: 'Approve Order' },
    { type: #FOR_ACTION, dataAction: 'copyCustomer', label: 'Copy Customer' }
  ]
  key SoId,
  
  

  @EndUserText.label: 'So Number'
  @UI.lineItem: [{ position: 20 }]
  @UI.identification: [{ position: 20 }]
  SoNumber,

  @EndUserText.label: 'Customer'
  @UI.lineItem: [{ position: 30 }]
  @UI.identification: [{ position: 30 }]
  @UI.selectionField: [{ position: 10 }]
  Customer,

  @EndUserText.label: 'Order Date'
  @UI.lineItem: [{ position: 40 }]
  @UI.identification: [{ position: 40 }]
  OrderDate,

  @EndUserText.label: 'Status'
  @UI.lineItem: [{ position: 50 }]
  @UI.identification: [{ position: 50 }]
  Status,

//  @EndUserText.label: 'Currency'
//  @UI.lineItem: [{ position: 60 }]
//  @UI.identification: [{ position: 60 }]
//  Currency,

  @EndUserText.label: 'Currency'
  @UI.lineItem: [{ position: 60 }]
  @UI.identification: [{ position: 60 }]
  @Consumption.valueHelpDefinition: [{ entity: { name: 'I_Currency', element: 'Currency' } }] 
  Currency,

  @EndUserText.label: 'Unit'
  @UI.lineItem: [{ position: 70 }]
  @UI.identification: [{ position: 70 }]  
  @Consumption.valueHelpDefinition: [{ entity: { name: 'I_UnitOfMeasure', element: 'UnitOfMeasure' } }]
  Unit,

  @EndUserText.label: 'Unit Price'
  @UI.lineItem: [{ position: 80 }]
  @UI.identification: [{ position: 80 }]
  @Semantics.amount.currencyCode: 'Currency'
  UnitPrice,

  @EndUserText.label: 'Quantity'
  @UI.lineItem: [{ position: 90 }]
  @UI.identification: [{ position: 90 }]
  @Semantics.quantity.unitOfMeasure: 'Unit'
  Quantity,

  @EndUserText.label: 'Total Amount'
  @UI.lineItem: [{ position: 100 }]
  @UI.identification: [{ position: 100 }]
  @Semantics.amount.currencyCode: 'Currency'
  TotalAmt,

  CreatedBy,
  CreatedAt,
  LastChangedBy,
  LastChangedAt,
  LocalLastChangedAt,
  
  

   
   _Item : redirected to composition child Y182C_RAP_ITEM,
   
   _Currency // <--- Expose here too

}
