//Bibliotecas
#INCLUDE "totvs.ch"
#INCLUDE "fwmvcdef.ch"

//Variaveis Estaticas
STATIC cTitulo   := "Cadastro de Artistas"
STATIC cAliasMVC := "ZD1"

/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßß {Protheus.doc} ZMVC01A ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
ßß   @description Cadastro de Artistas (com Validações e alterações de caracteris)    ßß
ßß   @author Renato Silva                                                             ßß
ßß   @since 10/03/2024                                                                ßß
ßß   @obs Atualizacoes > Model-View-Control > Modelo 01 c/ Val - Cad Artistas         ßß
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function zMVC01A()

	Local aArea     := FWGetArea()
	Local oBrowse   := GetValType('O')
	Private aRotina := {}

    //Definicao do menu
    aRotina := MenuDef()

	//Instancia a classe do browse
	oBrowse := FWMBrowse():New()

	//Configura a tabela a ser utilizada
	oBrowse:SetAlias(cAliasMVC)

	//Configura o titulo do browse
	oBrowse:SetDescription(cTitulo)

	//Configura os campos que serao exibidos no browse
	//oBrowse:SetOnlyFields({"ZD1_NOME"})

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
STATIC Function MenuDef()

	Local aRotina    := {}
	Local aRotinaAut := FWMVCMenu('ZMVC01A')
	Local n := 0

    // Populo a variável aRotina.
    ADD OPTION aRotina TITLE "Legenda"  ACTION "U_SZ9LEG"    OPERATION 6 ACCESS 0
    ADD OPTION aRotina TITLE "Sobre"    ACTION "U_SZ9SOBRE"  OPERATION 6 ACCESS 0

    For n := 1 To Len(aRotinaAut)
        aAdd( aRotina, aRotinaAut[n] )
    Next n

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
	Local bPos    := { |oMdl| COMP011POS( oMdl ) }
	Local bCommit := Nil
	Local bCancel := Nil

    // Cria a estrutura a ser usada no Modelo de Dados
	oStruct := FWFormStruct(1, cAliasMVC)

	// Remove campos da estrutura
	//oStruct:RemoveField( 'ZD1_DTFORM' )

	// Criação de campos Memo virtuais SYP
	FWMemoVirtual( oStruct, {{'ZD1_CDSYP1','ZD1_MMSYP1'},{'ZD1_CDSYP2','ZD1_MMSYP2'}}  )

    // Alteração de propriedades dos campos da estrutura
	// SetProperty( <Campo>, <Propriedade>, <Valor> )
    oStruct:SetProperty( 'ZD1_CODIGO' , MODEL_FIELD_INIT, FWBuildFeature(STRUCT_FEATURE_INIPAD , 'GetSXENum("ZD1","ZD1_CODIGO")') )
    //oStruct:SetProperty( '*'          , MODEL_FIELD_NOUPD, .T. )
	
	//Cria o modelo de dados para cadastro
	oModel := MPFormModel():New("zMVC01AM", bPre, bPos, bCommit, bCancel)

	//Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:AddFields("ZD1MASTER", /*cOwner*/, oStruct, /*bPreVal*/, /*bPosVal*/, /*bCarga*/ )

    // Adiciona um titulo ao Modelo de Dados
	oModel:SetDescription("Modelo de dados - " + cTitulo)

	// Adiciona a descricao do Componente do Modelo de Dados
	oModel:GetModel("ZD1MASTER"):SetDescription( "Dados de - " + cTitulo)

	// Definindo a chave primária da tabela para a aplicação
	oModel:SetPrimaryKey({'ZD1_FILIAL','ZD1_CODIGO'})

	// Liga a validação da ativação do Modelo de Dados
	oModel:SetVldActivate( { |oModel| COMP011ACT( oModel ) } )

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
	Local oModel  := FWLoadModel("zMVC01A")
	Local oView   := GetValType('O')

	// Cria a estrutura a ser usada na View
	Local oStruct := FWFormStruct(2, cAliasMVC, { |cCampo| COMP11STRU(cCampo) },/*lViewUsado*/,/*lVirtual*/,/*lFilOnView*/,/*cProgram*/)
  	
	/*Cria os agrupamentos de Campos
	//AddGroup( cID, cTitulo, cIDFolder, nType )   nType => ( 1=Janela; 2=Separador )*/
	oStruct:AddGroup( 'GRUPO01', 'Alguns Dados', '', 1 )
	oStruct:AddGroup( 'GRUPO02', 'Outros Dados', '', 2 )

    //Altero propriedades dos campos da estrutura, colocando cada campo em um grupo
	oStruct:SetProperty( '*'         , MVC_VIEW_GROUP_NUMBER, 'GRUPO01' )
	//oStruct:SetProperty( 'ZD1_NOME', MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )
	oStruct:SetProperty( 'ZD1_DTFORM', MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )

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

	// Exibe mensagem a cada ação na View
	oView:SetViewAction( 'BUTTONOK'    , { |o| Help(,,'HELP',,'Ação de Confirmar' + o:ClassName(),1,0) } )
	oView:SetViewAction( 'BUTTONCANCEL', { |o| Help(,,'HELP',,'Ação de Cancelar ' + o:ClassName(),1,0) } )

Return oView


/*
-------------------------------------------------------------------------------
    Alerta para preencher a data de formação
-------------------------------------------------------------------------------
*/
Static Function COMP011POS( oModel )

	Local nOperation := oModel:GetOperation()
	Local lRet       := .T.

	If nOperation == MODEL_OPERATION_UPDATE
		If Empty( oModel:GetValue( 'ZD1MASTER', 'ZD1_DTFORM' ) )
			Help( ,, 'HELP',, 'Informe a data de formação', 1, 0)
			lRet := .F.
		EndIf
	EndIf

Return lRet


/*
-------------------------------------------------------------------------------
    Validação antes de excluir o artista
-------------------------------------------------------------------------------
*/
Static Function COMP011ACT( oModel )  // Passa o model sem dados

	Local aArea      := FWGetArea()
	Local cQuery     := ''
	Local cTmp       := ''
	Local lRet       := .T.
	Local nOperation := oModel:GetOperation()

	If nOperation == MODEL_OPERATION_DELETE .AND. lRet

		cTmp    := GetNextAlias()

		cQuery  += "SELECT ZD1_CODIGO FROM " + RetSqlName( 'ZD1' ) + " ZD1 "
		cQuery  += "WHERE EXISTS ( "
		cQuery  += "    SELECT 1 FROM " + RetSqlName( 'ZD2' ) + " ZD2 "
		cQuery  += "    WHERE ZD2_ARTIST = ZD1_CODIGO"
		cQuery  += "    AND ZD2.D_E_L_E_T_ = ' ' ) "
		cQuery  += "AND ZD1_CODIGO = '" + ZD1->ZD1_CODIGO  + "' "
		cQuery  += "AND ZD1.D_E_L_E_T_ = ' ' "

		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cTmp, .F., .T. )

		lRet := (cTmp)->( EOF() )

		(cTmp)->( dbCloseArea() )

		If lRet
		    cQuery  += "SELECT ZD1_CODIGO FROM " + RetSqlName( 'ZD1' ) + " ZD1 "
		    cQuery  += "WHERE EXISTS ( "
			cQuery  += "    SELECT 1 FROM " + RetSqlName( 'ZD4' ) + " ZD4 "
			cQuery  += "    WHERE ZD4_ARTIST = ZD1_CODIGO"
			cQuery  += "    AND ZD4.D_E_L_E_T_ = ' ' ) "
			cQuery  += "AND ZD1_CODIGO = '" + ZD1->ZD1_CODIGO  + "' "
			cQuery  += "AND ZD1.D_E_L_E_T_ = ' ' "

			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cTmp, .F., .T. )

			lRet := (cTmp)->( EOF() )

			(cTmp)->( dbCloseArea() )

		EndIf

		If !lRet
			Help( ,, 'HELP',, 'Este artista não pode ser excluído.', 1, 0)
		EndIf

	EndIf

	FWRestArea( aArea )

Return lRet

/*
-------------------------------------------------------------------------------
    Condição para extringir o campo Onservações
-------------------------------------------------------------------------------
*/
Static Function COMP11STRU( cCampo )

	Local lRet := .T.
	If cCampo == 'ZD1_OBSERV'
		lRet := .F.
	EndIf

Return lRet


/*
-------------------------------------------------------------------------------
    Opções em Outras Ações com mensagens informativas
-------------------------------------------------------------------------------
*/
User Function SZ9SOBRE()

    Local cSobre := ""
	cSobre := "<font color = GREEN>Minha primeira tela em MVC Modelo 1<br>"
	cSobre += "Este fonte foi desenvolvido por um protheuzeiro da Sistematizei.</font>"
    FWAlertInfo(cSobre,"INFORMAÇÃO")

Return NIL


User Function SZ9LEG()
    
    Local aLegenda := {}

    aAdd(aLegenda,{ "BR_AMARELO" , "Autor"      })
    aAdd(aLegenda,{ "BR_AZUL"    , "Intérprete" })

    BRWLegenda("Classificação de músicos","Autor/Intérprete",aLegenda)

Return aLegenda


// Propriedades existentes para ModelDef:
//      MODEL_FIELD_TITULO    Titulo
//      MODEL_FIELD_TOOLTIP   Descrição completa do campo
//      MODEL_FIELD_IDFIELD   Nome (ID)
//      MODEL_FIELD_TIPO      Tipo
//      MODEL_FIELD_TAMANHO   Tamanho
//      MODEL_FIELD_DECIMAL   Decimais
//      MODEL_FIELD_VALID     Validação
//      MODEL_FIELD_WHEN      Modo de edição
//      MODEL_FIELD_VALUES    Lista de valores permitido do campo (combo)
//      MODEL_FIELD_OBRIGAT   Indica se o campo tem preenchimento obrigatório
//      MODEL_FIELD_INIT      Inicializador padrão
//      MODEL_FIELD_KEY       Indica se o campo é chave
//      MODEL_FIELD_NOUPD     Indica se o campo pode receber valor em uma operação de update
//      MODEL_FIELD_VIRTUAL   Indica se o campo é virtual

// Propriedades existentes para ViewDef:
//		MVC_VIEW_IDFIELD        Nome do Campo
//		MVC_VIEW_ORDEM          Ordem
//		MVC_VIEW_TITULO         Título do campo
//		MVC_VIEW_DESCR          Descrição do campo
//		MVC_VIEW_HELP			Array com Help
//		MVC_VIEW_PICT			Picture
//		MVC_VIEW_PVAR			Bloco de Picture Var
//		MVC_VIEW_LOOKUP			Consulta F3
//		MVC_VIEW_CANCHANGE		Indica se o campo é editável
//		MVC_VIEW_FOLDER_NUMBER  Pasta do campo
//		MVC_VIEW_GROUP_NUMBER   Agrupamento do campo
//		MVC_VIEW_COMBOBOX       Lista de valores permitido do campo (Combo)
//		MVC_VIEW_MAXTAMCMB      Tamanho Maximo da maior opção do combo
//		MVC_VIEW_INIBROW		Inicializador de Browse
//		MVC_VIEW_VIRTUAL		Indica se o campo é virtual
//		MVC_VIEW_PICTVAR		Picture Variável
//		MVC_VIEW_INSERTLINE     Indica se deve haver pulo de linha após o campo
//		MVC_VIEW_WIDTH          Largura fixa do campo no grid
//		MVC_VIEW_MODAL          Indica se o campo deve ser exibido em formulários modal
