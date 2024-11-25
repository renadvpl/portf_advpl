//Bibliotecas
#Include 'TOTVS.ch'
#Include 'FWMVCDef.ch'

/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßß {Protheus.doc} ZMVC05 ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
ßß   @description Cadastro de Artistas (Modelo 01 com MarkBrowse em MVC)            ßß
ßß   @author Renato Silva                                                           ßß
ßß   @since 19/03/2024                                                              ßß
ßß   @obs Criar a ZD1_OK com o tamanho 2 no Configurador e deixar como não usado    ßß
ßß   @obs Atualizacoes > Model-View-Control > Mod 1 c/ Marca - Artistas             ßß
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function zMVC05()

    Private oMark as OBJECT
     
    //Criando o MarkBrow
    oMark := FWMarkBrowse():New()
    oMark:SetAlias('ZD1')
     
    //Setando semáforo, descrição e campo de mark
    oMark:SetSemaphore(.T.)
    oMark:SetDescription('Seleção do Cadastro de Artistas')
    oMark:SetFieldMark('ZD1_OK')
     
    //Ativando a janela
    oMark:Activate()

Return NIL
  
Static Function MenuDef()

    Local aRotina := {}
    //Criação das opções
    ADD OPTION aRotina TITLE 'Processar' ACTION 'u_zMarkProc' OPERATION 2 ACCESS 0

Return aRotina


User Function zMarkProc()
/*----------------------------------------------------------------------------------
Rotina para processamento e verificação de quantos registros estão marcados
----------------------------------------------------------------------------------*/
    Local aArea  := FWGetArea()
    Local cMarca := oMark:Mark()
    Local nTotal := 0
     
    //Percorrendo os registros da ZD1
    ZD1->(dbGoTop())
    While ! ZD1->(EoF())
        //Caso esteja marcado, aumenta o contador
        If oMark:IsMark(cMarca)
            nTotal++
             
            //Limpando a marca
            RecLock('ZD1', .F.)
                ZD1_OK := ''
            ZD1->(MSUnlock())
        EndIf
         
        //Pulando registro
        ZD1->( dbSkip() )

    EndDo
     
    //Mostrando a mensagem de registros marcados
    FWAlertInfo('Foram marcados <b>' + cValToChar( nTotal ) + ' artistas</b>.', "Atenção")
     
    //Restaurando área armazenada
    FWRestArea(aArea)

Return NIL
