
{
 One way to do it is to change the cursor size attributes. Here are some
 routines I use and a little demo program I wrote for another user a
 while back(Gosh almost a year now<g>). Also if your doing a lot of
 screen writing and either don't want the cursor to move or not be
 visible at all you might want to try looking into direct video memory
 writes.
}

PROGRAM CursorDemo;              (*  May 27/93, Greg Estabrooks     *)
USES CRT;                        (*  For Readkey, Clrscr.           *)
CONST
     (* Define Cursor Value to make chaning cursor easier *)
    NoCursor      = $2000;
    DefaultCursor = $0607;
    BlockCursor   = $000A;
VAR
    Curs :WORD;                 (* Stores saved cursor value         *)
    Ch   :CHAR;

PROCEDURE SetCursor( Cursor :WORD ); ASSEMBLER;
                     (* Routine to change the shape of the cursor    *)
ASM
  Mov AH,1                      (* Function to change cursor shape   *)
  Mov BH,0                      (* Set Page to 0                     *)
  Mov CX,Cursor                 (* Load new cursor Shape Value       *)
  Int $10                       (* Call Dos                          *)
END;{SetCursor}

FUNCTION GetCursor :WORD; ASSEMBLER;
                   (* Routine to return Cursor Shape                 *)
ASM
  Mov AH,3                      (* Function to return cursor shape   *)
  Mov BH,0                      (* Set Page to 0                     *)
  Int $10                       (* Call Dos                          *)
  Mov AX,CX                     (* Move Result to proper register    *)
END;{GetCursor}

BEGIN
  Clrscr;                       (* Clear the screen for demonstration*)
  Curs := GetCursor;            (* Save Current Cursor Value         *)
  Writeln('The Cursor is turned off');
  SetCursor( NoCursor );        (* Turn off the cursor               *)
  Ch := Readkey;                (* Pause to show user new cursor     *)
  Writeln('The Cursor is a block shape');
  SetCursor( BlockCursor );     (*  Set the cursor to a block        *)
  Ch := Readkey;
  Writeln('The Cursor is now the normal shape');
  SetCursor( DefaultCursor );   (* Set Default Cursor                *)
  Ch := Readkey;

  SetCursor( Curs );            (* Restore cursor to previous style  *)
END.
