create or replace 
function                               FUNCTION_NA
  RETURN NUMBER
  IS
    CURRENT_REFERENCE_ID NUMBER := 0;
  begin
    SELECT REFERENCE_ID + 1
    into CURRENT_REFERENCE_ID
    FROM SCHEMA.DST_CACH_DEL_CUSTOM_PROC_LOGGER
    WHERE ID =
      (select max(id) from SCHEMA.DST_CACH_DEL_CUSTOM_PROC_LOGGER
      ); 
      return CURRENT_REFERENCE_ID;
  END ;