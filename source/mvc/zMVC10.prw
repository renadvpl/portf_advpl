//Bibliotecas
#INCLUDE 'totvs.ch'
#INCLUDE 'fwmvcdef.ch'

/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßß {Protheus.doc} ZMVC09 ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
ßß   @description  Funcionamento da FWExecView (abertura de outra view)             ßß
ßß   @author       Renato Silva                                                     ßß
ßß   @since        20/03/2024                                                       ßß
ßß   @obs          Atualizacoes > Model-View-Control > Abertura Outra View          ßß
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function zMVC10()

    Local aArea   := FWGetArea()
    Local cFunBkp := FunName()
     
    dbSelectArea('SA2')
    SA2->( dbSetOrder(1) ) //Filial + Código + Loja

    //Se conseguir posicionar
    If SA2->( dbSeek(FWxFilial('SA2') + "F00002") )
        SetFunName("MATA020")
        FWExecView('Visualizacao Teste', 'MATA020', MODEL_OPERATION_VIEW)
        SetFunName(cFunBkp)
    EndIf
     
    FWRestArea(aArea)

Return NIL
