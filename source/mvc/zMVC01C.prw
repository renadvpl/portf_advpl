//Bibliotecas
#INCLUDE 'totvs.ch'
#INCLUDE "fwmvcdef.ch"

/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßß {Protheus.doc} ZMVC01C ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
ßß   @description Exemplo de montagem da modelo e interface para um tabela em MVC,    ßß
ßß                utilizando um MODEL e VIEW já existentes                            ßß
ßß   @author      Renato Silva                                                        ßß
ßß   @since       26/03/2024                                                          ßß
ßß   @obs         Atualizacoes > Model-View-Control > Modelo 01 - Cad Artistas        ßß
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function zMVC01C()

    Local oBrowse := FWMBrowse():New()
    Private aRotina := {}

	aRotina := MenuDef()
    oBrowse:SetAlias('ZD1')
    oBrowse:SetDescription( 'Cadastro de Artistas com Premiações' )
    oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------

Static Function MenuDef()
    // Não é recomendado este formato de menu pela dificuldade de manutenção
    Local aRotina := {}

    aAdd( aRotina, { 'Visualizar', 'VIEWDEF.ZMVC01C', 0, 2, 0, NIL } )
    aAdd( aRotina, { 'Incluir'   , 'VIEWDEF.ZMVC01C', 0, 3, 0, NIL } )
    aAdd( aRotina, { 'Alterar'   , 'VIEWDEF.ZMVC01C', 0, 4, 0, NIL } )
    aAdd( aRotina, { 'Excluir'   , 'VIEWDEF.ZMVC01C', 0, 5, 0, NIL } )
    aAdd( aRotina, { 'Imprimir'  , 'VIEWDEF.ZMVC01C', 0, 8, 0, NIL } )
    aAdd( aRotina, { 'Copiar'    , 'VIEWDEF.ZMVC01C', 0, 9, 0, NIL } )

Return aRotina

//------------------------------------------------------------------------------------------------------------

Static Function ModelDef()

    // Cria a estrutura a ser acrescentada no Modelo de Dados
    Local oStruZD5 := FWFormStruct( 1, 'ZD5' )

    // Inicia o Model com um Model já existente
    Local oModel as OBJECT
    oModel := FWLoadModel("ZMVC01")

    // Adiciona a nova FORMFIELD
    oModel:AddFields( 'ZD5MASTER', 'ZD1MASTER', oStruZD5 )

    // Faz relacionamento entre os compomentes do model
    oModel:SetRelation( 'ZD5MASTER', { ;
        { 'ZD5_FILIAL', 'FWxFilial( "ZD5" )' }, ;
        { 'ZD5_CODIGO', 'ZD1_CODIGO' } }, ZD5->( IndexKey( 1 ) ) )

    // Adiciona a descricao do novo componente
    oModel:GetModel( 'ZD5MASTER' ):SetDescription( 'Complemento de Dados do Artista' )
    //oModel:GetModel( 'ZD5MASTER' ):SetOptional( .T. )

Return oModel

//-------------------------------------------------------------------------------------------------------

Static Function ViewDef()

    // Cria a estrutura a ser acrescentada na View
    Local oStruZD5 := FWFormStruct( 2, 'ZD5' )

    // Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
    Local oModel   := FWLoadModel( 'ZMVC01C' )

    // Inicia a View com uma View ja existente
    Local oView    := FWLoadView( 'ZMVC01' )

    // Altera o Modelo de dados quer será utilizado
    oView:SetModel( oModel )

    // Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
    oView:AddField( 'VIEW_ZD5', oStruZD5, 'ZD5MASTER' )

    // É preciso criar sempre um box vertical dentro de um horizontal e vice-versa
    // como na COMP011, o box é horizontal, cria-se um vertical primeiro
    oView:CreateVerticalBox(  'TELANOVA' , 100, 'TELA'     )
    oView:CreateHorizontalBox('SUPERIOR' ,  50, 'TELANOVA' )
    oView:CreateHorizontalBox('INFERIOR' ,  50, 'TELANOVA' )

    // Relaciona o ID da View com o "box" para exibicao
    oView:SetOwnerView( 'VIEW_ZD1', 'SUPERIOR' )
    oView:SetOwnerView( 'VIEW_ZD5', 'INFERIOR' )

    // Liga a identificacao do componente
    oView:EnableTitleView( 'VIEW_ZD1' )
    oView:EnableTitleView( 'VIEW_ZD5' )

Return oView
