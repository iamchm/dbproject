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