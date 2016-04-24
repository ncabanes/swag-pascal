(*
  Category: SWAG Title: SORTING ROUTINES
  Original name: 0023.PAS
  Description: Radix Sort
  Author: JOY MUKHERJEE
  Date: 05-28-93  13:57
*)

{
> I agree... unFortunately the Radix algorithm (which is a
> sophisticated modification of a Distribution Sort algorithm) is
> very Complex, highly CPU dependent and highly data dependent.

We must be speaking of a different Radix Sort.  Is the sort you are
talking about sort numbers on the basis of their digits?

> My understanding is that a Radix sort cannot be implemented in
> Pascal without using a majority of Asm (which means you might as
> well code the whole thing in Asm.)

> assembly) or dig up some working code, I would love to play With it!

************************************************************************
*                                                                      *
* Name : Joy Mukherjee                                                 *
* Date : Mar. 26, 1990                                                 *
* Description : This is the Radix sort implemented in Pascal           *
*                                                                      *
************************************************************************
}

Program SortStuff;

Uses Crt, Dos;

Type
    AType = Array [1..400] of Integer;
    Ptr   = ^Node;
    Node  = Record
          Info : Integer;
          Link : Ptr;
        end;
    LType = Array [0..9] of Ptr;

Var
   Ran     : AType;
   MaxData : Integer;

Procedure ReadData (Var A : AType; Var MaxData : Integer);

Var I : Integer;

begin
     MaxData := 400;
     For I := 1 to 400 do A [I] := Random (9999);
end;

Procedure WriteArray (A : AType; MaxData : Integer);

Var I : Integer;

begin
  For I := 1 to MaxData do
    Write (A [I] : 5);
  Writeln;
end;

Procedure Insert (Var L : LType; Number, LN : Integer);

Var
  P, Q : Ptr;

begin
  New (P);
  P^.Info := Number;
  P^.Link := Nil;
  Q := L [LN];
  if Q = Nil then
    L [LN] := P
  else
  begin
    While Q^.Link <> Nil do
      Q := Q^.Link;
    Q^.Link := P;
  end;
end;


Procedure Refill (Var A : AType; Var L : LType);
Var
  I, J : Integer;
  P    : Ptr;
begin
  J := 1;
  For I := 0 to 9 do
  begin
    P := L [I];
    While P <> Nil do
    begin
      A [J] := P^.Info;
      P := P^.Link;
      J := J + 1;
    end;
  end;
  For I := 0 to 9 do
    L [I] := Nil;
end;

Procedure RadixSort (Var A : AType; MaxData : Integer);
Var
  L        : LType;
  I,
  divisor,
  ListNo,
  Number   : Integer;
begin
  For I := 0 to 9 do L [I] := Nil;
  divisor := 1;
  While divisor <= 1000 do
  begin
    I := 1;
    While I <= MaxData do
    begin
      Number := A [I];
      ListNo := Number div divisor MOD 10;
      Insert (L, Number, ListNo);
      I := I + 1;
    end;
    Refill (A, L);
    divisor := 10 * divisor;
  end;
end;

begin
    ReadData (Ran, MaxData);
    Writeln ('Unsorted : ');
    WriteArray (Ran, MaxData);
    RadixSort (Ran, MaxData);
    Writeln ('Sorted   : ');
    WriteArray (Ran, MaxData);
end.

