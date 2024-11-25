#include 'totvs.ch'
#include 'xmlxfun.ch'

/*/{Protheus.doc} CEPCORREIOS
    Consumir o Webservice do Correios
    @type Function
    @author Renato Silva
    @since 11/01/2022
    @version 1.0
    @see https://tdn.totvs.com/display/tec/HTTPPost
    @see https://tdn.totvs.com/display/tec/At
    @see https://tdn.totvs.com/display/tec/XmlParser
    @see https://medium.com/@markos12/consumindo-o-webservice-dos-correios-soap-via-extens%C3%A3o-do-1b087bf290fb
    /*/
User Function cepcorreios()
    // VARIÁVEIS DA HTTPPOST(<cUrl>, <cGetParms>, <cPostParms>, <nTimeOut>, <aHeadStr>, <@aHeaderGet>)
    Local cUrlWSDL := "https://apps.correios.com.br/SigepMasterJPA/AtendeClienteService/AtendeCliente"
    Local nTimeOut := 120
    Local aHeadStr := {}
    Local cData    := ""
    Local cHeadRet := ""

    // Captura o retorno do WebService (Rua, Município, etc.)
    Local aData    := {}

    // VARIÁVEIS DA XML PARSER(<oXml>, <cReplace>, <cError>, <cWarning>)
    Local oXml     := ""
    Local cError   := ""
    Local cWarning := ""
    Local sPostRet := "" 

    Private cEnder := ""

    dbSelectArea("SA1")

    If !Empty(M->A1_CEP)
        // Montar o cabeçalho do SOAP
        aAdd(aHeadStr,"SOAPAction: 'http://cliente.bean.master.sigep.bsb.correios.com.br/AtendeCliente/consultaCEP'")
        aAdd(aHeadStr,"Content-Type: text/xml;charset=UTF-8")
        cData := "<soapenv:Envelope xmlns:soapenv='http://schemas.xmlsoap.org/soap/envelope/' xmlns:cli='http://cliente.bean.master.sigep.bsb.correios.com.br/'>"
        cData += "<soapenv:Header/>"
           cData += "<soapenv:Body>"
             cData += "<cli:consultaCEP>"
               cData += "<cep>"+M->A1_CEP+"</cep>"
             cData += "</cli:consultaCEP>"
           cData += "</soapenv:Body>"
        cData += "</soapenv:Envelope>"

        sPostRet := HttpPost(cUrlWSDL, "", cData, nTimeOut, aHeadStr, @cHeadRet)
        // Utilizar o variável sPostRet
        If !Empty(sPostRet)
            If AT("<faultcode>",sPostRet) == 0
                oXml := XmlParser(sPostRet, "_", @cError, @cWarning)

                aAdd(aData, oXml:_SOAP_ENVELOPE:_SOAP_BODY:_NS2_CONSULTACEPRESPONSE:_RETURN:_END:TEXT)
                aAdd(aData, oXml:_SOAP_ENVELOPE:_SOAP_BODY:_NS2_CONSULTACEPRESPONSE:_RETURN:_BAIRRO:TEXT)
                aAdd(aData, oXml:_SOAP_ENVELOPE:_SOAP_BODY:_NS2_CONSULTACEPRESPONSE:_RETURN:_CIDADE:TEXT)
                aAdd(aData, oXml:_SOAP_ENVELOPE:_SOAP_BODY:_NS2_CONSULTACEPRESPONSE:_RETURN:_UF:TEXT)
                aAdd(aData, oXml:_SOAP_ENVELOPE:_SOAP_BODY:_NS2_CONSULTACEPRESPONSE:_RETURN:_CEP:TEXT)

                cEnder       := aData[1]
                M->A1_BAIRRO := aData[2]
                M->A1_MUN    := aData[3]
                M->A1_EST    := aData[4]

            Else
                FWAlertWarning("CEP inválido ou não encontrado.","ATENÇÃO")

            EndIf

        EndIf

    EndIf

    SA1->(dbCloseArea())

Return (cEnder)
