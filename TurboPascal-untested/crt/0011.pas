{****************************************************************************
 * Procedure ..... Scroll()
 * Purpose ....... Scroll the screen either up or down
 * Parameters .... nRow       Top row of scroll area
 *                 nCol       Left column of scroll area
 *                 nRows      Number of rows in scroll area
 *                 nCols      Number of cols in scroll area
 *                 nLines     Number of lines to scroll
 *                 nDirect    Direction to scroll in indicator
 *                 nAttr      Color attribute to leave behind
 * Returns ....... Nothing
 * Notes ......... A 0 for nDirect will scroll the screen up, a 1 will
 *                 scroll it down.
 * Author ........ Martin Richardson
 * Date .......... October 2, 1992
 ****************************************************************************}
PROCEDURE Scroll( nRow, nCol, nRows, nCols, nLines, nDirect, nAttr: BYTE ); assembler;
ASM
        MOV     CH, nRow
        DEC     CH
        MOV     CL, nCol
        DEC     CL
        MOV     DH, nRows
        ADD     DH, CH
        DEC     DH
        MOV     DL, nCols
        ADD     DL, CL
        DEC     DL
        MOV     BH, nAttr
        MOV     AL, nLInes

        MOV     AH, nDirect
        AND     AH, 1
        OR      AH, 6

        INT     10h
END;
