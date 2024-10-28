CREATE OR REPLACE PROCEDURE get_recipes_by_tag (
    p_tag_name IN VARCHAR2
) AS
    v_tag_id NUMBER;
    v_recipe_name VARCHAR2(50);
    v_recipe_count INTEGER := 0;  -- Initialize recipe count
BEGIN
    -- Display available tags
    DBMS_OUTPUT.PUT_LINE('Available Tag Types:');
    FOR tag IN (SELECT tag_name FROM tag_type) LOOP
        DBMS_OUTPUT.PUT_LINE('- ' || tag.tag_name);
    END LOOP;

    -- Fetch the tag_id for the given tag_name
    SELECT tag_id
    INTO v_tag_id
    FROM tag_type
    WHERE UPPER(tag_name) = UPPER(p_tag_name);  -- Case-insensitive comparison

    -- Fetch recipes associated with the given tag_id
    DBMS_OUTPUT.PUT_LINE('Recipes with tag "' || p_tag_name || '":');
    FOR recipe IN (
        SELECT r.recipe_name
        FROM recipe r
        JOIN recipe_tag rt ON r.recipe_id = rt.recipe_id
        WHERE rt.tag_id = v_tag_id
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('- ' || recipe.recipe_name);
        v_recipe_count := v_recipe_count + 1;  -- Increment count for each recipe found
    END LOOP;

    -- If no recipes found for the tag
    IF v_recipe_count = 0 THEN
        DBMS_OUTPUT.PUT_LINE('No recipes available for the tag "' || p_tag_name || '".');
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('The tag "' || p_tag_name || '" does not exist. Please check the available tags.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('An unexpected error occurred: ' || SQLERRM);
END get_recipes_by_tag;
/


BEGIN
    get_recipes_by_tag('contains egg'); 
end;
/ 

BEGIN
    get_recipes_by_tag('veg'); 
end;
