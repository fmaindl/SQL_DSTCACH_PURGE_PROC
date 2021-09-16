create or replace 
PROCEDURE                                         PROC_NAME
IS
  POSTAL_CODE    VARCHAR2 (200);
  PROC_COUNTER   NUMBER;
  LAST_ID        NUMBER;
  DELETED_COUNT  NUMBER;
  DELETED_COUNT2 number;
  LIST_LENGTH number;
  PSTL_CD_ARRAY ARRAYOBJECT := ARRAYOBJECT();
  PSTL_CD_LIST varchar2(100);
  REFERENCE_ID NUMBER;
begin
  REFERENCE_ID := SCHEMA.GET_DSTCACH_PURG_REFID;
  DBMS_OUTPUT.PUT_LINE('REFERENCE ID:' || REFERENCE_ID);
  LAST_ID        := SCHEMA.GET_LAST_ID(REFERENCE_ID);
  DBMS_OUTPUT.PUT_LINE('Last ID:' || LAST_ID);
  PSTL_CD_ARRAY := SCHEMA.GET_PSTL_CODES(REFERENCE_ID);
  DELETED_COUNT  := 0;
  DELETED_COUNT2 := 0;
  PROC_COUNTER   := 0;
  PSTL_CD_LIST := '';
  LIST_LENGTH := PSTL_CD_ARRAY.COUNT;
  
  
  for I in 1..LIST_LENGTH
  
  LOOP
    POSTAL_CODE := PSTL_CD_ARRAY(I);
    PSTL_CD_LIST := CONCAT(PSTL_CD_LIST, CONCAT(POSTAL_CODE, ' '));
    delete
    FROM SCHEMA.DST_CACH_T
    WHERE SCHEMA.DST_CACH_T.OVRD_YN = 'F'
    AND (SCHEMA.DST_CACH_T.LOC1 LIKE CONCAT('%', CONCAT(TO_CHAR(POSTAL_CODE), '%'))
    OR SCHEMA.DST_CACH_T.LOC2 LIKE CONCAT('%', CONCAT(TO_CHAR(POSTAL_CODE), '%')));
    PROC_COUNTER   := PROC_COUNTER + 1;
    DELETED_COUNT2 := sql%ROWCOUNT;
    DELETED_COUNT  := DELETED_COUNT + DELETED_COUNT2;
    EXIT
  WHEN PROC_COUNTER = LIST_LENGTH;
  end LOOP;
  insert into SCHEMA.DST_CACH_DEL_CUSTOM_PROC_LOGGER (REFERENCE_ID,POSTAL_CODES,COMPLETION_DATE,ROWS_DELETED) values ((LAST_ID),(PSTL_CD_LIST),(select sysdate from DUAL), (DELETED_COUNT));
  commit;
  DBMS_OUTPUT.put_line('Committed');
EXCEPTION
WHEN NOT_LOGGED_ON THEN
  DBMS_OUTPUT.put_line ('Table purging unsuccessful. Your program issues a database call without being connected to Oracle.');
WHEN PROGRAM_ERROR THEN
  DBMS_OUTPUT.put_line ('Table purging unsuccessful. PL/SQL has an internal problem.');
WHEN STORAGE_ERROR THEN
  DBMS_OUTPUT.put_line ('Table purging unsuccessful. PL/SQL runs out of memory or memory has been corrupted.');
WHEN TIMEOUT_ON_RESOURCE THEN
  DBMS_OUTPUT.put_line ('A time-out occurs while Oracle is waiting for a resource.');
WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE ('Table purging unsuccessful. Some unforseen error occured');
END;