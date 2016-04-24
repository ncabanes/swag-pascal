(*
  Category: SWAG Title: RODENT MANAGMENT ROUTINES
  Original name: 0009.PAS
  Description: Mouse Library
  Author: LOU DUCHEZ
  Date: 11-02-93  17:39
*)

{
From: LOU DUCHEZ
Subj: mouse Library
}

unit mouse;
interface                                 { "Global" declarations }
var mouseexist, mousecursoron: boolean;   { Is a mouse hooked up? / Is the    }
procedure mouseinit;                      {   mouse cursor "on"?              }
procedure mouseon;
procedure mouseoff;
function mousex: word;                    { Note about coordinates: these     }
function mousey: word;                    {  routines return values starting  }
function mouseleft: boolean;              {  at 0, not 1 (even in text mode). }
function mousemiddle: boolean;            {  So for text mode, you may want   }
function mouseright: boolean;             {  to modify a bit ...              }
procedure setmousexy(newx, newy: word);
procedure limitmouse(lox, loy, hix, hiy: word);


implementation                            { internal workings }
uses dos;
var regs: registers;                      { Used for the "mouse" interrupts }
    xshift, yshift: byte;                 { Depending on your video mode, you }
                                          {  may need to convert "mouse"      }
                                          {  coordinates to / from "video"    }
procedure calcshifts;                     {  coordinates.  It's a matter of   }
var tempregs: registers;                  {  shifting left/right; xshift      }
begin                                     {  records how to shift the "X",    }
  tempregs.ah := $0f;                     {  and yshift records for the "Y".  }
  intr($10, tempregs);                    { Procedure CalcShifts figures out  }
  case tempregs.al of                     {  what text mode you're in and how }
    0, 1, 2, 3, 7: begin                  {  much to shift by.  It gets the   }
      xshift := 3;                        {  video mode w/interrupt $10/$0f;  }
      yshift := 3;                        {  modes 0, 1, 2, 3 and 7 are text  }
      end;                                {  modes.  4, 5, $0d and $13 are    }
    4, 5, $0d, $13: begin                 {  320 x 200 graphics modes.  All   }
      xshift := 1;                        {  other graphics modes are okay    }
      yshift := 0;                        {  "as is", although come to think  }
      end;                                {  of it I had a CGA system when I  }
    else begin                            {  wrote this library and thus      }
      xshift := 0;                        {  couldn't text VGA modes ...      }
      yshift := 0;
      end;
    end;
  end;


procedure mouseinit;                  { Initializes mouse -- determines if   }
begin                                 { one is present, then figures out the }
  regs.ax := $0000;                   { shifts, and initializes the "cursor" }
  intr($33, regs);                    { variable to "false". }
  mouseexist := (regs.ax = $FFFF);
  if mouseexist then calcshifts;      { Called automatically on startup; you }
  mousecursoron := false;             { should call it if you change video   }
  end;                                { modes in the program. }


procedure mouseon;                    { Turns cursor ON. }
begin
  if mouseexist then begin            { Note: you really should "pair" each }
    regs.ax := $0001;                 {  "on" with an "off"; if you don't,  }
    intr($33, regs);                  {  the PC can get confused. }
    mousecursoron := true;
    end;
  end;


procedure mouseoff;                   { Turns cursor OFF.  Note: when writing }
begin                                 {  to the screen, you typically want to }
  if mouseexist then begin            {  turn the cursor OFF: the PC isn't    }
    regs.ax := $0002;                 {  smart enough to say, "I'm writing a  }
    intr($33, regs);                  {  character right where the mouse      }
    mousecursoron := false;           {  cursor is: better make it inverse    }
    end;                              {  video".  So you need to shut it off. }
  end;


function mousex: word;                { Gets the current mouse column. }
var tempword: word;
begin
  if mouseexist then begin
    regs.ax := $0003;
    intr($33, regs);
    tempword := regs.cx;
    end
   else
    tempword := 0;
  mousex := tempword shr xshift;      { one of those funky "shift" things }
  end;

function mousey: word;                { Gets the current mouse row. }
var tempword: word;
begin
  if mouseexist then begin
    regs.ax := $0003;
    intr($33, regs);
    tempword := regs.dx;
    end
   else
    tempword := 0;
  mousey := tempword shr yshift;
  end;


function mouseleft: boolean;      { Is the left button down? }
var tempword: word;
begin
  if mouseexist then begin
    regs.ax := $0003;
    intr($33, regs);
    tempword := regs.bx;
    end
   else
    tempword := 0;
  mouseleft := mouseexist and (1 and tempword = 1);
  end;


function mousemiddle: boolean;    { Is the middle button down? }
var tempword: word;
begin
  if mouseexist then begin
    regs.ax := $0003;
    intr($33, regs);
    tempword := regs.bx;
    end
   else
    tempword := 0;
  mousemiddle := mouseexist and (4 and tempword = 4);
  end;


function mouseright: boolean;     { Is the right button down? }
var tempword: word;
begin
  if mouseexist then begin
    regs.ax := $0003;
    intr($33, regs);
    tempword := regs.bx;
    end
   else
    tempword := 0;
  mouseright := mouseexist and (2 and tempword = 2);
  end;


procedure setmousexy(newx, newy: word);   { Position mouse cursor. }
begin
  regs.ax := $0004;
  regs.cx := newx shl xshift;             { Shifts to get it into "mouse" }
  regs.dx := newy shl yshift;             {  coordinates. }
  intr($33, regs);
  end;


procedure limitmouse(lox, loy, hix, hiy: word);   { Restrict mouse movements. }
begin
  regs.ah := $0f;
  intr($10, regs);
  regs.ax := $0007;
  regs.cx := lox shl xshift;
  regs.dx := hix shl xshift;
  intr($33, regs);
  regs.ax := $0008;
  regs.cx := loy shl yshift;
  regs.dx := hiy shl yshift;
  intr($33, regs);
  end;


begin                 { Startup code: initializes mouse and gets video mode. }
  mouseinit;
  end.

