//Bibliotecas de Funcoes
#INCLUDE "totvs.ch"
#INCLUDE "fwmvcdef.ch"

//Variaveis Estaticas
STATIC cTitulo   := "Artistas (com botões na ViewDef)"
STATIC cAliasMVC := "ZD1"

/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßß {Protheus.doc} ZMVC07 ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
ßß   @description Cadastro de Artistas (Modelo 01 com Botoes na ViewDef)            ßß
ßß   @author Renato Silva                                                           ßß
ßß   @since 19/03/2024                                                              ßß
ßß   @obs Atualizacoes > Model-View-Control > Mod 1 c/ Botoes - Artistas            ßß
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function zMVC07()

	Local aArea   := FWGetArea()
	Local oBrowse as OBJECT

	//Instanciando o browse
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias(cAliasMVC)
	oBrowse:SetDescription(cTitulo)
	oBrowse:DisableDetails()

	//Ativa a Browse
	oBrowse:Activate()

	FWRestArea(aArea)

Return NIL


Static Function MenuDef()
	Local aRotina := {}
	//Adicionando opcoes do menu
	ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.zMVC07" OPERATION 1 ACCESS 0
	ADD OPTION aRotina TITLE "Incluir"    ACTION "VIEWDEF.zMVC07" OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.zMVC07" OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE "Excluir"    ACTION "VIEWDEF.zMVC07" OPERATION 5 ACCESS 0
Return aRotina


Static Function ModelDef()

	Local oStruct := FWFormStruct(1, cAliasMVC)
	Local oModel  as OBJECT
	Local bPre    := Nil
	Local bPos    := Nil
	Local bCommit := Nil
	Local bCancel := Nil

	//Cria o modelo de dados para cadastro
	oModel := MPFormModel():New("zMVC07M", bPre, bPos, bCommit, bCancel)
	oModel:AddFields("ZD1MASTER", /*cOwner*/, oStruct)
	oModel:SetDescription("Modelo de dados - " + cTitulo)
	oModel:GetModel("ZD1MASTER"):SetDescription( "Dados de - " + cTitulo)
	oModel:SetPrimaryKey({})

Return oModel


Static Function ViewDef()

	Local oModel  := FWLoadModel("zMVC07")
	Local oStruct := FWFormStruct(2, cAliasMVC)
	Local oView   as OBJECT

	//Cria a visualizacao do cadastro
	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField("VIEW_ZD1", oStruct, "ZD1MASTER")
	oView:CreateHorizontalBox("TELA" , 100 )
	oView:SetOwnerView("VIEW_ZD1", "TELA")

    //Adiciona botões direto no Outras Ações da ViewDef atraves do metodo AddUserButton
    //addUserButton( <cTitle>, <cResource>, <bBloco>, [cToolTip], [nShortCut], [aOptions], [lShowBar] )
	oView:addUserButton("Mensagem", "MAGIC_BMP", {|| Alert("Apenas uma mensagem de teste")}, , , , .T.)
    oView:addUserButton("Imprimir", "MAGIC_BMP", {|| Alert("Em construção")               }, , , , .F.)
	
Return oView

