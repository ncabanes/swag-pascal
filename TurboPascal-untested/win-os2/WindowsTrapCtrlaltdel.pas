(*
  Category: SWAG Title: WINDOWS & OS2 STUFF
  Original name: 0054.PAS
  Description: Windows Trap Ctrl/Alt/Del
  Author: MARC VAN LEEUWEN
  Date: 02-28-95  10:04
*)

PROGRAM NoReset;
{(c)1993 by Marc van Leeuwen. Fido 2:285/228 == Pascal-Net 115:115/0  }
{ ┌──────────┐ (c) 1993Use it as you want, it works for me, }
{ │SW-Program│ LSharP but it might not work for you, so use}
{ └──────────┘ Softwareit as is, and modify the errors yourself!}
Uses Crt,Dos
{$IFDEF DPMI}
,WinAPI
{$ENDIF};

{$F+}

{ $ DEFINE TSR}
{^^^^^^^^^^^^^ Take away the 2 spases to make a tsr program that intercepts}
{ the reset. it WON'T work in protected-mode!}

{$IFDEF TSR}
 {$IFDEF DPMI}
 {$M 1024}
 {$ELSE}
 {$M 1024,0,0}
 {$ENDIF}
{$ENDIF}

var
 Seg0000 : word;

PROCEDURE Init_Seg0000;
const
 Seg = $0000;
 Ofs = 0;
begin
{$IFDEF DPMI}
 Seg0000 := AllocSelector(0);
 SetSelectorBase(Seg0000, Seg*Longint(16)+Ofs);
 SetSelectorLimit(Seg0000, $FFFF);
{$ELSE}
 seg0000 := seg;
{$ENDIF}
end;

Const
 CtrlCharacter =$4;
 AltCharacter = $8;
 DelCharacter = 83;

VAR OudInterupt : Procedure;

Procedure ResetIntercept; Interrupt;
BEGIN
 IF (Port[$60] = DelCharacter) AND
 ((Mem[Seg0000:$0417] AND CtrlCharacter) = CtrlCharacter) AND
 ((Mem[Seg0000:$0417] AND AltCharacter) = AltCharacter) THEN
BEGIN
 Inline($FA);
 Port[$20]:=$20;
 Inline($FB);
END
 ELSE
BEGIN
 Inline($9C);
 OudInterupt;
END;
END;

Procedure SwitchResetOff;
BEGIN
 GetIntVec($09,@OudInterupt);
 SetIntVec($09,@ResetIntercept);
END;

Procedure SwitchResetOn;
BEGIN
 SetIntVec($09,@OudInterupt);
END;

BEGIN
{$IFDEF TSR}
 {$IFDEF DPMI}
( => TSR-programs can`t be made for DPMI-mode programs!!! <= )
 {$ENDIF}
 SwitchResetOff;
 Keep(0);{Start de TSR}
{$ELSE}
 Init_Seg0000;
 SwitchResetOff;

 {Vervolgens Uw programma, zoals...}
 Writeln('Ctrl-Alt-Del won''t work now!');
 Repeat Until ReadKey = #27; {Escape stopt het programma}
 Writeln('Ctrl-Alt-Del will be switched on.');
 {En dan weer eindigen met}

 SwitchResetOn;
{$ENDIF}
END.

