if object_id('PI_PILE', 'U') is not null
	drop table PI_PILE;

if object_id('PIE_PILE_ENTETE', 'U') is not null
	drop table PIE_PILE_ENTETE;

create table PIE_PILE_ENTETE
(
	PIE_ID int identity
	,PIE_LABEL varchar(255)

	,constraint PK_PIE_PILE_ENTETE
		primary key (PIE_ID)
);

create table PI_PILE
(
	PI_ID int identity
	,PI_ORDER int default 0
	,PI_VAL	varchar(255)
	,PIE_ID int

	,constraint PK_PI_PILE
		primary key (PI_ID)

	,constraint FK_PI_PILE_PIE_ID 
		foreign key (PIE_ID)
		references PIE_PILE_ENTETE(PIE_ID)
);
