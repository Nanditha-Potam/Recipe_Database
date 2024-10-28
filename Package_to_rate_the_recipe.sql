
--To create a package where user can give the rating or update or delete it.
CREATE OR REPLACE PACKAGE RatingManagement AS
    PROCEDURE Add_Rating(
        p_user_id IN NUMBER,
        p_recipe_id IN NUMBER,
        p_rating IN NUMBER,
        p_review IN VARCHAR2 DEFAULT NULL
    );

    PROCEDURE Update_Rating(
        p_user_id IN NUMBER,
        p_recipe_id IN NUMBER,
        p_rating IN NUMBER,
        p_review IN VARCHAR2 DEFAULT NULL
    );

    PROCEDURE Delete_Rating(
        p_review_id IN NUMBER  -- Ensure this parameter matches the body
    );
END RatingManagement;
/
CREATE OR REPLACE PACKAGE BODY RatingManagement AS

    PROCEDURE Add_Rating(
        p_user_id IN NUMBER,
        p_recipe_id IN NUMBER,
        p_rating IN NUMBER,
        p_review IN VARCHAR2 DEFAULT NULL
    ) IS
    BEGIN
        INSERT INTO rate_review (user_id, recipe_id, rating, review)
        VALUES (p_user_id, p_recipe_id, p_rating, p_review);
        
        DBMS_OUTPUT.PUT_LINE('Thank you for the review');
        
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            RAISE_APPLICATION_ERROR(-20001, 'Rating already exists for this user and recipe.');
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20002, 'Error adding rating: ' || SQLERRM);
    END Add_Rating;

    PROCEDURE Update_Rating(
        p_user_id IN NUMBER,
        p_recipe_id IN NUMBER,
        p_rating IN NUMBER,
        p_review IN VARCHAR2 DEFAULT NULL
    ) IS
    BEGIN
        UPDATE rate_review
        SET rating = p_rating,
            review = p_review,
            review_date = CURRENT_DATE  -- Update review date on modification
        WHERE user_id = p_user_id AND recipe_id = p_recipe_id;
        
        DBMS_OUTPUT.PUT_LINE('The changes you made are being updated');

        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20003, 'No rating found to update for this user and recipe.');
        END IF;
    END Update_Rating;

    PROCEDURE Delete_Rating(
        p_review_id IN NUMBER  -- This parameter should match the specification
    ) IS
    BEGIN
        DELETE FROM rate_review
        WHERE review_id = p_review_id;

        DBMS_OUTPUT.PUT_LINE('Your review has been deleted');

        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20004, 'No rating found to delete with the specified review ID.');
        END IF;
    END Delete_Rating;

END RatingManagement;
/
