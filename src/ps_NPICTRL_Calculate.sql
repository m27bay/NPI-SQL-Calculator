create procedure ps_NPICTRL_Calculate
(
	@Equation varchar(max)
	,@Rez varchar(255) output
	,@Debug bit = 0
)
as
begin
	declare @StartTime datetime2 = getdate();

	declare 
		@MainPieId int,
		@SecondPieId int;

	declare 
		@Val varchar(255),
		@ValId	int,
		@Val2	int,
		@ValId2 int,
		@Val3	int,
		@ValId3 int;

	declare @TmpRez varchar(255);

	insert into PIE_PILE_ENTETE (PIE_LABEL) values ('Main');
	select @MainPieId = max(PIE_ID) from PIE_PILE_ENTETE;

	insert into PIE_PILE_ENTETE (PIE_LABEL) values ('Secondary');
	select @SecondPieId = max(PIE_ID) from PIE_PILE_ENTETE;

	insert into PI_PILE
	(
		PIE_ID
		,PI_VAL
		,PI_ORDER
	)
	select
		@MainPieId
		,value
		,row_number() over (order by (select null))
	from 
		string_split(@Equation, ' ')

	if @Debug = 1
	begin
		select 'AFTER PROC';
		select * from PIE_PILE_ENTETE where PIE_ID = @MainPieId;
		select * from PI_PILE where PIE_ID = @MainPieId order by PI_ORDER;
	end;

	declare @SizeMainPile int;
	select @SizeMainPile = count(*) from PI_PILE where PIE_ID = @MainPieId;
	declare @SizeSecondPile int;
	select @SizeSecondPile = count(*) from PI_PILE where PIE_ID = @SecondPieId;

	declare 
		@Order	int,
		@Order2 int,
		@Order3 int;

	while @SizeMainPile > 1 or @SizeSecondPile > 0
	begin
		select top 1 
			@Val = PI_VAL
			,@ValId = PI_ID
			,@Order = PI_ORDER
		from PI_PILE 
		where PIE_ID = @MainPieId
		order by PI_ORDER;
		
		if @Debug = 1
		begin
			select 'BEGIN';
			select @Val as Val, @ValId as ValId, @Order as [Order];
		end;

		delete from PI_PILE where PI_ID = @ValId;
		
		if @Val in ('-', '+', '*', '/')
		begin
			if @Debug = 1
				select 'VAL IS OPERATOR';

			select top 1 
				@Val2 = try_convert(int, PI_VAL)
				,@ValId2 = PI_ID
				,@Order2 = PI_ORDER
			from PI_PILE 
			where PIE_ID = @SecondPieId;

			if @Debug = 1
			begin
				select 'VAL2';
				select @Val2 as Val, @ValId2 as ValId, @Order as [Order];
			end;

			delete from PI_PILE where PI_ID = @ValId2;

			select top 1 
				@Val3 = try_convert(int, PI_VAL)
				,@ValId3 = PI_ID
				,@Order3 = PI_ORDER
			from PI_PILE 
			where PIE_ID = @SecondPieId;

			if @Debug = 1
			begin
				select 'VAL3';
				select @Val3 as Val, @ValId3 as ValId, @Order as [Order];
			end;

			delete from PI_PILE where PI_ID = @ValId3;

			set @TmpRez =	case @Val
							when '-' then @Val2 - @Val3
							when '+' then @Val2 + @Val3
							when '*' then @Val2 * @Val3
							when '/' then try_convert(int, try_convert(decimal, @Val2) / @Val3)
						end;

			if @Debug = 1
			begin
				select 'REZ';
				select @TmpRez as rez;
			end;

			insert into PI_PILE
			(
				PIE_ID
				,PI_VAL
				,PI_ORDER
			)
			select
				@MainPieId
				,@TmpRez
				,case
					when @Order <= @Order2 and @Order <= @Order3 then @Order
					when @Order2 <= @Order and @Order2 <= @Order3 then @Order2
					when @Order3 <= @Order and @Order3 <= @Order2 then @Order3
				end

			if @Debug = 1
			begin
				select * from PIE_PILE_ENTETE where PIE_ID = @MainPieId;
				select * from PI_PILE where PIE_ID = @MainPieId order by PI_ORDER;
			end;
		end
		else
		begin
			insert into PI_PILE
			(
				PIE_ID
				,PI_VAL
				,PI_ORDER
			)
			select
				@SecondPieId
				,@Val
				,@Order

			if @Debug = 1
			begin
				select 'VAL IS NUMBER';
				select * from PIE_PILE_ENTETE where PIE_ID = @SecondPieId;
				select * from PI_PILE where PIE_ID = @SecondPieId order by PI_ORDER;
			end;
		end;

		select @SizeMainPile = count(*) from PI_PILE where PIE_ID = @MainPieId;
		select @SizeSecondPile = count(*) from PI_PILE where PIE_ID = @SecondPieId;
	end;

	select top 1 @Rez = PI_VAL from PI_PILE where PIE_ID = @MainPieId order by PI_ORDER;
	declare @EndTime datetime2 = getdate();
	select datediff(ms, @StartTime, @EndTime) as ' EXEC TIME (in ms)';
	select datediff(ns, @StartTime, @EndTime) as ' EXEC TIME (in ns)';
end;