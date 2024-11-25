//Bibliotecas
#INCLUDE "totvs.ch"
#INCLUDE "fwmvcdef.ch"

//Variaveis Estaticas
STATIC cTitulo   := "Cadastro de CDs"
STATIC cTabPai   := "ZD2"
STATIC cTabFilho := "ZD3"

/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßß {Protheus.doc} ZMVC03A ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
ßß   @description Cadastro de CDs (Modelo 03)                                        ßß
ßß   @author Renato Silva                                                            ßß
ßß   @since 10/03/2024                                                               ßß
ßß   @obs Atualizacoes > Model-View-Control > Mod 3 - Cad CDs                        ßß
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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
    Função que cria todas as rotinas de menu, retornando assim as opções da rotina.
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
    A função ModelDef deve sempre retornar o objeto do Model.
    O model é o responsável pela regra de negócio.
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

	// Indica que é opcional ter dados informados na Grid
	//oModel:GetModel( 'ZD3DETAIL' ):SetOptional(.T.)
	//oModel:GetModel( 'ZD3DETAIL' ):SetOnlyView(.T.)
	
	// Liga o controle de nao-repeticao de linha
	oModel:GetModel("ZD3DETAIL"):SetUniqueLine({'ZD3_MUSICA'})

Return oModel


/*
----------------------- VIEWDEF --------------------------------------------------------
    A View é a camada responsável pela interface gráfica e interação com o seu usuário.
    Também é um objeto, que deve ser definido dentro da função ViewDef e por sua vez
    a função deve retornar o objeto de View.
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
	// Define qual o Modelo de dados será utilizado
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

	// Liga a Edição de Campos na FormGrid
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
			Help( ,, 'Help',, 'Só são permitidos códigos pares de música', 1, 0 )
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
				
				If oModelZD3:IsInserted() .AND. !oModelZD3:IsDeleted() // Verifica se é uma linha nova
					nCt++
				EndIf
				
			Next nI
			
			If nCt > 2
				Help( ,, 'Help',, 'É permitida a inclusão de apenas duas novas músicas de cada vez', 1, 0 )
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
		lOk := ( FWExecView('Inclusão por FWExecView','ZMVC01', nOperation, , { || .T. } ) == 0 )
		
	ElseIf nOperation == MODEL_OPERATION_UPDATE
		
		ZD1->( dbSetOrder( 1 ) )
		If ZD1->( dbSeek( FWxFilial( 'ZD1' ) + FwFldGet( 'ZD3_MUSICA' ) ) )
			lOk := ( FWExecView('Alteração por FWExecView','ZMVC01', nOperation, , { || .T. } ) == 0 )
		EndIf
		
	EndIf

	If lOk
		Help( ,, 'Help',, 'Foi confirmada a manutenção do(a) artista', 1, 0 )
	Else
		Help( ,, 'Help',, 'Foi cancelada a manutenção do(a) artista', 1, 0 )
	EndIf

	FWRestArea( aAreaZD1 )
	FWRestArea( aArea )

Return lOk
