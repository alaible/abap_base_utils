CLASS zcl_sel_opt DEFINITION
  PUBLIC
  INHERITING FROM zcl_sel_var
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS:
*      get_type REDEFINITION,
      set_type REDEFINITION,
*      append_new RAISING zcx_vs_data_access_error,
      save_values RAISING zcx_data_access_error,
      prepare_save,
      rem_value_incl IMPORTING iv_value TYPE simple RAISING zcx_no_entry_found,
      add_value_incl IMPORTING iv_value TYPE simple,
      add_value_incl_no_dupl IMPORTING iv_value TYPE simple,
      rem_value_excl IMPORTING iv_value TYPE simple RAISING zcx_no_entry_found,
      add_value_excl IMPORTING iv_value TYPE simple,
      add_value_excl_no_dupl IMPORTING iv_value TYPE simple.
ENDCLASS.



CLASS ZCL_SEL_OPT IMPLEMENTATION.


  METHOD add_value_excl.
    me->mt_tvarvc = VALUE #( BASE me->mt_tvarvc ( name = mv_name type = me->mv_type sign = 'E' opti = 'EQ' low = iv_value ) ).
  ENDMETHOD.


  METHOD add_value_excl_no_dupl.
*** Keine doppelten Einträge in der Tabelle
    IF line_exists( mt_tvarvc[ name = mv_name type = me->mv_type sign = 'E' opti = 'EQ' low = iv_value ] ).
*      OR line_exists( mt_tvarvc_old[ name = mv_name type = me->mv_type sign = 'E' opti = 'EQ' low = iv_value ] ).
      RETURN.
    ENDIF.
    me->add_value_excl( iv_value ).
  ENDMETHOD.


  METHOD add_value_incl.
    me->mt_tvarvc = VALUE #( BASE me->mt_tvarvc ( name = mv_name type = me->mv_type sign = 'I' opti = 'EQ' low = iv_value ) ).
  ENDMETHOD.


  METHOD add_value_incl_no_dupl.
    IF line_exists( mt_tvarvc[ name = mv_name type = me->mv_type sign = 'E' opti = 'EQ' low = iv_value ] ).
*      OR line_exists( mt_tvarvc_old[ low = iv_value ] ).
      RETURN.
    ENDIF.
    me->add_value_incl( iv_value ).
  ENDMETHOD.


  METHOD prepare_save.
    DATA: lv_cnt TYPE i VALUE 0.
    LOOP AT me->mt_tvarvc ASSIGNING FIELD-SYMBOL(<tvarvc>).
      <tvarvc>-numb = CONV #( |{ lv_cnt WIDTH = 4 PAD = '0' ALIGN = RIGHT }| ).
      lv_cnt = lv_cnt + 1.
    ENDLOOP.
  ENDMETHOD.


  METHOD rem_value_excl.
    IF line_exists( me->mt_tvarvc[ name = mv_name type = me->mv_type sign = 'E' opti = 'EQ' low = iv_value ] ).
      DELETE me->mt_tvarvc WHERE name = mv_name AND type = me->mv_type AND sign = 'E' AND opti = 'EQ' AND low = iv_value.
    ELSE.
      RAISE EXCEPTION TYPE zcx_no_entry_found
        EXPORTING
          mv_object = 'mt_tvarvc_old'
          mv_key1   = |{ mv_name }-- type = { me->mv_type }|
          mv_key2   = |excl. par|.
    ENDIF.
  ENDMETHOD.


  METHOD rem_value_incl.
    IF line_exists( me->mt_tvarvc[ name = mv_name type = me->mv_type sign = 'I' opti = 'EQ' low = iv_value ] ).
      DELETE me->mt_tvarvc WHERE name = mv_name AND type = me->mv_type AND sign = 'I' AND opti = 'EQ' AND low = iv_value.
    ELSE.
      RAISE EXCEPTION TYPE zcx_no_entry_found
        EXPORTING
          mv_object = 'mt_tvarvc_old'
          mv_key1   = |{ mv_name }-- type = { me->mv_type }|
          mv_key2   = |excl. par|.
    ENDIF.
  ENDMETHOD.


  METHOD save_values.
*** Hochzählen der laufenden Nummer
    me->prepare_save( ).

*** Zuerst Löschen, aber nur wenn bereits Einträge vorhanden
    IF me->mv_var_new EQ abap_false.
      me->delete_from_name( ).
    ENDIF.

*** Insert über Tabellenwerte
    INSERT tvarvc FROM TABLE mt_tvarvc.

    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_data_access_error
        EXPORTING
          mv_table = 'tvarvc'
          mv_op    = 'insert'
          mv_info  = |{ mv_name } -Type: { me->mv_type }|.
    ENDIF.

*    CATCH zcx_vs_data_access_error. " Fehler beim DB-Zugriff (i/u/d)
  ENDMETHOD.


  METHOD set_type.
    me->mv_type = 'S'.
  ENDMETHOD.
ENDCLASS.
