(*
  Category: SWAG Title: TSR UTILITIES AND ROUTINES
  Original name: 0029.PAS
  Description: Screen Scrool TSR
  Author: ERIK ANDERSON
  Date: 08-25-94  09:11
*)

{
>Basically a function that allows me to have 3 lines at the top non scrollabl
>(that I can change, the content of the lines), but so the stuff underthem
>scrolles...

Well, when you don't like the way the BIOS scrolls the screen, change
the BIOS!

Here's an interesting program that I just wrote for this purpose.  It
installs a TSR-like program that interferes with the BIOS scroll-up
routine and forces the top to be a variable you set.

While debugging the program, I ran into a bit of trouble with the way
that TP handles interrupts.  If you notice, half of the ISR has turned
into restoring the registers that TP trashes!
}
Uses Dos, Crt; {Crt only used by main pgm}

var
  TopLine : byte;
  OldInt  : Procedure;

{Procedure Catch is the actual ISR, filtering out BIOS SCROLL-UP commands, and
 forcing the top of the scroll to be the value [TopLine] }

{$F+}
procedure Catch(Flags, rCS, rIP, rAX, rBX, rCX, rDX, rSI, rDI, rDS, rES, rBP: Word); Interrupt;
{  Procedure Catch; interrupt;}
  begin {Catch}
    asm
      MOV  AX, Flags
      SAHF
      MOV  AX, rAX
      MOV  BX, rBX
      MOV  CX, rCX
      MOV  DX, rDX
      MOV  SI, rSI
      MOV  DI, rDI
      CMP  AH, 06
      JNE  @Pass
      CMP  CH, TopLine
      JA   @Pass
      MOV  CH, TopLine

@Pass:
    end;
    OldInt;          {Pass through to old handler}
    asm
      MOV  rAX, AX
      MOV  rBX, BX
      MOV  rCX, CX
      MOV  rDX, DX
      MOV  rSI, SI
      MOV  rDI, DI
    end;
  end; {Catch}
{$F-}

  Procedure Install;
  begin
    GetIntVec($10, Addr(OldInt));
    SetIntVec($10, Addr(Catch));
  end;

  Procedure DeInstall;
  begin
    SetIntVec($10, Addr(OldInt));
  end;

begin
  ClrScr;
  DirectVideo := TRUE;
  TopLine := 5; {Keep 5+1 lines at top of screen}
  Install;
  while true do readln;
end.

{
>p.p.s  I also need a routine (preferably in Turbo Pascal 7 ASM) that saves t
>       content of the current screen in an ANSI file on the disk.  I saw one
>       a while ago in SWAG, but I can't seem to find it now (I'm a dist site
>       but still can't find it).

Also, since I didn't have anything better to do, I sat down and did a
version of your screen->ANSI.  It's rather primitive... it does a 80x24
dump with auto-EOLn seensing, does no CRLF if the line is 80 chars long
(relies on screen wrap) and no macroing. If you want to, you can add
macroing, which replaces a number of spaces with a single ANSI 'set
cursor' command. Well, here goes...

}
  Procedure Xlate(var OutFile : text); {by Erik Anderson}
  {The screen is basically an array of elements, each element containing one
   a one-byte character and a one-byte color attribute}
  const
    NUMROWS = 25;
    NUMCOLS = 80;
  type
    ElementType = record
                    ch   : char;
                    Attr : byte;
                  end;
    ScreenType = array[1..NUMROWS,1..NUMCOLS] of ElementType;

  {The Attribute is structured as follows:
    bit 0: foreground blue element
    bit 1:     "      green element
    bit 2:     "      red element
    bit 3: high intensity flag
    bit 4: background blue element
    bit 5:     "      green element
    bit 6:     "      red element
    bit 7: flash flag

  The following constant masks help the program acess different parts
  of the attribute}
  const
    TextMask = $07; {0000 0111}
    BoldMask = $08; {0000 1000}
    BackMask = $70; {0111 0000}
    FlshMask = $80; {1000 0000}
    BackShft = 4;

    ESC = #$1B;

  {ANSI colors are not the same as IBM colors... this table fixes the
   discrepancy:}
    ANSIcolors : array[0..7] of byte = (0, 4, 2, 6, 1, 5, 3, 7);

    {This procedure sends the new attribute to the ANSI dump file}
    Procedure ChangeAttr(var Outfile : text; var OldAtr : byte; NewAtr : byte);
    var
      Connect : string[1]; {Is a seperator needed?}
    begin
      Connect := '';
      write(Outfile, ESC, '['); {Begin sequence}
      If (OldAtr AND (BoldMask+FlshMask)) <>     {Output flash & blink}
         (NewAtr AND (BoldMask+FlshMask)) then begin
        write(Outfile, '0');
        If NewAtr AND BoldMask <> 0 then write(Outfile, ';1');
        If NewAtr AND FlshMask <> 0 then write(Outfile, ';5');
        OldAtr := $FF; Connect := ';';   {Force other attr's to print}
      end;

      If OldAtr AND BackMask <> NewAtr AND BackMask then begin
        write(OutFile, Connect,
              ANSIcolors[(NewAtr AND BackMask) shr BackShft] + 40);
        Connect := ';';
      end;

      If OldAtr AND TextMask <> NewAtr AND TextMask then begin
        write(OutFile, Connect,
              ANSIcolors[NewAtr AND TextMask] + 30);
      end;

      write(outfile, 'm'); {Terminate sequence}
      OldAtr := NewAtr;
    end;

    {Does this character need a changing of the attribute?  If it is a space,
     then only the background color matters}

    Function AttrChanged(Attr : byte; ThisEl : ElementType) : boolean;
    var
      Result : boolean;
    begin
      Result := FALSE;
      If ThisEl.ch = ' ' then begin
        If ThisEl.Attr AND BackMask <> Attr AND BackMask then
          Result := TRUE;
      end else begin
        If ThisEl.Attr <> Attr then Result := TRUE;
      end;
      AttrChanged := Result;
    end;

  var
    Screen   : ScreenType absolute $b800:0000;
    ThisAttr, TestAttr : byte;
    LoopRow, LoopCol, LineLen : integer;
  begin {Xlate}
    ThisAttr := $FF; {Force attribute to be set}
    For LoopRow := 1 to NUMROWS do begin

      LineLen := NUMCOLS;   {Find length of line}
      While (LineLen > 0) and (Screen[LoopRow, LineLen].ch = ' ')
            and not AttrChanged($00, Screen[LoopRow, LineLen])
        do Dec(LineLen);

      For LoopCol := 1 to LineLen do begin {Send stream to file}
        If AttrChanged(ThisAttr, Screen[LoopRow, LoopCol])
          then ChangeAttr(Outfile, ThisAttr, Screen[LoopRow, LoopCol].Attr);
        write(Outfile, Screen[LoopRow, LoopCol].ch);
      end;
    If LineLen < 80 then writeln(OutFile); {else wraparound occurs}
    end;
  end; {Xlate}

var
  OutFile : text;
begin
  Assign(OutFile, 'dump.scn');
  Rewrite(OutFile);
  Xlate(OUtFile);
  Close(OUtFile);
end.

