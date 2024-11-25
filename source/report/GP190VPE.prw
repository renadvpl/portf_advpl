#INCLUDE 'protheus.ch'

/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßß {Protheus.doc} GP190VPE ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
ßß   @description Ponto-de-Entrada para validar a inclusão de determinada tarefa      ßß
ßß   @author Renato Silva                                                             ßß
ßß   @since 07/11/2023                                                                ßß
ßß   @type function                                                                   ßß
ßß   @see https://tdn.totvs.com/display/public/PROT/DT_PE_GP190VPE_Validacao_Tarefa   ßß
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function GP190VPE()
 
    Local lRet    := .T.
    Local cCateg  := SRA->RA_CATFUNC
    Local aSX5    := FWGetSX5( "28", cCateg )
    Local cDscCat := aSX5[1,4]

    If !( cCateg $ "I*J*T" )
        Help(, , "Atenção", NIL, "Funcionário(a) " + cDscCat, 1, 0, NIL, NIL, NIL, NIL, NIL,;
            {"Não é possível realizar o lançamento de tarefas para esta matrícula."})
        lRet := .F.
    EndIf
 
Return lRet
