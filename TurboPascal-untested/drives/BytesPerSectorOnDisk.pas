(*
  Category: SWAG Title: DISK DRIVE HANDLING ROUTINES
  Original name: 0041.PAS
  Description: Bytes per sector on disk
  Author: MARTIN RICHARDSON
  Date: 09-26-93  08:47
*)

{*****************************************************************************
 * Function ...... BytesPerSector()
 * Purpose ....... To return the number of bytes per sector of a disk
 * Parameters .... nDrive          Drive containing disk
 * Returns ....... The number of bytes per sector of the specified disk
 * Notes ......... None
 * Author ........ Martin Richardson
 * Date .......... May 13, 1992
 *****************************************************************************}
FUNCTION BytesPerSector( nDrive: BYTE ): INTEGER;
VAR 
   Regs: Registers;
BEGIN
     Regs.AH := $1C;
     Regs.DL := nDrive;
     MSDOS( Regs );
     BytesPerSector := Regs.AL * Regs.CX;
END;


