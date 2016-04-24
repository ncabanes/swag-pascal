(*
  Category: SWAG Title: RODENT MANAGMENT ROUTINES
  Original name: 0041.PAS
  Description: Another Good Mouse Unit
  Author: KENTON SHOWALTER
  Date: 08-30-96  09:36
*)


unit Mouse;

interface

uses
	Dos,
	Crt;

const
	LeftButton   = 1;
	MiddleButton = 4;
	RightButton  = 2;
	NoButton     = 0;

procedure ShowMouse;
procedure HideMouse;
function  ButtonStatus : Byte;
procedure WhereMouse (var X, Y : Byte);
procedure MoveMouse (X, Y : Byte);
procedure ConfineMouse (X1, Y1, X2, Y2 : Byte);
procedure DefineMouse (MC, CC : Char; MA, CA : Byte);
procedure ObscureMouse (X1, Y1, X2, Y2 : Byte);
procedure SetMouseSpeed (DX, DY : Integer);
procedure MouseMovement (var DX, DY : Integer);
procedure ResetMouse;
function  MouseExists : Boolean;
function  MouseHidden : Boolean;

implementation

var
	MouseInstalled : Boolean;
	Buttons : Byte;
	Hidden : Boolean;

function MouseExists : Boolean;
begin
	MouseExists := MouseInstalled;
end;

procedure ShowMouse;
var Reg : Registers;
begin
	if MouseInstalled
	then begin
		if Hidden
		then begin
			Reg.AX := $0001;
			Intr ($33, Reg);
		end;
		Hidden := False;
	end;
end;

procedure HideMouse;
var Reg : Registers;
begin
	if MouseInstalled
	then begin
		if not Hidden
		then begin
			Reg.AX := $0002;
			Intr ($33, Reg);
		end;
		Hidden := True;
	end;
end;

function ButtonStatus : Byte;
var Reg : Registers;
begin
	ButtonStatus := 0;
	if MouseInstalled
	then begin
		Reg.AX := $0003;
		Intr ($33, Reg);
		ButtonStatus := Reg.BX;
	end;
end;

procedure WhereMouse (var X, Y : Byte);
var Reg : Registers;
begin
	X := 0;
	Y := 0;
	if MouseInstalled
	then begin
		Reg.AX := $0003;
		Intr ($33, Reg);
		X := (Reg.CX div 8) + 1;
		Y := (Reg.DX div 8) + 1;
	end;
end;

procedure MoveMouse (X, Y : Byte);
var Reg : Registers;
begin
	if MouseInstalled
	then begin
		Reg.AX := $0004;
		Reg.CX := X * 8 - 1;
		Reg.DX := Y * 8 - 1;
		Intr ($33, Reg);
	end;
end;

procedure ConfineMouse (X1, Y1, X2, Y2 : Byte);
var Reg : Registers;
begin
	if MouseInstalled
	then begin
		Reg.AX := $0007;
		Reg.CX := (X1 - 1) * 8;
		Reg.DX := (X2 - 1) * 8;
		Intr ($33, Reg);
		Reg.AX := $0008;
		Reg.CX := (Y1 - 1) * 8;
		Reg.DX := (Y2 - 1) * 8;
		Intr ($33, Reg);
	end;
end;

procedure DefineMouse (MC, CC : Char; MA, CA : Byte);
type
	Convert = record
		case Integer of
			0 : (C, A : Byte);
			1 : (I : Word);
		end;
var
	Converter : Convert;
	Msk, Csr : Word;
	Reg : Registers;
begin
	if MouseInstalled
	then begin
		Converter.C := Ord (MC);
		Converter.A := MA;
		Msk := Converter.I;
		Converter.C := Ord (CC);
		Converter.A :=CA;
		Csr := Converter.I;
		Reg.AX := $000A;
		Reg.BX := $0000;
		Reg.CX := Msk;
		Reg.DX := Csr;
		Intr ($33, Reg);
	end;
end;

procedure ObscureMouse (X1, Y1, X2, Y2 : Byte);
var Reg : Registers;
begin
	if MouseInstalled
	then begin
		Reg.AX := $0010;
		Reg.CX := X1 * 8 - 1;
		Reg.DX := Y1 * 8 - 1;
		Reg.SI := X2 * 8 - 1;
		Reg.DI := Y2 * 8 - 1;
		Intr ($33, Reg);
		Hidden := True;
	end;
end;

procedure SetMouseSpeed (DX, DY : Integer);
var Reg : Registers;
begin
	if MouseInstalled
	then begin
		Reg.AX := $000F;
		Reg.CX := DX;
		Reg.DX := DY;
		Intr ($33, Reg);
	end;
end;

procedure MouseMovement (var DX, DY : Integer);
var Reg : Registers;
begin
	DX := 0;
	DY := 0;
	if MouseInstalled
	then begin
		Reg.AX := $000B;
		Intr ($33, Reg);
		DX := Reg.CX;
		DY := Reg.DX;
	end;
end;

procedure ResetMouse;
begin
	DefineMouse (#255, #0, 255, 127);
	ConfineMouse (1, 1, 80, 25);
	SetMouseSpeed (8, 16);
	MoveMouse (1, 1);
end;

procedure InitMouse;
var Reg : Registers;
begin
	Reg.AX := $0000;
	Intr ($33, Reg);
	if (Reg.AX = $0000)
		then MouseInstalled := False
		else begin
			MouseInstalled := True;
			Buttons := 1;
			case Reg.BX of
				$FFFF : Buttons := 2;
				$0000 : Buttons := 1;
				$0003 : Buttons := 3;
			end;
			DefineMouse (#255, #0, 255, 127);
			ConfineMouse (1, 1, 80, 25);
			SetMouseSpeed (8, 16);
		end;
end;

function MouseHidden : Boolean;
begin
	MouseHidden := Hidden;
end;

begin
	InitMouse;
	Hidden := True;
	ShowMouse;
	Hidden := True;
	ShowMouse;
end.


Here is a sample program using the unit:

program MouseTest;

uses
	Crt,
	Mouse;

var
	BX, BY : Byte;
	TheX, TheY : Integer;
	Stuff : string;

begin
	ShowMouse;
	repeat
		WhereMouse (BX, BY);
		TheX := BX;
		TheY := BY;
		GotoXY (TheX, TheY);
		if ButtonStatus = 1
		then begin
			Readln (Stuff);
		end;
	until ButtonStatus = 2;
	HideMouse;
end.

