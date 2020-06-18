CREATE OR REPLACE FUNCTION doesCollide (
	a_class_id IN VARCHAR,
	a_class_id_no IN NUMBER,
	b_class_id IN VARCHAR,
	b_class_id_no IN NUMBER
)
RETURN NUMBER
IS
	checkCollide NUMBER;
	a_day NUMBER;
	a_start_h NUMBER;
	a_start_m NUMBER;
	a_lec_time NUMBER;
	a_start_time NUMBER;
	a_end_time NUMBER;
	b_day NUMBER;
	b_start_h NUMBER;
	b_start_m NUMBER;
	b_lec_time NUMBER;
	b_start_time NUMBER;
	b_end_time NUMBER;
BEGIN
	/* ù ��° class�� ������ ������ �ֱ� */
	SELECT c_day, c_start_h, c_start_m, c_lec_time
	INTO a_day, a_start_h, a_start_m, a_lec_time
	FROM class
	WHERE c_num = a_class_id and c_div = a_class_id_no;
	/* �� ��° class�� ������ ������ �ֱ� */
	SELECT c_day, c_start_h, c_start_m, c_lec_time
	INTO b_day, b_start_h, b_start_m, b_lec_time
	FROM class
	WHERE c_num = b_class_id and c_div = b_class_id_no;
	
	checkCollide := 0;
	
	/* ������ ��� ȯ���� �ð� ��� */
	a_start_time := (60 * a_start_h) + a_start_m;
	a_end_time := a_start_time + a_lec_time;
	b_start_time := (60 * b_start_h) + b_start_m;
	b_end_time := b_start_time + b_lec_time;

	/* �ð��� �浹�ϴ��� �˻� */
	IF (a_day = b_day) THEN
		IF (a_start_time = b_start_time) THEN
			checkCollide := 1;
		ELSIF (a_start_time > b_start_time) THEN
			IF (b_end_time > a_start_time) THEN
				checkCollide := 1;
			END IF;
		ELSIF (a_start_time < b_start_time) THEN
			IF (a_end_time > b_start_time) THEN
				checkCollide := 1;
			END IF;
		END IF;
	END IF;
	COMMIT;
	RETURN checkCollide;
END;
/