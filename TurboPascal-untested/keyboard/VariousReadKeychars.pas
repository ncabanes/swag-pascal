(*
  Category: SWAG Title: KEYBOARD I/O ROUTINES
  Original name: 0023.PAS
  Description: Various READ Key/Chars
  Author: SWAG SUPPORT TEAM
  Date: 05-29-93  08:53
*)

{
Author : GAYLE DAVIS

I have seen a number of messages recently about keyboard access.  Here are
some neat FAST routines to use instead of ReadKey (Crt Unit).  Be advised
that in these routines, I add 128 to the HI Byte in order to be able to use
all 256 Characters.  Just remember to add 128 to test For all Function keys.
}

Uses
  Dos;

Function GetKey (Var Key : Word) : Boolean; Assembler;
{ determine if key pressed and return it as a Word }
{ if Lo(key) = 0 and Hi(key) <> 0 then we have a FN key ! }
Asm
  MOV     AH, 1
  INT     16H
  MOV     AL, 0
  JE      @@1
  xor     AH, AH
  INT     16H
  LES     DI, Key
  MOV     Word PTR ES : [DI], AX
  MOV     AL, 1
 @@1 :
end;

Function GetChar (Var Key : Char) : Boolean;
{ determine if key pressed and return it as a Char}
Var
  c : Word;
begin
  Key := #0;
  if GetKey (c) then
  begin
    GetChar := True;
    if (LO (c) = 0) and (HI (c) <> 0) then
      Key := CHR ( HI (c) + 128 )  { add 128 For FN keys }
    else
      Key := CHR (LO (c) );
  end
  else
    GetChar := False;
end;

Function KeyReady : Char;
{ looks For and PEEKS at Char but DOES not read it out of buffer }
{ returns the Char it finds or #0 if no Character waiting        }
Var
  Regs : Registers;
  Key  : Byte;
begin
  Regs.AH := 1;                          { determine if a key has been }
  INTR ( $16, Regs );                    { converted to a key code     }
  if ( Regs.Flags and FZERO = 0 ) then
  begin                          { yes, Character now in keyboard buffer }
                                 { determine what it is }
    if ( Regs.AL = 0 ) then
      Key := Regs.AH + 128
    else
      Key := Regs.AL;
  end
  else
    Key := 0;
  KeyReady := CHR (Key);
end;

Procedure ClearKeyBuffer;
Var
  Regs : Registers;
begin
  Regs.AH := 0;                { Clear ENTIRE keyboard }
  INTR ( $16, Regs );          { buffer via the BIOS   }
end;

Function AnyKeyPressed (Ch : Char; Clear : Boolean) : Boolean;
{ Check if a Character is present in buffer, and optionally clears it }
Var
  Key  : Char;
  Regs : Registers;

begin
  Key := KeyReady;
  AnyKeyPressed := (Key = Ch);
  if (Key = Ch) and Clear then
    ClearKeyBuffer;
end;

