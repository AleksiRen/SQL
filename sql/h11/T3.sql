CREATE PROC pankki.TiliOte
 --PARAMETRIT
 @TILINUMERO VARCHAR(20),
 @TAPAHTUMALKM INT = 10
 AS
 SET NOCOUNT ON
--tämänhetkinen tilin saldo
DECLARE @TILISALDO decimal(11,2)= (select saldo from PANKKI.TILI WHERE CD =  @TILINUMERO)
--taulu johon säilötään tulokset
declare @taulu table (tapahtumapvm datetime, summa varchar(200), saldo decimal(11,2))
--kursorilla rivi kerrallaan, jotta saadaan laskettua tilin saldo sen hetkisen tapahtuman jälkeen
 DECLARE kursori CURSOR FOR SELECT  top(@TAPAHTUMALKM)
 									A.TAPAHTUMAPVM AS AIKA,
									a.maara
									,a.tyyppi
							FROM PANKKI.TILitapahtuma AS A 
							ORDER BY AIKA DESC
--KURSORIN MUUTTUJAt
DECLARE 
@SUM decimal(11,2),
@pvm datetime,
@tyyppi char(1)

--kursorilla haetaan pvm, siirretty määrä ja tapahtuman tyyppi 
OPEN KURSORI
 FETCH NEXT FROM kursori INTO @pvm, @sum, @tyyppi
  WHILE @@FETCH_STATUS = 0
  BEGIN
	--kursorilla haetut tilitapahtuma- taulun rivit, sekä tilin sen hetkinen saldo insertataan tauluun
	if @tyyppi = 'O'
	begin
		insert into @taulu(tapahtumapvm, summa, saldo)
		values (@pvm, '-'+FORMAT(@sum, 'C', 'fi-fi'), @tilisaldo)	
		 --jos kyseessä oli otto, lisätään oton verran rahaa @tilinsaldoon, jotta saadaan seuraavaa riviä varten oikea arvo sen hetkiseen tilin saldoon
		SET @TILISALDO += @SUM	
	end
	
	else
	begin
		insert into @taulu(tapahtumapvm, summa, saldo)
		values (@pvm, '+'+ FORMAT(@sum, 'C', 'fi-fi'), @tilisaldo)	
		--jos kyseessä taas insertti, miinustetaan insertin verran @tilinsaldosta, jotta saadaan tapahtumaa edeltävä arvo
		set @TILISALDO -=@sum
	end
	
	FETCH NEXT FROM kursori INTO @pvm, @sum, @tyyppi
  END
  CLOSE kursori
  DEALLOCATE kursori

  SELECT CURRENT_TIMESTAMP AS AIKA, NULL AS SUMMA, (SELECT SALDO FROM PANKKI.TILI WHERE CD =  @TILINUMERO) AS SALDO
  UNION
  select tapahtumapvm, SUMMA, SALDO
  from @taulu
  order by aika desc

SET NOCOUNT OFF
GO


SELECT * 
FROM PANKKI.TILITAPAHTUMA
WHERE TILI = '123456-123457'

EXEC pankki.TiliOte '123456-123457', 3

