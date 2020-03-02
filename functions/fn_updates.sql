create or replace function fn_updates() returns void as 
$$
begin
    perform fn_update_route_schedule();
    perform fn_update_estimate_locations();
    return;
end;
$$
language plpgsql;