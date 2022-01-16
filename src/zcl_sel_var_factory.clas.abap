CLASS zcl_sel_var_factory DEFINITION PUBLIC CREATE PRIVATE.
  PUBLIC SECTION.
    CLASS-METHODS:
*** Factory-Method für Selektions-Optionen
      create_selopt_keep_old IMPORTING iv_name TYPE tvarvc-name RETURNING VALUE(ro_sel_opt) TYPE REF TO zcl_sel_opt,
      create_selopt_with_o_lock IMPORTING iv_name TYPE tvarvc-name RETURNING VALUE(ro_sel_opt) TYPE REF TO zcl_sel_opt RAISING zcx_enqueue_error,
      create_selopt_with_e_lock IMPORTING iv_name TYPE tvarvc-name RETURNING VALUE(ro_sel_opt) TYPE REF TO zcl_sel_opt RAISING zcx_enqueue_error.
    CLASS-METHODS:
*** Factory-Methoden für Selektions-Parameter
      create_selpar_with_o_lock IMPORTING iv_name TYPE tvarvc-name RETURNING VALUE(ro_sel_par) TYPE REF TO zcl_sel_par RAISING zcx_enqueue_error,
      create_selpar_with_e_lock IMPORTING iv_name TYPE tvarvc-name RETURNING VALUE(ro_sel_par) TYPE REF TO zcl_sel_par RAISING zcx_enqueue_error.
*        create_selpar IMPORTING iv_name type tvarvc-name RETURNING VALUE(ro_sel_var) type ref to zcl_sel_var.
ENDCLASS.



CLASS ZCL_SEL_VAR_FACTORY IMPLEMENTATION.


  METHOD create_selopt_keep_old.
    ro_sel_opt = NEW #( iv_name ).
    ro_sel_opt->set_type( ).
*** Aktuelle Werte aus der Tabelle tvarvc lesen
    ro_sel_opt->read_current_values( ).
    ro_sel_opt->keep_old_values( ).
  ENDMETHOD.


  METHOD create_selopt_with_e_lock.
    ro_sel_opt = NEW #( iv_name ).
    ro_sel_opt->set_type( ).
    ro_sel_opt->enqueue_tvarv( zcl_sel_var=>gc_lock_excl ).
*    CATCH zcx_enqueue_error. " Fehler beim Setzen einer Sperre (SM12)
*** Aktuelle Werte aus der Tabelle tvarvc lesen
    ro_sel_opt->read_current_values( ).
  ENDMETHOD.


  METHOD create_selopt_with_o_lock.
    ro_sel_opt = NEW #( iv_name ).
    ro_sel_opt->set_type( ).
    ro_sel_opt->enqueue_tvarv( zcl_sel_var=>gc_lock_opt ).
*    CATCH zcx_enqueue_error. " Fehler beim Setzen einer Sperre (SM12)
*** Aktuelle Werte aus der Tabelle tvarvc lesen
    ro_sel_opt->read_current_values( ).
  ENDMETHOD.


  METHOD create_selpar_with_e_lock.
    ro_sel_par = NEW #( iv_name ).
    ro_sel_par->set_type( ).
    ro_sel_par->enqueue_tvarv( zcl_sel_var=>gc_lock_excl ).
*    CATCH zcx_enqueue_error. " Fehler beim Setzen einer Sperre (SM12)
    ro_sel_par->read_current_values( ).
  ENDMETHOD.


  METHOD create_selpar_with_o_lock.
    ro_sel_par = NEW #( iv_name ).
    ro_sel_par->set_type( ).
    ro_sel_par->enqueue_tvarv( zcl_sel_var=>gc_lock_opt ).
*    CATCH zcx_enqueue_error. " Fehler beim Setzen einer Sperre (SM12)
    ro_sel_par->read_current_values( ).
  ENDMETHOD.
ENDCLASS.
