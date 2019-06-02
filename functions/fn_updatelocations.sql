create or replace function fn_updatelocations() returns void as 
$$
begin

    -- Clear out old records
    delete from location
    where updated < (now() - interval '1 minute');

    -- Find all the currently active mobiles
    create temp table mobile_locations (
        mobile_id int
    );

    drop table mobile_locations;

end;
$$
language plpgsql;