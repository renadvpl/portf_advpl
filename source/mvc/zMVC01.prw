//Bibliotecas
#INCLUDE "totvs.ch"
#INCLUDE "fwmvcdef.ch"

//Variaveis Estaticas
STATIC cTitulo   := "Cadastro de Artistas"
STATIC cAliasMVC := "ZD1"

/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßß {Protheus.doc} ZMVC01 ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
ßß   @description Cadastro de Artistas (exemplo basico de MVC)                        ßß
ßß   @author Renato Silva                                                             ßß
ßß   @since 10/03/2024                                                                ßß
ßß   @obs Atualizacoes > Model-View-Control > Modelo 01 - Cad Artistas                ßß
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function zMVC01()

	Local aArea     := FWGetArea()
	Local oBrowse   := GetValType('O')
	Private aRotina := {}

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

    //Filtra os registros exibidos no browse
	//oBrowse:SetFilterDefault("ZD1_CODIGO == '000001'")
    
	//Carrega coluna adicional com o sinal indicativo, conforme regra
	//oBrowse:AddLegend("!Empty(ZD1_DTFORM)","GREEN","Protheuzeiro Ativo")

	//O default do browse é fazer o cache, porém se tivermos vários views condicionais, devemos não utilizar o cache.
    //oBrowse:SetCacheView(.F.)

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

	Local aRotina := {}
/*
	//Adicionando opcoes do menu
	ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.zMVC01" OPERATION 1 ACCESS 0
	ADD OPTION aRotina TITLE "Incluir"    ACTION "VIEWDEF.zMVC01" OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.zMVC01" OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE "Excluir"    ACTION "VIEWDEF.zMVC01" OPERATION 5 ACCESS 0
	ADD OPTION aRotina TITLE 'Imprimir'   ACTION 'VIEWDEF.zMVC01' OPERATION 8 ACCESS 0
	ADD OPTION aRotina TITLE 'Copiar'     ACTION 'VIEWDEF.zMVC01' OPERATION 9 ACCESS 0

	/* ou*/
	aRotina := FWMVCMenu('zMVC01')

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

	//Cria o modelo de dados para cadastro
	oModel := MPFormModel():New("zMVC01M", bPre, bPos, bCommit, bCancel)

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
	Local oModel  := FWLoadModel("zMVC01")

	// Cria a estrutura a ser usada na View
	Local oStruct := FWFormStruct(2, cAliasMVC, /*lViewUsado*/,/*lVirtual*/,/*lFilOnView*/,/*cProgram*/)
  	
	//Cria a visualizacao do cadastro
	Local oView   := GetValType('O')
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
