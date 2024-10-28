--Procedure to add new Recipe to the Recipe Database
CREATE OR REPLACE PROCEDURE add_recipe (
    p_recipe_name         VARCHAR2,
    p_cuisine_id          NUMBER,
    p_cooking_time_min    NUMBER,
    p_ingredients         CLOB,
    p_calories            DECIMAL,
    p_instruction         CLOB,
    p_dietary_restriction VARCHAR2,
    p_servings            NUMBER,
    p_user_id             NUMBER,
    p_tag_id              NUMBER,                
    p_carbs               NUMBER,
    p_protein             NUMBER,
    p_fat                 NUMBER,
    p_cooking_tip         VARCHAR2,              
    p_tutorial_video      VARCHAR2               
) AS
    v_recipe_id NUMBER;
BEGIN
    -- Insert into Recipe table
    INSERT INTO Recipe (recipe_name, cuisine_id, cooking_time_min, ingredients, calories, instruction, dietary_restriction, servings, user_id)
    VALUES (p_recipe_name, p_cuisine_id, p_cooking_time_min, p_ingredients, p_calories, p_instruction, p_dietary_restriction, p_servings, p_user_id)
    RETURNING recipe_id INTO v_recipe_id;

    -- Insert into nutrition_info table
    INSERT INTO nutrition_info (recipe_id, carbs, protein, fat)
    VALUES (v_recipe_id, p_carbs, p_protein, p_fat);

    -- Insert into recipe_tag table using tag_id
    INSERT INTO recipe_tag (recipe_id, tag_id) 
    VALUES (v_recipe_id, p_tag_id);

    -- Insert into TIPS table
    INSERT INTO TIPS (recipe_id, cooking_tip, tutorial_video)
    VALUES (v_recipe_id, p_cooking_tip, p_tutorial_video);

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;

--case 1 To add the recipe by calling the add_recipe procedure
BEGIN
    add_recipe(
        p_recipe_name => 'Moussaka',
        p_cuisine_id => 15,          
        p_cooking_time_min => 90,
        p_ingredients => 'Eggplants, Ground Beef, Onion, Garlic, Tomato Sauce, Olive Oil, Bechamel Sauce, Cinnamon, Salt, Pepper',
        p_calories => 600,
        p_instruction => 'Slice eggplants, sprinkle with salt, and let sit to remove bitterness. Sauté onions and garlic in olive oil, add ground beef (or lentils) and cook until browned. Add tomato sauce, cinnamon, salt, and pepper. Simmer for 20 minutes. Layer eggplants in a baking dish, add meat sauce, and top with bechamel sauce. Bake at 350°F (175°C) for about 45 minutes.',
        p_dietary_restriction => null,
        p_servings => 6,
        p_user_id => 23,             
        p_tag_id => 3,             
        p_carbs => 50,             
        p_protein => 25,            
        p_fat => 35,               
        p_cooking_tip => 'Let it cool before slicing for better presentation.',
        p_tutorial_video => 'http://example.com/video4'
    );
END;

SELECT * FROM Recipe;
SELECT * FROM nutrition_info;
SELECT * FROM recipe_tag;
SELECT * FROM TIPS;

--The Procedure to Update the recipe by the user
CREATE OR REPLACE PROCEDURE update_recipe (
    p_recipe_id           NUMBER,          -- Recipe ID remains constant
    p_user_id             NUMBER,          -- User ID making the update
    p_recipe_name         VARCHAR2 DEFAULT NULL,
    p_cuisine_id          NUMBER DEFAULT NULL,
    p_cooking_time_min    NUMBER DEFAULT NULL,
    p_ingredients         CLOB DEFAULT NULL,
    p_calories            DECIMAL DEFAULT NULL,
    p_instruction         CLOB DEFAULT NULL,
    p_dietary_restriction VARCHAR2 DEFAULT NULL,
    p_servings            NUMBER DEFAULT NULL,
    p_carbs               NUMBER DEFAULT NULL,
    p_protein             NUMBER DEFAULT NULL,
    p_fat                 NUMBER DEFAULT NULL,
    p_cooking_tip         VARCHAR2 DEFAULT NULL,
    p_tutorial_video      VARCHAR2 DEFAULT NULL,
    p_tag_id              NUMBER DEFAULT NULL
) AS
    v_user_id NUMBER;
BEGIN
    -- Check if the recipe belongs to the user
    SELECT user_id INTO v_user_id
    FROM Recipe
    WHERE recipe_id = p_recipe_id;

    IF v_user_id != p_user_id THEN
        RAISE_APPLICATION_ERROR(-20001, 'You are not authorized to update this recipe.');
    END IF;

    -- Update the Recipe table conditionally using NVL
    UPDATE Recipe
    SET recipe_name = NVL(p_recipe_name, recipe_name),
        cuisine_id = NVL(p_cuisine_id, cuisine_id),
        cooking_time_min = NVL(p_cooking_time_min, cooking_time_min),
        ingredients = NVL(p_ingredients, ingredients),
        calories = NVL(p_calories, calories),
        instruction = NVL(p_instruction, instruction),
        dietary_restriction = NVL(p_dietary_restriction, dietary_restriction),
        servings = NVL(p_servings, servings)
    WHERE recipe_id = p_recipe_id;  -- recipe_id remains unchanged

    -- Update the nutrition_info table conditionally using NVL
    UPDATE nutrition_info
    SET carbs = NVL(p_carbs, carbs),
        protein = NVL(p_protein, protein),
        fat = NVL(p_fat, fat)
    WHERE recipe_id = p_recipe_id;  -- recipe_id remains unchanged

    -- Update the TIPS table conditionally using NVL
    UPDATE TIPS
    SET cooking_tip = NVL(p_cooking_tip, cooking_tip),
        tutorial_video = NVL(p_tutorial_video, tutorial_video)
    WHERE recipe_id = p_recipe_id;  -- recipe_id remains unchanged

    -- Update or insert into recipe_tag table
    IF p_tag_id IS NOT NULL THEN
        BEGIN
            UPDATE recipe_tag
            SET tag_id = p_tag_id
            WHERE recipe_id = p_recipe_id;

            IF SQL%ROWCOUNT = 0 THEN
                -- If no row was updated, insert a new one
                INSERT INTO recipe_tag (recipe_id, tag_id)
                VALUES (p_recipe_id, p_tag_id);
            END IF;
        EXCEPTION
            WHEN OTHERS THEN
                ROLLBACK;
                RAISE_APPLICATION_ERROR(-20003, 'Error updating or inserting tag.');
        END;
    END IF;

    COMMIT;

    -- Output confirmation message
    DBMS_OUTPUT.PUT_LINE('Dear user, the changes have been updated.');

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20002, 'Recipe not found.');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;

--case 1: To update the recipe based on required changes needed 
BEGIN
    update_recipe(
        p_recipe_id => 22,  
        p_user_id => 23,    
        p_tag_id => 7
    );
END;

--case 2: trying to make changes by the person who didnt added the recipe into the database.
BEGIN
    update_recipe(
        p_recipe_id => 21,  
        p_user_id => 21,    
        p_tag_id => 7
    );
END;

SELECT * FROM Recipe;
SELECT * FROM nutrition_info;
SELECT * FROM recipe_tag;
SELECT * FROM TIPS;


--The procedure to delete_recipe by the user

CREATE OR REPLACE PROCEDURE delete_recipe (
    p_recipe_id NUMBER,
    p_user_id   NUMBER
) AS
    v_user_id NUMBER;
BEGIN
    -- Check if the recipe belongs to the user
    SELECT user_id INTO v_user_id
    FROM Recipe
    WHERE recipe_id = p_recipe_id;

    IF v_user_id != p_user_id THEN
        RAISE_APPLICATION_ERROR(-20001, 'You are not authorized to delete this recipe.');
    END IF;

    -- Delete from recipe_tag table
    DELETE FROM recipe_tag
    WHERE recipe_id = p_recipe_id;

    -- Delete from TIPS table
    DELETE FROM TIPS
    WHERE recipe_id = p_recipe_id;

    -- Delete from nutrition_info table
    DELETE FROM nutrition_info
    WHERE recipe_id = p_recipe_id;

    -- Delete from Recipe table
    DELETE FROM Recipe
    WHERE recipe_id = p_recipe_id;

    COMMIT;

    -- Output confirmation message
    DBMS_OUTPUT.PUT_LINE('Dear user, the recipe has been deleted successfully.');

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20002, 'Recipe not found.');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;

BEGIN
    delete_recipe(
        p_recipe_id => 22,  -- ID of the recipe to delete
        p_user_id => 23     -- User ID requesting the deletion
    );
END;

SELECT * FROM nutrition_info;
SELECT * FROM recipe_tag;
SELECT * FROM TIPS where RECIPE_ID=21;
select * from recipe where RECIPE_ID=21;
select * from avg_rating;

