class ZCL_LOG_UTILS definition
  public
  create public .

*"* public components of class ZCL_LOG_UTILS
*"* do not include other source files here!!!
public section.

  class-methods get_message_text
    importing
      !is_message type BDCMSGCOLL
    returning
      value(ev_text) type STRING .
  methods CONSTRUCTOR
    importing
      !iv_title type SYTITLE optional .
  methods ADD_CALL_TRANSACTION_MESSAGES
    importing
      !it_MESSAGES type TAB_BDCMSGCOLL .
  methods DISPLAY .
  methods ADD_MESSAGE
    importing
      !iv_class type SYMSGID default sy-msgid
      !iv_number type SYMSGNO default sy-msgno
      !iv_type type SYMSGTY default sy-msgty
      !iv_parameter_1 type ANY  default sy-msgv1
      !PVI_PARAMETRO_2 type ANY default sy-msgv1
      !PVI_PARAMETRO_3 type ANY default sy-msgv1
      !PVI_PARAMETRO_4 type ANY default sy-msgv1.
  class-methods get_last_message_text
    importing
      !it_messages type TAB_BDCMSGCOLL
    returning
      value(ev_text) type STRING .
  methods ADD_LAST_CALL_TRANS_MESSAGE
    importing
      !it_messages type TAB_BDCMSGCOLL .
  type-pools ABAP .
  class-methods LAST_CALL_TRANS_MESSAGE_IS
    importing
      !it_MESSAGES type TAB_BDCMSGCOLL
      !iv_MSGID type BDCMSGCOLL-MSGID
      !iv_MSGNR type BDCMSGCOLL-MSGNR
    returning
      value(ev_IS) type ABAP_BOOL .
  class-methods GET_LAST_CALL_TRANS_MESSAGE
    importing
      !it_messages type TAB_BDCMSGCOLL
    returning
      value(es_messages) type BDCMSGCOLL .
  methods EMPTY
    returning
      value(ev_EMPTY) type ABAP_BOOL .
  class-methods MOSTRAR_RESULTADOS_BAPI
    importing
      !PTI_RESULTADOS type BAPIRET2_T .
  class-methods get_last_message_text_BAPI
    importing
      !it_messages type BAPIRET2_T
    returning
      value(ev_text) type STRING .
  class-methods get_message_text_BAPI
    importing
      !is_message type BAPIRET2
    returning
      value(ev_text) type STRING .
*"* protected components of class ZCL_LOG_UTILS
*"* do not include other source files here!!!
protected section.

  data LV_LOG type ref to CL_CFA_MESSAGE_HANDLER .
*"* private components of class ZCL_LOG_UTILS
*"* do not include other source files here!!!
private section.

  data LV_EMPTY type ABAP_BOOL .

ENDCLASS.

CLASS ZCL_LOG_UTILS IMPLEMENTATION.

method ADD_CALL_TRANSACTION_MESSAGES.

  FIELD-SYMBOLS:
    <LE_MENSAJE> TYPE BDCMSGCOLL.

  DATA:
    LV_MSGNR TYPE SYMSGNO.

  LOOP AT it_MESSAGES ASSIGNING <LE_MENSAJE>.

    LV_MSGNR = <LE_MENSAJE>-MSGNR.

    ME->ADD_MESSAGE(
      iv_class = <LE_MENSAJE>-MSGID
      iv_number = LV_MSGNR
      iv_type = <LE_MENSAJE>-MSGTYP
      iv_parameter_1 = <LE_MENSAJE>-MSGV1
      PVI_PARAMETRO_2 = <LE_MENSAJE>-MSGV2
      PVI_PARAMETRO_3 = <LE_MENSAJE>-MSGV3
      PVI_PARAMETRO_4 = <LE_MENSAJE>-MSGV4
      ).

  ENDLOOP.

  IF SY-SUBRC EQ 0.
    ME->LV_EMPTY = ABAP_FALSE.
  ENDIF.

endmethod.


method CONSTRUCTOR.

  CREATE OBJECT ME->LV_LOG
    EXPORTING
      I_TITLE = iv_title
      I_SAVE_MESSAGES = SPACE.

  ME->LV_EMPTY = ABAP_TRUE.

endmethod.


method DISPLAY.

  data:
    LE_RESULTADO TYPE BAL_S_EXCM.

  CALL METHOD ME->LV_LOG->DISPLAY
    IMPORTING
      E_COMMAND = LE_RESULTADO.

endmethod.


method ADD_MESSAGE.

  ME->LV_LOG->ADD_MESSAGE(
    I_MSGCLASS = iv_class
    I_MSGNO = iv_number
    I_SEVERITY = iv_type
    I_VAR1 = iv_parameter_1
    I_VAR2 = PVI_PARAMETRO_2
    I_VAR3 = PVI_PARAMETRO_3
    I_VAR4 = PVI_PARAMETRO_4
    ).

  ME->LV_EMPTY = ABAP_FALSE.

endmethod.


method get_last_message_text.

  FIELD-SYMBOLS:
    <LE_MENSAJE> TYPE BDCMSGCOLL.

  DATA:
    LV_ULTIMA_LINEA TYPE I.

  DESCRIBE TABLE it_messages LINES LV_ULTIMA_LINEA.

  IF LV_ULTIMA_LINEA GT 0.

    READ TABLE it_messages
    ASSIGNING <LE_MENSAJE>
    INDEX LV_ULTIMA_LINEA.

    ev_text = get_message_text( <LE_MENSAJE> ).

  ENDIF.

endmethod.


METHOD get_message_text.

  MESSAGE ID is_message-MSGID TYPE 'S' NUMBER is_message-MSGNR
  INTO ev_text
  WITH is_message-MSGV1 is_message-MSGV2 is_message-MSGV3 is_message-MSGV4.

ENDMETHOD.


method ADD_LAST_CALL_TRANS_MESSAGE.

  FIELD-SYMBOLS:
    <LE_MENSAJE> TYPE BDCMSGCOLL.

  DATA:
    LV_ULTIMA_LINEA TYPE I,
    LT_MENSAJES TYPE TAB_BDCMSGCOLL.

  DESCRIBE TABLE it_messages LINES LV_ULTIMA_LINEA.

  IF LV_ULTIMA_LINEA GT 0.

    READ TABLE it_messages
    ASSIGNING <LE_MENSAJE>
    INDEX LV_ULTIMA_LINEA.

    APPEND <LE_MENSAJE> TO LT_MENSAJES.

    ME->ADD_CALL_TRANSACTION_MESSAGES( LT_MENSAJES ).

    ME->LV_EMPTY = ABAP_FALSE.

  ENDIF.

endmethod.


method LAST_CALL_TRANS_MESSAGE_IS.

  DATA:
    LE_MENSAJE TYPE BDCMSGCOLL.

  CALL METHOD ZCL_LOG_UTILS=>GET_LAST_CALL_TRANS_MESSAGE
    EXPORTING
      it_messages = it_MESSAGES
    RECEIVING
      es_messages  = LE_MENSAJE
      .

  IF LE_MENSAJE-MSGID EQ iv_MSGID AND LE_MENSAJE-MSGNR EQ iv_MSGNR.
    ev_IS = ABAP_TRUE.
  ELSE.
    ev_IS = ABAP_FALSE.
  ENDIF.

endmethod.


method GET_LAST_CALL_TRANS_MESSAGE.

  DATA:
    LV_ULTIMA_LINEA TYPE I.

  DESCRIBE TABLE it_messages LINES LV_ULTIMA_LINEA.

  IF LV_ULTIMA_LINEA GT 0.

    READ TABLE it_messages
    INTO es_messages
    INDEX LV_ULTIMA_LINEA.

  ENDIF.

endmethod.


method EMPTY.

  ev_EMPTY = ME->LV_EMPTY.

endmethod.


method MOSTRAR_RESULTADOS_BAPI.

  FIELD-SYMBOLS:
    <LE_RESULTADO> TYPE BAPIRET2.

  DATA:
    LV_LOG TYPE REF TO ZCL_LOG_UTILS.

  LOOP AT PTI_RESULTADOS ASSIGNING <LE_RESULTADO>.

    AT FIRST.

      CREATE OBJECT LV_LOG
        EXPORTING
          iv_title = 'Resultados llamada BAPI'.

    ENDAT.

    CALL METHOD LV_LOG->ADD_MESSAGE
      EXPORTING
        iv_class       = <LE_RESULTADO>-ID
        iv_number      = <LE_RESULTADO>-NUMBER
        iv_type        = <LE_RESULTADO>-TYPE
        iv_parameter_1 = <LE_RESULTADO>-MESSAGE_V1
        PVI_PARAMETRO_2 = <LE_RESULTADO>-MESSAGE_V2
        PVI_PARAMETRO_3 = <LE_RESULTADO>-MESSAGE_V3
        PVI_PARAMETRO_4 = <LE_RESULTADO>-MESSAGE_V4
        .

    AT LAST.

      LV_LOG->DISPLAY( ).

    ENDAT.

  ENDLOOP.

endmethod.


METHOD get_last_message_text_BAPI .

  FIELD-SYMBOLS:
    <LE_MENSAJE> TYPE BAPIRET2.

  DATA:
    LV_ULTIMA_LINEA TYPE I.

  DESCRIBE TABLE it_messages LINES LV_ULTIMA_LINEA.

  IF LV_ULTIMA_LINEA GT 0.

    READ TABLE it_messages
    ASSIGNING <LE_MENSAJE>
    INDEX LV_ULTIMA_LINEA.

    ev_text = get_message_text_BAPI( <LE_MENSAJE> ).

  ENDIF.

ENDMETHOD.


METHOD get_message_text_BAPI .

  ev_text = is_message-MESSAGE.

ENDMETHOD.


ENDCLASS.


