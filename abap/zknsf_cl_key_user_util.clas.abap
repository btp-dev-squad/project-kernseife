class ZKNSF_CL_KEY_USER_UTIL definition
  public
  create protected .

public section.

  methods IS_KEY_USER_GENERATED
    importing
      !OBJECT_NAME type SOBJ_NAME
      !OBJECT_TYPE type TROBJTYPE
    returning
      value(IS_KEY_USER_GENERATED) type ABAP_BOOLEAN .
  methods IS_CDS_GENERATED
    importing
      !OBJECT_NAME type SOBJ_NAME
      !OBJECT_TYPE type TROBJTYPE
    returning
      value(IS_CDS_GENERATED) type ABAP_BOOLEAN .
  class-methods GET_INSTANCE
    returning
      value(INST) type ref to ZKNSF_CL_KEY_USER_UTIL .
protected section.

  types:
    BEGIN OF ty_key_user_objects,
             object_type TYPE trobjtype,
             object_name TYPE trobj_name,
           END OF ty_key_user_objects .

  data:
    key_user_objects TYPE HASHED TABLE OF ty_key_user_objects WITH UNIQUE KEY object_type object_name .
  class-data INSTANCE type ref to ZKNSF_CL_KEY_USER_UTIL .

  methods CONSTRUCTOR .
private section.
ENDCLASS.



CLASS ZKNSF_CL_KEY_USER_UTIL IMPLEMENTATION.


  METHOD constructor.
    " Load all Key-User Object
    SELECT FROM atov_u_item_bom_del FIELDS bom_object, bom_object_name  WHERE is_deleted = @abap_false INTO TABLE @key_user_objects.
  ENDMETHOD.


  METHOD get_instance.
    IF instance IS INITIAL.
      instance = NEW zknsf_cl_key_user_util( ).
    ENDIF.

    RETURN instance.
  ENDMETHOD.


  METHOD is_cds_generated.
    CLEAR is_cds_generated.
    IF object_type = 'VIEW'.
      SELECT SINGLE FROM all_cds_sql_views FIELDS @abap_true WHERE sqlviewname = @object_name INTO @is_cds_generated.
    ENDIF.
  ENDMETHOD.


  METHOD is_key_user_generated.
    " Check if it is used in Custom Fields
    DATA object_name_30 TYPE c LENGTH 30.
    object_name_30 = object_name.
    SELECT SINGLE FROM cfd_w_rep_enh FIELDS @abap_true WHERE enhancement_object_name = @object_name_30  INTO @DATA(is_custom_field_stuff).
    IF sy-subrc EQ 0.
      RETURN abap_true.
    ENDIF.

    DATA(object_name_check) = object_name.
    DATA(object_type_check) = object_type.

    " For DB Views we need to check to corresponding DDLS, as Key-User generated objects unfortunatly don't use view entities (yet)
    IF object_type = 'VIEW'.
      " Find DDLS for this DB view
      SELECT SINGLE FROM all_cds_sql_views FIELDS ddlsourcename WHERE sqlviewname = @object_name INTO @DATA(cds_view_name).
      IF sy-subrc EQ 0.
        object_name_check = cds_view_name.
        object_type_check = 'DDLS'.
      ENDIF.
    ENDIF.

    IF line_exists( key_user_objects[ object_type = object_type_check object_name = object_name_check ] ).
      RETURN abap_true.
    ENDIF.

    " Check if it is a Custom Business Object CDS View
    DATA object_name_16 TYPE c LENGTH 16.
    object_name_16 = object_name.
    SELECT SINGLE FROM scbo_node FIELDS @abap_true WHERE cds_view_name = @object_name_30 OR abap_view_name = @object_name_16 INTO @DATA(is_cbo).
    IF sy-subrc EQ 0.
      RETURN abap_true.
    ENDIF.

    RETURN abap_false.
  ENDMETHOD.
ENDCLASS.
