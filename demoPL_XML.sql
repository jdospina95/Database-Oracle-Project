CREATE TABLE emp (
 empno  NUMBER(4) NOT NULL,
 ename  VARCHAR2(10),
 job    VARCHAR2(9),
 mgr    NUMBER(4),
 sal    NUMBER(7,2),
 deptno NUMBER(2));
 
 INSERT INTO emp VALUES
 (7369, 'SMITH', 'CLERK', 7902, 800, 20);
INSERT INTO EMP VALUES
 (7499, 'ALLEN', 'SALESMAN', 7698, 1600, 30);
INSERT INTO EMP VALUES
 (7521, 'WARD', 'SALESMAN', 7698, 1250, 30);
INSERT INTO EMP VALUES
 (7566, 'JONES', 'MANAGER', 7839, 2975, 20);
INSERT INTO EMP VALUES
 (7654, 'MARTIN', 'SALESMAN', 7698, 1250, 30);
INSERT INTO EMP VALUES
 (7698, 'BLAKE', 'MANAGER', 7839, 2850, 30);
INSERT INTO EMP VALUES
 (7782, 'CLARK', 'MANAGER', 7839, 2450, 10);
INSERT INTO EMP VALUES
 (7788, 'SCOTT', 'ANALYST', 7566, 3000, 20);
INSERT INTO EMP VALUES
 (7839, 'KING', 'PRESIDENT', NULL, 5000, 10);
INSERT INTO EMP VALUES
 (7844, 'TURNER', 'SALESMAN', 7698, 1500, 30);
INSERT INTO EMP VALUES
 (7876, 'ADAMS', 'CLERK', 7788, 1100, 20);
INSERT INTO EMP VALUES
 (7900, 'JAMES', 'CLERK', 7698, 950, 30);
INSERT INTO EMP VALUES
 (7902, 'FORD', 'ANALYST', 7566, 3000, 60);
INSERT INTO EMP VALUES
 (7934, 'MILLER', 'CLERK', 7782, 1300, 10);
COMMIT;

CREATE TABLE dept (
 deptno NUMBER(2),
 dname  VARCHAR2(15),
 loc    VARCHAR2(15));

INSERT INTO dept VALUES (10, 'ACCOUNTING', 'NEW YORK');
INSERT INTO dept VALUES (20, 'RESEARCH', 'DALLAS');
INSERT INTO dept VALUES (30, 'SALES', 'CHICAGO');
INSERT INTO dept VALUES (40, 'OPERATIONS', 'BOSTON');
COMMIT;

SELECT XMLELEMENT("name", e.ename) AS employee
FROM   emp e
WHERE  e.empno = 7782;

SELECT XMLELEMENT("employee",
         XMLELEMENT("works_number", e.empno),
         XMLELEMENT("name", e.ename)
       ) AS employee
FROM   emp e
WHERE  e.empno = 7782;

SELECT XMLELEMENT("employee",
         XMLATTRIBUTES(
           e.empno AS "works_number",
           e.ename AS "name")
       ) AS employee
FROM   emp e
WHERE  e.empno = 7782;


SELECT XMLELEMENT("employee",
         XMLATTRIBUTES(e.empno AS "works_number"),
         XMLELEMENT("name",e.ename),
         XMLELEMENT("job",e.job)
       ) AS employee
FROM   emp e
WHERE  e.empno = 7782;

SELECT XMLELEMENT("employee",
         XMLFOREST(
           e.empno AS "works_number",
           e.ename AS "name",
           e.job AS "job")
       ) AS employee
FROM   emp e
WHERE  e.empno = 7782;


SELECT XMLELEMENT("employee",
         XMLFOREST(
           e.empno AS "works_number",
           e.ename AS "name")
       ) AS employees
FROM   emp e
WHERE  e.deptno = 10;

SELECT XMLAGG(
         XMLELEMENT("employee",
           XMLFOREST(
             e.empno AS "works_number",
             e.ename AS "name")
         )
       ) AS employees
FROM   emp e
WHERE  e.deptno = 10;

SELECT XMLELEMENT("employees",
         XMLAGG(
           XMLELEMENT("employee",
             XMLFOREST(
               e.empno AS "works_number",
               e.ename AS "name")
           )
         )
       ) AS employees
FROM   emp e
WHERE  e.deptno = 10;




create table XMLTable (doc_id number, xml_data XMLType);

insert into XMLTable values (1,
XMLType('<FAQLIST>
<QUESTION>
<QUERY>Question 1</QUERY>
<RESPONSE>Answer goes here.</RESPONSE>
</QUESTION>
</FAQLIST>'));


insert into XMLTable values (1,
XMLType('<FAQLIST>
<QUESTION>
<QUERY>Pregunta 2</QUERY>
<RESPONSE>Que es una base de datos?.</RESPONSE>
</QUESTION>
</FAQLIST>'));

select extractValue(xml_data, '/FAQLIST/
QUESTION/QUERY') ---XPathexpression
from XMLTable
where existsNode(xml_data, '/FAQLIST/
QUESTION[RESPONSE="Que es una base de datos?."]') = 1;

select * from XMLTable
create index XMLTable_ind on XMLTable
(extractValue(xml_data, '/FAQLIST/
QUESTION/QUERY') );


CREATE TABLE EMPLOYEES
(
   id     NUMBER,
   data   XMLTYPE
);


INSERT INTO EMPLOYEES
     VALUES (1, xmltype ('<Employees>
    <Employee emplid="1111" type="admin">
        <firstname>John</firstname>
        <lastname>Watson</lastname>
        <age>30</age>
        <email>johnwatson@sh.com</email>
    </Employee>
    <Employee emplid="2222" type="admin">
        <firstname>Sherlock</firstname>
        <lastname>Homes</lastname>
        <age>32</age>
        <email>sherlock@sh.com</email>
    </Employee>
    <Employee emplid="3333" type="user">
        <firstname>Jim</firstname>
        <lastname>Moriarty</lastname>
        <age>52</age>
        <email>jim@sh.com</email>
    </Employee>
    <Employee emplid="4444" type="user">
        <firstname>Mycroft</firstname>
        <lastname>Holmes</lastname>
        <age>41</age>
        <email>mycroft@sh.com</email>
    </Employee>
</Employees>'));


---retorna primer nombre y segundo nombre de los emplreados

SELECT t.id, x.*
     FROM employees t,
          XMLTABLE ('/Employees/Employee'
                    PASSING t.data
                    COLUMNS firstname VARCHAR2(30) PATH 'firstname', 
                            lastname VARCHAR2(30) PATH 'lastname') x
    WHERE t.id = 1;

	----Muestra Primer nombre de los empleados text() indica el valor de ese campo
   SELECT t.id, x.*
     FROM employees t,
          XMLTABLE ('/Employees/Employee/firstname'
                    PASSING t.data
                    COLUMNS firstname VARCHAR2 (30) PATH 'text()') x
    WHERE t.id = 1;

-- Imprime el primer nombre y el tipo @indica un atributo
   SELECT emp.id, x.*
     FROM employees emp,
          XMLTABLE ('/Employees/Employee'
                    PASSING emp.data
                    COLUMNS firstname VARCHAR2(30) PATH 'firstname',
                            type VARCHAR2(30) PATH '@type') x;

---imprime nombres de los emppleado con id 2222 

   SELECT t.id, x.*
     FROM employees t,
          XMLTABLE ('/Employees/Employee[@emplid=2222]'
                    PASSING t.data
                    COLUMNS firstname VARCHAR2(30) PATH 'firstname', 
                            lastname VARCHAR2(30) PATH 'lastname') x
    WHERE t.id = 1;


--Muestra nombres de los empleados cuando son admins 
   SELECT t.id, x.*
     FROM employees t,
          XMLTABLE ('/Employees/Employee[@type="admin"]'
                    PASSING t.data
                    COLUMNS firstname VARCHAR2(30) PATH 'firstname', 
                            lastname VARCHAR2(30) PATH 'lastname') x
    WHERE t.id = 1;

--Muestra nombres de los empleados cuando la  edad  > 40
   SELECT t.id, x.*
     FROM employees t,
          XMLTABLE ('/Employees/Employee[age>40]'
                    PASSING t.data
                    COLUMNS firstname VARCHAR2(30) PATH 'firstname', 
                            lastname VARCHAR2(30) PATH 'lastname',
                            age VARCHAR2(30) PATH 'age') x
    WHERE t.id = 1;

