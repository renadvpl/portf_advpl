//Bibliotecas de Fun��es
#include "TOTVS.ch"
#include "TopConn.ch"
#include "RPTDef.ch"
#include "FWPrintSetup.ch"

//Alinhamentos
#define PAD_LEFT    0
#define PAD_RIGHT   1
#define PAD_CENTER  2
#define PAD_JUSTIFY 3 //Op��o dispon�vel somente a partir da vers�o 1.6.2 da TOTVS Printer

/*
%%%%%%%%%%%%%%%% {Protheus.doc} User Function IMPPDFT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%    @Desc:   Gera��o de Relat�rio em PDF com a classe FWMSPrinter                    %%
%%    @Func:   ImpPDFt                                                                 %%
%%    @Author: Renato Silva                                                            %%
%%    @Since:  28/11/2022                                                              %%
%%    @obs     https://tdn.totvs.com/display/public/framework/FWMsPrinter              %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
*/ 
User Function ImpPDFt()

    Local aArea  := FWGetArea()
    Private lJob := IsBlind()
     
    //Se for execu��o autom�tica, n�o mostra pergunta, executa direto
    If lJob
        Processa({|| fMontaPDF()}, "Processando...")
         
    //Sen�o, se a pergunta for confirmada, executa o relat�rio
    Else
        If FWAlertYesNo("Deseja gerar o relat�rio?", "Aten��o")
            Processa({|| fMontaPDF()}, "Processando...")
        EndIf
    EndIf
     
    FWRestArea(aArea)

Return
 
/*---------------------------------------------------------------------*
 | Func:  fMontaPDF                                                    |
 | Desc:  Fun��o que monta o relat�rio                                 |
 *---------------------------------------------------------------------*/
 
Static Function fMontaPDF()
    Local cCaminho    := ""
    Local cArquivo    := ""
    Local cTexto      :=fCriaTexto()
    //Linhas e colunas
    Private nLinAtu   := 000
    Private nTamLin   := 010
    Private nLinFin   := 820
    Private nColIni   := 010
    Private nColFin   := 550
    Private nColMeio  := (nColFin-nColIni)/2
    Private nEspLin   := 015
    //Vari�veis auxiliares
    Private dDataGer  := Date()
    Private cHoraGer  := Time()
    //Objeto de Impress�o
    Private oPrintPvt
    Private cNomeFont  := "Arial"
    Private oFontDet   := TFont():New(cNomeFont, 9, -11, .T., .F., 5, .T., 5, .T., .F.)
    Private oFontDetN  := TFont():New(cNomeFont, 9, -13, .T., .T., 5, .T., 5, .T., .F.)
    Private oFontDetI  := TFont():New(cNomeFont,  , -11, ,.F.,,,,, .F., .T.)
    Private oFontCabN  := TFont():New(cNomeFont, , -15, , .T.,,,,, .F., .F.)


    //Se for via JOB, muda as parametriza��es
    If lJob
        //Define o caminho dentro da protheus data e o nome do arquivo
        cCaminho := "\x_relatorios\"
        cArquivo := "impPDF_job_" + dToS(dDataGer) + "_" + StrTran(cHoraGer, ':', '-') + ".pdf"
         
        //Se n�o existir a pasta na Protheus Data, cria ela
        If ! ExistDir(cCaminho)
            MakeDir(cCaminho)
        EndIf
         
        //Cria o objeto FWMSPrinter
        oPrintPvt := FWMSPrinter():New(;
            cArquivo,; // cFilePrinter
            IMP_PDF,;  // nDevice
            .F.,;      // lAdjustToLegacy
            '',;       // cPathInServer
            .T.,;      // lDisabeSetup
            .F.,;      // lTReport
            ,;         // oPrintSetup
            ,;         // cPrinter
            .T.,;      // lServer
            .T.,;      // lParam10
            ,;         // lRaw
            .F.;       // lViewPDF
        )
        oPrintPvt:cPathPDF := cCaminho
         
    Else
        //Definindo o diret�rio como a tempor�ria do S.O. e o nome do arquivo com a data e hora (sem dois pontos)
        cCaminho  := GetTempPath()
        cArquivo  := "impPDF_" + dToS(dDataGer) + "_" + StrTran(cHoraGer, ':', '-')
         
        //Criando o objeto do FMSPrinter
        oPrintPvt := FWMSPrinter():New(;
            cArquivo,; // cFilePrinter = Nome do arquivo de relat�rio a ser criado;
            IMP_PDF,;  // nDevice = Tipos de Sa�da aceitos: IMP_SPOOL Envia para impressora. IMP_PDF Gera arquivo PDF � partir do relat�rio. Default � IMP_SPOOL
            .F.,;      // lAdjustToLegacy = Se .T. recalcula as coordenadas para manter o legado de propor��es com a classe TMSPrinter;
            "",;       // cPathInServer = Diret�rio onde o arquivo de relat�rio ser� salvo;
            .T.,;      // lDisabeSetup = Se .T. n�o exibe a tela de Setup;
            ,;         // lTReport = Indica que a classe foi chamada pelo TReport;
            ,;         // oPrintSetup = Objeto FWPrintSetup instanciado pelo usu�rio;
            "",;       // cPrinter = Impressora destino "for�ada" pelo usu�rio. Default � "";
            ,;         // lServer = Indica impress�o via Server (.REL N�o ser� copiado para o Client). Default � .F.
            ,;         // lParam10 = Descontinuado;
            ,;         // lRaw = .T. indica impress�o RAW/PCL, enviando para o dispositivo de impress�o caracteres bin�rios(RAW)
            .T.;       // lViewPDF = Quando o tipo de impress�o for PDF, define se arquivo ser� exibido ap�s a impress�o. O default � .T.
        )
        oPrintPvt:cPathPDF := cCaminho
    EndIf
     
    //Setando os atributos necess�rios do relat�rio
    oPrintPvt:SetResolution(72) // define resolu��o do relat�rio (72, fixo)
    oPrintPvt:SetPortrait()
    oPrintPvt:SetPaperSize(DMPAPER_A4)  // SetPaperSize ( <nPaperSize>, [nHeight], [nWidth] )
    oPrintPvt:SetMargin(60, 60, 60, 60) // SetMargin ( <nLeft>, <nTop>, <nRight>, <nBottom> )
     
    oPrintPvt:StartPage() // Inicializa a p�gina.
    
        //Primeiramente, iremos imprimir o texto alinhado a esquerda
        nLinAtu := 30
        oPrintPvt:SayAlign(nLinAtu, nColIni, "Texto (Esquerda):"                     , oFontDetN,  (nColFin - nColIni), 015, , PAD_LEFT, )
        nLinAtu += 15
        oPrintPvt:SayAlign(nLinAtu, nColIni, cTexto                                  , oFontDet ,  (nColFin - nColIni), 300, , PAD_LEFT, )
        
        nLinAtu += 250
        oPrintPvt:SayAlign(nLinAtu, nColIni + 100, "Dados:"                          , oFontDetN,  200,    015, , PAD_LEFT,  )
        nLinAtu += nEspLin

        oPrintPvt:SayAlign(nLinAtu, nColIni + 100, "Terminal de Informa��o:"         , oFontCabN,  200,    015, , PAD_LEFT,  )
        nLinAtu += nEspLin + 5

        oPrintPvt:SayAlign(nLinAtu, nColIni + 100, "Site:"                           , oFontDetN,  200,    015, , PAD_LEFT,  )
        oPrintPvt:SayAlign(nLinAtu, nColIni + 170, "https://www.globo.com/"          , oFontDet ,  200,    015, , PAD_LEFT,  )
        nLinAtu += nEspLin

        oPrintPvt:SayAlign(nLinAtu, nColIni + 100, "e-Mail:"                         , oFontDetN,  200,    015, , PAD_LEFT,  )
        oPrintPvt:SayAlign(nLinAtu, nColIni + 170, "suporte@globo.com"               , oFontDet ,  200,    015, , PAD_LEFT,  )
        nLinAtu += nEspLin

        oPrintPvt:SayAlign(nLinAtu, nColIni + 100, "WhatsApp:"                       , oFontDetN,  200,    015, , PAD_LEFT,  )
        oPrintPvt:SayAlign(nLinAtu, nColIni + 170, "(11) 9 9738-5495"                , oFontDet ,  200,    015, , PAD_LEFT,  )
        nLinAtu += nEspLin

        oPrintPvt:SayAlign(nLinAtu, nColIni + 100, "Um projeto da *Tabajara Corp*"   , oFontDetI,  200,    015, , PAD_LEFT,  )
        nLinAtu += nEspLin

    oPrintPvt:EndPage() // Finaliza a p�gina.
     
    //Se for via job, imprime o arquivo para gerar corretamente o pdf
    If lJob
        oPrintPvt:Print()

    //Se for via manual, mostra o relat�rio
    Else
        oPrintPvt:Preview()
    EndIf

Return NIL

Static Function fCriaTexto()

    Local cTexto := ""

    cTexto += "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum." + CRLF
    cTexto += "" + CRLF
    cTexto += "Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit" + CRLF
    cTexto += "" + CRLF
    cTexto += ", sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur, vel illum qui dolorem eum fugiat quo voluptas nulla pariatur?" + CRLF
    cTexto += "" + CRLF
    cTexto += "But I must explain to you how all this mistaken idea of denouncing pleasure and praising pain was born and I will give you a complete account of the system, and expound the actual teachings of the great explorer of the truth, the master-builder of human happiness. No one rejects, dislikes, or avoids pleasure itself, because it is pleasure, but because those who do not know how to pursue pleasure rationally encounter consequences that are extremely painful. Nor again is there" + CRLF
    cTexto += "" + CRLF
    cTexto += "anyone who loves or pursues or desires to obtain pain of itself, because it is pain, but because occasionally circumstances occur in which toil and pain can procure him some great pleasure. To take a trivial example, which of us ever undertakes laborious physical exercise, except to obtain some advantage from it? But who has any right to find fault with a man who chooses to enjoy a pleasure that has no annoying consequences, or one who avoids a pain that produces no resultant pleasure?" + CRLF
    cTexto += "" + CRLF
    cTexto += "Sugest�es, Cr�ticas ou outras ideias, podem entrar em contato." + CRLF

Return cTexto
