//Bibliotecas
#INCLUDE "totvs.ch"
#INCLUDE "fwmvcdef.ch"

//Variaveis Estaticas
STATIC cTitulo   := "Cadastro de CDs"
STATIC cTabPai   := "ZD2"
STATIC cTabFilho := "ZD3"

/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßß {Protheus.doc} ZMVC03 ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
ßß   @description Cadastro de CDs (Modelo 03)                                        ßß
ßß   @author Renato Silva                                                            ßß
ßß   @since 10/03/2024                                                               ßß
ßß   @obs Atualizacoes > Model-View-Control > Mod 3 - Cad CDs                        ßß
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function zMVC03()

	Local aArea     := FWGetArea()
	Local oBrowse   := GetValType('O')
	Private aRotina := {}

	//Instancia a classe do browse
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias(cTabPai)
	oBrowse:SetDescription(cTitulo)
	oBrowse:DisableDetails()

	//Ativa a Browse
	oBrowse:Activate()

	FWRestArea(aArea)

Return NIL


/*
-------------------------- MENUDEF --------------------------------------------------
    Função que cria todas as rotinas de menu, retornando assim as opções da rotina.
-------------------------------------------------------------------------------------
*/
STATIC Function MenuDef()
	Local aRotina := {}

	//Adicionando opcoes do menu
	ADD OPTION aRotina TITLE "Visualizar" ACTION 'VIEWDEF.zMVC03' OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE "Incluir"    ACTION 'VIEWDEF.zMVC03' OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"    ACTION 'VIEWDEF.zMVC03' OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE "Excluir"    ACTION 'VIEWDEF.zMVC03' OPERATION 5 ACCESS 0
	ADD OPTION aRotina TITLE 'Imprimir'   ACTION 'VIEWDEF.zMVC03' OPERATION 8 ACCESS 0
	ADD OPTION aRotina TITLE 'Copiar'     ACTION 'VIEWDEF.zMVC03' OPERATION 9 ACCESS 0

Return aRotina


/*
--------------------------- MODELDEF ---------------------------------------------------
    A função ModelDef deve sempre retornar o objeto do Model.
    O model é o responsável pela regra de negócio.
----------------------------------------------------------------------------------------
*/
Static Function ModelDef()

	Local oStruPai   := GetValType('O')
	Local oStruFilho := GetValType('O')
	Local oModel     := GetValType('O')
	Local aRelation  := {}
	Local bPre       := Nil
	Local bPos       := Nil
	Local bCommit    := Nil
	Local bCancel    := Nil

    // Cria a estrutura a ser usada no Modelo de Dados
	oStruPai   := FWFormStruct(1, cTabPai)
	oStruFilho := FWFormStruct(1, cTabFilho)

	//Cria o modelo de dados para cadastro
	oModel := MPFormModel():New("zMVC03M", bPre, bPos, bCommit, bCancel)
	oModel:AddFields("ZD2MASTER", /*cOwner*/, oStruPai)
	oModel:AddGrid("ZD3DETAIL","ZD2MASTER",oStruFilho,/*bLinePre*/, /*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)
	oModel:SetDescription("Modelo de dados - " + cTitulo)
	oModel:GetModel("ZD2MASTER"):SetDescription( "Dados de - " + cTitulo)
	oModel:GetModel("ZD3DETAIL"):SetDescription( "Grid de - " + cTitulo)
	oModel:SetPrimaryKey({})

	//Fazendo o relacionamento
	aAdd(aRelation, {"ZD3_FILIAL", "FWxFilial('ZD3')"} )
	aAdd(aRelation, {"ZD3_CD", "ZD2_CD"})
	oModel:SetRelation("ZD3DETAIL", aRelation, ZD3->( IndexKey(1) ))
	
	//Definindo campos unicos da linha
	oModel:GetModel("ZD3DETAIL"):SetUniqueLine({'ZD3_MUSICA'})

	//Definindo o número máximo de linhas
    oModel:GetModel("ZD3DETAIL"):SetMaxLine(3)

Return oModel


/*
----------------------- VIEWDEF --------------------------------------------------------
    A View é a camada responsável pela interface gráfica e interação com o seu usuário.
    Também é um objeto, que deve ser definido dentro da função ViewDef e por sua vez
    a função deve retornar o objeto de View.
----------------------------------------------------------------------------------------
*/
STATIC Function ViewDef()

	Local oModel     := FWLoadModel("zMVC03")
	Local oStruPai   := FWFormStruct(2, cTabPai)
	Local oStruFilho := FWFormStruct(2, cTabFilho)
	Local oView

	//Cria a visualizacao do cadastro
	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField("VIEW_ZD2", oStruPai  , "ZD2MASTER")
	oView:AddGrid("VIEW_ZD3" , oStruFilho, "ZD3DETAIL")

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
