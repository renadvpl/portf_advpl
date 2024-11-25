//Bibliotecas
#Include "Totvs.ch"
#Include "FWMVCDef.ch"

/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßß {Protheus.doc} ZMVC03T ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
ßß   @description Cadastro de Artistas x CDs x Músicas (Modelo X)                   ßß
ßß   @author Renato Silva                                                           ßß
ßß   @since 19/03/2024                                                              ßß
ßß   @obs Atualizacoes > Model-View-Control > Mod X > Em Árvore                     ßß
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function zMVC03T()

	Local aArea     := FWGetArea()
	Local oBrowse   := GetValType('O')
	Private aRotina := {}

	aRotina := MenuDef()

	// Instanciando o browse
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('ZD1')
	oBrowse:SetDescription("Art x CDs x Mús (Em Árvore)")
	oBrowse:DisableDetails()

	// Ação de alteração com duplo-clique
    oBrowse:SetExecuteDef(3)

	// Ativa a Browse
	oBrowse:Activate()

	FWRestArea(aArea)

Return NIL


Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.zMVC03T" OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE "Inserir"    ACTION "VIEWDEF.zMVC03T" OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Modificar"  ACTION "VIEWDEF.zMVC03T" OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE "Apagar"     ACTION "VIEWDEF.zMVC03T" OPERATION 5 ACCESS 0

Return aRotina



Static Function ViewDef()

	Local oModel     := FWLoadModel("ZMVC03X") // Model já existente
	Local oStruPai   := FWFormStruct(2, 'ZD1')
	Local oStruFilho := FWFormStruct(2, 'ZD2', { |x| ! Alltrim(x) $ 'ZD2_NOME' })
    Local oStruNeto  := FWFormStruct(2, 'ZD3')
	Local oView      := GetValType('O')
	Local aTreeInfo  := {}

	//Cria a visualizacao do cadastro
	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField("VIEW_ZD1", oStruPai  , "ZD1MASTER")
	// Cria a estrutura das grids em formato de árvore
	//    [1] ID do Model
	//    [2] Array de 1 dimensão com os IDs dos campos que iram aparecer no tree.
	//    [3] Objeto do tipo FWViewStruct com a Estruturas dos campos
	aAdd( aTreeInfo, { "ZD2DETAIL", { "ZD2_CD"  , "ZD2_NOMECD" } , oStruFilho } )
	aAdd( aTreeInfo, { "ZD3DETAIL", { "ZD3_ITEM", "ZD3_MUSICA" } , oStruNeto } )

	// oView:AddTreeGrid( IDTree, Grids em Tree, IDDetail )
    oView:AddTreeGrid( "TREE", aTreeInfo, "DETAIL_TREE" )

    oView:CreateHorizontalBox( 'EMCIMA' , 35 )
    oView:CreateHorizontalBox( 'EMBAIXO', 65 )
		oView:CreateVerticalBox( 'EMBAIXOESQ', 30, 'EMBAIXO' )
		oView:CreateVerticalBox( 'EMBAIXODIR', 70, 'EMBAIXO' )

	// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView( 'VIEW_ZD1'   , 'EMCIMA'     )
	oView:SetOwnerView( 'TREE'       , 'EMBAIXOESQ' )
	oView:SetOwnerView( 'DETAIL_TREE', 'EMBAIXODIR' )

	//Removendo campos
    oStruFilho:RemoveField("ZD2_ARTIST")
    oStruFilho:RemoveField("ZD2_NOME")
	oStruNeto:RemoveField("ZD3_CD")

	//Adicionando campo incremental na grid
	oView:AddIncrementField("VIEW_ZD3", "ZD3_ITEM")

Return oView
