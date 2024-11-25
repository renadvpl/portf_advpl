//Bibliotecas
#INCLUDE "protheus.ch"
#INCLUDE "fwmvcdef.ch"

/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßß {Protheus.doc} ZMVC02 ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
ßß   @description Função principal para construção da tela de Requisição de Compras.  ßß
ßß   @author Renato Silva                                                             ßß
ßß   @since 30/05/2021                                                                ßß
ßß   @see https://tdn.totvs.com/display/framework/FWFormModelStruct                   ßß
ßß   @see https://tdn.totvs.com/display/framework/FWBuildFeature                      ßß
ßß   @see https://tdn.totvs.com/display/framework/FWFormGridModel                     ßß
ßß   @see https://tdn.totvs.com/display/framework/FwStruTrigger                       ßß
ßß   @see https://tdn.totvs.com/display/framework/FWFormView                          ßß
ßß   @obs Atualizacoes > Model-View-Control > Mod 02 - Requis Compras                 ßß
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function ZMVC02()
    
    Local aArea   := FWGetArea()
    Local oBrowse := FWMBrowse():New()

    oBrowse:SetAlias("ZD7")
    oBrowse:SetDescription("Requisição de Compras")
    
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
    
// Objeto responsável pela criação da estrutura TEMPORÁRIA do cabeçalho. 
    Local oStrCab := FWFormModelStruct():New()

// Objeto responsável pela estrutura dos itens.
    Local oStrIte := FWFormStruct(1,"ZD7")

// Chamada da função que validará a inclusão ANTES de ir para a inserção dos itens do GRID.
    Local bVldPos := {|| U_VLDZD7()}

// Chamada da função que validará a inclusão/alteração/exclusão dos itens.
    Local bVldCom := {|| U_GRVZD7()}

// Objeto responsável do desenvolvimento e traz as características dos campos.
    Local oModel := MPFormModel():New("ZMVC02M",,bVldPos,bVldCom,)

// Armazenar uma estrutura de gatilho nos campos Quantidade e Preço
    Local aTrigQnt := {}
    LOcal aTrigPrc := {}

// Criação da tabela TEMPORÁRIA para o Cabeçalho
    oStrCab:AddTable("ZD7",{"ZD7_FILIAL","ZD7_NUM","ZD7_ITEM"},"Cabeçalho ZD7")

// Criação dos campos da tabela TEMPORÁRIA
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
        "Emissão",;
        "Emissão",;
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
        "Usuário",;
        "Usuário",;
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

// ================ TRATAMENTO DA ESTRUTURA DOS ITENS NO GRID DA APLICAÇÃO ===============================   

// Modificação do inicializador padrão dos campos para não emitir menssgem de colunas vazias   
    oStrIte:SetProperty("ZD7_NUM"   , MODEL_FIELD_INIT, FWBuildFeature(STRUCT_FEATURE_INIPAD,'"*"'))
    oStrIte:SetProperty("ZD7_USER"  , MODEL_FIELD_INIT, FWBuildFeature(STRUCT_FEATURE_INIPAD,"__cUserId"))
    oStrIte:SetProperty("ZD7_EMISSA", MODEL_FIELD_INIT, FWBuildFeature(STRUCT_FEATURE_INIPAD,"dDataBase"))
    oStrIte:SetProperty("ZD7_FORNEC", MODEL_FIELD_INIT, FWBuildFeature(STRUCT_FEATURE_INIPAD,'"*"'))
    oStrIte:SetProperty("ZD7_LOJA"  , MODEL_FIELD_INIT, FWBuildFeature(STRUCT_FEATURE_INIPAD,'"*"'))

// Chamo a função FWStruTrigger para montar o bloco de código do gatilho que irá dentro dos arrays.
// Em seguida, usarei as quatro posições dos arrays para a criação do gatilho.
    aTrigQnt := FWStruTrigger(;
        "ZD7_QUANT",; // Campo que irá disparar o gatilho.
        "ZD7_TOTAL",; // Campo que irá receber o conteúdo.
        "M->ZD7_QUANT * M->ZD7_PRECO",;
        .F.)

    aTrigPrc := FWStruTrigger(;
        "ZD7_PRECO",;
        "ZD7_TOTAL",;
        "M->ZD7_QUANT * M->ZD7_PRECO",;
        .F.)

    oStrIte:AddTrigger(aTrigQnt[1],aTrigQnt[2],aTrigQnt[3],aTrigQnt[4])
    oStrIte:AddTrigger(aTrigPrc[1],aTrigPrc[2],aTrigPrc[3],aTrigPrc[4])    

// Vinculação com o cabeçalho
    oModel:AddFields("ZD7MASTER",,oStrCab)
    oModel:AddGrid("ZD7DETAIL","ZD7MASTER",oStrIte,,,,,)

// Adicionando model de totalizadores
    oModel:AddCalc("ZD7TOTAL","ZD7MASTER","ZD7DETAIL", "ZD7_PRODUT", "QTDITENS","COUNT",,,"Número de Produtos")
    oModel:AddCalc("ZD7TOTAL","ZD7MASTER","ZD7DETAIL", "ZD7_QUANT" , "QTDTOTAL","SUM"  ,,,"Total de Itens")
    oModel:AddCalc("ZD7TOTAL","ZD7MASTER","ZD7DETAIL", "ZD7_TOTAL" , "PRCTOTAL","SUM"  ,,,"Preço Total da Requisição")

// Setar a relação entre o cabeçalho e item neste ponto
    //oModel:SetRelation("ZD7DETAIL",{{"ZD7_FILIAL","'IIF(!INCLUI, ZD7->ZD7_FILIAL, FWxFilial('ZD7'))'"},{"ZD7_NUM","ZD7->ZD7_NUM"}},ZD7->(IndexKey(1))) // forma direta
            // OU
    aRelations := {}
    aAdd(aRelations,{"ZD7_FILIAL","iif(!INCLUI, ZD7->ZD7_FILIAL, FWxFilial('ZD7'))"})
    aAdd(aRelations,{"ZD7_NUM","ZD7->ZD7_NUM"})
    oModel:SetRelation("ZD7DETAIL",aRelations,ZD7->( IndexKey(1) ))

// Setar a chave primária
    oModel:SetPrimaryKey({})

// Para não-repetição da informação do campo ITEM
    oModel:GetModel("ZD7DETAIL"):SetUniqueLine({"ZD7_ITEM"})      

// Título do Modelo de Dados
    oModel:SetDescription("Modelo 02 de Requisição de Compras")

// Setar a descrição/título que aparecerão no CABEÇALHO e no GRID DE ITENS
    oModel:GetModel("ZD7MASTER"):SetDescription("Cabeçalho da Requisição de Compras")
    oModel:GetModel("ZD7DETAIL"):SetDescription("Itens da Requisição de Compras")

// Finalizando a função Model, setando o modelo antigo de GRID que permite pegar o aHeader e o aCols.
    oModel:GetModel("ZD7DETAIL"):SetUseOldGrid(.T.)

Return oModel


//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% VIEWDEF %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


Static Function ViewDef()

    Local oView      := GetValType('O')

    /*Faço o Load do Movel referente à função/fonte MVCZD7, sendo assim se este Model
    estivesse em um outro fonte eu poderia pegar de lá, sem ter que copiar tudooo de novo
    */
    Local oModel     := FwLoadModel("ZMVC02")

    //Objeto encarregado de montar a estrutura temporária do cabeçalho da View
    Local oStrCab    := FwFormViewStruct():New()

    /* Objeto responsável por montar a parte de estrutura dos itens/grid
    Como estou usando FwFormStruct, ele traz a estrutura de TODOS OS CAMPOS, sendo assim
    caso eu não queira que algum campo, apareça na minha grid, eu devo remover este campo com RemoveField
    */
    Local oStrIte    := FwFormStruct(2,"ZD7") //1 para model 2 para view

    // Criação da estrutura dos totalizadores
    Local oStrTotais := FWCalcStruct(oModel:GetModel("ZD7TOTAL"))

    //Crio dentro da estrutura da View, os campos do cabeçalho

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
        .F.,;    	                // [10]  L   Indica se o campo é alteravel
        Nil,;                       // [11]  C   Pasta do campo
        Nil,;                       // [12]  C   Agrupamento do campo
        Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
        Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
        Nil,;                       // [15]  C   Inicializador de Browse
        Nil,;                       // [16]  L   Indica se o campo é virtual
        Nil,;                       // [17]  C   Picture Variavel
        Nil)                        // [18]  L   Indica pulo de linha após o campo

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
        Iif(INCLUI, .T., .F.),;         // [10]  L   Indica se o campo é alteravel
        Nil,;                           // [11]  C   Pasta do campo
        Nil,;                           // [12]  C   Agrupamento do campo
        Nil,;                           // [13]  A   Lista de valores permitido do campo (Combo)
        Nil,;                           // [14]  N   Tamanho maximo da maior opção do combo
        Nil,;                           // [15]  C   Inicializador de Browse
        Nil,;                           // [16]  L   Indica se o campo é virtual
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
        Iif(INCLUI, .T., .F.),;     // [10]  L   Indica se o campo é alteravel
        Nil,;                       // [11]  C   Pasta do campo
        Nil,;                       // [12]  C   Agrupamento do campo
        Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
        Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
        Nil,;                       // [15]  C   Inicializador de Browse
        Nil,;                       // [16]  L   Indica se o campo é virtual
        Nil,;                       // [17]  C   Picture Variavel
        Nil)

    oStrCab:AddField(;
        "ZD7_USER",;                // [01]  C   Nome do Campo
        "05",;                      // [02]  C   Ordem
        "Usuário",;                 // [03]  C   Titulo do campo
        X3Descric('ZD7_USER'),;     // [04]  C   Descricao do campo
        Nil,;                       // [05]  A   Array com Help
        "C",;                       // [06]  C   Tipo do campo
        X3Picture("ZD7_USER"),;     // [07]  C   Picture
        Nil,;                       // [08]  B   Bloco de PictTre Var
        Nil,;                       // [09]  C   Consulta F3
        .F.,;                       // [10]  L   Indica se o campo é alteravel
        Nil,;                       // [11]  C   Pasta do campo
        Nil,;                       // [12]  C   Agrupamento do campo
        Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
        Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
        Nil,;                       // [15]  C   Inicializador de Browse
        Nil,;                       // [16]  L   Indica se o campo é virtual
        Nil,;                       // [17]  C   Picture Variavel
        Nil) 

    oStrIte:RemoveField("ZD7_NUM")
    oStrIte:RemoveField("ZD7_EMISSA")
    oStrIte:RemoveField("ZD7_FORNEC")            
    oStrIte:RemoveField("ZD7_LOJA")      
    oStrIte:RemoveField("ZD7_USER")

// Bloqueando a edição dos campos Item e Total
    oStrIte:SetProperty("ZD7_ITEM",  MVC_VIEW_CANCHANGE,.F.)
    oStrIte:SetProperty("ZD7_TOTAL", MVC_VIEW_CANCHANGE,.F.)

// Passagem das características visuais do projetos para aplicação

// Instância da classe FWFormView para o objeto View
    oView := FWFormView():New()

// Passagem do modelo de dados ao objeto View
    oView:SetModel(oModel)

// Montagem da estrutura de visualização do cabeçalho e dos itens
    oView:AddField("VIEW_ZD7M",oStrCab,"ZD7MASTER") // CABEÇALHO
    oView:AddGrid("VIEW_ZD7D",oStrIte,"ZD7DETAIL") // ITENS
    oView:AddField("VIEW_ZD7T",oStrTotais,"ZD7TOTAL") // TOTALIZADORES

// Deixar a numeração do campo Item do Grid incremental
    oView:AddIncrementalField("ZD7DETAIL","ZD7_ITEM")

// Criação da tela, dividindo proporcionalmente o tamanho do cabeçalho e do grid
    oView:CreateHorizontal("CABEC",20)
    oView:CreateHorizontal("GRID" ,50)
    oView:CreateHorizontal("TOTAL",30)

// Associação das Views aos IDs
    oView:SetOwnerView("VIEW_ZD7M","CABEC")    
    oView:SetOwnerView("VIEW_ZD7D","GRID")
    oView:SetOwnerView("VIEW_ZD7T","TOTAL")

// Ativação das Views
    oView:EnableTitleView("VIEW_ZD7M","Cabeçalho da Requisição de Compras")
    oView:EnableTitleView("VIEW_ZD7D","Itens da Requisição de Compras")
    oView:EnableTitleView("VIEW_ZD7T","Totais da Requisição de Compras")

// Fechamento com bloco de código para verificar se a janela deve ou não ser fechada após a execução do botão OK.
    oView:SetCloseOnOk({|| .T.})

Return oView

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

User Function GRVZD7()
    
    Local aArea  := FWGetArea()
    Local oModel := FWModelActive() //Capturo o modelo ativo
    Local lRet   := .T.

// Criar modelo de dados CABEÇALHO/ITENS    
    Local oModelCab := oModel:GetModel("ZD7MASTER")
    Local oModelIte := oModel:GetModel("ZD7DETAIL") //Responsável pelo aHeader e aCols

// Captura dos valores que estão no cabeçalho
    Local cFilZD7   := oModelCab:GetValue("ZD7_FILIAL")
    Local cNum      := oModelCab:GetValue("ZD7_NUM")
    Local dEmissao  := oModelCab:GetValue("ZD7_EMISSA")
    Local cFornece  := oModelCab:GetValue("ZD7_FORNEC")
    Local cLoja     := oModelCab:GetValue("ZD7_LOJA")
    Local cUser     := oModelCab:GetValue("ZD7_USER")

// Variáveis que farão a captura dos dados com base do aHeader e do aCols
    Local aHeadAux  := oModelIte:aHeader  // Captura o aHeader
    Local aColsAux  := oModelIte:aCols    // Captura o aCols

// Pegar posição de cada campo do GRID, não do cabeçalho
    Local nPosItem  := aScan(aHeadAux, {|x| AllTrim(Upper(x[2])) == AllTrim("ZD7_ITEM")})
    Local nPosProd  := aScan(aHeadAux, {|x| AllTrim(Upper(x[2])) == AllTrim("ZD7_PRODUT")})
    Local nPosQtd   := aScan(aHeadAux, {|x| AllTrim(Upper(x[2])) == AllTrim("ZD7_QUANT")})
    Local nPosPrc   := aScan(aHeadAux, {|x| AllTrim(Upper(x[2])) == AllTrim("ZD7_PRECO")})
    Local nPosTotal := aScan(aHeadAux, {|x| AllTrim(Upper(x[2])) == AllTrim("ZD7_TOTAL")})

// Preciso pegar a linha atual que o usuário está posicionado, para isso utilizei uma variável.
    Local nLinAtu := 0

// Preciso identificar qual o tipo de operação que o usuário está fazendo (inclusão, alteração ou exclusão)
    Local cOption := oModelCab:GetOperation()

// Selecionar a tabela com um índice de ordenação
    dbSelectArea("ZD7")
    ZD7->(DBSetOrder(1))

// Se a operação que está sendo realizada for uma inserção, ele fará
    IF cOption == MODEL_OPERATION_INSERT
// Porém, antes de tentar inserir, eu devo verificar se a linha está deletada.
        For nLinAtu := 1 To Len(aColsAux)
        // Expressão para verificar se uma linha está deletada no aCols.
            If !aColsAux[nLinAtu][Len(aHeadAux)+1]
                RecLock("ZD7",.T.) // Inclusão
                // CABEÇALHO
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
        // Expressão para verificar se uma linha está deletada no aCols.
            If aColsAux[nLinAtu][Len(aHeadAux)+1]
            // Se a linha estiver deletada, preciso verificar se ela está incluída ou não no sistema.
                ZD7->(dbSetOrder(2)) // Buscar o produto pelo índice 2
                // Se encontrar o produto no banco, o fonte deve deletar
                If ZD7->(dbSeek(cFilZD7+cNum+aColsAux[nLinAtu,nPosItem]))
                    RecLock("ZD7",.F.)
                        dbDelete()
                    ZD7->(MSUnLock())
                EndIf
            Else //Se a linha não estiver excluída, faço a alteração. Embora seja uma alteração,
            //posso ter novos itens inclusos no pedido. Sendo assim, preciso validar se estes itens existem no banco de dados ou caso eles não existem, faço uma inclusão (RecLock)
                ZD7->(dbSetOrder(2)) // Buscar o produto pelo índice 2
                // Se encontrar o produto no banco, ele fará a alteração.
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
        // Ele percorrerá todo arquivo, e enquanto a filial for igual ao do pedido e o número do pedido for
        // igual ao número que está posicionado para excluir (pedido que você quer excluir),
        // ocorrerá a DELEÇÃO/EXCLUSÃO dos registros.
        While !ZD7->(EOF()) .and. ZD7->ZD7_FILIAL = cFilZD7 .and. ZD7->ZD7_NUM = cNum
            RecLock("ZD7",.F.)
                dbDelete()
            ZD7->(MSUnLock())
            ZD7->(dbSkip())
        EndDo
        /*
        // OUTRA FORMA DE EXCLUSÃO COM BASE NO QUE ESTÁ NO GRID
        ZD7->(DBSetOrder(2))
        For nLinAtu := 1 To Len(aColsAux)
            // Regrinha para verificar se a linha está excluída, se não tiver incluir.
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
    Função para retornar TRUE se o número do pedido não estiver dentro da tabela.
    Evitar que sejam incluídos dois pedidos com o mesmo número.
    @type Function
*/
User Function VLDZD7()

    Local lRet  := .T. // Variável de controle que irá retornar TRUE se o número do pedido não estiver dentro da tabela.
    Local aArea := FWGetArea()

// Instancio os objetos Models para capturar os campos digitados no cabeçalho
    Local oModel    := FWModelActive()
    Local oModelCab := oModel:GetModel("ZD7MASTER")

    Local cFilZD7   := oModelCab:GetValue("ZD7_FILIAL")
    Local cNum      := oModelCab:GetValue("ZD7_NUM")

    Local cOption   := oModelCab:GetOperation()      

    If cOption == MODEL_OPERATION_INSERT
        dbSelectArea("ZD7")
        ZD7->(dbSetOrder(1)) // Índice: Filial + Nº Pedido
        // Se ele encontrar o número do pedido na tabela, a variável lRet retornará FALSE e impedirá a inserção
        If ZD7->( dbSeek(cFilZD7 + cNum) )
            lRet := .F.
            // Use o HELP, pois usando o Alert e o MsgInfo, ele aparece uma mensagem de erro.
            Help(NIL,NIL,"ATENÇÃO",NIL,"Este pedido já existe em nosso sistema.",1,0,NIL,NIL,NIL,NIL,NIL,{"Escolha outro número de pedido"})
        EndIf

    EndIf

    FWRestArea(aArea)

Return lRet
