(*
  Category: SWAG Title: SOUNDBLASTER/ADLIB/SPEAKER ROUTINES
  Original name: 0109.PAS
  Description: PC-Speaker-dial-unit
  Author: G�RAN WEINHOLT
  Date: 01-02-98  07:34
*)


Hello Gayle!

I don't know if you got my previous letter, so I write again. I'd like
to contribute to the SWAG with this "PC-Speaker-dial-unit". It dials
your phone using the PC-Speaker. Here it is:

Unit PCSDial;

(*
   This unit shows how You can use the PC-Speaker to dial a phonenumber.
   Just hold the telephone's microphone near the PC-Speaker. Preferably
   realy close to the PC-Speaker. If the signals don't get trough, move
   the mic closer to PC-Speaker.

   BTW, it ain't 100% sure that this works with all the numbers.

   This unit was written by Göran Weinholt. It is very welcome in
   the SWAG. If you use this in a creation of your own, please give
   me credit.

    - Göran Weinholt <weinholt@usa.net>
*)

Interface

Uses SoundU, Crt;
{SoundU can be found in SOUND.SWG under the title "Multiple Sound 
Channels"}

Const Tones1:Array [1..4] of Word=(697,770,852,941);
      Tones2:Array [1..4] of Word=(1209,1336,1477,1633);
      Combos:Array [1..16,1..2] of Byte=
        {  1209     1336     1477     1633Hz }
{ 697   }((1,1),{1}(1,2),{2}(1,3),{3}(1,4),{A} (* What's the A, B, C and 
*)
{ 770   } (2,1),{4}(2,2),{5}(2,3),{6}(2,4),{B} (* D for? E-Mail me if    
*)
{ 852   } (3,1),{7}(3,2),{8}(3,3),{9}(3,4),{C} (* you now :-)            
*)
{ 941Hz } (4,1),{*}(4,2),{0}(4,3),{#}(4,4) {D});
{ Source: Aceex Faxmodem User's manual, Appendix B }

                    { The length of               }
Var ToneLength,     { a tone,                     }
    ToneDelay,      { the delay between tones and }
    LongDelay:Word; { a long delay                }
                    { in milliseconds.            }

Procedure DialNumber(s:string);
Function DetectWindows:Boolean;
{ This is necessary because the SoundU unit doesn't work under windows. 
}

Implementation

Procedure DialNumber(s:string);
Var A:Byte;
    I:Byte;
begin
 If not DetectWindows then
 For A := 1 to Length(S) do Begin
  If S[A] in ['0'..'9','*','#','A'..'D'] Then begin
   Case S[A] of
    '1':I := 1; '2':I := 2; '3':I := 3; 'A':I := 4;
    '4':I := 5; '5':I := 6; '6':I := 7; 'B':I := 8;
    '7':I := 9; '8':I := 10;'9':I := 11;'C':I := 12;
    '*':I := 13;'0':I := 14;'#':I := 15;'D':I := 16;
   End; (* Yes, spupid method! *)
   
DoubleSound(Tones1[Combos[I,1]],Tones2[Combos[I,2]],ToneLength/1000,22050);
   Delay(ToneDelay);
  End Else
  If S[A] = '-' then Delay(LongDelay);
 End;
end;

Function DetectWindows:Boolean;assembler;
  asm
    mov ax, 1600h
    int 2Fh
    xor dl, dl
    cmp al, 01h
    je @Label1
    cmp al, 0FFh
    je @Label1
    cmp al, 00h
    je @Label2
    cmp al, 80h
    je @Label2
    mov dl, True

   @Label1:
    mov dl, True
    jmp @Label3
   @Label2:
    mov ax, 4680h
    int 2Fh
    cmp ax, 02h
    je @Label1
    mov dl, False
   @Label3:
    xchg al, dl
  end;

Begin
  ToneLength := 150;
  ToneDelay := 70;
  LongDelay := 1000;
End.


{---------8<--- CUT HERE 
----------------------------------------------------}
Program Test; (* A test of the PCSDial unit. *)

Uses PCSDial;

Begin
 If DetectWindows then begin
  WriteLn('Sorry! This doesn''t work with Windows.');
 End;
 WriteLn('Dialing 1-800-733-1340...');
 DialNumber('1-800-733-1340');
End.

