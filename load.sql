-- create temp table for orgs
create table organisation_temp (
	name character varying (200) not null,
	code character (9),
	website character varying (200),
	email character varying (200),
	domain character varying (200)
);

-- import organisations
\copy organisation_temp from 'data/organisations.csv' csv header;

-- insert into proper table
insert into organisation(name, code, website, email)
select name, code, website, email from organisation_temp;

-- now insert our authentication table
insert into authentication(organisation_id, domain)
select distinct o.id, t.domain from organisation_temp t
join organisation o on t.name = o.name
where t.domain is not null;

drop table organisation_temp;

-- load Aberdeenshire
\copy staging from 'data/aberdeenshire.csv' csv header;
select fn_loadstaging(organisation_name := 'Aberdeenshire');