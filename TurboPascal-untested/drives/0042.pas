{****************************************************************************
 * Procedure ..... SetDrive()
 * Purpose ....... To set the current drive
 * Parameters .... i          Drive number to change to (0=A, 1=B, 2=C, etc.)
 * Returns ....... N/A
 * Notes ......... None
 * Author ........ Martin Richardson
 * Date .......... May 13, 1992
 ****************************************************************************}
PROCEDURE SetDrive( i : INTEGER ); ASSEMBLER;
ASM
     MOV  AH, 0Eh
     MOV  DL, BYTE PTR i
     INT  21h
END;

{****************************************************************************
 * Procedure ..... SetCDrive()
 * Purpose ....... To set the current drive
 * Parameters .... c          Drive letter to change to
 * Returns ....... N/A
 * Notes ......... Same as SetDrive, but you pass the drive letter instead of
 *                 number.
 *               . Uses function SetDrive
 * Author ........ Martin Richardson
 * Date .......... May 13, 1992
 ****************************************************************************}
PROCEDURE SetCDrive( c :CHAR );
BEGIN
     IF ( c IN ['A'..'Z'] ) THEN
        SetDrive( POS( c, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ' ) - 1 );
END;

