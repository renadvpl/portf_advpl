Function U_ASSOCDOC(cPdRot)
    If P_LMEMCALC
       fAddMemLog('Fórmula : ' + 'U_ASSOCDOC' ,1)
    EndIf
    
    cVerbaRot := cPdRot
    
    Begin Sequence
        If ( AbortProc() )
            Break
        EndIf
    
        IF ( Empty(SRA->RA_XASSDOC) .and. !(SRA->RA_XASSDOC $ "01|06") )
    
            FGERAVERBA("556",FTABELA("U010",VAL(SRA->RA_XASSDOC),6),,,,)
    
        EndIF
    
    
    If P_LMEMCALC
       fGrvLogFun(GetRotExec(), cPeriodo, cSemana,'U_ASSOCDOC', aMenLog)
       aMenLog := {}
    EndIf
    
    End Sequence
Return
