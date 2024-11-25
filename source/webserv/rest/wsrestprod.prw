#include 'totvs.ch'
#include 'restful.ch'

// Início da criação do SERVIÇO REST
WSRESTFUL WSRESTPROD DESCRIPTION "Serviço REST para manipulação de produtos"

    // Parâmetro utilizado para busca do produto e para exclusão via método delete
    WSDATA CODPRODUTO AS STRING

    // Início da criação dos métodos que o meu WEBSERVICE terá
    WSMETHOD GET buscarproduto DESCRIPTION "Retorna dados do cadastro do produto" WSSYNTAX "/buscarproduto" PATH "buscarproduto" PRODUCES APPLICATION_JSON

    WSMETHOD POST inserirproduto DESCRIPTION "Insere dados do cadastro do produto" WSSYNTAX "/inserirproduto" PATH "inserirproduto" PRODUCES APPLICATION_JSON

    WSMETHOD PUT alterarproduto DESCRIPTION "Altera dados do cadastro do produto" WSSYNTAX "/alterarproduto" PATH "alterarproduto" PRODUCES APPLICATION_JSON

    WSMETHOD DELETE apagarproduto DESCRIPTION "Apaga dados do cadastro do produto" WSSYNTAX "/apagarproduto" PATH "apagarproduto" PRODUCES APPLICATION_JSON

END WSRESTFUL

// %%%%%%%%%%%% Construção de método GET para trazer dados da tabela SB1 %%%%%%%%%%%%%%%%%%%%%%%%%%

WSMETHOD GET buscarproduto WSRECEIVE CODPRODUTO WSREST WSRESTPROD

    Local lRet := .T. // Variável lógica de retorno do método

    // Recuperamos o produto que está sendo utilizado na URL/PARAMETRO
    Local cCodProd := self:CODPRODUTO
    Local aArea := GetArea()
    Local oJson := JsonObject():New() // Instanciando a classe
    Local cJson := ""
    Local aProd := {} // Array que receberá os dados e transformados em JSON
    Local oReturn // Caso o produto não seja encontrado, retorna uma mensagem de erro.
    Local cReturn // Retorno de sucesso adicional

    /* O objetivo é trazer do banco de dados, os campos: Código, Descrição, Unidade, NCM, Grupo e Bloqueio*/

    Local cStatus := ""
    Local cGrupo := ""

    dbSelectArea("SB1")
    SB1->(dbSetOrder(1))

    If SB1->(dbSeek(xFilial('SB1')+cCodProd))
        cStatus := IIf(SB1->B1_MSBLQL == '1','Bloqueado','Desbloqueado')
        cGrupo := Posicione('SBM',1,xFilial('SBM')+SB1->B1_GRUPO,'BM_DESC')

        aAdd(aProd,JsonObject():New()) // Passo o array para estrutura JSON
        // Como só tenho uma linha, pois somente podem existir um produto com mesmo código,
        // logo coloco 1 na posição do índice do array
        aProd[1]['prodcod']    := AllTrim(SB1->B1_COD)
        aProd[1]['proddesc']   := AllTrim(SB1->B1_DESC)
        aProd[1]['produm']     := AllTrim(SB1->B1_UM)
        aProd[1]['prodtipo']   := AllTrim(SB1->B1_TIPO)
        aProd[1]['prodncm']    := AllTrim(SB1->B1_POSIPI)
        aProd[1]['prodgrupo']  := cGrupo
        aProd[1]['prodstatus'] := cStatus

        oReturn := JsonObject():New()
        oReturn['cRet'] := "200"
        oReturn['cMessage'] := EncodeUTF8("Código do produto encontrado com êxito na base de dados.")
        cReturn := FWJsonSerialize(oReturn)

        oJson['produtos'] := aProd // Passo para JSON com Cabeçalho e Itens que são os campos da SB1

        // Serialização do JSON, transformando o retorno de itens em JSON através do FWJSONSerialize.
        cJson := FWJsonSerialize(oJson)

        ::SetResponse(cJson)
        ::SetResponse(cReturn)
    Else
        SetRestFault(400,EncodeUTF8("Código do produto não encontrado na base de dados."))
        lRet := .F.
        Return(lRet)
    EndIf   

    SB1->(dbCloseArea())
    RestArea(aArea)
    
    FreeObj(oJson)
    FreeObj(oReturn)

RETURN(lRet)

// %%%%%%%%%%%%% Construção de método POST para trazer dados da tabela SB1 %%%%%%%%%%%%%%%%%%%%%%%%%

WSMETHOD POST inserirproduto WSRECEIVE WSREST WSRESTPROD

    Local lRet    := .T.
    Local aArea   := GetArea()
    Local oJson   := JsonObject():New() // Instanciando a classe
    Local oReturn := JsonObject():New()

    oJson:FromJson(self:GetContent())

    If Empty(oJson['produtos']:GetJsonObject('prodcod'))
        SetRestFault(400,EncodeUTF8("Código do produto está em branco."))
        lRet := .F.
        Return(lRet)
    Else
        dbSelectArea("SB1")
        SB1->(dbSetOrder(1))

        If SB1->(dbSeek(xFilial('SB1')+AllTrim(oJson['produtos']:GetJsonObject('prodcod'))))
            SetRestFault(401,EncodeUTF8("Código do produto já existe na base de dados."))
            lRet := .F.
            Return(lRet)
        ElseIf Empty(oJson['produtos']:GetJsonObject('proddesc'))
            SetRestFault(402,EncodeUTF8("Descrição do produto está em branco."))
            lRet := .F.
            Return(lRet)
        ElseIf Empty(oJson['produtos']:GetJsonObject('produm'))
            SetRestFault(403,EncodeUTF8("Unidade de medida está em branco."))
            lRet := .F.
            Return(lRet)
        ElseIf Empty(oJson['produtos']:GetJsonObject('prodgrupo'))
            SetRestFault(404,EncodeUTF8("Grupo do produto está em branco."))
            lRet := .F.
            Return(lRet)
        ElseIf !SBM->(DbSeek(xFilial("SBM")+AllTrim(oJson["produtos"]:GetJsonObject("prodgrupo"))))  
            SetRestFault(405,EncodeUTF8("Grupo Inválido | Insira um código de grupo existente!")) //Setando um erro
            lRet := .F.
            Return(lRet)
        ElseIf Empty(oJson['produtos']:GetJsonObject('prodtipo'))
            SetRestFault(406,EncodeUTF8("Tipo do produto está em branco."))
            lRet := .F.
            Return(lRet)
        Else
            RecLock('SB1',.T.)
                SB1->B1_COD    := oJson['produtos']:GetJsonObject('prodcod')
                SB1->B1_DESC   := oJson['produtos']:GetJsonObject('proddesc')
                SB1->B1_UM     := oJson['produtos']:GetJsonObject('produm')
                SB1->B1_TIPO   := oJson['produtos']:GetJsonObject('prodtipo')
                SB1->B1_GRUPO  := oJson['produtos']:GetJsonObject('prodgrupo')
                SB1->B1_MSBLQL := '1'
            SB1->(MSUnlock())
            SB1->(dbCloseArea())

            oReturn['prodcod']  := oJson['produtos']:GetJsonObject('prodcod')
            oReturn['proddesc'] := oJson['produtos']:GetJsonObject('proddesc')
            oReturn['cRet']     := '201 - Sucesso!'
            oReturn['cMessage'] := 'Registro inserido na base de dados.'

            Self:SetStatus(201)
            Self:SetContentType(APPLICATION_JSON)
            Self:SetResponse(FWJsonSerialize(oReturn))

        EndIf
    EndIf

    RestArea(aArea)
    FreeObj(oJson)
    FreeObj(oReturn)
    
RETURN (lRet)

// %%%%%%%% Construção de método PUT para trazer dados da tabela SB1 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

WSMETHOD PUT alterarproduto WSRECEIVE WSREST WSRESTPROD

    Local lRet    := .T.
    Local aArea   := GetArea()
    Local oJson   := JsonObject():New() // Instanciando a classe
    Local oReturn := JsonObject():New()

    oJson:FromJson(self:GetContent())

    If Empty(oJson['produtos']:GetJsonObject('prodcod'))
        SetRestFault(400,EncodeUTF8("Código do produto está em branco."))
        lRet := .F.
        Return(lRet)
    Else
        dbSelectArea("SB1")
        SB1->(dbSetOrder(1))

        If !SB1->(dbSeek(xFilial('SB1')+AllTrim(oJson['produtos']:GetJsonObject('prodcod'))))
            SetRestFault(401,EncodeUTF8("Código do produto não existe na base de dados."))
            lRet := .F.
            Return(lRet)
        ElseIf Empty(oJson['produtos']:GetJsonObject('proddesc'))
            SetRestFault(402,EncodeUTF8("Descrição do produto está em branco."))
            lRet := .F.
            Return(lRet)
        ElseIf Empty(oJson['produtos']:GetJsonObject('produm'))
            SetRestFault(403,EncodeUTF8("Unidade de medida está em branco."))
            lRet := .F.
            Return(lRet)
        ElseIf Empty(oJson['produtos']:GetJsonObject('prodgrupo'))
            SetRestFault(404,EncodeUTF8("Grupo do produto está em branco."))
            lRet := .F.
            Return(lRet)
        ElseIf !SBM->(DbSeek(xFilial("SBM")+AllTrim(oJson["produtos"]:GetJsonObject("prodgrupo"))))  
            SetRestFault(405,EncodeUTF8("Grupo Inválido | Insira um código de grupo existente!")) //Setando um erro
            lRet := .F.
            Return(lRet)
        ElseIf Empty(oJson['produtos']:GetJsonObject('prodtipo'))
            SetRestFault(406,EncodeUTF8("Tipo do produto está em branco."))
            lRet := .F.
            Return(lRet)
        Else
            RecLock('SB1',.F.)
                SB1->B1_DESC   := oJson['produtos']:GetJsonObject('proddesc')
                SB1->B1_UM     := oJson['produtos']:GetJsonObject('produm')
                SB1->B1_TIPO   := oJson['produtos']:GetJsonObject('prodtipo')
                SB1->B1_GRUPO  := oJson['produtos']:GetJsonObject('prodgrupo')
            SB1->(MSUnlock())

            oReturn['prodcod']  := oJson['produtos']:GetJsonObject('prodcod')
            oReturn['proddesc'] := oJson['produtos']:GetJsonObject('proddesc')
            oReturn['cRet']     := '201 - Sucesso!'
            oReturn['cMessage'] := 'Registro alterado com sucesso.'

            Self:SetStatus(201)
            Self:SetContentType(APPLICATION_JSON)
            Self:SetResponse(FWJsonSerialize(oReturn))

        EndIf
        SB1->(dbCloseArea())
    EndIf

    RestArea(aArea)
    FreeObj(oJson)
    FreeObj(oReturn)
    
RETURN (lRet)

// %%%%%%%%%%%%% Construção de método DELETE para trazer dados da tabela SB1 %%%%%%%%%%%%%%%%%%%%%%%%%

WSMETHOD DELETE apagarproduto WSRECEIVE CODPRODUTO WSREST WSRESTPROD

    Local lRet      := .T.
    Local cCodProd  := self:CODPRODUTO
    Local cDescProd := ""
    Local aArea     := GetArea()
    Local oJson     := JsonObject():New()
    Local oReturn   := JsonObject():New()

    dbSelectArea("SB1")
    SB1->(dbSetOrder(1))

    If !SB1->(dbSeek(xFilial('SB1')+cCodProd))
        SetRestFault(401,EncodeUTF8("Código do produto não existe na base de dados."))
        lRet := .F.
        Return(lRet)
    Else
        cDescProd := SB1->B1_DESC
        RecLock('SB1',.F.)
            dbDelete()
        SB1->(MSUnlock())

        oReturn['prodcod']  := cCodProd
        oReturn['proddesc'] := cDescProd
        oReturn['cRet']     := '201 - Sucesso!'
        oReturn['cMessage'] := EncodeUTF8('Registro excluído com sucesso.')

        Self:SetStatus(201)
        Self:SetContentType(APPLICATION_JSON)
        Self:SetResponse(FWJsonSerialize(oReturn))
    EndIf
    SB1->(dbCloseArea())

    RestArea(aArea)
    FreeObj(oJson)
    FreeObj(oReturn)

RETURN (lRet)
