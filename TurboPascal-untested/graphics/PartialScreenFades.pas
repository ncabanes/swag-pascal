(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0154.PAS
  Description: Partial Screen Fades
  Author: TOMER LICHTASH
  Date: 11-26-94  05:02
*)

Program Cheap_Cross_Fading;
Uses CRT;

{
  Here's a cheap cross fading routine I did some time ago. I cleaned it up,
  optimized a few parts, and made it look pretty. <g>.

  Use or abuse at will, just, as always, throw me a greet in your scrolltext
  of doc files. Greet me as Dr. Nibble. Or if you dislike handles for some
  anal reason, greet me as David Proper.
}

Const
 Bits : array[1..8] of byte = ($80,$40,$20,$10,$08,$04,$02,$01);

 MaxText = 6;
 TextList : Array[1..MaxText] of String[30] = (
            ' Dr. Nibble of',
            '    Daemon',
            '   presents',
            '   a cheap',
            ' crossfading',
            '   routine');

var
 Counter : integer;
 CH      : char;
 Loop    : integer;
 Di     : byte;


Procedure GTxT(Xp,Yp, Color : Integer; Line : String; Fseg,Fofs: word;
               FYS : integer);
Var
 Loop  : Byte;
 X     : Integer;
 Y     : Integer;

begin
 For Loop := 1 to Length(line) do
  For Y := 1 to FYS do
   For X := 1 to 8 do
    {$R-}
    If MEM[Fseg:Fofs+(Y-1)+ord(Line[Loop])*FYS] and bits[X] <> 0 then
     if Mem[$A000:(Loop*9)+(X+Xp)+(320*(Y+Yp))] = di then
        Mem[$A000:(Loop*9)+(X+Xp)+(320*(Y+Yp))] := 3 else
        Mem[$A000:(Loop*9)+(X+Xp)+(320*(Y+Yp))] := Color
    {$R+}
end;


Procedure SetColor(C,R,G,B : Byte);
 Begin
  Port[$3C8] := C; Port[$3C9] := R; Port[$3C9] := G; Port[$3C9] := B;
 End;

Procedure VideoMode(Mode : Byte);
 Begin
  Asm
   Mov  AH,00
   Mov  AL,Mode
   Int  10h
  End;
 End;


BEGIN
 VideoMode($13);
 DI := 2;
 Counter := 1;


repeat
 FillChar(mem[$A000:0],$ffff,#0);
 SetColor(1,0,0,0); SetColor(2,1,0,0); SetColor(3,1,0,0);
 DI := 2;
 GTxT(90,90,1,TextList[Counter+1],$F000,$FA6E,8);
 dec(di); if di = 0 then di := 2;
 GTxT(90,90,2,TextList[Counter],$F000,$FA6E,8);
 for loop := 1 to 63 do begin
                         SetColor(2,loop,0,0);
                         SetColor(3,loop,0,0);
                         delay(20);
                        end;
 delay(400);
 for loop := 1 to 63 do begin
                         SetColor(1,loop,0,0);
                         SetColor(2,63-loop,0,0);
                         if loop < 32 then SetColor(3,63-loop,0,0)
                                      else SetColor(3,loop,0,0);
                         delay(20);
                        end;
 delay(400);
 for loop := 1 to 63 do begin
                         SetColor(1,63-loop,0,0);
                         SetColor(3,63-loop,0,0);
                         Delay(20);
                        end;
 inc(Counter,2); if counter > MaxText then counter := 1;
until keypressed;

 ch := readkey;
 VideoMode(3);
END.


