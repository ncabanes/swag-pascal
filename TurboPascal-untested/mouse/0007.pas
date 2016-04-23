Unit Mouse4;

{*******************************************************************}
{*                   Mouse4 - Text Mouse Unit                      *}
{*                     version .9, 11/20/87                        *}
{*                by Richard Sadowsky 74017,1670                   *}
{*                 released to the public domain                   *}
{*******************************************************************}

Interface

Uses DOS;

const
  CURPOS           = 1; { not used yet in this version }
  LEFTPRESS        = 2;
  LEFTREL          = 4;
  RIGHTPRESS       = 8;
  RIGHTREL         = 16;

var
  Mouse_Reg        : Registers;
  Mouse_Installed  : Boolean;
  Mouse_Error      : Word;

function InitMouse : Word;
{ Function 0 - Initialize mouse software and hardware }

procedure ShowMouse;
{ function 1 - show mouse cursor }

procedure HideMouse;
{ function 2 - hide mouse cursor }

function MousePosition(var MouseX,MouseY : Word) : Word;
{ function 3 - return mouse position and button status }
{ X and Y values scaled for 80 col text mode }

procedure setmouseposition(mousex, mousey: Word);
{ function 4 - sets mouse position  }
{ X and Y values scaled for 80 col text mode }

function mousepress(button: Word;
                     var count, lastx, lasty: Word): Word;
{ function 5 - gets button press information  }
{ X and Y values scaled for 80 col text mode }

function mouserelease(button: Word;
                       var count, lastx, lasty: Word): Word;
{ function 6 - gets button release information  }
{ X and Y values scaled for 80 col text mode }

procedure setmousexy(x1,y1,x2,y2: Word);
{ functions 7 and 8 - sets min/max values for horizontal/vertical  }
{ X and Y values scaled for 80 col text mode }

procedure restoremousexy;
{ functions 7 and 8 - restores min/max values for CGA screen }

procedure SetPixeltoMickey(Horiz,Verti : Word);
{ function 15 - sets the mickey to pixel ratio }

implementation

function InitMouse : Word;
{ Function 0 - Initialize mouse software and hardware }
begin
  with Mouse_Reg do
    Ax := 0;
  Intr($33,Mouse_Reg);
  InitMouse := Mouse_Reg.Ax;
end;

procedure ShowMouse;
{ function 1 - show mouse cursor }
begin
  Mouse_Reg.Ax := 1;
  Intr($33,Mouse_Reg);
end;

procedure HideMouse;
{ function 2 - hide mouse cursor }

begin
  Mouse_Reg.AX := 2;
  Intr($33,Mouse_Reg);
end;

function MousePosition(var MouseX,MouseY : Word) : Word;
{ function 3 - return mouse position and button status }
{ X and Y values scaled for 80 col text mode }
begin
  Mouse_Reg.Ax := 3;
  Intr($33,Mouse_Reg);
  with Mouse_Reg do begin
    MouseX := Succ(Cx DIV 8);
    MouseY := Succ(Dx DIV 8);
    MousePosition := Bx;
  end;
end;

procedure setmouseposition(mousex, mousey: Word);
{ function 4 - sets mouse position  }
{ X and Y values scaled for 80 col text mode }
begin
  Mouse_Reg.ax:=4;
  Mouse_Reg.cx:=Pred(mousex*8);
  Mouse_Reg.dx:=Pred(mousey*8);
  intr($33,Mouse_Reg);
end;

function mousepress(button: Word;
                     var count, lastx, lasty: Word): Word;
{ function 5 - gets button press information  }
{ X and Y values scaled for 80 col text mode }
begin
  Mouse_Reg.ax:=5;
  Mouse_Reg.bx:=button;
  intr($33,Mouse_Reg);;
  mousepress:=Mouse_Reg.ax;
  count:=Mouse_Reg.bx;
  lastx:=Succ(Mouse_Reg.cx div 8);
  lasty:=Succ(Mouse_Reg.dx div 8);
end;

function mouserelease(button: Word;
                       var count, lastx, lasty: Word): Word;
{ function 6 - gets button release information  }
{ X and Y values scaled for 80 col text mode }
begin
  Mouse_Reg.ax:=6;
  Mouse_Reg.bx:=button;
  intr($33,Mouse_Reg);;
  mouserelease:=Mouse_Reg.ax;
  count:=Mouse_Reg.bx;
  lastx := Succ(Mouse_Reg.cx div 8);
  lasty := Succ(Mouse_Reg.dx div 8);
end;

procedure setmousexy(x1,y1,x2,y2: Word);
{ functions 7 and 8 - sets min/max values for horizontal/vertical  }
{ X and Y values scaled for 80 col text mode }
begin
  Mouse_Reg.ax:=7;
  Mouse_Reg.cx:=Pred(x1*8);
  Mouse_Reg.dx:=Pred(x2*8);
  intr($33,Mouse_Reg);
  Mouse_Reg.ax:=8;
  Mouse_Reg.cx:=Pred(y1*8);
  Mouse_Reg.dx:=Pred(y2*8);
  intr($33,Mouse_Reg);
end;

procedure restoremousexy;
{ functions 7 and 8 - restores min/max values for CGA screen }
begin
  Mouse_Reg.ax:=7;
  Mouse_Reg.cx:=0;
  Mouse_Reg.dx:=639;
  intr($33,Mouse_Reg);
  Mouse_Reg.ax:=8;
  Mouse_Reg.cx:=0;
  Mouse_Reg.dx:=199;
  intr($33,Mouse_Reg);
end;

procedure SetPixeltoMickey(Horiz,Verti : Word);
{ function 15 - sets the mickey to pixel ratio }

begin
  with Mouse_Reg do begin
    Ax := 15;
    Cx := Horiz;
    Dx := Verti;
  end;
  Intr($33,Mouse_Reg)
end;

begin
  Mouse_Error := InitMouse;
  Mouse_Installed := Mouse_Error = 65535;
end.
