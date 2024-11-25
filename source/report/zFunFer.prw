//Bibliotecas de Funcoes
#Include "protheus.ch"
#Include "topconn.ch"
/*
ßßßßßßßßß {Protheus.doc} User Function zFunFer ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
ßß    @description Relatorio dos Dias de Direito de cada matricula                    ßß
ßß    @type Function                                                                  ßß
ßß    @author Renato Silva                                                            ßß
ßß    @since 08/10/2022                                                               ßß
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function zFunFer()

    Local aArea    := FWGetArea()
	Local oReport  as OBJECT
    Local aPergs   := {}
    //Local dDataDe  := FirstDate(Date())
    //Local dDataAt  := LastDate(Date())
    Local cFilDe  := Space(TamSX3('RA_FILIAL')[1])
    Local cFilAt  := StrTran(cFilDe, ' ', 'Z')
    Local cMatDe  := Space(TamSX3('RA_MAT')[1])
    Local cMatAt  := StrTran(cMatDe, ' ', 'Z')


    aAdd(aPergs, {1, "Filial De"    ,  cFilDe,  "", ".T.", "XM0", ".T.", 12, .F.})
    aAdd(aPergs, {1, "Filial Até"   ,  cFilAt,  "", ".T.", "XM0", ".T.", 12, .T.})
    aAdd(aPergs, {1, "Matricula De" ,  cMatDe,  "", ".T.", "SRA", ".T.", 36, .F.})
    aAdd(aPergs, {1, "Matricula Até",  cMatAt,  "", ".T.", "SRA", ".T.", 36, .T.})
	aAdd(aPergs, {1, "Situação"     ,Space(05),   ,"fSituacao()","","",0,.T.})

    //Se a pergunta for confirmada
    If ParamBox(aPergs, "Informe os parâmetros", , , , , , , , , .F., .F.)
		oReport := ReportDef()
		oReport:PrintDialog()
	EndIf
	
	FWRestArea(aArea)

Return NIL


Static Function ReportDef()

    Local oReport as OBJECT
	Local oSecFun as OBJECT
	Local oSecPer as OBJECT

	//Criação do componente de impressão
	oReport := TReport():New("zFunFer","Funcionarios x Dias de Direito",,{|oReport| fRepPrint(oReport)},"Funcionarios x Dias de Direito")
	oReport:SetTotalInLine(.F.)
	oReport:lParamPage := .F.
	oReport:oPage:SetPaperSize(9)
	oReport:SetPortrait()
	oReport:SetLineHeight(50)
    oReport:cFontBody := "Arial"
	oReport:nFontBody := 8
	
	//Criando a seção
	oSecFun := TRSection():New( oReport,"Dados",{"QRY_FUNC"} )
	oSecFun:SetTotalInLine(.F.)
	
	//Colunas do relatório
	TRCell():New(oSecFun, "RA_FILIAL" , "QRY_FUNC", "Filial"   , , 02,,,,,,,,,,,)
	TRCell():New(oSecFun, "RA_MAT"    , "QRY_FUNC", "Matricula", , 06,,,,,,,,,,,)
	TRCell():New(oSecFun, "RA_NOME"    ,"QRY_FUNC", "Nome do Func", , 30,,,,,,,,,,,)
	TRCell():New(oSecFun, "RA_ADMISSA", "QRY_FUNC", "Admissao" , , 10,,{|| StoD(QRY_FUNC->RA_ADMISSA) },,,,,,,,,)
	TRCell():New(oSecFun, "RA_SITFOLH", "QRY_FUNC", "Situac"   , , 01,,,,,,,,,,,)
	TRCell():New(oSecFun, "RA_CIC"    , "QRY_FUNC", "C.P.F."   , , 14,,,,,,,,,,,)

	//Criando a seção
	oSecPer := TRSection():New( oSecFun,"Dias de Direito",{"QRY_FUNC"} )
	oSecPer:SetTotalInLine(.F.)
	
	//Colunas do relatório
	TRCell():New(oSecPer, "RF_PD"      , "QRY_PER", "Verba"        , , 03,,,,,,,,,,,)
	TRCell():New(oSecPer, "RF_DESCPD"  , "QRY_PER", "Desc.Verba"   , , 15,,,,,,,,,,,)
	TRCell():New(oSecPer, "RF_DATABAS" , "QRY_PER", "Ini PerAquis" , , 10,,{|| StoD(QRY_PER->RF_DATABAS) },,,,,,,,,)
	TRCell():New(oSecPer, "RF_DATAFIM" , "QRY_PER", "Fim PerAquis" , , 10,,{|| StoD(QRY_PER->RF_DATAFIM) },,,,,,,,,)
	TRCell():New(oSecPer, "RF_DIASPRG" , "QRY_PER", "Dias Dir"     , , 02,,,,,,,,,,,)
	TRCell():New(oSecPer, "RF_DFERVAT" , "QRY_PER", "Dias Venc"    , , 02,,,,,,,,,,,)
	TRCell():New(oSecPer, "RF_DFERAAT" , "QRY_PER", "Dias Ant"     , , 02,,,,,,,,,,,)
	TRCell():New(oSecPer, "RF_STATUS"  , "QRY_PER", "Situação"     , , 10,,,,,,,,,,,)

Return oReport


Static Function fRepPrint(oReport)

    Local aArea    := FWGetArea()
	Local cFunc     := ""
	Local oSecFun  := Nil
	Local oSecPer  := Nil
	Local nAtual   := 0
	Local nTotal   := 0
	Local nCount    := 0
	Private cSituac := ""

	For nCount := 1 to len(MV_PAR05) - 1
		cSituac += "'" + (substr(MV_PAR05,nCount,1)) + "',"
	Next nCount
	cSituac += "'" + (substr(MV_PAR05,len(MV_PAR05),1)) + "'"
	
	//Pegando as seções
	oSecFun := oReport:Section(1)
	oSecPer := oReport:Section(1):Section(1)
	
	//Faz uma consulta buscando os dados sintéticos
    cFunc := "SELECT"                         + CRLF
    cFunc += "    RA_FILIAL,"                 + CRLF
    cFunc += "    RA_MAT,"                    + CRLF
	cFunc += "    RA_NOME,"                   + CRLF
    cFunc += "    RA_ADMISSA,"                + CRLF
    cFunc += "    RA_SITFOLH,"                + CRLF
    cFunc += "    RA_CIC"                     + CRLF
    cFunc += "FROM "+RetSQLName('SRA')+" SRA" + CRLF
    cFunc += "WHERE SRA.D_E_L_E_T_=''"        + CRLF
    cFunc += "    AND SRA.RA_FILIAL >='"+MV_PAR01+"'"+ CRLF
    cFunc += "    AND SRA.RA_FILIAL <='"+MV_PAR02+"'"+ CRLF
    cFunc += "    AND SRA.RA_MAT >= '"+MV_PAR03+"'" + CRLF
    cFunc += "    AND SRA.RA_MAT <= '"+MV_PAR04+"'" + CRLF
	cFunc += "    AND SRA.RA_SITFOLH IN (" + cSituac + ")" + CRLF
	cFunc += "ORDER BY SRA.RA_MAT" + CRLF

	TCQuery cFunc New Alias "QRY_FUNC"

	Count To nTotal
	
	If nTotal != 0
		oReport:SetMeter(nTotal)
		QRY_FUNC->(DbGoTop())
		nAtual := 0
		oSecFun:Init()

        While !QRY_FUNC->(EOF())
			nAtual++
			oReport:SetMsgPrint("Imprimindo registro " + cValToChar(nAtual) + " de " + cValToChar(nTotal) + "...")
			oReport:IncMeter()
			
			//Imprimindo a linha atual
			oSecFun:PrintLine()
			
            cPerAq := "SELECT"                         + CRLF
			cPerAq += "    RF_PD,"                     + CRLF
			cPerAq += "    'FERIAS' RF_DESCPD,"        + CRLF
            cPerAq += "    RF_DATABAS,"                + CRLF
            cPerAq += "    RF_DATAFIM,"                + CRLF
			cPerAq += "    RF_DIASPRG,"                + CRLF
            cPerAq += "    RF_DFERVAT,"                + CRLF
            cPerAq += "    RF_DFERAAT,"                + CRLF
            cPerAq += "    RF_STATUS"                  + CRLF
            cPerAq += "FROM "+RetSQLName('SRF')+" SRF" + CRLF
            cPerAq += "WHERE SRF.D_E_L_E_T_=''"        + CRLF
            cPerAq += "    AND SRF.RF_FILIAL ='"+ QRY_FUNC->(RA_FILIAL) +"'"+ CRLF
            cPerAq += "    AND SRF.RF_MAT = '"+ QRY_FUNC->(RA_MAT) +"'" + CRLF

            TCQuery cPerAq New Alias "QRY_PER"

            //Enquanto houver dados analíticos
            oSecPer:Init()

            While ! QRY_PER->(EOF())
                oSecPer:PrintLine()
                QRY_PER->(dbSkip())
            EndDo

            QRY_PER->(dbCloseArea())
            oSecPer:Finish()

            oSecFun:Finish()
            oSecFun:Init()

            QRY_FUNC->(dbSkip())

        EndDo
		oSecFun:Finish()
        
    EndIf

    QRY_FUNC->(dbCloseArea())
    FWRestArea(aArea)

Return NIL
