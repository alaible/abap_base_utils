class ZCX_DATA_ACCESS_ERROR definition
  public
  inheriting from CX_STATIC_CHECK
  create public .

public section.

  interfaces IF_T100_DYN_MSG .
  interfaces IF_T100_MESSAGE .

  data MV_TABLE type SYMSGV .
  data MV_OP type SYMSGV .
  data MV_INFO type SYMSGV .

  methods CONSTRUCTOR
    importing
      !TEXTID like IF_T100_MESSAGE=>T100KEY optional
      !PREVIOUS like PREVIOUS optional
      !MV_TABLE type SYMSGV optional
      !MV_OP type SYMSGV optional
      !MV_INFO type SYMSGV optional .
protected section.
private section.
ENDCLASS.



CLASS ZCX_DATA_ACCESS_ERROR IMPLEMENTATION.


  method CONSTRUCTOR.
CALL METHOD SUPER->CONSTRUCTOR
EXPORTING
PREVIOUS = PREVIOUS
.
me->MV_TABLE = MV_TABLE .
me->MV_OP = MV_OP .
me->MV_INFO = MV_INFO .
clear me->textid.
if textid is initial.
  IF_T100_MESSAGE~T100KEY = IF_T100_MESSAGE=>DEFAULT_TEXTID.
else.
  IF_T100_MESSAGE~T100KEY = TEXTID.
endif.
  endmethod.
ENDCLASS.
