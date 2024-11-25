#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßß {Protheus.doc} ZMVC03C ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
ßß   @description Cadastro de CDs (Modelo 03) - Tela de Consulta                     ßß
ßß   @author Renato Silva                                                            ßß
ßß   @since 10/03/2024                                                               ßß
ßß   @obs Atualizacoes > Model-View-Control > Mod 3 - Cad CDs                        ßß
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function ZMVC03C()
    FWExecView('Consulta Musicas',"ZMVC03C", 3,, { || .T. } )
Return NIL


//-------------------------------------------------------------------
Static Function ModelDef()
    // Cria a estrutura a ser usada no Modelo de Dados
    Local oStruPar := FWFormModelStruct():New()
    Local oStruZD2 := FWFormStruct( 1, 'ZD2' , { |x| ALLTRIM(x) $ 'ZD2_CD, ZD2_NOMECD'   } )
    Local oStruZD3 := FWFormStruct( 1, 'ZD3' , { |x| ALLTRIM(x) $ 'ZD3_ITEM, ZD3_MUSICA' } )
    Local oModel   := GetValType('O')

    oStruPar:AddField( ;
    "CD"                       , ;               // [01] Titulo do campo
    "CD"                       , ;               // [02] ToolTip do campo
    "CD"                       , ;               // [03] Id do Field
    "C"                        , ;               // [04] Tipo do campo
    TamSX3('ZD2_CD')[1]        , ;               // [05] Tamanho do campo
    TamSX3('ZD2_CD')[1]        , ;               // [06] Decimal do campo
    FWBuildFeature( STRUCT_FEATURE_VALID, 'ExistCpo("ZD2",M->CD,1)' ) , ;   // [07] Code-block de validação do campo
                               , ;               // [08] Code-block de validação When do campo
                               , ;               // [09] Lista de valores permitido do campo
    .T.                          )               // [10] Indica se o campo tem preenchimento obrigatório

    oStruPar:AddField( ;
    "Carregar"                     , ;           // [01] Titulo do campo
    "Carregar"                     , ;           // [02] ToolTip do campo
    'BOTAO'                        , ;           // [03] Id do Field
    'BT'                           , ;           // [04] Tipo do campo
    1                              , ;           // [05] Tamanho do campo
    0                              , ;           // [06] Decimal do campo
    { |oMdl| Carrega( oMdl ), .T. }  )           // [07] Code-block de validação do campo


    oStruZD2:SetProperty ( 'ZD2_CD', MODEL_FIELD_VALID, FWBuildFeature( 1, '.T.' ) )
    oStruZD2:SetProperty ( 'ZD2_CD', MODEL_FIELD_INIT , NIL )

    oModel := MPFormModel():New( 'MDTESTE' , , { | oMdl | NIL } )

    oModel:AddFields( 'PARAMETROS', NIL, oStruPar )

    oModel:AddGrid( 'ZD2DETAIL', 'PARAMETROS', oStruZD2 )

    oModel:AddGrid( 'ZD3DETAIL', 'ZD2DETAIL', oStruZD3 )

    oModel:AddCalc( 'CALCULOS', 'PARAMETROS', 'ZD2DETAIL', 'ZD2_CD', 'ZD2_TOT01', 'COUNT', { | oFW | TOTAIS( oFW, .T. ) }, , "TOTAL 01" )
    oModel:AddCalc( 'CALCULOS', 'PARAMETROS', 'ZD2DETAIL', 'ZD2_CD', 'ZD2_TOT02', 'COUNT', { | oFW | TOTAIS( oFW, .F. ) }, , "TOTAL 02" )

    //oModel:SetRelation( 'ZD3DETAIL', { { 'ZD3_FILIAL', 'xFilial( "ZD3" )' } , { 'ZD3_MUSICA', 'ZD2_MUSICA' } } , ZD3->( IndexKey( 1 ) ) )

    oModel:GetModel( 'ZD3DETAIL' ):SetUniqueLine( { 'ZD3_AUTOR' } )

    oModel:SetDescription( 'Modelo de Musicas' )
    oModel:GetModel( 'PARAMETROS' ):SetDescription( 'Parâmetros' )
    oModel:GetModel( 'ZD2DETAIL' ):SetDescription( 'Dados dos CDs' )
    oModel:GetModel( 'ZD3DETAIL' ):SetDescription( 'Dados das Músicas'  )

    oModel:SetPrimaryKey( {} )

Return oModel


//-------------------------------------------------------------------
Static Function ViewDef()
    // Cria a estrutura a ser usada na View
    Local oStruPar := FWFormViewStruct():New()
    Local oStruZD2 := FWFormStruct( 2, 'ZD2' , { |x| ALLTRIM(x) $ 'ZD2_CD, ZD2_NOMECD' } )
    Local oStruZD3 := FWFormStruct( 2, 'ZD3' , { |x| ALLTRIM(x) $ 'ZD3_ITEM, ZD3_MUSICA' } )
    // Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
    Local oModel   := FWLoadModel( 'ZMVC03C' )
    Local oView    := GetValType('O')
    Local oCalc1   := GetValType('O')

    oStruPar:AddField( ;
    'CD'             , ;             // [01] Campo
    'ZZ'             , ;             // [02] Ordem
    'CD'             , ;             // [03] Titulo
    'CD'             , ;             // [04] Descricao
    , ;                              // [05] Help
    'G'              , ;             // [06] Tipo do campo   COMBO, Get ou CHECK
    "@!"             , ;             // [07] Picture
    , ;                              // [08] PictVar
                    )                // [09] F3

    oStruPar:AddField( ;
    'BOTAO'          , ;             // [01] Campo
    "ZZ"             , ;             // [02] Ordem
    "Carregar"       , ;             // [03] Titulo
    "Carregar"       , ;             // [04] Descricao
    NIL              , ;             // [05] Help
    'BT'             )               // [06] Tipo do campo   COMBO, Get ou CHECK

    oView := FWFormView():New()
    oView:SetModel( oModel )
    oView:AddField( 'VIEW_PAR' , oStruPar, 'PARAMETROS' )
    oView:AddGrid(  'VIEW_ZD2' , oStruZD2, 'ZD2DETAIL'  )
    oView:AddGrid(  'VIEW_ZD3' , oStruZD3, 'ZD3DETAIL'  )

    oCalc1 := FWCalcStruct( oModel:GetModel( 'CALCULOS') )
    oView:AddField( 'VIEW_CALC', oCalc1, 'CALCULOS' )

    oView:CreateHorizontalBox( "BOX1" , 15 )
    oView:CreateHorizontalBox( "BOX2" , 30 )
    oView:CreateHorizontalBox( "BOX3" , 15 )
    oView:CreateHorizontalBox( "BOX4" , 40 )

    oView:SetOwnerView( 'VIEW_PAR' , "BOX1" )
    oView:SetOwnerView( 'VIEW_ZD2' , "BOX2" )
    oView:SetOwnerView( 'VIEW_CALC', "BOX3" )
    oView:SetOwnerView( 'VIEW_ZD3' , "BOX4" )

    oView:EnableTitleView('VIEW_CALC','Totais')

Return oView


//-------------------------------------------------------------------
Static Function TOTAIS( oFW, lPar )
    Local lRet := .T.

    If lPar
        lRet := ( Mod( Val( oFw:GetValue( 'ZD2DETAIL', 'ZD2_CD' ) ) , 2 ) == 0 )
    Else
        lRet := ( Mod( Val( oFw:GetValue( 'ZD2DETAIL', 'ZD2_CD' ) ) , 2 ) <> 0 )
    EndIf
Return lRet

//-------------------------------------------------------------------
Static Function Carrega( oMdl )

    Local aArea      := FWGetArea()
    Local cMusica    := ''
    Local cTmp       := GetNextAlias()
    Local cTmp2      := GetNextAlias()
    Local nLinhaZD2  := 0
    Local nLinhaZD3  := 0
    Local oModel     := FWModelActive()
    Local oModelZD2  := oModel:GetModel( 'ZD2DETAIL' )
    Local oModelZD3  := oModel:GetModel( 'ZD3DETAIL' )

    cMusica := oModel:GetValue( 'PARAMETROS', 'MUSICA' )

    oModelZD2:DeActivate( .T. )
    If !oModelZD2:Activate()
        Help( ,, 'Help',, 'Restricao de ativacao do Modelo', 1, 0 )
        Return NIL
    EndIf	

    BeginSql Alias cTmp

        SELECT ZD2_CD, ZD2_NOMECD
        FROM %table:ZD2% ZD2
        WHERE ZD2_FILIAL = %FWxFilial:ZD2%
        and ZD2_CD >= %exp:cMusica%
        and ZD2.%notdel%

    EndSql

    nLinhaZD2 := 1

    While !(cTmp)->( EOF() )
        
        If nLinhaZD2 > 1
            If oModelZD2:AddLine() <> nLinhaZD2
                Help( ,, 'HELP',, 'Nao incluiu linha na ZD2' + CRLF + oModel:getErrorMessage()[6], 1, 0)   
                (cTmp)->( dbSkip() )
                Loop			
            EndIf
        EndIf
        
        oModelZD2:SetValue( 'ZD2_CD'    , (cTmp)->ZD2_CD     )
        oModelZD2:SetValue( 'ZD2_NOMECD', (cTmp)->ZD2_NOMECD )
        
        nLinhaZD2++
        
        cMusica := (cTmp)->ZD2_CD
        
        BeginSql Alias cTmp2
            
            SELECT ZD3_ITEM, ZD3_MUSICA
            FROM %table:ZD3% ZD3
            WHERE ZD3_FILIAL = %FWxFilial:ZD3%
            and ZD3_MUSICA = %exp:cMusica%
            and ZD3.%notdel%
            
        EndSql
        
        nLinhaZD3 := 1
        
        While !(cTmp2)->( EOF() )  .and. cMusica== (cTmp2)->ZD3_MUSICA
            
            If nLinhaZD3 > 1
                If oModelZD3:AddLine() <> nLinhaZD3
                    Help( ,, 'HELP',, 'Nao incluiu linha na ZD3' + CRLF + oModel:getErrorMessage()[6], 1, 0)
                    (cTmp2)->( dbSkip() )
                    Loop
                EndIf
            EndIf
            
            oModelZD3:SetValue( 'ZD3_MUSICA', (cTmp2)->ZD3_MUSICA )
            oModelZD3:SetValue( 'ZD3_ITEM'  , (cTmp2)->ZD3_ITEM   )
            
            nLinhaZD3++
            
            (cTmp2)->( dbSkip() )
        End
        
        (cTmp2)->( dbCloseArea() )
        
        (cTmp)->( dbSkip() )

    End

    (cTmp)->( dbCloseArea() )

    FWRestArea( aArea )

Return NIL
