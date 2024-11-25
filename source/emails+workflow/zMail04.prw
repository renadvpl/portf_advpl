//Bibliotecas
#Include "TOTVS.ch"
#Include "TopConn.ch"

/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßß {Protheus.doc} MT121BRW ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
ßß   @description P.E. que adiciona funções no Outras Ações do Pedido de Compras      ßß
ßß   @author Renato Silva                                                             ßß
ßß   @since 10/03/2024                                                                ßß
ßß   @see https://tdn.totvs.com/pages/releaseview.action?pageId=51249528              ßß
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function MT121BRW()
    Local aArea := FWGetArea()

    //Adiciona funções no Outras Ações
    aAdd(aRotina, {"Enviar Workflow (*)", "u_zMail04()", 0, 2, 0, Nil})

    FWRestArea(aArea)
Return NIL

/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßß {Protheus.doc} ZMAIL04 ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
ßß   @description Função que monta o email e dispara o workflow                       ßß
ßß   @author Renato Silva                                                             ßß
ßß   @since 10/03/2024                                                                ßß
ßß   @see https://tdn.totvs.com/pages/releaseview.action?pageId=51249528              ßß
ßß   @obs Caso você queira gravar o ID, crie um campo (C7_X_WFID) e grave a cWFID     ßß
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function zMail04()
    Processa({|| fProcessa() }, "Processando...")
Return NIL

Static Function fProcessa()
    Local aArea := FWGetArea()
    Local oProcess
    Local oHtml
    Local cMailID    := ""
    Local cWFID      := ""
    Local cMsgAux    := ""
    Local cCodProc   := "000001"
    Local cCodUsr    := RetCodUsr()
    Local cNomeUsr   := UsrRetName(cCodUsr)
    Local cQrySC7    := ""
    Local nValTot    := 0
    Local cMascQuant := PesqPict("SC7", "C7_QUANT")
    Local cMascUnita := PesqPict("SC7", "C7_PRECO")
    Local cMascDesco := PesqPict("SC7", "C7_VLDESC")
    Local cMascVlTot := PesqPict("SC7", "C7_TOTAL")

    //Posiciona na condição de pagamento e no fornecedor
    dbSelectArea("SE4")
    SE4->(dbSetOrder(1)) // E4_FILIAL + E4_CODIGO
    SE4->(MsSeek(FWxFilial("SE4") + SC7->C7_COND))
    dbSelectArea("SA2")
    SA2->(dbSetOrder(1)) // A2_FILIAL + A2_COD + A2_LOJA
    SA2->(MsSeek(FWxFilial("SA2") + SC7->C7_FORNECE + SC7->C7_LOJA))

    ProcRegua(1)

    //Se o campo de eMail estiver vazio
    If Empty(SA2->A2_EMAIL)
        FWAlertError("O campo de eMail está vazio!", "Falha no Workflow")

    //Se tiver o campo de eMail preenchido
    Else
        //Instancia o processo
        oProcess := TWFProcess():New(cCodProc, "Aprovação Pedido de Compras")
        oProcess :NewTask("Pedido de Compras", "\workflow\modelo_pedido_compra.html" )

        //Define o Assunto, o Destinatário e o que irá executar quando o destinatário enviar a resposta
        oProcess:cSubject := "Aprovação de Pedido de Compras - Número " + SC7->C7_NUM
        oProcess:cTo      := Alltrim(SA2->A2_EMAIL)
        oProcess:bReturn  := "u_zMail05()"

        //Pega o corpo do HTML e o ID do WorkFlow
        oHtml := oProcess:oHTML
        cWFID := oProcess:fProcessID + oProcess:fTaskId

        //Define os campos gerais do corpo
        IncProc("Dados gerais do Workflow")
        oHtml:ValByName("WFPedidoCompra"        , SC7->C7_NUM)
        oHtml:ValByName("WFDataEmissao"         , dToC(SC7->C7_EMISSAO))
        oHtml:ValByName("WFCondicaoPagamento"   , SC7->C7_COND + " - " + SE4->E4_DESCRI)
        oHtml:ValByName("WFFornecedor"          , SA2->A2_COD + " " + SA2->A2_LOJA)
        oHtml:ValByName("WFNome"                , SA2->A2_NOME)
        oHtml:ValByName("WFContato"             , SC7->C7_CONTATO)
        oHtml:ValByName("WFEmail"               , SA2->A2_EMAIL)
        oHtml:ValByName("WFObservacao"          , Alltrim(SC7->C7_OBS))
        oHtml:ValByName("WFEmpresa"             , cEmpAnt)
        oHtml:ValByName("WFFilial"              , cFilAnt)
        oHtml:ValByName("WFUsuarioCodigo"       , cCodUsr)
        oHtml:ValByName("WFUsuarioNome"         , cNomeUsr)
        oHtml:ValByName("WFID"                  , cWFID)
        oHtml:ValByName("WFData"                , dToC(Date()))
        oHtml:ValByName("WFHora"                , Time())

        //Busca agora, todos os itens do pedido de compras
        cQrySC7 := " SELECT " + CRLF
        cQrySC7 += "     C7_ITEM, " + CRLF
        cQrySC7 += "     C7_PRODUTO, " + CRLF
        cQrySC7 += "     C7_DESCRI, " + CRLF
        cQrySC7 += "     C7_UM, " + CRLF
        cQrySC7 += "     C7_QUANT, " + CRLF
        cQrySC7 += "     C7_PRECO, " + CRLF
        cQrySC7 += "     C7_VLDESC, " + CRLF
        cQrySC7 += "     C7_TOTAL - C7_VLDESC AS TOTAL, " + CRLF
        cQrySC7 += "     C7_DATPRF " + CRLF
        cQrySC7 += " FROM " + CRLF
        cQrySC7 += "     " + RetSQLName("SC7") + " SC7 " + CRLF
        cQrySC7 += " WHERE " + CRLF
        cQrySC7 += "     C7_FILIAL = '" + SC7->C7_FILIAL + "' " + CRLF
        cQrySC7 += "     AND C7_NUM = '" + SC7->C7_NUM + "' " + CRLF
        cQrySC7 += "     AND SC7.D_E_L_E_T_ = ' ' " + CRLF
        cQrySC7 += " ORDER BY " + CRLF
        cQrySC7 += "     C7_ITEM " + CRLF
        TCQuery cQrySC7 New Alias "QRY_SC7"
        TCSetField("QRY_SC7", "C7_DATPRF", "D")

        //Percorre os dados
        While ! QRY_SC7->(EoF())
            IncProc("Adicionando item " + QRY_SC7->C7_ITEM)

            //Incrementa o total
            nValTot += QRY_SC7->TOTAL

            //Adiciona os valores dos itens (tem que ter o . no nome)
            aAdd(oHtml:ValByName('it.Seq')       , QRY_SC7->C7_ITEM)
            aAdd(oHtml:ValByName('it.Produto')   , QRY_SC7->C7_PRODUTO)
            aAdd(oHtml:ValByName('it.Descricao') , QRY_SC7->C7_DESCRI)
            aAdd(oHtml:ValByName('it.UnidMed')   , QRY_SC7->C7_UM)
            aAdd(oHtml:ValByName('it.Quantidade'), Alltrim(Transform(QRY_SC7->C7_QUANT,  cMascQuant)) )
            aAdd(oHtml:ValByName('it.ValUnit')   , "R$ " + Alltrim(Transform(QRY_SC7->C7_PRECO,  cMascUnita)) )
            aAdd(oHtml:ValByName('it.ValDescon') , "R$ " + Alltrim(Transform(QRY_SC7->C7_VLDESC, cMascDesco)) )
            aAdd(oHtml:ValByName('it.ValTotal')  , "R$ " + Alltrim(Transform(QRY_SC7->TOTAL,     cMascVlTot)) )
            aAdd(oHtml:ValByName('it.DataEntreg'), dToC(QRY_SC7->C7_DATPRF))

            QRY_SC7->(dbSkip())
        EndDo
        QRY_SC7->(dbCloseArea())

        //Define o valor total
        oHtml:ValByName("WFValorTotal", "R$ " + Alltrim(Transform(nValTot, cMascVlTot)))

        //Dispara o início do processo
        IncProc("Enviando o WorkFlow")
        cMailID := oProcess:Start()

        //Exibe uma mensagem
        cMsgAux := "Foi disparado um WorkFlow!" + CRLF
        cMsgAux += "WF ID: " + cWFID + CRLF
        cMsgAux += "eMail ID: " + cMailID
        FWAlertInfo(cMsgAux, "Disparo zMail04")

        //Encerra o processo
        IncProc("Encerrando processo")
        oProcess:Free()
    EndIf

    FWRestArea(aArea)
Return NIL
