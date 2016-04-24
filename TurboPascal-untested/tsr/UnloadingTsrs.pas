(*
  Category: SWAG Title: TSR UTILITIES AND ROUTINES
  Original name: 0037.PAS
  Description: Unloading TSRs
  Author: TOM MERTENS
  Date: 05-26-95  23:30
*)

{
> I don't know. That's what I'd like to know - how to unload a
> TSR! Ugh. I've been able to program a way to see if it's in
> memory, and modify the current data in it, but nothing more.

Hmmm... Well.... have a look at this code, it is a part from my TSR, I have
marked the procedures that are just for my TSR, and have made a seperate
function in the new interrupt to unload the TSR.  The unload part is written
in July 94 by Luis Mezquita Raya.  It seems to work :)
It is a TSR player for HSC files (by Chicken yep).
}

{$F+}
PROCEDURE New78Int(Flags,cs,ip,ax,bx,cx,dx,si,di,ds,es,bp:word); Interrupt;
BEGIN
  IF LO(ax) = 00 THEN BEGIN             {Installed?}
    ax := $6676; {BL}
    bx := $7984; {OT}
    IF Active THEN
      cx := $0001                       {Active}
    ELSE
      cx := $0000;                      {Inactive}
    dx := $0115                         {Version & Revision}
  END ELSE
  IF LO(ax) = 01 THEN BEGIN             {Play A File}
    IF Active THEN BEGIN
     FNamePTR := Ptr(bx,cx);
     MOVE(FNamePTR^, Filename, 256);
     IF Play(Filename) THEN
       ax := 00                         {Okay!}
     ELSE ax := 01;                     {Problemo}
    END ELSE
      ax := 01                          {Not Active!}
  END ELSE
  IF LO(ax) = 02 THEN BEGIN             {Quit playing}
     StopPlay;
  END ELSE
  IF LO(ax) = 03 THEN BEGIN             {Set State}
    cx := WORD(Active);                 {Former State Active}
    IF bx = 0 THEN Bossil_Active := FALSE;
    IF bx = 1 THEN Bossil_Active := TRUE;
  END;
  IF LO(ax) = 04 THEN BEGIN
      asm                               {THIS IS THE UNLOAD PROC}
                cli
                mov AH,49h
                mov ES,PrefixSeg
                push ES
                mov ES,ES:[2Ch]
                int 21h
                pop ES
                mov AH,49h
                int 21h
                sti
     end;
END;
END;
{$F-}

BEGIN {MAIN PROGRAM TO ILLUSTRATE CHECKING IF INSTALLED OR NOT}
  GetIntVec($78, Old78hInt);
  IF ((Old78hInt <> NIL) AND (ParamSTR(1) <> stopparam)) THEN BEGIN
    WRITELN('Interrupt Vector 78h Was Already Allocated!');
    HALT(0);
  END ELSE
  IF ((Old78hInt <> nil) AND (ParamSTR(1) = stopparam)) THEN BEGIN
    WRITELN('Desactivated!');
    ASM
      MOV AX,0004h
      INT 78h
    END;
    SetIntVec($78, NIL);
    HALT(0);
  END ELSE
  IF ParamSTR(1) = stopparam THEN BEGIN
    WRITELN('Not installed yet!  Could not desinstall!');
    HALT(0);
  END;
  ASM
    MOV AX,0000h
    INT 78h
    MOV AX, ID1
    MOV BX, ID2
  END;
  IF (ID1 = $6676) AND (ID2 = $7984) THEN BEGIN
    WRITELN('Already installed!  Not reinstalled')
    HALT(0);
  END;
    SetIntVec($78, @New78Int);
  WRITELN('Installed                    (c) 1995, BLoT');
  Active := TRUE;
  Keep(0);
END.
{
I left out the VAR part, but I guess you are smart enough to reconstruct that
one...  Anyway, it seems to work perfectely at my side, so...
}
