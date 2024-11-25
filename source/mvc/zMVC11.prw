//Bibliotecas
#INCLUDE 'TOTVS.ch'
#INCLUDE 'FWMVCDef.ch'

/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßß {Protheus.doc} ZMVC11 ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
ßß  @description  Utilizacao do ExecAuto para carregar um modelo de dados da tabela ßß
ßß  @author       Renato Silva                                                      ßß
ßß  @since        20/03/2024                                                        ßß
ßß  @obs          Atualizacoes > Model-View-Control > Exec Auto Modelo              ßß
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function zMVC11()

	Local aArea     := FWGetArea()
	Local lDeuCerto := .F.
	Local oModel    := GetValType('O')
	Local oZD1Mod   := GetValType('O')
	Local aErro     := {}

    //Tem que abrir a tabela primeiro, para não ocasionar o erro _SetNamedPrvt : owner private environment not found
    // ao passar pelo GetSXENum
    dbSelectArea("ZD1")

	//Pegando o modelo de dados, setando a operação de inclusão
	//oModel := u_z01Model()
	oModel := FWLoadModel("zMVC01")
	oModel:SetOperation(3)
	oModel:Activate()

	//Pegando o model dos campos
	oZD1Mod:= oModel:GetModel("ZD1MASTER")
    oZD1Mod:setValue("ZD1_CODIGO" ,  GetSXENum("ZD1", "ZD1_CODIGO") )
	oZD1Mod:setValue("ZD1_NOME"   ,  "Chitãozinho e Xororó"         )
	oZD1Mod:setValue("ZD1_OBSERV" ,  "Observação Teste ExecAuto"    )
    ConfirmSX8()

	//Se conseguir validar as informações e realizar o commit
	If oModel:VldData() .And. oModel:CommitData()
		lDeuCerto := .T.

	//Se não conseguir validar as informações, altera a variável para false
	Else
		lDeuCerto := .F.
	EndIf

	//Se não deu certo a inclusão, mostra a mensagem de erro
	If ! lDeuCerto
		//Busca o Erro do Modelo de Dados
		aErro := oModel:GetErrorMessage()

		//Monta o Texto que será mostrado na tela
		AutoGrLog("Id do formulário de origem:"  + ' [' + AllToChar(aErro[01]) + ']')
		AutoGrLog("Id do campo de origem: "      + ' [' + AllToChar(aErro[02]) + ']')
		AutoGrLog("Id do formulário de erro: "   + ' [' + AllToChar(aErro[03]) + ']')
		AutoGrLog("Id do campo de erro: "        + ' [' + AllToChar(aErro[04]) + ']')
		AutoGrLog("Id do erro: "                 + ' [' + AllToChar(aErro[05]) + ']')
		AutoGrLog("Mensagem do erro: "           + ' [' + AllToChar(aErro[06]) + ']')
		AutoGrLog("Mensagem da solução: "        + ' [' + AllToChar(aErro[07]) + ']')
		AutoGrLog("Valor atribuído: "            + ' [' + AllToChar(aErro[08]) + ']')
		AutoGrLog("Valor anterior: "             + ' [' + AllToChar(aErro[09]) + ']')

		//Mostra a mensagem de Erro
		MostraErro()
	EndIf

	//Desativa o modelo de dados
	oModel:DeActivate()

	FWRestArea(aArea)

Return NIL
