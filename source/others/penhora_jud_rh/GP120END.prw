/* Biblioteca de Fun��es */
#include "protheus.ch"
#include "topconn.ch"

/*
����������������������������� {Protheus.doc} GP120END �����������������������������������
��                                                                                     ��
��   @description : Ponto-de-Entrada que permite a grava��o de informa��es             ��
��                  de campos do usu�rio ap�s o processamento completo do              ��
��                  Fechamento de um determinado roteiro                               ��
��   @author      : Renato Silva                                                       ��
��   @since       : 11/09/2024                                                         ��
��   @see         : https://tdn.totvs.com/pages/releaseview.action?pageId=507974069    ��
��                                                                                     ��
�����������������������������������������������������������������������������������������
*/

User Function GP120END()
    local aAreaZAK := ZAK->( FWGetArea() )
    local aRotPE   := PARAMIXB
    local cRotPE   := ""
    local cRotFOL  := 'FOL'
    local nOrder   := RetOrdem( "ZAK", "ZAK_FILIAL+ZAK_CODFIL" )
    local nIndex   := 0
    local lPenhora := FWAliasInDic('ZAK')

    for nIndex := 1 to Len( aRotPE )
        cRotPE += aRotPE[ nIndex, 1 ]
    next nIndex
    
    if lPenhora .and. ( cRotFOL $ cRotPE )
        dbSelectArea('ZAK')
        ZAK->( dbSetOrder( nOrder ), dbGotop() )
    
        while !ZAK->( EOF() )
            RecLock("ZAK", .F.)
                ZAK->ZAK_SLDATU := ZAK->ZAK_SLDCAL
                if ZAK->ZAK_SLDCAL == 0
                    ZAK->ZAK_STATUS := '2'
                endif
            ZAK->( MsUnLock() )
            ZAK->( dbSkip() )
        enddo

    endif

    ZAK->( dbCloseArea() )
    FWRestArea( aAreaZAK )

Return NIL
