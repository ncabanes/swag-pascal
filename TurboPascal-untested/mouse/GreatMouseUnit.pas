(*
  Category: SWAG Title: RODENT MANAGMENT ROUTINES
  Original name: 0031.PAS
  Description: Great Mouse Unit
  Author: TIM RHODES
  Date: 09-04-95  10:54
*)


(*
                               Mouse Functions
                               ───────────────

          I am relesing this source into the Public Domain. You are
          free to use and/or modify this code as you wish.
          This code is being released as-is, and should be at your
          own risk. Liberty Software, and myself are not responsible
          for what it may or may not do on your system.

          Written on : 02/25/95, by: Tim E. Rhodes - Liberty Software
*)
Unit MsFuncs;
Interface
Uses Dos,Crt;
Var
 MSAvailable  : Boolean; {True if Mouse Available}
 MsButtons    : Integer; {Number of buttons if Mouse Available}
 MsLastX      : Word;    {Filled by MsGetPos,Ms*Pressed and Ms*Released}
 MsLastY      : Word;    {Filled by MsGetPos,Ms*Pressed and Ms*Released}
 Count        :Word;
Procedure MsInit;                  {0000h RESET DRIVER AND READ STATUS}
Procedure MsShow;                  {0001h SHOW MOUSE CURSOR}
Procedure MsHide;                  {0002h HIDE MOUSE CURSOR}
Procedure MsGetPos;                {0003h RETURN POSITION AND BUTTON STATUS}
                                   {      Fills MsPosX, and MsPosY}
Function MsWhereX:Word;            {0003h RETURN MOUSE COLUMN POSITION}
Function MsWhereY:Word;            {0003h RETURN MOUSE ROW POSITION}
Function MsLeftDown:Boolean;       {0003h RETURN TRUE IF LEFT BUTTON DOWN}
Function MsRightDown:Boolean;      {0003h RETURN TRUE IF RIGHT BUTTON DOWN}
Function MsBothDown:Boolean;       {0003h RETURN TRUE IF BOTH BUTTONS DOWN}
Function MsMiddleDown:Boolean;     {0003h RETURN TRUE IF MIDDLE BUTTON DOWN}
Procedure MsGotoXY(X,Y:Word);      {0004h POSITION MOUSE CURSOR}
Function MsLeftPressed:Boolean;    {0005h RETURN TRUE IF LEFT BUTTON PRESSED}
Function MsRightPressed:Boolean;   {0005h RETURN TRUE IF RIGHT BUTTON PRESSED}
Function MsBothPressed:Boolean;    {0005h RETURN TRUE IF BOTH BUTTONS PRESSED}
Function MsMiddlePressed:Boolean;  {0005h RETURN TRUE IF MIDDLE BUTTON PRESSED}
Function MsLeftReleased:Boolean;   {0006h RETURN TRUE IF LEFT BUTTON RELEASED}
Function MsRightReleased:Boolean;  {0006h RETURN TRUE IF RIGHT BUTTON RELEASED}
Function MsBothReleased:Boolean;   {0006h RETURN TRUE IF BOTH BUTTONS RELEASED}
Function MsMiddleReleased:Boolean; {0006h RETURN TRUE IF MIDDLE BUTTON RELEASED}
Procedure MsWindow(X,Y,X1,Y1:Word);{0007h DEFINE HORIZONTAL CURSOR RANGE}
                                   {  and 0008h  VERTICAL CURSOR RANGE}
                        {NOT USED - 0009h DEFINE GRAPHICS CURSOR - NOT USED}
Procedure MsAttr(ScreenMask,CursorMask:Word);
                                   {000Ah DEFINE TEXT CURSOR - SOFTWARE}
Procedure MsSize(StartScan,EndScan:Word);
                                   {000Ah DEFINE TEXT CURSOR - HARDWARE}
Implementation
Var
 SavedExitPtr : Pointer;
 Regs         : Registers;
 TempWord     : Word;
Procedure MsInit;Assembler;
 Asm
          MOV MSAvailable,False
          MOV MsButtons,0
          MOV AX,0000h
          INT 33h
          CMP AX,0000h
           JE @Done
          CMP AX,0FFFFh
          JNE @Done
          MOV MsAvailable,True
          CMP BX,0002h
           JE @Two
          CMP BX,0003h
           JE @Three
          CMP BX,0FFFFh
           JE @Three
    @Two: MOV MsButtons,2
          JMP @Done
  @Three: MOV MsButtons,3
          JMP @Done
   @Done:
 End;
Procedure MsShow;Assembler;
 Asm
         CMP MsAvailable,True
         JNE @Done
         MOV AX,0001h
         INT 33h
  @Done:
 End;
Procedure MsHide;Assembler;
 Asm
         CMP MsAvailable,True
         JNE @Done
         MOV AX,0002h
         INT 33h
  @Done:
 End;
Procedure MsGetPos;
 Begin
  Asm
          CMP MsAvailable,True
          JNE @Done
          MOV AX,0003h
          INT 33h
          MOV MsLastX,CX
          MOV MsLastY,DX
   @Done:
  End;
  MsLastX:=(MsLastX DIV 8)+1;{Converts XPos to 80 column test mode}
  MsLastY:=(MsLastY DIV 8)+1;{Converts YPos to 25 Row text mode}
 End;

Function MsWhereX:Word;
 Begin
  Asm
          CMP MsAvailable,True
          JNE @Done
          MOV AX,0003h
          INT 33h
          MOV TempWord,CX
   @Done:
  End;
  MsWhereX:=(TempWord DIV 8)+1;{Converts XPos to 80 column test mode}
 End;
Function MsWhereY:Word;
 Begin
  Asm
          CMP MsAvailable,True
          JNE @Done
          MOV AX,0003h
          INT 33h
          MOV TempWord,DX
   @Done:
  End;
  MsWhereY:=(TempWord DIV 8)+1;{Converts YPos to 25 Row text mode}
 End;
Function MsLeftDown:Boolean;
 Begin
  Asm
          MOV @Result,False
          CMP MsAvailable,True
          JNE @Done
          MOV AX,0003h
          INT 33h
          MOV MsLastX,CX
          MOV MsLastY,DX
          CMP BX,1
          JNE @Done
          MOV @Result,True
   @Done:
  End;
  MsLastX:=(MsLastX DIV 8)+1;{Converts XPos to 80 column test mode}
  MsLastY:=(MsLastY DIV 8)+1;{Converts YPos to 25 Row text mode}
 End;
Function MsRightDown:Boolean;
 Begin
  Asm
          MOV @Result,False
          CMP MsAvailable,True
          JNE @Done
          MOV AX,0003h
          INT 33h
          MOV MsLastX,CX
          MOV MsLastY,DX
          CMP BX,2
          JNE @Done
          MOV @Result,True
   @Done:
  End;
  MsLastX:=(MsLastX DIV 8)+1;{Converts XPos to 80 column test mode}
  MsLastY:=(MsLastY DIV 8)+1;{Converts YPos to 25 Row text mode}
 End;
Function MsBothDown:Boolean;
 Begin
  Asm
          MOV @Result,False
          CMP MsAvailable,True
          JNE @Done
          MOV AX,0003h
          INT 33h
          MOV MsLastX,CX
          MOV MsLastY,DX
          CMP BX,3
          JNE @Done
          MOV @Result,True
   @Done:
  End;
  MsLastX:=(MsLastX DIV 8)+1;{Converts XPos to 80 column test mode}
  MsLastY:=(MsLastY DIV 8)+1;{Converts YPos to 25 Row text mode}
 End;
Function MsMiddleDown:Boolean;
 Begin
  Asm
          MOV @Result,False
          CMP MsAvailable,True
          JNE @Done
          MOV AX,0003h
          INT 33h
          MOV MsLastX,CX
          MOV MsLastY,DX
          CMP BX,4
          JNE @Done
          MOV @Result,True
   @Done:
  End;
  MsLastX:=(MsLastX DIV 8)+1;{Converts XPos to 80 column test mode}
  MsLastY:=(MsLastY DIV 8)+1;{Converts YPos to 25 Row text mode}
 End;

Procedure MsGotoXY(X,Y:Word);
 Begin
  X:=(X-1)*8;{Convert 80 Column text mode to pixels}
  Y:=(Y-1)*8;{Convert 25 Row text mode to pixels}
  Asm
          CMP MsAvailable,True
          JNE @Done
          MOV AX,0004h
          MOV CX,X
          MOV DX,Y
          INT 33h
   @Done:
  End;
 End;
Function MsLeftPressed:Boolean;
Begin
 Asm
         MOV @Result,False
         CMP MsAvailable,True
         JNE @Done
         MOV AX,0005h
         MOV BX,0000h
         INT 33h
         MOV Count,BX
         MOV MsLastX,CX
         MOV MsLastY,DX
         CMP AX,1
         JNE @Done
         MOV @Result,True
  @Done:
 End;
  MsLastX:=(MsLastX DIV 8)+1;{Converts XPos to 80 column test mode}
  MsLastY:=(MsLastY DIV 8)+1;{Converts YPos to 25 Row text mode}
End;
Function MsRightPressed:Boolean;
Begin
 Asm
         MOV @Result,False
         CMP MsAvailable,True
         JNE @Done
         MOV AX,0005h
         MOV BX,0001h
         INT 33h
         MOV Count,BX
         MOV MsLastX,CX
         MOV MsLastY,DX
         CMP AX,2
         JNE @Done
         MOV @Result,True
  @Done:
 End;
  MsLastX:=(MsLastX DIV 8)+1;{Converts XPos to 80 column test mode}
  MsLastY:=(MsLastY DIV 8)+1;{Converts YPos to 25 Row text mode}
End;
Function MsBothPressed:Boolean;
Begin
 Asm
         MOV @Result,False
         CMP MsAvailable,True
         JNE @Done
         MOV AX,0005h
         MOV BX,0002h
         INT 33h
         MOV Count,BX
         MOV MsLastX,CX
         MOV MsLastY,DX
         CMP AX,3
         JNE @Done
         MOV @Result,True
  @Done:
 End;
  MsLastX:=(MsLastX DIV 8)+1;{Converts XPos to 80 column test mode}
  MsLastY:=(MsLastY DIV 8)+1;{Converts YPos to 25 Row text mode}
End;
Function MsMiddlePressed:Boolean;
Begin
 Asm
         MOV @Result,False
         CMP MsAvailable,True
         JNE @Done
         MOV AX,0005h
         MOV BX,0002h
         INT 33h
         MOV Count,BX
         MOV MsLastX,CX
         MOV MsLastY,DX
         CMP AX,4
         JNE @Done
         MOV @Result,True
  @Done:
 End;
  MsLastX:=(MsLastX DIV 8)+1;{Converts XPos to 80 column test mode}
  MsLastY:=(MsLastY DIV 8)+1;{Converts YPos to 25 Row text mode}
End;
Function MsLeftReleased:Boolean;
Begin
 Asm
         MOV @Result,False
         CMP MsAvailable,True
         JNE @Done
         MOV AX,0006h
         MOV BX,0000h
         INT 33h
         MOV Count,BX
         MOV MsLastX,CX
         MOV MsLastY,DX
         CMP AX,1
         JNE @Done
         MOV @Result,True
  @Done:
 End;
  MsLastX:=(MsLastX DIV 8)+1;{Converts XPos to 80 column test mode}
  MsLastY:=(MsLastY DIV 8)+1;{Converts YPos to 25 Row text mode}
End;

Function MsRightReleased:Boolean;
Begin
 Asm
         MOV @Result,False
         CMP MsAvailable,True
         JNE @Done
         MOV AX,0006h
         MOV BX,0001h
         INT 33h
         MOV Count,BX
         MOV MsLastX,CX
         MOV MsLastY,DX
         CMP AX,2
         JNE @Done
         MOV @Result,True
  @Done:
 End;
  MsLastX:=(MsLastX DIV 8)+1;{Converts XPos to 80 column test mode}
  MsLastY:=(MsLastY DIV 8)+1;{Converts YPos to 25 Row text mode}
End;
Function MsBothReleased:Boolean;
Begin
 Asm
         MOV @Result,False
         CMP MsAvailable,True
         JNE @Done
         MOV AX,0006h
         MOV BX,0002h
         INT 33h
         MOV Count,BX
         MOV MsLastX,CX
         MOV MsLastY,DX
         CMP AX,3
         JNE @Done
         MOV @Result,True
  @Done:
 End;
  MsLastX:=(MsLastX DIV 8)+1;{Converts XPos to 80 column test mode}
  MsLastY:=(MsLastY DIV 8)+1;{Converts YPos to 25 Row text mode}
End;
Function MsMiddleReleased:Boolean;
Begin
 Asm
         MOV @Result,False
         CMP MsAvailable,True
         JNE @Done
         MOV AX,0006h
         MOV BX,0002h
         INT 33h
         MOV Count,BX
         MOV MsLastX,CX
         MOV MsLastY,DX
         CMP AX,4
         JNE @Done
         MOV @Result,True
  @Done:
 End;
  MsLastX:=(MsLastX DIV 8)+1;{Converts XPos to 80 column test mode}
  MsLastY:=(MsLastY DIV 8)+1;{Converts YPos to 25 Row text mode}
End;
Procedure MsWindow(X,Y,X1,Y1:Word);
Begin
  X:=(X-1)*8;{Convert 80 Column text mode to pixels}
  Y:=(Y-1)*8;{Convert 25 Row text mode to pixels}
  X1:=(X1-1)*8;{Convert 80 Column text mode to pixels}
  Y1:=(Y1-1)*8;{Convert 25 Row text mode to pixels}
 Asm
         CMP MsAvailable,True
         JNE @Done
         MOV AX,0007h
         MOV CX,X
         MOV DX,X1
         INT 33h
         MOV AX,0008h
         MOV CX,Y
         MOV DX,Y1
         INT 33h
         JMP @Done
  @Done:
 End;
End;
Procedure MsAttr(ScreenMask,CursorMask:Word);Assembler;
 Asm
         CMP MsAvailable,True
         JNE @Done
         MOV AX,000Ah
         MOV BX,0000h
         MOV CX,ScreenMask
         MOV DX,CursorMask
         INT 33h
  @Done:
 End;
Procedure MsSize(StartScan,EndScan:Word);Assembler;
 Asm
         CMP MsAvailable,True
         JNE @Done
         MOV AX,000Ah
         MOV BX,0001h
         MOV CX,StartScan
         MOV DX,EndScan
         INT 33h
  @Done:
 End;
Procedure MouseExit;
 Begin
  ExitProc:=SavedExitPtr;
 End;
Begin
 SavedExitPtr:=ExitProc;
 ExitProc:=@MouseExit;
 MsInit;
End.

