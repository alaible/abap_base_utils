class ZCX_NO_ENTRY_FOUND definition
  public
  inheriting from CX_STATIC_CHECK
  create public .

public section.

  interfaces IF_T100_DYN_MSG .
  interfaces IF_T100_MESSAGE .

  data MV_OBJECT type SYMSGV .
  data MV_KEY1 type SYMSGV .
  data MV_KEY2 type SYMSGV .

  methods CONSTRUCTOR
    importing
      !TEXTID like IF_T100_MESSAGE=>T100KEY optional
      !PREVIOUS like PREVIOUS optional
      !MV_OBJECT type SYMSGV optional
      !MV_KEY1 type SYMSGV optional
      !MV_KEY2 type SYMSGV optional .
protected section.
private section.
ENDCLASS.



CLASS ZCX_NO_ENTRY_FOUND IMPLEMENTATION.


  method CONSTRUCTOR.
CALL METHOD SUPER->CONSTRUCTOR
EXPORTING
PREVIOUS = PREVIOUS
.
me->MV_OBJECT = MV_OBJECT .
me->MV_KEY1 = MV_KEY1 .
me->MV_KEY2 = MV_KEY2 .
clear me->textid.
if textid is initial.
  IF_T100_MESSAGE~T100KEY = IF_T100_MESSAGE=>DEFAULT_TEXTID.
else.
  IF_T100_MESSAGE~T100KEY = TEXTID.
endif.
  endmethod.
ENDCLASS.
