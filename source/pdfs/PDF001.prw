//Bibliotecas
#Include "TOTVS.ch"
#Include "TopConn.ch"
#Include "RPTDef.ch"
#Include "FWPrintSetup.ch"

//Alinhamentos
#Define PAD_LEFT    0
#Define PAD_RIGHT   1
#Define PAD_CENTER  2
#Define PAD_JUSTIFY 3
/*
%%%%%%%%%%%%%%%% {Protheus.doc} User Function PDF001 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%    @Desc:   Gera��o de PDF com FWMSPrinter (impress�o de textos c/ Say e SayBitmap) %%
%%    @Func:   PDF001                                                                  %%
%%    @Author: Renato Silva                                                            %%
%%    @Since:  28/11/2022                                                              %%
%%    @obs     https://tdn.totvs.com/display/public/framework/FWMsPrinter              %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
*/
User Function PDF001()

    Local aArea  := FWGetArea()

    If FWAlertYesNo("Deseja gerar o relat�rio?", "ATEN��O")
        Processa({|| fMontaRel()}, "Processando...")
    EndIf

    FWRestArea(aArea)

Return NIL

 
Static Function fMontaRel()

    Local cCaminho    := ""
    Local cArquivo    := ""
    Local lNegrito    := .T.
    Local lSublinhado := .T.
    Local lItalico    := .T.
 
    Private nLinAtu   := 000
    Private nTamLin   := 010
    Private nLinFin   := 820
    Private nColIni   := 010
    Private nColFin   := 550
    Private nColMeio  := (nColFin-nColIni)/2
    Private nEspLin   := 015
    //Cor usada
    Private nCorForte := RGB(003, 101, 002)

    Private dDataGer  := Date()
    Private cHoraGer  := Time()

    Private oPrintPvt
    Private cNomeFont  := "Arial"
    Private oFontCabN  := TFont():New(cNomeFont, , -15, ,  lNegrito, , , , , !lSublinhado, !lItalico)
    Private oFontDet   := TFont():New(cNomeFont, , -11, , !lNegrito, , , , , !lSublinhado, !lItalico)
    Private oFontDetN  := TFont():New(cNomeFont, , -13, ,  lNegrito, , , , , !lSublinhado, !lItalico)
    Private oFontDetI  := TFont():New(cNomeFont, , -11, , !lNegrito, , , , , !lSublinhado,  lItalico)
    Private oFontMin   := TFont():New(cNomeFont, , -09, , !lNegrito, , , , , !lSublinhado, !lItalico)
    
    cCaminho  := GetTempPath()
    cArquivo  := "PDF001_" + DtoS(dDataGer) + "_" + StrTran(cHoraGer, ':', '-')
        
    oPrintPvt := FWMSPrinter():New(cArquivo,IMP_PDF,.F.,"",.T.,,,"",,,,.T.)
    oPrintPvt:cPathPDF := cCaminho
     
    oPrintPvt:SetResolution(72)
    oPrintPvt:SetPortrait()
    oPrintPvt:SetPaperSize(DMPAPER_A4)
    oPrintPvt:SetMargin(60, 60, 60, 60)
     
    oPrintPvt:StartPage()

        //Imprimindo o logo, FWMsPrinter(): SayBitmap ( <nVert>, <nHori>, <cDiretorio>, [nLargura], [nAltura] )
        cLogoRel := "\images\logo_fuabc.jpg"
        oPrintPvt:SayBitmap(nLinAtu + 50, nColIni + 25, cLogoRel, 130, 78) // 100 � a metade de 200, - 35 que � a metade da largura, d� 065

        nLinAtu := 40
        oPrintPvt:SayAlign(nLinAtu, nColIni + 200, "Dados:"                           , oFontDetN , 200, 015, nCorForte, PAD_LEFT, )
        nLinAtu += nEspLin

        oPrintPvt:SayAlign(nLinAtu, nColIni + 200, "Funda��o do ABC:"                 , oFontCabN , 200, 015, nCorForte, PAD_LEFT, )
        nLinAtu += nEspLin + 5

        oPrintPvt:SayAlign(nLinAtu, nColIni + 200, "Site:"                            , oFontDetN , 200, 015, , PAD_LEFT, )
        oPrintPvt:SayAlign(nLinAtu, nColIni + 270, "https://fuabc.org.br"             , oFontDet  , 200, 015, , PAD_LEFT, )
        nLinAtu += nEspLin

        oPrintPvt:SayAlign(nLinAtu, nColIni + 200, "eMail:"                           , oFontDetN , 200, 015, , PAD_LEFT, )
        oPrintPvt:SayAlign(nLinAtu, nColIni + 270, "renato.silva@fuabc.org.br"        , oFontDet  , 200, 015, , PAD_LEFT, )
        nLinAtu += nEspLin

        oPrintPvt:SayAlign(nLinAtu, nColIni + 200, "WhatsApp:"                        , oFontDetN , 200, 015, , PAD_LEFT, )
        oPrintPvt:SayAlign(nLinAtu, nColIni + 270, "(11) 9 9738-5495"                 , oFontDet  , 200, 015, , PAD_LEFT, )
        nLinAtu += nEspLin

        oPrintPvt:SayAlign(nLinAtu, nColIni + 200, "Um projeto da *RSilva Sistemas*"  , oFontDetI , 200, 015, , PAD_LEFT, )
        nLinAtu += nEspLin

        //Imprime textos laterais com o m�todo Say
        cTextoAux := "At vero eos et accusamus et iusto odio dignissimos ducimus qui blanditiis praesentium voluptatum deleniti atque corrupti quos dolores et quas molestias excepturi sint occaecati cupiditate non provident"
        oPrintPvt:Say(040,     nColIni - 15, "Esq: " + cTextoAux, oFontMin, , nCorForte, 090)
        oPrintPvt:Say(nLinFin, nColFin + 15, "Dir: " + cTextoAux, oFontMin, , nCorForte, 270)

    oPrintPvt:EndPage()
     
    oPrintPvt:Preview()

Return NIL
