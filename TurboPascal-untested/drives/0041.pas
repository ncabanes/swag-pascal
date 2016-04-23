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