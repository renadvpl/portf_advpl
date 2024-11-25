#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

/*
��������������������������� {Protheus.doc} ZMVC29 ��������������������������������������
��   Exemplo de importacao de dados para uma estrutura de pai/filho                   ��
��   para um rotina desenvolvida em MVC                                               ��
��   @author Renato Silva                                                             ��
��   @since 06/04/2024                                                                ��
��   @obs Atualizacoes > Model-View-Control > Modelo 03 > Import de CDs/Musicas       ��
����������������������������������������������������������������������������������������
*/
User Function ZMVC29()

	Local aSay     := {}
	Local aButton  := {}
	Local nOpc     := 0
	Local Titulo   := 'IMPORTACAO DE MUSICAS'
	Local cDesc1   := 'Esta rotina fara a importacao de musicas,'
	Local cDesc2   := 'conforme leiaute das tabelas.'
	Local cDesc3   := ''
	Local lOk      := .T.

	aAdd( aSay, cDesc1 )
	aAdd( aSay, cDesc2 )
	aAdd( aSay, cDesc3 )

	aAdd( aButton, { 1, .T., { || nOpc := 1, FechaBatch() } } )
	aAdd( aButton, { 2, .T., { || FechaBatch()            } } )

	FormBatch( Titulo, aSay, aButton )

	If nOpc == 1

		Processa( { || lOk := Runproc() },'Aguarde','Processando...',.F.)

		If lOk
			FWAlertInfo( 'Processamento terminado com sucesso.', 'ATEN��O' )
		Else
			FWAlertError( 'Processamento realizado com problemas.', 'ATEN��O' )
		EndIf

	EndIf

Return NIL


//-------------------------------------------------------------------
Static Function Runproc()
	Local lRet     := .T.
	Local aCposCab := {}
	Local aCposDet := {}
	Local aAux     := {}

	aCposCab := {}
	aCposDet := {}
	aAdd( aCposCab, { 'ZD2_CD'     , '000005'      } )
	aAdd( aCposCab, { 'ZD2_ARTIST' , '000007'      } )
	aAdd( aCposCab, { 'ZD2_NOMECD' , 'La, La, La,' } )


	aAux := {}
	aAdd( aAux, { 'ZD3_ITEM'   , '01'         } )
	aAdd( aAux, { 'ZD3_MUSICA' , 'Musica 01'  } )
	aAdd( aCposDet, aAux )

	aAux := {}
	aAdd( aAux, { 'ZD3_ITEM'   , '02'         } )
	aAdd( aAux, { 'ZD3_MUSICA' , 'Musica 02'  } )
	aAdd( aCposDet, aAux )

	If !Import( 'ZD2', 'ZD3', aCposCab, aCposDet )
		lRet := .F.
	EndIf


	aCposCab := {}
	aCposDet := {}
	aAdd( aCposCab, { 'ZD2_CD'     , '000006'         } )
	aAdd( aCposCab, { 'ZD2_ARTIST' , '000007'         } )
	aAdd( aCposCab, { 'ZD2_NOMECD' , 'Bla, bla, bla,' } )

	aAux := {}
	aAdd( aAux, { 'ZD3_ITEM'   , '01'         } )
	aAdd( aAux, { 'ZD3_MUSICA' , 'Musica 01'  } )
	aAdd( aCposDet, aAux )

	aAux := {}
	aAdd( aAux, { 'ZD3_ITEM'   , '02'         } )
	aAdd( aAux, { 'ZD3_MUSICA' , 'Musica 02'  } )
	aAdd( aCposDet, aAux )

	If !Import( 'ZD2', 'ZD3', aCposCab, aCposDet )
		lRet := .F.
	EndIf


Return lRet


//-------------------------------------------------------------------
Static Function Import( cMaster, cDetail, aCpoMaster, aCpoDetail )

	Local  oModel, oAux, oStruct
	Local  nI        := 0
	Local  nJ        := 0
	Local  nPos      := 0
	Local  lRet      := .T.
	Local  aAux	     := {}
	Local  nItErro   := 0
	Local  lAux      := .T.

	dbSelectArea( cDetail )
	dbSetOrder( 1 )

	dbSelectArea( cMaster )
	dbSetOrder( 1 )

	// Aqui ocorre o instanciamento do modelo de dados (Model)
	// Neste exemplo instanciamos o modelo de dados do fonte ZMVC03
	// que � a rotina de manuten��o de musicas
	oModel := FWLoadModel( 'ZMVC03' )

	// Temos que definir qual a opera��o deseja: 3 � Inclus�o / 4 � Altera��o / 5 - Exclus�o
	oModel:SetOperation( MODEL_OPERATION_INSERT )

	// Antes de atribuirmos os valores dos campos temos que ativar o modelo
	// Se o Modelo nao puder ser ativado, talvez por uma regra de ativacao
	// o retorno sera .F.
	lRet := oModel:Activate()

	If lRet

		// Instanciamos apenas a parte do modelo referente aos dados de cabe�alho
		oAux    := oModel:GetModel( cMaster + 'MASTER' )

		// Obtemos a estrutura de dados do cabe�alho
		oStruct := oAux:GetStruct()
		aAux	:= oStruct:GetFields()

		If lRet
			For nI := 1 To Len( aCpoMaster )

				// Verifica se os campos passados existem na estrutura do cabe�alho
				If ( nPos := aScan( aAux, { |x| AllTrim( x[3] ) ==  AllTrim( aCpoMaster[nI][1] ) } ) ) > 0

					// � feita a atribuicao do dado aos campo do Model do cabe�alho
					If !( lAux := oModel:SetValue( cMaster + 'MASTER', aCpoMaster[nI][1], aCpoMaster[nI][2] ) )

						// Caso a atribui��o n�o possa ser feita, por algum motivo (valida��o, por exemplo)
						// o m�todo SetValue retorna .F.
						lRet    := .F.
						Exit

					EndIf
				EndIf
			Next
		EndIf
	EndIf

	If lRet
		// Intanciamos apenas a parte do modelo referente aos dados do item
		oAux     := oModel:GetModel( cDetail + 'DETAIL' )

		// Obtemos a estrutura de dados do item
		oStruct  := oAux:GetStruct()
		aAux	 := oStruct:GetFields()

		nItErro  := 0

		For nI := 1 To Len( aCpoDetail )
			// Inclu�mos uma linha nova
			// ATENCAO: O itens s�o criados em uma estrura de grid (FORMGRID), portanto j� � criada uma primeira
			// linha em branco automaticamente, desta forma come�amos a inserir novas linhas a partir da 2� vez

			If nI > 1

				// Incluimos uma nova linha de item

				If  ( nItErro := oAux:AddLine() ) <> nI

					// Se por algum motivo o metodo AddLine() n�o consegue incluir a linha,
					// ele retorna a quantidade de linhas j�
					// existem no grid. Se conseguir retorna a quantidade mais 1
					lRet    := .F.
					Exit

				EndIf

			EndIf

			For nJ := 1 To Len( aCpoDetail[nI] )

			// Verifica se os campos passados existem na estrutura de item
				If ( nPos := aScan( aAux, { |x| AllTrim( x[3] ) ==  AllTrim( aCpoDetail[nI][nJ][1] ) } ) ) > 0

					If !( lAux := oModel:SetValue( cDetail + 'DETAIL', aCpoDetail[nI][nJ][1], aCpoDetail[nI][nJ][2] ) )

						// Caso a atribui��o n�o possa ser feita, por algum motivo (valida��o, por exemplo)
						// o m�todo SetValue retorna .F.
						lRet    := .F.
						nItErro := nI
						Exit

					EndIf
				EndIf
			Next

			If !lRet
				Exit
			EndIf

		Next

	EndIf

	If lRet
		// Faz-se a valida��o dos dados, note que diferentemente das tradicionais "rotinas autom�ticas"
		// neste momento os dados n�o s�o gravados, s�o somente validados.
		If ( lRet := oModel:VldData() )

			// Se o dados foram validados faz-se a grava��o efetiva dos dados (commit)
			lRet := oModel:CommitData()

		EndIf
	EndIf

	If !lRet

		// Se os dados n�o foram validados obtemos a descri��o do erro para gerar LOG ou mensagem de aviso
		aErro   := oModel:GetErrorMessage()

		// A estrutura do vetor com erro �:
		AutoGrLog( "Id do formul�rio de origem:" + ' [' + AllToChar( aErro[1] ) + ']' )
		AutoGrLog( "Id do campo de origem:     " + ' [' + AllToChar( aErro[2] ) + ']' )
		AutoGrLog( "Id do formul�rio de erro:  " + ' [' + AllToChar( aErro[3] ) + ']' )
		AutoGrLog( "Id do campo de erro:       " + ' [' + AllToChar( aErro[4] ) + ']' )
		AutoGrLog( "Id do erro:                " + ' [' + AllToChar( aErro[5] ) + ']' )
		AutoGrLog( "Mensagem do erro:          " + ' [' + AllToChar( aErro[6] ) + ']' )
		AutoGrLog( "Mensagem da solu��o:       " + ' [' + AllToChar( aErro[7] ) + ']' )
		AutoGrLog( "Valor atribuido:           " + ' [' + AllToChar( aErro[8] ) + ']' )
		AutoGrLog( "Valor anterior:            " + ' [' + AllToChar( aErro[9] ) + ']' )

		If nItErro > 0
			AutoGrLog( "Erro no Item:          " + ' [' + AllTrim( AllToChar( nItErro ) ) + ']' )
		EndIf

		MostraErro()

	EndIf

	// Desativamos o Model
	oModel:DeActivate()

Return lRet
