{
MARK OUELLET

> I know, Mark, that is what Mike said in his last post on it,
> however, when I tried to make that correction the error simply changed
> from an unrecognized Variable to a Type mismatch.  I kept the Program
> and may be able to rework it.  I think Mike indicated originally that it
> was untested. I kept a copy and may get back to it later.   I thought
> (grin) that you might come along and supply the missing touch!!  I've
> profited greatly by the instruction of your skilled hand as well as that
> of Mike's.

    The Type mismatch comes from the fact Mike elected to use a general
purpose Pointer Type For his Array rather than defining a new String
Pointer Type.

    Ok, you have two possible solutions to the problem. You can (A)
TypeCast every Pointer use With String() as in

   if PA[MIDDLE]^ < S

BECOMES

   if String(PA[MIDDLE]^) < S

This one is long and requires adding the Typecast to every single
comparison. Or you can (B) define a new StrPointer Type and redefine the
Array to an Array of StrPointer.

Here is a version that should work correctly. I decided to go With the
String Pointer Type since Mike Uses GetMem anyways. if he had been using
NEW() then each allocation would have been For a 255 caracter String but
since he allready Uses GetMem to request just enough to hold the String
then the new Type will pose no problems.

    Note that some additions and Modifications have also been done to
make it work. I guess Mike was pretty tired when he wrote this ;-). The
sorting routine does work as is, just as Mike stated. I also took it
upon myself to reformat it to my standards.
}


{$A+,B-,D+,E-,F+,G+,I+,L+,N-,O+,P+,Q+,R+,S+,T+,V-,X+,Y+}
{$M 65520,100000,655360}
{
  Written by Mike Copeland and Posted to the Pascal Lessons echo
  on April 10th 1993.

  Modified by Mark Ouellet on May 3rd 1993 and reposted to Pascal
  Lessons echo.

  Modifications are not indicated in any way to avoid loading the echo
  too much. A File compare of both versions will point out the obvious
  modifications and additions.
}
Program Text_File_SORT;

Uses
  Dos, Crt, Printer;

Const
  MAXL = 10000;   { maximum # of Records to be processed }

Type
  BBUF       = Array[1..16384] of Char;
  StrPointer = ^String;

Var
  I    : Word;
  IDX  : Word;
  P    : StrPointer;
  S    : String;
  BP   : ^BBUF;                       { large buffer For Text File i/o }
  PA   : Array [1..MAXL] of StrPointer;{ Pointer Array }
  F    : Text;

Procedure Pause;
begin
  { Flush Keyboard buffer }
  Asm
    Mov AX, 0C00h;
    Int 21h
  end;
  Writeln('Press a key to continue...');
  { Wait For Keypress }
  While not KeyPressed do;
  { Flush Keyboard Buffer again, we don't need the key }
  Asm
    Mov AX, 0C00h;
    Int 21h
  end;
end;

Procedure L_HSORT (LEFT, RIGHT : Word);{ Lo-Hi QuickSort }
Var
  LOWER,
  UPPER,
  MIDDLE : Word;
  PIVOT,
  T      : String;
  Temp   : StrPointer;
begin
  LOWER  := LEFT;
  UPPER  := RIGHT;
  MIDDLE := (LEFT + RIGHT) Shr 1;
  PIVOT  := PA[MIDDLE]^;
  Repeat
    While PA[LOWER]^ < PIVOT do
      Inc(LOWER);
    While PIVOT < PA[UPPER]^ do
      Dec(UPPER);
    if LOWER <= UPPER then
    begin
      Temp := PA[LOWER];
      PA[LOWER] := PA[UPPER];
      PA[UPPER] := Temp;
      Inc (LOWER);
      Dec (UPPER);
    end;
  Until LOWER > UPPER;
  if LEFT < UPPER then
    L_HSORT (LEFT, UPPER);
  if LOWER < RIGHT then
    L_HSORT (LOWER, RIGHT);
end; { L_HSORT }

begin
  ClrScr;
  Assign (F,'input.dat');
  New (BP);
  SetTextBuf (F,BP^);
  Reset (F);
  IDX := 0;
  While not EOF (F) do
  begin          { read File; load into Heap }
    readln (F,S);
    Inc (IDX);
    GetMem (P,Length(S)+1);
    P^ := S;
    PA[IDX] := P;
    gotoXY (1,22);
    Write (IDX:5)
  end;
  Close (F);
  Dispose (BP);
  if IDX > 1 then
    L_HSORT (1,IDX);                  { sort the data }
  For I := 1 to IDX do begin          { display the data }
    Writeln (PA[I]^);
    if not Boolean(I MOD 23) then
      pause;
  end;
  Writeln ('Finis...')
end.
