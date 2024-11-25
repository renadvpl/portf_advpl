//Bibliotecas
#Include "Totvs.ch"
#Include "RESTFul.ch"
#Include "TopConn.ch"

/*
ßßßßßßßßßßßßßßßßßßßßßßßßß  {Protheus.doc} WSPROD02  ßßßßßßßßßßßßßßßßßßßßßßßßß
ßß   @description Cadastro de Produtos via WebServices (WsRestFul)         ßß
ßß   @author Renato Silva                                                  ßß
ßß   @since 23/08/2023                                                     ßß
ßß   @version 1.0                                                          ßß
ßß   @type function                                                        ßß
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

WSRESTFUL wsProd02 DESCRIPTION 'Cadastro de Produtos WS'
    //Atributos
    WSDATA id         AS STRING
    WSDATA updated_at AS STRING
    WSDATA limit      AS INTEGER
    WSDATA page       AS INTEGER
 
    //Métodos
    WSMETHOD GET  ID  DESCRIPTION 'Retorna o registro pesquisado' ;
        WSSYNTAX '/wsProd02/get_id?{id}';
        PATH 'get_id'  PRODUCES APPLICATION_JSON
    WSMETHOD GET  ALL DESCRIPTION 'Retorna todos os registros';
        WSSYNTAX '/wsProd02/get_all?{updated_at, limit, page}';
        PATH 'get_all' PRODUCES APPLICATION_JSON
    WSMETHOD POST NEW DESCRIPTION 'Inclusão de registro';
        WSSYNTAX '/wsProd02/new';
        PATH 'new'     PRODUCES APPLICATION_JSON

END WSRESTFUL


WSMETHOD GET ID WSRECEIVE id WSSERVICE wsProd02
    Local lRet       := .T.
    Local jResponse  := JsonObject():New()
    Local cAliasWS   := 'SB1'

    //Se o id estiver vazio
    If Empty(::id)
        Self:setStatus(500) 
        jResponse['errorId']  := 'ID001'
        jResponse['error']    := 'ID vazio'
        jResponse['solution'] := 'Informe o ID'
    Else
        dbSelectArea( cAliasWS )
        (cAliasWS)->( dbSetOrder(1) )

        //Se não encontrar o registro
        If ! (cAliasWS)->(MsSeek(FWxFilial(cAliasWS) + ::id))
            Self:setStatus(500) 
            jResponse['errorId']  := 'ID002'
            jResponse['error']    := 'ID não encontrado'
            jResponse['solution'] := 'Código ID não encontrado na tabela ' + cAliasWS
        Else
            jResponse['cod']    := (cAliasWS)->B1_COD 
            jResponse['desc']   := (cAliasWS)->B1_DESC 
            jResponse['tipo']   := (cAliasWS)->B1_TIPO 
            jResponse['um']     := (cAliasWS)->B1_UM 
            jResponse['locpad'] := (cAliasWS)->B1_LOCPAD 
            jResponse['grupo']  := (cAliasWS)->B1_GRUPO 
        EndIf
    EndIf

    Self:SetContentType('application/json')
    Self:SetResponse( jResponse:toJSON() )

Return lRet


WSMETHOD GET ALL WSRECEIVE updated_at, limit, page WSSERVICE wsProd02
    Local lRet       := .T.
    Local jResponse  := JsonObject():New()
    Local cQueryTab  := ''
    Local nTamanho   := 10
    Local nTotal     := 0
    Local nPags      := 0
    Local nPagina    := 0
    Local nAtual     := 0
    Local oRegistro
    Local cAliasWS   := 'SB1'

    cQueryTab := " SELECT " + CRLF
    cQueryTab += "     TAB.R_E_C_N_O_ AS TABREC " + CRLF
    cQueryTab += " FROM " + CRLF
    cQueryTab += "     " + RetSQLName(cAliasWS) + " TAB " + CRLF
    cQueryTab += " WHERE " + CRLF
    cQueryTab += "     TAB.D_E_L_E_T_ = '' " + CRLF
    If ! Empty(::updated_at)
        cQueryTab += "     AND ((CASE WHEN SUBSTRING(B1_USERLGA, 03, 1) != ' ' THEN " + CRLF
        cQueryTab += "        CONVERT(VARCHAR,DATEADD(DAY,((ASCII(SUBSTRING(B1_USERLGA,12,1)) - 50) * 100 + (ASCII(SUBSTRING(B1_USERLGA,16,1)) - 50)),'19960101'),112) " + CRLF
        cQueryTab += "        ELSE '' " + CRLF
        cQueryTab += "     END) >= '" + StrTran(::updated_at, '-', '') + "') " + CRLF
    EndIf
    cQueryTab += " ORDER BY TABREC" + CRLF

    TCQuery cQueryTab New Alias 'QRY_TAB'

    If QRY_TAB->( EoF() )
        jResponse['errorId']  := 'ALL001'
        jResponse['error']    := 'Registro(s) não encontrado(s)'
        jResponse['solution'] := 'A consulta de registros não retornou nenhuma informação'
    Else
        jResponse['objects'] := {}

        Count To nTotal
        QRY_TAB->( dbGoTop() )

        If ! Empty(::limit)
            nTamanho := ::limit
        EndIf

        nPags := NoRound( nTotal / nTamanho, 0 )
        nPags += iif( nTotal % nTamanho != 0, 1, 0 )
        
        //Se vier página
        If ! Empty(::page)
            nPagina := ::page
        EndIf

        If nPagina <= 0 .Or. nPagina > nPags
            nPagina := 1
        EndIf

        If nPagina != 1
            QRY_TAB->( dbSkip((nPagina-1) * nTamanho) )
        EndIf

        jJsonMeta := JsonObject():New()
        jJsonMeta['total']         := nTotal
        jJsonMeta['current_page']  := nPagina
        jJsonMeta['total_page']    := nPags
        jJsonMeta['total_items']   := nTamanho
        jResponse['meta']          := jJsonMeta

        While ! QRY_TAB->( EoF() )
            nAtual++
            
            If nAtual > nTamanho
                Exit
            EndIf

            dbSelectArea( cAliasWS )
            (cAliasWS)->( dbGoTo(QRY_TAB->TABREC) )
            
            oRegistro := JsonObject():New()
            oRegistro['cod']    := (cAliasWS)->B1_COD 
            oRegistro['desc']   := (cAliasWS)->B1_DESC 
            oRegistro['tipo']   := (cAliasWS)->B1_TIPO 
            oRegistro['um']     := (cAliasWS)->B1_UM 
            oRegistro['locpad'] := (cAliasWS)->B1_LOCPAD 
            oRegistro['grupo']  := (cAliasWS)->B1_GRUPO 
            aAdd(jResponse['objects'], oRegistro)

            QRY_TAB->(dbSkip())

        EndDo
    EndIf
    QRY_TAB->( dbCloseArea() )

    Self:SetContentType('application/json')
    Self:SetResponse(jResponse:toJSON())

Return lRet



WSMETHOD POST NEW WSRECEIVE WSSERVICE wsProd02
    Local lRet              := .T.
    Local aDados            := {}
    Local jJson             := Nil
    Local cJson             := Self:GetContent()
    Local cError            := ''
    Local nLinha            := 0
    Local cDirLog           := '\x_logs\'
    Local cArqLog           := ''
    Local cErrorLog         := ''
    Local aLogAuto          := {}
    Local nCampo            := 0
    Local jResponse         := JsonObject():New()
    Local cAliasWS          := 'SB1'
    Private lMsErroAuto     := .F.
    Private lMsHelpAuto     := .T.
    Private lAutoErrNoFile  := .T.
 
    IF ! ExistDir(cDirLog)
        MakeDir(cDirLog)
    EndIF    

    Self:SetContentType('application/json')
    jJson  := JsonObject():New()
    cError := jJson:FromJson(cJson)
 
    IF ! Empty(cError)
        Self:setStatus(500) 
        jResponse['errorId']  := 'NEW004'
        jResponse['error']    := 'Parse do JSON'
        jResponse['solution'] := 'Erro ao fazer o Parse do JSON'

    Else
		dbSelectArea(cAliasWS)
       
		//Adiciona os dados do ExecAuto
		aAdd(aDados, {'B1_COD'   , jJson:GetJsonObject('cod')   , Nil})
		aAdd(aDados, {'B1_DESC'  , jJson:GetJsonObject('desc')  , Nil})
		aAdd(aDados, {'B1_TIPO'  , jJson:GetJsonObject('tipo')  , Nil})
		aAdd(aDados, {'B1_UM'    , jJson:GetJsonObject('um')    , Nil})
		aAdd(aDados, {'B1_LOCPAD', jJson:GetJsonObject('locpad'), Nil})
		aAdd(aDados, {'B1_GRUPO' , jJson:GetJsonObject('grupo') , Nil})
		
		//Percorre os dados do execauto
		For nCampo := 1 To Len(aDados)
			//Se o campo for data, retira os hifens e faz a conversão
			If GetSX3Cache(aDados[nCampo][1], 'X3_TIPO') == 'D'
				aDados[nCampo][2] := StrTran(aDados[nCampo][2], '-', '')
				aDados[nCampo][2] := sToD(aDados[nCampo][2])
			EndIf
		Next

		MsExecAuto({|x, y| MATA010(x, y)}, aDados, 3)

		If lMsErroAuto
			cErrorLog   := ''
			aLogAuto    := GetAutoGrLog()
			For nLinha := 1 To Len(aLogAuto)
				cErrorLog += aLogAuto[nLinha] + CRLF
			Next nLinha

			//Grava o arquivo de log
			cArqLog := 'wsProd02_New_' + dToS(Date()) + '_' + StrTran(Time(), ':', '-') + '.log'
			MemoWrite(cDirLog + cArqLog, cErrorLog)

           Self:setStatus(500) 
			jResponse['errorId']  := 'NEW005'
			jResponse['error']    := 'Erro na inclusão do registro'
			jResponse['solution'] := 'Nao foi possivel incluir o registro, foi gerado um arquivo de log em ' + cDirLog + cArqLog + ' '
			lRet := .F.
		Else
			jResponse['note']     := 'Registro incluido com sucesso'
		EndIf

    EndIf

    Self:SetResponse( jResponse:toJSON() )

Return lRet
