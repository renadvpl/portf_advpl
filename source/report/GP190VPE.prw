#INCLUDE 'protheus.ch'

/*
��������������������������� {Protheus.doc} GP190VPE ������������������������������������
��   @description Ponto-de-Entrada para validar a inclus�o de determinada tarefa      ��
��   @author Renato Silva                                                             ��
��   @since 07/11/2023                                                                ��
��   @type function                                                                   ��
��   @see https://tdn.totvs.com/display/public/PROT/DT_PE_GP190VPE_Validacao_Tarefa   ��
����������������������������������������������������������������������������������������
*/

User Function GP190VPE()
 
    Local lRet    := .T.
    Local cCateg  := SRA->RA_CATFUNC
    Local aSX5    := FWGetSX5( "28", cCateg )
    Local cDscCat := aSX5[1,4]

    If !( cCateg $ "I*J*T" )
        Help(, , "Aten��o", NIL, "Funcion�rio(a) " + cDscCat, 1, 0, NIL, NIL, NIL, NIL, NIL,;
            {"N�o � poss�vel realizar o lan�amento de tarefas para esta matr�cula."})
        lRet := .F.
    EndIf
 
Return lRet
