#include 'parmtype.ch'
#include 'protheus.ch'
#include 'rwmake.ch'
#include 'tbiconn.ch'
#include 'topconn.ch'

/*/{Protheus.doc} ATIVINAT
Relatório de Ativos e Inativos
@author Ricardo Antunes
@since 26/08/20
@version 1.0
/*/

User Function ATIVINAT()

	local oReport   := nil
	local aPergs    := {}
	local cUsers	:= SuperGetMv("FU_RESTUSE",,"000000|")
	private aRet    := {}
 
	if!(__cUserid $ cUsers)
		Help( ,, 'RESTUSER/FU_RESTUSE',,"Usuário não tem permissão para acessar essa rotina!", 1, 0)
	Else
	    aAdd(aPergs,{2,"Empresas"    , "1"      , { "1=Somente Ativas", "2=Todas" }    ,70 ,".T.",.F.})
		aAdd(aPergs,{1,"Situações"   , " ADFT"         ,              , "fSituacao()"  ,"" ,"",06,.F.})
		aAdd(aPergs,{1,"Categorias"  , "ACDEGHIJMPST*" ,              , "fCategoria()" ,"" ,"",55,.F.})
		aAdd(aPergs,{2,"Ordenar por" , "1"      , { "1=Mantida" , "2=CPF" , "3=Nome" } ,50 , ""  ,.F.})

		//-----------------------
		// Abertura das perguntas
		//-----------------------
		if ParamBox(aPergs,"Parâmetros da Rotina",aRet, , , , , , , , .T. ,.T.)
			oReport:= ReportDef()
			oReport:PrintDialog()
		endif

	EndIf

Return NIL


/*/{Protheus.doc} ReportDef
Definição do tReport
@author Daniel de S. Bastos
@since 11/01/2018
@version 1.0
/*/
Static Function ReportDef()

	Local oReport  as OBJECT
	Local oSection as OBJECT

	oReport := TReport():New("ATIVINAT","Ativos e Inativos",,{|oReport| ReportPrint(oReport)},"Este relatório irá imprimir Ativos e Inativos.")
	oReport:SetLandscape(.T.)
	oReport:SetColSpace(2)

	// -----------------------------
	// Secao 1 - Dados analíticos
	// -----------------------------
	oSection := TRSection():New(oReport,"Func. Ativos e Inativos" )
	oSection:SetTotalInLine(.T.)
	
	TRCell():New(oSection,"CNPJ"			,"WRK"	,"CNPJ"		 ,		                        ,14							    , ,{|| WRK->CNPJ })
    TRCell():New(oSection,"MANTIDA"			,"WRK"	,"MANTIDA"	 ,		                        ,25							    , ,{|| WRK->MANTIDA })
    TRCell():New(oSection,"DESCEMP"			,"WRK"	,"DESCEMP"	 ,		                        ,25							    , ,{|| WRK->DESCEMP })
    TRCell():New(oSection,"FILIAL"			,"WRK"	,"FILIAL"    ,		                        ,TamSX3("RA_FILIAL")  	[1]	    , ,{|| WRK->FILIAL })
	TRCell():New(oSection,"DESCFIL"			,"WRK"	,"DESCFIL"	 ,		                        ,30							    , ,{|| WRK->DESCFIL})
    TRCell():New(oSection,"RE"				,"WRK"	,"RE"		 ,PesqPict("SRA","RA_MAT")      ,TamSX3("RA_MAT")  		[1]     , ,{|| WRK->RE })
	TRCell():New(oSection,"CCUSTO"			,"WRK"	,"CCUSTO"	 ,		                        ,TamSX3("RA_CC")		[1]     , ,{|| WRK->CCUSTO	 })
    TRCell():New(oSection,"DESCC"	        ,"WRK"	,"DESCC"	 ,			                    ,30				                , ,{|| WRK->DESCC })
    TRCell():New(oSection,"NOME"			,"WRK"	,"NOME"		 ,		                        ,25							    , ,{|| WRK->NOME })
	TRCell():New(oSection,"CPF"	            ,"WRK"	,"CPF"	     ,		                        ,TamSX3("RA_CIC")       [1]     , ,{|| WRK->CPF})
	TRCell():New(oSection,"PIS"	            ,"WRK"	,"PIS"       ,		                        ,TamSX3("RA_PIS")       [1]     , ,{|| WRK->PIS })
    TRCell():New(oSection,"NASC"	        ,"WRK"	,"NASC"      ,                              ,TamSX3("RA_NASC")      [1]	+ 4 , ,{|| SToD(WRK->DATANASC) })
	TRCell():New(oSection,"SEXO"	        ,"WRK"	,"SEXO"		 ,		                        ,TamSX3("RA_SEXO")      [1]     , ,{|| WRK->SEXO })
    TRCell():New(oSection,"COR"	            ,"WRK"	,"COR"		 ,		                        ,13                             , ,{|| X3Combo("RA_RACACOR",WRK->COR) })
	TRCell():New(oSection,"ADMISSAO"		,"WRK"	,"ADMISSAO"	 ,		                        ,TamSX3("RH_DATAINI")	[1]     , ,{|| StoD(WRK->ADMISSAO) })
    TRCell():New(oSection,"DEMISSAO"        ,"WRK"	,"DEMISSAO"  ,                              ,TamSX3("RA_DEMISSA")   [1]	    , ,{|| SToD(WRK->DEMISSAO) })
    TRCell():New(oSection,"FUNC"	        ,"WRK"	,"FUNCAO"	 ,			                    ,TamSX3("RA_CODFUNC")   [1]     , ,{|| WRK->CODFUNCAO })
	TRCell():New(oSection,"DESCFUNC"        ,"WRK"	,"DESCFUNC"  ,			                    ,TamSX3("RJ_DESC")      [1]     , ,{|| WRK->CARGO })
	TRCell():New(oSection,"HRSEMAN"	        ,"WRK"	,"HRSEMAN"   ,                              ,TamSX3("RA_HRSEMAN")   [1]	    , ,{|| WRK->HMENSAIS })
	TRCell():New(oSection,"HRSMES"	        ,"WRK"	,"HRSMES"    ,                              ,TamSX3("RA_HRSMES")    [1]	    , ,{|| WRK->HSEMANA })	
    TRCell():New(oSection,"CATEG"	        ,"WRK"	,"CATEGORIA" ,                              ,TamSX3("RA_CATFUNC")   [1]	    , ,{|| WRK->CATEGORIA })
    TRCell():New(oSection,"SALARIO"	        ,"WRK"	,"SALARIO"   ,PesqPict("SRA","RA_SALARIO")  ,TamSX3("RA_SALARIO")   [1]     , ,{|| WRK->SALARIO })
	TRCell():New(oSection,"GRATREP"	        ,"WRK"	,"GRATREP"   ,PesqPict("SRA","RA_GRATREP")  ,TamSX3("RA_GRATREP")   [1]     , ,{|| WRK->GRATREP })
   	TRCell():New(oSection,"SITUA"	        ,"WRK"	,"SITUAÇÃO"  ,                              ,TamSX3("RA_SITFOLH")   [1]	    , ,{|| WRK->SITFOLHA })
    TRCell():New(oSection,"GRAURAI"	        ,"WRK"	,"GRAUINRAI" ,                              ,TamSX3("RA_GRINRAI")   [1]	    , ,{|| WRK->GRAURAIS })
	TRCell():New(oSection,"DESGRAU"	        ,"WRK"	,"DESCGRAU"  ,                              ,80                    	        , ,{|| WRK->SX526 })
    TRCell():New(oSection,"TPRESC"	        ,"WRK"	,"TPRESC"    ,                              ,TamSX3("RA_RESCRAI")   [1]	    , ,{|| WRK->RESCRAIS })
	TRCell():New(oSection,"DESCRES"	        ,"WRK"	,"DESCRES"   ,                              ,80                    	        , ,{|| WRK->SX527 })
    TRCell():New(oSection,"DEFICI"	        ,"WRK"	,"DEFICIENTE",                              ,TamSX3("RA_DEFIFIS")   [1]	    , ,{|| UPPER(X3COMBO("RA_DEFIFIS",WRK->DEFICIENCIA)) })
	TRCell():New(oSection,"TPDEFI"	        ,"WRK"	,"TPDEFICI"  ,                              ,TamSX3("RA_TPDEFFI")   [1]	    , ,{|| UPPER(X3COMBO("RA_TPDEFFI",WRK->TPDEFICI)) })
    TRCell():New(oSection,"GRATFIX"	        ,"WRK"	,"GRATFIX"   ,                              ,TamSX3("RA_GRATFIX")   [1]	    , ,{|| WRK->GRATFIX })
    TRCell():New(oSection,"EMAIL"	        ,"WRK"	,"EMAIL"     ,                              ,TamSX3("RA_EMAIL")     [1]	    , ,{|| WRK->EMAIL })
    TRCell():New(oSection,"SINDICA"	        ,"WRK"	,"SINDICATO" ,                              ,TamSX3("RA_SINDICA")   [1]	    , ,{|| WRK->SINDICATO })
	TRCell():New(oSection,"CIDADE          ","WRK"	,"CIDADE"    ,                              ,TamSX3("RA_MUNICIP")   [1]	    , ,{|| WRK->CIDADE })
	TRCell():New(oSection,"UF"	            ,"WRK"	,"UF"        ,                              ,TamSX3("RA_ESTADO")    [1]	    , ,{|| WRK->UF })

Return(oReport)


/*/{Protheus.doc} ReportPrint
Impressão do tReport
@author Daniel de S. Bastos
@since 08/08/2017
@version 2.0
/*/

Static Function ReportPrint(oReport)

	local oSection	:= oReport:Section(1)
	local aGerenc   := fGetZAA()
	local cSituac 	:= ""
	local cCateg    := ""
    local n1		:= ""
	local cQry 		:= ""
	local cTpOrd    := ""
	local cOrdem    := ""

//------------------------------------------
// Tratamento das Situações e Categoria
//------------------------------------------
    cSituac := Upper(fSqlIN( aRet[02], 1 ))
    cCateg  := Upper(fSqlIN( aRet[03], 1 ))

//------------------------------------------
// Tratamento da Ordenação
//------------------------------------------
    cTpOrd  := aRet[04]

	Do Case
	    Case cTpOrd == '1'
	        cOrdem := "MANTIDA , FILIAL , RE"
	    Case cTpOrd == '2'
	        cOrdem := "CPF , MANTIDA , FILIAL"
		Case cTpOrd == '3'
	        cOrdem := "NOME , MANTIDA , FILIAL"
	End Case
	    
//--------------------
// Tratamento da Query
//--------------------
    For n1 := 1 To Len(aGerenc)

		cQry += "SELECT DISTINCT" + CRLF
		cQry += "    ZAA_CNPJ CNPJ," + CRLF
		cQry += "    ZAA_CODEMP MANTIDA," + CRLF
		cQry += "    ZAA_DSCEMP DESCEMP," + CRLF
		cQry += "    RA_FILIAL FILIAL,"  + CRLF
		cQry += "    ZAA_DSCFIL DESCFIL," + CRLF
		cQry += "    RA_MAT RE," + CRLF
		cQry += "    RA_NOME NOME," + CRLF
		cQry += "    RA_CC CCUSTO," + CRLF
		cQry += "    CTT_DESC01 DESCC," + CRLF
		cQry += "    RA_ADMISSA ADMISSAO," + CRLF
		cQry += "    RA_CIC CPF," + CRLF
		cQry += "    RA_PIS PIS," + CRLF
		cQry += "    RA_NASC DATANASC," + CRLF
		cQry += "    RA_ADMISSA ADMISSAO," + CRLF
		cQry += "    RA_DEMISSA DEMISSAO," + CRLF
		cQry += "    RA_HRSMES HMENSAIS," + CRLF
		cQry += "    RA_HRSEMAN HSEMANA," + CRLF
		cQry += "    RA_CODFUNC CODFUNCAO," + CRLF
		cQry += "    RJ_DESC CARGO," + CRLF
		cQry += "    RA_CATFUNC CATEGORIA," + CRLF
		cQry += "    RA_SALARIO SALARIO," + CRLF
		cQry += "    RA_GRATREP GRATREP," + CRLF
		cQry += "    ZAA_MUNIC MUNICIPIO," + CRLF
		cQry += "    RA_SITFOLH SITFOLHA," + CRLF
		cQry += "    RA_GRINRAI GRAURAIS," + CRLF
		cQry += "    RA_SEXO SEXO," + CRLF
		cQry += "    RA_RACACOR COR," + CRLF
		cQry += "    RA_RESCRAI RESCRAIS," + CRLF
		cQry += "    RA_GRATFIX GRATFIX," + CRLF
		cQry += "    RA_EMAIL EMAIL," + CRLF
		cQry += "    RA_SINDICA SINDICATO," + CRLF
		cQry += "    RA_DEFIFIS DEFICIENCIA," + CRLF
		cQry += "    RA_ESTADO UF," + CRLF
		cQry += "    RA_MUNICIP CIDADE," + CRLF
		cQry += "    RA_TPDEFFI TPDEFICI," + CRLF
		cQry += "    SX5A.X5_DESCRI SX526," + CRLF
		cQry += "    SX5b.X5_DESCRI SX527" + CRLF
		cQry += "FROM SRA"+aGerenc[n1,1]+"0 SRA" + CRLF
		cQry += "INNER JOIN SIGA.ZAA010 ZAA"  + CRLF
		cQry += "    on ZAA_CODEMP = '"+aGerenc[n1,1]+"'" + CRLF
		cQry += "    and ZAA_CODFIL = RA_FILIAL"  + CRLF
		cQry += "    and ZAA.D_E_L_E_T_ <> '*'"  + CRLF

		cQry += "INNER JOIN SRJ"+aGerenc[n1,1]+"0 SRJ" + CRLF
		cQry += "    on RJ_FUNCAO = RA_CODFUNC "  + CRLF
		cQry += "    and SRJ.D_E_L_E_T_ <> '*'"  + CRLF

		cQry += "INNER JOIN CTT"+aGerenc[n1,1]+"0 CTT"+ CRLF
		cQry += "    on CTT_CUSTO = RA_CC "  + CRLF
		cQry += "    and CTT.D_E_L_E_T_ <> '*'"  + CRLF

		cQry += "LEFT JOIN SX5010 SX5A"  + CRLF
		cQry += "    on SX5A.X5_TABELA  = '26'"  + CRLF
		cQry += "    and SX5A.X5_CHAVE = SRA.RA_GRINRAI" + CRLF
		cQry += "    and SX5A.D_E_L_E_T_ <> '*'"  + CRLF

		cQry += "LEFT JOIN SX5010 SX5B "  + CRLF
		cQry += "    on SX5B.X5_TABELA  = '27'  "  + CRLF
		cQry += "    and SX5B.X5_CHAVE = SRA.RA_RESCRAI" + CRLF
		cQry += "    and SX5B.D_E_L_E_T_ <> '*'"  + CRLF

		cQry += "WHERE SRA.D_E_L_E_T_ <> '*'"  + CRLF
		cQry += "    and RA_SITFOLH in ("+ cSituac +")" + CRLF
		cQry += "    and RA_CATFUNC in ("+ cCateg +")" + CRLF + CRLF

		cQry += "UNION ALL" + CRLF + CRLF

    Next nCount

	cQry := Stuff( cQry,len(cQry)-12,12,"ORDER BY " + cOrdem )

	cQry := ChangeQuery(cQry)
	TCQuery cQry New Alias "WRK"

	dbSelectArea("WRK")
	WRK->(dbGoTop())
	
	if WRK->(EOF())
		FWAlertInfo("Não há dados para impressão.")
		return()
	endif
	
	oSection:SetLineHeight(15)
	oSection:Init()

	while WRK->(!EOF())
		if oReport:Cancel()
			exit
		endif

		oSection:PrintLine()

		WRK->(dbSkip())
	enddo

	oSection:FiniSh()

	if select("WRK") > 0
		WRK->(dbCloseArea())
	EndIf

return


Static Function fGetZAA()

	Local aEmpresas := {}
    Local cQryZAA	:= GetNextAlias()
	Local cOpcao    := aRet[1]
	Local cSitEmp    := ""

	cSitEmp := IIf( cOpcao == '2' , "%ZAA.ZAA_SITUAC!='O'%", "%ZAA.ZAA_SITUAC='A'%" )

    BeginSQL Alias cQryZAA
        SELECT ZAA_CODEMP FROM %table:ZAA% ZAA
        WHERE ZAA.%notdel% and %exp:cSitEmp%
            and ZAA.ZAA_CODEMP not in ('28','31','32','33')
        GROUP BY ZAA_CODEMP ORDER BY ZAA_CODEMP
    EndSQL
	
	Do While !(cQryZAA)->(EOF())
		aAdd(aEmpresas, { AllTrim((cQryZAA)->ZAA_CODEMP) })
		(cQryZAA)->(dbSkip())
	EndDo

	(cQryZAA)->(dbCloseArea())

Return aEmpresas
