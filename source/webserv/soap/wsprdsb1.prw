#include "protheus.ch"
#include "apwebsrv.ch"
#include "topconn.ch"

//CÓDIGO, DESCRIÇÃO, UNIDADE DE MEDIDA, TIPO, NCM E GRUPO

WSSTRUCT STProduto

    WSDATA produtoB1COD    AS STRING OPTIONAL
    WSDATA produtoB1DESC   AS STRING OPTIONAL
    WSDATA produtoB1UM     AS STRING OPTIONAL
    WSDATA produtoB1TIPO   AS STRING OPTIONAL
    WSDATA produtoB1POSIPI AS STRING OPTIONAL
    WSDATA produtoB1GRUPO  AS STRING OPTIONAL

ENDWSSTRUCT

WSSTRUCT STProdVenda

    WSDATA produtoCodigo    AS STRING  OPTIONAL
    WSDATA produtoDescricao AS STRING  OPTIONAL
    WSDATA produtoQtdTotal  AS INTEGER OPTIONAL
    WSDATA produtoVlrTotal  AS FLOAT   OPTIONAL

    WSDATA cRet     AS STRING OPTIONAL
    WSDATA cMessage AS STRING OPTIONAL

ENDWSSTRUCT

WSSTRUCT STRetMsgProd
    WSDATA cRet     AS STRING OPTIONAL
    WSDATA cMessage AS STRING OPTIONAL
ENDWSSTRUCT

WSSTRUCT STRetGerProd
    WSDATA WSBuscaProd AS STProduto
    WSDATA WSRetMsg    AS STRetMsgProd
ENDWSSTRUCT

WSSERVICE WSPRDSB1 DESCRIPTION "Serviço para retornar os dados de um produto específico da Empresa"

    WSDATA _cCodProduto   AS STRING // Parâmetro de entrada
    WSDATA wsRetornoGeral AS STRetGerProd // Parâmetro de retorno
    WSDATA wsBuscaProdVen AS STProdVenda
    WSMETHOD BuscaProduto DESCRIPTION "Busca produtos da tabela SB1 com base no código."
    WSMETHOD BuscaProdVen DESCRIPTION "Busca quantidade de produtos vendidos e total de venda."

ENDWSSERVICE

WSMETHOD BuscaProduto WSRECEIVE _cCodProduto WSSEND wsRetornoGeral WSSERViCE WSPRDSB1

    Local cCodProduto := ::_cCodProduto
    dbSelectArea("SB1")
    SB1->(dbSetOrder(1))

    If SB1->(dbSeek(xFilial("SB1")+cCodProduto))

        ::WSRetornoGeral:WSRetMsg:cRet                := "[T]"
        ::WSRetornoGeral:WSRetMsg:cMessage            := "Sucesso! O produto foi encontrado."

        ::WSRetornoGeral:WSBuscaProd:produtoB1COD     := SB1->B1_COD
        ::WSRetornoGeral:WSBuscaProd:produtoB1DESC    := SB1->B1_DESC
        ::WSRetornoGeral:WSBuscaProd:produtoB1UM      := SB1->B1_UM
        ::WSRetornoGeral:WSBuscaProd:produtoB1TIPO    := SB1->B1_TIPO
        ::WSRetornoGeral:WSBuscaProd:produtoB1POSIPI  := SB1->B1_POSIPI
        ::WSRetornoGeral:WSBuscaProd:produtoB1GRUPO   := POSICIONE("SBM",1,xFilial("SBM")+SB1->B1_GRUPO,"BM_DESC")
    
    Else
        ::WSRetornoGeral:WSRetMsg:cRet                := "[F]"
        ::WSRetornoGeral:WSRetMsg:cMessage            := "Falha! O produto não foi encontrado."        
    
    EndIf
    
    SB1->(dbCloseArea())
    
RETURN .T.

WSMETHOD BuscaProdVen WSRECEIVE _cCodProduto WSSEND wsBuscaProdVen WSSERViCE WSPRDSB1

    Local cCodProduto := ::_cCodProduto
    Local nQtdVend := 0
    Local nTotVend := 0

    dbSelectArea("SD2")
    SD2->(dbSetOrder(1))
    SD2->(dbSeek(xFilial("SD2")+cCodProduto))

    While SD2->(!EoF()) .and. SD2->D2_COD = cCodProduto
        // Vai incrementar os totais dentro dessas variaveis
        nQtdVend += SD2->D2_QUANT
        nTotVend += SD2->D2_TOTAL

        SD2->(dbSkip())
    EndDo

    SD2->(dbCloseArea())

    If nQtdVend > 0
        ::wsBuscaProdVen:cRet             := "[T]"
        ::wsBuscaProdVen:cMessage         := "Sucesso! O produto vendido foi encontrado."

        ::wsBuscaProdVen:produtoCodigo    := cCodProduto
        ::wsBuscaProdVen:produtoDescricao := POSICIONE("SB1",1,xFilial("SB1")+cCodProduto,"B1_DESC")
        ::wsBuscaProdVen:produtoQtdTotal  := nQtdVend
        ::wsBuscaProdVen:produtoVlrTotal  := nTotVend
    Else
        ::wsBuscaProdVen:cRet             := "[F]"
        ::wsBuscaProdVen:cMessage         := "Falha! O produto vendido NÃO foi encontrado."
    EndIf

RETURN .T.
