CLASS lhc_Y182I_RAP_HEADER DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      keys REQUEST requested_authorizations FOR y182i_rap_header RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      REQUEST requested_authorizations FOR y182i_rap_header RESULT result.

    METHODS ApprovedStatus FOR MODIFY
       keys FOR ACTION y182i_rap_header~ApprovedStatus RESULT result.

    METHODS copyCustomer FOR MODIFY
       keys FOR ACTION y182i_rap_header~copyCustomer.

    METHODS calculateTotalAmt FOR DETERMINE ON MODIFY
       keys FOR y182i_rap_header~calculateTotalAmt.

    METHODS validateCustomer FOR VALIDATE ON SAVE
       keys FOR y182i_rap_header~validateCustomer.

ENDCLASS.

CLASS lhc_Y182I_RAP_HEADER IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD ApprovedStatus.
    " Optional: You can read what the user entered in the popup dialog if needed
    LOOP AT keys INTO DATA(ls_key).
      DATA(lv_note) = ls_key-%param-confirmation_note.
    ENDLOOP.

    " 1. Update the Status field for the selected records
    MODIFY ENTITIES OF Y182I_RAP_HEADER IN LOCAL MODE
      ENTITY Y182I_RAP_HEADER
       UPDATE FIELDS ( status )
      WITH VALUE #( FOR key IN keys ( %tky   = key-%tky
                                     status = 'Approved' ) )
      FAILED failed
      REPORTED reported.

    " 2. Read back the updated entity instances
    READ ENTITIES OF Y182I_RAP_HEADER IN LOCAL MODE
      ENTITY Y182I_RAP_HEADER
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_header).

    " 3. Populate the result table for $self using your updated mapping
    result = VALUE #( FOR emp IN lt_header ( %tky   = emp-%tky
                                             %param = emp ) ).
  ENDMETHOD.

  METHOD copyCustomer.
    " 1. Read the original header records based on selected keys
    READ ENTITIES OF Y182I_RAP_HEADER IN LOCAL MODE
      ENTITY Y182I_RAP_HEADER
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_original_header).

    " 2. Read the associated items for these headers
    READ ENTITIES OF Y182I_RAP_HEADER IN LOCAL MODE
      ENTITY Y182I_RAP_HEADER BY \_Item
      ALL FIELDS WITH CORRESPONDING #( lt_original_header )
      RESULT DATA(lt_original_item).

    DATA lt_create_header TYPE TABLE FOR CREATE Y182I_RAP_HEADER.
    DATA lt_create_item   TYPE TABLE FOR CREATE Y182I_RAP_HEADER\_Item.

    " 3. Prepare Header payload
    LOOP AT lt_original_header ASSIGNING FIELD-SYMBOL(<ls_orig_h>).
      DATA(ls_key) = keys[ %tky = <ls_orig_h>-%tky ].

      DATA(lv_new_cid) = ls_key-%cid.

      APPEND VALUE #(
        %cid      = lv_new_cid
        %is_draft = ls_key-%is_draft
        SoNumber  = <ls_orig_h>-SoNumber && '-COPY'
        Customer  = <ls_orig_h>-Customer
        OrderDate = <ls_orig_h>-OrderDate
        Currency  = <ls_orig_h>-Currency
        Unit      = <ls_orig_h>-Unit
        UnitPrice = <ls_orig_h>-UnitPrice
        Quantity  = <ls_orig_h>-Quantity
        Status    = 'N'
      ) TO lt_create_header.

      " 4. Prepare Item payloads linked via %target and %cid_ref
      LOOP AT lt_original_item INTO DATA(ls_orig_i) WHERE SoId = <ls_orig_h>-SoId.
        APPEND VALUE #(
          %cid_ref      = lv_new_cid
          %target       = VALUE #( (
            %cid        = |ITEM_CID_{ sy-tabix }_{ cl_system_uuid=>create_uuid_x16_static( ) }`|
            %is_draft   = ls_key-%is_draft
            ItemNumber  = ls_orig_i-ItemNumber
            Material    = ls_orig_i-Material
            Unit        = ls_orig_i-Unit
            Quantity    = ls_orig_i-Quantity
            NetPrice    = ls_orig_i-NetPrice
          ) )
        ) TO lt_create_item.
      ENDLOOP.
    ENDLOOP.

    " 5. Modify entities to create both Header and Items together
    IF lt_create_header IS NOT INITIAL.
      MODIFY ENTITIES OF Y182I_RAP_HEADER IN LOCAL MODE
        ENTITY Y182I_RAP_HEADER
        CREATE FIELDS ( SoNumber Customer OrderDate Currency Unit UnitPrice Quantity Status )
        WITH lt_create_header
        ENTITY Y182I_RAP_HEADER
        CREATE BY \_Item
        FIELDS ( ItemNumber Material Unit Quantity NetPrice )
        WITH lt_create_item
        MAPPED DATA(lt_mapped)
        FAILED DATA(lt_failed)
        REPORTED DATA(lt_reported).

      " Pass back mapped, failed, and reported structures
      mapped-Y182I_RAP_HEADER   = CORRESPONDING #( lt_mapped-Y182I_RAP_HEADER ).
      failed-Y182I_RAP_HEADER   = CORRESPONDING #( lt_failed-Y182I_RAP_HEADER ).
      reported-Y182I_RAP_HEADER = CORRESPONDING #( lt_reported-Y182I_RAP_HEADER ).
    ENDIF.
  ENDMETHOD.

  METHOD calculateTotalAmt.
    " 1. Read the header instances for the modified keys
    READ ENTITIES OF Y182I_RAP_HEADER IN LOCAL MODE ENTITY Y182I_RAP_HEADER
      FIELDS ( Quantity UnitPrice ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_header).

    DATA lt_update TYPE TABLE FOR UPDATE Y182I_RAP_HEADER.

    " 2. Calculate TotalAmt (Quantity * UnitPrice) for each record
    LOOP AT lt_header INTO DATA(ls_header).
      DATA(lv_total) = ls_header-Quantity * ls_header-UnitPrice.

      APPEND VALUE #( %tky              = ls_header-%tky
                      TotalAmt          = lv_total
                      %control-TotalAmt = if_abap_behv=>mk-on ) TO lt_update.
    ENDLOOP.

    " 3. Modify the entity instances with the updated total amount
    MODIFY ENTITIES OF Y182I_RAP_HEADER IN LOCAL MODE
      ENTITY Y182I_RAP_HEADER
      UPDATE FIELDS ( TotalAmt ) WITH lt_update.
  ENDMETHOD.

  METHOD validateCustomer.
    READ ENTITIES OF Y182I_RAP_HEADER IN LOCAL MODE ENTITY Y182I_RAP_HEADER
      FIELDS ( Customer ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_header).

    LOOP AT lt_header INTO DATA(ls_header).
      IF ls_header-Customer IS INITIAL.
        INSERT VALUE #( %tky = ls_header-%tky ) INTO TABLE failed-Y182I_RAP_HEADER.
        APPEND VALUE #( %tky              = ls_header-%tky
                        %msg              = new_message_with_text(
                                               severity = if_abap_behv_message=>severity-error
                                               text     = 'Customer cannot be blank' )
                        %element-Customer = if_abap_behv=>mk-on ) TO reported-Y182I_RAP_HEADER.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
