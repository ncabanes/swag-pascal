Unit Multi;
{--------------------------------------------------------------------------------}
{                                                                                }
{ Hilfsfunktionen zur quasi-Multitaskingverarbeitung unter Turbo Pascal          }
{                                                                                }
{ (c) 1994 by Hegel Udo                                                          }
{                                                                                }
{--------------------------------------------------------------------------------}
Interface
{--------------------------------------------------------------------------------}
Type
  StartProc = Procedure;
{--------------------------------------------------------------------------------}
Procedure AddTask (Start : StartProc;StackSize : Word);
Procedure Transfer;
{--------------------------------------------------------------------------------}
Implementation
{--------------------------------------------------------------------------------}
Uses
  Dos;
{--------------------------------------------------------------------------------}
Type
  TaskPtr   = ^TaskRec;
  TaskRec   = Record
    StackSize : Word;
    Stack     : Pointer;
    SPSave    : Word;
    SSSave    : Word;
    BPSave    : Word;
    Next      : TaskPtr;
  end;
{--------------------------------------------------------------------------------}
Const
  MinStack = 1024;
  MaxStack = 32768;
{--------------------------------------------------------------------------------}
Var
  Tasks    : TaskPtr;
  AktTask  : TaskPtr;
  OldExit  : Pointer;
{--------------------------------------------------------------------------------}
Procedure AddTask (Start : StartProc;StackSize : Word);
Type
  OS = Record
    O,S : Word;
  end;
Var
  W  : ^TaskPtr;
  SS : Word;
  SP : Word;
begin
  W := @Tasks;
  While Assigned (W^) do W := @W^^.Next;
  New (W^);
  if StackSize < MinStack then StackSize := MinStack;
  if StackSize > MaxStack then StackSize := MaxStack;
  W^^.StackSize := StackSize;
  GetMem (W^^.Stack,StackSize);
  SS := OS(W^^.Stack).S;
  SP := OS(W^^.Stack).O+StackSize-4;
  Move (Start,Ptr(SS,SP)^,4);
  W^^.SPSave := SP;
  W^^.SSSave := SS;
  W^^.BPSave := W^^.SPSave;
  W^^.Next := NIL;
end;
{--------------------------------------------------------------------------------}
Procedure Transfer; Assembler;
Asm
  LES SI,AktTask                               { Alter Status sichern }
  MOV ES:[SI].TaskRec.SPSave,SP
  MOV ES:[SI].TaskRec.SSSave,SS
  MOV ES:[SI].TaskRec.BPSave,BP
  MOV AX,Word Ptr ES:[SI].TaskRec.Next         { Neue Task bestimmen }
  OR  AX,Word Ptr ES:[SI].TaskRec.Next+2
  JE  @InitNew
  LES SI,ES:[SI].TaskRec.Next
  JMP @DoJob
@InitNew:
  LES SI,Tasks
@DoJob:
  MOV Word Ptr AktTask,SI                      { Neue Task Sichern }
  MOV Word Ptr AktTask+2,ES
  CLI                                          { Status wieder hertstellen }
  MOV SP,ES:[SI].TaskRec.SPSave
  MOV SS,ES:[SI].TaskRec.SSSave
  STI
  MOV BP,ES:[SI].TaskRec.BPSave
end;
{--------------------------------------------------------------------------------}
BEGIN
  New (Tasks);              { Hauptprogramm als Task anmelden }
  Tasks^.StackSize := 0;
  Tasks^.Stack := NIL;
  Tasks^.Next := NIL;
  AktTask := Tasks;
END.

{ --------------------------   DEMO PROGRAM ---------------------- }

Program Multi_Demo;

Uses
  DOS, Crt, Multi;

TYPE

      ScreenState = (free, used);          { Is screen position free? }
      WindowType  = Record                 { Window descriptor }
                      X,
                      Y,
                      Xsize,
                      Ysize  : Integer;
                    End;


var   screen      : Array(.0..81,0..26.) of ScreenState;
      WindowTable : Array(.1..20.) of WindowType;
      i,j,                                 { Index variables }
      NoWindows   : Integer;               { No. of windows on screen }

Procedure MakeWindow(X, Y, Xsize, Ysize: Integer; Heading: String);

{ Reserves screenspace for window and draws border around it }

   const NEcorner = #187;                { Characters for double-line border }
         SEcorner = #188;
         SWcorner = #200;
         NWcorner = #201;
         Hor      = #205;
         Vert     = #186;

   var   i,j : Integer;

   Begin
     Window(1,1,80,25);

     { Reserve screen space }
     For i:=X to X+Xsize-1 Do
       For j:=Y to Y+Ysize-1 Do screen(.i,j.):=used;

     { Draw border - sides }
     i:=X;
     For j:=Y+1 to Y+Ysize-2 Do
     Begin
       GotoXY(i,j);
       Write(Vert);
     End;

     i:=X+Xsize-1;
     For j:=Y+1 to Y+Ysize-2 Do
     Begin
       GotoXY(i,j);
       Write(Vert);
     End;

     j:=Y;
     For i:=X+1 to X+Xsize-2 Do
     Begin
       GotoXY(i,j);
       Write(Hor);
     End;

     j:=Y+Ysize-1;
     For i:=X+1 to X+Xsize-2 Do
     Begin
       GotoXY(i,j);
       Write(Hor);
     End;

     { Draw border - corners }
     GotoXY(X,Y);
     Write(NWcorner);
     GotoXY(X+Xsize-1,Y);
     Write(NEcorner);
     GotoXY(X+Xsize-1,Y+Ysize-1);
     Write(SEcorner);
     GotoXY(X,Y+Ysize-1);
     Write(SWcorner);

     { Make Heading }
     GotoXY(X+(Xsize-Length(Heading)) div 2,Y);
     Write(heading);

     { Save in table }
     NoWindows:=NoWindows+1;
     WindowTable(.NoWindows.).X:=X;
     WindowTable(.NoWindows.).Y:=Y;
     WindowTable(.NoWindows.).Xsize:=Xsize;
     WindowTable(.NoWindows.).Ysize:=Ysize;

   End; { MakeWindow }

Procedure SelectWindow(i : Integer);

   { Specifies which window will receive subsequent output }

   Begin
     With WindowTable(.i.) Do
     Begin
       Window(X+1,Y+1,X+Xsize-2,Y+Ysize-2);
     End;
   End; { SelectWindow }


Procedure RemoveWindow(n: Integer);

   { Removes window number n }

   var i,j : Integer;

   Begin
     SelectWindow(n);
     With WindowTable(.n.) Do
     Begin
       Window(X,Y,X+Xsize,Y+Ysize);
       For i:=X to X+Xsize Do
         For j:=Y to Y+Ysize Do screen(.i,j.):=free;
     End; { With }
     ClrScr;
   End; { SelectWindow }

Procedure Task1;Far;
VAR
    SR : SearchRec;
begin
  MakeWindow(27, 2,18,4,' Sub Task 1 ');
  REPEAT
    FINDFIRST('*.*',anyfile,SR);
    WHILE DOSERROR = 0 DO
          BEGIN
          Transfer;
          SelectWindow(2);
          WriteLn(SR.Name : 12);
          FINDNEXT(SR);
          Delay(10);
          END;
  UNTIL FALSE;
end;

Procedure Task2;Far;
VAR
    SR : SearchRec;
begin
  MakeWindow(27, 7,18,4,' Sub Task 2 ');
  REPEAT
    FINDFIRST('\TURBO\TP\*.*',anyfile,SR);
    WHILE DOSERROR = 0 DO
          BEGIN
          Transfer;
          SelectWindow(3);
          WriteLn(SR.Name : 12);
          FINDNEXT(SR);
          Delay(10);
          END;
  UNTIL FALSE;
end;

Procedure Task3;Far;
VAR
    SR : SearchRec;
begin
  MakeWindow(27,12,18,4,' Sub Task 3 ');
  REPEAT
    FINDFIRST('\TURBO\*.*',anyfile,SR);
    WHILE DOSERROR = 0 DO
          BEGIN
          Transfer;
          SelectWindow(4);
          WriteLn(SR.Name : 12);
          FINDNEXT(SR);
          Delay(10);
          END;
  UNTIL FALSE;
end;

Procedure Task4;Far;
VAR
    SR : SearchRec;
begin
  MakeWindow(27,17,18,4,' Sub Task 4 ');
  REPEAT
    FINDFIRST('\*.*',anyfile,SR);
    WHILE DOSERROR = 0 DO
          BEGIN
          Transfer;
          SelectWindow(5);
          WriteLn(SR.Name : 12);
          FINDNEXT(SR);
          Delay(10);
          END;
  UNTIL FALSE;
end;

BEGIN
  ClrScr;
  MakeWindow( 5,21,75,4,' Multi-Program Demo ');
  SelectWindow(1);
  WriteLn(' This is the MAIN task window and we will start 4 others too');
  AddTask (Task1,8192);
  AddTask (Task2,8192);
  AddTask (Task3,8192);
  AddTask (Task4,8192);
  REPEAT
    Transfer;
  UNTIL KEYPRESSED;
END.
