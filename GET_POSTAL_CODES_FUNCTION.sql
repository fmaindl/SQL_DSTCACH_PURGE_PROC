create or replace 
FUNCTION                     FUNCTION_NAME(
      V_REFERENCE_ID NUMBER )
    RETURN ARRAYOBJECT
  IS
    REFERENCE_ID   NUMBER    := V_REFERENCE_ID;
    NUMBER_OF_ROWS NUMBER    := 10;
    PSTL_CD_LIST ARRAYOBJECT := ARRAYOBJECT();
    INDEX_VALUE                NUMBER;
    TOTAL_ROWS                 NUMBER;
    NUMBER_OF_PRIORITY_ENTRIES number;
    LOOP_RANGE number := 10;
    PRIORITY_ENTRY_ADJUSTER number;
  BEGIN
    SELECT COUNT(*) INTO TOTAL_ROWS FROM SCHEMA.PSTL_CD_T;
    SELECT COUNT(*)
    INTO NUMBER_OF_PRIORITY_ENTRIES
    from
      (SELECT * FROM SCHEMA.PSTL_CD_T WHERE PRIORITY_ENTRY = 'Y'
      FETCH NEXT 10 rows only
      ) ;
    PRIORITY_ENTRY_ADJUSTER := NUMBER_OF_PRIORITY_ENTRIES;
    
    if NUMBER_OF_PRIORITY_ENTRIES > 0 then
      NUMBER_OF_ROWS             := NUMBER_OF_ROWS - NUMBER_OF_PRIORITY_ENTRIES;
    END IF;  
    IF REFERENCE_ID             > TOTAL_ROWS THEN
      REFERENCE_ID             := 1;
    end if;
      FOR I IN 0..(LOOP_RANGE - 1)
      LOOP
        PSTL_CD_LIST.extend;
        if NUMBER_OF_PRIORITY_ENTRIES > 0 then 
          SELECT POSTAL_CODE
          INTO PSTL_CD_LIST(i + 1)
          from SCHEMA.PSTL_CD_T
          where SCHEMA.PSTL_CD_T.PRIORITY_ENTRY = 'Y'
          FETCH NEXT 1 rows only;
          DBMS_OUTPUT.PUT_LINE('Postal Code List: ' ||PSTL_CD_LIST(I+1));
          update SCHEMA.PSTL_CD_T set PRIORITY_ENTRY = 'N' where POSTAL_CODE = PSTL_CD_LIST(I + 1);
          commit;
          NUMBER_OF_PRIORITY_ENTRIES := NUMBER_OF_PRIORITY_ENTRIES - 1;
        elsif REFERENCE_ID                     + I - PRIORITY_ENTRY_ADJUSTER > TOTAL_ROWS then
          INDEX_VALUE      := (REFERENCE_ID + I - PRIORITY_ENTRY_ADJUSTER -
          TOTAL_ROWS);
          SELECT POSTAL_CODE
          INTO PSTL_CD_LIST(i + 1)
          FROM SCHEMA.PSTL_CD_T
          where SCHEMA.PSTL_CD_T.id = INDEX_VALUE;
          DBMS_OUTPUT.put_line('Postal Code List: ' ||PSTL_CD_LIST(i+1));
        else
          INDEX_VALUE := REFERENCE_ID + I - PRIORITY_ENTRY_ADJUSTER;
          SELECT POSTAL_CODE
          INTO PSTL_CD_LIST(i + 1)
          FROM SCHEMA.PSTL_CD_T
          where SCHEMA.PSTL_CD_T.id = INDEX_VALUE;
          DBMS_OUTPUT.put_line('Postal Code List: ' ||PSTL_CD_LIST(i+1));
      end if;
        
      END LOOP;
      return PSTL_CD_LIST;
    END ;