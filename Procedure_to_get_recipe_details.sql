CREATE OR REPLACE PROCEDURE get_recipe_details (
    p_recipe_name IN VARCHAR2
) AS
    v_cooking_time_min     NUMBER;
    v_servings             NUMBER;
    v_ingredients          CLOB;
    v_instruction          CLOB;
    v_carbs                NUMBER;
    v_protein              NUMBER;
    v_fat                  NUMBER;
    v_cooking_tip          VARCHAR2(500);
    v_tutorial_video       VARCHAR2(500);
    v_recipe_count         INTEGER;
BEGIN
    -- Check if the recipe exists (case-insensitive)
    SELECT COUNT(*)
    INTO v_recipe_count
    FROM recipe
    WHERE UPPER(recipe_name) = UPPER(p_recipe_name);  -- Case-insensitive comparison

    -- If recipe is not found, display message and exit
    IF v_recipe_count = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Sorry, the recipe you are looking for is not available.');
        RETURN;  -- Exit the procedure
    END IF;

    -- Fetch the recipe details with correct joins
    SELECT 
        r.cooking_time_min,
        r.servings,
        r.ingredients,
        r.instruction,
        n.carbs,
        n.protein,
        n.fat,
        t.cooking_tip,
        t.tutorial_video
    INTO 
        v_cooking_time_min, v_servings, v_ingredients, v_instruction,
        v_carbs, v_protein, v_fat, v_cooking_tip, v_tutorial_video
    FROM 
        recipe r
    LEFT JOIN 
        nutrition_info n ON r.recipe_id = n.recipe_id
    LEFT JOIN 
        TIPS t ON r.recipe_id = t.recipe_id
    WHERE 
        UPPER(r.recipe_name) = UPPER(p_recipe_name);  -- Ensure we are fetching tips for the correct recipe

    -- Display the recipe details with gaps
    DBMS_OUTPUT.PUT_LINE('recipe_name: ' || p_recipe_name);
    DBMS_OUTPUT.PUT_LINE('');  -- Gap
    DBMS_OUTPUT.PUT_LINE('Cooking Time: ' || v_cooking_time_min || ' minutes');
    DBMS_OUTPUT.PUT_LINE('');  -- Gap
    DBMS_OUTPUT.PUT_LINE('Servings: ' || v_servings);
    DBMS_OUTPUT.PUT_LINE('');  -- Gap
    DBMS_OUTPUT.PUT_LINE('Ingredients:');
    DBMS_OUTPUT.PUT_LINE(v_ingredients);
    DBMS_OUTPUT.PUT_LINE('');  -- Gap
    DBMS_OUTPUT.PUT_LINE('Instructions:');
    DBMS_OUTPUT.PUT_LINE(v_instruction);
    DBMS_OUTPUT.PUT_LINE('');  -- Gap
    DBMS_OUTPUT.PUT_LINE('Nutrition Info:');
    DBMS_OUTPUT.PUT_LINE('- Carbs: ' || v_carbs || 'g');
    DBMS_OUTPUT.PUT_LINE('- Protein: ' || v_protein || 'g');
    DBMS_OUTPUT.PUT_LINE('- Fat: ' || v_fat || 'g');
    DBMS_OUTPUT.PUT_LINE('');  -- Gap
    DBMS_OUTPUT.PUT_LINE('Cooking Tip: ' || NVL(v_cooking_tip, 'No cooking tips available.'));
    DBMS_OUTPUT.PUT_LINE('');  -- Gap
    DBMS_OUTPUT.PUT_LINE('Tutorial Video: ' || NVL(v_tutorial_video, 'No video available.'));
    DBMS_OUTPUT.PUT_LINE('');  -- Gap
    DBMS_OUTPUT.PUT_LINE('I hope you like the content! Please share your experience and don''t forget to give a rating.');

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('An unexpected error occurred: ' || SQLERRM);
END get_recipe_details;
/

BEGIN
    get_recipe_details('brownie'); -- This will now work regardless of case
END;
/

BEGIN
    get_recipe_details('pasta'); -- This will now work regardless of case
END;
/

BEGIN
    get_recipe_details('corn'); -- This will now work regardless of case
END;
/
