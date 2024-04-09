CLASS zcl_test_abap_cloud_05d DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_test_abap_cloud_05d IMPLEMENTATION.



  METHOD if_oo_adt_classrun~main.

    DATA create_bank TYPE STRUCTURE FOR CREATE i_banktp.
    DATA bank_id_number TYPE i_banktp-BankInternalID VALUE '8890'.
    DATA id_exists TYPE i_banktp-BankInternalID VALUE '0000'.
    SELECT SINGLE bankinternalid FROM i_bank_2
    WITH PRIVILEGED ACCESS
   WHERE BankInternalID = @bank_id_number INTO @id_exists .
    IF sy-subrc = 0.
      out->write( |bank id exists { id_exists } | ).
      id_exists = id_exists + 1 .
      shift id_exists left deleting leading space.
      out->write( |new try with { id_exists } | ).
      bank_id_number = id_exists.
    ENDIF.

    create_bank = VALUE #( bankcountry = 'CZ'
                         bankinternalid = bank_id_number
                         longbankname = 'Bank name'
                         longbankbranch = 'Bank branch'
                         banknumber = bank_id_number
                         bankcategory = ''
                         banknetworkgrouping = ''
                         swiftcode = 'SABMGB2LACP'
                         ismarkedfordeletion = ''
                  ).




    MODIFY ENTITIES OF i_banktp
    PRIVILEGED
    ENTITY bank
    CREATE FIELDS ( bankcountry
                  bankinternalid
                  longbankname
                  longbankbranch
                  banknumber
                  bankcategory
                  banknetworkgrouping
                  swiftcode
                  IsMarkedForDeletion
               )
     WITH VALUE #( (
     %cid = 'cid1'
       bankcountry         = create_bank-bankcountry
       bankinternalid      = create_bank-bankinternalid
       longbankname        = create_bank-longbankname
       longbankbranch      = create_bank-longbankbranch
       banknumber          = create_bank-banknumber
       bankcategory        = create_bank-bankcategory
       banknetworkgrouping = create_bank-banknetworkgrouping
       SWIFTCode           = create_bank-SWIFTCode
       IsMarkedForDeletion = create_bank-IsMarkedForDeletion
       )  )

     MAPPED DATA(mapped)
     REPORTED DATA(reported)
     FAILED DATA(failed).

    LOOP AT reported-bank INTO DATA(reported_error_1).
      DATA(exc_create_bank) = cl_message_helper=>get_longtext_for_message(
        EXPORTING
          text               = reported_error_1-%msg
        ).
      out->write( |error { exc_create_bank } |  ).
    ENDLOOP.


    COMMIT ENTITIES
    RESPONSE OF i_banktp
    FAILED DATA(failed_commit)
    REPORTED DATA(reported_commit).



    LOOP AT reported_commit-bank INTO DATA(reported_error_2).
      DATA(exc_create_bank2) = cl_message_helper=>get_longtext_for_message(
        EXPORTING
          text               = reported_error_2-%msg
      ).
      out->write( |error { exc_create_bank2 } |  ).
    ENDLOOP.
    IF reported_commit-bank IS INITIAL.
      COMMIT WORK.

      SELECT SINGLE * FROM I_Bank_2
      WITH PRIVILEGED ACCESS

      WHERE BankInternalID = @bank_id_number INTO @DATA(my_bank).
      out->write( |my new bank { my_bank-BankName } { my_bank-BankInternalID }| ).
    ENDIF.
  ENDMETHOD.

ENDCLASS.
