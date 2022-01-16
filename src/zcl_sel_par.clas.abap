CLASS zcl_sel_par DEFINITION
  PUBLIC
  INHERITING FROM zcl_sel_var
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS:
      set_value IMPORTING iv_value TYPE simple.
    METHODS:
      save_db RAISING zcx_data_access_error,
      set_type redefinition.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_SEL_PAR IMPLEMENTATION.


  METHOD save_db.
    MODIFY tvarvc FROM TABLE me->mt_tvarvc.

    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_data_access_error
        EXPORTING
          mv_table = 'tvarvc'
          mv_op    = 'insert'
          mv_info  = |{ mv_name } -Type: { me->mv_type }|.
    ENDIF.
  ENDMETHOD.


  METHOD set_type.
    me->mv_type = 'P'.
  ENDMETHOD.


  METHOD set_value.
*** die Komponente numb kann bei Selektions-Parametern immer auf den Wert 0000 gesetzt werden
*** (-> Es gibt nur einen Eintrag bei Parametern)
    me->mt_tvarvc = VALUE #( ( name = mv_name type = me->mv_type sign = 'I' opti = 'EQ' low = iv_value numb = '0000' ) ).
  ENDMETHOD.
ENDCLASS.
