FUNCTION RESET_SEQUENCE(psSeqName IN VARCHAR2) RETURN NUMBER
IS
lsSql VARCHAR2(32767);
lbLocked BOOLEAN := FALSE;
lsLockName VARCHAR2(256);
lsLockHandle VARCHAR2(256);
liRetCode PLS_INTEGER;
lnCacheSize NUMBER;
lnMinValue NUMBER;
lnIncrementBy NUMBER;
lnVal NUMBER;
BEGIN

lsLockName := 'RSEQ_' || psSeqName;

DBMS_LOCK.ALLOCATE_UNIQUE(lsLockName, lsLockHandle);
liRetCode := DBMS_LOCK.REQUEST(lsLockHandle, DBMS_LOCK.X_MODE, 5, TRUE);

IF liRetCode != 0 THEN
raise_application_error(-20000, 'cannot reset sequence ' || psSeqName || ', resource busy');
END IF;

lbLocked := TRUE;

lsSql := 'select CACHE_SIZE, MIN_VALUE, INCREMENT_BY from USER_SEQUENCES where SEQUENCE_NAME = ''' || UPPER(psSeqName) || '''';
EXECUTE IMMEDIATE lsSql INTO lnCacheSize, lnMinValue, lnIncrementBy;

lsSql := 'alter sequence '|| psSeqName ||' nocache';
EXECUTE IMMEDIATE lsSql;

lsSql := 'select '|| psSeqName ||'.nextval from dual';
EXECUTE IMMEDIATE lsSql INTO lnVal;

lsSql := 'alter sequence '|| psSeqName ||' increment by ' || TO_CHAR(lnMinValue - lnVal);
EXECUTE IMMEDIATE lsSql;

lsSql := 'select '|| psSeqName ||'.nextval from dual';
EXECUTE IMMEDIATE lsSql INTO lnVal;

lsSql := 'alter sequence '|| psSeqName ||' increment by ' || lnIncrementBy;
EXECUTE IMMEDIATE lsSql;

IF lnCacheSize &gt; 0 THEN

lsSql := 'alter sequence '|| psSeqName ||' cache ' || lnCacheSize;
EXECUTE IMMEDIATE lsSql;

END IF;

liRetCode := DBMS_LOCK.RELEASE(lsLockHandle);
RETURN lnVal;

EXCEPTION
WHEN OTHERS THEN
IF lbLocked THEN
liRetCode := DBMS_LOCK.RELEASE(lsLockHandle);
END IF;
RAISE;
END RESET_SEQUENCE;