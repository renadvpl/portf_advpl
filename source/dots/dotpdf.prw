//Bibliotecas
#Include "TOTVS.ch"

/*
%%%%%%%%%%%%%%%% {Protheus.doc} User Function IMPDOT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%    @Desc    Geração de relatório com modelo DOT do Word com exportação para PDF     %%
%%    @Func    IMPDOT                                                                  %%
%%    @Author  Renato Silva                                                            %%
%%    @Since   19/04/2023                                                              %%
%%    @Obs:    https://tdn.totvs.com/display/public/framework/OLE_CreateLink           %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
*/
User Function DOTPDF()

    Local aArea     := FWGetArea()
    Local aPergs    := {}
	Local cProduto  := Space(06)
    
    //Adicionando os parametros do ParamBox
    aAdd(aPergs, {1, "Produto",  cProduto,  "", ".T.", "SB1", ".T.", 80,  .F.})
    
    //Se a pergunta for confirma, cria as definicoes do relatorio
    If ParamBox(aPergs, "Informe os parâmetros", , , , , , , , , .F., .F.)
        Processa({|| fMontaPDF()}, "Processando...")
    EndIf
     
    FWRestArea(aArea)

Return NIL


Static Function fMontaPDF()

    Local nHandWord  := 0
    Local cPastaTmp  := "C:\Temp\" //GetTempPath()
    Local cArqOrigi  := "\dots\produto.dotx"
    Local cArqLocal  := cPastaTmp + "produtos.dotx"
    Local cArqPDF    := cPastaTmp + "produtos.pdf"

    dbSelectArea("SB1")
    SB1->( dbSetOrder(1) )

    If SB1->( MsSeek(FWxFilial("SB1") + MV_PAR01) )

        //Copia o dot do servidor para a máquina local
        __CopyFile(cArqOrigi, cArqLocal)

        //Cria um ponteiro e já chama o arquivo
        nHandWord := OLE_CreateLink()
        OLE_NewFile(nHandWord, cArqLocal)
        
        //Setando o conteúdo das DocVariables
        OLE_SetDocumentVar( nHandWord, "CodProduto" , Alltrim(SB1->B1_COD) )
        OLE_SetDocumentVar( nHandWord, "DescProduto", Alltrim(SB1->B1_DESC) )
        OLE_SetDocumentVar( nHandWord, "UnidProduto", Alltrim(SB1->B1_UM) )
        OLE_SetDocumentVar( nHandWord, "DataGeracao", DtoC(Date()) )
        OLE_SetDocumentVar( nHandWord, "HoraGeracao", Time() )
        
        //Atualizando campos
        OLE_UpdateFields(nHandWord)
        
        //Gera o PDF do documento
        OLE_SetProperty(nHandWord,'208',.F.)
        OLE_SaveAsFile( nHandWord, cArqPDF, , , .F., 17 )

        //Fechando o arquivo e o link
        OLE_CloseFile(nHandWord)
        Sleep(1000)
        OLE_CloseLink(nHandWord)

        //Abre o PDF
        ShellExecute("OPEN", cArqPDF, "", cPastaTmp, 1 )

    Else
        FWAlertError("Produto não encontrado!", "Falha")
    EndIf

Return NIL
