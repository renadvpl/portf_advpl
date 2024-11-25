#include "protheus.ch"
#include "topconn.ch"

/*///{Protheus.doc} User Function FU020R ////////////////////////////////////////////////////////////////////////////////////////////
    Relatório com as informações dos funcionários ativos
    @type Function
    @author Renato Silva
    @since 26/04/2022
    @version 1.0
    @obs Inserir o grupo de perguntas FU020R (semelhante ao ABSENT). Não foi inserido funções
    para manipular a SX1 devido a possibilidade da descontinuidade das mesmas.
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////*/

User Function FU020R()

    Private oReport  := Nil
    Private oSection := Nil
    Private cPerg 	 := "FU020R" // Inserir o Grupo de Perguntas FU020R

    Pergunte(cPerg,.F.)

    ReportDef()
    oReport:PrintDialog()

Return


Static Function ReportDef()

    oReport := TReport():New("Funcionários","Informações dos Funcionários",cPerg,{|oReport| PrintReport(oReport)},"Informações dos Funcionários")
    oReport:SetLandscape(.F.)

    oSection := TRSection():New( oReport , "FUNCIONARIOS", {"SQL"} )

    TRCell():New( oSection, "RA_MAT",     "SRA", "Matríc.  ")
    TRCell():New( oSection, "RA_NOME",    "SRA", "Nome Funcionário")
    TRCell():New( oSection, "RA_CC",      "SRA", "C.Custo")
    TRCell():New( oSection, "RA_CODFUNC", "SRA", "Func.")
    TRCell():New( oSection, "RJ_DESC",    "SRJ", "Desc. Função")
    TRCell():New( oSection, "RA_ADMISSA", "SRA", "Admissão")
    TRCell():New( oSection, "RA_RG",      "SRA", "R.G.")
    TRCell():New( oSection, "RA_CATFUNC", "SRA", "Cat.Func.")
    TRCell():New( oSection, "RA_NASC",    "SRA", "Nascimento")
    TRCell():New( oSection, "RA_EMAIL",   "SRA", "E-mail")
    TRCell():New( oSection, "RA_TELEFON", "SRA", "Telefone")
    TRCell():New( oSection, "RA_XOBS",    "SRA", "Observações")

Return oReport


Static Function PrintReport(oReport)

    Local cTabFunc := GetNextAlias()
    Local cSituac  := ""
	Local nCount   := 0

    cSituac	:= ""
    For nCount:=1 to Len(MV_PAR09)
	    cSituac += "'"+Subs(MV_PAR09,nCount,1)+"'"
	    If ( nCount+1 ) <= Len(MV_PAR09)
		    cSituac += "," 
	    Endif
    Next nCount   
    cSituac	:= "%"+cSituac+"%"

	oSection:BeginQuery() 
    
    BeginSql Alias cTabFunc
	  
        SELECT
            SRA.RA_MAT,
            SRA.RA_NOME,
            SRA.RA_CC,
            SRA.RA_CODFUNC,
            SRJ.RJ_DESC,
            SRA.RA_ADMISSA,
            SRA.RA_RG,
            CASE
                WHEN SRA.RA_CATFUNC = 'A' THEN 'Autônom.'
                WHEN SRA.RA_CATFUNC = 'M' THEN 'Mensal.'
                WHEN SRA.RA_CATFUNC = 'T' THEN 'Taref.'
                WHEN SRA.RA_CATFUNC = 'J' THEN 'Planton.'
                ELSE 'Outros'
            END RA_CATFUNC,
            SRA.RA_NASC,
            SRA.RA_EMAIL,
            SRA.RA_TELEFON,
            SRA.RA_XOBS
        FROM
            %table:SRA% SRA
            INNER JOIN %table:SRJ% SRJ
            ON SRA.RA_CODFUNC = SRJ.RJ_FUNCAO
        WHERE
            SRA.RA_FILIAL between %exp:(MV_PAR01)% and %exp:(MV_PAR02)% and
            SRA.RA_MAT    between %exp:(MV_PAR05)% and %exp:(MV_PAR06)% and
            SRA.RA_NOME   between %exp:(MV_PAR07)% and %exp:(MV_PAR08)% and
            SRA.RA_CC     between %exp:(MV_PAR03)% and %exp:(MV_PAR04)% and
            SRA.RA_SITFOLH in (%exp:Upper(cSituac)%) and
            SRA.%notdel%
        ORDER BY
            SRA.RA_MAT
	EndSql

	oSection:EndQuery()
    oSection:Print()

    (cTabFunc)->(dbCloseArea())

Return 
