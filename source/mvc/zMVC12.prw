//Bibliotecas
#INCLUDE 'totvs.ch'
#INCLUDE 'fwmvcdef.ch'

/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßß {Protheus.doc} ZMVC12 ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
ßß   @description Utilizacao do ExecAuto acionando a classe FWMVCRotAuto            ßß
ßß   @author      Renato Silva                                                      ßß
ßß   @since       20/03/2024                                                        ßß
ßß   @obs         Atualizacoes > Model-View-Control > Exec Auto Rotina              ßß
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function zMVC12()

	Local aArea         := FWGetArea()
    Local aDados        := {}
    Private aRotina     := FWLoadMenuDef("zMVC01")
    //Private oModel      := u_z01Model()
    Private oModel      := FWLoadModel("zMVC01")
    Private lMsErroAuto := .F.
     
    //Adicionando os dados do ExecAuto
    aAdd(aDados, {"ZD1_CODIGO"  ,   GetSXENum("ZD1", "ZD1_CODIGO") , Nil})
    aAdd(aDados, {"ZD1_NOME"    ,   "Só Pra Contrariar"            , Nil})
    aAdd(aDados, {"ZD1_OBSERV"  ,   "Observação Teste ExecAuto 2"  , Nil})
    ConfirmSX8()
     
    //Chamando a inclusão - Modelo 1
    lMsErroAuto := .F.
    FWMVCRotAuto( ;
        oModel,;                        //Modelo
        "ZD1",;                         //Alias
        MODEL_OPERATION_INSERT,;        //Operacao
        {{"ZD1MASTER", aDados}};        //Dados
    )

    //Se tiver mais de um Form, deve se passar dessa forma:
    // {{"ZZ2MASTER", aAutoCab}, {"ZZ3DETAIL", aAutoItens}})
     
    //Se houve erro no ExecAuto, mostra mensagem
    If lMsErroAuto
        MostraErro()
     
    //Senão, mostra uma mensagem de inclusão    
    Else
        FWAlertInfo("Registro incluido!", "Atenção")
    EndIf
     
    FWRestArea(aArea)

Return NIL
