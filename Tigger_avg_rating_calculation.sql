
--trigger for finding avg rating of a recipe whenever a new user adds a rating.
CREATE OR REPLACE TRIGGER update_rating 
FOR INSERT or update or delete ON rate_review
COMPOUND TRIGGER
    -- Declare a variable to store the recipe ID
    v_recipe_id rate_review.recipe_id%TYPE;
BEFORE STATEMENT IS
BEGIN
    -- Initialize the recipe ID variable before the statement execution
    v_recipe_id := NULL;
END BEFORE STATEMENT;
AFTER EACH ROW IS
BEGIN
    -- Store the recipe ID of the inserted row
    v_recipe_id := :new.recipe_id;
END AFTER EACH ROW;
AFTER STATEMENT IS
BEGIN
    -- Calculate the new average rating for the specific recipe ID
    DECLARE
        v_avg_rating NUMBER;
    BEGIN
        SELECT AVG(rating) INTO v_avg_rating
        FROM rate_review
        WHERE recipe_id = v_recipe_id
        GROUP BY recipe_id;
        -- Update the avg_rating table with the new average rating
        UPDATE avg_rating
        SET avg_rating = round(v_avg_rating,2)
        WHERE recipe_id = v_recipe_id;
        -- Optionally, you can output a message indicating that the average rating has been updated
        DBMS_OUTPUT.PUT_LINE('Average rating updated for recipe ID ' || v_recipe_id || ' to ' || v_avg_rating);
    END;
END AFTER STATEMENT;
END update_rating;
