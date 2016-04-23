{
> I was wondering if anywone could tell me how to read
> the partition table off of a hard drive directly through the BIOS.

This routine should work for any sector. It returns zero if no errors.
}
FUNCTION ReadSector(drive, head, track, sector : Byte;
         buff : Pointer): Byte;
{ drive = 0 for drive A:, 1 = B:,   }
{ 80h = first hard drive.           }
BEGIN
  ASM
    mov [@result], 0    { setup for no error }
    mov  ax, 0201h      { read 1 sector }
    les bx, [buff]      { es:bx -> buffer }
    mov ch, [track]
    mov cl, [sector]
    mov dh, [head]
    mov dl, [drive]
    int 13h
    jnc @@NoErr
      mov [@result], ah
    @@NoErr:
  END
END;

VAR
  buffer : Array[0..511] OF Byte;
BEGIN
  WriteLn('Result is ', ReadSector($80, 0, 0, 1, @buffer));
  ReadLn;
END.


