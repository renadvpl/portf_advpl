//Bibliotecas
#INCLUDE "totvs.ch"
#INCLUDE "fwmvcdef.ch"

/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßß {Protheus.doc} ZMVC08 ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
ßß   @description Exemplo de montagem da modelo e interface para uma multiplas      ßß
ßß                browses em MVC                                                    ßß
ßß   @author      Renato Silva                                                      ßß
ßß   @since       03/04/2024                                                        ßß
ßß   @obs         Atualizacoes > Model-View-Control > Multiplos Browsers            ßß
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function zMVC27()

	Local aCoors  := FWGetDialogSize( oMainWnd )
	Local oPanelUp, oFWLayer, oPanelLeft, oPanelRight
	Local oBrowseUp, oBrowseLeft, oBrowseRight, oRelacZD2, oRelacZD3

	Private oDlgPrinc as OBJECT

	Define MsDialog oDlgPrinc Title 'Múltiplos Browses' From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel

	// Cria o conteiner onde serão colocados os browses
	oFWLayer := FWLayer():New()
	oFWLayer:Init( oDlgPrinc, .F., .T. )

	// PAINEL SUPERIOR
	oFWLayer:AddLine( 'UP', 50, .F. )                  // Cria uma "linha" com 50% da tela
	oFWLayer:AddCollumn( 'ALL', 100, .T., 'UP' )       // Na "linha" criada eu crio uma coluna com 100% da tamanho dela
	oPanelUp := oFWLayer:GetColPanel( 'ALL', 'UP' )    // Pego o objeto desse pedaço do container

	// PAINEL INFERIOR
	oFWLayer:AddLine( 'DOWN', 50, .F. )                     // Cria uma "linha" com 50% da tela
	oFWLayer:AddCollumn( 'LEFT' ,  50, .T., 'DOWN' )        // Na "linha" criada eu crio uma coluna com 50% da tamanho dela
	oFWLayer:AddCollumn( 'RIGHT',  50, .T., 'DOWN' )        // Na "linha" criada eu crio uma coluna com 50% da tamanho dela
	oPanelLeft  := oFWLayer:GetColPanel( 'LEFT' , 'DOWN' )  // Pego o objeto do pedaço esquerdo
	oPanelRight := oFWLayer:GetColPanel( 'RIGHT', 'DOWN' )  // Pego o objeto do pedaço direito

	// BROWSE SUPERIOR - ARTISTAS
	oBrowseUp:= FWmBrowse():New()
	oBrowseUp:SetOwner( oPanelUp )          // Aqui se associa o browse ao componente de tela
	oBrowseUp:SetDescription( "Artistas" )
	oBrowseUp:SetAlias( 'ZD1' )
	oBrowseUp:SetMenuDef( 'zMVC27' )        // Define de onde virao os botoes deste browse
	oBrowseUp:SetProfileID( '1' )
	oBrowseUp:ForceQuitButton()
	oBrowseUp:Activate()

	// Lado Esquerdo CDs
	oBrowseLeft:= FWMBrowse():New()
	oBrowseLeft:SetOwner( oPanelLeft )
	oBrowseLeft:SetDescription( 'CDs' )
	// Referencia uma funcao que nao tem menu para que nao exiba nenhum botao
	oBrowseLeft:SetMenuDef( '' )
	oBrowseLeft:DisableDetails()
	oBrowseLeft:SetAlias( 'ZD2' )
	oBrowseLeft:SetProfileID( '2' )

	// Relacionamento entre os Browses
	oRelacZD2:= FWBrwRelation():New()
	oRelacZD2:AddRelation( oBrowseUp  , oBrowseLeft ,{;
	    { 'ZD2_FILIAL', 'FWxFilial( "ZD2" )' },;
		{ 'ZD2_ARTIST', 'ZD1_CODIGO'} } )
	oRelacZD2:Activate()

	// Ativa o Browse Filho
	oBrowseLeft:Activate()

	// Lado Direito - Músicas
	oBrowseRight:= FWMBrowse():New()
	oBrowseRight:SetOwner( oPanelRight )
	oBrowseRight:SetDescription( 'Músicas' )
	oBrowseRight:SetMenuDef( '' )  // Referencia uma funcao que nao tem menu para que nao exiba nenhum botao
	oBrowseRight:DisableDetails()
	oBrowseRight:SetAlias( 'ZD3' )
	oBrowseRight:SetProfileID( '3' )

	// Relacionamento entre os Browses
	oRelacZD3:= FWBrwRelation():New()
	oRelacZD3:AddRelation( oBrowseLeft, oBrowseRight,;
	    { { 'ZD3_FILIAL', 'FWxFilial( "ZD3" )' },;
		  { 'ZD3_CD'    , 'ZD2_CD'} } )
	oRelacZD3:Activate()


	// Ativa o Browse Filho
	oBrowseRight:Activate()

	Activate MsDialog oDlgPrinc Center

Return NIL

//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}
    // Forma nao recomendada
	aAdd( aRotina, { 'Visualizar', 'VIEWDEF.zMVC27', 0, 2, 0, NIL } )
	aAdd( aRotina, { 'Incluir'   , 'VIEWDEF.zMVC27', 0, 3, 0, NIL } )
	aAdd( aRotina, { 'Alterar'   , 'VIEWDEF.zMVC27', 0, 4, 0, NIL } )
	aAdd( aRotina, { 'Excluir'   , 'VIEWDEF.zMVC27', 0, 5, 0, NIL } )
	aAdd( aRotina, { 'Imprimir'  , 'VIEWDEF.zMVC27', 0, 8, 0, NIL } )

Return aRotina


//-------------------------------------------------------------------
Static Function ModelDef()
    // Utilizo um model que ja existe
Return FWLoadModel( 'ZMVC08' )


//-------------------------------------------------------------------
Static Function ViewDef()
    // Utilizo uma View que ja existe
Return FWLoadView( 'ZMVC08' )
