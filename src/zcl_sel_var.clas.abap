CLASS zcl_sel_var DEFINITION PUBLIC ABSTRACT CREATE PROTECTED.
  PUBLIC SECTION.
    TYPES: tty_tvarvc TYPE TABLE OF tvarvc WITH EMPTY KEY.
    METHODS:
*      get_type ABSTRACT RETURNING VALUE(rv_type) TYPE tvarvc-type,
      set_type ABSTRACT,
      constructor IMPORTING iv_name TYPE tvarvc-name,
      delete_from_name RETURNING VALUE(rv_del_cnt) TYPE i RAISING zcx_data_access_error,
      enqueue_tvarv IMPORTING iv_lock_mode TYPE c RAISING zcx_enqueue_error,
      dequeue_tvarv,
      keep_old_values,
      get_old_content RETURNING VALUE(rt_cont) TYPE tty_tvarvc,
      promote_to_write_lock RAISING zcx_enqueue_error,
      read_current_values.
*** Flag, ob Variable neu (-> Keine Werte in der Tabelle tvarvc)
    DATA: mv_var_new TYPE abap_bool READ-ONLY.
*** Bisherige Wert(e) aus der Tabelle tvarc
    DATA: mt_tvarvc_old TYPE TABLE OF tvarvc READ-ONLY.
*** Konstanten für Lock-Type
    CLASS-DATA: gc_lock_excl    TYPE c LENGTH 1 VALUE 'E',
                gc_lock_shared  TYPE c LENGTH 1 VALUE 'S',
                gc_lock_opt     TYPE c LENGTH 1 VALUE 'O',
                gc_lock_promote TYPE c LENGTH 1 VALUE 'R'.

  PROTECTED SECTION.
*** "Schlüsseldaten" der Selektions-Varaible
    DATA: mv_name TYPE tvarvc-name,
          mv_type TYPE tvarvc-type.
*** Payload zum Speichern der Variablen in der Tabelle tvarvc
    DATA: mt_tvarvc TYPE TABLE OF tvarvc.
ENDCLASS.



CLASS ZCL_SEL_VAR IMPLEMENTATION.


  METHOD constructor.
    mv_name = iv_name.
  ENDMETHOD.


  METHOD delete_from_name.
    IF mv_name IS INITIAL.
      RAISE EXCEPTION TYPE zcx_data_access_error
        EXPORTING
          mv_table = 'tvarvc'
          mv_op    = 'delete'
          mv_info  = 'tvarv-name initial'.
    ENDIF.

    DELETE FROM tvarvc
          WHERE name = @mv_name
            AND type = @mv_type.

    rv_del_cnt = sy-dbcnt.
  ENDMETHOD.


  METHOD dequeue_tvarv.
    CALL FUNCTION 'DEQUEUE_EZTVARVC'
      EXPORTING
*       mode_tvarvc = 'E'              " Sperrmodus zur Tabelle TVARVC
*       mandt       = SY-MANDT         " 01. Enqueue Argument
        name = mv_name                " 02. Enqueue Argument
        type = mv_type                " 03. Enqueue Argument
*       numb =                  " 04. Enqueue Argument
*       x_name      = space            " Argument 02 mit Initialwert belegen?
*       x_type      = space            " Argument 03 mit Initialwert belegen?
*       x_numb      = space            " Argument 04 mit Initialwert belegen?
*       _scope      = '3'
*       _synchron   = space            " Synchron entsperren
*       _collect    = ' '              " Sperre zunächst nur Sammeln
      .
  ENDMETHOD.


  METHOD enqueue_tvarv.
*** Sperre wird mit Type gesetzt
    CALL FUNCTION 'ENQUEUE_EZTVARVC'
      EXPORTING
        mode_tvarvc    = iv_lock_mode
        name           = mv_name
        type           = mv_type
*       numb           =
*       x_name         = space
*       x_type         = space
*       x_numb         = space
*       _scope         = '2'
*       _wait          = space
*       _collect       = ' '
      EXCEPTIONS
        foreign_lock   = 1
        system_failure = 2
        OTHERS         = 3.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_enqueue_error
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDMETHOD.


  METHOD get_old_content.
    rt_cont = me->mt_tvarvc_old.
  ENDMETHOD.


  METHOD keep_old_values.
    INSERT LINES OF mt_tvarvc_old INTO mt_tvarvc INDEX 1.
  ENDMETHOD.


  METHOD promote_to_write_lock.
    me->enqueue_tvarv( gc_lock_promote ).
*    CATCH zcx_enqueue_error. " Fehler beim Setzen einer Sperre (SM12)
  ENDMETHOD.


  METHOD read_current_values.
    SELECT FROM tvarvc
         FIELDS *
          WHERE name = @mv_name
            AND type = @mv_type
     INTO TABLE @mt_tvarvc_old.

*** Flag für Sel-Var neu setzen
    IF lines( mt_tvarvc_old ) = 0.
      me->mv_var_new = abap_true.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
