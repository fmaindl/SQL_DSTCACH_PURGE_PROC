create or replace 
FUNCTION                                                   FUNC_NAME(
      V_REFERENCE_ID NUMBER )
    RETURN NUMBER
  IS
    REFERENCE_ID   number := V_REFERENCE_ID;
    NUMBER_OF_ROWS number := 10;
    TOTAL_ROWS number;
    NUMBER_OF_PRIORITY_ENTRIES number;
    
  begin
    select COUNT(*) into TOTAL_ROWS from SCHEMA.PSTL_CD_T;
    select count(*) into NUMBER_OF_PRIORITY_ENTRIES from (select * from SCHEMA.pstl_cd_t where PRIORITY_ENTRY = 'Y' FETCH NEXT 10 ROWS ONLY) ;
    
    NUMBER_OF_ROWS :=   NUMBER_OF_ROWS - NUMBER_OF_PRIORITY_ENTRIES;
    
    IF REFERENCE_ID + NUMBER_OF_ROWS - 1 >
      TOTAL_ROWS then
      REFERENCE_ID := REFERENCE_ID + NUMBER_OF_ROWS - 1 - TOTAL_ROWS;
    else
      REFERENCE_ID := REFERENCE_ID + NUMBER_OF_ROWS - 1;
    END IF;
    return REFERENCE_ID;
  END ;