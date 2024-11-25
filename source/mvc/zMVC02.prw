//Bibliotecas
#INCLUDE "protheus.ch"
#INCLUDE "fwmvcdef.ch"

/*
��������������������������� {Protheus.doc} ZMVC02 ��������������������������������������
��   @description Fun��o principal para constru��o da tela de Requisi��o de Compras.  ��
��   @author Renato Silva                                                             ��
��   @since 30/05/2021                                                                ��
��   @see https://tdn.totvs.com/display/framework/FWFormModelStruct                   ��
��   @see https://tdn.totvs.com/display/framework/FWBuildFeature                      ��
��   @see https://tdn.totvs.com/display/framework/FWFormGridModel                     ��
��   @see https://tdn.totvs.com/display/framework/FwStruTrigger                       ��
��   @see https://tdn.totvs.com/display/framework/FWFormView                          ��
��   @obs Atualizacoes > Model-View-Control > Mod 02 - Requis Compras                 ��
����������������������������������������������������������������������������������������
*/

User Function ZMVC02()
    
    Local aArea   := FWGetArea()
    Local oBrowse := FWMBrowse():New()

    oBrowse:SetAlias("ZD7")
    oBrowse:SetDescription("Requisi��o de Compras")
    
    oBrowse:DisableDetails()
    oBrowse:Activate()   

    FWRestArea(aArea)

Return NIL

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% MENUDEF %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Static Function MenuDef()

    Local aRotina := FWMVCMenu("ZMVC02")
    
Return aRotina

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% MODELDEF %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Static Function ModelDef()
    
// Objeto respons�vel pela cria��o da estrutura TEMPOR�RIA do cabe�alho. 
    Local oStrCab := FWFormModelStruct():New()

// Objeto respons�vel pela estrutura dos itens.
    Local oStrIte := FWFormStruct(1,"ZD7")

// Chamada da fun��o que validar� a inclus�o ANTES de ir para a inser��o dos itens do GRID.
    Local bVldPos := {|| U_VLDZD7()}

// Chamada da fun��o que validar� a inclus�o/altera��o/exclus�o dos itens.
    Local bVldCom := {|| U_GRVZD7()}

// Objeto respons�vel do desenvolvimento e traz as caracter�sticas dos campos.
    Local oModel := MPFormModel():New("ZMVC02M",,bVldPos,bVldCom,)

// Armazenar uma estrutura de gatilho nos campos Quantidade e Pre�o
    Local aTrigQnt := {}
    LOcal aTrigPrc := {}

// Cria��o da tabela TEMPOR�RIA para o Cabe�alho
    oStrCab:AddTable("ZD7",{"ZD7_FILIAL","ZD7_NUM","ZD7_ITEM"},"Cabe�alho ZD7")

// Cria��o dos campos da tabela TEMPOR�RIA
    oStrCab:AddField(;
        "Filial",;
        "Filial",;
        "ZD7_FILIAL",;
        "C",;
        TamSX3("ZD7_FILIAL")[1],;
        0,;
        Nil,;
        Nil,;
        {},;
        .F.,;
        FWBuildFeature(STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,ZD7->ZD7_FILIAL,FWxFilial('ZD7'))" ),;
        .T.,;
        .F.,;
        .F.)

    oStrCab:AddField(;
        "Pedido",;
        "Pedido",;
        "ZD7_NUM",;
        "C",;
        TamSX3("ZD7_NUM")[1],;
        0,;
        Nil,;
        Nil,;
        {},;
        .F.,;
        FWBuildFeature(STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,ZD7->ZD7_NUM,GetSXENum('ZD7','ZD7_NUM'))" ),;
        .T.,;
        .F.,;
        .F.)
    
    oStrCab:AddField(;
        "Emiss�o",;
        "Emiss�o",;
        "ZD7_EMISSA",;
        "D",;
        TamSX3("ZD7_EMISSA")[1],;
        0,;
        Nil,;
        Nil,;
        {},;
        .F.,;
        FWBuildFeature(STRUCT_FEATURE_INIPAD, "IIF(!INCLUI,ZD7->ZD7_EMISSA,dDataBase)" ),;
        .T.,;
        .F.,;
        .F.)

    oStrCab:AddField(;
        "Fornecedor",;
        "Fornecedor",;
        "ZD7_FORNEC",;
        "C",;
        TamSX3("ZD7_FORNEC")[1],;
        0,;
        Nil,;
        Nil,;
        {},;
        .F.,;
        FWBuildFeature(STRUCT_FEATURE_INIPAD, "IIF(!INCLUI,ZD7->ZD7_FORNEC,'')" ),;
        .T.,;
        .F.,;
        .F.)

    oStrCab:AddField(;
        "Loja",;
        "Loja",;
        "ZD7_LOJA",;
        "C",;
        TamSX3("ZD7_LOJA")[1],;
        0,;
        Nil,;
        Nil,;
        {},;
        .F.,;
        FWBuildFeature(STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,ZD7->ZD7_LOJA,'')" ),;
        .T.,;
        .F.,;
        .F.)

    oStrCab:AddField(;
        "Usu�rio",;
        "Usu�rio",;
        "ZD7_USER",;
        "C",;
        TamSX3("ZD7_USER")[1],;
        0,;
        Nil,;
        Nil,;
        {},;
        .T.,;
        FWBuildFeature(STRUCT_FEATURE_INIPAD, "iif(!INCLUI,ZD7->ZD7_USER,__cUserId)" ),;
        .F.,;
        .F.,;
        .F.)   

// ================ TRATAMENTO DA ESTRUTURA DOS ITENS NO GRID DA APLICA��O ===============================   

// Modifica��o do inicializador padr�o dos campos para n�o emitir menssgem de colunas vazias   
    oStrIte:SetProperty("ZD7_NUM"   , MODEL_FIELD_INIT, FWBuildFeature(STRUCT_FEATURE_INIPAD,'"*"'))
    oStrIte:SetProperty("ZD7_USER"  , MODEL_FIELD_INIT, FWBuildFeature(STRUCT_FEATURE_INIPAD,"__cUserId"))
    oStrIte:SetProperty("ZD7_EMISSA", MODEL_FIELD_INIT, FWBuildFeature(STRUCT_FEATURE_INIPAD,"dDataBase"))
    oStrIte:SetProperty("ZD7_FORNEC", MODEL_FIELD_INIT, FWBuildFeature(STRUCT_FEATURE_INIPAD,'"*"'))
    oStrIte:SetProperty("ZD7_LOJA"  , MODEL_FIELD_INIT, FWBuildFeature(STRUCT_FEATURE_INIPAD,'"*"'))

// Chamo a fun��o FWStruTrigger para montar o bloco de c�digo do gatilho que ir� dentro dos arrays.
// Em seguida, usarei as quatro posi��es dos arrays para a cria��o do gatilho.
    aTrigQnt := FWStruTrigger(;
        "ZD7_QUANT",; // Campo que ir� disparar o gatilho.
        "ZD7_TOTAL",; // Campo que ir� receber o conte�do.
        "M->ZD7_QUANT * M->ZD7_PRECO",;
        .F.)

    aTrigPrc := FWStruTrigger(;
        "ZD7_PRECO",;
        "ZD7_TOTAL",;
        "M->ZD7_QUANT * M->ZD7_PRECO",;
        .F.)

    oStrIte:AddTrigger(aTrigQnt[1],aTrigQnt[2],aTrigQnt[3],aTrigQnt[4])
    oStrIte:AddTrigger(aTrigPrc[1],aTrigPrc[2],aTrigPrc[3],aTrigPrc[4])    

// Vincula��o com o cabe�alho
    oModel:AddFields("ZD7MASTER",,oStrCab)
    oModel:AddGrid("ZD7DETAIL","ZD7MASTER",oStrIte,,,,,)

// Adicionando model de totalizadores
    oModel:AddCalc("ZD7TOTAL","ZD7MASTER","ZD7DETAIL", "ZD7_PRODUT", "QTDITENS","COUNT",,,"N�mero de Produtos")
    oModel:AddCalc("ZD7TOTAL","ZD7MASTER","ZD7DETAIL", "ZD7_QUANT" , "QTDTOTAL","SUM"  ,,,"Total de Itens")
    oModel:AddCalc("ZD7TOTAL","ZD7MASTER","ZD7DETAIL", "ZD7_TOTAL" , "PRCTOTAL","SUM"  ,,,"Pre�o Total da Requisi��o")

// Setar a rela��o entre o cabe�alho e item neste ponto
    //oModel:SetRelation("ZD7DETAIL",{{"ZD7_FILIAL","'IIF(!INCLUI, ZD7->ZD7_FILIAL, FWxFilial('ZD7'))'"},{"ZD7_NUM","ZD7->ZD7_NUM"}},ZD7->(IndexKey(1))) // forma direta
            // OU
    aRelations := {}
    aAdd(aRelations,{"ZD7_FILIAL","iif(!INCLUI, ZD7->ZD7_FILIAL, FWxFilial('ZD7'))"})
    aAdd(aRelations,{"ZD7_NUM","ZD7->ZD7_NUM"})
    oModel:SetRelation("ZD7DETAIL",aRelations,ZD7->( IndexKey(1) ))

// Setar a chave prim�ria
    oModel:SetPrimaryKey({})

// Para n�o-repeti��o da informa��o do campo ITEM
    oModel:GetModel("ZD7DETAIL"):SetUniqueLine({"ZD7_ITEM"})      

// T�tulo do Modelo de Dados
    oModel:SetDescription("Modelo 02 de Requisi��o de Compras")

// Setar a descri��o/t�tulo que aparecer�o no CABE�ALHO e no GRID DE ITENS
    oModel:GetModel("ZD7MASTER"):SetDescription("Cabe�alho da Requisi��o de Compras")
    oModel:GetModel("ZD7DETAIL"):SetDescription("Itens da Requisi��o de Compras")

// Finalizando a fun��o Model, setando o modelo antigo de GRID que permite pegar o aHeader e o aCols.
    oModel:GetModel("ZD7DETAIL"):SetUseOldGrid(.T.)

Return oModel


//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% VIEWDEF %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


Static Function ViewDef()

    Local oView      := GetValType('O')

    /*Fa�o o Load do Movel referente � fun��o/fonte MVCZD7, sendo assim se este Model
    estivesse em um outro fonte eu poderia pegar de l�, sem ter que copiar tudooo de novo
    */
    Local oModel     := FwLoadModel("ZMVC02")

    //Objeto encarregado de montar a estrutura tempor�ria do cabe�alho da View
    Local oStrCab    := FwFormViewStruct():New()

    /* Objeto respons�vel por montar a parte de estrutura dos itens/grid
    Como estou usando FwFormStruct, ele traz a estrutura de TODOS OS CAMPOS, sendo assim
    caso eu n�o queira que algum campo, apare�a na minha grid, eu devo remover este campo com RemoveField
    */
    Local oStrIte    := FwFormStruct(2,"ZD7") //1 para model 2 para view

    // Cria��o da estrutura dos totalizadores
    Local oStrTotais := FWCalcStruct(oModel:GetModel("ZD7TOTAL"))

    //Crio dentro da estrutura da View, os campos do cabe�alho

    oStrCab:AddField(;
        "ZD7_NUM",;                 // [01]  C   Nome do Campo
        "01",;                      // [02]  C   Ordem
        "Pedido",;                  // [03]  C   Titulo do campo
        X3Descric('ZD7_NUM'),;      // [04]  C   Descricao do campo
        Nil,;                       // [05]  A   Array com Help
        "C",;                       // [06]  C   Tipo do campo
        X3Picture("ZD7_NUM"),;      // [07]  C   Picture
        Nil,;                       // [08]  B   Bloco de PictTre Var
        Nil,;                       // [09]  C   Consulta F3
        .F.,;    	                // [10]  L   Indica se o campo � alteravel
        Nil,;                       // [11]  C   Pasta do campo
        Nil,;                       // [12]  C   Agrupamento do campo
        Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
        Nil,;                       // [14]  N   Tamanho maximo da maior op��o do combo
        Nil,;                       // [15]  C   Inicializador de Browse
        Nil,;                       // [16]  L   Indica se o campo � virtual
        Nil,;                       // [17]  C   Picture Variavel
        Nil)                        // [18]  L   Indica pulo de linha ap�s o campo

    oStrCab:AddField(;
        "ZD7_EMISSA",; 
        "02",;  
        "Emissao",; 
        X3Descric('ZD7_EMISSA'),;
        Nil,; 
        "D",; 
        X3Picture("ZD7_EMISSA"),; 
        Nil,; 
        Nil,; 
        Iif(INCLUI, .T., .F.),;  
        Nil,; 
        Nil,;  
        Nil,;
        Nil,; 
        Nil,; 
        Nil,;
        Nil,;
        Nil)  

    oStrCab:AddField(;
        "ZD7_FORNEC",;
        "03",;
        "Fornecedor",; 
        X3Descric('ZD7_FORNEC'),;       // [04]  C   Descricao do campo
        Nil,;                           // [05]  A   Array com Help
        "C",;                           // [06]  C   Tipo do campo
        X3Picture("ZD7_FORNEC"),;       // [07]  C   Picture
        Nil,;                           // [08]  B   Bloco de PictTre Var
        "SA2",;                         // [09]  C   Consulta F3
        Iif(INCLUI, .T., .F.),;         // [10]  L   Indica se o campo � alteravel
        Nil,;                           // [11]  C   Pasta do campo
        Nil,;                           // [12]  C   Agrupamento do campo
        Nil,;                           // [13]  A   Lista de valores permitido do campo (Combo)
        Nil,;                           // [14]  N   Tamanho maximo da maior op��o do combo
        Nil,;                           // [15]  C   Inicializador de Browse
        Nil,;                           // [16]  L   Indica se o campo � virtual
        Nil,;                           // [17]  C   Picture Variavel
        Nil) 

    oStrCab:AddField(;
        "ZD7_LOJA",;                // [01]  C   Nome do Campo
        "04",;                      // [02]  C   Ordem
        "Loja",;                    // [03]  C   Titulo do campo
        X3Descric('ZD7_LOJA'),;     // [04]  C   Descricao do campo
        Nil,;                       // [05]  A   Array com Help
        "C",;                       // [06]  C   Tipo do campo
        X3Picture("ZD7_LOJA"),;     // [07]  C   Picture
        Nil,;                       // [08]  B   Bloco de PictTre Var
        Nil,;                       // [09]  C   Consulta F3
        Iif(INCLUI, .T., .F.),;     // [10]  L   Indica se o campo � alteravel
        Nil,;                       // [11]  C   Pasta do campo
        Nil,;                       // [12]  C   Agrupamento do campo
        Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
        Nil,;                       // [14]  N   Tamanho maximo da maior op��o do combo
        Nil,;                       // [15]  C   Inicializador de Browse
        Nil,;                       // [16]  L   Indica se o campo � virtual
        Nil,;                       // [17]  C   Picture Variavel
        Nil)

    oStrCab:AddField(;
        "ZD7_USER",;                // [01]  C   Nome do Campo
        "05",;                      // [02]  C   Ordem
        "Usu�rio",;                 // [03]  C   Titulo do campo
        X3Descric('ZD7_USER'),;     // [04]  C   Descricao do campo
        Nil,;                       // [05]  A   Array com Help
        "C",;                       // [06]  C   Tipo do campo
        X3Picture("ZD7_USER"),;     // [07]  C   Picture
        Nil,;                       // [08]  B   Bloco de PictTre Var
        Nil,;                       // [09]  C   Consulta F3
        .F.,;                       // [10]  L   Indica se o campo � alteravel
        Nil,;                       // [11]  C   Pasta do campo
        Nil,;                       // [12]  C   Agrupamento do campo
        Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
        Nil,;                       // [14]  N   Tamanho maximo da maior op��o do combo
        Nil,;                       // [15]  C   Inicializador de Browse
        Nil,;                       // [16]  L   Indica se o campo � virtual
        Nil,;                       // [17]  C   Picture Variavel
        Nil) 

    oStrIte:RemoveField("ZD7_NUM")
    oStrIte:RemoveField("ZD7_EMISSA")
    oStrIte:RemoveField("ZD7_FORNEC")            
    oStrIte:RemoveField("ZD7_LOJA")      
    oStrIte:RemoveField("ZD7_USER")

// Bloqueando a edi��o dos campos Item e Total
    oStrIte:SetProperty("ZD7_ITEM",  MVC_VIEW_CANCHANGE,.F.)
    oStrIte:SetProperty("ZD7_TOTAL", MVC_VIEW_CANCHANGE,.F.)

// Passagem das caracter�sticas visuais do projetos para aplica��o

// Inst�ncia da classe FWFormView para o objeto View
    oView := FWFormView():New()

// Passagem do modelo de dados ao objeto View
    oView:SetModel(oModel)

// Montagem da estrutura de visualiza��o do cabe�alho e dos itens
    oView:AddField("VIEW_ZD7M",oStrCab,"ZD7MASTER") // CABE�ALHO
    oView:AddGrid("VIEW_ZD7D",oStrIte,"ZD7DETAIL") // ITENS
    oView:AddField("VIEW_ZD7T",oStrTotais,"ZD7TOTAL") // TOTALIZADORES

// Deixar a numera��o do campo Item do Grid incremental
    oView:AddIncrementalField("ZD7DETAIL","ZD7_ITEM")

// Cria��o da tela, dividindo proporcionalmente o tamanho do cabe�alho e do grid
    oView:CreateHorizontal("CABEC",20)
    oView:CreateHorizontal("GRID" ,50)
    oView:CreateHorizontal("TOTAL",30)

// Associa��o das Views aos IDs
    oView:SetOwnerView("VIEW_ZD7M","CABEC")    
    oView:SetOwnerView("VIEW_ZD7D","GRID")
    oView:SetOwnerView("VIEW_ZD7T","TOTAL")

// Ativa��o das Views
    oView:EnableTitleView("VIEW_ZD7M","Cabe�alho da Requisi��o de Compras")
    oView:EnableTitleView("VIEW_ZD7D","Itens da Requisi��o de Compras")
    oView:EnableTitleView("VIEW_ZD7T","Totais da Requisi��o de Compras")

// Fechamento com bloco de c�digo para verificar se a janela deve ou n�o ser fechada ap�s a execu��o do bot�o OK.
    oView:SetCloseOnOk({|| .T.})

Return oView

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

User Function GRVZD7()
    
    Local aArea  := FWGetArea()
    Local oModel := FWModelActive() //Capturo o modelo ativo
    Local lRet   := .T.

// Criar modelo de dados CABE�ALHO/ITENS    
    Local oModelCab := oModel:GetModel("ZD7MASTER")
    Local oModelIte := oModel:GetModel("ZD7DETAIL") //Respons�vel pelo aHeader e aCols

// Captura dos valores que est�o no cabe�alho
    Local cFilZD7   := oModelCab:GetValue("ZD7_FILIAL")
    Local cNum      := oModelCab:GetValue("ZD7_NUM")
    Local dEmissao  := oModelCab:GetValue("ZD7_EMISSA")
    Local cFornece  := oModelCab:GetValue("ZD7_FORNEC")
    Local cLoja     := oModelCab:GetValue("ZD7_LOJA")
    Local cUser     := oModelCab:GetValue("ZD7_USER")

// Vari�veis que far�o a captura dos dados com base do aHeader e do aCols
    Local aHeadAux  := oModelIte:aHeader  // Captura o aHeader
    Local aColsAux  := oModelIte:aCols    // Captura o aCols

// Pegar posi��o de cada campo do GRID, n�o do cabe�alho
    Local nPosItem  := aScan(aHeadAux, {|x| AllTrim(Upper(x[2])) == AllTrim("ZD7_ITEM")})
    Local nPosProd  := aScan(aHeadAux, {|x| AllTrim(Upper(x[2])) == AllTrim("ZD7_PRODUT")})
    Local nPosQtd   := aScan(aHeadAux, {|x| AllTrim(Upper(x[2])) == AllTrim("ZD7_QUANT")})
    Local nPosPrc   := aScan(aHeadAux, {|x| AllTrim(Upper(x[2])) == AllTrim("ZD7_PRECO")})
    Local nPosTotal := aScan(aHeadAux, {|x| AllTrim(Upper(x[2])) == AllTrim("ZD7_TOTAL")})

// Preciso pegar a linha atual que o usu�rio est� posicionado, para isso utilizei uma vari�vel.
    Local nLinAtu := 0

// Preciso identificar qual o tipo de opera��o que o usu�rio est� fazendo (inclus�o, altera��o ou exclus�o)
    Local cOption := oModelCab:GetOperation()

// Selecionar a tabela com um �ndice de ordena��o
    dbSelectArea("ZD7")
    ZD7->(DBSetOrder(1))

// Se a opera��o que est� sendo realizada for uma inser��o, ele far�
    IF cOption == MODEL_OPERATION_INSERT
// Por�m, antes de tentar inserir, eu devo verificar se a linha est� deletada.
        For nLinAtu := 1 To Len(aColsAux)
        // Express�o para verificar se uma linha est� deletada no aCols.
            If !aColsAux[nLinAtu][Len(aHeadAux)+1]
                RecLock("ZD7",.T.) // Inclus�o
                // CABE�ALHO
                    ZD7_FILIAL  := cFilZD7
                    ZD7_NUM     := cNum
                    ZD7_EMISSA  := dEmissao
                    ZD7_FORNEC  := cFornece
                    ZD7_LOJA    := cLoja
                    ZD7_USER    := cUser
                // GRID DE ITENS
                    ZD7_ITEM    := aColsAux[nLinAtu,nPosItem]
                    ZD7_PRODUT  := aColsAux[nLinAtu,nPosProd]
                    ZD7_QUANT   := aColsAux[nLinAtu,nPosQtd]
                    ZD7_PRECO   := aColsAux[nLinAtu,nPosPrc]
                    ZD7_TOTAL   := aColsAux[nLinAtu,nPosTotal]
                ZD7->(MSUnLock())
            EndIf

        Next nLinAtu
    

    ELSEIF cOption == MODEL_OPERATION_UPDATE

        For nLinAtu := 1 To Len(aColsAux)
        // Express�o para verificar se uma linha est� deletada no aCols.
            If aColsAux[nLinAtu][Len(aHeadAux)+1]
            // Se a linha estiver deletada, preciso verificar se ela est� inclu�da ou n�o no sistema.
                ZD7->(dbSetOrder(2)) // Buscar o produto pelo �ndice 2
                // Se encontrar o produto no banco, o fonte deve deletar
                If ZD7->(dbSeek(cFilZD7+cNum+aColsAux[nLinAtu,nPosItem]))
                    RecLock("ZD7",.F.)
                        dbDelete()
                    ZD7->(MSUnLock())
                EndIf
            Else //Se a linha n�o estiver exclu�da, fa�o a altera��o. Embora seja uma altera��o,
            //posso ter novos itens inclusos no pedido. Sendo assim, preciso validar se estes itens existem no banco de dados ou caso eles n�o existem, fa�o uma inclus�o (RecLock)
                ZD7->(dbSetOrder(2)) // Buscar o produto pelo �ndice 2
                // Se encontrar o produto no banco, ele far� a altera��o.
                If ZD7->(DBSeek(cFilZD7+cNum+aColsAux[nLinAtu,nPosItem]))
                    RecLock("ZD7",.F.)
                        ZD7_FILIAL  := cFilZD7
                        ZD7_NUM     := cNum
                        ZD7_EMISSA  := dEmissao
                        ZD7_FORNEC  := cFornece
                        ZD7_LOJA    := cLoja
                        ZD7_USER    := cUser
                        ZD7_ITEM    := aColsAux[nLinAtu,nPosItem]
                        ZD7_PRODUT  := aColsAux[nLinAtu,nPosProd]
                        ZD7_QUANT   := aColsAux[nLinAtu,nPosQtd]
                        ZD7_PRECO   := aColsAux[nLinAtu,nPosPrc]
                        ZD7_TOTAL   := aColsAux[nLinAtu,nPosTotal]                    
                    ZD7->(MSUnLock())
                Else
                    RecLock("ZD7",.T.)
                        ZD7_FILIAL  := cFilZD7
                        ZD7_NUM     := cNum
                        ZD7_EMISSA  := dEmissao
                        ZD7_FORNEC  := cFornece
                        ZD7_LOJA    := cLoja
                        ZD7_USER    := cUser
                        ZD7_ITEM    := aColsAux[nLinAtu,nPosItem]
                        ZD7_PRODUT  := aColsAux[nLinAtu,nPosProd]
                        ZD7_QUANT   := aColsAux[nLinAtu,nPosQtd]
                        ZD7_PRECO   := aColsAux[nLinAtu,nPosPrc]
                        ZD7_TOTAL   := aColsAux[nLinAtu,nPosTotal]                    
                    ZD7->(MSUnLock())
                EndIf
            EndIf

        Next nLinAtu
    ELSEIF cOption == MODEL_OPERATION_DELETE
        ZD7->(dbSetOrder(1))
        // Ele percorrer� todo arquivo, e enquanto a filial for igual ao do pedido e o n�mero do pedido for
        // igual ao n�mero que est� posicionado para excluir (pedido que voc� quer excluir),
        // ocorrer� a DELE��O/EXCLUS�O dos registros.
        While !ZD7->(EOF()) .and. ZD7->ZD7_FILIAL = cFilZD7 .and. ZD7->ZD7_NUM = cNum
            RecLock("ZD7",.F.)
                dbDelete()
            ZD7->(MSUnLock())
            ZD7->(dbSkip())
        EndDo
        /*
        // OUTRA FORMA DE EXCLUS�O COM BASE NO QUE EST� NO GRID
        ZD7->(DBSetOrder(2))
        For nLinAtu := 1 To Len(aColsAux)
            // Regrinha para verificar se a linha est� exclu�da, se n�o tiver incluir.
            If ZD7->(DBSeek(cFilZD7+cNum+aColAux[nLinAtu][nPosItem]))
                RecLock("ZD7",.F.)
                    DBDelete()
                ZD7->(MSUnlock())
            EndIf
        Next nLinAtu
        */
    ENDIF
    
    FWRestArea(aArea)

Return lRet

/*
{Protheus.doc} User Function VLDZD7
    Fun��o para retornar TRUE se o n�mero do pedido n�o estiver dentro da tabela.
    Evitar que sejam inclu�dos dois pedidos com o mesmo n�mero.
    @type Function
*/
User Function VLDZD7()

    Local lRet  := .T. // Vari�vel de controle que ir� retornar TRUE se o n�mero do pedido n�o estiver dentro da tabela.
    Local aArea := FWGetArea()

// Instancio os objetos Models para capturar os campos digitados no cabe�alho
    Local oModel    := FWModelActive()
    Local oModelCab := oModel:GetModel("ZD7MASTER")

    Local cFilZD7   := oModelCab:GetValue("ZD7_FILIAL")
    Local cNum      := oModelCab:GetValue("ZD7_NUM")

    Local cOption   := oModelCab:GetOperation()      

    If cOption == MODEL_OPERATION_INSERT
        dbSelectArea("ZD7")
        ZD7->(dbSetOrder(1)) // �ndice: Filial + N� Pedido
        // Se ele encontrar o n�mero do pedido na tabela, a vari�vel lRet retornar� FALSE e impedir� a inser��o
        If ZD7->( dbSeek(cFilZD7 + cNum) )
            lRet := .F.
            // Use o HELP, pois usando o Alert e o MsgInfo, ele aparece uma mensagem de erro.
            Help(NIL,NIL,"ATEN��O",NIL,"Este pedido j� existe em nosso sistema.",1,0,NIL,NIL,NIL,NIL,NIL,{"Escolha outro n�mero de pedido"})
        EndIf

    EndIf

    FWRestArea(aArea)

Return lRet
