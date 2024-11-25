//Bibliotecas de Funcoes
#INCLUDE "totvs.ch"
#INCLUDE "fwmvcdef.ch"

//Variaveis Estaticas
STATIC cTitulo   := "Cadastro de CDs"
STATIC cTabPai   := "ZD2"
STATIC cTabFilho := "ZD3"

/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßß {Protheus.doc} ZMVC13 ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
ßß   @description CDs x Músicas (Modelo 3 com Validacoes)                           ßß
ßß   @author Renato Silva                                                           ßß
ßß   @since 19/03/2024                                                              ßß
ßß   @obs Atualizacoes > Model-View-Control > Mod 3 c/ Validacoes - CDs/Mus         ßß
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function zMVC13()

	Local aArea     := FWGetArea()
	Local oBrowse   := GetValType('O')

	//Instanciando o browse
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias(cTabPai)
	oBrowse:SetDescription(cTitulo)
	oBrowse:DisableDetails()

	//Ativa a Browse
	oBrowse:Activate()

	FWRestArea(aArea)

Return Nil


Static Function MenuDef()
	Local aRotina := {}
	//Adicionando opcoes do menu
	ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.zMVC13" OPERATION 1 ACCESS 0
	ADD OPTION aRotina TITLE "Incluir"    ACTION "VIEWDEF.zMVC13" OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.zMVC13" OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE "Excluir"    ACTION "VIEWDEF.zMVC13" OPERATION 5 ACCESS 0
Return aRotina


Static Function ModelDef()

	Local oStruPai   := FWFormStruct(1, cTabPai)
	Local oStruFilho := FWFormStruct(1, cTabFilho)
	Local aRelation  := {}
	Local oModel     := GetValType('O')
	Local bPre       := {|| u_z13bPre()}
	Local bPos       := {|| u_z13bPos()}
	Local bCommit    := Nil
	Local bCancel    := Nil
    Local bLinePos   := {|oMdl| u_z13bLinP(oModel)}

	//Cria o modelo de dados para cadastro
	oModel := MPFormModel():New("zMVC13M", bPre, bPos, bCommit, bCancel)
	oModel:AddFields("ZD2MASTER", /*cOwner*/, oStruPai)
	oModel:AddGrid("ZD3DETAIL","ZD2MASTER",oStruFilho,/*bLinePre*/, bLinePos,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)
	oModel:SetDescription("Modelo de dados - " + cTitulo)
	oModel:GetModel("ZD2MASTER"):SetDescription( "Dados de - " + cTitulo)
	oModel:GetModel("ZD3DETAIL"):SetDescription( "Grid de - " + cTitulo)
	oModel:SetPrimaryKey({})

	//Fazendo o relacionamento
	aAdd(aRelation, {"ZD3_FILIAL", "FWxFilial('ZD3')"} )
	aAdd(aRelation, {"ZD3_CD", "ZD2_CD"})
	oModel:SetRelation("ZD3DETAIL", aRelation, ZD3->(IndexKey(1)))
	
	//Definindo campos unicos da linha
	oModel:GetModel("ZD3DETAIL"):SetUniqueLine({'ZD3_MUSICA'})

Return oModel


Static Function ViewDef()

	Local oModel     := FWLoadModel("zMVC13")
	Local oStruPai   := FWFormStruct(2, cTabPai)
	Local oStruFilho := FWFormStruct(2, cTabFilho)
	Local oView

	//Cria a visualizacao do cadastro
	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField("VIEW_ZD2", oStruPai, "ZD2MASTER")
	oView:AddGrid("VIEW_ZD3",  oStruFilho,  "ZD3DETAIL")

	//Partes da tela
	oView:CreateHorizontalBox("CABEC", 30)
	oView:CreateHorizontalBox("GRID", 70)
	oView:SetOwnerView("VIEW_ZD2", "CABEC")
	oView:SetOwnerView("VIEW_ZD3", "GRID")

	//Titulos
	oView:EnableTitleView("VIEW_ZD2", "Cabecalho - ZD2 (CDs)")
	oView:EnableTitleView("VIEW_ZD3", "Grid - ZD3 (Musicas dos CDs)")

	//Removendo campos
	oStruFilho:RemoveField("ZD3_CD")

	//Adicionando campo incremental na grid
	oView:AddIncrementField("VIEW_ZD3", "ZD3_ITEM")

Return oView

 
User Function z13bPre()
  /*-------------------------------------------------------------
  Função chamada na criação do Modelo de Dados (pré-validação)
  -------------------------------------------------------------*/
    Local oModelPad  := FWModelActive()
    Local lRet       := .T.
     
    oModelPad:GetModel('ZD2MASTER'):GetStruct():SetProperty('ZD2_NOMECD', MODEL_FIELD_WHEN, ;
	  FwBuildFeature(STRUCT_FEATURE_WHEN, 'INCLUI'))

Return lRet

 
User Function z13bPos()
  /*-----------------------------------------------------------------------
  Função chamada no clique do botão Ok do Modelo de Dados (pós-validação)
  -----------------------------------------------------------------------*/
    Local oModelPad  := FWModelActive()
    Local cNomeCD    := oModelPad:GetValue('ZD2MASTER', 'ZD2_NOMECD')
    Local lRet       := .T.
     
    //Se o nome do CD estiver vazio
    If Empty(cNomeCD) .Or. Len(Alltrim(cNomeCD)) < 3
        Help(, , "Help", , "Nome do CD inválido!", 1, 0, , , , , , ;
		  {"Insira um nome válido que tenha, no mínimo, 3 caracteres"})
        lRet := .F.
    EndIf
     
Return lRet


User Function z13bLinP(oModel)
  /*-----------------------------------------------------------
  Função chamada ao trocar de linha na grid (bloco bLinePos)
  -----------------------------------------------------------*/
    Local oModelZD3  := oModel:GetModel('ZD3DETAIL')
    Local nOperation := oModel:GetOperation()
    Local lRet       := .T.
    Local cMusica    := oModelZD3:GetValue("ZD3_MUSICA")

    //Se não for exclusão e nem visualização
    If 	nOperation != MODEL_OPERATION_DELETE .And. nOperation != MODEL_OPERATION_VIEW

        //Se a música tiver vazia, ou for menor que 3    
        If Empty(cMusica) .Or. Len(Alltrim(cMusica)) < 3
            Help(, , "Help", , "Nome da Música inválida!", 1, 0, , , , , , ;
			    {"Insira um nome válido que tenha, no mínimo, 3 caracteres"})
            lRet := .F.
        EndIf
    EndIf

Return lRet
