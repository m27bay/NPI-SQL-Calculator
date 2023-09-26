begin tran
	declare 
		--@Equation varchar(max) = '13 12 - 20 26 * *'
		@Equation varchar(max) = '230 653748 * 7830 + 5 / 673 -'
		,@Rez varchar(255)
		,@Debug bit = 0;

	exec ps_NPICTRL_Calculate @Equation, @Rez output, @Debug;
	select @Equation+' = '+convert(varchar(255), @Rez) AS RESULTAT;
rollback tran