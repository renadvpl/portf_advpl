#include "protheus.ch"
#include "apwebsrv.ch"
#include "topconn.ch"

//CÓDIGO, NOME, CPF, ENDEREÇO, BAIRRO, ESTADO E CEP

/*ESTRUTURA DE DADOS QUE RETORNARÁ PELO WEBSERVICE NA CHAMADA PELO CLIENTE*/

WSSTRUCT STCliente

    WSDATA clienteA1COD    AS STRING OPTIONAL
    WSDATA clienteA1LOJA   AS STRING OPTIONAL
    WSDATA clienteA1NOME   AS STRING OPTIONAL
    WSDATA clienteA1CPF    AS STRING OPTIONAL
    WSDATA clienteA1END    AS STRING OPTIONAL
    WSDATA clienteA1BAIRRO AS STRING OPTIONAL
    WSDATA clienteA1MUNIC  AS STRING OPTIONAL
    WSDATA clienteA1ESTADO AS STRING OPTIONAL
    WSDATA clienteA1CEP    AS STRING OPTIONAL

ENDWSSTRUCT

WSSTRUCT STRetMsg
    WSDATA cRet     AS STRING OPTIONAL
    WSDATA cMessage AS STRING OPTIONAL
ENDWSSTRUCT

WSSTRUCT STRetornoGeral
    WSDATA WSSTClient AS STCliente
    WSDATA WSSTRetMsg AS STRetMsg
ENDWSSTRUCT

WSSERVICE WSCLISA1 DESCRIPTION "Serviço para retornar os dados de cliente específico da Empresa"

    // Código que será requisitado pelo método de busca do cliente.
    WSDATA _cCodClienteLoja AS STRING

    // Chamada da estrutura de retorno que será retornada pelo método.
    WSDATA WSRetornoGeral AS STRetornoGeral

    // Chamada da estrutura de entrada e retorno de inclusão de cliente.
    WSDATA WSDadosCli   AS STCliente
    WSDATA WSRetInclui  AS STRetMsg
    WSDATA cToken       AS STRING

    WSMETHOD BuscaCliente DESCRIPTION "Busca clientes da tabela SA1 com base no código e loja."
    WSMETHOD IncluiCliente DESCRIPTION "Inclusão de clientes na tabela SA1 da base de dados."    

ENDWSSERVICE

//       Método       Parâmetro de Entrada       Retorno do WS         WS a qual pertence
WSMETHOD BuscaCliente WSRECEIVE _cCodClienteLoja WSSEND WSRetornoGeral WSSERVICE WSCLISA1
    Local cCliCodLoja := ::_cCodClienteLoja

    dbSelectArea("SA1")
    SA1->(dbSetOrder(1))
    
    // Se ele encontrar, popula a estrutura de dados WSSTRUCT STCliente através do WSRetornoGeral
    If SA1->(dbSeek(xFilial("SA1")+cCliCodLoja))

        ::WSRetornoGeral:WSSTRetMsg:cRet     := "[T]"
        ::WSRetornoGeral:WSSTRetMsg:cMessage := "Sucesso! Regsitro encontrado, os dados estão listados."

        ::WSRetornoGeral:WSSTClient:clienteA1COD    := SA1->A1_COD
        ::WSRetornoGeral:WSSTClient:clienteA1LOJA   := SA1->A1_LOJA
        ::WSRetornoGeral:WSSTClient:clienteA1NOME   := SA1->A1_NOME
        ::WSRetornoGeral:WSSTClient:clienteA1CPF    := SA1->A1_CGC
        ::WSRetornoGeral:WSSTClient:clienteA1END    := SA1->A1_END
        ::WSRetornoGeral:WSSTClient:clienteA1BAIRRO := SA1->A1_BAIRRO
        ::WSRetornoGeral:WSSTClient:clienteA1MUNIC  := SA1->A1_MUN
        ::WSRetornoGeral:WSSTClient:clienteA1ESTADO := SA1->A1_EST
        ::WSRetornoGeral:WSSTClient:clienteA1CEP    := SA1->A1_CEP
    else
        ::WSRetornoGeral:WSSTRetMsg:cRet     := "[F]"
        ::WSRetornoGeral:WSSTRetMsg:cMessage := "Dados não encontrados com parâmetro passado."
    EndIf

    SA1->(dbCloseArea())

RETURN .T.

WSMETHOD IncluiCliente WSRECEIVE cToken, wsDadosCli WSSEND WSRetInclui WSSERVICE WSCLISA1
    
    Local cTokenDefault := '#euamoADVPL'
    
    // Capturamos os dados que estão sendo enviados e jogamos em variáveis
    Local cA1COD := StrTran(::wsDadosCli:clienteA1COD,"?","")
    Local cA1LOJ := StrTran(::wsDadosCli:clienteA1LOJA,"?","")
    Local cA1NOM := StrTran(::wsDadosCli:clienteA1NOME,"?","")
    Local cA1CPF := StrTran(::wsDadosCli:clienteA1CPF,"?","")
    Local cA1END := StrTran(::wsDadosCli:clienteA1END,"?","")
    Local cA1BAI := StrTran(::wsDadosCli:clienteA1BAIRRO,"?","")
    Local cA1MUN := StrTran(::wsDadosCli:clienteA1MUNIC,"?","")
    Local cA1EST := StrTran(::wsDadosCli:clienteA1ESTADO,"?","")
    Local cA1CEP := StrTran(::wsDadosCli:clienteA1CEP,"?","")

    If Empty(::cToken)
        SetSoapFault('Token não informado','Operação não permitida!')
        RETURN .F.
    ElseIf cTokenDefault <> ::cToken
        SetSoapFault('Token inválido, informe o token correto','Operação não permitida!')
        RETURN .F.
    Else
        dbSelectArea("SA1")
        SA1->(dbSetOrder(1))

        If Empty(cA1COD) .OR. Empty(cA1LOJ) .OR. Empty(cA1NOM) .OR. Empty(cA1CPF) .OR. Empty(cA1END) .OR. Empty(cA1BAI) .OR. Empty(cA1MUN) .OR. Empty(cA1EST) .OR. Empty(cA1CEP)
            ::WSRetInclui:cRet     := "902"
            ::WSRetInclui:cMessage := "Operação não permitida! Existem dados vazios. Todos os campos são obrigatórios."
        ElseIf SA1->(dbSeek(FWxFilial('SA1')+cA1COD+cA1LOJ))
            ::WSRetInclui:cRet     := "901"
            ::WSRetInclui:cMessage := "Operação não permitida! O cliente/loja já existe no banco de dados."
        Else
            RecLock('SA1',.T.)
                SA1->A1_COD    := cA1COD
                SA1->A1_LOJA   := cA1LOJ
                SA1->A1_NOME   := cA1NOM
                SA1->A1_CGC    := cA1CPF
                SA1->A1_END    := cA1END
                SA1->A1_BAIRRO := cA1BAI
                SA1->A1_MUN    := cA1MUN
                SA1->A1_EST    := cA1EST
                SA1->A1_CEP    := cA1CEP
            SA1->(MSUnlock())

            ::WSRetInclui:cRet     := "903"
            ::WSRetInclui:cMessage := "Operação concluída com sucesso! Seus dados foram enviados para o banco de dados do Protheus."
        EndIf
        SA1->(dbCloseArea())
    
    EndIf
    
RETURN .T.
