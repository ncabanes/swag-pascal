(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0123.PAS
  Description: Is the CPU doing something?
  Author: MATS DAHLIN
  Date: 11-26-94  05:07
*)

{
  Sometimes you have trouble to know if the computer really does something
  or if it has gone into an endless loop. This is a problem that I have
  got when I constructed some programs which done some heavy numerical
  computations. (Some of them take about 15 minutes to run on a 66 MHz
  486-DX2.)

  So, to solve my problems I created an object which implement a spinning
  indicator that gives information on the screen that something is really
  going on. I haven't put in much comments but I think it will be easy to
  follow the code anyway. After the code of the SpinU unit is a simple
  demo program.

  Enjoy!

  By Mats Dahlin, 1994-10-13

  If you have any suggestions/questions, please a message to
      CompuServe: 70622,157
      Internet  : 70622.157@compuserve.comsend E-mail to
}

unit SpinU;

{********************************************************************}
interface
{********************************************************************}

type
  TSpin = object
    x, y     : Byte;
    ColorAttr: Byte;
    Index    : Byte;
    SpinDelay: Byte;
    Clockwise: Boolean;
    Counter  : Byte;
    procedure Init(InitX, InitY : Byte;        { Coordinate of the "spinner" }
                   InitColorAttr: Byte;       { Color attribute of "spinner" }
                   InitIndex    : Byte;             { Initial spin character }
                   InitSpinDelay: Byte;{ Delay before next turn of "spinner" }
                   InitClockwise: Boolean);         { Spin clockwise or... ? }
    procedure Display;
    procedure Update;
    procedure Clear;
  end;

{********************************************************************}
implementation
{********************************************************************}

uses
  Crt;

procedure TSpin.Init(InitX, InitY : Byte;
                     InitColorAttr: Byte;
                     InitIndex    : Byte;
                     InitSpinDelay: Byte;
                     InitClockwise: Boolean);
begin
  x := InitX;
  y := InitY;
  ColorAttr := InitColorAttr;
  Index := InitIndex;
  SpinDelay := InitSpinDelay;
  Counter := 0;
  Clockwise := InitClockwise;
  Display;
end;

{************************************************}

procedure TSpin.Display;
const
  CSpinCh: array [1..4] of Char = ('/', '-', '\', '|');
var
  OldAttr: Byte;
begin
  OldAttr := TextAttr;
  TextColor(ColorAttr);
  Gotoxy(x, y);
  Write(CSpinCh[Index]);
  TextAttr := OldAttr;
end;

{************************************************}

procedure TSpin.Update;
begin
  Display;
  Inc(Counter);
  if (Counter>=SpinDelay) then
  case Clockwise of
    True : begin
             Inc(Index);
             if (Index=5) then
               Index := 1;
             Counter := 0;
           end;
    False: begin
             Dec(Index);
             if (Index=0) then
               Index := 4;
             Counter := 0;
           end;
  end;
end;

{************************************************}

procedure TSpin.Clear;
begin
  Gotoxy(x, y);
  Write(#32);
end;

{********************************************************************}

end.

{ And here comes the demo program... }

program SpinTest;

uses
  Dos, Crt, SpinU;

const
  NoOfSpinners = 15;
  NoOfRows     = 4;

var
  Spin: array [1..NoOfSpinners, 1..NoOfRows] of TSpin;
  i, j: Integer;

{************************************************}

procedure CursorOff;
var
  Regs: Registers;
begin
  FillChar(Regs, SizeOf(Regs), 0);
  Regs.AH := $01;
  Regs.CX := $2000;
  Intr($10, Regs);
end;

{************************************************}

procedure CursorOn;
var
  Regs: Registers;
begin
  FillChar(Regs, SizeOf(Regs), 0);
  Regs.AH := $0F;
  Intr($10, Regs);
  if ((Regs.AL and $07)=$07) then
    Regs.CX := $0C0D
  else
    Regs.CX := $0607;
  Regs.AH := $01;
  Intr($10, Regs);
end;

{************************************************}

begin
  CursorOff;
  Gotoxy(1, 12);
  Writeln('SPINTEST - By Mats Dahlin, 1994-10-13');
  Writeln('(A demo program of the SpinU unit)');
  for i := 1 to NoOfSpinners do                         { Setup the spinners }
    for j := 1 to NoOfRows do
      Spin[i, j].Init(5*i, 2*j, i, j, 15*j, Odd(j));
  repeat                                                  { Let them spin... }
    for i := 1 to NoOfSpinners do
      for j := 1 to NoOfRows do
        Spin[i, j].Update;
  until KeyPressed;
  for i := 1 to NoOfSpinners do     { These loops aren't really necessary in }
    for j := 1 to NoOfRows do                  { this little demo program... }
      Spin[i, j].Clear;
  ClrScr;
  CursorOn;
end.

