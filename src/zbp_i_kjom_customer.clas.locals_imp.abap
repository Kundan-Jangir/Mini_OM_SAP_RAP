CLASS lhc_customer DEFINITION
  INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS get_global_authorizations
      FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations
      FOR Customer
      RESULT result.

    METHODS setInitialStatus
      FOR DETERMINE ON MODIFY
      IMPORTING keys
                  FOR Customer~setInitialStatus.

    METHODS normalizeCustomerData
      FOR DETERMINE ON MODIFY
      IMPORTING keys
                  FOR Customer~normalizeCustomerData.

    METHODS validateCustomer
      FOR VALIDATE ON SAVE
      IMPORTING keys
                  FOR Customer~validateCustomer.

    METHODS validateCustomerName
      FOR VALIDATE ON SAVE
      IMPORTING keys
                  FOR Customer~validateCustomerName.

    METHODS validateCreditLimit
      FOR VALIDATE ON SAVE
      IMPORTING keys
                  FOR Customer~validateCreditLimit.

    METHODS validateEmailAddress
      FOR VALIDATE ON SAVE
      IMPORTING keys
                  FOR Customer~validateEmailAddress.

ENDCLASS.


CLASS lhc_customer IMPLEMENTATION.

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

    READ ENTITIES OF zi_kjom_customer IN LOCAL MODE
      ENTITY Customer
        FIELDS ( Status )
        WITH CORRESPONDING #( keys )
      RESULT DATA(customers).

    DELETE customers
      WHERE Status IS NOT INITIAL.

    CHECK customers IS NOT INITIAL.

    MODIFY ENTITIES OF zi_kjom_customer IN LOCAL MODE
      ENTITY Customer
        UPDATE FIELDS ( Status )
        WITH VALUE #(
          FOR customer IN customers
          (
            %tky   = customer-%tky
            Status = zif_kjom_constants=>customer_status-active
          )
        )
      FAILED DATA(failed_update)
      REPORTED DATA(reported_update).

    reported-customer =
      CORRESPONDING #( DEEP reported_update-customer ).

  ENDMETHOD.


  METHOD normalizeCustomerData.

    READ ENTITIES OF zi_kjom_customer IN LOCAL MODE
      ENTITY Customer
        FIELDS (
          CustomerName
          EmailAddress
        )
        WITH CORRESPONDING #( keys )
      RESULT DATA(customers).

    DATA updates TYPE TABLE FOR UPDATE zi_kjom_customer.

    LOOP AT customers INTO DATA(customer).

      DATA(normalized_name) =
        condense(
          val  = customer-CustomerName
          from = ` `
          to   = ` ` ).

      DATA(normalized_email) =
        to_lower( customer-EmailAddress ).

      IF normalized_name  = customer-CustomerName
         AND normalized_email = customer-EmailAddress.
        CONTINUE.
      ENDIF.

      APPEND VALUE #(
        %tky = customer-%tky

        CustomerName = normalized_name
        %control-CustomerName =
          COND #(
            WHEN normalized_name <> customer-CustomerName
            THEN if_abap_behv=>mk-on
            ELSE if_abap_behv=>mk-off )

        EmailAddress = normalized_email
        %control-EmailAddress =
          COND #(
            WHEN normalized_email <> customer-EmailAddress
            THEN if_abap_behv=>mk-on
            ELSE if_abap_behv=>mk-off )
      ) TO updates.

    ENDLOOP.

    CHECK updates IS NOT INITIAL.

    MODIFY ENTITIES OF zi_kjom_customer IN LOCAL MODE
      ENTITY Customer
        UPDATE
        FROM updates
      REPORTED DATA(reported_update).

    reported-customer =
      CORRESPONDING #( DEEP reported_update-customer ).

  ENDMETHOD.


  METHOD validateCustomer.

    READ ENTITIES OF zi_kjom_customer IN LOCAL MODE
      ENTITY Customer
        FIELDS (
          CustomerUUID
          Customer
        )
        WITH CORRESPONDING #( keys )
      RESULT DATA(customers).

    LOOP AT customers INTO DATA(customer).

      APPEND VALUE #(
        %tky        = customer-%tky
        %state_area = 'VALIDATE_CUSTOMER'
      ) TO reported-customer.

      IF customer-Customer IS INITIAL.

        APPEND VALUE #(
          %tky = customer-%tky
        ) TO failed-customer.

        APPEND VALUE #(
          %tky              = customer-%tky
          %state_area       = 'VALIDATE_CUSTOMER'
          %element-Customer = if_abap_behv=>mk-on
          %msg              = new_message(
                                id       = 'ZKJ_OM_MSG'
                                number   = '002'
                                severity = if_abap_behv_message=>severity-error )
        ) TO reported-customer.

        CONTINUE.

      ENDIF.

      SELECT SINGLE
             customer_uuid
        FROM zkj_om_customer
        WHERE customer_id   = @customer-Customer
          AND customer_uuid <> @customer-CustomerUUID
        INTO @DATA(existing_customer_uuid).

      IF sy-subrc = 0.

        APPEND VALUE #(
          %tky = customer-%tky
        ) TO failed-customer.

        APPEND VALUE #(
          %tky              = customer-%tky
          %state_area       = 'VALIDATE_CUSTOMER'
          %element-Customer = if_abap_behv=>mk-on
          %msg              = new_message(
                                id       = 'ZKJ_OM_MSG'
                                number   = '106'
                                severity = if_abap_behv_message=>severity-error
                                v1       = 'Create customer'
                                v2       = customer-Customer )
        ) TO reported-customer.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD validateCustomerName.

    READ ENTITIES OF zi_kjom_customer IN LOCAL MODE
      ENTITY Customer
        FIELDS ( CustomerName )
        WITH CORRESPONDING #( keys )
      RESULT DATA(customers).

    LOOP AT customers INTO DATA(customer).

      APPEND VALUE #(
        %tky        = customer-%tky
        %state_area = 'VALIDATE_CUSTOMER_NAME'
      ) TO reported-customer.

      IF customer-CustomerName IS INITIAL.

        APPEND VALUE #(
          %tky = customer-%tky
        ) TO failed-customer.

        APPEND VALUE #(
          %tky                  = customer-%tky
          %state_area           = 'VALIDATE_CUSTOMER_NAME'
          %element-CustomerName = if_abap_behv=>mk-on
          %msg                  = new_message(
                                    id       = 'ZKJ_OM_MSG'
                                    number   = '103'
                                    severity = if_abap_behv_message=>severity-error )
        ) TO reported-customer.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD validateCreditLimit.

    READ ENTITIES OF zi_kjom_customer IN LOCAL MODE
      ENTITY Customer
        FIELDS (
          CreditLimit
          Currency
        )
        WITH CORRESPONDING #( keys )
      RESULT DATA(customers).

    LOOP AT customers INTO DATA(customer).

      APPEND VALUE #(
        %tky        = customer-%tky
        %state_area = 'VALIDATE_CREDIT_LIMIT'
      ) TO reported-customer.

      IF customer-CreditLimit < 0.

        APPEND VALUE #(
          %tky = customer-%tky
        ) TO failed-customer.

        APPEND VALUE #(
          %tky                 = customer-%tky
          %state_area          = 'VALIDATE_CREDIT_LIMIT'
          %element-CreditLimit = if_abap_behv=>mk-on
          %msg                 = new_message(
                                   id       = 'ZKJ_OM_MSG'
                                   number   = '104'
                                   severity = if_abap_behv_message=>severity-error )
        ) TO reported-customer.

      ENDIF.

      IF customer-CreditLimit IS NOT INITIAL
         AND customer-Currency IS INITIAL.

        APPEND VALUE #(
          %tky = customer-%tky
        ) TO failed-customer.

        APPEND VALUE #(
          %tky              = customer-%tky
          %state_area       = 'VALIDATE_CREDIT_LIMIT'
          %element-Currency = if_abap_behv=>mk-on
          %msg              = new_message(
                                id       = 'ZKJ_OM_MSG'
                                number   = '105'
                                severity = if_abap_behv_message=>severity-error )
        ) TO reported-customer.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD validateEmailAddress.

    READ ENTITIES OF zi_kjom_customer IN LOCAL MODE
      ENTITY Customer
        FIELDS ( EmailAddress )
        WITH CORRESPONDING #( keys )
      RESULT DATA(customers).

    LOOP AT customers INTO DATA(customer).

      APPEND VALUE #(
        %tky        = customer-%tky
        %state_area = 'VALIDATE_EMAIL'
      ) TO reported-customer.

      IF customer-EmailAddress IS INITIAL.
        CONTINUE.
      ENDIF.

      IF customer-EmailAddress NP '*@*.*'.

        APPEND VALUE #(
          %tky = customer-%tky
        ) TO failed-customer.

        APPEND VALUE #(
          %tky                  = customer-%tky
          %state_area           = 'VALIDATE_EMAIL'
          %element-EmailAddress = if_abap_behv=>mk-on
          %msg                  = new_message(
                                    id       = 'ZKJ_OM_MSG'
                                    number   = '107'
                                    severity = if_abap_behv_message=>severity-error
                                    v1       = customer-EmailAddress )
        ) TO reported-customer.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
