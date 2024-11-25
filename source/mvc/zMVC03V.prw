#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßß {Protheus.doc} ZMVC03V ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
ßß   @description Cadastro de CDs (Modelo 03)                                        ßß
ßß   @author Renato Silva                                                            ßß
ßß   @since 02/04/2024                                                               ßß
ßß   @obs Atualizacoes > Model-View-Control > Mod 3 c/ Out View                      ßß
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function ZMVC03V()

    Local oBrowse as OBJECT

    oBrowse := FWmBrowse():New()
    oBrowse:SetAlias( 'ZD2' )
    oBrowse:SetDescription( 'Cadastro de CDs' )
    oBrowse:SetMenuDef( 'ZMVC03V' )
    oBrowse:Activate()

Return NIL


//-------------------------------------------------------------------
Static Function MenuDef()

    Local aRotina := {}
    aRotina := FWMVCMenu( 'ZMVC03V' )

Return aRotina


//-------------------------------------------------------------------

Static Function ModelDef()
// Utilizo um model que já existe
Return FWLoadModel( 'ZMVC03' )

//-------------------------------------------------------------------

Static Function ViewDef()

    // Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
    Local oStruZD2 := FWFormStruct( 2, 'ZD2' )

    // Cria a estrutura a ser usada na View
    Local oModel   := FWLoadModel( 'ZMVC03V' )
    Local oView    := GetValType('O')

    // Cria o objeto de View
    oView := FWFormView():New()

    // Define qual o Modelo de dados será utilizado
    oView:SetModel( oModel )

    //Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
    oView:AddField( 'VIEW_ZD2', oStruZD2, 'ZD2MASTER' )

    // Criar um "box" horizontal para receber algum elemento da view
    oView:CreateHorizontalBox( 'TELA', 100 )

    // Relaciona o ID da View com o "box" para exibicao
    oView:SetOwnerView( 'VIEW_ZD2', 'TELA' )

    // Criar novo botao na barra de botoes
    oView:AddUserButton( 'Artistas', 'CLIPS', { |oView, lCopy| COMP021VBUT(oView, lCopy) } )

Return oView


//-------------------------------------------------------------------

Static Function COMP021VBUT( oView, lCopy )

    Local oStruZD3     := FWFormStruct( 2, 'ZD3' )
    Local oModel       := oView:GetModel()
    Local aCoors       := FWGetDialogSize( oMainWnd )
    Local oNewView     := GetValType('O')
    Local oFWMVCWindow := GetValType('O')


    // Cria o objeto de View
    oNewView := FWFormView():New( oView )

    // Define qual o Modelo de dados será utilizado
    oNewView:SetModel( oModel )

    //Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
    oNewView:AddGrid( 'VIEW_ZD3', oStruZD3, 'ZD3DETAIL' )

    // Criar um "box" horizontal para receber algum elemento da view
    oNewView:CreateHorizontalBox( 'SUBTELA', 100 )

    // Relaciona o ID da View com o "box" para exibicao
    oNewView:SetOwnerView( 'VIEW_ZD3', 'SUBTELA' )

    // Define campos que terao Auto Incremento
    oNewView:AddIncrementField( 'VIEW_ZD3', 'ZD3_ITEM' )

    // Liga a identificacao do componente
    oNewView:EnableTitleView('VIEW_ZD3')

    // Liga a Edição de Campos na FormGrid
    oNewView:SetViewProperty( 'VIEW_ZD3', "ENABLEDGRIDDETAIL", { 50 } )

    // Desliga a navegacao interna de registros
    oNewView:setUseCursor( .F. )

    // Define fechamento da tela
    oNewView:SetCloseOnOk( {||.T.} )

    // Criacao do Tela
    oFWMVCWindow := FWMVCWindow():New()
    oFWMVCWindow:SetPos( aCoors[1], aCoors[2] )
    oFWMVCWindow:SetSize( aCoors[3] * 0.7, aCoors[4] * 0.7 )
    oFWMVCWindow:SetTitle( 'CDs dos Artistas' )
    oFWMVCWindow:SetUseControlBar( .T. )
    oFWMVCWindow:SetView( oNewView )
    oFWMVCWindow:Activate( ,,, lCopy)

Return NIL
