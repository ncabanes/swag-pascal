{
> How would one find the diffrence between a 43 line monitor and a 50
> line monitor?

At least VGA is required for 50 lines of 16-color text.  At least EGA is
required for the 43 lines.  Simply test the video BIOS to identify a VGA.

Those displays use an 8x8 font so multiply the number of lines by 8. VGA 50*8
= 400 lines which is greater than EGA vertical resolution of 350. For 25 line
display, VGA uses 8x16y font and EGA uses 8x14y font.
}

procedure OnlyVGA; assembler;
asm
  @CheckForVga: {push    es}
                mov     AH,1ah       {Get Display Combination Code}
                mov     AL,00h       {AX := $1A00;}
                int     10h          {Intr($10, Regs);}
                cmp     AL,1ah       {IsVGA:= (AL=$1A) AND((BL=7) OR(BL=8))}
                jne     @NoVGA
                cmp     BL,07h       {VGA w/ monochrome analog display}
                je      @VgaPresent
                cmp     BL,08h       {VGA w/ color analog display}
                je      @VgaPresent
  @NoVGA:
                mov     ax,0003h     {text mode}
                int     10h
                push    cs
                pop     ds
                lea     dx,@message
                mov     ah,9
                int     21h          {print $ terminated string}
                mov     ax,4c00h
                int     21h          {terminate}
  @message:     db      'Sorry, but you need a VGA to see this!',10,13,24h
  @VgaPresent:  {pop     es}
  {After here is where your VGA code can execute}
end;  {OnlyVGA}

