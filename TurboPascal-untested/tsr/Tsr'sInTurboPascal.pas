(*
  Category: SWAG Title: TSR UTILITIES AND ROUTINES
  Original name: 0027.PAS
  Description: Tsr's In Turbo Pascal
  Author: LUIS MEZQUITA
  Date: 08-24-94  13:44
*)

Program TSR;

{ TSR Demo                      }
{ (c) Jul 94 Luis Mezquita Raya }

{$M $1000,0,0}

uses  Crt,Dos;

var   OldInt09h:procedure;

Procedure EndTSR; assembler;
asm
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

{$f+}
Procedure NewInt09h; interrupt;
var k:byte; kb_exit:boolean;
begin
 k:=Port[$60];
 kb_exit:=False;
 if k<$80
 then begin
       Sound(5000);
       Delay(1);
       NoSound;
      end
 else if k=$CE                          { $4E or $80 }
      then kb_exit:=True;
 asm pushf end;
 OldInt09h;
 if kb_exit
 then begin
       Sound(440);
       Delay(15);
       NoSound;
       SetIntVec(9,@OldInt09h);
       EndTSR;
      end;
end;
{$f-}

begin
 GetIntVec(9,@OldInt09h);
 SetIntVec(9,@NewInt09h);
 Keep(0);
end.
>--- cut here -----------------------------------------------------

        When you run this program you get a key-click each time you
press a key but TSR program discharges if you press the big '+' key
(at numeric keyboard).

                   Greetings,
                            Luis


