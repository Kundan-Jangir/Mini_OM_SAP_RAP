CLASS lhc_product DEFINITION
  INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS get_global_authorizations
      FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations
      FOR Product
      RESULT result.

    METHODS setInitialStatus
      FOR DETERMINE ON MODIFY
      IMPORTING keys
      FOR Product~setInitialStatus.

    METHODS normalizeProductData
      FOR DETERMINE ON MODIFY
      IMPORTING keys
      FOR Product~normalizeProductData.

    METHODS validateProduct
      FOR VALIDATE ON SAVE
      IMPORTING keys
      FOR Product~validateProduct.

    METHODS validateProductName
      FOR VALIDATE ON SAVE
      IMPORTING keys
      FOR Product~validateProductName.

    METHODS validatePrice
      FOR VALIDATE ON SAVE
      IMPORTING keys
      FOR Product~validatePrice.

    METHODS validateStock
      FOR VALIDATE ON SAVE
      IMPORTING keys
      FOR Product~validateStock.

    METHODS validateTaxPercentage
      FOR VALIDATE ON SAVE
      IMPORTING keys
      FOR Product~validateTaxPercentage.

    METHODS validateBaseUnit
      FOR VALIDATE ON SAVE
      IMPORTING keys
      FOR Product~validateBaseUnit.

    METHODS validatePlant
      FOR VALIDATE ON SAVE
      IMPORTING keys
      FOR Product~validatePlant.

ENDCLASS.


CLASS lhc_product IMPLEMENTATION.

  METHOD get_global_authorizations.

    IF requested_authorizations-%create = if_abap_behv=>mk-on.
      result-%create = if_abap_behv=>auth-allowed.
    ENDIF.

    IF requested_authorizations-%update = if_abap_behv=>mk-on.
      result-%update = if_abap_behv=>auth-allowed.
    ENDIF.

    IF requested_authorizations-%delete = if_abap_behv=>mk-on.
      result-%delete = if_abap_behv=>auth-allowed.
    ENDIF.

  ENDMETHOD.


  METHOD setInitialStatus.

    READ ENTITIES OF zi_kjom_product IN LOCAL MODE
      ENTITY Product
        FIELDS ( Status )
        WITH CORRESPONDING #( keys )
      RESULT DATA(products).

    DELETE products
      WHERE Status IS NOT INITIAL.

    CHECK products IS NOT INITIAL.

    MODIFY ENTITIES OF zi_kjom_product IN LOCAL MODE
      ENTITY Product
        UPDATE FIELDS ( Status )
        WITH VALUE #(
          FOR product IN products
          (
            %tky   = product-%tky
            Status = zif_kjom_constants=>product_status-active
          )
        )
      REPORTED DATA(reported_update).

    reported-product =
      CORRESPONDING #( DEEP reported_update-product ).

  ENDMETHOD.


  METHOD normalizeProductData.

    READ ENTITIES OF zi_kjom_product IN LOCAL MODE
      ENTITY Product
        FIELDS (
          Product
          ProductName
        )
        WITH CORRESPONDING #( keys )
      RESULT DATA(products).

    DATA updates TYPE TABLE FOR UPDATE zi_kjom_product.

    LOOP AT products INTO DATA(product).

      DATA normalized_product TYPE c LENGTH 18.
      DATA normalized_name    TYPE c LENGTH 80.

      normalized_product = product-Product.
      normalized_name    = product-ProductName.

      TRANSLATE normalized_product TO UPPER CASE.
      CONDENSE normalized_product NO-GAPS.
      CONDENSE normalized_name.

      IF normalized_product = product-Product
         AND normalized_name = product-ProductName.
        CONTINUE.
      ENDIF.

      APPEND VALUE #(
        %tky = product-%tky

        Product = normalized_product
        %control-Product =
          COND #(
            WHEN normalized_product <> product-Product
            THEN if_abap_behv=>mk-on
            ELSE if_abap_behv=>mk-off )

        ProductName = normalized_name
        %control-ProductName =
          COND #(
            WHEN normalized_name <> product-ProductName
            THEN if_abap_behv=>mk-on
            ELSE if_abap_behv=>mk-off )
      ) TO updates.

    ENDLOOP.

    CHECK updates IS NOT INITIAL.

    MODIFY ENTITIES OF zi_kjom_product IN LOCAL MODE
      ENTITY Product
        UPDATE
        FROM updates
      REPORTED DATA(reported_update).

    reported-product =
      CORRESPONDING #( DEEP reported_update-product ).

  ENDMETHOD.


  METHOD validateProduct.

    READ ENTITIES OF zi_kjom_product IN LOCAL MODE
      ENTITY Product
        FIELDS (
          ProductUUID
          Product
        )
        WITH CORRESPONDING #( keys )
      RESULT DATA(products).

    LOOP AT products INTO DATA(product).

      APPEND VALUE #(
        %tky        = product-%tky
        %state_area = 'VALIDATE_PRODUCT'
      ) TO reported-product.

      IF product-Product IS INITIAL.

        APPEND VALUE #(
          %tky = product-%tky
        ) TO failed-product.

        APPEND VALUE #(
          %tky             = product-%tky
          %state_area      = 'VALIDATE_PRODUCT'
          %element-Product = if_abap_behv=>mk-on
          %msg             = new_message(
                               id       = 'ZKJ_OM_MSG'
                               number   = '201'
                               severity =
                                 if_abap_behv_message=>severity-error )
        ) TO reported-product.

        CONTINUE.

      ENDIF.

      SELECT SINGLE product_uuid
        FROM zkj_om_product
        WHERE product_id   = @product-Product
          AND product_uuid <> @product-ProductUUID
        INTO @DATA(existing_product_uuid).

      IF sy-subrc = 0.

        APPEND VALUE #(
          %tky = product-%tky
        ) TO failed-product.

        APPEND VALUE #(
          %tky             = product-%tky
          %state_area      = 'VALIDATE_PRODUCT'
          %element-Product = if_abap_behv=>mk-on
          %msg             = new_message(
                               id       = 'ZKJ_OM_MSG'
                               number   = '202'
                               severity =
                                 if_abap_behv_message=>severity-error
                               v1       = product-Product )
        ) TO reported-product.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD validateProductName.

    READ ENTITIES OF zi_kjom_product IN LOCAL MODE
      ENTITY Product
        FIELDS ( ProductName )
        WITH CORRESPONDING #( keys )
      RESULT DATA(products).

    LOOP AT products INTO DATA(product).

      APPEND VALUE #(
        %tky        = product-%tky
        %state_area = 'VALIDATE_PRODUCT_NAME'
      ) TO reported-product.

      IF product-ProductName IS INITIAL.

        APPEND VALUE #(
          %tky = product-%tky
        ) TO failed-product.

        APPEND VALUE #(
          %tky                 = product-%tky
          %state_area          = 'VALIDATE_PRODUCT_NAME'
          %element-ProductName = if_abap_behv=>mk-on
          %msg                 = new_message(
                                   id       = 'ZKJ_OM_MSG'
                                   number   = '203'
                                   severity =
                                     if_abap_behv_message=>severity-error )
        ) TO reported-product.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD validatePrice.

    READ ENTITIES OF zi_kjom_product IN LOCAL MODE
      ENTITY Product
        FIELDS (
          StandardPrice
          Currency
        )
        WITH CORRESPONDING #( keys )
      RESULT DATA(products).

    LOOP AT products INTO DATA(product).

      APPEND VALUE #(
        %tky        = product-%tky
        %state_area = 'VALIDATE_PRICE'
      ) TO reported-product.

      IF product-StandardPrice < 0.

        APPEND VALUE #(
          %tky = product-%tky
        ) TO failed-product.

        APPEND VALUE #(
          %tky                   = product-%tky
          %state_area            = 'VALIDATE_PRICE'
          %element-StandardPrice = if_abap_behv=>mk-on
          %msg                   = new_message(
                                     id       = 'ZKJ_OM_MSG'
                                     number   = '204'
                                     severity =
                                       if_abap_behv_message=>severity-error )
        ) TO reported-product.

      ENDIF.

      IF product-StandardPrice IS NOT INITIAL
         AND product-Currency IS INITIAL.

        APPEND VALUE #(
          %tky = product-%tky
        ) TO failed-product.

        APPEND VALUE #(
          %tky              = product-%tky
          %state_area       = 'VALIDATE_PRICE'
          %element-Currency = if_abap_behv=>mk-on
          %msg              = new_message(
                                id       = 'ZKJ_OM_MSG'
                                number   = '205'
                                severity =
                                  if_abap_behv_message=>severity-error )
        ) TO reported-product.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD validateStock.

    READ ENTITIES OF zi_kjom_product IN LOCAL MODE
      ENTITY Product
        FIELDS (
          AvailableStock
          ReorderLevel
        )
        WITH CORRESPONDING #( keys )
      RESULT DATA(products).

    LOOP AT products INTO DATA(product).

      APPEND VALUE #(
        %tky        = product-%tky
        %state_area = 'VALIDATE_STOCK'
      ) TO reported-product.

      IF product-AvailableStock < 0.

        APPEND VALUE #(
          %tky = product-%tky
        ) TO failed-product.

        APPEND VALUE #(
          %tky                    = product-%tky
          %state_area             = 'VALIDATE_STOCK'
          %element-AvailableStock = if_abap_behv=>mk-on
          %msg                    = new_message(
                                      id       = 'ZKJ_OM_MSG'
                                      number   = '207'
                                      severity =
                                        if_abap_behv_message=>severity-error )
        ) TO reported-product.

      ENDIF.

      IF product-ReorderLevel < 0.

        APPEND VALUE #(
          %tky = product-%tky
        ) TO failed-product.

        APPEND VALUE #(
          %tky                 = product-%tky
          %state_area          = 'VALIDATE_STOCK'
          %element-ReorderLevel = if_abap_behv=>mk-on
          %msg                 = new_message(
                                   id       = 'ZKJ_OM_MSG'
                                   number   = '208'
                                   severity =
                                     if_abap_behv_message=>severity-error )
        ) TO reported-product.

      ENDIF.

      IF product-AvailableStock >= 0
         AND product-ReorderLevel >= 0
         AND product-AvailableStock <= product-ReorderLevel.

        APPEND VALUE #(
          %tky                    = product-%tky
          %state_area             = 'VALIDATE_STOCK'
          %element-AvailableStock = if_abap_behv=>mk-on
          %msg                    = new_message(
                                      id       = 'ZKJ_OM_MSG'
                                      number   = '212'
                                      severity =
                                        if_abap_behv_message=>severity-warning )
        ) TO reported-product.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD validateTaxPercentage.

    READ ENTITIES OF zi_kjom_product IN LOCAL MODE
      ENTITY Product
        FIELDS ( TaxPercentage )
        WITH CORRESPONDING #( keys )
      RESULT DATA(products).

    LOOP AT products INTO DATA(product).

      APPEND VALUE #(
        %tky        = product-%tky
        %state_area = 'VALIDATE_TAX'
      ) TO reported-product.

      IF product-TaxPercentage < 0
         OR product-TaxPercentage > 100.

        APPEND VALUE #(
          %tky = product-%tky
        ) TO failed-product.

        APPEND VALUE #(
          %tky                   = product-%tky
          %state_area            = 'VALIDATE_TAX'
          %element-TaxPercentage = if_abap_behv=>mk-on
          %msg                   = new_message(
                                     id       = 'ZKJ_OM_MSG'
                                     number   = '209'
                                     severity =
                                       if_abap_behv_message=>severity-error )
        ) TO reported-product.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD validateBaseUnit.

    READ ENTITIES OF zi_kjom_product IN LOCAL MODE
      ENTITY Product
        FIELDS ( BaseUnit )
        WITH CORRESPONDING #( keys )
      RESULT DATA(products).

    LOOP AT products INTO DATA(product).

      APPEND VALUE #(
        %tky        = product-%tky
        %state_area = 'VALIDATE_BASE_UNIT'
      ) TO reported-product.

      IF product-BaseUnit IS INITIAL.

        APPEND VALUE #(
          %tky = product-%tky
        ) TO failed-product.

        APPEND VALUE #(
          %tky              = product-%tky
          %state_area       = 'VALIDATE_BASE_UNIT'
          %element-BaseUnit = if_abap_behv=>mk-on
          %msg              = new_message(
                                id       = 'ZKJ_OM_MSG'
                                number   = '206'
                                severity =
                                  if_abap_behv_message=>severity-error )
        ) TO reported-product.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD validatePlant.

    READ ENTITIES OF zi_kjom_product IN LOCAL MODE
      ENTITY Product
        FIELDS ( DefaultPlant )
        WITH CORRESPONDING #( keys )
      RESULT DATA(products).

    LOOP AT products INTO DATA(product).

      APPEND VALUE #(
        %tky        = product-%tky
        %state_area = 'VALIDATE_PLANT'
      ) TO reported-product.

      IF product-DefaultPlant IS INITIAL.

        APPEND VALUE #(
          %tky = product-%tky
        ) TO failed-product.

        APPEND VALUE #(
          %tky                  = product-%tky
          %state_area           = 'VALIDATE_PLANT'
          %element-DefaultPlant = if_abap_behv=>mk-on
          %msg                  = new_message(
                                    id       = 'ZKJ_OM_MSG'
                                    number   = '210'
                                    severity =
                                      if_abap_behv_message=>severity-error )
        ) TO reported-product.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
