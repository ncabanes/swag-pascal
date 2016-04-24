(*
  Category: SWAG Title: DOS & ENVIRONMENT ROUTINES
  Original name: 0028.PAS
  Description: Redirect DOS I/O
  Author: MARTIN RICHARDSON
  Date: 09-26-93  09:28
*)

{****************************************************************************
 * Procedure ..... StandardIO
 * Purpose ....... To allow input/output redirection from the DOS command
 *                 line.
 * Parameters .... None
 * Returns ....... N/A
 * Notes ......... Normal TP writes do not allow i/o redirection.  This is a
 *                 fix for that.
 * Author ........ Martin Richardson
 * Date .......... May 13, 1992
 ****************************************************************************}
PROCEDURE StandardIO;
BEGIN
     ASSIGN( Input, '' );
     RESET( Input );
     ASSIGN( Output, '' );
     REWRITE( Output );
END;

