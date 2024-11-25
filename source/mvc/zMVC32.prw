//Bibliotecas
#Include "totvs.ch"
#Include "FWMVCDef.ch"

Static lEmExecucao   := .F.

/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßß {Protheus.doc} ZMVC32 ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
ßß   @description Artistas x CDs com 2 browses de cadastro usando FWBrwRelation     ßß
ßß   @author Renato Silva                                                           ßß
ßß   @since 06/04/2024                                                              ßß
ßß   @obs Atualizacoes > Model-View-Control > Mod 3 c/ Dois Browses (FWBrwRelation) ßß
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function zMVC32()

	Local aArea      := FWGetArea()
    Local cFunBkp    := FunName()
	Local aCoors     := FWGetDialogSize( oMainWnd )
	Local cIdArtist  := ""
	Local cIdCds     := ""
	Local oPanelUp   as OBJECT
	Local oTela      as OBJECT
	Local oPanelDown as OBJECT
	Local oRelaction as OBJECT
	Private aRotina := {}

	//Tratativa para impedir que seja aberta a mesma janela por cima da original do browse
	If ! lEmExecucao
		SetFunName("zMVC32")
		dbSelectArea("ZD1")
		dbSelectArea("ZD2")

		//Cria a janela principal
		Define MsDialog oDlgPrinc Title "Artistas x CDs com 2 browses (FWBrwRelation)" ;
		From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] OF oMainWnd Pixel

			//Divide a tela em dois containers, um de 30% e outro de 68%
			oTela     := FWFormContainer():New( oDlgPrinc )
			cIdArtist := oTela:CreateHorizontalBox( 30 )
			cIdCds    := oTela:CreateHorizontalBox( 68 )
			oTela:Activate( oDlgPrinc, .F. )

			//Cria os painéis
			oPanelUp  	:= oTela:GetPanel( cIdArtist )
			oPanelDown  := oTela:GetPanel( cIdCds )

			//Cria o browse superior trazendo dados da ZD1
			oBrowseUp:= FWmBrowse():New()
			oBrowseUp:SetOwner(oPanelUp)
			oBrowseUp:SetDescription("Artistas")
			oBrowseUp:SetAlias('ZD1')
			oBrowseUp:DisableDetails()
			oBrowseUp:SetProfileID('1')
			oBrowseUp:ExecuteFilter(.T.)
			oBrowseUp:SetMainProc("zMVC03")
			oBrowseUp:ForceQuitButton()
			oBrowseUp:SetCacheView (.F.)
			oBrowseUp:SetOnlyFields({'ZD1_CODIGO', 'ZD1_NOME'})
			oBrowseUp:Activate()

			//Cria o browse inferior, que irá trazer todos os cds do artista
			aRotina   := MenuDef()
			oBrowseDwn:= FWMBrowse():New()
			oBrowseDwn:SetOwner(oPanelDown)
			oBrowseDwn:SetDescription("CDs")
			oBrowseDwn:DisableDetails()
			oBrowseDwn:SetAlias('ZD2')
			oBrowseDwn:SetProfileID('2')
			oBrowseDwn:SetMainProc("zMVC01")
			oBrowseDwn:SetCacheView (.F.)
			oBrowseDwn:SetOnlyFields({'ZD2_CD', 'ZD2_NOMECD'})

			//Faz o relacionamento entre os dois browses
			oRelaction:= FWBrwRelation():New()
			oRelaction:AddRelation( oBrowseUp  , oBrowseDwn , { { 'ZD2_ARTIST' , 'ZD1_CODIGO' } } )
			oRelaction:Activate()
			oBrowseDwn:Activate()

			//Atualiza os browses e cria a janela na tela
			oBrowseUp:Refresh()
			oBrowseDwn:Refresh()
			lEmExecucao := .T.

		Activate MsDialog oDlgPrinc Center

		lEmExecucao := .F.
        SetFunName(cFunBkp)
	EndIf

	FWRestArea(aArea)

Return NIL

Static Function MenuDef()
	Local aRotina := FWMVCMenu('zMVC32')
Return aRotina

