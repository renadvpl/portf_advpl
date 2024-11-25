#include "protheus.ch"
#include "fwmvcdef.ch"

#define MVC_TITLE "Grid MVC sem cabeçalho"
#define MVC_ALIAS "ZAG"
#define MVC_VIEWDEF_NAME "VIEWDEF.MVCGRID"

/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßßß {Protheus.doc} MVCGRID ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
ßß   @description Rotina MVC de GRID sem cabacalho                                       ßß
ßß   @author      Renato Silva                                                           ßß
ßß   @since       21/08/2024                                                             ßß
ßß   @type        function                                                               ßß
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
user function MVCGRID()
    FWExecView( "Alteração", MVC_VIEWDEF_NAME, MODEL_OPERATION_UPDATE)
return


static function ModelDef()
    local oModel    as object
    local oStrField as object
    local oStrGrid  as object

    // Estrutura Fake de Field
    oStrField := FWFormModelStruct():New()
    oStrField:addTable("", {"C_STRING1"}, MVC_TITLE, {|| ""})
    oStrField:addField("String 01", "Campo de texto", "C_STRING1", "C", 15)

    //Estrutura de Grid, alias Real presente no dicionário de dados
    oStrGrid := FWFormStruct(1, MVC_ALIAS)
    // oStrGrid:SetProperty("ZAG_SALDOA" , MODEL_FIELD_VIRTUAL, .T.)

    aTrigSld := FWStruTrigger("ZAG_MONTAN","ZAG_SALDOA","M->ZAG_MONTAN",.F.)
    oStrGrid:AddTrigger(aTrigSld[1],aTrigSld[2],aTrigSld[3],aTrigSld[4])

    oModel := MPFormModel():New("MIDMAIN")
    oModel:addFields("CABID", /*cOwner*/, oStrField, nil, nil, {|oMdl| ""})
    oModel:addGrid("GRIDID", "CABID", oStrGrid, nil, nil, nil, nil, {|oMdl| loadGrid(oMdl)})
    oModel:setDescription(MVC_TITLE)

    // É necessário que haja alguma alteração na estrutura Field
    oModel:setActivate({ |oModel| onActivate(oModel)})

return oModel


static function onActivate(oModel)

    //Só efetua a alteração do campo para inserção
    if oModel:GetOperation() == MODEL_OPERATION_INSERT
        FwFldPut("C_STRING1", "FAKE" , nil, oModel)
    endif

return


static function loadGrid(oModel)
    local aData as array
    local cAlias as char
    local cWorkArea as char
    local cTablename as char

    cWorkArea  := Alias()
    cAlias     := GetNextAlias()
    cTablename := "%" + RetSqlName(MVC_ALIAS) + "%"

    BeginSql Alias cAlias
        SELECT *, R_E_C_N_O_ RECNO
        FROM %exp:cTablename%
        WHERE D_E_L_E_T_ = ' '
    EndSql

    aData := FwLoadByAlias(oModel, cAlias, MVC_ALIAS, "RECNO",, .T.)

    (cAlias)->(DBCloseArea())

    if !Empty(cWorkArea) .And. Select(cWorkArea) > 0
        DBSelectArea(cWorkArea)
    endif

return aData


static function viewDef()
    local oView as object
    local oModel as object
    local oStrCab as object
    local oStrGrid as object

    // Estrutura Fake de Field
    oStrCab := FWFormViewStruct():New()
    oStrCab:addField("C_STRING1", "01" , "String 01", "Campo de texto", , "C" )

    //Estrutura de Grid
    oStrGrid := FWFormStruct(2, MVC_ALIAS )
    oStrGrid:SetProperty("ZAG_SALDOA" , MVC_VIEW_CANCHANGE, .F.)

    oModel := FWLoadModel("MVCGRID")
    oView := FwFormView():New()

    oView:setModel(oModel)
    oView:addField("CAB", oStrCab, "CABID")
    oView:addGrid("GRID", oStrGrid, "GRIDID")
    oView:createHorizontalBox("TOHIDE", 0 )
    oView:createHorizontalBox("TOSHOW", 100 )
    oView:setOwnerView("CAB", "TOHIDE" )
    oView:setOwnerView("GRID", "TOSHOW")

    oView:setDescription( MVC_TITLE )

return oView

