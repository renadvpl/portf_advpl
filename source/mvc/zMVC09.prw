//Bibliotecas
#INCLUDE "totvs.ch"
#INCLUDE "fwmvcdef.ch"

//Variaveis Estaticas
STATIC cTitulo   := "Artistas (com separação em abas)"
STATIC cAliasMVC := "ZD1"

/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßß {Protheus.doc} ZMVC09 ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
ßß   @description  Cadastro de Artistas (Modelo 01 com separacao em abas)           ßß
ßß   @author       Renato Silva                                                     ßß
ßß   @since        19/03/2024                                                       ßß
ßß   @obs          Atualizacoes > Model-View-Control > Mod 1 c/ Abas - Artistas     ßß
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function zMVC09()

	Local aArea     := FWGetArea()
	Local oBrowse   as OBJECT

	//Instanciando o browse
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias(cAliasMVC)
	oBrowse:SetDescription(cTitulo)
	oBrowse:DisableDetails()

	//Ativa a Browse
	oBrowse:Activate()

	FWRestArea(aArea)

Return Nil


Static Function MenuDef()
	Local aRotina := {}
	//Adicionando opcoes do menu
	ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.zMVC09" OPERATION 1 ACCESS 0
	ADD OPTION aRotina TITLE "Incluir"    ACTION "VIEWDEF.zMVC09" OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.zMVC09" OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE "Excluir"    ACTION "VIEWDEF.zMVC09" OPERATION 5 ACCESS 0
Return aRotina


Static Function ModelDef()

	Local oStruct := FWFormStruct(1, cAliasMVC)
	Local oModel  as OBJECT
	Local bPre    := Nil
	Local bPos    := Nil
	Local bCommit := Nil
	Local bCancel := Nil

	//Cria o modelo de dados para cadastro
	oModel := MPFormModel():New("zMVC09M", bPre, bPos, bCommit, bCancel)
	oModel:AddFields("ZD1MASTER", /*cOwner*/, oStruct)
	oModel:SetDescription("Modelo de dados - " + cTitulo)
	oModel:GetModel("ZD1MASTER"):SetDescription( "Dados de - " + cTitulo)
	oModel:SetPrimaryKey({})

Return oModel


Static Function ViewDef()

    Local cCamposPrin := "ZD1_CODIGO|ZD1_NOME"
    Local cCamposObse := "ZD1_DTFORM|ZD1_OBSERV"
	Local oModel      := FWLoadModel("zMVC09")
	Local oStructPrin := FWFormStruct(2, cAliasMVC, {|cCampo| AllTrim(cCampo) $ cCamposPrin})
    Local oStructObse := FWFormStruct(2, cAliasMVC, {|cCampo| AllTrim(cCampo) $ cCamposObse})
	Local oView       := FWFormView():New()

    //Retira as abas padrões
    oStructPrin:SetNoFolder()
    oStructObse:SetNoFolder()

	//Cria a visualizacao do cadastro
	oView:SetModel(oModel)
    oView:AddField("VIEW_PRIN", oStructPrin, "ZD1MASTER")
    oView:AddField("VIEW_OBSE", oStructObse, "ZD1MASTER")
	
    //Cria o controle de Abas
    oView:CreateFolder('ABAS')
    oView:AddSheet('ABAS', 'ABA_PRIN', 'Aba principal do Cadastro')
    oView:AddSheet('ABAS', 'ABA_OBSE', 'Aba com campos de Observações')
 
    //Cria os Box que serão vinculados as abas
    oView:CreateHorizontalBox( 'BOX_PRIN' ,100, /*owner*/, /*lUsePixel*/, 'ABAS', 'ABA_PRIN')
    oView:CreateHorizontalBox( 'BOX_OBSE' ,100, /*owner*/, /*lUsePixel*/, 'ABAS', 'ABA_OBSE')
 
    //Amarra as Abas aos Views de Struct criados
    oView:SetOwnerView('VIEW_PRIN','BOX_PRIN')
    oView:SetOwnerView('VIEW_OBSE','BOX_OBSE')

Return oView


