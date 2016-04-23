{
> I have always addressed $B800 as the screen segment for direct video
> writes in text.... Err, umm, does anyone have the code to detect whether
> it is $B000 or $B800 (for Herc.'s and the like)...
}

Function ColorAdaptor: Boolean; Assembler; {returns TRUE for color monitor}
asm
  int 11                   {BIOS call - get equipment list}
  and ax, $0030            {mask off all but bits 4 & 5}
  xor ax, $0030            {flip bits 4 & 5 - return val is in ax}
end;

{
This function uses a BIOS interrupt to get the equipment list(at $0000:$0410)
as determined at time of power-up.  The only problem I can see here is that
a TRUE(non-zero value in al) will also be returned if no video card was
detected at power-up.
}