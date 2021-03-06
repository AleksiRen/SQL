﻿CREATE FUNCTION pankki.Asiakkaat(
@ALARAJA int,
@YLARAJA int)
RETURNS @paluu TABLE(AsiakasId BIGINT, AsiakasNimi VARCHAR(200))
AS
BEGIN
DECLARE @LASKURI INT = 0
--INSERTTAA ALARAJASTA YLÄRAJAAN MAHDOLLISET ID ARVOT JA NIMET TAULUUN
WHILE @ALARAJA < @YLARAJA+1
BEGIN
	INSERT @PALUU(AsiakasId, AsiakasNimi)
	SELECT ID, NIMI
	FROM PANKKI.YRITYS
	WHERE ID =@ALARAJA
	UNION
	SELECT ID, ETUNIMI + ' '+SUKUNIMI AS NIMI
	FROM PANKKI.HENKILO
	WHERE ID =@ALARAJA
	SET @ALARAJA+=1
END
RETURN
END
GO

--SELECT * FROM PANKKI.ASIAKKAAT (250,300)



