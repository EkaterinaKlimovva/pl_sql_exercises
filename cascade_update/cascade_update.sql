CREATE OR REPLACE PROCEDURE cascade_update 
    (p_main_table VARCHAR2, 
    p_sub_table IN VARCHAR2) AUTHID CURRENT_USER IS
    v_main_table_name VARCHAR2(30000) := UPPER(p_main_table);
    v_sub_table_name VARCHAR2(30000) := UPPER(p_sub_table);
    cnt NUMBER(30) := 0;
    temp1 NUMBER(30);
    temp2 NUMBER(30);
BEGIN     
    SELECT COUNT(table_name)
    INTO temp1
    FROM user_tables
    WHERE table_name = v_main_table_name;
        
    SELECT COUNT(table_name)
    INTO temp2
    FROM user_tables
    WHERE table_name = v_sub_table_name;
        
    IF temp1 = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Первой таблицы не существует');
    ELSIF temp2 = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Второй таблицы не существует');
    ELSE
        FOR cur IN (SELECT DISTINCT cc.table_name AS r_table_name,
                    cc.column_name AS r_column_name,
                    uc.constraint_name,
                    cr.table_name,
                    cr.column_name
                FROM user_cons_columns cc
                JOIN user_constraints uc 
                ON cc.constraint_name = uc.constraint_name
                JOIN user_cons_columns cr
                ON uc.r_constraint_name = cr.constraint_name
                WHERE uc.constraint_type = 'R'
                    AND uc.r_constraint_name IN (SELECT constraint_name
                                                FROM user_constraints
                                                WHERE table_name = 'EMPLOYEES'
                                                    AND constraint_type = 'P')
                ORDER BY cc.table_name) LOOP
            IF v_main_table_name != v_sub_table_name THEN
                IF cur.r_table_name = v_sub_table_name THEN 
                    DBMS_OUTPUT.PUT_LINE('Создан триггер: ' || cur.constraint_name || '_TRG');
                    EXECUTE IMMEDIATE 'CREATE OR REPLACE TRIGGER '
                                  || cur.constraint_name
                                  || '_TRG
                                 AFTER UPDATE OF '
                                  || cur.column_name
                                  || ' ON '
                                  || v_main_table_name
                                  || '
                                 FOR EACH ROW
                                 BEGIN
                                   UPDATE '
                                  || v_sub_table_name
                                  || ' SET '
                                  || cur.r_column_name
                                  || ' = :NEW.'
                                  || cur.column_name
                                  || ' WHERE '
                                  || cur.r_column_name
                                  || ' = :OLD.'
                                  || cur.column_name
                                  || ';
                                 END;';
            END IF;
        ELSE
            DBMS_OUTPUT.PUT_LINE('Создан триггер: ' || cur.constraint_name || '_TRG');
            IF cur.table_name = cur.r_table_name THEN
                EXECUTE IMMEDIATE 'CREATE OR REPLACE TRIGGER ' || cur.constraint_name || '_TRG' ||
                        ' AFTER UPDATE OF ' || cur.column_name || ' ON ' || cur.table_name ||
                        ' FOR EACH ROW
                        WHEN (NEW.'|| cur.r_column_name || ' IS NULL)
                        DECLARE
                           PRAGMA AUTONOMOUS_TRANSACTION;
                        BEGIN
                           IF :NEW.'|| cur.column_name || ' IS NOT NULL AND :OLD.'|| cur.column_name || ' <> :NEW.'|| cur.column_name || ' THEN
                              UPDATE '|| cur.table_name || '
                              SET '|| cur.r_column_name || ' = :NEW.'|| cur.column_name || '
                              WHERE '|| cur.r_column_name || ' = :OLD.'|| cur.column_name || ';
                              COMMIT;
                           END IF;
                        END;';
                    EXECUTE IMMEDIATE 'ALTER TABLE ' || cur.table_name || ' DROP CONSTRAINT ' || cur.constraint_name;
            ELSE
                EXECUTE IMMEDIATE 'CREATE OR REPLACE TRIGGER '
                                  || cur.constraint_name
                                  || '_TRG
                                 AFTER UPDATE OF '
                                  || cur.column_name
                                  || ' ON '
                                  || v_main_table_name
                                  || '
                                 FOR EACH ROW
                                 BEGIN
                                   UPDATE '
                                  || cur.r_table_name
                                  || ' SET '
                                  || cur.r_column_name
                                  || ' = :NEW.'
                                  || cur.column_name
                                  || ' WHERE '
                                  || cur.r_column_name
                                  || ' = :OLD.'
                                  || cur.column_name
                                  || ';
                                 END;';
            END IF;
        END IF;    
        cnt := cnt + 1;
        END LOOP;
        
        IF cnt = 0 THEN
            DBMS_OUTPUT.PUT_LINE('Нет связи между таблицами');
        END IF;
    END IF;
END cascade_update;
/
BEGIN
    cascade_update('employees', 'employees');
END;