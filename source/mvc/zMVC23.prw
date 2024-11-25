#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

/*
��������������������������� {Protheus.doc} ZMVC23 ��������������������������������������
��   Exemplo de importacao de dados para uma tabela simples                           ��
��   para um rotina desenvolvida em MVC                                               ��
��   @author Renato Silva                                                             ��
��   @since 06/04/2024                                                                ��
��   @obs Atualizacoes > Model-View-Control > Modelo 01 - Cad Artistas                ��
����������������������������������������������������������������������������������������
*/
User Function ZMVC23()

	Local aSay    := {}
	Local aButton := {}
	Local nOpc    := 0
	Local cTitulo := 'IMPORTACAO DE ARTISTAS'
	Local lOk     := .T.

	aAdd( aSay, 'Esta rotina fara a importacao de artistas,' )
	aAdd( aSay, 'conforme leiaute da tabela.' )
	aAdd( aSay, '')

	aAdd( aButton, { 1, .T., { || nOpc := 1, FechaBatch() } } )
	aAdd( aButton, { 2, .T., { || FechaBatch()            } } )

	FormBatch( cTitulo, aSay, aButton )

	If nOpc == 1

		Processa( { || lOk := Runproc() },'Aguarde','Processando...',.F.)

		If lOk
			ApMsgInfo( 'Processamento terminado com sucesso.', 'ATEN��O' )
		Else
			ApMsgStop( 'Processamento realizado com problemas.', 'ATEN��O' )
		EndIf

	EndIf

Return NIL


//-------------------------------------------------------------------
Static Function RunProc()

	Local lRet    := .T.
	Local aCampos := {}

	// Criamos um vetor com os dados para facilitar o manuseio dos dados
	aCampos := {}
	aAdd( aCampos, { 'ZD1_CODIGO' , '000007'      } )
	aAdd( aCampos, { 'ZD1_NOME'   , 'Villa Lobos' } )
	aAdd( aCampos, { 'ZD1_DTFORM' , CtoD('')      } )
	aAdd( aCampos, { 'ZD1_TIPO'   , 'C'           } )

	If !Import( 'ZD1', aCampos )
		lRet := .F.
	EndIf


	// Importamos outro registro
	aCampos := {}
	aAdd( aCampos, { 'ZD1_CODIGO' , '000011'    } )
	aAdd( aCampos, { 'ZD1_NOME'   , 'Tom Jobim' } )
	aAdd( aCampos, { 'ZD1_DTFORM' , CtoD('')    } )
	aAdd( aCampos, { 'ZD1_TIPO'   , 'C'         } )

	If !Import( 'ZD1', aCampos )
		lRet := .F.
	EndIf


	// Importamos outro registro
	aCampos := {}
	aAdd( aCampos, { 'ZD1_CODIGO' , '000012'          } )
	aAdd( aCampos, { 'ZD1_NOME'   , 'Emilio Santiago' } )
	aAdd( aCampos, { 'ZD1_DTFORM' , CtoD('')          } )
	aAdd( aCampos, { 'ZD1_TIPO'   , 'I'               } )

	If !Import( 'ZD1', aCampos )
		lRet := .F.
	EndIf


	// Importamos outro registro
	aCampos := {}
	aAdd( aCampos, { 'ZD1_CODIGO' , '000013'      } )
	aAdd( aCampos, { 'ZD1_NOME'   , 'Clara Nunes' } )
	aAdd( aCampos, { 'ZD1_DTFORM' , CtoD('')      } )
	aAdd( aCampos, { 'ZD1_TIPO'   , 'I'           } )

	If !Import( 'ZD1', aCampos )
		lRet := .F.
	EndIf


	// Importamos outro registro
	aCampos := {}
	aAdd( aCampos, { 'ZD1_CODIGO' , '000014'     } )
	aAdd( aCampos, { 'ZD1_NOME'   , 'Zizi Possi' } )
	aAdd( aCampos, { 'ZD1_DTFORM' , CtoD('')     } )
	aAdd( aCampos, { 'ZD1_TIPO'   , 'C'          } )

	If !Import( 'ZD1', aCampos )
		lRet := .F.
	EndIf


	// Importamos outro registro
	aCampos := {}
	aAdd( aCampos, { 'ZD1_NOME'   , 'Forca Erro' } )
	aAdd( aCampos, { 'ZD1_DTFORM' , CtoD('')     } )
	aAdd( aCampos, { 'ZD1_TIPO'   , 'X'          } )

	If !Import( 'ZD1', aCampos )
		lRet := .F.
	EndIf

Return lRet


//-------------------------------------------------------------------
Static Function Import( cMaster , aCpoMaster )

	Local oModel, oAux, oStruct
	Local nI      := 0
	Local nPos    := 0
	Local lRet    := .T.
	Local aAux	  := {}
	Local nItErro := 0
	Local lAux    := .T.

	dbSelectArea( cMaster )
	dbSetOrder( 1 )

	// Aqui ocorre o instanciamento do modelo de dados (Model)
	// Neste exemplo, instanciamos o modelo de dados do fonte ZMVC01
	// que � a rotina de manuten��o de artistas
	oModel := FWLoadModel( 'ZMVC01' )

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
					
					// Eh feita a atribuicao do dado aos campos do Model do cabe�alho
					If !( lAux := oModel:SetValue( cMaster + 'MASTER', aCpoMaster[nI][1], aCpoMaster[nI][2] ) )
						// Caso a atribui��o n�o possa ser feita, por algum motivo (valida��o, por exemplo)
						// o m�todo SetValue retorna .F.
						lRet    := .F.
						Exit
					EndIf
				EndIf
			Next
		EndIf
		
		
		If lRet
			// Faz-se a valida��o dos dados, note que diferentemente das tradicionais "rotinas autom�ticas"
			// neste momento os dados n�o s�o gravados, s�o somente validados.
			If ( lRet := oModel:VldData() )
				// Se o dados foram validados, faz-se a grava��o efetiva dos dados (commit)
				lRet := oModel:CommitData()
			EndIf
		EndIf
	EndIf

	If !lRet
		// Se os dados n�o foram validados, obtemos a descri��o do erro para gerar LOG ou mensagem de aviso
		aErro   := oModel:GetErrorMessage()

		// A estrutura do vetor com erro �:
		AutoGrLog( "Id do formul�rio de origem:" + ' [' + AllToChar( aErro[1]  ) + ']' )
		AutoGrLog( "Id do campo de origem:     " + ' [' + AllToChar( aErro[2]  ) + ']' )
		AutoGrLog( "Id do formul�rio de erro:  " + ' [' + AllToChar( aErro[3]  ) + ']' )
		AutoGrLog( "Id do campo de erro:       " + ' [' + AllToChar( aErro[4]  ) + ']' )
		AutoGrLog( "Id do erro:                " + ' [' + AllToChar( aErro[5]  ) + ']' )
		AutoGrLog( "Mensagem do erro:          " + ' [' + AllToChar( aErro[6]  ) + ']' )
		AutoGrLog( "Mensagem da solu��o:       " + ' [' + AllToChar( aErro[7]  ) + ']' )
		AutoGrLog( "Valor atribuido:           " + ' [' + AllToChar( aErro[8]  ) + ']' )
		AutoGrLog( "Valor anterior:            " + ' [' + AllToChar( aErro[9]  ) + ']' )

		If nItErro > 0
			AutoGrLog( "Erro no Item:          " + ' [' + AllTrim( AllToChar( nItErro  ) ) + ']' )
		EndIf

		MostraErro()

	EndIf

	// Desativamos o Model
	oModel:DeActivate()

Return lRet
