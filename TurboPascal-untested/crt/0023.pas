{
ML>Basically a function that allows me to have 3 lines at the top non scrollabl
ML>(that I can change, the content of the lines), but so the stuff underthem
ML>scrolles...

Well, when you don't like the way the BIOS scrolls the screen, change
the BIOS!

Here's an interesting program that I just wrote for this purpose.  It
installs a TSR-like program that interferes with the BIOS scroll-up
routine and forces the top to be a variable you set.

While debugging the program, I ran into a bit of trouble with the way
that TP handles interrupts.  If you notice, half of the ISR has turned
into restoring the registers that TP trashes!
========================================================================
}
Uses Dos, Crt; {Crt only used by main pgm}

var
  TopLine : byte;
  V       : STRING;
  OldInt  : Procedure;

{Procedure Catch is the actual ISR, filtering out BIOS SCROLL-UP commands, and
 forcing the top of the scroll to be the value [TopLine] }

{$F+}
procedure Catch(Flags, rCS, rIP, rAX, rBX, rCX, rDX, rSI, rDI, rDS, rES, rBP: WORD); INTERRUPT;
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

  FUNCTION ItisTrue : BOOLEAN;
  BEGIN
  ItisTrue := (V <> 'quit');
  END;

begin
  ClrScr;
  DirectVideo := TRUE;
  TopLine := 5; {Keep 5+1 lines at top of screen}
  Install;
  GoToXY(1,24);
  WriteLn('Start Typing to see demo... type "quit" to stop ..');
  while Itistrue do readln(V);
  DeInstall;
end.
====================================================================
