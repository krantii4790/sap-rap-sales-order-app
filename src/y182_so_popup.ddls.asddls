@EndUserText.label: 'POPUP MESSAGE'
define abstract entity Y182_SO_Popup
{
    @EndUserText.label: 'Do you want to approve?'
  @UI.defaultValue: 'Do you want to approve?'
  confirmation_note : abap.char(100);    
}
