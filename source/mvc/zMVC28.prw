#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßß {Protheus.doc} ZMVC28 ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
ßß   Exemplo de montagem da modelo e interface para uma tabela em MVC,                ßß
ßß   utilizando NEW MODEL para um rotina desenvolvida em MVC                          ßß
ßß   @author Renato Silva                                                             ßß
ßß   @since 06/04/2024                                                                ßß
ßß   @obs Atualizacoes > Model-View-Control > Modelo 03 > Import de CDs/Musicas       ßß
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function ZMVC28()

	Local oBrowse := GetValType('O')
				
	NEW MODEL                              ;
	TYPE 		    3                      ;
	DESCRIPTION 	"Musicas"              ;
	BROWSE      	oBrowse                ;
	SOURCE      	"ZMVC28"               ;
	MODELID     	"MZMVC28"              ;
	MASTER      	"ZD2"                  ;
	DETAIL      	"ZD3"                  ;
	RELATION    	{ {'ZD3_FILIAL', 'FWxFilial("ZD3")'}, {'ZD3_CD', 'ZD2_CD'} } ;
	ORDERKEY		ZD3->( IndexKey( 1 ) ) ;
	PRIMARYKEY      {}                     ;
	AUTOINCREMENT   'ZD3_ITEM';
          
Return NIL


/*
NEW MODEL
TYPE: <nTipo 1 / 2 / 3>
DESCRIPTION: <cDescricaoRotina>
BROWSE: <oBrowse>
SOURCE: <cNomeFonte>
MODELID: <cModelID>
FILTER: <cFiltro>
CANACTIVE: <bSetVldActive = Bloco para validação da ativação do Model. Recebe como parâmetro o Model>
PRIMARYKEY: <aPrimaryKey>
MASTER <cMasterAlias>
HEADER <aHeader,...>
BEFORE <bBeforeModel>
AFTER <bAfterModel>
COMMIT <bCommit>
CANCEL <bCancel>
BEFOREFIELD <bBeforeField>
AFTERFIELD <bAfterField>
LOAD <bFieldLoad>
DETAIL <cDetailAlias>
BEFORELINE <bBeforeLine>
AFTERLINE <bAfterLine>
BEFOREGRID <bBeforeGrid>
AFTERGRID <bAfterGrid>
LOADGRID <bGridLoad>
RELATION <aRelation>
ORDERKEY <cOrder>
UNIQUELINE <aUniqueLine>
AUTOINCREMENT <cFieldInc>
OPTIONAL
*/
