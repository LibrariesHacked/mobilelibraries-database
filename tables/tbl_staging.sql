create table staging (
	organisation character varying (200) not null,
	mobile character varying (200) not null,
	route character varying (200) not null,
	community character varying (200),
	stop character varying (200) not null,
	address character varying (250),
	postcode character varying (8),
	geox numeric not null,
	geoy numeric not null,
	day character varying (9) not null,
	arrival time with time zone not null,
	departure time with time zone not null,
	frequency character varying (100) not null,
	"start" date not null,
	"end" date,
	timetable character varying (200)
);