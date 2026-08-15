CREATE OR REPLACE FUNCTION delete_user(uid uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF auth.uid() = uid THEN
    DELETE FROM auth.users WHERE id = uid;
  ELSE
    RAISE EXCEPTION 'Unauthorized: You can only delete your own account';
  END IF;
END;
$$;
