(*
  Category: SWAG Title: TSR UTILITIES AND ROUTINES
  Original name: 0040.PAS
  Description: Sample for Unloading a TSR
  Author: LARRY HADLEY
  Date: 09-04-95  11:56
*)

{
 **********************************************
 * CLICK.PAS by Larry Hadley  2-02-1993       *
 * donated to the public domain. if you use   *
 * this code or derive from it, credit would  *
 * be appreciated.                            *
 ********************************************** }

{$S-,N-}
{$M 1024, 0, 0}
Program CLICK;

Uses
  Crt,Dos;

Var
  SavedInt09h,
  SavedInt66h  :Pointer;

Procedure keyClick;
begin
  Sound(50);
  Delay(1);
  NoSound;
end;

Procedure Int09h; interrupt;
begin
  keyClick;           { Sound click everytime called -
                        this is clumsy because key releases as
                        well as keypresses are signalled. Good
                        thing this is For demo only! :-) }
  Asm
    pushf            { push flags to simulate "int" call }
    call SavedInt09h { pass control to original int09 handler -
                       necessary to allow keyboard use. Also
                       demo's chaining of interrupts. }
  end;
end;

Procedure Int66h(AX, BX, CX, DX, SI, DI, DS, ES, BP:Word); interrupt;
Var
  int09new :Pointer;
begin
  if AX<>$FFFF then
    Exit;            { not our call, leave }

  GetIntVec($09, int09new);
  if int09new<>@int09h then
    Exit;            { interrupt vectors have been changed. }

  SetIntVec($09, SavedInt09h); { restore interrupt vectors }
  SetIntVec($66, SavedInt66h);

  MemW[PrefixSeg:$16] := BX; { modify PSP to return to calling }
  MemW[PrefixSeg:$0A] := DI; { Program... }
  MemW[PrefixSeg:$0C] := ES;

  Asm
    mov ah, $50
    mov bx, PrefixSeg
    push ds
    int $21            { set conText }
    pop ds
  end;
  AX := 0;        { tell caller "no error" }
end;

begin   { main - t.s.r. init code }
  GetIntVec($09, SavedInt09h);
  GetIntVec($66, SavedInt66h);

  SetIntVec($09, @Int09h);
  SetIntVec($66, @Int66h);

  Writeln('Click TSR installed.');

  Keep(0);
end.

{************************************************
 * CLICKU.PAS by Larry Hadley  2-02-1993        *
 * CLICK T.S.R. removal Program                 *
 * released into the public domain. if you use  *
 * this code or derive from it, credit would be *
 * appreciated.                                 *
 ************************************************}

{$S-,N-}
Program CLICKU;

Uses
  Dos;

Var
  rtn_seg,
  rtn_ofs  : Word;
  return   : Pointer;

Label int66_error;

Procedure Exit_Label; { ...to provide an address For Dos return to }
begin
  Halt(0);  { I haven't been able to establish For sure that
              this code regains control here. BTW, Brian I have
              code to save DS and restore upon return to this
              Program if you're interested.  This would allow
              using global Variables to save SS:SP. Int 21h func
              $4C destroys DS (and just about everything else)
              on Exit...}
end;

begin
  return := @exit_Label;
  rtn_seg := SEG(return^);
  rtn_ofs := ofS(return^);
  Asm
    mov ax, $FFFF
    mov bx, PrefixSeg
    mov es, rtn_seg
    mov di, rtn_ofs      { pass parms in Registers ax, bx, es, di}
    int $66              { call i.s.r. uninstall Function }
    cmp ax, 0
    jne int66_error      { i.s.r. has returned error }
  end;
  Writeln('Click TSR uninstalled.');
  Asm
    mov ah, $4C
    int $21              { Dos terminate }
  end;

  int66_error:
  Writeln('Error removing TSR.');
  Halt(1);
end.

