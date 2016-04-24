(*
  Category: SWAG Title: OOP/TURBO VISION ROUTINES
  Original name: 0035.PAS
  Description: Extended TV GADGETS
  Author: DONN AULT
  Date: 02-15-94  08:09
*)

{********************************************************************}
{                                                                    }
{ Author:     Donn Ault                                              }
{ Date:       12/18/91                                               }
{ Purpose:    Extend clock view to show am/pm                        }
{             Extend heap view to include commas (more readable)     }
{ Copyright:  Donated to the public domain                           }
{                                                                    }
{ Notes:                                                             }
{  + In your main program you will need more space for the expanded  }
{    views.  The old clock uses 9 characters while the new           }
{    clock uses 12.  The old heap viewer uses 9 while the new one    }
{    uses 13.  Change the R.B.X occordingly.                         }
{                                                                    }
{********************************************************************}

unit xgadgets;

{$F+,O+,S-,D-}

interface

uses Dos, Objects, Views, App, gadgets;

type
  PXHeapView = ^TXHeapView;
  TXHeapView = object (THeapView)
    Procedure Draw; Virtual;
    Function  Comma ( N : LongInt ) : String;
  End;

  PXClockView = ^TXClockView;
  TXClockView = Object (TClockView)
    am : Char;
    Function FormatTimeStr (h,m,s : word) : String; Virtual;
    Procedure Draw; Virtual;
  End;

implementation

uses Drivers;

Function TXHeapView.Comma ( n : LongInt) : String;
Var num, loc : Byte;
    s : String;
    t : String;
Begin
  Str (n,s);
  Str (n:Size.X,t);

  num := length(s) div 3;
  if (length(s) mod 3) = 0 then dec (num);

  delete (t,1,num);
  loc := length(t)-2;

  while num > 0 do
  Begin
    Insert (',',t,loc);
    dec (num);
    dec (loc,3);
  End;

  Comma := t;
End;

procedure TXHeapView.Draw;
var
  S: String;
  B: TDrawBuffer;
  C: Byte;

begin
  OldMem := MemAvail;

  S := Comma (OldMem);
  C := GetColor(2);
  MoveChar(B, ' ', C, Size.X);
  MoveStr(B, S, C);
  WriteLine(0, 0, Size.X, 1, B);
end;

procedure TXClockView.Draw;
var
  B: TDrawBuffer;
  C: Byte;
begin
  C := GetColor(2);
  MoveChar(B, ' ', C, Size.X);
  MoveStr(B, TimeStr + ' '+am+'m', C);     { Modified line }
  WriteLine(0, 0, Size.X, 1, B);
end;

Function TXClockView.FormatTimeStr (h,m,s: Word) : String;
Begin
  if h = 0 then
  Begin
    h := 12;
    am := 'a';
  End
  Else if h > 12 then
  Begin
    dec (h,12);
    am := 'p';
  End
  Else am := 'a';
  FormatTimeStr := TClockView.FormatTimeStr (h,m,s);
End;

End.


