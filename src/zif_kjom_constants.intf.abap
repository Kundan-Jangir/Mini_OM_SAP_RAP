INTERFACE zif_kjom_constants
  PUBLIC.

  CONSTANTS:
    BEGIN OF customer_status,
      active   TYPE c LENGTH 1 VALUE 'A',
      blocked  TYPE c LENGTH 1 VALUE 'B',
      inactive TYPE c LENGTH 1 VALUE 'I',
    END OF customer_status.

  CONSTANTS:
    BEGIN OF product_status,
      active       TYPE c LENGTH 1 VALUE 'A',
      blocked      TYPE c LENGTH 1 VALUE 'B',
      discontinued TYPE c LENGTH 1 VALUE 'D',
    END OF product_status.

  CONSTANTS:
    BEGIN OF sales_order_status,
      new                 TYPE c LENGTH 1 VALUE 'N',
      submitted           TYPE c LENGTH 1 VALUE 'S',
      approved            TYPE c LENGTH 1 VALUE 'A',
      rejected            TYPE c LENGTH 1 VALUE 'R',
      partially_delivered TYPE c LENGTH 1 VALUE 'P',
      delivered           TYPE c LENGTH 1 VALUE 'D',
      completed           TYPE c LENGTH 1 VALUE 'C',
      cancelled           TYPE c LENGTH 1 VALUE 'X',
    END OF sales_order_status.

  CONSTANTS:
    BEGIN OF delivery_status,
      new                 TYPE c LENGTH 1 VALUE 'N',
      ready               TYPE c LENGTH 1 VALUE 'R',
      partially_processed TYPE c LENGTH 1 VALUE 'P',
      goods_issued        TYPE c LENGTH 1 VALUE 'G',
      cancelled           TYPE c LENGTH 1 VALUE 'X',
    END OF delivery_status.

  CONSTANTS:
    BEGIN OF billing_status,
      new       TYPE c LENGTH 1 VALUE 'N',
      released  TYPE c LENGTH 1 VALUE 'R',
      cancelled TYPE c LENGTH 1 VALUE 'C',
    END OF billing_status.

  CONSTANTS:
    BEGIN OF document_category,
      sales_order TYPE c LENGTH 2 VALUE 'SO',
      delivery    TYPE c LENGTH 2 VALUE 'DL',
      billing     TYPE c LENGTH 2 VALUE 'BI',
    END OF document_category.

ENDINTERFACE.
