//Bibliotecas
#INCLUDE "totvs.ch"
#INCLUDE "fwmvcdef.ch"

//Variveis Estaticas
STATIC cTitulo   := "Artistas x CDs x Músicas (com VerticalBox)"
STATIC cTabPai   := "ZD1"
STATIC cTabFilho := "ZD2"
STATIC cTabNeto  := "ZD3"

/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßß {Protheus.doc} ZMVC08 ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
ßß   @description Artistas x CDs x Músicas (Modelo X com Caixa Vertical)            ßß
ßß   @author Renato Silva                                                           ßß
ßß   @since 19/03/2024                                                              ßß
ßß   @obs Atualizacoes > Model-View-Control > Mod X c/ Cx Vertical-Regras           ßß
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function zMVC08()

	Local aArea     := FWGetArea()
	Local oBrowse   as OBJECT
	Private aRotina := {}

	//Instanciando o browse
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias(cTabPai)
	oBrowse:SetDescription(cTitulo)
	oBrowse:DisableDetails()

	//Ativa a Browse
	oBrowse:Activate()

	FWRestArea(aArea)

Return Nil


Static Function MenuDef()
	Local aRotina := {}
	//Adicionando opcoes do menu
	ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.zMVC08" OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE "Incluir"    ACTION "VIEWDEF.zMVC08" OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.zMVC08" OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE "Excluir"    ACTION "VIEWDEF.zMVC08" OPERATION 5 ACCESS 0
Return aRotina


Static Function ModelDef()

	Local oStruPai   := FWFormStruct(1, cTabPai)
	Local oStruFilho := FWFormStruct(1, cTabFilho, { |x| ! Alltrim(x) $ 'ZD2_NOME' })
    Local oStruNeto  := FWFormStruct(1, cTabNeto)
	Local oModel     as OBJECT
	Local aRelFilho  := {}
    Local aRelNeto   := {}
	Local bPre       := Nil
	Local bPos       := Nil
	Local bCommit    := Nil
	Local bCancel    := Nil
	Local bLinePre   := { |oMdlG,nLine,cAcao,cCampo| COMP023LPRE( oMdlG, nLine, cAcao, cCampo ) }
	Local bLoad      := { |oObj, lCopia| LoadZD2( oObj, lCopia )}

	// Cria o modelo de dados para cadastro
	oModel := MPFormModel():New("zMVC08M", bPre, bPos, bCommit, bCancel)
	oModel:AddFields("ZD1MASTER", /*cOwner*/, oStruPai)
	oModel:AddGrid("ZD2DETAIL","ZD1MASTER",oStruFilho,/*bLinePre*/, /*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/, bLoad)
    oModel:AddGrid("ZD3DETAIL","ZD2DETAIL",oStruNeto, bLinePre, /*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)
	oModel:SetPrimaryKey({})

    // Fazendo o relacionamento (pai e filho)
    oStruFilho:SetProperty("ZD2_ARTIST", MODEL_FIELD_OBRIGAT, .F.)
	aAdd(aRelFilho, {"ZD2_FILIAL", "FWxFilial('ZD2')"} )
	aAdd(aRelFilho, {"ZD2_ARTIST", "ZD1_CODIGO"})
	oModel:SetRelation("ZD2DETAIL", aRelFilho, ZD2->(IndexKey(1)))

	// Fazendo o relacionamento (filho e neto)
	aAdd(aRelNeto, {"ZD3_FILIAL", "FWxFilial('ZD3')"} )
	aAdd(aRelNeto, {"ZD3_CD"    , "ZD2_CD"})
	oModel:SetRelation("ZD3DETAIL", aRelNeto, ZD3->(IndexKey(1)))

	// Definindo campos unicos da linha
    oModel:GetModel("ZD2DETAIL"):SetUniqueLine({'ZD2_CD'})
	oModel:GetModel("ZD3DETAIL"):SetUniqueLine({'ZD3_MUSICA'})

	// Nao Permite Incluir, Alterar ou Excluir linhas na formgrid
	oModel:GetModel( 'ZD3DETAIL' ):SetNoInsertLine()
	oModel:GetModel( 'ZD3DETAIL' ):SetNoUpdateLine()
	oModel:GetModel( 'ZD3DETAIL' ):SetNoDeleteLine()

	// Adiciona regras de preenchimento
    //
    // Tipo 1 Pre-validacao:
    // Adiciona uma relação de dependência entre campos do formulário, impedindo a atribuição
    // de valor caso os campos de dependëncia nao tenham valor atribuido.
    // 
    // Tipo 2 pos-validacao
    // Adiciona uma relação de dependência entre a referência de origem e destino, provocando
    // uma reavaliação do destino em caso de atualização da origem.
    //
    // Tipo 3 pre e pos-validacao
    oModel:AddRules( 'ZD1MASTER', 'ZD1_DTFORM', 'ZD1MASTER', 'ZD1_NOME', 1 )
    
Return oModel


Static Function ViewDef()

	Local oModel     := FWLoadModel("zMVC08")
	Local oStruPai   := FWFormStruct(2, cTabPai)
	Local oStruFilho := FWFormStruct(2, cTabFilho, { |x| ! Alltrim(x) $ 'ZD2_NOME' })
    Local oStruNeto  := FWFormStruct(2, cTabNeto)
	Local oView      := GetValType('O')

	//Cria a visualizacao do cadastro
	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField("VIEW_ZD1", oStruPai  , "ZD1MASTER")
	oView:AddGrid("VIEW_ZD2" , oStruFilho, "ZD2DETAIL")
    oView:AddGrid("VIEW_ZD3" , oStruNeto , "ZD3DETAIL")

	//Partes da tela
	oView:CreateHorizontalBox("CABEC_PAI", 25)
	oView:CreateHorizontalBox("ESPACO_MEIO", 60)
        oView:CreateVerticalBox("MEIO_ESQUERDA", 50 , "ESPACO_MEIO")
        oView:CreateVerticalBox("MEIO_DIREITA",  50 , "ESPACO_MEIO")
	oView:CreateHorizontalBox("OUTROS", 15)

	oView:SetOwnerView("VIEW_ZD1", "CABEC_PAI")
	oView:SetOwnerView("VIEW_ZD2", "MEIO_ESQUERDA")
    oView:SetOwnerView("VIEW_ZD3", "MEIO_DIREITA")

	//Titulos
    oView:EnableTitleView( "VIEW_ZD1", "Pai - ZD1 (Artistas)" )
	oView:EnableTitleView( "VIEW_ZD2", "Filho - ZD2 (CDs)", RGB(224, 30, 43) )
	oView:EnableTitleView( "VIEW_ZD3", "Neto - ZD3 (Musicas dos CDs)" )

	//Removendo campos
    oStruFilho:RemoveField("ZD2_ARTIST")
    oStruFilho:RemoveField("ZD2_NOME")
	oStruNeto:RemoveField("ZD3_CD")

	//Adicionando campo incremental na grid
	oView:AddIncrementField("VIEW_ZD3", "ZD3_ITEM")

	//Acrescenta um objeto externo ao View do MVC
	oView:AddOtherObject("OTHER_PANEL", {|oPanel| COMP23BUT(oPanel)})
    oView:SetOwnerView("OTHER_PANEL",'OUTROS')

Return oView


Static Function COMP23BUT( oPanel )

    @ 10, 10 Button 'Estatistica'  Size 36, 13 Message 'Contagem da FormGrid' Pixel Action COMP23ACAO( 'ZD2DETAIL', 'Existem CDs na Grid' ) of oPanel
    @ 10, 60 Button 'Artista'      Size 36, 13 Message 'Incluir Artista'      Pixel Action FWExecView('Inclusao por FWExecView','ZMVC01', MODEL_OPERATION_INSERT, , { || .T. } ) of oPanel

Return NIL


Static Function COMP23ACAO( cIdGrid, cMsg )

	Local oModel      := FWModelActive()
	Local oModelFilho := oModel:GetModel( cIdGrid )
	Local nI          := 0
	Local nCtInc      := 0
	Local nCtAlt      := 0
	Local nCtDel      := 0
	Local aSaveLines  := FWSaveRows()

	For nI := 1 To oModelFilho:Length()
		oModelFilho:GoLine( nI )

		If     oModelFilho:IsDeleted()
			nCtDel++
		ElseIf oModelFilho:IsInserted()
			nCtInc++
		ElseIf oModelFilho:IsUpdated()
			nCtAlt++
		EndIf

	Next nI


	Help( ,, 'HELP',, cMsg + CRLF + ;
		Alltrim( Str( nCtInc ) ) + ' linhas incluidas' + CRLF + ;
		Alltrim( Str( nCtAlt ) ) + ' linhas alteradas' + CRLF + ;
		Alltrim( Str( nCtDel ) ) + ' linhas deletadas' + CRLF  ;
	, 1, 0)

	FWRestRows( aSaveLines )

Return NIL


Static Function COMP023LPRE( oModelGrid, nLinha, cAcao, cCampo )

	Local lRet       := .T.
	Local oModel     := oModelGrid:GetModel()
	Local nOperation := oModel:GetOperation()

	// Valida se pode ou nao deletar uma linha do Grid
	If cAcao == 'DELETE' .and. nOperation == MODEL_OPERATION_UPDATE
		lRet := .F.
		Help( ,, 'Help',, 'Nao permitido apagar linhas na alteração.' + CRLF + ;
		'Voce está na linha ' + Alltrim( Str( nLinha ) ), 1, 0 )
    EndIf

Return lRet


Static Function LoadZD2( oGrid, lCopy )

	Local aArea   := FWGetArea() 
	Local aFields := {}
	Local aRet    := {} 
	Local cFields := 'R_E_C_N_O_'
	Local cTmp    as char
	Local cQuery  as char

	// Pega campos que fazem parte da estrutura do objeto, para otimizar retorno da query
	aFields := oGrid:GetStruct():GetFields()
	aEval( aFields, { |aX| IIf( !aX[MODEL_FIELD_VIRTUAL], cFields += ',' + aX[MODEL_FIELD_IDFIELD],) } )

	cTmp   := GetNextAlias() 
	cQuery := ""
	cQuery += "SELECT " + cFields + " FROM " + RetSqlName( 'ZD2' ) + " ZD2"
	cQuery += " WHERE ZD2_FILIAL='" + FWxFilial( 'ZD2' ) + "'"
	cQuery += " AND ZD2_ARTIST = '" + oGrid:GetModel():GetModel( 'ZD1MASTER' ):GetValue( 'ZD1_CODIGO' ) + "'"
	cQuery += " AND ZD2.D_E_L_E_T_=' '"

	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cTmp, .F., .T. ) 

	aRet := FWLoadByAlias( oGrid, cTmp ) 

	(cTmp)->( dbCloseArea() ) 

	FWRestArea( aArea ) 

Return aRet  
