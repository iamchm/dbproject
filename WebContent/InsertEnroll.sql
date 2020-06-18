CREATE OR REPLACE PROCEDURE InsertEnroll (
	/* IN parameters: �й�, �����ȣ, �й� */
	sStudentId IN VARCHAR2,
	sCourseId IN VARCHAR2,
	nCourseIdNo IN NUMBER,
	/* OUT parameter: �Է� ��� �޽��� */
	result OUT VARCHAR2 )
IS 
	/* EXCEPTION�� */
	too_many_sumCourseUnit EXCEPTION; -- �ִ����� �ʰ�
	too_many_courses EXCEPTION; -- �̹� ��ϵ� ���� ��û
	too_many_students EXCEPTION; -- ������û �ο� �ʰ�
	duplicate_time EXCEPTION; -- �̹� ��ϵ� ���� �� �ߺ��Ǵ� �ð� ����
	/* �ʿ��� ������ */
	nYear NUMBER;
	nSemester NUMBER;
	nSumCourseUnit NUMBER;
	nCourseUnit NUMBER;
	nCnt NUMBER;
	nTeachMax NUMBER;
	check_Collide NUMBER;
	/* Ŀ�� */
	CURSOR enroll_cursor(enYear enroll.en_year%TYPE, enSem enroll.en_semester%TYPE) IS
		SELECT *
		FROM enroll
		WHERE en_sNUM = sStudentID and en_year = enYear and en_semester = enSem;
	
BEGIN
	result := '';
	DBMS_OUTPUT.put_line('#');
	DBMS_OUTPUT.put_line(sStudentId || '���� �����ȣ ' || sCourseId || ', �й�' || TO_CHAR(nCourseIdNo) || '�� ���� ����� ��û�Ͽ����ϴ�.');
	
	/* ���� �⵵�� �б� �˾Ƴ��� */
	nYear := Date2EnrollYear(SYSDATE);
	nSemester := Date2EnrollSemester(SYSDATE);

	/* ���� ó�� 1: �ִ����� �ʰ� ���� */
	SELECT SUM(c.c_grade)
	INTO nSumCourseUnit
	FROM class c, enroll e
	WHERE e.en_sNum = sStudentId and e.en_year = nYear and e.en_semester = nSemester and e.en_cNum = c.c_num and e.en_cDiv = c.c_div;

	SELECT c_grade
	INTO nCourseUnit
	FROM class
	WHERE c_num = sCourseId and c_div = nCourseIdNo;
	
	IF (nSumCourseUnit + nCourseUnit > 18)
	THEN
		RAISE too_many_sumCourseUnit;
	END IF;

	/* ���� ó�� 2: ������ ���� ��û ���� */
	SELECT COUNT(*)
	INTO nCnt
	FROM enroll
	WHERE en_sNum = sStudentId and en_cNum = sCourseID;
	
	IF (nCnt > 0)
	THEN
		RAISE too_many_courses;
	END IF;

	/* ���� ó�� 3: ������û �ο� �ʰ� ���� */
	SELECT c_max_students
	INTO nTeachMax
	FROM class
	WHERE c_year = nYear and c_semester = nSemester and c_num = sCourseId and c_div = nCourseIdNo;

	SELECT COUNT(*)
	INTO nCnt
	FROM enroll
	WHERE en_year = nYear and en_semester = nSemester and en_cNum = sCourseId and en_cDiv = nCourseIdNo;

	IF (nCnt >= nTeachMax)
	THEN
		RAISE too_many_students;
	END IF;
	
	/* ���� ó�� 4: ��û�� ����� �ð� �ߺ� ���� */
	check_Collide := 0;
	FOR enroll_list IN enroll_cursor(nYear, nSemester) LOOP
		check_Collide := doesCollide(sCourseId, nCourseIdNo, enroll_list.en_cNum, enroll_list.en_cDiv);
		IF (check_Collide > 0)
		THEN
			RAISE duplicate_time;
		END IF;
	END LOOP;
	
	/* ���� ��û ��� */
	INSERT INTO enroll(en_sNum, en_cNum, en_cDiv, en_year, en_semester)
	VALUES (sStudentId, sCourseId, nCourseIdNo, nYear, nSemester);
	
	UPDATE student
	SET s_total_grade = nSumCourseUnit + nCourseUnit
	WHERE s_num = sStudentId;
	
	COMMIT;
	result := '������û ����� �Ϸ�Ǿ����ϴ�.';
	
EXCEPTION
	WHEN too_many_sumCourseUnit THEN
		result := '�ִ������� �ʰ��Ͽ����ϴ�.';
	WHEN too_many_courses THEN
		result := '�̹� ��ϵ� ������ ��û�Ͽ����ϴ�.';
	WHEN too_many_students THEN
		result := '������û �ο��� �ʰ��Ǿ� ����� �Ұ����մϴ�.';
	WHEN duplicate_time THEN
		result := '�̹� ��ϵ� ���� �� �ߺ��Ǵ� �ð��� �����մϴ�.';
	WHEN OTHERS THEN
		ROLLBACK;
		result := SQLCODE;
	END;
/
	