//Bibliotecas de Funcoes
#INCLUDE 'TOTVS.ch'
#INCLUDE 'FWMVCDef.ch'
  
//Vari�veis Est�ticas
Static cCamposChv := "ZD4_ANO;"

/*
��������������������������� {Protheus.doc} ZMVC04 ������������������������������������
��   @description Cadastro de Premiacoes de Artistas (Modelo 02)                    ��
��   @author Renato Silva                                                           ��
��   @since 19/03/2024                                                              ��
��   @obs Atualizacoes > Model-View-Control > Mod 1 c/ Cpos-chave - Premiacoes      ��
��������������������������������������������������������������������������������������
*/
 
User Function zMVC04()

    Local aArea   := FWGetArea()
    Local oBrowse := GetValType('O')
      
    //Cria um browse para a ZD4
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("ZD4")
    oBrowse:SetDescription("Premia��es")
    oBrowse:Activate()
      
    FWRestArea(aArea)

Return Nil


Static Function MenuDef()

    Local aRot := {}
      
    //Adicionando op��es
    ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.zMVC04' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
    ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.zMVC04' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
    ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.zMVC04' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
    ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.zMVC04' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5

Return aRot


Static Function ModelDef()
    //Na montagem da estrutura do Modelo de dados, o cabe�alho filtrar� e exibir� somente os campos chave, j� a grid ir� carregar a estrutura inteira conforme fun��o fModStruct
    Local oModel    := GetValType('O')
    Local oStruCab  := FWFormStruct(1, 'ZD4', {|cCampo| Alltrim(cCampo) $ cCamposChv})
    Local oStruGrid := fModStruct()
 
    //Monta o modelo de dados
    oModel := MPFormModel():New('zMVC04M', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )
 
    //Agora, define no modelo de dados, que ter� um Cabe�alho e uma Grid apontando para estruturas acima
    oModel:AddFields('MdFieldZD4', NIL, oStruCab)
    oModel:AddGrid('MdGridZD4', 'MdFieldZD4', oStruGrid, , )
 
    //Monta o relacionamento entre Grid e Cabe�alho, as express�es da Esquerda
    //representam o campo da Grid e da direita do Cabe�alho
    oModel:SetRelation('MdGridZD4', {;
            {'ZD4_FILIAL', 'FWxFilial("ZD4")'},;
            {'ZD4_ANO'   , 'ZD4_ANO'};
        }, ZD4->(IndexKey(1)))
     
    //Definindo outras informa��es do Modelo e da Grid
    oModel:GetModel("MdGridZD4"):SetMaxLine(9999)
    oModel:SetDescription("Cadastro de Premia��es")
    oModel:SetPrimaryKey({"ZD4_FILIAL", "ZD4_ANO"})
 
Return oModel


Static Function ViewDef()
/*-------------------------------------------------------------------------------------------------------------
  Na montagem da estrutura da visualiza��o de dados, vamos chamar o modelo criado anteriormente.
  No cabe�alho, vamos mostrar somente os campos-chave e na grid vamos carregar conforme a fun��o fViewStruct
-------------------------------------------------------------------------------------------------------------*/
    Local oView     := GetValType('O')
    Local oModel    := FWLoadModel('zMVC04')
    Local oStruCab  := FWFormStruct(2, "ZD4", {|cCampo| Alltrim(cCampo) $ cCamposChv})
    Local oStruGRID := fViewStruct()
 
    //Define que no cabe�alho n�o ter� separa��o de abas (SXA)
    oStruCab:SetNoFolder()
 
    //Cria o View
    oView:= FWFormView():New() 
    oView:SetModel(oModel)              
 
    //Cria uma �rea de Field vinculando a estrutura do cabe�alho com MDFieldZD4, e uma Grid vinculando com MdGridZD4
    oView:AddField('VIEW_ZD4', oStruCab , 'MdFieldZD4')
    oView:AddGrid('GRID_ZD4' , oStruGRID, 'MdGridZD4' )
 
    //O cabe�alho (MAIN) ter� 25% de tamanho, e o restante de 75% ir� para a GRID
    oView:CreateHorizontalBox("MAIN", 25)
    oView:CreateHorizontalBox("GRID", 75)
 
    //Vincula o MAIN com a VIEW_ZD4 e a GRID com a GRID_ZD4
    oView:SetOwnerView('VIEW_ZD4', 'MAIN')
    oView:SetOwnerView('GRID_ZD4', 'GRID')
    oView:EnableControlBar(.T.)
 
    //Define o campo incremental da grid como o ZD4_ITEM
    oView:AddIncrementField('GRID_ZD4', 'ZD4_ITEM')

Return oView


//Fun��o chamada para montar o modelo de dados da Grid (retorna todos os campos)
Static Function fModStruct()
    Local oStruct := GetValType('O')
    oStruct := FWFormStruct(1, 'ZD4')
Return oStruct


//Fun��o chamada para montar a visualiza��o de dados da Grid (retorna os campos, excetuando os campos chave)
Static Function fViewStruct()
    Local oStruct := GetValType('O')
    oStruct := FWFormStruct(2, "ZD4", {|cCampo| !(Alltrim(cCampo) $ cCamposChv)})
Return oStruct
