#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "MSGRAPHI.CH"

/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßß {Protheus.doc} ZMVC03B ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
ßß   @description Exemplo de montagem da modelo e interface para uma estrutura       ßß
ßß                pai/filho em MVC e com gráficos de pizza e de barras.              ßß
ßß   @author      Renato Silva                                                       ßß
ßß   @since       26/03/2024                                                         ßß
ßß   @obs         Atualizacoes > Model-View-Control > Mod 3 - Cad CDs                ßß
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function ZMVC03B()

	Local oBrowse as OBJECT

	Static oGrafPizza as OBJECT
	Static oGrafBar as OBJECT

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias( 'ZD2' )
	oBrowse:SetDescription( 'Cadastro de CDs' )
	oBrowse:SetMenuDef( 'ZMVC03B' )
	oBrowse:Activate()

Return NIL


//-------------------------------------------------------------------

Static Function MenuDef()

	Local aRotina := {}
	aRotina := FWMVCMenu( 'ZMVC03B' )

Return aRotina

//-------------------------------------------------------------------

Static Function ModelDef()

	// Cria a estrutura a ser usada no Modelo de Dados
	Local oStruPai   := FWFormStruct( 1, 'ZD2' )
	Local oStruFilho := FWFormStruct( 1, 'ZD3' )
	
	// Cria o objeto do Modelo de Dados
	Local oModel := MPFormModel():New( 'ZMVC03BM' )

	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:AddFields( 'ZD2MASTER',, oStruPai )

	// Adiciona ao modelo uma estrutura de formulário de edição por grid
	oModel:AddGrid( 'ZD3DETAIL', 'ZD2MASTER', oStruFilho )

	// Faz relaciomaneto entre os compomentes do model
	oModel:SetRelation( 'ZD3DETAIL', { ;
	    { 'ZD3_FILIAL', 'FWxFilial( "ZD3" )' }, ;
		{ 'ZD3_CD'    , 'ZD2_CD' } }, ZD3->( IndexKey(1) ) )
	oModel:SetPrimaryKey({})

	// Liga o controle de nao repeticao de linha
	oModel:GetModel( 'ZD3DETAIL' ):SetUniqueLine( { 'ZD3_MUSICA' } )

	// Adiciona a descricao do Modelo de Dados
	oModel:SetDescription( 'Modelo de Dados - CDs' )

	// Adiciona a descricao do Componente do Modelo de Dados
	oModel:GetModel( 'ZD2MASTER' ):SetDescription( 'Dados da CDs' )
	oModel:GetModel( 'ZD3DETAIL' ):SetDescription( 'Grids das Músicas'  )

Return oModel

//-------------------------------------------------------------------

Static Function ViewDef()

	// Cria a estrutura a ser usada na View
	Local oStruPai   := FWFormStruct( 2, 'ZD2' )
	Local oStruFilho := FWFormStruct( 2, 'ZD3' )

	// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
	Local oModel     := FWLoadModel( 'ZMVC03B' )
	Local oView      := GetValType('O')

	// Cria o objeto de View
	oView := FWFormView():New()

	// Define qual o Modelo de dados será utilizado
	oView:SetModel( oModel )

	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField( 'VIEW_ZD2', oStruPai, 'ZD2MASTER' )

	//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
	oView:AddGrid(  'VIEW_ZD3', oStruFilho, 'ZD3DETAIL' )

	// Criar um box horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'SUPERIOR', 25 )
	oView:CreateHorizontalBox( 'INFERIOR', 75 )

	// Dividir o box inferior em outros 2
	oView:CreateVerticalBox( 'INFERIORE', 70, 'INFERIOR' )
	oView:CreateVerticalBox( 'INFERIORD', 30, 'INFERIOR' )

	// Dividir o box da esquerda em outros 2
	oView:CreateHorizontalBox( 'GRAFPIZZA', 40, 'INFERIORD' )
	oView:CreateHorizontalBox( 'GRAFBARRA', 60, 'INFERIORD' )

	// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView( 'VIEW_ZD2', 'SUPERIOR'  )
	oView:SetOwnerView( 'VIEW_ZD3', 'INFERIORE' )

	// Define campos que terao Auto Incremento
	oView:AddIncrementField( 'VIEW_ZD3', 'ZD3_ITEM' )

	// Liga a identificacao do componente
	oView:EnableTitleView( "VIEW_ZD2", "Cabecalho - ZD2 (CDs)"        )
	oView:EnableTitleView( "VIEW_ZD3", "Grid - ZD3 (Musicas dos CDs)" )

	// Cria componentes nao MVC
	oView:AddOtherObject("OTHER_PIZZA", {|oPanel,oView| GrafPizza(.F.,oPanel/*,oView:GetModel()*/)})
	oView:SetOwnerView("OTHER_PIZZA",'GRAFPIZZA')

	oView:AddOtherObject("OTHER_BARRA", {|oPanel,oView| GrafBarra(.F.,oPanel/*,oView:GetModel()*/)})
	oView:SetOwnerView("OTHER_BARRA",'GRAFBARRA')

	oView:SetFieldAction( 'ZD3_MUSICA', { |oView, cIDView, cField, xValue| GraRefresh() } )
	oView:SetViewAction( 'DELETELINE'  , { |oView| GraRefresh() } )
	oView:SetViewAction( 'UNDELETELINE', { |oView| GraRefresh() } )

Return oView



//-------------------------------------------------------------------
Static Function GrafPizza( lReDraw, oPanel )

	Local aArea      := FWGetArea()
	Local aAreaZD1   := ZD1->( FWGetArea() )
	Local nQtd       := 0
	Local nQtdInt    := 0
	Local nQtdAut    := 0
	Local oModel     := FwModelActive()
	Local oModelZD2  := oModel:GetModel('ZD2MASTER')
	Local oModelZD3  := oModel:GetModel('ZD3DETAIL')
	Local nI         := GetValType('N')

	For nI := 1 To oModelZD3:Length()
		If !oModelZD3:IsDeleted( nI )
			nQtd++
			If ZD1->( dbSeek( FWxFilial( 'ZD1' ) + oModelZD2:GetValue( 'ZD2_ARTIST' ) ) )
				If ZD1->ZD1_TIPO == "C"
					nQtdAut++
				Else
					nQtdInt++
				EndIf
			EndIf
		EndIf
	Next

	If !lReDraw
		oGrafPizza := FWChartFactory():New()
		oGrafPizza := oGrafPizza:GetInstance( PIECHART )
		oGrafPizza:Init( oPanel, .F. )
		oGrafPizza:SetTitle( "Participação", CONTROL_ALIGN_CENTER )
		oGrafPizza:SetLegend( CONTROL_ALIGN_BOTTOM )
	Else
		oGrafPizza:Reset()
	EndIf

	oGrafPizza:addSerie( "Compositores" , nQtdAut/nQtd * 100 )
	oGrafPizza:addSerie( "Interpretes"  , nQtdInt/nQtd * 100 )

	oGrafPizza:build()

	FWRestArea( aAreaZD1 )
	FWRestArea( aArea )

Return NIL


//-------------------------------------------------------------------

Static Function GrafBarra( lReDraw, oPanel )

	Local aArea      := FWGetArea()
	Local aAreaZD1   := ZD1->( FWGetArea() )
	Local nQtd       := 0
	Local nQtdInt    := 0
	Local nQtdAut    := 0
	Local oModel     := FWModelActive()
	Local oModelZD2  := oModel:GetModel('ZD2MASTER')
	Local oModelZD3  := oModel:GetModel('ZD3DETAIL')
	Local nI         := GetValType('N')

	For nI := 1 To oModelZD3:Length()
		If !oModelZD3:IsDeleted( nI )
			nQtd ++
			If ZD1->( dbSeek( FWxFilial( 'ZD1' ) + oModelZD2:GetValue( 'ZD2_ARTIST' ) ) )
				If ZD1->ZD1_TIPO == "C"
					nQtdAut++
				Else
					nQtdInt++
				EndIf
			EndIf
		EndIf
	Next

	If !lReDraw
		oGrafBar := FWChartFactory():New()
		oGrafBar := oGrafBar:GetInstance( BARCHART )
		oGrafBar:Init( oPanel, .F., .F. )
		oGrafBar:SetMaxY( 15 )
		oGrafBar:SetTitle( "Quantidade", CONTROL_ALIGN_CENTER )
		oGrafBar:SetLegend( CONTROL_ALIGN_RIGHT )
	Else
		oGrafBar:Reset()
	EndIf

	oGrafBar:addSerie( "Total de Musicas" , nQtd    )
	oGrafBar:addSerie( "Compositores" ,   nQtdAut )
	oGrafBar:addSerie( "Interpretes"  ,   nQtdInt )

	oGrafBar:build()

	FWRestArea( aAreaZD1 )
	FWRestArea( aArea )

Return .T.


//-------------------------------------------------------------------
Static Function GraRefresh()

	GrafPizza( .T., oGrafPizza:oOwner )
	GrafBarra( .T., oGrafBar:oOwner   )

Return NIL
