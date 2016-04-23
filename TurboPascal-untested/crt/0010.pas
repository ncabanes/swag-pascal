(*
===========================================================================
 BBS: Beta Connection
Date: 09-21-93 (09:28)             Number: 2846
From: ROBERT ROTHENBURG            Refer#: 2648
  To: GAYLE DAVIS                   Recvd: YES (PVT)
Subj: SWAG Submission  (Part 1)      Conf: (232) T_Pascal_R
---------------------------------------------------------------------------
->#643

Gayle,

        Here's the GUI Unit I mentioned that I would submit for the SWAG
        reader a while back.

        There's no documentation and a few things could be touched up,
        but it works.

*)

Unit GUI; (* Video and GUI Routines *)

Interface

Const
  NormalCursor = $0D0E; (* Might be different on some systems *)
  BlankCursor  = $2000;

Type
  ScrBuffer   = Array [0..1999] Of Word; (* Screen Buffer *)

Var
  DirectVideoGUI: Boolean; (* define as TRUE if direct-video writing *)
  Screen: Array [0..7] Of ScrBuffer Absolute $B800: 0000;

Procedure SetActivePage (Page: Byte);
Procedure ScrollWindowUp (NoLines, Attrib, ColUL, RowUL, ColLR, RowLR: Byte);
Procedure ScrollWindowDn (NoLines, Attrib, ColUL, RowUL, ColLR, RowLR: Byte);
Procedure HLineCharAttrib (Page: Byte; CharAttrib: Word; xFrom, xTo, Y: Byte);
Procedure VLineCharAttrib (Page: Byte; CharAttrib: Word; X, yFrom, yTo: Byte);
Function  GetCharAttribXY (Page, X, Y: Byte): Word;
Function  GetCharAttrib (Page: Byte): Word;
Procedure PutCharAttrib (Page: Byte; CharAttrib: Word; NoChar: Word);
Procedure WriteChar (Page: Byte; CharAttrib: Word; NoChar: Word);
Procedure CWriteXY (Page, attrib, X, Y: Byte; n: String);
Procedure WriteXY (Page, attrib, X, Y: Byte; Var n: String);
Procedure WriteXYCh (Page, attrib, X, Y, c: Byte);
Procedure SetCursorPos (Page, Column, Row: Byte);
Procedure GetCursorPos (Var Page, Column, Row: Byte);
Procedure SetCursorType (ctype: Word);
Function  GetCursorType (Page: Byte): Word;

Procedure InitDirect;
Procedure SavScr (Page: Byte; Var S: ScrBuffer);
Procedure ResScr (Page: Byte; Var S: ScrBuffer);

Function  GetKeyCode: Word; (* Wait for Key from Buffer *)
Function  GetKeyFlags: Byte;
Function  PollKey (Var Status: Word): Word;
Function  GetKeyStroke: Word;  (* Enhanced Keyboard? *)
Function  CheckKeyBoard: Word; (* Enhanced Keyboard? *)
Procedure WriteKey (KeyCode: Word; Var Status: Byte);

Procedure WaitOnUser (Var Code, X, Y, Button: Word);
Function  InitMouse: Word;
Procedure ShowMouseCursor;
Procedure HideMouseCursor;
Procedure SetMouseWindow (X1, Y1, X2, Y2: Word);
Procedure GetMousePos (Var X, Y, button: Word);
Procedure SetMousePos (X, Y: Word);
Procedure GetButtonPressInfo (Var X, Y, Button, NumberOfPresses: Word);
Procedure GetButtonRelInfo (Var X, Y, Button, NumberOfReleases: Word);

Procedure Frame (Page, X1, Y1, X2, Y2, c: Byte; Title: String);
Procedure Shadow (Page, X1, Y1, X2, Y2, cc: Byte);
Procedure FHLine (Page, Attrib, xFrom, xTo, Y: Byte);
Procedure FVLine (Page, Attrib, X, yFrom, yTo: Byte);
Procedure FrameReadLN (Var T: String; Page, X1, Y1, X2, Y2, cc: Byte);
Procedure Dialogue (Var T: String; Page, X1, Y1, X2, Y2, cc: Byte; Title: String);

IMPLEMENTATION

uses DOS;

Const
  NUL    = #00;
  DEL    = #08;
  LF     = #10;
  CR     = #13;
  SP     = #32;

  VIO    = $10;  (* BIOS Video Interrupt *)
  KBIO   = $16;  (* BIOS Keyboard        *)
  MIO    = $33;  (* Mouse Services       *)
Var X, Y: Word;
    reg: registers;
    DTemp: ScrBuffer;

function x80(y: word): word;
begin
  asm
    MOV AX,y
    MOV BX,AX
    MOV CL,4
    SHL BX,CL
    MOV CL,6
    SHL AX,CL
    ADD AX,BX
    MOV @Result, AX
  end
end;

function x80p(y,x: word): word;
begin
  asm
    MOV AX,y
    MOV BX,AX
    MOV CL,4
    SHL BX,CL
    MOV CL,6
    SHL AX,CL
    ADD AX,BX
    ADD AX,x
    MOV @Result, AX
  end
end;

Procedure WriteChar (Page: Byte; CharAttrib: Word; NoChar: Word);
Begin
  Asm
    MOV AX, CharAttrib
    MOV BL, AH
    MOV AH, $0A
    MOV BH, Page
    MOV CX, NoChar
    Int VIO
  End;
End;

Procedure PutCharAttrib (Page: Byte; CharAttrib: Word; NoChar: Word);
Begin
  Asm
    MOV AX, CharAttrib
    MOV BL, AH
    MOV AH, $09
    MOV BH, Page
    MOV CX, NoChar
    Int VIO
  End;
End;

Function GetCharAttrib (Page: Byte): Word;
Begin
  Asm
    MOV AH, $08
    MOV BH, Page
    Int VIO
    MOV @Result, AX
  End;
End;

Procedure InitDirect; (* CRT uses the variable "DirectVideo"... *)
Begin
  DirectVideoGUI := True
End;

Function GetCharAttribXY (Page, X, Y: Byte): Word;
Begin
  If DirectVideoGUI
  Then GetCharAttribXY := Screen [Page] [ x80p(Y,X)]
  Else Begin
    Asm
      MOV AH, $02
      MOV BH, Page
      MOV DH, Y
      MOV DL, X
      Int VIO
      MOV AH, $08
      MOV BH, Page
      Int VIO
      MOV @Result, AX
    End
  End;
End;

Procedure ScrollWindowUp (NoLines, Attrib, ColUL, RowUL, ColLR, RowLR: Byte);
  Assembler;
Asm
  MOV AH, $06
  MOV AL, NoLines
  MOV BH, Attrib
  MOV CH, RowUL
  MOV CL, ColUL
  MOV DH, RowLR
  MOV DL, ColLR
  Int VIO
End;

Procedure ScrollWindowDn (NoLines, Attrib, ColUL, RowUL, ColLR, RowLR: Byte);
Begin
  Asm
    MOV AH, $07
    MOV AL, NoLines
    MOV BH, Attrib
    MOV CH, RowUL
    MOV CL, ColUL
    MOV DH, RowLR
    MOV DL, ColLR
    Int VIO
  End;
End;

Procedure SetActivePage (Page: Byte); Assembler;
Asm
  MOV AH, $05
  MOV AL, Page
  Int VIO
End;

Procedure GetCursorPos (Var Page, Column, Row: Byte);
Var p, X, Y: Byte;
Begin
  p := Page;
  Asm
    MOV AH, $03
    MOV BH, p
    Int VIO
    MOV p, BH
    MOV X, DL
    MOV Y, DH
  End;
  Page := p;
  Column := X;
  Row := Y;
End;

Function GetCursorType (Page: Byte): Word;
Begin
  Asm
    MOV AH, $03;
    MOV BH, Page
    Int VIO
    MOV @Result, CX
  End;
End;

Procedure SetCursorPos (Page, Column, Row: Byte);
Begin
  Asm
    MOV AH, $02
    MOV BH, Page
    MOV DH, Row
    MOV DL, Column
    Int VIO
  End;
End;

Procedure SetCursorType (ctype: Word);
Begin
  Asm
    MOV AH, $01
    MOV CX, ctype
    Int VIO
  End;
End;

Procedure WriteXYCh (Page, attrib, X, Y, c: Byte);
Begin
  If DirectVideoGUI
  Then Screen [Page] [ x80p(Y,X) ] :=
    (attrib ShL 8) + c
  Else Begin
    Asm
      MOV AH, $02
      MOV BH, Page
      MOV DL, X
      MOV DH, Y
      Int VIO
      MOV AL, c
      MOV BL, Attrib
      MOV AH, $09
      MOV CX, 1
      Int VIO
    End
  End
End;

Procedure WriteXY (Page, attrib, X, Y: Byte; Var n: String);
Var i: byte;
Begin
  If n [0] <> #0
  Then If DirectVideoGUI
  Then Begin
    For i := 1 To Length (n)
    Do Screen [Page] [ x80p(Y,X+Pred (i)) ] := (attrib ShL 8) + Ord (n [i] );
  End
  Else Begin
   for i:=1 to Length(n)
    do
     WriteXYCh(Page,Attrib,X+pred(i),y,ord(n[i]));
End
End;

Procedure CWriteXY (Page, attrib, X, Y: Byte; n: String);
Begin
  WriteXY (Page, attrib, X, Y, n);
End;

Procedure HLineCharAttrib (Page: Byte; CharAttrib: Word; xFrom, xTo, Y: Byte);
Begin
  If DirectVideoGUI
  Then For X := x80p(Y, xFrom) To x80p(Y, xTo)
    Do Screen [Page] [X] := CharAttrib
  Else Begin
    SetCursorPos (Page, xFrom, Y);
    PutCharAttrib (Page, CharAttrib, (xTo - xFrom) + 1)
  End
End;

Procedure VLineCharAttrib (Page: Byte; CharAttrib: Word; X, yFrom, yTo: Byte);
Var Y: Byte;
Begin
  For Y := yFrom To yTo
  Do If DirectVideoGUI
  Then Screen [Page] [ x80p(Y, X)] := CharAttrib
  Else Begin
    SetCursorPos (Page, X, Y);
    PutCharAttrib (Page, CharAttrib, 1)
  End
End;

Procedure Frame (Page, X1, Y1, X2, Y2, c: Byte; Title: String);
Begin
  ScrollWindowUP (0, c, X1, Y1, X2, Y2); (* Must be on correct Page! *)
  For X := X1 To X2
  Do Begin
    WriteXYCh (Page, c, X, Y1, 196);
    WriteXYCh (Page, c, X, Y2, 196)
  End;
  For Y := Y1 To Y2
  Do Begin
    WriteXYCh (Page, c, X1, Y, 179);
    WriteXYCh (Page, c, X2, Y, 179)
  End;
  WriteXYCh (Page, c, X1, Y1, 218);
  WriteXYCh (Page, c, X2, Y1, 191);
  WriteXYCh (Page, c, X1, Y2, 192);
  WriteXYCh (Page, c, X2, Y2, 217);
  If title <> ''
  Then CWriteXY (Page, c, ( (X2 - X1) - (Length (title) + 2) ) Div 2, Y1, SP+Title);
End;

Procedure FHLine (Page, Attrib, xFrom, xTo, Y: Byte);
Begin
  HLineCharAttrib (Page, (Attrib ShL 8) + 196, Succ (xFrom), Pred (xTo), Y);
  WriteXYCh (Page, Attrib, xFrom, Y, 195);
  WriteXYCh (Page, Attrib, xTo, Y, 180);
End;

Procedure FVLine (Page, Attrib, X, yFrom, yTo: Byte);
Begin
  VLineCharAttrib (Page, (Attrib shl 8) + 179, X, Succ (yFrom), Pred (yTo) );
  WriteXYCh (Page, Attrib, X, yFrom, 194);
  WriteXYCh (Page, Attrib, X, yTo, 193);
End;


Procedure SavScr (Page: Byte; Var S: ScrBuffer);
Begin
  If DirectVideoGUI
  Then Move (Screen, S [Page], 4000)
  Else
    asm
      MOV DL, 79
@I1:  MOV DH, 24
@I0:  MOV BH, Page
      MOV AH,02
      INT VIO
      MOV AH,08
      INT VIO

      XCHG AX, DI
      XOR AX, AX
      MOV AL, DH
      MOV BX, AX
      MOV CL,4
      SHL BX,CL
      MOV CL,6
      SHL AX,CL
      ADD AX,BX
      CLC
      ADD AL,DL
      ADC AH,00
      SHL AX,1
      LDS SI, S
      ADD SI,AX

      XCHG AX, DI
      MOV WORD PTR [SI],AX
      DEC DH
      CMP DH,-1
      JNE @I0
      DEC DL
      CMP DL,-1
      JNE @I1
    end;
End;

Procedure ResScr (Page: Byte; var S: ScrBuffer);
Begin
  If DirectVideoGUI
  Then Move (S, Screen [Page], 4000)
  Else
    asm
      MOV DL, 79
@I1:  MOV DH, 24
@I0:  MOV BH, Page
      MOV AH,02
      INT VIO
      XOR AX, AX
      MOV AL, DH
      MOV BX, AX
      MOV CL,4
      SHL BX,CL
      MOV CL,6
      SHL AX,CL
      ADD AX,BX
      CLC
      ADD AL,DL
      ADC AH,00
      SHL AX,1

      LDS SI, S
      ADD SI,AX

      MOV AX,WORD PTR [SI]
      MOV BL, AH
      MOV BH, Page
      MOV AH, 09
      MOV CX, 1
      int VIO
      DEC DH
      CMP DH,-1
      JNE @I0
      DEC DL
      CMP DL,-1
      JNE @I1
    end;
End;

Function GetKeyCode: Word;
Begin
  Asm
    MOV AH, $00
    Int KBIO
    MOV @Result, AX
  End;
End;

Function PollKey (Var Status: Word): Word;
var s: word;
Begin
  asm
    MOV AH, 01
    INT KBIO
    MOV @Result, AX
    LAHF
    AND AX, 64
    MOV S, AX
  end;
  Status:=s;
End;

Function GetKeyStroke: Word;
Begin
  Asm
    MOV AH, $10
    Int KBIO
    MOV @Result, AX
  End;
End;

Function CheckKeyBoard: Word;
Begin
  Asm
    MOV AH, $11
    Int KBIO
    MOV @Result, AX
  End;
End;

Function GetKeyFlags: Byte;
Begin
  Asm
    MOV AH, $02
    Int KBIO
    MOV @Result, AL
  End;
End;

Function GetKeyStatus: Word;
Begin
  Asm
    MOV AH, $12
    Int KBIO
    MOV @Result, AX
  End;
End;

Procedure WriteKey (KeyCode: Word; Var Status: Byte);
Var s: Byte;
Begin
  Asm
    MOV AH, $05
    MOV CX, KeyCode
    Int KBIO
    MOV s, AL
  End;
  Status := s;
End;

Procedure WaitOnUser (Var Code, X, Y, Button: Word);
 (* wait for key or mouse click *)
Var Status: Word;
Begin
  Repeat
    Code := PollKey (Status);
    GetMousePos (X, Y, Button);
  Until (Button <> 0) Or (Status = 0);
End;

Function InitMouse: Word;
Begin
  Asm
    MOV AX, $0000
    Int MIO
    MOV @Result, AX
  End;
End;

Procedure ShowMouseCursor; Assembler;
Asm
  MOV AX, $0001
  Int MIO
End;

Procedure HideMouseCursor; Assembler;
Asm
  MOV AX, $0002
  Int MIO
End;

Procedure GetMousePos (Var X, Y, Button: Word);
Var X1, Y1, b: Word;
Begin
  Asm
    MOV AX, $0003
    Int MIO
    MOV b,  BX
    MOV X1, CX
    MOV Y1, DX
  End;
  X := X1;
  Y := Y1;
  Button := b;
End;

Procedure SetMousePos (X, Y: Word); Assembler;
Asm
  MOV AX, $0004
  MOV CX, X
  MOV DX, Y
  Int MIO
End;

Procedure GetButtonPressInfo (Var X, Y, Button, NumberOfPresses: Word);
Begin
  reg. AX := $0005;
  reg. BX := Button;
  Intr (MIO, reg);
  Button := reg. AX;
  X := reg. CX;
  Y := reg. DX;
  NumberOfPresses := reg. BX
End;

Procedure GetButtonRelInfo (Var X, Y, Button, NumberOfReleases: Word);
Begin
  reg. AX := $0006;
  reg. BX := Button;
  Intr (MIO, reg);
  Button := reg. AX;
  X := reg. CX;
  Y := reg. DX;
  NumberOfReleases := reg. BX
End;

Procedure SetMouseWindow (X1, Y1, X2, Y2: Word);
Begin
  reg. AX := $0007;
  reg. CX := X1;
  reg. DX := X2;
  Intr ($33, reg);
  Inc (reg. AX, 1);
  reg. CX := Y1;
  reg. DX := Y2;
  Intr (MIO, reg)
End;


Procedure Shadow (Page, X1, Y1, X2, Y2, cc: Byte);
Begin
  HLineCharAttrib (Page, (cc * $100) + $B1, Succ (X1), Succ (X2), Succ (Y2) );
  VLineCharAttrib (Page, (cc * $100) + $B1, Succ (X2), Succ (Y1), Succ (Y2) );
End;

Procedure Dialogue (Var T: String; Page, X1, Y1, X2, Y2, cc: Byte; Title: String);
Begin
  SavScr (Page, DTemp);
  Frame (Page, X1, Y1, X2, Y2, cc, ''); Title := SP + Title + SP;
  WriteXY (Page, cc, Succ (X1), Y1, Title);
  FrameReadLN (T, Page, Succ (X1), Succ (Y1), Pred (X2), Pred (Y2), cc);
  ResScr (Page, DTemp)
End;

Procedure FrameReadLN (Var T: String; Page, X1, Y1, X2, Y2, cc: Byte);
Var i, X, Y, z: Byte;
  Code: Word;
  C: Char;
Begin
  X := X1; Y := Y1;
  If T [0] <> #0
  Then For i := 0 To Pred (Ord (T [0] ) )
    Do WriteXYCh (Page, cc, (i Mod (X2 - X1) ) + X1, (i Div (X2 - X1) ) + Y1, Ord(T[0]));
  SetCursorType (NormalCursor);
  i := 0;
  Repeat
    SetCursorPos (Page, X, Y);
    Code := GetKeyCode;
    C := Chr (Lo (Code) );
    If C = NUL
    Then Begin
      Case Hi (Code) Of
        $4B: If i <> 0 Then Dec (i);
        $4D: If i < Ord (T [0] ) Then Inc (i);
        $47: i := 0;
        $4F: i := Ord (T [0] );
        {   $53:if i<ord(T[0]) then begin
        if i>1
        then T:=Copy(T,1,pred(i))+Copy(T,succ(i),255)
        else if i<>ord(T[0])
        then T:=Copy(T,2,255)
        else T:=Copy(T,1,pred(i));
        for z:=i to ord(T[0])
        do WriteXY(Page,cc,(z mod (x2-x1))+x1,(z div (x2-x1))+y1,T[z]);
        WriteXY(Page,cc,(succ(z) mod (x2-x1))+x1,
        (succ(z) div (x2-x1))+y1,SP);
        end;    }
      End;
      X := (i Mod (X2 - X1) ) + X1;
      Y := (i Div (X2 - X1) ) + Y1
    End
    Else If C <> CR
    Then If (i < 255) And (Y <= Y2)
    Then If C <> DEL
    Then Begin
      Inc (i);
      T [i] := C;
      If i > Ord (T [0] )
      Then Inc (T [0], 1);
      WriteXYCh (Page, cc, X, Y, Ord (C) );
      Inc (X);
      If X = X2
      Then Begin
        Inc (Y);
        X := X1
      End
    End
    Else If (i <> 0) And (i = Ord (T [0] ) )
    Then Begin
      {  if i<ord(T[0])
      then T:=Copy(T,1,pred(i))+Copy(T,succ(i),255);}
      Dec (i);
      Dec (T [0], 1);
      If X = X1
      Then Begin
        X := Pred (X2);
        Dec (Y)
      End
      Else Dec (X);
      If i = Ord (T [0] )
      Then WriteXYCh (Page, cc, X, Y, 32)
        {   else begin
        for z:=i to ord(T[0])
        do WriteXY(Page,cc,(z mod (x2-x1))+x1,(z div (x2-x1))+y1,T[z]);
        WriteXY(Page,cc,(succ(z) mod (x2-x1))+x1,
        (succ(z) div (x2-x1))+y1,SP);
        x:=(i mod (x2-x1))+x1;
        y:=(i div (x2-x1))+y1
        end  }
    End
  Until C = CR;
  SetCursorType (BlankCursor);
End;

End.
---
 * Your Software Resource * Selden NY * 516-736-6662
 * PostLink(tm) v1.07  YOURSOFTWARE (#5190) : RelayNet(tm)
