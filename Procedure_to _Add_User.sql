--CREATE PROCEDURE TO ADD USER

CREATE OR REPLACE PROCEDURE Add_User (
    p_user_name IN VARCHAR2,
    p_password IN VARCHAR2,
    p_email IN VARCHAR2
) AS
    v_is_admin NUMBER := 0;  -- Default to 0 for regular users
    v_user_exists NUMBER;
BEGIN
    -- Check if the username matches your specific username
    IF p_user_name = 'Nanditha_potam' and p_email='abcd@gmail.com' THEN
        v_is_admin := 1;  -- Set to 1 for the special user
    END IF;

    -- Check for existing user with the same username or email (case insensitive)
    SELECT COUNT(*)
    INTO v_user_exists
    FROM User_Details
    WHERE LOWER(user_name) = LOWER(p_user_name) OR LOWER(email) = LOWER(p_email);

    -- Debug output to verify user existence check
    DBMS_OUTPUT.PUT_LINE('Checking user: ' || p_user_name || ' | Email: ' || p_email);
   

    IF v_user_exists > 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Hello user, you already exist in the database.');
    END IF;

    -- Insert the new user into the User_Details table
    INSERT INTO User_Details (user_name, password, email, is_admin)
    VALUES (p_user_name, p_password, p_email, v_is_admin);

EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20001, 'Error adding user: ' || SQLERRM);
END Add_User;
/

begin
    Add_User('kavya reddy','kavya@123','kavya@gmail.com');
end;
