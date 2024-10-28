--Procedure to fetch Recipe by the cuisine:

CREATE OR REPLACE PROCEDURE fetch_recipes(cuisine VARCHAR2) IS 
    req_recipe VARCHAR2(50); 
    CURSOR e_cur IS  
        SELECT recipe_name  
        FROM recipe  
        WHERE cuisine_id = (SELECT cuisine_id FROM cuisine WHERE LOWER(cuisine_name) = LOWER(cuisine)); 

    -- Define a user-defined exception
    no_cuisine_found EXCEPTION; 

    v_cuisine_count INTEGER; -- Variable to store the count of cuisines

BEGIN 
    -- Check if the cuisine exists
    SELECT COUNT(*)
    INTO v_cuisine_count
    FROM cuisine 
    WHERE LOWER(cuisine_name) = LOWER(cuisine);

    IF v_cuisine_count = 0 THEN
        RAISE no_cuisine_found;
    END IF;

    OPEN e_cur; 
    LOOP 
        FETCH e_cur INTO req_recipe; 
        EXIT WHEN e_cur%NOTFOUND; 
        DBMS_OUTPUT.PUT_LINE(req_recipe); 
    END LOOP; 
    CLOSE e_cur; 

EXCEPTION 
    WHEN no_cuisine_found THEN 
        DBMS_OUTPUT.PUT_LINE('The specified cuisine is not available.'); 
    WHEN NO_DATA_FOUND THEN 
        DBMS_OUTPUT.PUT_LINE('No recipes found for the provided cuisine.'); 
END fetch_recipes;

BEGIN
    fetch_recipes('american');  
END;
/
