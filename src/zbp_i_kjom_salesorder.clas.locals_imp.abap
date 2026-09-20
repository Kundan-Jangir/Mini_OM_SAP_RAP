CLASS lhc_salesorder DEFINITION
  INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS setInitialOrderData
      FOR DETERMINE ON MODIFY
      IMPORTING keys
                  FOR SalesOrder~setInitialOrderData.

    METHODS deriveCustomerDefaults
      FOR DETERMINE ON MODIFY
      IMPORTING keys
                  FOR SalesOrder~deriveCustomerDefaults.

    METHODS validateCustomer
      FOR VALIDATE ON SAVE
      IMPORTING keys
                  FOR SalesOrder~validateCustomer.

    METHODS validateOrderDates
      FOR VALIDATE ON SAVE
      IMPORTING keys
                  FOR SalesOrder~validateOrderDates.

    METHODS validateOrderType
      FOR VALIDATE ON SAVE
      IMPORTING keys
                  FOR SalesOrder~validateOrderType.

    METHODS validateCurrency
      FOR VALIDATE ON SAVE
      IMPORTING keys
                  FOR SalesOrder~validateCurrency.

    METHODS assignSalesOrderID
      FOR DETERMINE ON MODIFY
      IMPORTING keys
                  FOR SalesOrder~assignSalesOrderID.

    METHODS validateItems
      FOR VALIDATE ON SAVE
      IMPORTING keys
                  FOR SalesOrder~validateItems.

ENDCLASS.

CLASS lhc_salesorder IMPLEMENTATION.

  METHOD setInitialOrderData.

    READ ENTITIES OF zi_kjom_salesorder IN LOCAL MODE
      ENTITY SalesOrder
        FIELDS (
          SalesOrderType
          OrderDate
          OverallStatus
        )
        WITH CORRESPONDING #( keys )
      RESULT DATA(orders).

    DATA updates TYPE TABLE FOR UPDATE zi_kjom_salesorder.

    LOOP AT orders INTO DATA(order).

      DATA(default_order_type) =
        COND #(
          WHEN order-SalesOrderType IS INITIAL
          THEN 'OR'
          ELSE order-SalesOrderType ).

      DATA(default_order_date) =
        COND #(
          WHEN order-OrderDate IS INITIAL
          THEN cl_abap_context_info=>get_system_date( )
          ELSE order-OrderDate ).

      DATA(default_status) =
        COND #(
          WHEN order-OverallStatus IS INITIAL
          THEN zif_kjom_constants=>sales_order_status-new
          ELSE order-OverallStatus ).

      IF default_order_type = order-SalesOrderType
         AND default_order_date = order-OrderDate
         AND default_status = order-OverallStatus.
        CONTINUE.
      ENDIF.

      APPEND VALUE #(
        %tky = order-%tky

        SalesOrderType = default_order_type
        %control-SalesOrderType =
          COND #(
            WHEN default_order_type <> order-SalesOrderType
            THEN if_abap_behv=>mk-on
            ELSE if_abap_behv=>mk-off )

        OrderDate = default_order_date
        %control-OrderDate =
          COND #(
            WHEN default_order_date <> order-OrderDate
            THEN if_abap_behv=>mk-on
            ELSE if_abap_behv=>mk-off )

        OverallStatus = default_status
        %control-OverallStatus =
          COND #(
            WHEN default_status <> order-OverallStatus
            THEN if_abap_behv=>mk-on
            ELSE if_abap_behv=>mk-off )
      ) TO updates.

    ENDLOOP.

    CHECK updates IS NOT INITIAL.

    MODIFY ENTITIES OF zi_kjom_salesorder IN LOCAL MODE
      ENTITY SalesOrder
        UPDATE
        FROM updates
      REPORTED DATA(reported_update).

    reported-salesorder =
      CORRESPONDING #( DEEP reported_update-salesorder ).

  ENDMETHOD.

  METHOD deriveCustomerDefaults.

    READ ENTITIES OF zi_kjom_salesorder IN LOCAL MODE
      ENTITY SalesOrder
        FIELDS (
          CustomerUUID
          SalesOrganization
          DistributionChannel
          Division
          TransactionCurrency
        )
        WITH CORRESPONDING #( keys )
      RESULT DATA(orders).

    DELETE orders WHERE CustomerUUID IS INITIAL.

    CHECK orders IS NOT INITIAL.

    SELECT customer_uuid,
           sales_organization,
           distribution_channel,
           division,
           currency_code
      FROM zkj_om_customer
      FOR ALL ENTRIES IN @orders
      WHERE customer_uuid = @orders-CustomerUUID
        AND status = @zif_kjom_constants=>customer_status-active
      INTO TABLE @DATA(customers).

    DATA updates TYPE TABLE FOR UPDATE zi_kjom_salesorder.

    LOOP AT orders INTO DATA(order).

      READ TABLE customers
        WITH KEY customer_uuid = order-CustomerUUID
        INTO DATA(customer).

      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      IF order-SalesOrganization = customer-sales_organization
         AND order-DistributionChannel = customer-distribution_channel
         AND order-Division = customer-division
         AND order-TransactionCurrency = customer-currency_code.
        CONTINUE.
      ENDIF.

      APPEND VALUE #(
        %tky = order-%tky

        SalesOrganization = customer-sales_organization
        %control-SalesOrganization =
          COND #(
            WHEN order-SalesOrganization <>
                 customer-sales_organization
            THEN if_abap_behv=>mk-on
            ELSE if_abap_behv=>mk-off )

        DistributionChannel = customer-distribution_channel
        %control-DistributionChannel =
          COND #(
            WHEN order-DistributionChannel <>
                 customer-distribution_channel
            THEN if_abap_behv=>mk-on
            ELSE if_abap_behv=>mk-off )

        Division = customer-division
        %control-Division =
          COND #(
            WHEN order-Division <> customer-division
            THEN if_abap_behv=>mk-on
            ELSE if_abap_behv=>mk-off )

        TransactionCurrency = customer-currency_code
        %control-TransactionCurrency =
          COND #(
            WHEN order-TransactionCurrency <>
                 customer-currency_code
            THEN if_abap_behv=>mk-on
            ELSE if_abap_behv=>mk-off )
      ) TO updates.

    ENDLOOP.

    CHECK updates IS NOT INITIAL.

    MODIFY ENTITIES OF zi_kjom_salesorder IN LOCAL MODE
      ENTITY SalesOrder
        UPDATE
        FROM updates
      REPORTED DATA(reported_update).

    reported-salesorder =
      CORRESPONDING #( DEEP reported_update-salesorder ).

  ENDMETHOD.

  METHOD validateCustomer.

    READ ENTITIES OF zi_kjom_salesorder IN LOCAL MODE
      ENTITY SalesOrder
        FIELDS ( CustomerUUID )
        WITH CORRESPONDING #( keys )
      RESULT DATA(orders).

    LOOP AT orders INTO DATA(order).

      APPEND VALUE #(
        %tky        = order-%tky
        %state_area = 'VALIDATE_CUSTOMER'
      ) TO reported-salesorder.

      IF order-CustomerUUID IS INITIAL.

        APPEND VALUE #(
          %tky = order-%tky
        ) TO failed-salesorder.

        APPEND VALUE #(
          %tky                  = order-%tky
          %state_area           = 'VALIDATE_CUSTOMER'
          %element-CustomerUUID = if_abap_behv=>mk-on
          %msg                  = new_message(
                                    id       = 'ZKJ_OM_MSG'
                                    number   = '301'
                                    severity =
                                      if_abap_behv_message=>severity-error )
        ) TO reported-salesorder.

        CONTINUE.

      ENDIF.

      SELECT SINGLE customer_id
        FROM zkj_om_customer
        WHERE customer_uuid = @order-CustomerUUID
          AND status = @zif_kjom_constants=>customer_status-active
        INTO @DATA(customer_id).

      IF sy-subrc <> 0.

        APPEND VALUE #(
          %tky = order-%tky
        ) TO failed-salesorder.

        APPEND VALUE #(
          %tky                  = order-%tky
          %state_area           = 'VALIDATE_CUSTOMER'
          %element-CustomerUUID = if_abap_behv=>mk-on
          %msg                  = new_message(
                                    id       = 'ZKJ_OM_MSG'
                                    number   = '302'
                                    severity =
                                      if_abap_behv_message=>severity-error
                                    v1       = 'Selected customer' )
        ) TO reported-salesorder.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD validateOrderDates.

    READ ENTITIES OF zi_kjom_salesorder IN LOCAL MODE
      ENTITY SalesOrder
        FIELDS (
          OrderDate
          RequestedDeliveryDate
        )
        WITH CORRESPONDING #( keys )
      RESULT DATA(orders).

    LOOP AT orders INTO DATA(order).

      APPEND VALUE #(
        %tky        = order-%tky
        %state_area = 'VALIDATE_ORDER_DATES'
      ) TO reported-salesorder.

      IF order-OrderDate IS INITIAL.

        APPEND VALUE #(
          %tky = order-%tky
        ) TO failed-salesorder.

        APPEND VALUE #(
          %tky               = order-%tky
          %state_area        = 'VALIDATE_ORDER_DATES'
          %element-OrderDate = if_abap_behv=>mk-on
          %msg               = new_message(
                                 id       = 'ZKJ_OM_MSG'
                                 number   = '303'
                                 severity =
                                   if_abap_behv_message=>severity-error )
        ) TO reported-salesorder.

      ENDIF.

      IF order-RequestedDeliveryDate IS NOT INITIAL
         AND order-OrderDate IS NOT INITIAL
         AND order-RequestedDeliveryDate < order-OrderDate.

        APPEND VALUE #(
          %tky = order-%tky
        ) TO failed-salesorder.

        APPEND VALUE #(
          %tky                         = order-%tky
          %state_area                  = 'VALIDATE_ORDER_DATES'
          %element-RequestedDeliveryDate = if_abap_behv=>mk-on
          %msg                         = new_message(
                                           id       = 'ZKJ_OM_MSG'
                                           number   = '304'
                                           severity =
                                             if_abap_behv_message=>severity-error )
        ) TO reported-salesorder.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD validateOrderType.

    READ ENTITIES OF zi_kjom_salesorder IN LOCAL MODE
      ENTITY SalesOrder
        FIELDS ( SalesOrderType )
        WITH CORRESPONDING #( keys )
      RESULT DATA(orders).

    LOOP AT orders INTO DATA(order).

      APPEND VALUE #(
        %tky        = order-%tky
        %state_area = 'VALIDATE_ORDER_TYPE'
      ) TO reported-salesorder.

      IF order-SalesOrderType IS INITIAL.

        APPEND VALUE #(
          %tky = order-%tky
        ) TO failed-salesorder.

        APPEND VALUE #(
          %tky                   = order-%tky
          %state_area            = 'VALIDATE_ORDER_TYPE'
          %element-SalesOrderType = if_abap_behv=>mk-on
          %msg                   = new_message(
                                     id       = 'ZKJ_OM_MSG'
                                     number   = '314'
                                     severity =
                                       if_abap_behv_message=>severity-error )
        ) TO reported-salesorder.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD validateCurrency.

    READ ENTITIES OF zi_kjom_salesorder IN LOCAL MODE
      ENTITY SalesOrder
        FIELDS ( TransactionCurrency )
        WITH CORRESPONDING #( keys )
      RESULT DATA(orders).

    LOOP AT orders INTO DATA(order).

      APPEND VALUE #(
        %tky        = order-%tky
        %state_area = 'VALIDATE_CURRENCY'
      ) TO reported-salesorder.

      IF order-TransactionCurrency IS INITIAL.

        APPEND VALUE #(
          %tky = order-%tky
        ) TO failed-salesorder.

        APPEND VALUE #(
          %tky                         = order-%tky
          %state_area                  = 'VALIDATE_CURRENCY'
          %element-TransactionCurrency = if_abap_behv=>mk-on
          %msg                         = new_message(
                                           id       = 'ZKJ_OM_MSG'
                                           number   = '315'
                                           severity =
                                             if_abap_behv_message=>severity-error )
        ) TO reported-salesorder.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD assignSalesOrderID.

    READ ENTITIES OF zi_kjom_salesorder IN LOCAL MODE
      ENTITY SalesOrder
        FIELDS (
          SalesOrderUUID
          SalesOrder
        )
        WITH CORRESPONDING #( keys )
      RESULT DATA(orders).

    DELETE orders
      WHERE SalesOrder IS NOT INITIAL.

    CHECK orders IS NOT INITIAL.

    DATA updates TYPE TABLE FOR UPDATE zi_kjom_salesorder.

    LOOP AT orders INTO DATA(order).

      DATA uuid_text TYPE c LENGTH 32.
      DATA id_part   TYPE c LENGTH 8.
      DATA order_id  TYPE c LENGTH 10.

      uuid_text = order-SalesOrderUUID.

      id_part = substring(
        val = uuid_text
        off = 24
        len = 8
      ).

      TRANSLATE id_part TO UPPER CASE.

      order_id = |SO{ id_part }|.

      APPEND VALUE #(
        %tky = order-%tky

        SalesOrder = order_id
        %control-SalesOrder = if_abap_behv=>mk-on
      ) TO updates.

    ENDLOOP.

    CHECK updates IS NOT INITIAL.

    MODIFY ENTITIES OF zi_kjom_salesorder IN LOCAL MODE
      ENTITY SalesOrder
        UPDATE
        FROM updates
      REPORTED DATA(reported_update).

    reported-salesorder =
      CORRESPONDING #( DEEP reported_update-salesorder ).

  ENDMETHOD.

  METHOD validateItems.

    READ ENTITIES OF zi_kjom_salesorder IN LOCAL MODE
      ENTITY SalesOrder
        BY \_Items
        FIELDS ( SalesOrderItemUUID )
        WITH CORRESPONDING #( keys )
      RESULT DATA(items)
      LINK DATA(item_links).

    LOOP AT keys INTO DATA(order_key).

      APPEND VALUE #(
        %tky        = order_key-%tky
        %state_area = 'VALIDATE_ITEMS'
      ) TO reported-salesorder.

      IF NOT line_exists(
        item_links[
          KEY id
          COMPONENTS
            source-%tky = order_key-%tky
        ]
      ).

        APPEND VALUE #(
          %tky = order_key-%tky
        ) TO failed-salesorder.

        APPEND VALUE #(
          %tky        = order_key-%tky
          %state_area = 'VALIDATE_ITEMS'
          %msg        = new_message(
                          id       = 'ZKJ_OM_MSG'
                          number   = '305'
                          severity =
                            if_abap_behv_message=>severity-error )
        ) TO reported-salesorder.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.

CLASS lhc_salesorderitem DEFINITION
  INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS setInitialItemData
      FOR DETERMINE ON MODIFY
      IMPORTING keys
                  FOR SalesOrderItem~setInitialItemData.

    METHODS deriveProductDefaults
      FOR DETERMINE ON MODIFY
      IMPORTING keys
                  FOR SalesOrderItem~deriveProductDefaults.

    METHODS calculateItemAmounts
      FOR DETERMINE ON MODIFY
      IMPORTING keys
                  FOR SalesOrderItem~calculateItemAmounts.

    METHODS validateProduct
      FOR VALIDATE ON SAVE
      IMPORTING keys
                  FOR SalesOrderItem~validateProduct.

    METHODS validateQuantity
      FOR VALIDATE ON SAVE
      IMPORTING keys
                  FOR SalesOrderItem~validateQuantity.

    METHODS validateDiscount
      FOR VALIDATE ON SAVE
      IMPORTING keys
                  FOR SalesOrderItem~validateDiscount.

    METHODS validateItemCurrency
      FOR VALIDATE ON SAVE
      IMPORTING keys
                  FOR SalesOrderItem~validateItemCurrency.

    METHODS assignItemNumber
      FOR DETERMINE ON MODIFY
      IMPORTING keys
                  FOR SalesOrderItem~assignItemNumber.

    METHODS calculateHeaderTotals
      FOR DETERMINE ON MODIFY
      IMPORTING keys
                  FOR SalesOrderItem~calculateHeaderTotals.

ENDCLASS.

CLASS lhc_salesorderitem IMPLEMENTATION.

  METHOD setInitialItemData.

    READ ENTITIES OF zi_kjom_salesorder IN LOCAL MODE
      ENTITY SalesOrderItem
        FIELDS (
          DiscountPercentage
          ItemStatus
        )
        WITH CORRESPONDING #( keys )
      RESULT DATA(items).

    DATA updates TYPE TABLE FOR UPDATE zi_kjom_salesorder\\SalesOrderItem.

    LOOP AT items INTO DATA(item).

      DATA(default_status) =
        COND #(
          WHEN item-ItemStatus IS INITIAL
          THEN zif_kjom_constants=>sales_order_status-new
          ELSE item-ItemStatus ).

      IF default_status = item-ItemStatus.
        CONTINUE.
      ENDIF.

      APPEND VALUE #(
        %tky = item-%tky

        ItemStatus = default_status
        %control-ItemStatus = if_abap_behv=>mk-on
      ) TO updates.

    ENDLOOP.

    CHECK updates IS NOT INITIAL.

    MODIFY ENTITIES OF zi_kjom_salesorder IN LOCAL MODE
      ENTITY SalesOrderItem
        UPDATE
        FROM updates
      REPORTED DATA(reported_update).

    reported-salesorderitem =
      CORRESPONDING #( DEEP reported_update-salesorderitem ).

  ENDMETHOD.

  METHOD deriveProductDefaults.

    READ ENTITIES OF zi_kjom_salesorder IN LOCAL MODE
      ENTITY SalesOrderItem
        FIELDS (
          ProductUUID
          ProductDescription
          OrderQuantityUnit
          TransactionCurrency
          UnitPrice
          TaxPercentage
          Plant
        )
        WITH CORRESPONDING #( keys )
      RESULT DATA(items).

    DELETE items WHERE ProductUUID IS INITIAL.

    CHECK items IS NOT INITIAL.

    SELECT product_uuid,
           product_name,
           base_unit,
           currency_code,
           standard_price,
           tax_percentage,
           default_plant
      FROM zkj_om_product
      FOR ALL ENTRIES IN @items
      WHERE product_uuid = @items-ProductUUID
        AND status = @zif_kjom_constants=>product_status-active
      INTO TABLE @DATA(products).

    DATA updates TYPE TABLE FOR UPDATE zi_kjom_salesorder\\SalesOrderItem.

    LOOP AT items INTO DATA(item).

      READ TABLE products
        WITH KEY product_uuid = item-ProductUUID
        INTO DATA(product).

      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      IF item-ProductDescription = product-product_name
         AND item-OrderQuantityUnit = product-base_unit
         AND item-TransactionCurrency = product-currency_code
         AND item-UnitPrice = product-standard_price
         AND item-TaxPercentage = product-tax_percentage
         AND item-Plant = product-default_plant.
        CONTINUE.
      ENDIF.

      APPEND VALUE #(
        %tky = item-%tky

        ProductDescription = product-product_name
        %control-ProductDescription = if_abap_behv=>mk-on

        OrderQuantityUnit = product-base_unit
        %control-OrderQuantityUnit = if_abap_behv=>mk-on

        TransactionCurrency = product-currency_code
        %control-TransactionCurrency = if_abap_behv=>mk-on

        UnitPrice = product-standard_price
        %control-UnitPrice = if_abap_behv=>mk-on

        TaxPercentage = product-tax_percentage
        %control-TaxPercentage = if_abap_behv=>mk-on

        Plant = product-default_plant
        %control-Plant = if_abap_behv=>mk-on
      ) TO updates.

    ENDLOOP.

    CHECK updates IS NOT INITIAL.

    MODIFY ENTITIES OF zi_kjom_salesorder IN LOCAL MODE
      ENTITY SalesOrderItem
        UPDATE
        FROM updates
      REPORTED DATA(reported_update).

    reported-salesorderitem =
      CORRESPONDING #( DEEP reported_update-salesorderitem ).

  ENDMETHOD.

  METHOD calculateItemAmounts.

    READ ENTITIES OF zi_kjom_salesorder IN LOCAL MODE
      ENTITY SalesOrderItem
        FIELDS (
          OrderQuantity
          UnitPrice
          DiscountPercentage
          TaxPercentage
          GrossAmount
          DiscountAmount
          NetAmount
          TaxAmount
          TotalAmount
        )
        WITH CORRESPONDING #( keys )
      RESULT DATA(items).

    DATA updates
        TYPE TABLE FOR UPDATE zi_kjom_salesorderitem.

    LOOP AT items INTO DATA(item).

      DATA gross_amount_calc    TYPE decfloat34.
      DATA discount_amount_calc TYPE decfloat34.
      DATA net_amount_calc      TYPE decfloat34.
      DATA tax_amount_calc      TYPE decfloat34.
      DATA total_amount_calc    TYPE decfloat34.

      gross_amount_calc =
          CONV decfloat34( item-OrderQuantity )
        * CONV decfloat34( item-UnitPrice ).

      discount_amount_calc =
          gross_amount_calc
        * CONV decfloat34( item-DiscountPercentage )
        / CONV decfloat34( 100 ).

      net_amount_calc =
          gross_amount_calc
        - discount_amount_calc.

      tax_amount_calc =
          net_amount_calc
        * CONV decfloat34( item-TaxPercentage )
        / CONV decfloat34( 100 ).

      total_amount_calc =
          net_amount_calc
        + tax_amount_calc.

      DATA gross_amount    LIKE item-GrossAmount.
      DATA discount_amount LIKE item-DiscountAmount.
      DATA net_amount      LIKE item-NetAmount.
      DATA tax_amount      LIKE item-TaxAmount.
      DATA total_amount    LIKE item-TotalAmount.

      gross_amount    = gross_amount_calc.
      discount_amount = discount_amount_calc.
      net_amount      = net_amount_calc.
      tax_amount      = tax_amount_calc.
      total_amount    = total_amount_calc.

      IF item-GrossAmount    = gross_amount
         AND item-DiscountAmount = discount_amount
         AND item-NetAmount      = net_amount
         AND item-TaxAmount      = tax_amount
         AND item-TotalAmount    = total_amount.
        CONTINUE.
      ENDIF.

      APPEND VALUE #(
        %tky = item-%tky

        GrossAmount = gross_amount
        %control-GrossAmount = if_abap_behv=>mk-on

        DiscountAmount = discount_amount
        %control-DiscountAmount = if_abap_behv=>mk-on

        NetAmount = net_amount
        %control-NetAmount = if_abap_behv=>mk-on

        TaxAmount = tax_amount
        %control-TaxAmount = if_abap_behv=>mk-on

        TotalAmount = total_amount
        %control-TotalAmount = if_abap_behv=>mk-on
      ) TO updates.

    ENDLOOP.

    CHECK updates IS NOT INITIAL.

    MODIFY ENTITIES OF zi_kjom_salesorder IN LOCAL MODE
      ENTITY SalesOrderItem
        UPDATE
        FROM updates
      REPORTED DATA(reported_update).

    reported-salesorderitem =
      CORRESPONDING #( DEEP reported_update-salesorderitem ).

  ENDMETHOD.

  METHOD validateProduct.

    READ ENTITIES OF zi_kjom_salesorder IN LOCAL MODE
      ENTITY SalesOrderItem
        FIELDS ( ProductUUID )
        WITH CORRESPONDING #( keys )
      RESULT DATA(items).

    LOOP AT items INTO DATA(item).

      APPEND VALUE #(
        %tky        = item-%tky
        %state_area = 'VALIDATE_PRODUCT'
      ) TO reported-salesorderitem.

      IF item-ProductUUID IS INITIAL.

        APPEND VALUE #(
          %tky = item-%tky
        ) TO failed-salesorderitem.

        APPEND VALUE #(
          %tky                  = item-%tky
          %state_area           = 'VALIDATE_PRODUCT'
          %element-ProductUUID  = if_abap_behv=>mk-on
          %msg                  = new_message(
                                    id       = 'ZKJ_OM_MSG'
                                    number   = '306'
                                    severity =
                                      if_abap_behv_message=>severity-error )
        ) TO reported-salesorderitem.

        CONTINUE.

      ENDIF.

      SELECT SINGLE product_id
        FROM zkj_om_product
        WHERE product_uuid = @item-ProductUUID
          AND status = @zif_kjom_constants=>product_status-active
        INTO @DATA(product_id).

      IF sy-subrc <> 0.

        APPEND VALUE #(
          %tky = item-%tky
        ) TO failed-salesorderitem.

        APPEND VALUE #(
          %tky                 = item-%tky
          %state_area          = 'VALIDATE_PRODUCT'
          %element-ProductUUID = if_abap_behv=>mk-on
          %msg                 = new_message(
                                   id       = 'ZKJ_OM_MSG'
                                   number   = '307'
                                   severity =
                                     if_abap_behv_message=>severity-error
                                   v1       = 'Selected product' )
        ) TO reported-salesorderitem.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD validateQuantity.

    READ ENTITIES OF zi_kjom_salesorder IN LOCAL MODE
      ENTITY SalesOrderItem
        FIELDS (
          ProductUUID
          OrderQuantity
        )
        WITH CORRESPONDING #( keys )
      RESULT DATA(items).

    LOOP AT items INTO DATA(item).

      "Clear previous messages belonging to this validation
      APPEND VALUE #(
        %tky        = item-%tky
        %state_area = 'VALIDATE_QUANTITY'
      ) TO reported-salesorderitem.

      "Do not repeat the Product validation here
      IF item-ProductUUID IS INITIAL.
        CONTINUE.
      ENDIF.

      "Quantity must be positive
      IF item-OrderQuantity <= 0.

        APPEND VALUE #(
          %tky = item-%tky
        ) TO failed-salesorderitem.

        APPEND VALUE #(
          %tky                   = item-%tky
          %state_area            = 'VALIDATE_QUANTITY'
          %element-OrderQuantity = if_abap_behv=>mk-on
          %msg                   = new_message(
                                     id       = 'ZKJ_OM_MSG'
                                     number   = '308'
                                     severity =
                                       if_abap_behv_message=>severity-error )
        ) TO reported-salesorderitem.

        CONTINUE.

      ENDIF.

      SELECT SINGLE
             product_id,
             available_stock
        FROM zkj_om_product
        WHERE product_uuid = @item-ProductUUID
          AND status       = @zif_kjom_constants=>product_status-active
        INTO @DATA(product_stock).

      "Missing or inactive Product is reported by validateProduct
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      "No stock at all
      IF product_stock-available_stock <= 0.

        APPEND VALUE #(
          %tky        = item-%tky
          %state_area = 'VALIDATE_QUANTITY'

          %path = VALUE #(
            SalesOrder-%is_draft      = item-%is_draft
            SalesOrder-SalesOrderUUID = item-SalesOrderUUID
          )

          %element-OrderQuantity = if_abap_behv=>mk-on

          %msg = new_message(
            id       = 'ZKJ_OM_MSG'
            number   = '316'
            severity = if_abap_behv_message=>severity-error
            v1       = product_stock-product_id )
          ) TO reported-salesorderitem.

        CONTINUE.

      ENDIF.

      "Requested quantity exceeds current stock
      IF item-OrderQuantity > product_stock-available_stock.

        APPEND VALUE #(
          %tky        = item-%tky
          %state_area = 'VALIDATE_QUANTITY'

          %path = VALUE #(
            SalesOrder-%is_draft      = item-%is_draft
            SalesOrder-SalesOrderUUID = item-SalesOrderUUID
          )

          %element-OrderQuantity = if_abap_behv=>mk-on

          %msg = new_message(
                   id       = 'ZKJ_OM_MSG'
                   number   = '313'
                   severity = if_abap_behv_message=>severity-error
                   v1       = |{ item-OrderQuantity }|
                   v2       = |{ product_stock-available_stock }|
                   v3       = product_stock-product_id )
        ) TO reported-salesorderitem.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD validateDiscount.

  READ ENTITIES OF zi_kjom_salesorder IN LOCAL MODE
    ENTITY SalesOrderItem
      FIELDS (
        SalesOrderUUID
        DiscountPercentage
      )
      WITH CORRESPONDING #( keys )
    RESULT DATA(items).

  LOOP AT items INTO DATA(item).

    "Clear previous state messages for this validation
    APPEND VALUE #(
      %tky        = item-%tky
      %state_area = 'VALIDATE_DISCOUNT'

      %path = VALUE #(
        SalesOrder-%is_draft      = item-%is_draft
        SalesOrder-SalesOrderUUID = item-SalesOrderUUID
      )
    ) TO reported-salesorderitem.

    IF item-DiscountPercentage < 0
       OR item-DiscountPercentage > 100.

      APPEND VALUE #(
        %tky = item-%tky
      ) TO failed-salesorderitem.

      APPEND VALUE #(
        %tky        = item-%tky
        %state_area = 'VALIDATE_DISCOUNT'

        %path = VALUE #(
          SalesOrder-%is_draft      = item-%is_draft
          SalesOrder-SalesOrderUUID = item-SalesOrderUUID
        )

        %element-DiscountPercentage =
          if_abap_behv=>mk-on

        %msg = new_message(
                 id       = 'ZKJ_OM_MSG'
                 number   = '309'
                 severity =
                   if_abap_behv_message=>severity-error )
      ) TO reported-salesorderitem.

    ENDIF.

  ENDLOOP.

ENDMETHOD.

  METHOD validateItemCurrency.

    READ ENTITIES OF zi_kjom_salesorder IN LOCAL MODE
      ENTITY SalesOrderItem
        FIELDS (
          SalesOrderUUID
          TransactionCurrency
        )
        WITH CORRESPONDING #( keys )
      RESULT DATA(items).

    CHECK items IS NOT INITIAL.

    READ ENTITIES OF zi_kjom_salesorder IN LOCAL MODE
      ENTITY SalesOrderItem
        BY \_SalesOrder
        FIELDS (
          SalesOrderUUID
          TransactionCurrency
        )
        WITH CORRESPONDING #( keys )
      RESULT DATA(parent_orders).

    LOOP AT items INTO DATA(item).

      APPEND VALUE #(
        %tky        = item-%tky
        %state_area = 'VALIDATE_ITEM_CURRENCY'
      ) TO reported-salesorderitem.

      "Item currency must exist
      IF item-TransactionCurrency IS INITIAL.

        APPEND VALUE #(
          %tky        = item-%tky
          %state_area = 'VALIDATE_ITEM_CURRENCY'

          %path = VALUE #(
            SalesOrder-%is_draft      = item-%is_draft
            SalesOrder-SalesOrderUUID = item-SalesOrderUUID
          )

          %element-TransactionCurrency = if_abap_behv=>mk-on

          %msg = new_message(
                   id       = 'ZKJ_OM_MSG'
                   number   = '315'
                   severity = if_abap_behv_message=>severity-error )
        ) TO reported-salesorderitem.
        CONTINUE.

      ENDIF.

      READ TABLE parent_orders INTO DATA(parent_order)
        WITH TABLE KEY entity
        COMPONENTS
          SalesOrderUUID = item-SalesOrderUUID.

      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      "The header validation handles an empty header currency
      IF parent_order-TransactionCurrency IS INITIAL.
        CONTINUE.
      ENDIF.

      IF item-TransactionCurrency <>
         parent_order-TransactionCurrency.

        APPEND VALUE #(
          %tky = item-%tky
        ) TO failed-salesorderitem.

        APPEND VALUE #(
          %tky        = item-%tky
          %state_area = 'VALIDATE_ITEM_CURRENCY'

          %path = VALUE #(
            SalesOrder-%is_draft      = item-%is_draft
            SalesOrder-SalesOrderUUID = item-SalesOrderUUID
          )

          %element-TransactionCurrency = if_abap_behv=>mk-on

          %msg = new_message(
                   id       = 'ZKJ_OM_MSG'
                   number   = '312'
                   severity = if_abap_behv_message=>severity-error
                   v1       = item-TransactionCurrency
                   v2       = parent_order-TransactionCurrency )
        ) TO reported-salesorderitem.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD assignItemNumber.

    READ ENTITIES OF zi_kjom_salesorder IN LOCAL MODE
      ENTITY SalesOrderItem
        FIELDS (
          SalesOrderUUID
          SalesOrderItem
        )
        WITH CORRESPONDING #( keys )
      RESULT DATA(created_items).

    DELETE created_items
      WHERE SalesOrderItem IS NOT INITIAL.

    CHECK created_items IS NOT INITIAL.

    DATA parent_keys
      TYPE TABLE FOR READ IMPORT zi_kjom_salesorder.

    parent_keys = VALUE #(
      FOR GROUPS parent_group OF item IN created_items
        GROUP BY (
          SalesOrderUUID = item-SalesOrderUUID
          IsDraft        = item-%is_draft
        )
      (
        SalesOrderUUID = parent_group-SalesOrderUUID
        %is_draft      = parent_group-IsDraft
      )
    ).

    READ ENTITIES OF zi_kjom_salesorder IN LOCAL MODE
      ENTITY SalesOrder
        BY \_Items
        FIELDS ( SalesOrderItem )
        WITH CORRESPONDING #( parent_keys )
      RESULT DATA(all_items).

    DATA updates TYPE TABLE FOR UPDATE zi_kjom_salesorderitem.

    LOOP AT parent_keys INTO DATA(parent_key) USING KEY entity.

      DATA next_item_number TYPE i VALUE 10.

      LOOP AT all_items INTO DATA(existing_item) USING KEY entity
        WHERE SalesOrderUUID = parent_key-SalesOrderUUID
          AND SalesOrderItem IS NOT INITIAL.

        DATA(existing_item_number) =
          CONV i( existing_item-SalesOrderItem ).

        IF existing_item_number >= next_item_number.
          next_item_number = existing_item_number + 10.
        ENDIF.

      ENDLOOP.

      LOOP AT created_items INTO DATA(created_item) USING KEY entity
        WHERE SalesOrderUUID = parent_key-SalesOrderUUID.

        DATA formatted_item_number TYPE n LENGTH 6.
        formatted_item_number = next_item_number.

        APPEND VALUE #(
          %tky = created_item-%tky

          SalesOrderItem = formatted_item_number
          %control-SalesOrderItem = if_abap_behv=>mk-on
        ) TO updates.

        next_item_number += 10.

      ENDLOOP.

    ENDLOOP.

    CHECK updates IS NOT INITIAL.

    MODIFY ENTITIES OF zi_kjom_salesorder IN LOCAL MODE
      ENTITY SalesOrderItem
        UPDATE
        FROM updates
      REPORTED DATA(reported_update).

    reported-salesorderitem =
      CORRESPONDING #( DEEP reported_update-salesorderitem ).

  ENDMETHOD.

  METHOD calculateHeaderTotals.

    DATA parent_keys
      TYPE TABLE FOR READ IMPORT zi_kjom_salesorder.

    parent_keys = VALUE #(
      FOR GROUPS parent_group OF item_key IN keys
        GROUP BY (
          SalesOrderUUID = item_key-SalesOrderUUID
          IsDraft        = item_key-%is_draft
        )
      (
        SalesOrderUUID = parent_group-SalesOrderUUID
        %is_draft      = parent_group-IsDraft
      )
    ).

    CHECK parent_keys IS NOT INITIAL.

    "Read remaining items after create, update, or delete
    READ ENTITIES OF zi_kjom_salesorder IN LOCAL MODE
      ENTITY SalesOrder
        BY \_Items
        FIELDS (
          GrossAmount
          DiscountAmount
          NetAmount
          TaxAmount
          TotalAmount
        )
        WITH CORRESPONDING #( parent_keys )
      RESULT DATA(remaining_items).

    DATA header_updates
      TYPE TABLE FOR UPDATE zi_kjom_salesorder.

    LOOP AT parent_keys INTO DATA(parent_key).

      DATA gross_total    TYPE decfloat34 VALUE 0.
      DATA discount_total TYPE decfloat34 VALUE 0.
      DATA net_total      TYPE decfloat34 VALUE 0.
      DATA tax_total      TYPE decfloat34 VALUE 0.
      DATA grand_total    TYPE decfloat34 VALUE 0.

      LOOP AT remaining_items INTO DATA(item) USING KEY entity
        WHERE SalesOrderUUID = parent_key-SalesOrderUUID.

        gross_total =
          gross_total + CONV decfloat34( item-GrossAmount ).

        discount_total =
          discount_total + CONV decfloat34( item-DiscountAmount ).

        net_total =
          net_total + CONV decfloat34( item-NetAmount ).

        tax_total =
          tax_total + CONV decfloat34( item-TaxAmount ).

        grand_total =
          grand_total + CONV decfloat34( item-TotalAmount ).

      ENDLOOP.

      APPEND VALUE #(
        SalesOrderUUID = parent_key-SalesOrderUUID
        %is_draft      = parent_key-%is_draft

        GrossAmount = gross_total
        %control-GrossAmount = if_abap_behv=>mk-on

        DiscountAmount = discount_total
        %control-DiscountAmount = if_abap_behv=>mk-on

        NetAmount = net_total
        %control-NetAmount = if_abap_behv=>mk-on

        TaxAmount = tax_total
        %control-TaxAmount = if_abap_behv=>mk-on

        TotalAmount = grand_total
        %control-TotalAmount = if_abap_behv=>mk-on
      ) TO header_updates.

    ENDLOOP.

    CHECK header_updates IS NOT INITIAL.

    MODIFY ENTITIES OF zi_kjom_salesorder IN LOCAL MODE
      ENTITY SalesOrder
        UPDATE
        FROM header_updates.

  ENDMETHOD.

ENDCLASS.
