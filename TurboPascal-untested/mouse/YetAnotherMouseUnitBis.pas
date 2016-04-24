(*
  Category: SWAG Title: RODENT MANAGMENT ROUTINES
  Original name: 0036.PAS
  Description: Yet another Mouse Unit
  Author: LUKASZ GRABUN
  Date: 05-31-96  09:16
*)

{
Here it comes (from Polish Computer Magazine ,,Bajtek'', just litlle enhanced
by me): }

unit Mouse;

interface

uses Dos;

function InitMouseOk : boolean;
function GetButton : byte;
function GetX : byte;
function GetY : byte;
procedure GetMousePos(var x,y : integer);
procedure MouseShow;
procedure MouseHide;

implementation

var r : registers;

function InitMouseOk;
begin
  r.ax:=0;
  intr($33,r);
  InitMouseOk:=boolean(r.al)
end;

function GetButton;
begin
  r.ax:=5;
  intr($33,r);
  GetButton:=r.al
end;

function GetX;
var x : byte;
begin
  r.ax:=3;
  intr($33,r);
  x:=r.cx shr 3;
  GetX:=x
end;

function GetY;
var y : byte;
begin
  r.ax:=3;
  intr($33,r);
  y:=r.dx shr 3;
  GetY:=y
end;

procedure GetMousePos;
begin
  r.ax:=3;
  intr($33,r);
  x:=r.cx shr 3;
  y:=r.dx shr 3
end;

procedure MouseShow;
begin
  r.ax:=1;
  intr($33,r)
end;

procedure MouseHide;
begin
  r.ax:=2;
  intr($33,r)
end;

end.

