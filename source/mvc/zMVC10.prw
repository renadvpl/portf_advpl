//Bibliotecas
#INCLUDE 'totvs.ch'
#INCLUDE 'fwmvcdef.ch'

/*
��������������������������� {Protheus.doc} ZMVC09 ������������������������������������
��   @description  Funcionamento da FWExecView (abertura de outra view)             ��
��   @author       Renato Silva                                                     ��
��   @since        20/03/2024                                                       ��
��   @obs          Atualizacoes > Model-View-Control > Abertura Outra View          ��
��������������������������������������������������������������������������������������
*/
User Function zMVC10()

    Local aArea   := FWGetArea()
    Local cFunBkp := FunName()
     
    dbSelectArea('SA2')
    SA2->( dbSetOrder(1) ) //Filial + C�digo + Loja

    //Se conseguir posicionar
    If SA2->( dbSeek(FWxFilial('SA2') + "F00002") )
        SetFunName("MATA020")
        FWExecView('Visualizacao Teste', 'MATA020', MODEL_OPERATION_VIEW)
        SetFunName(cFunBkp)
    EndIf
     
    FWRestArea(aArea)

Return NIL
