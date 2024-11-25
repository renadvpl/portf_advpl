#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWMBROWSE.CH"

User function gpea030()

    Local aParam   := PARAMIXB
    Local cIdPonto := ''
    Local xRet     := .T.

    if aParam <> NIL
        cIdPonto := aParam[2]

        if cIdPonto == "FORMCOMMITTTSPOS"
            dbSelectArea("SQ3")
            dbSetOrder(1)

            if SQ3->( dbSeek( FWxFilial("SQ3")+SRJ->RJ_FUNCAO ) )
                RecLock("SQ3",.F.)
            else
                RecLock("SQ3",.T.)
            endif
                    SQ3->Q3_FILIAL  := FWxFilial("SQ3")
                    SQ3->Q3_CARGO   := SRJ->RJ_FUNCAO
                    SQ3->Q3_DESCSUM := SRJ->RJ_DESC
                    SRJ->RJ_CARGO   := SRJ->RJ_FUNCAO // Associar o cargo replicado à função cadastrada.
                    SQ3->Q3_CBO     := SRJ->RJ_CODCBO
                    SQ3->Q3_ADTPCAR := SRJ->RJ_ADTPFUN
                    SQ3->Q3_ADTPJU  := SRJ->RJ_ADTPJU
                    SQ3->Q3_ADTPESC := SRJ->RJ_ADTPESC
                    SQ3->Q3_ADATIV  := SRJ->RJ_ADATIV
                    SQ3->Q3_ADTPROV := SRJ->RJ_ADTPROV
                    SQ3->Q3_ADHORAS := SRJ->RJ_ADHORAS
                    SQ3->Q3_ACUM    := SRJ->RJ_ACUM
                    SQ3->Q3_CTESP   := SRJ->RJ_CTESP
                    SQ3->Q3_DEDEXC  := SRJ->RJ_DEDEXC
                    SQ3->Q3_LEI     := SRJ->RJ_LEI
                    SQ3->Q3_DTLEI   := SRJ->RJ_DTLEI
                    SQ3->Q3_SIT     := SRJ->RJ_SIT
                SQ3->( MSUnLock() )

            FWAlertSuccess("Cargo replicado com sucesso.","Cargo")

        endIf

        SQ3->( dbCloseArea() )

    endif

Return xRet
