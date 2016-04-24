(*
  Category: SWAG Title: SCREEN HANDLING ROUTINES
  Original name: 0072.PAS
  Description: Screen Fun - Cascade And WipeIt!
  Author: ALLEN WALKER
  Date: 11-26-94  05:06
*)

{
A while back someone asked for a "cascade" type screen thingy, and a also a
screen wipe that would look sort of like a TV screen powering down... Here
they are... & I would like them to get into the next SWAG... 8)
}
Program Cascade1;

{causes entire screen to "fall", character by character, to the bottom of the }
{     screen...                                                               }
{                                                                             }
{              Released for SWAG use!  Use freely!                            }
{                                                                             }
{   But if you do use it, please let me know...                               }
{                                                                             }
{         Allen Walker  - Crazy Train ][  (604)383-2201                       }
{                                                                             }

Uses CRT;

Var MGAScreenMem:Array[0..1999] of Word Absolute $B000:0000;
    CGAScreenMem:Array[0..1999] of Word Absolute $B800:0000;

Function Mono_Colour:Boolean;
{Mono = False, Color = True}
Var I,J,X,Y:Integer;
    A,B,C,D:Word;
begin
  X:=WhereX-1; Y:=WhereY-1;
  C:=MGAScreenMem[Y*80+X]; D:=CGAScreenMem[Y*80+X];
  Write('A'+Chr(8));
  A:=MGAScreenMem[Y*80+X]; B:=CGAScreenMem[Y*80+X];
  MGAScreenMem[Y*80+X]:=C; CGAScreenMem[Y*80+X]:=D;
  If (A mod 256) =$41 then begin Mono_Colour:=False; Exit; end;
  If (B mod 256) =$41 then begin Mono_Colour:=True; Exit; end;
end;

Procedure Cascade;
Var L,I,X : Word;
    MC    : Boolean;
begin
  MC:=Mono_Colour;
  For L:=1 to 25 do
  begin
    For I:=1999 downto 80 do
    begin
      If MC then
      begin
        If (CGAScreenMem[I] and $70FF =32) and
                     (CGAScreenMem[I-80] and $70FF <>32) then
        begin
          X:=CGAScreenMem[I]; CGAScreenMem[I]:=CGAScreenMem[I-80];
          CGAScreenMem[I-80]:=X;
        end;
      end
        else
      begin
        If (MGAScreenMem[I] and $70FF =32) and
                     (MGAScreenMem[I-80] and $70FF <>32) then
        begin
          X:=MGAScreenMem[I]; MGAScreenMem[I]:=MGAScreenMem[I-80];
          MGAScreenMem[I-80]:=X;
        end;
      end;
    end;
      Delay(100);
  end;
end;

begin
  Cascade;
end.





Program CRTWipe;
{Causes screen to wipe from bottom & top towards the middle, then from the    }
{   sides to the center...                                                    }
{                                                                             }
{              Released for SWAG use!  Use freely!                            }
{                                                                             }
{   But if you do use it, please let me know...                               }
{                                                                             }
{         Allen Walker  - Crazy Train ][  (604)383-2201                       }
{                                                                             }
Uses CRT;

Var MGAScreenMem:Array[0..1999] of Word Absolute $B000:0000;
    CGAScreenMem:Array[0..1999] of Word Absolute $B800:0000;
    MC : Boolean;

Function Mono_Colour:Boolean;
{Mono = False, Color = True}
Var I,J,X,Y:Integer;
    A,B,C,D:Word;
begin
  X:=WhereX-1; Y:=WhereY-1;
  C:=MGAScreenMem[Y*80+X]; D:=CGAScreenMem[Y*80+X];
  Write('A'+Chr(8));
  A:=MGAScreenMem[Y*80+X]; B:=CGAScreenMem[Y*80+X];
  MGAScreenMem[Y*80+X]:=C; CGAScreenMem[Y*80+X]:=D;
  If (A mod 256) =$41 then begin Mono_Colour:=False; Exit; end;
  If (B mod 256) =$41 then begin Mono_Colour:=True; Exit; end;
end;

Procedure SetChar(N,Z:Word);
begin
  If MC then CGAScreenMem[N]:=Z else MGAScreenMem[N]:=Z;
end;

Function ReadChar(N:Word):Word;
begin
  If MC then ReadChar:=CGAScreenMem[N] else ReadChar:=MGAScreenMem[N];
end;

Procedure WipeIt;
Var L,X,Y,Z : Word;
begin
  MC:=Mono_Colour;
  For L:=1 to 12 do
  For Y:=12 downto 0 do
  begin
    For X:=0 to 79 do
    begin
      Z:=ReadChar(X+(80*Y)); SetChar(X+(80*Y)+80,Z); SetChar(X+(80*Y),1792);
    end;
    For X:=0 to 79 do
    begin
      Z:=ReadChar(X+(80*(25-Y))); SetChar(X+(80*(25-Y))-80,Z);
      SetChar(X+(80*(25-Y)),1792);
    end;
  end;
  Delay(100);
  For X:=0 to 39 do
  begin
    SetChar(X+960,1792); SetChar(1039-X,1792); Delay(10);
  end;
end;

begin
  WipeIt;
end.

