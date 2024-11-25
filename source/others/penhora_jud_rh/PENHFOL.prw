#include "protheus.ch"
#include "fwmvcdef.ch"

#define MVC_TITLE "Lan�amentos de Penhora Judicial"
#define MVC_ALIAS "ZAK"

/*
���������������������������� {Protheus.doc} PENHFOL ���������������������������������������
��   @description Rotina para configurar os lan�amentos de desconto de penhora judicial  ��
��   @author      Renato Silva                                                           ��
��   @since       21/08/2024                                                             ��
��   @type        function                                                               ��
�������������������������������������������������������������������������������������������
*/
User function PENHFOL()

    if !FWAliasInDic('ZAK')
        FWAlertWarning('<h3>Solicite a implanta��o do Controle de Penhora ao setor de TI.</h3>','ATEN��O')
    else
        FWExecView( "Configura��o", "VIEWDEF.PENHFOL", MODEL_OPERATION_UPDATE)
    endif

return NIL


Static function modelDef()
    local oModel    := getValType('O')
    local oStrField := getValType('O')
    local oStrGrid  := getValType('O')

    // FAKE
    oStrField := FWFormModelStruct():New()
        oStrField:addTable("", {"C_STRING1"}, MVC_TITLE, {|| ""})
        oStrField:addField("String 01", "Campo de texto", "C_STRING1", "C", 15)

    // GRID
    oStrGrid := FWFormStruct( 1, MVC_ALIAS)
        oStrGrid:SetProperty("ZAK_STATUS" , MODEL_FIELD_INIT , FWBuildFeature(STRUCT_FEATURE_INIPAD,'"1"'))
        oStrGrid:SetProperty( '*'         , MODEL_FIELD_NOUPD, .T. )
        aTrigFunc := FWStruTrigger("ZAK_MAT","ZAK_NOME","Posicione('SRA', 1, M->ZAK_CODFIL+M->ZAK_MAT, 'RA_NOME')",.F.)
        aTrigSld  := FWStruTrigger("ZAK_DIVINI","ZAK_SLDATU","M->ZAK_DIVINI",.F.)
        aTrigSld1 := FWStruTrigger("ZAK_SLDATU","ZAK_SLDCAL","M->ZAK_SLDATU",.F.)
        aTrigLiq  := FWStruTrigger("ZAK_LIQUID","ZAK_VERBAS","iif(M->ZAK_LIQUID ='S','TODAS','')",.F.)
        oStrGrid:AddTrigger(aTrigFunc[1],aTrigFunc[2],aTrigFunc[3],aTrigFunc[4])
        oStrGrid:AddTrigger(aTrigSld[1] ,aTrigSld[2] ,aTrigSld[3] , aTrigSld[4])
        oStrGrid:AddTrigger(aTrigSld1[1],aTrigSld1[2],aTrigSld1[3],aTrigSld1[4])
        oStrGrid:AddTrigger(aTrigLiq[1] ,aTrigLiq[2] ,aTrigLiq[3] , aTrigLiq[4])

    oModel := MPFormModel():New("MIDMAIN",nil,{ |oMdl| validPos(oMdl) })
    oModel:addFields("CABID", nil, oStrField, nil, nil, {|oMdl| {""}})
    oModel:addGrid("GRIDID", "CABID", oStrGrid, {|oMdl,nLine,cAct| vldLinDel(oMdl,nLine,cAct) }, nil, nil, nil, {|oMdl| loadGrid(oMdl) })
    oModel:setDescription(MVC_TITLE)
    //oModel:getModel('GRIDID'):SetNoDeleteLine(.T.)
    oModel:setActivate({ |oModel| onActivate(oModel)})

return oModel



Static function onActivate(oModel)
    if oModel:getOperation() == MODEL_OPERATION_INSERT
        FWFldPut("C_STRING1", "FAKE" , nil, oModel)
    endif
return NIL



Static function loadGrid(oModel)
    local aData      := {} as Array
    local cAlias     := "" as Character
    local cWorkArea  := "" as Character
    local cTableName := "" as Character

    cWorkArea := Alias()
    cAlias := GetNextAlias()
    cTableName := "%"+RetSqlName(MVC_ALIAS)+"%"

    BeginSql Alias cAlias
        SELECT * FROM %exp:cTableName%
        WHERE D_E_L_E_T_ = ' '
    EndSql

    aData := FWLoadByAlias( oModel, cAlias, MVC_ALIAS,,, .T. )

    (cAlias)->( dbCloseArea() )

    if !Empty( cWorkArea ) .and. Select( cWorkArea ) > 0
        dbSelectArea( cWorkArea )
    endif

return aData



Static Function validPos( oModel )
	local nOperation := oModel:getOperation()
	local lRet       := .T.

	if nOperation == MODEL_OPERATION_UPDATE
		if oModel:getValue( 'GRIDID', 'ZAK_LIQUID' ) == 'N' .and. Empty( oModel:getValue( 'GRIDID', 'ZAK_VERBAS' ) )
			Help( nil, nil, 'BASE_PENH', nil, 'Para n�o-utiliza��o do l�quido como base de c�lculo, '+;
                 CRLF + 'deve preencher as verbas envolvidas', 1, 0)
			lRet := .F.
		endIf

        if oModel:getValue( 'GRIDID', 'ZAK_PERC' ) > 30.00
            Help( nil, nil, 'PERC_PENH', nil, 'O percentual de penhora n�o deve passar de 30%.', 1, 0)
            lRet := .F.
        endif
	EndIf

return lRet



Static Function vldLinDel( oModel, nLinha, cAcao )
    local lRet 	     := .T.
    local nOperation := oModel:getOperation()

    if cAcao == 'DELETE' .and. nOperation == MODEL_OPERATION_UPDATE
        FWAlertWarning( 'Essa a��o n�o � recomendada, mas a matr�cula ser� exclu�da do c�lculo de penhora.' )
    endIf

Return lRet



Static function viewDef()
    local oView    := getValType('O')
    local oModel   := getValType('O')
    local oStrCab  := getValType('O')
    local oStrGrid := getValType('O')

    // FAKE
    oStrCab := FWFormViewStruct():New()
        oStrCab:addField("C_STRING1", "01" , "String 01", "Campo de texto", , "C" )

    // GRID
    oStrGrid := FWFormStruct(2, MVC_ALIAS )
        oStrGrid:SetProperty("ZAK_SLDCAL" , MVC_VIEW_CANCHANGE, .F.)

    oModel := FWLoadModel("PENHFOL")
    oView := FwFormView():New()

    oView:setModel( oModel )
    oView:addField("CAB", oStrCab, "CABID")
    oView:addGrid("GRID", oStrGrid, "GRIDID")
    oView:createHorizontalBox("TOHIDE", 000 )
    oView:createHorizontalBox("TOSHOW", 100 )
    oView:setOwnerView("CAB" , "TOHIDE" )
    oView:setOwnerView("GRID", "TOSHOW" )
    oView:setDescription( MVC_TITLE )

return oView



/*
��������������������������� {Protheus.doc} PENHFCAL �������������������������������������
��   @description Fun��o chamada pela f�rmula PENHCALC do roteiro FOL                  ��
��   @author      Renato Silva                                                         ��
��   @since       21/08/2024                                                           ��
��   @obs         Cadastrar uma f�rmula para chamar esta funcao                        ��
��   *************** [ F�RMULA ] ******************************                        ��
�����������������������������������������������������������������������������������������
*/
User function PENHFCAL()
    local nPercPenh := 0
    local nDescPenh := 0
    local nVlrPenh  := 0
    local nBasePenh := 0
    local nTotalLiq := 0
    local nSaldoAtu := 0
    local cChavBusc := ""

    nTotalLiq := nLiquido
    cChavBusc := SRA->RA_FILIAL + SRA->RA_MAT

    dbSelectArea('ZAK')
    ZAK->( dbSetOrder(1), dbGoTop() )

    if ZAK->( dbSeek( FWxFilial('ZAK') + cChavBusc) ) .and. ZAK->ZAK_STATUS == '1'
        while !ZAK->(EOF())
            if ( ZAK->ZAK_CODFIL + ZAK->ZAK_MAT ) == cChavBusc
                nPercPenh := ZAK->ZAK_PERC
                nBasePenh := iif( ZAK->ZAK_LIQUID == 'S', nTotalLiq, fBuscaPD( ZAK->ZAK_VERBAS,'V') ) 
                nDescPenh := nBasePenh * (nPercPenh)/100
                
                if ZAK->ZAK_SLDCAL > 0 .and. ZAK->ZAK_SLDCAL < nDescPenh
                    nDescPenh := ZAK->ZAK_SLDCAL
                elseif ZAK->ZAK_SLDCAL <= 0
                    nDescPenh := ZAK->ZAK_SLDATU
                endif

                nSaldoAtu := ZAK->ZAK_SLDATU
                RecLock( 'ZAK', .F. )
                    ZAK->ZAK_SLDCAL := nSaldoAtu - nDescPenh
                ZAK->( msUnLock() )
                nVlrPenh += nDescPenh

            endif
            ZAK->( dbSkip() )

        enddo

        if nVlrPenh > 0 .and. nTotalLiq > 0
            fGeraVerba( "448", nVlrPenh )
            aPd[ fLocaliaPD("999"), 5 ] := nTotalLiq - nVlrPenh
        endif

    endif

    ZAK->( dbCloseArea() )

Return NIL
