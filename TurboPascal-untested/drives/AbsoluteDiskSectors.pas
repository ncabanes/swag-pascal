(*
  Category: SWAG Title: DISK DRIVE HANDLING ROUTINES
  Original name: 0102.PAS
  Description: Absolute Disk Sectors
  Author: EDDY THILLEMAN
  Date: 09-04-95  10:57
*)


FUNCTION ReadSector(drive, head, track, sector : Byte; buff: Pointer): Byte;
{ drive = 0 for drive A:, 1 = B:,   }
{ 80h = first hard drive.           }
ASSEMBLER; ASM
    mov  ax, 0201h      { read 1 sector }
    les  bx, [buff]     { es:bx -> buffer }
    mov  ch, [track]
    mov  cl, [sector]
    mov  dh, [head]
    mov  dl, [drive]
    int  13h
    mov  al, ah         { status result in al }
END;


FUNCTION WriteSector(drive, head, track, sector : Byte; buff: Pointer): Byte;
{ drive = 0 for drive A:, 1 = B:,   }
{ 80h = first hard drive.           }
ASSEMBLER; ASM
    mov  ax, 0301h      { read 1 sector }
    les  bx, [buff]     { es:bx -> buffer }
    mov  ch, [track]
    mov  cl, [sector]
    mov  dh, [head]
    mov  dl, [drive]
    int  13h
    mov  al, ah         { status result in al }
END;

