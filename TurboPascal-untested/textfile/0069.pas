
Program Viewit;
{$A-,B-,D-,E-,F-,G-,I-,L-,N-,O-,R-,S-,V-,X+}
{$M $800,0,655000}

 Uses Crt, DOS, Swunit, UmbHeap;
                       {^^^^^^^This Unit is in SWAG! Wish I can Find a XMS
                       one that can do the Same}
 Type
   TextMem = Array [1..15000] Of ^String;
   BString = String [32];
 Var
   NName  : String [14];
   FileVar: Text;
   FText  : TextMem;
   Lines  : Integer;
   Last   : Integer;
   OneLine, Temp, SString: BString;

 Procedure ShowColor (S : String);
 Var
   I: Byte;
 Begin
   For I := 1 To Length (S)
   Do Begin
     Case S [I] Of
       '0'..'9' : TextColor (LightCyan);
       'A'..'Z' : TextColor (LightGray);  {Changes Charater Colors in the
       File}        'a'..'z' : TextColor (White);      {Kinda Cool}
       #9: Write (' ': 8);
       Else TextColor (3);
     End;
     If S [I] <> #9 Then Write (S [I] );
   End;
   I := 79 - Length (S); Write (' ': I);
 End;

 Procedure Init (N: String);
 Var F: Text;
   S: String;
 Begin
   Extend_Heap;
   Curoff;
   FillChar ( FText, SizeOf (FText), 0 );
   Lines := 0;
   Assign ( f, N );
   (*$I-*)
   Reset ( f );
   (*$I+*)
   If IOResult <> 0 Then Exit;
   While ( Not EoF ( F ) )
         And ( MaxAvail > 80 )
   Do
   Begin
     Inc ( Lines );
     ReadLn ( F, S );
     If Length (S) > 79
     Then S [0] := #79;
     GetMem ( FText [Lines], 1 + Length (S) );
     FText [Lines]^ := S;
   End;
   Last := Lines;
   Close ( F );
 End;

{Ok NOW this Shearch KINDA Works ...Still Working On it!
If I dont hope someone can improv on it..}

Procedure Ucase (Var S: BString);
Var
  I: Integer;
Begin
  For I := 1 To Length (S) Do
    S [I] := UpCase (S [I] );
End;

Procedure LookFor (R: String);

Var
  I: Integer;
  S: BString;
Begin
  For I := 1 To Length (S) Do
    S [I] := UpCase (S [I] );
Begin
  GotoXY (2, 1);
  Assign (FileVar, R);
  Repeat
    WriteLn;
    GotoXY (2, 1);
    Reset (FileVar);
    ClrEol;
    TextAttr := 116; Write ('Search for? (Enter to quit) ');
    ReadLn (SString);
    If Length (SString) > 0 Then
    Begin
      Ucase (SString);
      Lines := 0;
      While Not EoF (FileVar) Do
      Begin
        TextAttr := 112;
        ReadLn (FileVar, OneLine);
        Inc (Lines);
        Temp := OneLine;
        Ucase (Temp);
        If Pos (SString, Temp) > 0
        Then WriteLn (Lines: 3, ': ', OneLine)
      End
    End
  Until Length (SString) = 0;
  GotoXY (1, 1);
  ClrEol;
End;
End;

Procedure ScrS (N: String);
Var CH : Char;
  count: Integer;

Begin
  Rot;
  TextAttr := $70;  (* Colors For Line 1 & 25 *)
  ClrScr;
  GotoXY ( 2, 1);
   Write ('F3=Find    F12=Screen Saver ');
  GotoXY ( 2, 25);
  While Pos ('\', N) > 0 Do Delete (n, 1, 1);
  For count := 1 To Length (N) Do N [count] := UpCase (n [count] );
  Write ('File: ', N, ', ', Last, ' Lines,  ');
  Write ( MemAvail, ' Bytes free.');
  GotoXY (63, 25); Write ('Lines: ');
  count := 1;
End;


Procedure Display (N: String);
 Var CH : Char;
   count: Integer;
 Procedure Update;
     Var Y, i: Integer;
     Begin
       If count > ( Last - 22 )
       Then count := last - 22;
       If count < 1
       Then count := 1;
       Y := 2;
       For  i := count To count + 22 Do
       Begin
         GotoXY (1, Y);
         ClrEol;
         Inc ( Y );
         If i <= Last Then ShowColor ( FText [i]^ ); {Displays File}
       End;
       TextAttr := $74;  (* Colors for Counter *)
       GotoXY (70, 25);
       If count + 23 > Last
       Then Write (Last)
       Else Write (count + 22);
       ClrEol
     End;

 Begin
   TextAttr := $70;  (* Colors For Line 1 & 25 *)
   ClrScr;
   GotoXY ( 2, 1);
   Write ('F3=Find    F12=Screen Saver ');
   {Write (' ');    }
   GotoXY ( 2, 25);
   While Pos ('\', N) > 0 Do Delete (n, 1, 1);
   For count := 1 To Length (N) Do N [count] := UpCase (n [count] );
   Write ('File: ', N, ', ', Last, ' Lines,  ');
   Write ( MemAvail, ' Bytes free.');
   GotoXY (63, 25); Write ('Lines: ');
   count := 1;
   Repeat
     TextAttr := $15;  { white on blue }
     Update;
     Repeat
       CH := ReadKey;
       If CH = #0 Then
       Begin
         CH := ReadKey;
         Case CH Of
           'H' : CH := #1; { up }
           'P' : CH := #2; { down }
           'Q' : CH := #3; { pg-up }
           'I' : CH := #4; { pg-down }
           'G' : CH := #5; { home }
           'O' : CH := #6; { end }
           #61 : CH := #7; {invoke lookfor F3}
           #67 : CH := #8  {Screen Saver F10}
           Else CH := #0; { discard }
         End
       End
     Until CH In [#27, #1..#8 ] ;
     Case CH Of
       #1 : Dec ( count );
       #2 : Inc ( count );
       #3 : Inc ( count, 22 );
       #4 : Dec ( count, 22 );
       #5 : count := 1;
       #6 : count := last;
       #7 : LookFor (ParamStr (1) );
       #8 : ScrS (ParamStr (1) );
     End;
   Until CH = #27;
 End;

 Procedure CleanUp;
 Var I : Integer;
 Begin   For I := last Downto 1 Do
   (*   FreeMem ( FText [i], 1 + Length (FText [i]^) );*)
   {This Causes RunTime Errors with the UMBHeap unit Added}
   TextAttr := 0;
   Curon;
   ClrScr;

 End;


Begin
  If ParamCount <> 1 Then
  Begin
    ClrScr;
    TextColor (15); WriteLn (' Cool View v1.0 Coded ßy ScrewFace CopyRight
95-96'    ); TextColor (8); WriteLn (' Usage :  VIEWER
[Drive:[\Path\]Name.Ext');    Sound (600);
    Delay (200);
    Sound (500);
    Delay (500);
    NoSound;
    Halt (0)
  End;
  Init (ParamStr (1) );
  { If Lines > 0 Then}
Begin
  Display (ParamStr (1) );
  CleanUp;
End;
End.

    =-==-==-=-=-=-=-==-=-=-=-=-==-=UNIT-==-=-=-=-=-==-==-=-=-=-=-==-=-=-
Unit Swunit;
{$A-,B-,D-,E-,F-,G+,I-,L-,N-,O-,R-,S-,V-,X+}
{$M $800,0,6550}

Interface
Procedure StringFx (s: String; X, Y, ic, c1, c2, c3 : Byte; del : Word);
Procedure Rot;
Procedure Curon;
Procedure Curoff;

Implementation
Uses Crt, DOS;

Function keypress : Boolean; Assembler; Asm
  mov AH, 0BH; Int 21h; And AL, 0feh; 
End;

Procedure StringFx (s: String; X, Y, ic, c1, c2, c3 : Byte; del : Word);
Var
  i : Integer;
  StrPos : Byte;
  CH : Char;
Begin
  GotoXY (X, Y);
  TextAttr := ic;
  Write (s);
  StrPos := 1;
  i := 1;
  While Not KeyPressed Do
  Begin
    Delay (del);
    GotoXY (X + (StrPos - 1), Y);
    TextAttr := ic; Write (s [StrPos] );
    TextAttr := c1; Write (s [StrPos + 1] );
    TextAttr := c2; Write (s [StrPos + 2] );
    TextAttr := c3; Write (s [StrPos + 3] );
    TextAttr := c2; Write (s [StrPos + 4] );
    TextAttr := c1; Write (s [StrPos + 5] );
    TextAttr := ic; Write (s [StrPos + 6] );
    Inc (StrPos, i);
    If StrPos + 6 = Ord (S [0] ) Then i := - 1;
    If StrPos = 1 Then i := 1;
  End;
  {   ch := readkey; if ch = #0 Then ch := readkey;}
End;

Procedure Curoff;
Begin
  Asm (* cursor off / Remove this if using the Code for A Door*)
    MOV  AH, 3
    XOr  BX, BX
    Int  10H
    Or   CH, 20H
    MOV  AH, 1
    Int  10H
  End;
End;


{clrscr;  (*Examples*)
StringFx('   ··  Press Any Key  ··   ',(lo(windmax) div
2)-10,hi(windmax)+1,red,lightred,lightred,15,300);{clrscr;
StringFx('   ··  Press Any Key  ··   ',(27),11,red,lightred,lightred,15,50);}

Procedure Curon;
Begin
  Asm (* cursor on / Remove this if using the Code for A Door*)
    MOV  AH, 3
    XOr  BX, BX
    Int  10H
    And   CH, 1FH
    MOV  AH, 1
    Int  10H
  End;
End;

Procedure Rot;
{Dont Remmber Who made this But I put in Here cause it Was Cool}

Const
  gseg : Word = $a000;
  dots = 459;
  dist : Word = 250;
  sintab : Array [0..255] Of Integer = (
  0, 3, 6, 9, 13, 16, 19, 22, 25, 28, 31, 34, 37, 40, 43, 46, 49, 52, 55, 58,
60, 63, 66, 68,  71, 74, 76, 79, 81, 84, 86, 88, 91, 93, 95, 97, 99, 101, 103,
105, 106, 108, 110, 111,  113, 114, 116, 117, 118, 119, 121, 122, 122, 123,
124, 125, 126, 126, 127, 127, 127,  128, 128, 128, 128, 128, 128, 128, 127,
127, 127, 126, 126, 125, 124, 123, 122, 122,  121, 119, 118, 117, 116, 114,
113, 111, 110, 108, 106, 105, 103, 101, 99, 97, 95, 93,
  91, 88, 86, 84, 81, 79, 76, 74, 71, 68, 66, 63, 60, 58, 55, 52, 49, 46, 43,
40, 37, 34, 31,  28, 25, 22, 19, 16, 13, 9, 6, 3, 0, - 3, - 6, - 9, - 13, -
16, - 19, - 22, - 25, - 28, - 31, - 34,  - 37, - 40, - 43, - 46, - 49, - 52, -
55, - 58, - 60, - 63, - 66, - 68, - 71, - 74, - 76, - 79, - 81,
  - 84, - 86, - 88, - 91, - 93, - 95, - 97, - 99, - 101, - 103, - 105, - 106,
- 108, - 110, - 111,  - 113, - 114, - 116, - 117, - 118, - 119, - 121, - 122,
- 122, - 123, - 124, - 125, - 126,  - 126, - 127, - 127, - 127, - 128, - 128,
- 128, - 128, - 128, - 128, - 128, - 127, - 127,  - 127, - 126, - 126, - 125,
- 124, - 123, - 122, - 122, - 121, - 119, - 118, - 117, - 116,
  - 114, - 113, - 111, - 110, - 108, - 106, - 105, - 103, - 101, - 99, - 97, -
95, - 93, - 91,  - 88, - 86, - 84, - 81, - 79, - 76, - 74, - 71, - 68, - 66, -
63, - 60, - 58, - 55, - 52, - 49,  - 46, - 43, - 40, - 37, - 34, - 31, - 28, -
25, - 22, - 19, - 16, - 13, - 9, - 6, - 3);Type
  dotrec = Record X, Y, z : Integer; End;
  dotpos = Array [0..dots] Of dotrec;
Var dot : dotpos;


{----------------------------------------------------------------------------}
  Procedure setpal (col, r, g, b : Byte); Assembler; Asm
    mov DX, 03c8h; mov AL, col; out DX, AL; Inc DX; mov AL, r
    out DX, AL; mov AL, g; out DX, AL; mov AL, b; out DX, AL;
  End;

Procedure setvideo (Mode : Word); Assembler; Asm
  mov AX, Mode; Int 10h
End;

Function esc : Boolean; Begin
  esc := port [$60] = 1;
End;

{----------------------------------------------------------------------------}

Procedure initi;
Var i : Word; X, z : Integer;
Begin
  i := 0;
  z := - 100;
  While z < 100 Do Begin
    X := - 100;
    While X < 100 Do Begin
      dot [i].X := X;
      dot [i].Y := - 45;
      dot [i].z := z;
      Inc (i);
      Inc (X, 10);
    End;
    Inc (z, 9);
  End;
  For i := 0 To 63 Do setpal (i, 0, i, i);
End;

{----------------------------------------------------------------------------}

Procedure rotation;
Const yst = 1;
Var
  xp : Array [0..dots] Of Word;
  yp : Array [0..dots] Of Byte;
  X, z : Integer; n : Word; phiy : Byte;
Begin
  Asm mov phiy, 0; mov ES, gseg; cli; End;
  Repeat
    Asm
      mov DX, 03dah
      @l1:
      In AL, DX
      Test AL, 8
      jnz @l1
      @l2:
      In AL, DX
      Test AL, 8
      jz @l2
    End;
    setpal (0, 0, 0, 10);
    For n := 0 To dots Do Begin
      Asm
        mov SI, n
        mov AL, Byte Ptr yp [SI]
        cmp AL, 200
        jae @skip
        ShL SI, 1
        mov BX, Word Ptr xp [SI]
        cmp BX, 320
        jae @skip
        ShL AX, 6
        mov DI, AX
        ShL AX, 2
        add DI, AX
        add DI, BX
        XOr AL, AL
        mov [ES: DI], AL
        @skip:
      End;
      
      X := (sintab [ (phiy + 192) Mod 255] * dot [n].X
      {^^^^  ^^^^^^^^^^^^^^^^^^^^^^^^^^ ^ ^^^^^^^^
      9     1                          3 2 }

      - sintab [phiy] * dot [n].z) Div 128;
      { ^ ^^^^^^^^^^^^ ^ ^^^^^^^^  ^^^^^^^
      7 4            6 5         8 }
      
      (*
      asm
      xor ah,ah                      { 1 }
      mov al,phiy
      add al,192
      mov si,ax
      mov ax,word ptr sintab[si]
      mov si,n                       { 2 }
      mov dx,word ptr dot[si].x
      mul dx                         { 3 }
      mov cx,ax
      mov dx,word ptr dot[si].z      { 5 }
      mov al,phiy                    { 4 }
      mov si,ax
      mov ax,word ptr sintab[si]
      mul dx                         { 6 }
      sub cx,ax                      { 7 }
      shr cx,7                       { 8 }
      mov x,cx                       { 9 }
      end;
      *)

      z := (sintab [ (phiy + 192) Mod 255] * dot [n].z + sintab [phiy] * dot
[n].X) Div 128;      xp [n] := 160 + (X * dist) Div (z - dist);
      yp [n] := 100 + (dot [n].Y * dist) Div (z - dist);
      
      {
      asm
      mov ax,x
      mov dx,dist
      mul dx
      mov dx,z
      sub dx,dist
      div dx
      add ax,160

      (* can't assign ax to xp[n] !? *)
      
      end;
      }

      Asm
        mov SI, n
        mov AL, Byte Ptr yp [SI]
        cmp AL, 200
        jae @skip
        ShL SI, 1
        mov BX, Word Ptr xp [SI]
        cmp BX, 320
        jae @skip
        ShL AX, 6
        mov DI, AX
        ShL AX, 2
        add DI, AX
        add DI, BX
        mov AX, z
        ShR AX, 3
        add AX, 30
        mov [ES: DI], AL
        @skip:
      End;
    End;
    Asm Inc phiy End;
    setpal (0, 0, 0, 0);
  Until KeyPressed;
  Asm sti End;
End;

{----------------------------------------------------------------------------}

Begin
  setvideo ($13);
  Initi;
  rotation;
  TextMode (LastMode);
End;
End.
