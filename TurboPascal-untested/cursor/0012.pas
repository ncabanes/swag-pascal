{BRIAN DHATT

> Does anyone have codes/source For replacing GotoXY Procedure?
}
Asm
  MOV AH,$0F                   {To get active page, returns BH}
  INT $10
  MOV Page,BH
end;

Asm                  {to find current cursor pos in form XX,YY}
  MOV AH,$3           {Equiv of XX:=WhereX, YY:=WhereY         }
  MOV BH,Page
  INT $10
  MOV YY,DH
  MOV XX,DL
end;

Asm                        {This block moves the cursor to           }
  MOV AH,$02               {XX,YY just like GotoXY(XX,YY)            }
  MOV BH,Page
  MOV DL,XX
  MOV DH,YY
  INT $10
end;

{
GREG ESTABROOKS

>Can someone tell me how to make the cursor in Turbo Pascal disappear and
>appear?
}

Program CursorDemo;              (*  May 27/93, Greg Estabrooks     *)
Uses
  Crt;                        (*  For ReadKey, ClrScr.           *)
Const
  (* Define Cursor Value to make chaning cursor easier *)
  NoCursor      = $2000;
  DefaultCursor = $0607;
  BlockCursor   = $000A;
Var
  Curs : Word;                 (* Stores saved cursor value         *)
  Ch   : Char;

Procedure SetCursor(Cursor : Word); Assembler;
                    (* Routine to change the shape of the cursor    *)
Asm
  Mov AH,1                      (* Function to change cursor shape   *)
  Mov BH,0                      (* Set Page to 0                     *)
  Mov CX,Cursor                 (* Load new cursor Shape Value       *)
  Int $10                       (* Call Dos                          *)
end;{SetCursor}

Function GetCursor : Word; Assembler;
                   (* Routine to return Cursor Shape                 *)
Asm
  Mov AH,3                      (* Function to return cursor shape   *)
  Mov BH,0                      (* Set Page to 0                     *)
  Int $10                       (* Call Dos                          *)
  Mov AX,CX                     (* Move Result to proper register    *)
end;{GetCursor}

begin
  ClrScr;                       (* Clear the screen For demonstration*)
  Curs := GetCursor;            (* Save Current Cursor Value         *)
  Writeln('The Cursor is turned off');
  SetCursor( NoCursor );        (* Turn off the cursor               *)
  Ch := ReadKey;                (* Pause to show user new cursor     *)
  Writeln('The Cursor is a block shape');
  SetCursor( BlockCursor );     (*  Set the cursor to a block        *)
  Ch := ReadKey;
  Writeln('The Cursor is now the normal shape');
  SetCursor( DefaultCursor );   (* Set Default Cursor                *)
  Ch := ReadKey;

  SetCursor( Curs );            (* Restore cursor to previous style  *)
end.
