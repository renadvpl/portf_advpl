#include 'totvs.ch'
#include 'restful.ch'

// Início da criação do SERVIÇO REST
WSRESTFUL WSRESTCLI DESCRIPTION "Serviço REST para manipulação de clientes"

    // Parâmetro utilizado para busca do cliente e para exclusão via método delete
    WSDATA CODCLIENTEDE  AS STRING
    WSDATA CODCLIENTEATE AS STRING

    // Início da criação dos métodos que o meu WEBSERVICE terá
    WSMETHOD GET buscarcliente;
        DESCRIPTION "Retorna dados do cadastro do cliente";
        WSSYNTAX "/buscarcliente";
        PATH "buscarcliente";
        PRODUCES APPLICATION_JSON

    WSMETHOD POST inserircliente;
        DESCRIPTION "Insere dados do cadastro do cliente";
        WSSYNTAX "/inserircliente";
        PATH "inserircliente";
        PRODUCES APPLICATION_JSON

    WSMETHOD PUT atualizarcliente;
        DESCRIPTION "Altera dados do cadastro do cliente";
        WSSYNTAX "/atualizarcliente";
        PATH "atualizarcliente";
        PRODUCES APPLICATION_JSON

    WSMETHOD DELETE apagarcliente;
        DESCRIPTION "Apaga dados do cadastro do cliente";
        WSSYNTAX "/apagarcliente";
        PATH "apagarcliente";
        PRODUCES APPLICATION_JSON

ENDWSRESTFUL

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% GET %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

WSMETHOD GET buscarcliente WSRECEIVE CODCLIENTEDE,CODCLIENTEATE WSREST WSRESTCLI
    
    Local lRet          := .T.
    Local nCount        := 1
    Local nRegistros    := 0
    Local cCodDe        := cValToChar(self:CODCLIENTEDE)
    Local cCodAte       := cValToChar(self:CODCLIENTEATE)
    Local aListClientes := {}
    Local oJson         := JsonObject():New()
    Local cJson         := ""
    
    // Pega um nome de Alias automaticamente para o armazenamento dos dados da QUERY,
    // evitando que fique travado, caso varias pessoas acessem o mesmo Alias.
    Local cAlias := GetNextAlias()
    Local cWhere := " AND SA1.A1_COD BETWEEN '"+cCodDe+"' AND '"+cCodAte+"' AND SA1.A1_FILIAL = '"+xFilial("SA1")+"' " // Armazenara o filtro da QUERY

    If self:CODCLIENTEDE > self:CODCLIENTEATE
        cCodDe  := cValToChar(self:CODCLIENTEATE)
        cCodAte := cValToChar(self:CODCLIENTEDE)
    EndIf
    
    cWhere := "%"+cWhere+"%"

    BeginSQL Alias cAlias
        SELECT
            SA1.A1_COD,    SA1.A1_LOJA,
            SA1.A1_NOME,   SA1.A1_NREDUZ,
            SA1.A1_END,    SA1.A1_EST,
            SA1.A1_BAIRRO, SA1.A1_MUN,
            SA1.A1_CGC
        FROM %table:SA1% SA1
        WHERE SA1.%notDel%
        %exp:cWhere%
    EndSQL

    Count To nRegistros

    (cAlias)->(dbGoTop())

    While (cAlias)->(!EoF())
        aAdd(aListClientes,JsonObject():New())
        aListClientes[nCount]['clicod']   := (cAlias)->A1_COD
        aListClientes[nCount]['cliloja']  := (cAlias)->A1_LOJA
        aListClientes[nCount]['clinome']  := AllTrim(EncodeUTF8((cAlias)->A1_NOME))
        aListClientes[nCount]['clinred']  := AllTrim(EncodeUTF8((cAlias)->A1_NREDUZ))
        aListClientes[nCount]['clinred']  := AllTrim(EncodeUTF8((cAlias)->A1_END))
        aListClientes[nCount]['cliest']   := (cAlias)->A1_EST
        aListClientes[nCount]['climun']   := (cAlias)->A1_MUN
        aListClientes[nCount]['clibai']   := (cAlias)->A1_BAIRRO
        aListClientes[nCount]['clicgc']   := (cAlias)->A1_CGC

        nCount++
        (cAlias)->(dbSkip())
    EndDo

    (cAlias)->(dbCloseArea())

    If nRegistros > 0
        oJson['clientes'] := aListClientes
        cJson:= FWJsonSerialize(oJson)
        ::SetResponse(cJson)
    Else
        SetRestFault(400,EncodeUTF8("Não existem registros de clientes para o filtro informados. Por favor, verifique e tente novamente."))
        lRet := .F.
        Return (lRet)
    EndIf

    FreeObj(oJson)

RETURN lRet

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% POST %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

WSMETHOD POST inserircliente WSRECEIVE WSREST WSRESTCLI
    
    Local lRet          := .T.
    Local aArea         := GetArea()
    Local oJson         := JsonObject():New()
    Local oReturn       := JsonObject():New()

    oJson:FromJson(Self:GetContent())

    If Empty(oJson['clientes']:GetJsonObject('clicod')) .OR. Empty(oJson['clientes']:GetJsonObject('cliloja'))
        SetRestFault(400,EncodeUTF8("Código do cliente ou da loja está em branco."))
        lRet := .F.
        Return(lRet)
    Else // Se não estiverem 'em branco', realiza a busca e verifica se o cliente já existe
        dbSelectArea("SA1")
        SA1->(dbSetOrder(1))

        If SA1->(dbSeek(xFilial('SA1')+AllTrim(oJson['clientes']:GetJsonObject('clicod'))+AllTrim(oJson['clientes']:GetJsonObject('cliloja'))))
            SetRestFault(401,EncodeUTF8("Código do produto já existe na base de dados."))
            lRet := .F.
            Return(lRet)
        ElseIf Empty(oJson['clientes']:GetJsonObject('clinome'))
            SetRestFault(402,EncodeUTF8("Nome do cliente está em branco."))
            lRet := .F.
            Return(lRet)
        ElseIf Empty(oJson['clientes']:GetJsonObject('clinred'))
            SetRestFault(403,EncodeUTF8("Nome reduzido do cliente está em branco."))
            lRet := .F.
            Return(lRet)
        ElseIf Empty(oJson['clientes']:GetJsonObject('cliend'))
            SetRestFault(404,EncodeUTF8("Endereço do cliente está em branco."))
            lRet := .F.
            Return(lRet)
        ElseIf Empty(oJson['clientes']:GetJsonObject('cliest'))
            SetRestFault(405,EncodeUTF8("Estado (UF) do cliente está em branco."))
            lRet := .F.
            Return(lRet)
        ElseIf Empty(oJson['clientes']:GetJsonObject('climun'))
            SetRestFault(406,EncodeUTF8("Cidade do cliente está em branco."))
            lRet := .F.
            Return(lRet)
        ElseIf Empty(oJson['clientes']:GetJsonObject('clibai'))
            SetRestFault(407,EncodeUTF8("Bairro do cliente está em branco."))
            lRet := .F.
            Return(lRet)
        ElseIf Empty(oJson['clientes']:GetJsonObject('clicgc'))
            SetRestFault(408,EncodeUTF8("CGC/CPF do cliente está em branco."))
            lRet := .F.
            Return(lRet)
        Else
            RecLock("SA1",.T.)
                SA1->A1_COD    := oJson['clientes']:GetJsonObject('clicod')
                SA1->A1_LOJA   := oJson['clientes']:GetJsonObject('cliloja')
                SA1->A1_NOME   := oJson['clientes']:GetJsonObject('clinome')
                SA1->A1_NREDUZ := oJson['clientes']:GetJsonObject('clinred')
                SA1->A1_END    := oJson['clientes']:GetJsonObject('cliend')
                SA1->A1_EST    := oJson['clientes']:GetJsonObject('cliest')
                SA1->A1_MUN    := oJson['clientes']:GetJsonObject('climun')
                SA1->A1_BAIRRO := oJson['clientes']:GetJsonObject('clibai')
                SA1->A1_CGC    := oJson['clientes']:GetJsonObject('clicgc')
                SA1->A1_MSBLQL := '1'
            SA1->(MSUnlock())
        EndIf
        
        SA1->(dbCloseArea())

        oReturn['clicod']   := oJson['clientes']:GetJsonObject('clicod')
        oReturn['cliloja']  := oJson['clientes']:GetJsonObject('cliloja')
        oReturn['clinome']  := oJson['clientes']:GetJsonObject('clinome')
        oReturn['cRet']     := "201 - Sucesso!"
        oReturn['cMessage'] := EncodeUTF8("Cliente incluído com sucesso na base de dados.")

        Self:SetStatus(201)
        Self:SetContentType(APPLICATION_JSON)
        Self:SetResponse(FWJsonSerialize(oReturn))
    EndIf

    RestArea(aArea)
    FreeObj(oJson)
    FreeObj(oReturn)

RETURN lRet

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PUT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

WSMETHOD PUT atualizarcliente WSRECEIVE WSREST WSRESTCLI
    
    Local lRet          := .T.
    Local aArea         := GetArea()
    Local oJson         := JsonObject():New()
    Local oReturn       := JsonObject():New()

    oJson:FromJson(Self:GetContent())

    If Empty(oJson['clientes']:GetJsonObject('clicod')) .OR. Empty(oJson['clientes']:GetJsonObject('cliloja'))
        SetRestFault(400,EncodeUTF8("Código do cliente ou da loja está em branco."))
        lRet := .F.
        Return(lRet)
    Else // Se não estiverem 'em branco', realiza a busca e verifica se o cliente já existe
        dbSelectArea("SA1")
        SA1->(dbSetOrder(1))

        If !SA1->(dbSeek(xFilial('SA1')+AllTrim(oJson['clientes']:GetJsonObject('clicod'))+AllTrim(oJson['clientes']:GetJsonObject('cliloja'))))
            SetRestFault(401,EncodeUTF8("Código/loja do cliente não existe na base de dados."))
            lRet := .F.
            Return(lRet)
        ElseIf Empty(oJson['clientes']:GetJsonObject('clinome'))
            SetRestFault(402,EncodeUTF8("Nome do cliente está em branco."))
            lRet := .F.
            Return(lRet)
        ElseIf Empty(oJson['clientes']:GetJsonObject('clinred'))
            SetRestFault(403,EncodeUTF8("Nome reduzido do cliente está em branco."))
            lRet := .F.
            Return(lRet)
        ElseIf Empty(oJson['clientes']:GetJsonObject('cliend'))
            SetRestFault(404,EncodeUTF8("Endereço do cliente está em branco."))
            lRet := .F.
            Return(lRet)
        ElseIf Empty(oJson['clientes']:GetJsonObject('cliest'))
            SetRestFault(405,EncodeUTF8("Estado (UF) do cliente está em branco."))
            lRet := .F.
            Return(lRet)
        ElseIf Empty(oJson['clientes']:GetJsonObject('climun'))
            SetRestFault(406,EncodeUTF8("Cidade do cliente está em branco."))
            lRet := .F.
            Return(lRet)
        ElseIf Empty(oJson['clientes']:GetJsonObject('clibai'))
            SetRestFault(407,EncodeUTF8("Bairro do cliente está em branco."))
            lRet := .F.
            Return(lRet)
        ElseIf Empty(oJson['clientes']:GetJsonObject('clicgc'))
            SetRestFault(408,EncodeUTF8("CGC/CPF do cliente está em branco."))
            lRet := .F.
            Return(lRet)
        Else
            RecLock("SA1",.F.)
                SA1->A1_NOME   := oJson['clientes']:GetJsonObject('clinome')
                SA1->A1_NREDUZ := oJson['clientes']:GetJsonObject('clinred')
                SA1->A1_END    := oJson['clientes']:GetJsonObject('cliend')
                SA1->A1_EST    := oJson['clientes']:GetJsonObject('cliest')
                SA1->A1_MUN    := oJson['clientes']:GetJsonObject('climun')
                SA1->A1_BAIRRO := oJson['clientes']:GetJsonObject('clibai')
                SA1->A1_CGC    := oJson['clientes']:GetJsonObject('clicgc')
            SA1->(MSUnlock())
        EndIf
        
        SA1->(dbCloseArea())

        oReturn['clicod']   := oJson['clientes']:GetJsonObject('clicod')
        oReturn['cliloja']  := oJson['clientes']:GetJsonObject('cliloja')
        oReturn['clinome']  := oJson['clientes']:GetJsonObject('clinome')
        oReturn['cRet']     := "201 - Sucesso!"
        oReturn['cMessage'] := EncodeUTF8("Registro alterado com sucesso na base de dados.")

        Self:SetStatus(201)
        Self:SetContentType(APPLICATION_JSON)
        Self:SetResponse(FWJsonSerialize(oReturn))
    EndIf

    RestArea(aArea)
    FreeObj(oJson)
    FreeObj(oReturn)

RETURN lRet

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% DELETE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

WSMETHOD DELETE apagarcliente WSRECEIVE CODCLIENTEDE,CODCLIENTEATE WSREST WSRESTCLI

    Local lRet    := .T.
    Local cCodDe  := self:CODCLIENTEDE
    Local cCodAte := self:CODCLIENTEATE  
    Local aArea   := GetArea()
    Local oReturn := JsonObject():New()
    Local nCount := 0

    If self:CODCLIENTEDE > self:CODCLIENTEATE
        cCodDe  := cValToChar(self:CODCLIENTEATE)
        cCodAte := cValToChar(self:CODCLIENTEDE)
    EndIf

    dbSelectArea("SA1")
    SA1->(dbSetOrder(1))
    SA1->(dbGoTop())

    While SA1->(!EoF()) .and. (SA1->A1_COD >= cCodDe .and. SA1->A1_COD <= cCodAte)
    
        If SA1->(dbSeek(xFilial('SA1')+SA1->A1_COD))
            RecLock('SA1',.F.)
                dbDelete()
            SA1->(MSUnlock())
            nCount++
        EndIf
        SA1->(dbSkip())

    EndDo

    SA1->(dbCloseArea())

    If nCount = 1
        oReturn['clidelet'] := "Foi deletado um registro do banco de dados."
        oReturn['cRet']     := '201 - Sucesso!'
        oReturn['cMessage'] := EncodeUTF8('Registro excluído com sucesso.')
        
        Self:SetStatus(201)
        Self:SetContentType(APPLICATION_JSON)
        Self:SetResponse(FWJsonSerialize(oReturn))

    ElseIf nCount > 1
        oReturn['clidelet'] := "Foram deletados "+cValToChar(nCount)+" registros do banco de dados."
        oReturn['cRet']     := '201 - Sucesso!'
        oReturn['cMessage'] := EncodeUTF8('Registros excluídos com sucesso.')

        Self:SetStatus(201)
        Self:SetContentType(APPLICATION_JSON)
        Self:SetResponse(FWJsonSerialize(oReturn))
    Else
        SetRestFault(401,EncodeUTF8("Não foram encontrados registros filtrados para deleção."))
        lRet := .F.
        Return(lRet)
    EndIf

    RestArea(aArea)

    FreeObj(oReturn)

RETURN (lRet)

/*
{
"clientes":
    {
        "clicod": "000011"
        "cliloja": "01"
        "clinome": "CLIENTE TESTE REST"
        "clinred": "CLI0011"
        "cliend": "AVENIDA DOS RESTS"
        "cliest": "SP"
        "climun": "SÃO PAULO"
        "clibai": "WEBSERVICES"
        "clicgc": "00022255588"
    }
}
*/
