(*
  Category: SWAG Title: COMMUNICATIONS/INT14 ROUTINES
  Original name: 0022.PAS
  Description: Simple Avatar code
  Author: SEAN PALMER
  Date: 08-27-93  20:06
*)

w{
SEAN PALMER

Using the state-driven approach, I came up With this simplistic
Avatar/0 interpreter as an example. Do With it as you wish...

by Sean L. Palmer
Public Domain
}

Program avtWrite;
{ example to do avatar/0 (FSC-0025) interpretation }
{ could easily be extended to handle /0+ and /1 codes }

Uses
  Crt;

{ this part of the Program controls the state-driven part of the display
  handler. }

Var
  saveAdr : Pointer;  { where state handler is now }
  c       : Char;     { Char accessed by state handler }
  b       : Byte Absolute c;

Procedure avtWriteCh(c2 : Char); Inline(
  $8F/$06/>C/            { pop Byte ptr [>c] }
  $FF/$1E/>SAVEADR);     { call dWord ptr [>saveAdr] }
                         { continue where handler l

                           call this Procedure from StateHandler to
                           suspend execution Until next time
}

Procedure wait; near; Assembler;
Asm                             { wait For next Char }
  pop Word ptr saveAdr          { save where to continue next time }
  retF                          { simulate Exit from calling proc }
end;

{
 a stateHandler Procedure should never ever Exit (only by calling 'wait'),
 shouldn't have any local Variables or parameters, and shouldn't call
 'wait' With anything on the stack (like from a subroutine).
 This routine is using the caller's stack, so be careful
}

Var
  avc : Char;
  avb : Byte Absolute avc;

Procedure stateHandler;
begin

  Repeat

    Case c of

      ^L :
        begin
          ClrScr;
          Textattr := 3;
        end;

      ^Y :
        begin
          wait;
          avc := c;
          wait;
          While c <> #0 do
          begin
            dec(c);
            Write(avc);
          end;
        end;

      ^V :
        begin
          wait;
          Case c of

            ^A :
              begin
                wait;
                Textattr := Byte(c);
              end;
            ^B : Textattr := Textattr or $80;
            ^C : if whereY > 1  then GotoXY(whereX, whereY - 1);
            ^D : if whereY < 25 then GotoXY(whereX, whereY + 1);
            ^E : if whereX > 1  then GotoXY(whereX - 1,whereY);
            ^F : if whereX < 80 then GotoXY(whereX + 1,whereY);
            ^G : clreol;
            ^H :
              begin
                wait;
                avb := b;
                wait;
                GotoXY(b + 1, avb + 1);
              end;
            else
              Write(^V, c);
          end;
        end;
      else
        Write(c);
   end;
   wait;
   Until False;
end;

Var
  i : Integer;
Const
  s : String = 'Oh my'^V^D^V^D^V^F^V^A#1'it works'^V^A#4',see?';
begin  {could do something like attach it to Output's InOutFunc...}
  saveAdr := ptr(seg(stateHandler), ofs(stateHandler) + 3); {skip header}
  For i := 1 to length(s) do
    avtWriteCh(s[i]);
end.

