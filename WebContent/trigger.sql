CREATE OR REPLACE TRIGGER BeforeUpdateStudent 
BEFORE
UPDATE ON student
FOR EACH ROW

DECLARE
    length_err EXCEPTION;
    blank_err EXCEPTION;
    nLength NUMBER;
    nBlank NUMBER;

BEGIN

    SELECT length(:new.s_pwd), instr(:new.s_pwd,' ')
    INTO nLength, nBlank
    FROM DUAL;

    IF (nLength < 4) THEN
        RAISE length_err;
    ELSIF (nBlank > 0) THEN
        RAISE blank_err;
    END IF;

    EXCEPTION 

    WHEN length_err THEN

        RAISE_APPLICATION_ERROR(-20002, '��ȣ�� 4�ڸ� �̻��̾�� �մϴ�');

    WHEN blank_err THEN

        RAISE_APPLICATION_ERROR(-20003, '��ȣ�� ������ �Էµ��� �ʽ��ϴ�.');

END;
/

CREATE SEQUENCE seq
START WITH 1
INCREMENT BY 1;
/

CREATE OR REPLACE TRIGGER en_num_trigger
BEFORE INSERT
ON enroll
REFERENCING NEW AS NEW
FOR EACH ROW
BEGIN
SELECT auto_seq.nextval INTO :NEW.en_num FROM dual;
END;
/