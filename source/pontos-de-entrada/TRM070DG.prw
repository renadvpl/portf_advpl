#include "totvs.ch"

/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßß {Protheus.doc} TRM070DG ßßßßßßßßßßßßßßßßßßßßßßßßß
ßß   @description   Gravação do líder do treinamento ao curso realizado    ßß
ßß                  pela matrícula                                         ßß
ßß   @author        Renato Silva                                           ßß
ßß   @since         20/07/2023                                             ßß
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User function TRM070DG()

    Local nPosMat    := aScan(aHeader, { |x| AllTrim(x[2]) == "RA4_MAT" })
    Local nPosCalend := aScan(aHeader, { |x| AllTrim(x[2]) == "RA4_CALEND" })
    Local nPosTurma  := aScan(aHeader, { |x| AllTrim(x[2]) == "RA4_TURMA" })
    Local nPosDtVal  := aScan(aHeader, { |x| AllTrim(x[2]) == "RA4_VALIDA" })
    Local nPosLider  := aScan(aHeader, { |x| AllTrim(x[2]) == "RA4_ULIDER" })
    Local nX         := 0  as Numeric
    Local cChave1    := "" as Character
    Local cChave2    := "" as Character    

    For nX := 1 To Len(aCols)
        cChave1 := aCols[nX][nPosMat] + aCols[nX][nPosCalend] + aCols[nX][nPosTurma] + ;
           RA2->RA2_CURSO + DtoS(aCols[nX][nPosDtVal])
        cChave2 := RA4->(RA4_MAT + RA4_CALEND + RA4_TURMA + RA4_CURSO + DtoS(RA4_VALIDA))

        If cChave1 == cChave2
            RA4->RA4_ULIDER := aCols[nX][nPosLider]
        EndIf
    Next nX

Return NIL
