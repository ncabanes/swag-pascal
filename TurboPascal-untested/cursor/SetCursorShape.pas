(*
  Category: SWAG Title: CURSOR HANDLING ROUTINES
  Original name: 0016.PAS
  Description: Set CURSOR Shape
  Author: MARTIN RICHARDSON
  Date: 09-26-93  09:27
*)

{****************************************************************************
 * Procedure ..... SetCursor()
 * Purpose ....... To set the cursor shape
 * Parameters .... nTop       Top line of cursor
 *                 nBottom    Bottom line of cursor
 * Returns ....... N/A
 * Notes ......... None
 * Author ........ Martin Richardson
 * Date .......... May 13, 1992
 ****************************************************************************}
PROCEDURE SetCursor( nTop, nBottom : INTEGER ); ASSEMBLER;
ASM
     MOV  AH, 1
     MOV  CH, BYTE PTR nTop
     MOV  CL, BYTE PTR nBottom
     INT  10h
END;


