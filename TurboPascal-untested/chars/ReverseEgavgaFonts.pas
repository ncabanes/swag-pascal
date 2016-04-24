(*
  Category: SWAG Title: CHARACTER HANDLING
  Original name: 0009.PAS
  Description: Reverse EGA/VGA Fonts
  Author: RICHARD WILTON
  Date: 11-26-93  18:06
*)

program Reverse;

{
  Sample program demonstrating manipulation of the VGA (EGA?)
  alphanumeric character set using the 80x25 character mode.

  The only thing this program does is to copy the current character
  set from the video adapter, and restore it in such a way that all
  the characters appear upside-down.  To restore the characters,
  simply run the program again.  Not that this is a terribly useful
  thing to do, mind you...

  NOTE: This has not been tested on monochrome monitors or in
        other video modes.

  Written using Borland Pascal 7.0.

  For more information on character sets for other video modes and
  a whole bunch of good stuff on the EGA & VGA in general, you will
  want the following book:

   Title     - "Programmer's Guide to PC & PS/2 Video Systems"
   Author    - Richard Wilton, 1987
   Publisher - Microsoft Press
               16011 NE 36th Way
               Box 97017
               Redmond, Washington  98073-9717
}

  var
    I, J: integer;
    CBuf: array [0..8191] of byte; { Buffer for original character map }


  procedure CharGenModeOn;

  { I'm sorry that there is no explanation here, but I did this a while
    ago and I don't have the reference with me right now.   }

    begin
      asm
        cli
        mov       dx,03C4h
        mov       ax,0100h
        out       dx,ax
        mov       ax,0402h
        out       dx,ax
        mov       ax,0704h
        out       dx,ax
        mov       ax,0300h
        out       dx,ax
        sti
        mov       dl,0CEh
        mov       ax,0204h
        out       dx,ax
        mov       ax,0005h
        out       dx,ax
        mov       ax,0006h
        out       dx,ax
     end;
   end;


  procedure CharGenModeOff;

    begin
      asm
        cli
        mov       dx,03C4h
        mov       ax,0100h
        out       dx,ax
        mov       ax,0302h
        out       dx,ax
        mov       ax,0304h
        out       dx,ax
        mov       ax,0300h
        out       dx,ax
        sti
        mov       dl,0CEh
        mov       ax,0004h
        out       dx,ax
        mov       ax,1005h
        out       dx,ax
        mov       ax,0E06h
        out       dx,ax
        mov       ah,0Fh
        int       10h
        cmp       al,7
        jne       @skip
        mov       ax,0806h
        out       dx,ax
      @skip:
      end;
    end;


  begin
    CharGenModeOn;  { Get access to character map }

    { Copy the current character map into the buffer }
    move( mem[$A000: 0], CBuf, 8192 );

    { Restore the map, inverting the top 16 scan lines.

      Characters are stored in a 8x32 pixel matrix, allowing
      for characters that are 32 scan lines high.  Each byte
      in the buffer represents one scan line of a single
      character.  In the 80x25 character mode only the first
      16 scan lines are displayed, so we need to be a little
      careful about what bytes are swapped. }

    for I := 0 to 255 do                { Each of the 256 characters }
      for J := 0 to 15 do               { Top 16 scan lines of each }
        mem[$a000:((I*32) + J)] := CBuf[(I*32) + (15 - J)];

    CharGenModeOff; { Restore normal video operations }
  end.

