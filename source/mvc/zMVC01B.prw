//Bibliotecas
#INCLUDE "totvs.ch"
#INCLUDE "fwmvcdef.ch"

//Variaveis Estaticas
STATIC cTitulo   := "Cadastro de Artistas"
STATIC cAliasMVC := "ZD1"

/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßß {Protheus.doc} ZMVC01B ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
ßß   @description Cadastro de Artistas (com acréscimo de campos)                      ßß
ßß   @author Renato Silva                                                             ßß
ßß   @since 10/03/2024                                                                ßß
ßß   @obs Atualizacoes > Model-View-Control > Modelo 01 - Cad Artistas                ßß
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function zMVC01B()

	Local aArea     := FWGetArea()
	Local oBrowse   := GetValType('O')
	Private aRotina := {}

	aRotina := MenuDef()

	//Instancia a classe do browse
	oBrowse := FWMBrowse():New()

	//Configura a tabela a ser utilizada
	oBrowse:SetAlias(cAliasMVC)

	//Configura o titulo do browse
	oBrowse:SetDescription(cTitulo)

	//Desativa a exibicao dos detalhes no rodape
	oBrowse:DisableDetails()

	//Ativa a browse
	oBrowse:Activate()

	FWRestArea(aArea)

Return NIL


/*
-------------------------- MENUDEF --------------------------------------------------
    Função que cria todas as rotinas de menu, retornando assim as opções da rotina.
-------------------------------------------------------------------------------------
*/
Static Function MenuDef()

	Local aRotina := {}
	aRotina := FWMVCMenu('ZMVC01B')

Return aRotina


/*
--------------------------- MODELDEF ---------------------------------------------------
    A função ModelDef deve sempre retornar o objeto do Model.
    O model é o responsável pela regra de negócio.
----------------------------------------------------------------------------------------
*/
Static Function ModelDef()

	Local oStruct := GetValType('O')
	Local oModel  := GetValType('O')
	Local bPre    := Nil
	Local bPos    := Nil
	Local bCommit := Nil
	Local bCancel := Nil

    // Cria a estrutura a ser usada no Modelo de Dados
	oStruct := FWFormStruct(1, cAliasMVC)

	oStruct:AddField( ;
		AllTrim( 'Exemplo 1'    )        , ;      // [01]  C   Titulo do campo
		AllTrim( 'Campo Exemplo 1' )     , ;      // [02]  C   ToolTip do campo
		'ZD1_XEXEM1'                     , ;      // [03]  C   Id do Field
		'C'                              , ;      // [04]  C   Tipo do campo
		1                                , ;      // [05]  N   Tamanho do campo
		0                                , ;      // [06]  N   Decimal do campo
		FwBuildFeature( STRUCT_FEATURE_VALID,"Pertence('12')"), ;    // [07]  B   Code-block de validação do campo
		NIL                              , ;      // [08]  B   Code-block de validação When do campo
		{'1=Sim','2=Nao'}                , ;      // [09]  A   Lista de valores permitido do campo
		NIL                              , ;      // [10]  L   Indica se o campo tem preenchimento obrigatório
		FwBuildFeature( STRUCT_FEATURE_INIPAD, "'2'" )       , ;      // [11]  B   Code-block de inicializacao do campo
		NIL                              , ;      // [12]  L   Indica se trata-se de um campo chave
		NIL                              , ;      // [13]  L   Indica se o campo pode receber valor em uma operação de update.
		.T.                              )        // [14]  L   Indica se o campo é virtual

	oStruct:AddField( ;
		AllTrim( 'Exemplo 2'    )        , ;      // [01]  C   Titulo do campo
		AllTrim( 'Campo Exemplo 2' )     , ;      // [02]  C   ToolTip do campo
		'ZD1_XEXEM2'                     , ;      // [03]  C   Id do Field
		'C'                              , ;      // [04]  C   Tipo do campo
		6                                , ;      // [05]  N   Tamanho do campo
		0                                , ;      // [06]  N   Decimal do campo
		FwBuildFeature( STRUCT_FEATURE_VALID,"ExistCpo('SA1', M->ZD1_XEXEM2,1)") , ;      // [07]  B   Code-block de validação do campo
		FwBuildFeature( STRUCT_FEATURE_WHEN,"INCLUI" )                           , ;      // [08]  B   Code-block de validação When do campo
		NIL                              , ;      // [09]  A   Lista de valores permitido do campo
		.F.                              , ;      // [10]  L   Indica se o campo tem preenchimento obrigatório
		NIL                              , ;      // [11]  B   Code-block de inicializacao do campo
		NIL                              , ;      // [12]  L   Indica se trata-se de um campo chave
		NIL                              , ;      // [13]  L   Indica se o campo pode receber valor em uma operação de update.
		.T.                              )        // [14]  L   Indica se o campo é virtual


	oStruct:AddField( ; 
		AllTrim( 'Exemplo 3'    )        , ;      // [01]  C   Titulo do campo
		AllTrim( 'Campo Exemplo 3' )     , ;      // [02]  C   ToolTip do campo
		'ZD1_XEXEM3'                     , ;      // [03]  C   Id do Field
		'L'                              , ;      // [04]  C   Tipo do campo
		1                                , ;      // [05]  N   Tamanho do campo
		0                                , ;      // [06]  N   Decimal do campo
		NIL                              , ;      // [07]  B   Code-block de validação do campo
		NIL                              , ;      // [08]  B   Code-block de validação When do campo
		NIL                              , ;      // [09]  A   Lista de valores permitido do campo
		NIL                              , ;      // [10]  L   Indica se o campo tem preenchimento obrigatório
		FwBuildFeature( STRUCT_FEATURE_INIPAD,'.T.' ), ;   // [11]  B   Code-block de inicializacao do campo
		NIL                              , ;      // [12]  L   Indica se trata-se de um campo chave
		NIL                              , ;      // [13]  L   Indica se o campo pode receber valor em uma operação de update.
		.T.                              )        // [14]  L   Indica se o campo é virtual


	oStruct:AddField( ;  
		"Carregar"                     , ;        // [01]  C   Titulo do campo
		"Carregar"                     , ;        // [02]  C   ToolTip do campo
		'BOTAO'                        , ;        // [03]  C   Id do Field
		'BT'                           , ;        // [04]  C   Tipo do campo
		1                              , ;        // [05]  N   Tamanho do campo
		0                              , ;        // [06]  N   Decimal do campo
		{ |oMdl| Help(,,'HELP',,'Acionou o botão',1,0),.T.} , ; // [07]  B   Code-block de validação do campo que no caso do botao é a ação
		FwBuildFeature( STRUCT_FEATURE_WHEN,"INCLUI" )      )   // [08]  B   Code-block de validação When do campo


	oStruct:AddField( ;  
		"Cores"                        , ;         // [01]  C   Titulo do campo
		"Cores"                        , ;         // [02]  C   ToolTip do campo
		'CORES'                        , ;         // [03]  C   Id do Field
		'BC'                           , ;         // [04]  C   Tipo do campo
		1                              , ;         // [05]  N   Tamanho do campo
		0                              , ;         // [06]  N   Decimal do campo
		{ |oMdl| Help(,,'HELP',,'Acionou o botão',1,0),.T.} )   // [07]  B   Code-block de validação do campo que no caso do botao é a ação


	//Cria o modelo de dados para cadastro
	oModel := MPFormModel():New("ZMVC01BM", bPre, bPos, bCommit, bCancel)

	//Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:AddFields("ZD1MASTER", /*cOwner*/, oStruct, /*bPreVal*/, /*bPosVal*/, /*bCarga*/ )

    // Adiciona um titulo ao Modelo de Dados
	oModel:SetDescription("Modelo de dados - " + cTitulo)

	// Adiciona a descricao do Componente do Modelo de Dados
	oModel:GetModel("ZD1MASTER"):SetDescription( "Dados de - " + cTitulo)

	// Definindo a chave primária da tabela para a aplicação
	oModel:SetPrimaryKey({'ZD1_FILIAL','ZD1_CODIGO'})

Return oModel



/*
----------------------- VIEWDEF --------------------------------------------------------
    A View é a camada responsável pela interface gráfica e interação com o seu usuário.
    Também é um objeto, que deve ser definido dentro da função ViewDef e por sua vez
    a função deve retornar o objeto de View.
----------------------------------------------------------------------------------------
*/
Static Function ViewDef()

    // Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
	Local oModel  := FWLoadModel("zMVC01B")
    Local oView   := GetValType('O')

	// Cria a estrutura a ser usada na View
	Local oStruct := FWFormStruct(2, cAliasMVC, /*lViewUsado*/,/*lVirtual*/,/*lFilOnView*/,/*cProgram*/)

	Local cOrdem    := '00'
	//Pega a ultima ordem de campos
	aEval( oStruct:aFields, { |aX| cOrdem := iif( aX[MVC_VIEW_ORDEM] > cOrdem, aX[MVC_VIEW_ORDEM] , cOrdem )  } )
  	
	cOrder := Soma1( cOrdem )
	oStruct:AddField( ;
		'ZD1_XEXEM1'                       , ;      // [01]  C   Nome do Campo
		cOrder                             , ;      // [02]  C   Ordem
		AllTrim( 'Exemplo 1'    )          , ;      // [03]  C   Titulo do campo
		AllTrim( 'Campo Exemplo 1' )       , ;      // [04]  C   Descricao do campo
		{ 'Exemplo de Campo de Manual 1' } , ;      // [05]  A   Array com Help
		'C'                                , ;      // [06]  C   Tipo do campo
		'@!'                               , ;      // [07]  C   Picture
		NIL                                , ;      // [08]  B   Bloco de Picture Var
		''                                 , ;      // [09]  C   Consulta F3
		.T.                                , ;      // [10]  L   Indica se o campo é alteravel
		NIL                                , ;      // [11]  C   Pasta do campo
		NIL                                , ;      // [12]  C   Agrupamento do campo
		{'1=Sim','2=Nao'}                  , ;      // [13]  A   Lista de valores permitido do campo (Combo)
		NIL                                , ;      // [14]  N   Tamanho maximo da maior opção do combo
		NIL                                , ;      // [15]  C   Inicializador de Browse
		.T.                                , ;      // [16]  L   Indica se o campo é virtual
		NIL                                , ;      // [17]  C   Picture Variavel
		NIL                                )        // [18]  L   Indica pulo de linha após o campo

	cOrder := Soma1( cOrdem )
	oStruct:AddField( ;
		'ZD1_XEXEM2'                       , ;      // [01]  C   Nome do Campo
		cOrder                             , ;      // [02]  C   Ordem
		AllTrim( 'Exemplo 2'    )          , ;      // [03]  C   Titulo do campo
		AllTrim( 'Campo Exemplo 2' )       , ;      // [04]  C   Descricao do campo
		{ 'Exemplo de Campo de Manual 2' } , ;      // [05]  A   Array com Help
		'C'                                , ;      // [06]  C   Tipo do campo
		'@!'                               , ;      // [07]  C   Picture
		NIL                                , ;      // [08]  B   Bloco de Picture Var
		'CLI'                              , ;      // [09]  C   Consulta F3
		.T.                                , ;      // [10]  L   Indica se o campo é alteravel
		NIL                                , ;      // [11]  C   Pasta do campo
		NIL                                , ;      // [12]  C   Agrupamento do campo
		NIL                                , ;      // [13]  A   Lista de valores permitido do campo (Combo)
		NIL                                , ;      // [14]  N   Tamanho maximo da maior opção do combo
		NIL                                , ;      // [15]  C   Inicializador de Browse
		.T.                                , ;      // [16]  L   Indica se o campo é virtual
		NIL                                , ;      // [17]  C   Picture Variavel
		NIL                                )        // [18]  L   Indica pulo de linha após o campo

	cOrder := Soma1( cOrdem )
	oStruct:AddField( ;                        // Ord. Tipo Desc.
		'ZD1_XEXEM3'                       , ;      // [01]  C   Nome do Campo
		cOrder                             , ;      // [02]  C   Ordem
		AllTrim( 'Exemplo 3'    )          , ;      // [03]  C   Titulo do campo
		AllTrim( 'Campo Exemplo 3' )       , ;      // [04]  C   Descricao do campo
		{ 'Exemplo de Campo de Manual 3' } , ;      // [05]  A   Array com Help
		'L'                                , ;      // [06]  C   Tipo do campo
		'@!'                               , ;      // [07]  C   Picture
		NIL                                , ;      // [08]  B   Bloco de Picture Var
		NIL                                , ;      // [09]  C   Consulta F3
		.T.                                , ;      // [10]  L   Indica se o campo é alteravel
		NIL                                , ;      // [11]  C   Pasta do campo
		NIL                                , ;      // [12]  C   Agrupamento do campo
		NIL                                , ;      // [13]  A   Lista de valores permitido do campo (Combo)
		NIL                                , ;      // [14]  N   Tamanho maximo da maior opção do combo
		NIL                                , ;      // [15]  C   Inicializador de Browse
		.T.                                , ;      // [16]  L   Indica se o campo é virtual
		NIL                                , ;      // [17]  C   Picture Variavel
		NIL                                )        // [18]  L   Indica pulo de linha após o campo

	cOrder := Soma1( cOrdem )
	oStruct:AddField( ;						// Ord. Tipo Desc.
		'BOTAO'          				  , ;       // [01]  C   Nome do Campo
		cOrder             				  , ;       // [02]  C   Ordem
		"Carregar"       				  , ;       // [03]  C   Titulo do campo
		"Carregar"                        , ;       // [04]  C   Descricao do campo
		NIL                               , ;       // [05]  A   Array com Help
		'BT'                              )         // [06] Tipo do campo   COMBO, Get ou CHECK

	cOrder := Soma1( cOrdem )
	oStruct:AddField( ;
		'CORES'          				  , ;       // [01]  C   Nome do Campo
		cOrder            				  , ;       // [02]  C   Ordem
		"Cor Exemplo"  					  , ;       // [03]  C   Titulo do campo
		"Cor Exemplo"    				  , ;       // [04]  C   Descricao do campo
		NIL              				  , ;       // [05]  A   Array com Help
		'BC'             				  )         // [06] Tipo do campo   COMBO, Get ou CHECK

	//Cria a visualizacao do cadastro
    oView := FWFormView():New()

	// Define qual o Modelo de dados a ser utilizado
	oView:SetModel(oModel)

	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField("VIEW_ZD1", oStruct, "ZD1MASTER")

	//Cria um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox("TELA", 100 )

    // Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView("VIEW_ZD1", "TELA")

Return oView
