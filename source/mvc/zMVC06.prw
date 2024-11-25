//Bibliotecas
#INCLUDE "TOTVS.ch"
#INCLUDE "FWMVCDef.ch"

//Variaveis Estaticas
STATIC cTitulo   := "Artistas x CDs x Músicas (com Cálculos)"
STATIC cTabPai   := "ZD1"
STATIC cTabFilho := "ZD2"
STATIC cTabNeto  := "ZD3"

/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßß {Protheus.doc} ZMVC06 ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
ßß   @description Artistas x CDs x Músicas (Modelo X com Cálculos)                  ßß
ßß   @author Renato Silva                                                           ßß
ßß   @since 19/03/2024                                                              ßß
ßß   @obs Atualizacoes > Model-View-Control > Mod X c/ Calculos - Art/CDs/Mus       ßß
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function zMVC06()

	Local aArea     := FWGetArea()
	Local oBrowse   := GetValType('O')

	//Instanciando o browse
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias(cTabPai)
	oBrowse:SetDescription(cTitulo)
	oBrowse:DisableDetails()

	//Ativa a Browse
	oBrowse:Activate()

	FWRestArea(aArea)

Return NIL


Static Function MenuDef()
	Local aRotina := {}
	//Adicionando opcoes do menu
	ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.zMVC06" OPERATION 1 ACCESS 0
	ADD OPTION aRotina TITLE "Incluir"    ACTION "VIEWDEF.zMVC06" OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.zMVC06" OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE "Excluir"    ACTION "VIEWDEF.zMVC06" OPERATION 5 ACCESS 0
Return aRotina


Static Function ModelDef()
	Local oStruPai   := FWFormStruct(1, cTabPai)
	Local oStruFilho := FWFormStruct(1, cTabFilho, { |x| ! Alltrim(x) $ 'ZD2_NOME' })
    Local oStruNeto  := FWFormStruct(1, cTabNeto)
	Local aRelFilho  := {}
    Local aRelNeto   := {}
	Local oModel     := GetValType('O')
	Local bPre       := Nil
	Local bPos       := Nil
	Local bCommit    := Nil
	Local bCancel    := Nil


	//Cria o modelo de dados para cadastro
	oModel := MPFormModel():New("zMVC06M", bPre, bPos, bCommit, bCancel)
	oModel:AddFields("ZD1MASTER", /*cOwner*/, oStruPai)
	oModel:AddGrid("ZD2DETAIL","ZD1MASTER",oStruFilho,/*bLinePre*/, /*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)
    oModel:AddGrid("ZD3DETAIL","ZD2DETAIL",oStruNeto,/*bLinePre*/, /*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)
	oModel:SetPrimaryKey({})

    //Fazendo o relacionamento (pai e filho)
    oStruFilho:SetProperty("ZD2_ARTIST", MODEL_FIELD_OBRIGAT, .F.)
	aAdd(aRelFilho, {"ZD2_FILIAL", "FWxFilial('ZD2')"} )
	aAdd(aRelFilho, {"ZD2_ARTIST", "ZD1_CODIGO"})
	oModel:SetRelation("ZD2DETAIL", aRelFilho, ZD2->(IndexKey(1)))

	//Fazendo o relacionamento (filho e neto)
	aAdd(aRelNeto, {"ZD3_FILIAL", "FWxFilial('ZD3')"} )
	aAdd(aRelNeto, {"ZD3_CD", "ZD2_CD"})
	oModel:SetRelation("ZD3DETAIL", aRelNeto, ZD3->(IndexKey(1)))

	//Definindo campos unicos da linha
    oModel:GetModel("ZD2DETAIL"):SetUniqueLine({'ZD2_CD'})
	oModel:GetModel("ZD3DETAIL"):SetUniqueLine({'ZD3_MUSICA'})

    //Adicionando totalizadores de campos
    oModel:AddCalc('TOTAIS', 'ZD1MASTER', 'ZD2DETAIL', 'ZD2_CD',     'XX_TOTCDS', 'COUNT', , , "Total de CDs:" )
    oModel:AddCalc('TOTAIS', 'ZD2DETAIL', 'ZD3DETAIL', 'ZD3_MUSICA', 'XX_TOTMUS', 'COUNT', , , "Total de Musicas:" )

Return oModel

/*/{Protheus.doc} ViewDef
Visualizacao de dados na funcao zMVC06
@author Daniel Atilio
@since 04/02/2022
@version 1.0
@type function
/*/

Static Function ViewDef()

	Local oModel     := FWLoadModel("zMVC06")
	Local oStruPai   := FWFormStruct(2, cTabPai)
	Local oStruFilho := FWFormStruct(2, cTabFilho, { |x| ! Alltrim(x) $ 'ZD2_NOME' })
    Local oStruNeto  := FWFormStruct(2, cTabNeto)
    Local oStruTot   := FWCalcStruct(oModel:GetModel('TOTAIS'))
	Local oView      := GetValType('O')

	//Cria a visualizacao do cadastro
	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField("VIEW_ZD1", oStruPai   , "ZD1MASTER")
	oView:AddGrid( "VIEW_ZD2", oStruFilho , "ZD2DETAIL")
    oView:AddGrid( "VIEW_ZD3", oStruNeto  , "ZD3DETAIL")
    oView:AddField("VIEW_TOT", oStruTot   , "TOTAIS"   )

	//Partes da tela
	oView:CreateHorizontalBox("CABEC_PAI" , 25)
	oView:CreateHorizontalBox("GRID_FILHO", 30)
    oView:CreateHorizontalBox("GRID_NETO" , 30)
    oView:CreateHorizontalBox("ENCH_TOT"  , 15)

	oView:SetOwnerView("VIEW_ZD1", "CABEC_PAI" )
	oView:SetOwnerView("VIEW_ZD2", "GRID_FILHO")
    oView:SetOwnerView("VIEW_ZD3", "GRID_NETO" )
    oView:SetOwnerView("VIEW_TOT", "ENCH_TOT"  )

	//Titulos
    oView:EnableTitleView("VIEW_ZD1", "Pai - ZD1 (Artistas)")
	oView:EnableTitleView("VIEW_ZD2", "Filho - ZD2 (CDs)")
	oView:EnableTitleView("VIEW_ZD3", "Neto - ZD3 (Musicas dos CDs)")

	//Removendo campos
    oStruFilho:RemoveField("ZD2_ARTIST")
    oStruFilho:RemoveField("ZD2_NOME")
	oStruNeto:RemoveField("ZD3_CD")

	//Adicionando campo incremental na grid
	oView:AddIncrementField("VIEW_ZD3", "ZD3_ITEM")

Return oView
