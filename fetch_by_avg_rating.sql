--to fetch based on avg_rating
CREATE OR REPLACE PROCEDURE Fetch_Recipes_By_Avg_Rating (
    p_rating IN NUMBER
) AS
    -- User-defined exception for invalid rating
    e_invalid_rating EXCEPTION;

BEGIN
    -- Check if the input rating is within the valid range
    IF p_rating < 0 OR p_rating > 5 THEN
        RAISE e_invalid_rating;
    END IF;

    -- Use a FOR loop to fetch recipes based on avg_rating
    FOR rec IN (
        SELECT r.recipe_id, r.recipe_name
        FROM Recipe r
        JOIN avg_rating ar ON r.recipe_id = ar.recipe_id
        WHERE ar.avg_rating >= p_rating
        ORDER BY ar.avg_rating DESC
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('Recipe ID: ' || rec.recipe_id || ' | Recipe Name: ' || rec.recipe_name);
    END LOOP;

    -- If no recipes were found, a message will not be printed,
    -- so we can check if the loop was executed at all
    IF SQL%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('No recipes found with an average rating greater than ' || p_rating);
    END IF;

EXCEPTION
    WHEN e_invalid_rating THEN
        DBMS_OUTPUT.PUT_LINE('Error: Please give the value in the range of 0 to 5.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('An unexpected error occurred: ' || SQLERRM);
END Fetch_Recipes_By_Avg_Rating;
/

begin
Fetch_Recipes_By_Avg_Rating(4);
end;

begin
Fetch_Recipes_By_Avg_Rating(10);
end;
