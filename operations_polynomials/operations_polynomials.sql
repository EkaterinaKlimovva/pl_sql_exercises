CREATE OR REPLACE PACKAGE Polynomial IS
    FUNCTION OpenBrackets (
        Polynom VARCHAR2
    ) RETURN VARCHAR2;
    
    FUNCTION OperationsPolynomials (
        fPolynom VARCHAR2,
        sPolynom VARCHAR2,
        operation VARCHAR2
    ) RETURN VARCHAR2;
    
    FUNCTION RowPolynomial (
        Polynom VARCHAR2,
        RowP NUMBER
    ) RETURN VARCHAR2;
       
    FUNCTION SimplificationPolynomial (
        Polynom VARCHAR2
    ) RETURN VARCHAR2;
END Polynomial;
/
CREATE OR REPLACE PACKAGE BODY Polynomial IS
    FUNCTION OpenBrackets (
        Polynom VARCHAR2
    ) RETURN VARCHAR2 IS
        output VARCHAR2(100) := '';
        otp VARCHAR2(100) := '';
        
        TYPE Tnom IS TABLE OF VARCHAR2(100)
            INDEX BY PLS_INTEGER;
        nom Tnom;
        
        TYPE Tcount IS TABLE OF VARCHAR2(100)
            INDEX BY PLS_INTEGER;
        cnt Tcount;
        
        sbstr VARCHAR2(100);
    BEGIN 
    IF REGEXP_COUNT(Polynom, '\(') = REGEXP_COUNT(Polynom, '\)') 
        AND REGEXP_COUNT(Polynom, '[^\(\)0-9\^x\+\-]') = 0 THEN
        IF REGEXP_COUNT(Polynom, '\(') > 1 THEN
            FOR i IN 1 .. REGEXP_COUNT(Polynom, '\(') LOOP
                nom(i) := REGEXP_SUBSTR(Polynom, '\([^\(\)]*\)', 1, i);
            END LOOP;
            IF nom.LAST > 1 THEN
                FOR j IN REVERSE 2 .. nom.LAST LOOP 
                    sbstr := '';
                    FOR k IN 1 .. REGEXP_COUNT(nom(j - 1), '\+|\-') - REGEXP_COUNT(nom(j - 1), '^\(\-') + 1 LOOP
                        FOR l IN 1 .. REGEXP_COUNT(nom(j), '\+|\-') - REGEXP_COUNT(nom(j), '^\(\-') + 1 LOOP  
                            IF l = 1 AND k = 1 THEN
                                        IF INSTR(REGEXP_SUBSTR(nom(j-1), '[+-]*[^\^]\d+x*(\^\d+)*|\d+x*(\^\d+)*', 1, k), 'x') != 0 
                                            AND INSTR(SUBSTR(REGEXP_SUBSTR(nom(j), '[+-]*[^\^]\d+x*(\^\d+)*|\d+x*(\^\d+)*', 1, l), 2), 'x') = 0 
                                            AND INSTR(SUBSTR(REGEXP_SUBSTR(nom(j-1), '[+-]*[^\^]\d+x*(\^\d+)*|\d+x*(\^\d+)*', 1, k), 2), 'x^') = 0 
                                            AND INSTR(SUBSTR(REGEXP_SUBSTR(nom(j), '[+-]*[^\^]\d+x*(\^\d+)*|\d+x*(\^\d+)*', 1, l), 2), 'x^') = 0 THEN     
                                                sbstr := '(' || REGEXP_SUBSTR(REGEXP_SUBSTR(nom(j-1), '^\-*\d+|\-*[^\^]\d+', 1, k), '\-*\d+') * REGEXP_SUBSTR(REGEXP_SUBSTR(nom(j), '^\-*\d+|\-*[^\^]\d+', 1, l), '\-*\d+') || 'x';
                                        ELSIF INSTR(REGEXP_SUBSTR(nom(j-1), '[+-]*[^\^]\d+x*(\^\d+)*|\d+x*(\^\d+)*', 1, k), 'x') != 0 
                                            AND INSTR(SUBSTR(REGEXP_SUBSTR(nom(j), '[+-]*[^\^]\d+x*(\^\d+)*|\d+x*(\^\d+)*', 1, l), 2), 'x') = 0 
                                            AND INSTR(SUBSTR(REGEXP_SUBSTR(nom(j-1), '[+-]*[^\^]\d+x*(\^\d+)*|\d+x*(\^\d+)*', 1, k), 2), 'x^') != 0
                                            AND INSTR(SUBSTR(REGEXP_SUBSTR(nom(j), '[+-]*[^\^]\d+x*(\^\d+)*|\d+x*(\^\d+)*', 1, l), 2), 'x^') = 0 THEN  
                                                sbstr := '(' || REGEXP_SUBSTR(REGEXP_SUBSTR(nom(j-1), '^\-*\d+|\-*[^\^]\d+', 1, k), '\-*\d+') * REGEXP_SUBSTR(REGEXP_SUBSTR(nom(j), '^\-*\d+|\-*[^\^]\d+', 1, l), '\-*\d+') 
                                                    || 'x^' || SUBSTR(REGEXP_SUBSTR(nom(j - 1), '\^\d+', REGEXP_INSTR(nom(j - 1), '^\-*\d+|\-*[^\^]\d+', 1, k)), 2); 
                                        ELSIF INSTR(REGEXP_SUBSTR(nom(j-1), '[+-]*[^\^]\d+x*(\^\d+)*|\d+x*(\^\d+)*', 1, k), 'x') != 0 
                                            AND INSTR(SUBSTR(REGEXP_SUBSTR(nom(j), '[+-]*[^\^]\d+x*(\^\d+)*|\d+x*(\^\d+)*', 1, l), 2), 'x') != 0 
                                            AND INSTR(SUBSTR(REGEXP_SUBSTR(nom(j-1), '[+-]*[^\^]\d+x*(\^\d+)*|\d+x*(\^\d+)*', 1, k), 2), 'x^') = 0
                                            AND INSTR(SUBSTR(REGEXP_SUBSTR(nom(j), '[+-]*[^\^]\d+x*(\^\d+)*|\d+x*(\^\d+)*', 1, l), 2), 'x^') = 0 THEN  
                                                sbstr := '(' || REGEXP_SUBSTR(REGEXP_SUBSTR(nom(j-1), '^\-*\d+|\-*[^\^]\d+', 1, k), '\-*\d+') * REGEXP_SUBSTR(REGEXP_SUBSTR(nom(j), '^\-*\d+|\-*[^\^]\d+', 1, l), '\-*\d+') || 'x^2'; 
                                        ELSIF INSTR(REGEXP_SUBSTR(nom(j-1), '[+-]*[^\^]\d+x*(\^\d+)*|\d+x*(\^\d+)*', 1, k), 'x') != 0 
                                            AND INSTR(SUBSTR(REGEXP_SUBSTR(nom(j), '[+-]*[^\^]\d+x*(\^\d+)*|\d+x*(\^\d+)*', 1, l), 2), 'x') != 0 
                                            AND INSTR(SUBSTR(REGEXP_SUBSTR(nom(j-1), '[+-]*[^\^]\d+x*(\^\d+)*|\d+x*(\^\d+)*', 1, k), 2), 'x^') = 0
                                            AND INSTR(SUBSTR(REGEXP_SUBSTR(nom(j), '[+-]*[^\^]\d+x*(\^\d+)*|\d+x*(\^\d+)*', 1, l), 2), 'x^') != 0 THEN  
                                                sbstr := '(' || REGEXP_SUBSTR(REGEXP_SUBSTR(nom(j-1), '^\-*\d+|\-*[^\^]\d+', 1, k), '\-*\d+') * REGEXP_SUBSTR(REGEXP_SUBSTR(nom(j), '^\-*\d+|\-*[^\^]\d+', 1, l), '\-*\d+') 
                                                    || 'x^' || (SUBSTR(REGEXP_SUBSTR(nom(j), '\^\d+', REGEXP_INSTR(nom(j), '^\-*\d+|\-*[^\^]\d+', 1, l)), 2) + 1); 
                                        ELSIF INSTR(REGEXP_SUBSTR(nom(j-1), '[+-]*[^\^]\d+x*(\^\d+)*|\d+x*(\^\d+)*', 1, k), 'x') != 0 
                                            AND INSTR(SUBSTR(REGEXP_SUBSTR(nom(j), '[+-]*[^\^]\d+x*(\^\d+)*|\d+x*(\^\d+)*', 1, l), 2), 'x') != 0 
                                            AND INSTR(SUBSTR(REGEXP_SUBSTR(nom(j-1), '[+-]*[^\^]\d+x*(\^\d+)*|\d+x*(\^\d+)*', 1, k), 2), 'x^') != 0
                                            AND INSTR(SUBSTR(REGEXP_SUBSTR(nom(j), '[+-]*[^\^]\d+x*(\^\d+)*|\d+x*(\^\d+)*', 1, l), 2), 'x^') = 0 THEN  
                                                sbstr := '(' || REGEXP_SUBSTR(REGEXP_SUBSTR(nom(j-1), '^\-*\d+|\-*[^\^]\d+', 1, k), '\-*\d+') * REGEXP_SUBSTR(REGEXP_SUBSTR(nom(j), '^\-*\d+|\-*[^\^]\d+', 1, l), '\-*\d+') 
                                                    || 'x^' || (SUBSTR(REGEXP_SUBSTR(nom(j - 1), '\^\d+', REGEXP_INSTR(nom(j - 1), '^\-*\d+|\-*[^\^]\d+', 1, k)), 2) + 1); 
                                        ELSIF INSTR(REGEXP_SUBSTR(nom(j-1), '[+-]*[^\^]\d+x*(\^\d+)*|\d+x*(\^\d+)*', 1, k), 'x') != 0 
                                            AND INSTR(SUBSTR(REGEXP_SUBSTR(nom(j), '[+-]*[^\^]\d+x*(\^\d+)*|\d+x*(\^\d+)*', 1, l), 2), 'x') != 0 
                                            AND INSTR(SUBSTR(REGEXP_SUBSTR(nom(j-1), '[+-]*[^\^]\d+x*(\^\d+)*|\d+x*(\^\d+)*', 1, k), 2), 'x^') != 0
                                            AND INSTR(SUBSTR(REGEXP_SUBSTR(nom(j), '[+-]*[^\^]\d+x*(\^\d+)*|\d+x*(\^\d+)*', 1, l), 2), 'x^') != 0 THEN  
                                                sbstr := '(' || REGEXP_SUBSTR(REGEXP_SUBSTR(nom(j-1), '^\-*\d+|\-*[^\^]\d+', 1, k), '\-*\d+') * REGEXP_SUBSTR(REGEXP_SUBSTR(nom(j), '^\-*\d+|\-*[^\^]\d+', 1, l), '\-*\d+') 
                                                    || 'x^' || (SUBSTR(REGEXP_SUBSTR(nom(j - 1), '\^\d+', REGEXP_INSTR(nom(j - 1), '^\-*\d+|\-*[^\^]\d+', 1, k)), 2)
                                                    + (SUBSTR(REGEXP_SUBSTR(nom(j), '\^\d+', REGEXP_INSTR(nom(j), '^\-*\d+|\-*[^\^]\d+', 1, l)), 2)));
                                        ELSIF INSTR(REGEXP_SUBSTR(nom(j-1), '[+-]*[^\^]\d+x*(\^\d+)*|\d+x*(\^\d+)*', 1, k), 'x') = 0 
                                            AND INSTR(SUBSTR(REGEXP_SUBSTR(nom(j), '[+-]*[^\^]\d+x*(\^\d+)*|\d+x*(\^\d+)*', 1, l), 2), 'x') != 0 
                                            AND INSTR(SUBSTR(REGEXP_SUBSTR(nom(j-1), '[+-]*[^\^]\d+x*(\^\d+)*|\d+x*(\^\d+)*', 1, k), 2), 'x^') = 0
                                            AND INSTR(SUBSTR(REGEXP_SUBSTR(nom(j), '[+-]*[^\^]\d+x*(\^\d+)*|\d+x*(\^\d+)*', 1, l), 2), 'x^') = 0 THEN  
                                                sbstr := '(' || REGEXP_SUBSTR(REGEXP_SUBSTR(nom(j-1), '^\-*\d+|\-*[^\^]\d+', 1, k), '\-*\d+') * REGEXP_SUBSTR(REGEXP_SUBSTR(nom(j), '^\-*\d+|\-*[^\^]\d+', 1, l), '\-*\d+') || 'x'; 
                                        ELSIF INSTR(REGEXP_SUBSTR(nom(j-1), '[+-]*[^\^]\d+x*(\^\d+)*|\d+x*(\^\d+)*', 1, k), 'x') = 0 
                                            AND INSTR(SUBSTR(REGEXP_SUBSTR(nom(j), '[+-]*[^\^]\d+x*(\^\d+)*|\d+x*(\^\d+)*', 1, l), 2), 'x') != 0 
                                            AND INSTR(SUBSTR(REGEXP_SUBSTR(nom(j-1), '[+-]*[^\^]\d+x*(\^\d+)*|\d+x*(\^\d+)*', 1, k), 2), 'x^') = 0
                                            AND INSTR(SUBSTR(REGEXP_SUBSTR(nom(j), '[+-]*[^\^]\d+x*(\^\d+)*|\d+x*(\^\d+)*', 1, l), 2), 'x^') != 0 THEN  
                                                sbstr := '(' || REGEXP_SUBSTR(REGEXP_SUBSTR(nom(j-1), '^\-*\d+|\-*[^\^]\d+', 1, k), '\-*\d+') * REGEXP_SUBSTR(REGEXP_SUBSTR(nom(j), '^\-*\d+|\-*[^\^]\d+', 1, l), '\-*\d+') 
                                                    || 'x^' || SUBSTR(REGEXP_SUBSTR(nom(j), '\^\d+', REGEXP_INSTR(nom(j), '^\-*\d+|\-*[^\^]\d+', 1, l)), 2); 
                                        ELSE
                                            sbstr := '(' || REGEXP_SUBSTR(REGEXP_SUBSTR(nom(j-1), '^\-*\d+|\-*[^\^]\d+', 1, k), '\-*\d+') * REGEXP_SUBSTR(REGEXP_SUBSTR(nom(j), '^\-*\d+|\-*[^\^]\d+', 1, l), '\-*\d+');
                                    END IF;
                            ELSE 
                                        IF INSTR(REGEXP_SUBSTR(nom(j-1), '[+-]*[^\^]\d+x*(\^\d+)*|\d+x*(\^\d+)*', 1, k), 'x') != 0 
                                            AND INSTR(SUBSTR(REGEXP_SUBSTR(nom(j), '[+-]*[^\^]\d+x*(\^\d+)*|\d+x*(\^\d+)*', 1, l), 2), 'x') = 0 
                                            AND INSTR(SUBSTR(REGEXP_SUBSTR(nom(j-1), '[+-]*[^\^]\d+x*(\^\d+)*|\d+x*(\^\d+)*', 1, k), 2), 'x^') = 0 
                                            AND INSTR(SUBSTR(REGEXP_SUBSTR(nom(j), '[+-]*[^\^]\d+x*(\^\d+)*|\d+x*(\^\d+)*', 1, l), 2), 'x^') = 0 THEN  
                                                sbstr := sbstr || '+' || REGEXP_SUBSTR(REGEXP_SUBSTR(nom(j-1), '^\-*\d+|\-*[^\^]\d+', 1, k), '\-*\d+') * REGEXP_SUBSTR(REGEXP_SUBSTR(nom(j), '^\-*\d+|\-*[^\^]\d+', 1, l), '\-*\d+') 
                                                || 'x';
                                        ELSIF INSTR(REGEXP_SUBSTR(nom(j-1), '[+-]*[^\^]\d+x*(\^\d+)*|\d+x*(\^\d+)*', 1, k), 'x') != 0 
                                            AND INSTR(SUBSTR(REGEXP_SUBSTR(nom(j), '[+-]*[^\^]\d+x*(\^\d+)*|\d+x*(\^\d+)*', 1, l), 2), 'x') = 0 
                                            AND INSTR(SUBSTR(REGEXP_SUBSTR(nom(j-1), '[+-]*[^\^]\d+x*(\^\d+)*|\d+x*(\^\d+)*', 1, k), 2), 'x^') != 0
                                            AND INSTR(SUBSTR(REGEXP_SUBSTR(nom(j), '[+-]*[^\^]\d+x*(\^\d+)*|\d+x*(\^\d+)*', 1, l), 2), 'x^') = 0 THEN  
                                                sbstr := sbstr || '+' ||  REGEXP_SUBSTR(REGEXP_SUBSTR(nom(j-1), '^\-*\d+|\-*[^\^]\d+', 1, k), '\-*\d+') * REGEXP_SUBSTR(REGEXP_SUBSTR(nom(j), '^\-*\d+|\-*[^\^]\d+', 1, l), '\-*\d+') 
                                                || 'x^' 
                                                    || SUBSTR(REGEXP_SUBSTR(nom(j - 1), '\^\d+', REGEXP_INSTR(nom(j - 1), '^\-*\d+|\-*[^\^]\d+', 1, k)), 2); 
                                        ELSIF INSTR(REGEXP_SUBSTR(nom(j-1), '[+-]*[^\^]\d+x*(\^\d+)*|\d+x*(\^\d+)*', 1, k), 'x') != 0 
                                            AND INSTR(SUBSTR(REGEXP_SUBSTR(nom(j), '[+-]*[^\^]\d+x*(\^\d+)*|\d+x*(\^\d+)*', 1, l), 2), 'x') != 0 
                                            AND INSTR(SUBSTR(REGEXP_SUBSTR(nom(j-1), '[+-]*[^\^]\d+x*(\^\d+)*|\d+x*(\^\d+)*', 1, k), 2), 'x^') = 0
                                            AND INSTR(SUBSTR(REGEXP_SUBSTR(nom(j), '[+-]*[^\^]\d+x*(\^\d+)*|\d+x*(\^\d+)*', 1, l), 2), 'x^') = 0 THEN  
                                                sbstr := sbstr || '+' ||  REGEXP_SUBSTR(REGEXP_SUBSTR(nom(j-1), '^\-*\d+|\-*[^\^]\d+', 1, k), '\-*\d+') * REGEXP_SUBSTR(REGEXP_SUBSTR(nom(j), '^\-*\d+|\-*[^\^]\d+', 1, l), '\-*\d+') 
                                                || 'x^2'; 
                                        ELSIF INSTR(REGEXP_SUBSTR(nom(j-1), '[+-]*[^\^]\d+x*(\^\d+)*|\d+x*(\^\d+)*', 1, k), 'x') != 0 
                                            AND INSTR(SUBSTR(REGEXP_SUBSTR(nom(j), '[+-]*[^\^]\d+x*(\^\d+)*|\d+x*(\^\d+)*', 1, l), 2), 'x') != 0 
                                            AND INSTR(SUBSTR(REGEXP_SUBSTR(nom(j-1), '[+-]*[^\^]\d+x*(\^\d+)*|\d+x*(\^\d+)*', 1, k), 2), 'x^') = 0
                                            AND INSTR(SUBSTR(REGEXP_SUBSTR(nom(j), '[+-]*[^\^]\d+x*(\^\d+)*|\d+x*(\^\d+)*', 1, l), 2), 'x^') != 0 THEN  
                                                sbstr := sbstr || '+' ||  REGEXP_SUBSTR(REGEXP_SUBSTR(nom(j-1), '^\-*\d+|\-*[^\^]\d+', 1, k), '\-*\d+') * REGEXP_SUBSTR(REGEXP_SUBSTR(nom(j), '^\-*\d+|\-*[^\^]\d+', 1, l), '\-*\d+')
                                                    || 'x^' || (SUBSTR(REGEXP_SUBSTR(nom(j), '\^\d+', REGEXP_INSTR(nom(j), '^\-*\d+|\-*[^\^]\d+', 1, l)), 2) + 1); 
                                        ELSIF INSTR(REGEXP_SUBSTR(nom(j-1), '[+-]*[^\^]\d+x*(\^\d+)*|\d+x*(\^\d+)*', 1, k), 'x') != 0 
                                            AND INSTR(SUBSTR(REGEXP_SUBSTR(nom(j), '[+-]*[^\^]\d+x*(\^\d+)*|\d+x*(\^\d+)*', 1, l), 2), 'x') != 0 
                                            AND INSTR(SUBSTR(REGEXP_SUBSTR(nom(j-1), '[+-]*[^\^]\d+x*(\^\d+)*|\d+x*(\^\d+)*', 1, k), 2), 'x^') != 0
                                            AND INSTR(SUBSTR(REGEXP_SUBSTR(nom(j), '[+-]*[^\^]\d+x*(\^\d+)*|\d+x*(\^\d+)*', 1, l), 2), 'x^') = 0 THEN  
                                                sbstr := sbstr || '+' ||  REGEXP_SUBSTR(REGEXP_SUBSTR(nom(j-1), '^\-*\d+|\-*[^\^]\d+', 1, k), '\-*\d+') * REGEXP_SUBSTR(REGEXP_SUBSTR(nom(j), '^\-*\d+|\-*[^\^]\d+', 1, l), '\-*\d+')
                                                    || 'x^' || (SUBSTR(REGEXP_SUBSTR(nom(j - 1), '\^\d+', REGEXP_INSTR(nom(j - 1), '^\-*\d+|\-*[^\^]\d+', 1, k)), 2) + 1); 
                                        ELSIF INSTR(REGEXP_SUBSTR(nom(j-1), '[+-]*[^\^]\d+x*(\^\d+)*|\d+x*(\^\d+)*', 1, k), 'x') != 0 
                                            AND INSTR(SUBSTR(REGEXP_SUBSTR(nom(j), '[+-]*[^\^]\d+x*(\^\d+)*|\d+x*(\^\d+)*', 1, l), 2), 'x') != 0 
                                            AND INSTR(SUBSTR(REGEXP_SUBSTR(nom(j-1), '[+-]*[^\^]\d+x*(\^\d+)*|\d+x*(\^\d+)*', 1, k), 2), 'x^') != 0
                                            AND INSTR(SUBSTR(REGEXP_SUBSTR(nom(j), '[+-]*[^\^]\d+x*(\^\d+)*|\d+x*(\^\d+)*', 1, l), 2), 'x^') != 0 THEN  
                                                sbstr := sbstr || '+' ||  REGEXP_SUBSTR(REGEXP_SUBSTR(nom(j-1), '^\-*\d+|\-*[^\^]\d+', 1, k), '\-*\d+') * REGEXP_SUBSTR(REGEXP_SUBSTR(nom(j), '^\-*\d+|\-*[^\^]\d+', 1, l), '\-*\d+')
                                                    || 'x^' || (SUBSTR(REGEXP_SUBSTR(nom(j), '\^\d+', REGEXP_INSTR(nom(j), '^\-*\d+|\-*[^\^]\d+', 1, l)), 2)
                                                    + SUBSTR(REGEXP_SUBSTR(nom(j - 1), '\^\d+', REGEXP_INSTR(nom(j - 1), '^\-*\d+|\-*[^\^]\d+', 1, k)), 2));
                                        ELSIF INSTR(REGEXP_SUBSTR(nom(j-1), '[+-]*[^\^]\d+x*(\^\d+)*|\d+x*(\^\d+)*', 1, k), 'x') = 0 
                                            AND INSTR(SUBSTR(REGEXP_SUBSTR(nom(j), '[+-]*[^\^]\d+x*(\^\d+)*|\d+x*(\^\d+)*', 1, l), 2), 'x') != 0 
                                            AND INSTR(SUBSTR(REGEXP_SUBSTR(nom(j-1), '[+-]*[^\^]\d+x*(\^\d+)*|\d+x*(\^\d+)*', 1, k), 2), 'x^') = 0
                                            AND INSTR(SUBSTR(REGEXP_SUBSTR(nom(j), '[+-]*[^\^]\d+x*(\^\d+)*|\d+x*(\^\d+)*', 1, l), 2), 'x^') = 0 THEN   
                                                sbstr := sbstr ||  '+' || 
                                                REGEXP_SUBSTR(REGEXP_SUBSTR(nom(j-1), '^\-*\d+|\-*[^\^]\d+', 1, k), '\-*\d+') * REGEXP_SUBSTR(REGEXP_SUBSTR(nom(j), '^\-*\d+|\-*[^\^]\d+', 1, l), '\-*\d+') || 'x'; 
                                        ELSIF INSTR(REGEXP_SUBSTR(nom(j-1), '[+-]*[^\^]\d+x*(\^\d+)*|\d+x*(\^\d+)*', 1, k), 'x') = 0 
                                            AND INSTR(SUBSTR(REGEXP_SUBSTR(nom(j), '[+-]*[^\^]\d+x*(\^\d+)*|\d+x*(\^\d+)*', 1, l), 2), 'x') != 0 
                                            AND INSTR(SUBSTR(REGEXP_SUBSTR(nom(j-1), '[+-]*[^\^]\d+x*(\^\d+)*|\d+x*(\^\d+)*', 1, k), 2), 'x^') = 0
                                            AND INSTR(SUBSTR(REGEXP_SUBSTR(nom(j), '[+-]*[^\^]\d+x*(\^\d+)*|\d+x*(\^\d+)*', 1, l), 2), 'x^') != 0 THEN  
                                                sbstr := sbstr || '+' ||  REGEXP_SUBSTR(REGEXP_SUBSTR(nom(j-1), '^\-*\d+|\-*[^\^]\d+', 1, k), '\-*\d+') * REGEXP_SUBSTR(REGEXP_SUBSTR(nom(j), '^\-*\d+|\-*[^\^]\d+', 1, l), '\-*\d+')
                                                    || 'x^' || SUBSTR(REGEXP_SUBSTR(nom(j), '\^\d+', REGEXP_INSTR(nom(j), '^\-*\d+|\-*[^\^]\d+', 1, l)), 2);
                                        ELSE
                                            sbstr := sbstr || '+' ||  REGEXP_SUBSTR(REGEXP_SUBSTR(nom(j-1), '^\-*\d+|\-*[^\^]\d+', 1, k), '\-*\d+') * REGEXP_SUBSTR(REGEXP_SUBSTR(nom(j), '^\-*\d+|\-*[^\^]\d+', 1, l), '\-*\d+');
                                    END IF;               
                            END IF;
                        END LOOP;
                    END LOOP;    
                        nom(j - 1) := sbstr || ')';
                        nom(j) := ' ';
                END LOOP;
            END IF;     
            output := SUBSTR(nom(1), 2, LENGTH(nom(1)) - 2);
        ELSE
            IF REGEXP_COUNT(Polynom, '(\-*\d+)*\(') > 0 THEN
                output := SUBSTR(Polynom, LENGTH(REGEXP_SUBSTR(Polynom, '(\-*\d+)*\(')) + 1, LENGTH(Polynom) -1 - LENGTH(REGEXP_SUBSTR(Polynom, '\-*\d*\(')));
            ELSE
                output := SUBSTR(Polynom, 2, LENGTH(Polynom) - 2);
            END IF;
        END IF;
        
        output := REPLACE(output, '-+', '+');
        output := REPLACE(output, '+-', '-');
        
        IF REGEXP_COUNT(Polynom, '\-*\d+\(') > 0 THEN
            FOR i IN 1 .. REGEXP_COUNT(output, '[\(+-]\d+|^\d+') LOOP   
                            IF i = 1 THEN
                                IF INSTR(REGEXP_SUBSTR(output, '[+-]*[^\^]\d+x*(\^\d+)*|\d+x*(\^\d+)*', 1, i), 'x') != 0 
                                    AND INSTR(REGEXP_SUBSTR(output, '[+-]*[^\^]\d+x*(\^\d+)*|\d+x*(\^\d+)*', 1, i), 'x^') = 0 THEN
                                        otp := otp ||
                                        SUBSTR(REGEXP_SUBSTR(Polynom, '\-?\d+\('), 1, LENGTH(REGEXP_SUBSTR(Polynom, '\-?\d+\(')) - 1) * REGEXP_SUBSTR(REGEXP_SUBSTR(output, '[+-]*[^\^]\d+x*(\^\d+)*|\d+x*(\^\d+)*', 1, i), '\-*\d+') 
                                        || 'x'; 
                                ELSIF INSTR(REGEXP_SUBSTR(output, '[+-]*[^\^]\d+x*(\^\d+)*|\d+x*(\^\d+)*', 1, i), 'x') != 0 
                                    AND INSTR(REGEXP_SUBSTR(output, '[+-]*[^\^]\d+x*(\^\d+)*|\d+x*(\^\d+)*', 1, i), 'x^') != 0 THEN
                                        otp := otp ||
                                        SUBSTR(REGEXP_SUBSTR(Polynom, '\-?\d+\('), 1, LENGTH(REGEXP_SUBSTR(Polynom, '\-?\d+\(')) - 1) * REGEXP_SUBSTR(REGEXP_SUBSTR(output, '[+-]*[^\^]\d+x*(\^\d+)*|\d+x*(\^\d+)*', 1, i), '\-*\d+')
                                        || 'x^' || SUBSTR(REGEXP_SUBSTR(REGEXP_SUBSTR(output, '[+-]*[^\^]\d+x*(\^\d+)*|\d+x*(\^\d+)*', 1, i), '\^\d+'), 2);
                                ELSE
                                    otp := otp || 
                                    SUBSTR(REGEXP_SUBSTR(Polynom, '\-?\d+\('), 1, LENGTH(REGEXP_SUBSTR(Polynom, '\-?\d+\(')) - 1) * REGEXP_SUBSTR(REGEXP_SUBSTR(output, '[+-]*[^\^]\d+x*(\^\d+)*|\d+x*(\^\d+)*', 1, i), '\-*\d+');
                                END IF;
                            ELSE
                                IF INSTR(REGEXP_SUBSTR(output, '[+-]*[^\^]\d+x*(\^\d+)*|\d+x*(\^\d+)*', 1, i), 'x') != 0 
                                    AND INSTR(REGEXP_SUBSTR(output, '[+-]*[^\^]\d+x*(\^\d+)*|\d+x*(\^\d+)*', 1, i), 'x^') = 0 THEN
                                        otp := otp || '+' ||
                                        SUBSTR(REGEXP_SUBSTR(Polynom, '\-?\d+\('), 1, LENGTH(REGEXP_SUBSTR(Polynom, '\-?\d+\(')) - 1) * REGEXP_SUBSTR(REGEXP_SUBSTR(output, '[+-]*[^\^]\d+x*(\^\d+)*|\d+x*(\^\d+)*', 1, i), '\-*\d+') 
                                        || 'x'; 
                                ELSIF INSTR(REGEXP_SUBSTR(output, '[+-]*[^\^]\d+x*(\^\d+)*|\d+x*(\^\d+)*', 1, i), 'x') != 0 
                                    AND INSTR(REGEXP_SUBSTR(output, '[+-]*[^\^]\d+x*(\^\d+)*|\d+x*(\^\d+)*', 1, i), 'x^') != 0 THEN
                                        otp := otp || '+' ||
                                        SUBSTR(REGEXP_SUBSTR(Polynom, '\-?\d+\('), 1, LENGTH(REGEXP_SUBSTR(Polynom, '\-?\d+\(')) - 1) * REGEXP_SUBSTR(REGEXP_SUBSTR(output, '[+-]*[^\^]\d+x*(\^\d+)*|\d+x*(\^\d+)*', 1, i), '\-*\d+')
                                        || 'x^' || SUBSTR(REGEXP_SUBSTR(REGEXP_SUBSTR(output, '[+-]*[^\^]\d+x*(\^\d+)*|\d+x*(\^\d+)*', 1, i), '\^\d+'), 2);
                                ELSE
                                    otp := otp || '+' ||
                                    SUBSTR(REGEXP_SUBSTR(Polynom, '\-?\d+\('), 1, LENGTH(REGEXP_SUBSTR(Polynom, '\-?\d+\(')) - 1) * REGEXP_SUBSTR(REGEXP_SUBSTR(output, '[+-]*[^\^]\d+x*(\^\d+)*|\d+x*(\^\d+)*', 1, i), '\-*\d+');
                                END IF; 
                            END IF;
            END LOOP;
            otp := REPLACE(otp, '-+', '+');
            otp := REPLACE(otp, '+-', '-');
        ELSE
            otp := output;
        END IF;
    END IF;
    
    IF REGEXP_COUNT(Polynom, '[^\(\)0-9\^x\+\-]') > 0 THEN
        DBMS_OUTPUT.PUT_LINE('Буква не х в многочлене');
    ELSIF REGEXP_COUNT(Polynom, '\(') != REGEXP_COUNT(Polynom, '\)') THEN
        DBMS_OUTPUT.PUT_LINE('Неверное количество скобок');
    END IF;
    RETURN otp;
        
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Ошибка');
                
    END OpenBrackets;
           
    FUNCTION OperationsPolynomials (
        fPolynom VARCHAR2,
        sPolynom VARCHAR2,
        operation VARCHAR2
    ) RETURN VARCHAR2 IS
        firstPolynom VARCHAR2(100) := fPolynom;
        secondPolynom VARCHAR2(100) := sPolynom;
    
        dl VARCHAR2(100) := '';
        ost VARCHAR2(100) := '';
        otv VARCHAR2(100) := '';
        stf VARCHAR2(100) := '';
        sts VARCHAR2(100) := '';
        nm NUMBER := 1;
        
        n1 NUMBER := 0;
        n2 NUMBER := 0;
        
        nL1 NUMBER := 0;
        nL2 NUMBER := 0;
        nL3 NUMBER := 0;
        
        sbstr VARCHAR2(100);
        newfirstPolynom VARCHAR2(100) := '';
        newsecondPolynom VARCHAR2(100) := '';
        
        TYPE Tn3 IS TABLE OF VARCHAR2(100)
                INDEX BY PLS_INTEGER;
        n3 Tn3;
        
        maxN NUMBER := 0;
        output VARCHAR2(100) := '';
        
        TYPE Tnom1 IS TABLE OF VARCHAR2(100)
            INDEX BY PLS_INTEGER;
        nom1 Tnom1;
        
        TYPE Tnom2 IS TABLE OF VARCHAR2(100)
            INDEX BY PLS_INTEGER;
        nom2 Tnom2;
        
        TYPE Tnom3 IS TABLE OF VARCHAR2(100)
            INDEX BY PLS_INTEGER;
        nom3 Tnom3;
    BEGIN
    IF operation NOT IN('+', '-', '*', '\') THEN
        output := 'Неверный знак операции';
    ELSE
        IF REGEXP_COUNT(firstPolynom, '\(') = REGEXP_COUNT(firstPolynom, '\)')
            AND REGEXP_COUNT(secondPolynom, '\(') = REGEXP_COUNT(secondPolynom, '\)') 
            AND REGEXP_COUNT(firstPolynom, '[^\(\)0-9\^x\+\-]') = 0 
            AND REGEXP_COUNT(secondPolynom, '[^\(\)0-9\^x\+\-]') = 0 THEN
            IF operation = '+' THEN
                firstPolynom := Polynomial.SimplificationPolynomial(firstPolynom);
                secondPolynom := Polynomial.SimplificationPolynomial(secondPolynom);
                
                IF REGEXP_COUNT(firstPolynom, '(\-\d+)?\([+-x0-9]*(\)\()*[+-x0-9]*\)') > 0 THEN
                    FOR i IN 1 .. REGEXP_COUNT(firstPolynom, '(\-\d+)?\([+-x0-9]*(\)\()*[+-x0-9]*\)') LOOP
                        sbstr := REGEXP_SUBSTR(firstPolynom, '(\-\d+)?\([+-x0-9]*(\)\()*[+-x0-9]*\)');
                        newfirstPolynom := Polynomial.OpenBrackets(sbstr);
                        firstPolynom := REPLACE(firstPolynom, sbstr, newfirstPolynom);
                    END LOOP;
                END IF;
                
                IF REGEXP_COUNT(secondPolynom, '(\-\d+)?\([+-x0-9]*(\)\()*[+-x0-9]*\)') > 0 THEN
                    FOR i IN 1 .. REGEXP_COUNT(secondPolynom, '(\-\d+)?\([+-x0-9]*(\)\()*[+-x0-9]*\)') LOOP
                        sbstr := REGEXP_SUBSTR(secondPolynom, '(\-\d+)?\([+-x0-9]*(\)\()*[+-x0-9]*\)');
                        newsecondPolynom := Polynomial.OpenBrackets(sbstr);
                        secondPolynom := REPLACE(secondPolynom, sbstr, newsecondPolynom);
                    END LOOP;
                END IF;
                
                IF REGEXP_COUNT(firstPolynom, '^\d+[+-\(]|[+-\(]\d+[+-\(]|[^\^]\d+$') > 0 THEN
                    FOR i IN 1 .. REGEXP_COUNT(firstPolynom, '^\d+[+-\(]|[+-\(]\d+[+-\(]|[^\^]\d+$') LOOP
                        nom1(i) := REGEXP_SUBSTR(firstPolynom, '^\d+[+-\(]|[+-\(]\d+[+-\(]|[^\^]\d+$', 1, i);
                    END LOOP;
                END IF;
                
                nL1 := nom1.LAST;
                IF REGEXP_COUNT(firstPolynom, '^\d+[+-\(]|[+-\(]\d+[+-\(]|[^\^]\d+$') > 0 THEN   
                    IF REGEXP_COUNT(secondPolynom, '^\d+[+-\(]|[+-\(]\d+[+-\(]|[^\^]\d+$') > 0 THEN
                        FOR i IN 1 .. REGEXP_COUNT(secondPolynom, '^\d+[+-\(]|[+-\(]\d+[+-\(]|[^\^]\d+$') LOOP
                            nom1(nL1 + i) := REGEXP_SUBSTR(secondPolynom, '^\d+[+-\(]|[+-\(]\d+[+-\(]|[^\^]\d+$', 1, i);
                        END LOOP;
                    END IF;
                ELSE
                    IF REGEXP_COUNT(secondPolynom, '^\d+[+-\(]|[+-\(]\d+[+-\(]|[^\^]\d+$') > 0 THEN
                        FOR i IN 1 .. REGEXP_COUNT(secondPolynom, '^\d+[+-\(]|[+-\(]\d+[+-\(]|[^\^]\d+$') LOOP
                            nom1(i) := REGEXP_SUBSTR(secondPolynom, '^\d+[+-\(]|[+-\(]\d+[+-\(]|[^\^]\d+$', 1, i);
                        END LOOP;
                    END IF;
                END IF;
                
                IF REGEXP_COUNT(firstPolynom, '^\d+x[+-]|[+-]\d+x[+-]|[+-]\d+x$') > 0 THEN
                    FOR i IN 1 .. REGEXP_COUNT(firstPolynom, '^\d+x[+-]|[+-]\d+x[+-]|[+-]\d+x$') LOOP
                        nom2(i) := REGEXP_SUBSTR(firstPolynom, '^\d+x[+-]|[+-]\d+x[+-]|[+-]\d+x$', 1, i);
                    END LOOP;
                END IF;
                
                nL2 := nom2.LAST;
                IF REGEXP_COUNT(firstPolynom, '^\d+x[+-]|[+-]\d+x[+-]|[+-]\d+x$') > 0 THEN
                    IF REGEXP_COUNT(secondPolynom, '^\d+x[+-]|[+-]\d+x[+-]|[+-]\d+x$') > 0 THEN
                        FOR i IN 1 .. REGEXP_COUNT(secondPolynom, '^\d+x[+-]|[+-]\d+x[+-]|[+-]\d+x$') LOOP
                            nom2(nL2 + i) := REGEXP_SUBSTR(secondPolynom, '^\d+x[+-]|[+-]\d+x[+-]|[+-]\d+x$', 1, i);
                        END LOOP;
                    END IF;        
                ELSE
                    IF REGEXP_COUNT(secondPolynom, '^\d+x[+-]|[+-]\d+x[+-]|[+-]\d+x$') > 0 THEN
                        FOR i IN 1 .. REGEXP_COUNT(secondPolynom, '^\d+x[+-]|[+-]\d+x[+-]|[+-]\d+x$') LOOP
                            nom2(i) := REGEXP_SUBSTR(secondPolynom, '^\d+x[+-]|[+-]\d+x[+-]|[+-]\d+x$', 1, i);
                        END LOOP;
                    END IF; 
                END IF;
                
                IF REGEXP_COUNT(firstPolynom, '[(+-]?\d+x\^\d+') > 0 THEN
                    FOR i IN 1 .. REGEXP_COUNT(firstPolynom, '[(+-]?\d+x\^\d+') LOOP
                        nom3(i) := REGEXP_SUBSTR(firstPolynom, '[(+-]?\d+x\^\d+', 1, i);
                        IF REGEXP_SUBSTR(nom3(i), '\d+', 1, 2) > maxN THEN
                            maxN := REGEXP_SUBSTR(nom3(i), '\d+', 1, 2);
                        END IF;
                    END LOOP;
                END IF;
                      
                nL3 := nom3.LAST;
                IF REGEXP_COUNT(firstPolynom, '[(+-]?\d+x\^\d+') > 0 THEN
                    IF REGEXP_COUNT(secondPolynom, '[(+-]?\d+x\^\d+') > 0 THEN
                        FOR i IN 1 .. REGEXP_COUNT(secondPolynom, '[(+-]?\d+x\^\d+') LOOP
                            nom3(nL3 + i) := REGEXP_SUBSTR(secondPolynom, '[(+-]?\d+x\^\d+', 1, i);
                            IF REGEXP_SUBSTR(nom3(nL3 + i), '\d+', 1, 2) > maxN THEN
                                maxN := REGEXP_SUBSTR(nom3(nL3 + i), '\d+', 1, 2);
                            END IF;
                        END LOOP;
                    END IF;
                ELSE 
                    IF  REGEXP_COUNT(secondPolynom, '[(+-]?\d+x\^\d+') > 0 THEN
                        FOR i IN 1 .. REGEXP_COUNT(secondPolynom, '[(+-]?\d+x\^\d+') LOOP
                            nom3(i) := REGEXP_SUBSTR(secondPolynom, '[(+-]?\d+x\^\d+', 1, i);
                            IF REGEXP_SUBSTR(nom3(i), '\d+', 1, 2) > maxN THEN
                                maxN := REGEXP_SUBSTR(nom3(i), '\d+', 1, 2);
                            END IF;
                        END LOOP;
                    END IF;
                END IF;
                
                IF nom1.LAST > 0 THEN
                    FOR i IN 1 .. nom1.LAST LOOP
                        IF SUBSTR(nom1(i), 1, 1) = '-' THEN
                            n1 := n1 - REGEXP_SUBSTR(nom1(i), '\d+');
                        ELSE
                            n1 := n1 + REGEXP_SUBSTR(nom1(i), '\d+');
                        END IF;
                    END LOOP;
                END IF;
                
                IF nom2.LAST > 0 THEN
                    FOR i IN 1 .. nom2.LAST LOOP
                        IF SUBSTR(nom2(i), 1, 1) = '-' THEN
                            n2 := n2 - REGEXP_SUBSTR(nom2(i), '\d+');
                        ELSE
                            n2 := n2 + REGEXP_SUBSTR(nom2(i), '\d+');
                        END IF;
                    END LOOP;
                END IF;
                
                IF maxN > 0 THEN
                    FOR i IN 2 .. maxN LOOP
                        n3(i) := 0;
                    END LOOP;
                END IF;
                
                IF maxN > 0 THEN
                    FOR i IN 2 .. maxN LOOP
                        IF REGEXP_COUNT(firstPolynom, '\^' || i) > 0 
                            OR REGEXP_COUNT(secondPolynom, '\^' || i) > 0 THEN
                            FOR j IN 1 .. nom3.LAST LOOP
                            IF SUBSTR(REGEXP_SUBSTR(nom3(j), '\^\d+'), 2) = i THEN
                                IF SUBSTR(nom3(j), 1, 1) = '-' THEN
                                    n3(i) := n3(i) - REGEXP_SUBSTR(nom3(j), '\d+');
                                ELSE
                                    n3(i) := n3(i) + REGEXP_SUBSTR(nom3(j), '\d+');
                                END IF;
                            END IF;
                            END LOOP;
                        END IF;
                    END LOOP;
                END IF;
                
                IF maxN > 0 THEN
                    FOR i IN REVERSE 2 .. maxN LOOP
                        IF i = maxN AND n3(i) != 0 THEN
                            output := output || n3(i) || 'x^' || i;
                        ELSE
                            IF n3(i) != 0 THEN
                                IF n3(i) > 0 THEN
                                    output := output || '+' || n3(i) || 'x^' || i;
                                ELSE
                                    output := output || n3(i) || 'x^' || i;
                                END IF;
                            END IF;
                        END IF;
                    END LOOP;
                END IF;
                
                IF n2 != 0 THEN
                    IF output IS NULL THEN
                        output := output || n2 || 'x';
                    ELSE
                        IF n2 > 0 THEN
                            output := output || '+' || n2 || 'x';
                        ELSE
                            output := output || n2 || 'x';
                        END IF;
                    END IF;
                END IF;
                
                IF n1 != 0 THEN
                    IF output IS NULL THEN
                        output := output || n1;
                    ELSE
                        IF n1 > 0 THEN
                            output := output || '+' || n1;
                        ELSE
                            output := output || n1;
                        END IF;
                    END IF;
                END IF;
            ELSIF operation = '-' THEN 
                secondPolynom := '-1(' || Polynomial.SimplificationPolynomial(secondPolynom) ||')';
                secondpolynom := '(' || Polynomial.SimplificationPolynomial(secondPolynom) || ')';
                output := Polynomial.OperationsPolynomials(firstPolynom, secondPolynom, '+');
            ELSIF operation = '*' THEN
                output := Polynomial.SimplificationPolynomial('(' || Polynomial.SimplificationPolynomial(firstPolynom) || ')' || '(' || Polynomial.SimplificationPolynomial(secondPolynom) || ')');
            ELSIF operation = '\' THEN
                firstPolynom := Polynomial.SimplificationPolynomial(firstPolynom);
                secondPolynom := Polynomial.SimplificationPolynomial(secondPolynom);
                
                IF INSTR(REGEXP_SUBSTR(firstPolynom, '[+-]\d+x*([\^]\d+)*|^\d+x*([\^]\d+)*', 1, nm), 'x') = 0 THEN
                    stf := 1;
                ELSE 
                    stf := NVL(REGEXP_SUBSTR(REGEXP_SUBSTR(firstPolynom, '\^\-*\d+', 1, nm), '\-*\d+'), 0);
                END IF;
                    
                WHILE NVL(REGEXP_SUBSTR(REGEXP_SUBSTR(firstPolynom, '\^\-*\d+', 1, nm), '\-*\d+'), 0) >= NVL(REGEXP_SUBSTR(REGEXP_SUBSTR(secondPolynom, '\^\-*\d+', 1, nm), '\-*\d+'), 0) LOOP
                    dl := REGEXP_SUBSTR(firstPolynom, '[+-]\d+|^\d+', 1, nm) / REGEXP_SUBSTR(secondPolynom, '[+-]\d+|^\d+', 1, nm);
                    IF INSTR(REGEXP_SUBSTR(firstPolynom, '[+-]\d+x*([\^]\d+)*|^\d+x*([\^]\d+)*', 1, nm), 'x^') != 0  
                        AND INSTR(REGEXP_SUBSTR(firstPolynom, '[+-]\d+x*([\^]\d+)*|^\d+x*([\^]\d+)*', 1, nm), 'x') != 0 
                        AND INSTR(REGEXP_SUBSTR(secondPolynom, '[+-]\d+x*([\^]\d+)*|^\d+x*([\^]\d+)*', 1, nm), 'x^') != 0  
                        AND INSTR(REGEXP_SUBSTR(secondPolynom, '[+-]\d+x*([\^]\d+)*|^\d+x*([\^]\d+)*', 1, nm), 'x') != 0 THEN
                        IF (REGEXP_SUBSTR(REGEXP_SUBSTR(firstPolynom, '[+-]\d+x*([\^]\d+)*|^\d+x*([\^]\d+)*', 1, nm), '\d+', 1, 2) 
                        - REGEXP_SUBSTR(REGEXP_SUBSTR(secondPolynom, '[+-]\d+x*([\^]\d+)*|^\d+x*([\^]\d+)*', 1, nm), '\d+', 1, 2)) = 0 THEN
                            dl := dl;
                        ELSIF (REGEXP_SUBSTR(REGEXP_SUBSTR(firstPolynom, '[+-]\d+x*([\^]\d+)*|^\d+x*([\^]\d+)*', 1, nm), '\d+', 1, 2) 
                        - REGEXP_SUBSTR(REGEXP_SUBSTR(secondPolynom, '[+-]\d+x*([\^]\d+)*|^\d+x*([\^]\d+)*', 1, nm), '\d+', 1, 2)) = 1 THEN
                            dl := dl || 'x';
                        ELSE
                            dl := dl || 'x^' 
                            || (REGEXP_SUBSTR(REGEXP_SUBSTR(firstPolynom, '[+-]\d+x*([\^]\d+)*|^\d+x*([\^]\d+)*', 1, nm), '\d+', 1, 2) 
                            - REGEXP_SUBSTR(REGEXP_SUBSTR(secondPolynom, '[+-]\d+x*([\^]\d+)*|^\d+x*([\^]\d+)*', 1, nm), '\d+', 1, 2));
                        END IF;
                    ELSIF INSTR(REGEXP_SUBSTR(firstPolynom, '[+-]\d+x*([\^]\d+)*|^\d+x*([\^]\d+)*', 1, nm), 'x^') != 0  
                        AND INSTR(REGEXP_SUBSTR(firstPolynom, '[+-]\d+x*([\^]\d+)*|^\d+x*([\^]\d+)*', 1, nm), 'x') != 0 
                        AND INSTR(REGEXP_SUBSTR(secondPolynom, '[+-]\d+x*([\^]\d+)*|^\d+x*([\^]\d+)*', 1, nm), 'x^') = 0  
                        AND INSTR(REGEXP_SUBSTR(secondPolynom, '[+-]\d+x*([\^]\d+)*|^\d+x*([\^]\d+)*', 1, nm), 'x') != 0 THEN
                        dl := dl || 'x^' 
                        || (REGEXP_SUBSTR(REGEXP_SUBSTR(firstPolynom, '[+-]\d+x*([\^]\d+)*|^\d+x*([\^]\d+)*', 1, nm), '\d+', 1, 2) - 1);
                        
                    ELSIF INSTR(REGEXP_SUBSTR(firstPolynom, '[+-]\d+x*([\^]\d+)*|^\d+x*([\^]\d+)*', 1, nm), 'x^') = 0  
                        AND INSTR(REGEXP_SUBSTR(firstPolynom, '[+-]\d+x*([\^]\d+)*|^\d+x*([\^]\d+)*', 1, nm), 'x') != 0 
                        AND INSTR(REGEXP_SUBSTR(secondPolynom, '[+-]\d+x*([\^]\d+)*|^\d+x*([\^]\d+)*', 1, nm), 'x^') = 0  
                        AND INSTR(REGEXP_SUBSTR(secondPolynom, '[+-]\d+x*([\^]\d+)*|^\d+x*([\^]\d+)*', 1, nm), 'x') != 0 THEN
                        dl := dl || 'x^2' ;
                    
                    ELSIF INSTR(REGEXP_SUBSTR(firstPolynom, '[+-]\d+x*([\^]\d+)*|^\d+x*([\^]\d+)*', 1, nm), 'x^') != 0  
                        AND INSTR(REGEXP_SUBSTR(firstPolynom, '[+-]\d+x*([\^]\d+)*|^\d+x*([\^]\d+)*', 1, nm), 'x') != 0 
                        AND INSTR(REGEXP_SUBSTR(secondPolynom, '[+-]\d+x*([\^]\d+)*|^\d+x*([\^]\d+)*', 1, nm), 'x^') = 0  
                        AND INSTR(REGEXP_SUBSTR(secondPolynom, '[+-]\d+x*([\^]\d+)*|^\d+x*([\^]\d+)*', 1, nm), 'x') = 0 THEN
                        dl := dl || 'x' 
                        || REGEXP_SUBSTR(REGEXP_SUBSTR(firstPolynom, '[+-]\d+x*([\^]\d+)*|^\d+x*([\^]\d+)*', 1, nm), '\d+', 1, 2);       
                    END IF;
                    
                    IF REGEXP_SUBSTR(REGEXP_SUBSTR(dl, '[+-]\d+x*([\^]\d+)*|^\d+x*([\^]\d+)*', 1, nm), '\d+', 1, 2) = 1 THEN
                        dl := SUBSTR(dl, 1, LENGTH(dl) - 2);
                    END IF;
                    
                    IF REGEXP_COUNT(dl, '^\d+$') = 0 THEN
                        firstPolynom := Polynomial.OperationsPolynomials(firstPolynom, Polynomial.OperationsPolynomials('(' || secondPolynom || ')', '(' || dl || ')', '*'), '-');
                    ELSE
                        firstPolynom := Polynomial.OperationsPolynomials(firstPolynom, Polynomial.SimplificationPolynomial(dl || '(' || secondPolynom || ')'), '-');
                    END IF;
                    
                    ost := firstPolynom;
                    IF nm = 1 THEN
                        otv := dl;
                    ELSE
                        otv := otv || '+' || dl;
                    END IF;
                    nm := nm + 1;
                    IF ost IS NULL THEN
                        output := otv;
                    ELSE
                        output := otv || ' остаток: ' || ost;
                    END IF;
                    
                    EXIT WHEN NVL(REGEXP_SUBSTR(REGEXP_SUBSTR(firstPolynom, '\^\-*\d+', 1, nm), '\-*\d+'), 0) = 0 
                        AND NVL(REGEXP_SUBSTR(REGEXP_SUBSTR(secondPolynom, '\^\-*\d+', 1, nm), '\-*\d+'), 0) = 0;
                END LOOP;
                
                IF output IS NOT NULL THEN
                    output := REPLACE(output, '-+', '+');
                    output := REPLACE(output, '+-', '-');
                END IF;
            END IF;
        END IF;
    END IF;
    IF REGEXP_COUNT(firstPolynom, '[^\(\)0-9\^x\+\-]') > 0 THEN
        DBMS_OUTPUT.PUT_LINE('Буква не х в первом многочлене');
    ELSIF REGEXP_COUNT(secondPolynom, '[^\(\)0-9\^x\+\-]') > 0 THEN
        DBMS_OUTPUT.PUT_LINE('Буква не х во втором многочлене');
    ELSIF REGEXP_COUNT(firstPolynom, '\(') != REGEXP_COUNT(firstPolynom, '\)') THEN
        DBMS_OUTPUT.PUT_LINE('Неверное количество скобок в первом многочлене');
    ELSIF REGEXP_COUNT(secondPolynom, '\(') != REGEXP_COUNT(secondPolynom, '\)') THEN
        DBMS_OUTPUT.PUT_LINE('Неверное количество скобок во втором многочлене');
    END IF;
    IF output IS NULL THEN       
        output := 'Степень делимого меньше степени делителя';
    END IF;
    
    RETURN output;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Ошибка');
    END OperationsPolynomials;   
    
    FUNCTION RowPolynomial (
        Polynom VARCHAR2,
        RowP NUMBER
    ) RETURN VARCHAR2 IS
        str VARCHAR(100) := '';
    BEGIN
    IF REGEXP_COUNT(Polynom, '\(') = REGEXP_COUNT(Polynom, '\)') 
        AND REGEXP_COUNT(Polynom, '[^\(\)0-9\^x\+\-]') = 0 THEN
        FOR i IN 1 .. RowP LOOP
            str := str || '(' || Polynomial.SimplificationPolynomial(Polynom) || ')';
        END LOOP;
    END IF;
    
    IF REGEXP_COUNT(Polynom, '[^\(\)0-9\^x\+\-]') > 0 THEN
        DBMS_OUTPUT.PUT_LINE('Буква не х в многочлене');
    ELSIF str IS NULL THEN
        DBMS_OUTPUT.PUT_LINE('Неверное количество скобок');
    END IF;
    RETURN Polynomial.SimplificationPolynomial(Polynomial.OpenBrackets(str));
        
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Ошибка');
    END RowPolynomial;
    
    FUNCTION SimplificationPolynomial (
        Polynom VARCHAR2
    ) RETURN VARCHAR2 IS
        newplnm VARCHAR2(100);
        sbstr VARCHAR2(100);
        output VARCHAR2(100);
        plnm VARCHAR2(100) := Polynom;
        
        n1 NUMBER := 0;
        n2 NUMBER := 0;
        
        maxN NUMBER := 0;
        
        TYPE Tn3 IS TABLE OF VARCHAR2(100)
            INDEX BY PLS_INTEGER;
        n3 Tn3;
        
        TYPE Tnom IS TABLE OF VARCHAR2(100)
            INDEX BY PLS_INTEGER;
        nom Tnom;
        
        TYPE Tnom1 IS TABLE OF VARCHAR2(100)
            INDEX BY PLS_INTEGER;
        nom1 Tnom1;
        
        TYPE Tnom2 IS TABLE OF VARCHAR2(100)
            INDEX BY PLS_INTEGER;
        nom2 Tnom2;
        
        TYPE Tnom3 IS TABLE OF VARCHAR2(100)
            INDEX BY PLS_INTEGER;
        nom3 Tnom3;
    BEGIN
    IF REGEXP_COUNT(Polynom, '\(') = REGEXP_COUNT(Polynom, '\)') 
        AND REGEXP_COUNT(Polynom, '[^\(\)0-9\^x\+\-]') = 0 THEN
        IF REGEXP_COUNT(plnm, '\(') > 0 THEN
            FOR i IN 1 .. REGEXP_COUNT(plnm, '\(')  LOOP
                sbstr := REGEXP_SUBSTR(plnm, '(\-*\d+)?\([+-x0-9]*(\)\()*[+-x0-9]*\)');
                newplnm := Polynomial.OpenBrackets(sbstr);
                plnm := REPLACE(plnm, sbstr, newplnm);
            END LOOP;
        END IF;
        
        IF REGEXP_COUNT(plnm, '^\d+[+-\(]|[+-\(]\d+[+-\(]|[^\^]\d+$') > 0 THEN
            FOR i IN 1 .. REGEXP_COUNT(plnm, '^\d+[+-\(]|[+-\(]\d+[+-\(]|[^\^]\d+$') LOOP
                nom1(i) := REGEXP_SUBSTR(plnm, '^\d+[+-\(]|[+-\(]\d+[+-\(]|[^\^]\d+$', 1, i);
            END LOOP;
        END IF;
        
        IF REGEXP_COUNT(plnm, '^\d+x|[+-]\d+x|[+-]\d+x$') > 0 THEN
            FOR i IN 1 .. REGEXP_COUNT(plnm, '^\d+x|[+-]\d+x|[+-]\d+x$') LOOP
                IF REGEXP_INSTR(plnm, '^\d+x\^+|[+-]\d+x\^+|[+-]\d+x\^+$', 1, i) = 0 THEN
                    nom2(i) := REGEXP_SUBSTR(plnm, '^\d+x|[+-]\d+x|[+-]\d+x$', 1, i);
                ELSE 
                    nom2(i) := 0;
                END IF;
            END LOOP;
        END IF;
        
        IF REGEXP_COUNT(plnm, '[(+-]?\d+x\^\d+') > 0 THEN
            FOR i IN 1 .. REGEXP_COUNT(plnm, '[\(+-]?\d+x\^\d+') LOOP
                nom3(i) := REGEXP_SUBSTR(plnm, '[\(+-]?\d+x\^\d+', 1, i);
                IF REGEXP_SUBSTR(nom3(i), '\-*\d+', 1, 2) > maxN THEN
                    maxN := REGEXP_SUBSTR(nom3(i), '\-*\d+', 1, 2);
                END IF;
            END LOOP;
        END IF;
        
        IF nom1.LAST > 0 THEN
            FOR i IN 1 .. nom1.LAST LOOP
                n1 := n1 + REGEXP_SUBSTR(nom1(i), '\-*\d+');
            END LOOP;
        END IF;
        
        IF nom2.LAST > 0 THEN
            FOR i IN 1 .. nom2.LAST LOOP
                n2 := n2 + REGEXP_SUBSTR(nom2(i), '\-*\d+');
            END LOOP;
        END IF;
        
        IF maxN > 0 THEN
            FOR i IN 2 .. maxN LOOP
                n3(i) := 0;
            END LOOP;
        END IF;
        
        IF maxN > 0 THEN    
            FOR i IN 2 .. maxN LOOP
                IF REGEXP_COUNT(plnm, '\^' || i) > 0 THEN
                    FOR j IN 1 .. nom3.LAST LOOP
                    IF SUBSTR(REGEXP_SUBSTR(nom3(j), '\^\d+'), 2) = i THEN
                        n3(i) := n3(i) + REGEXP_SUBSTR(nom3(j), '\-*\d+');
                    END IF;
                    END LOOP;
                END IF;
            END LOOP;
        END IF;
           
        IF maxN > 0 THEN 
            FOR i IN REVERSE 2 .. maxN LOOP
                IF i = maxN AND n3(i) != 0 THEN
                    output := output || n3(i) || 'x^' || i;
                ELSE
                    IF n3(i) != 0 THEN
                        IF n3(i) > 0 THEN
                            output := output || '+' || n3(i) || 'x^' || i;
                        ELSE
                            output := output || n3(i) || 'x^' || i;
                        END IF;
                    END IF;
                END IF;
            END LOOP;
        END IF;
        
        IF n2 != 0 THEN
            IF output IS NULL THEN
                output := output || n2 || 'x';
            ELSE
                IF n2 > 0 THEN
                    output := output || '+' || n2 || 'x';
                ELSE
                    output := output || n2 || 'x';
                END IF;
            END IF;
        END IF;
        
        IF n1 != 0 THEN
            IF output IS NULL THEN
                output := output || n1;
            ELSE
                IF n1 > 0 THEN
                    output := output || '+' || n1;
                ELSE
                    output := output || n1;
                END IF;
            END IF;
        END IF;
    END IF;
    
    IF REGEXP_COUNT(Polynom, '[^\(\)0-9\^x\+\-]') > 0 THEN
        DBMS_OUTPUT.PUT_LINE('Буква не х в многочлене');    
    ELSIF REGEXP_COUNT(Polynom, '\(') != REGEXP_COUNT(Polynom, '\)')  THEN
        DBMS_OUTPUT.PUT_LINE('Неверное количество скобок');
    END IF;
    RETURN output;
        
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Ошибка');
    END SimplificationPolynomial;
END Polynomial;
/

BEGIN
    DBMS_OUTPUT.PUT_LINE(Polynomial.RowPolynomial('(2x+1g)', 3));
END;