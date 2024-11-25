//Bibliotecas
#INCLUDE "totvs.ch"
#INCLUDE "fwmvcdef.ch"

//Variaveis Estaticas
STATIC cTitulo   := "Cadastro de CDs"
STATIC cTabPai   := "ZD2"
STATIC cTabFilho := "ZD3"

/*
��������������������������� {Protheus.doc} ZMVC03A ������������������������������������
��   @description Cadastro de CDs (Modelo 03)                                        ��
��   @author Renato Silva                                                            ��
��   @since 10/03/2024                                                               ��
��   @obs Atualizacoes > Model-View-Control > Mod 3 - Cad CDs                        ��
���������������������������������������������������������������������������������������
*/

User Function zMVC03A()

	Local aArea     := FWGetArea()
	Local oBrowse   := GetValType('O')
	Private aRotina := MenuDef()

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
    Fun��o que cria todas as rotinas de menu, retornando assim as op��es da rotina.
-------------------------------------------------------------------------------------
*/
STATIC Function MenuDef()
	Local aRotina := {}

	//Adicionando opcoes do menu
	ADD OPTION aRotina TITLE "Visualizar" ACTION 'VIEWDEF.zMVC03A' OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE "Incluir"    ACTION 'VIEWDEF.zMVC03A' OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"    ACTION 'VIEWDEF.zMVC03A' OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE "Excluir"    ACTION 'VIEWDEF.zMVC03A' OPERATION 5 ACCESS 0
	ADD OPTION aRotina TITLE 'Imprimir'   ACTION 'VIEWDEF.zMVC03A' OPERATION 8 ACCESS 0
	ADD OPTION aRotina TITLE 'Copiar'     ACTION 'VIEWDEF.zMVC03A' OPERATION 9 ACCESS 0

Return aRotina


/*
--------------------------- MODELDEF ---------------------------------------------------
    A fun��o ModelDef deve sempre retornar o objeto do Model.
    O model � o respons�vel pela regra de neg�cio.
----------------------------------------------------------------------------------------
*/
Static Function ModelDef()

	Local oStruPai   := GetValType('O')
	Local oStruFilho := GetValType('O')
	Local oModel     := GetValType('O')
	Local aRelation  := {}


    // Cria a estrutura a ser usada no Modelo de Dados
	oStruPai   := FWFormStruct(1, cTabPai)
	oStruFilho := FWFormStruct(1, cTabFilho)

	//Cria o modelo de dados para cadastro
	oModel := MPFormModel():New("zMVC03AM", , { | oMdl | COMP021POS( oMdl ) } , , )
	oModel:AddFields("ZD2MASTER", /*cOwner*/, oStruPai)
	oModel:AddGrid("ZD3DETAIL","ZD2MASTER",oStruFilho,/*bLinePre*/,  { | oMdlG | COMP021LPOS( oMdlG ) } , /*bPreVal*/, /*bPosVal*/)
	oModel:SetDescription("Modelo de dados - " + cTitulo)
	oModel:GetModel("ZD2MASTER"):SetDescription( "Dados de - " + cTitulo)
	oModel:GetModel("ZD3DETAIL"):SetDescription( "Grid de - " + cTitulo)
	oModel:SetPrimaryKey({})

	//Fazendo o relacionamento
	aAdd(aRelation, {"ZD3_FILIAL", "FWxFilial('ZD3')"} )
	aAdd(aRelation, {"ZD3_CD", "ZD2_CD"})
	oModel:SetRelation("ZD3DETAIL", aRelation, ZD3->( IndexKey(1) ))

	// Indica que � opcional ter dados informados na Grid
	//oModel:GetModel( 'ZD3DETAIL' ):SetOptional(.T.)
	//oModel:GetModel( 'ZD3DETAIL' ):SetOnlyView(.T.)
	
	// Liga o controle de nao-repeticao de linha
	oModel:GetModel("ZD3DETAIL"):SetUniqueLine({'ZD3_MUSICA'})

Return oModel


/*
----------------------- VIEWDEF --------------------------------------------------------
    A View � a camada respons�vel pela interface gr�fica e intera��o com o seu usu�rio.
    Tamb�m � um objeto, que deve ser definido dentro da fun��o ViewDef e por sua vez
    a fun��o deve retornar o objeto de View.
----------------------------------------------------------------------------------------
*/
STATIC Function ViewDef()

	Local oModel     := FWLoadModel("zMVC03A")
	// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
	Local oStruPai   := FWFormStruct(2, cTabPai)
	Local oStruFilho := FWFormStruct(2, cTabFilho)
	Local oView

	//Cria a visualizacao do cadastro
	oView := FWFormView():New()
	// Define qual o Modelo de dados ser� utilizado
	oView:SetModel(oModel)
    //Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
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
	oStruFilho:RemoveField( "ZD3_CD" )

	//Adicionando campo incremental na grid
	oView:AddIncrementField( "VIEW_ZD3", "ZD3_ITEM" )

	// Criar novo botao na barra de botoes
	oView:AddUserButton( 'Inclui Artista', 'CLIPS', { |oView| COMP021BUT() } )

	// Liga a Edi��o de Campos na FormGrid
	oView:SetViewProperty( 'VIEW_ZD3', "ENABLEDGRIDDETAIL", { 50 } )

	// Habilita a pesquisa
	oView:SetViewProperty( 'VIEW_ZD3', "GRIDSEEK" )

Return oView


Static Function COMP021LPOS( oModelGrid )

	Local lRet       := .T.
	Local oModel     := oModelGrid:GetModel()
	Local nOperation := oModel:GetOperation()

	If nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE
		
		If Mod( Val( FwFldGet( 'ZD3_MUSICA' )  ) , 2 )  <> 0
			Help( ,, 'Help',, 'S� s�o permitidos c�digos pares de m�sica', 1, 0 )
			lRet := .F.
		EndIf
		
	EndIf

Return lRet


//-----------------------------------------------------------------------------------------------------------


Static Function COMP021POS( oModel )

	Local lRet       := .T.
	Local aArea      := FWGetArea()
	Local aAreaZD1   := ZD1->( FWGetArea() )
	Local nOperation := oModel:GetOperation()
	Local oModelZD3  := oModel:GetModel( 'ZD3DETAIL' )
	Local nI         := 0
	Local nCt        := 0
	Local lAchou     := .F.
	Local aSaveLines := FWSaveRows()

	ZD1->( dbSetOrder( 1 ) )

	If nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE
		
		For nI := 1 To  oModelZD3:Length()
			
			oModelZD3:GoLine( nI )
			
			If !oModelZD3:IsDeleted()
				If ZD1->( dbSeek( FWxFilial( 'ZD1' ) + oModelZD3:GetValue( 'ZD3_MUSICA' ) ) )
					lAchou := .T.
					Exit
				EndIf
			EndIf
			
		Next nI
		
		If !lAchou
			Help( ,, 'Help',, 'Deve haver pelo menos um artista', 1, 0 )
			lRet := .F.
		EndIf
		
		If lRet
			
			For nI := 1 To oModelZD3:Length()
				
				oModelZD3:GoLine( nI )
				
				If oModelZD3:IsInserted() .AND. !oModelZD3:IsDeleted() // Verifica se � uma linha nova
					nCt++
				EndIf
				
			Next nI
			
			If nCt > 2
				Help( ,, 'Help',, '� permitida a inclus�o de apenas duas novas m�sicas de cada vez', 1, 0 )
				lRet := .F.
			EndIf
			
		EndIf
		
	EndIf

	FWRestRows( aSaveLines )

	FWRestArea( aAreaZD1 )
	FWRestArea( aArea )

Return lRet

//-----------------------------------------------------------------------------------------------------------

Static Function COMP021BUT()

	Local oModel     := FWModelActive()
	Local nOperation := oModel:GetOperation()
	Local aArea      := FWGetArea()
	Local aAreaZD1   := ZD1->( FWGetArea() )
	Local lOk        := .F.

	//FWExecView( /*cTitulo*/, /*cFonteModel*/, /*nAcao*/, /*bOk*/ )

	If nOperation == MODEL_OPERATION_INSERT // Inclusao
		lOk := ( FWExecView('Inclus�o por FWExecView','ZMVC01', nOperation, , { || .T. } ) == 0 )
		
	ElseIf nOperation == MODEL_OPERATION_UPDATE
		
		ZD1->( dbSetOrder( 1 ) )
		If ZD1->( dbSeek( FWxFilial( 'ZD1' ) + FwFldGet( 'ZD3_MUSICA' ) ) )
			lOk := ( FWExecView('Altera��o por FWExecView','ZMVC01', nOperation, , { || .T. } ) == 0 )
		EndIf
		
	EndIf

	If lOk
		Help( ,, 'Help',, 'Foi confirmada a manuten��o do(a) artista', 1, 0 )
	Else
		Help( ,, 'Help',, 'Foi cancelada a manuten��o do(a) artista', 1, 0 )
	EndIf

	FWRestArea( aAreaZD1 )
	FWRestArea( aArea )

Return lOk
