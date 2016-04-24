(*
  Category: SWAG Title: EXECUTION ROUTINES
  Original name: 0010.PAS
  Description: Trapping INT29 Output
  Author: TRISDARESA SUMARJOSO
  Date: 11-02-93  06:30
*)

{
TRISDARESA SUMARJOSO

> I was wondering if anyone knew how to make a split screen While
> making EXEC calls and not losing your Windows?

> Anyone got any ideas or routines that do this? I can do it easily
> using TTT when I just stay Within the Program, but the problems arise
> when I do the SwapVectors and do my Exec call, all hell breaks loose.
> Lynn.

        Here is a Unit that I've created to trap Int 29h. the Function of this
Unit is to trap the output that Dos spits through the Int 29h (such as XCopy,
PkZip, etc) and redirect it into a predefined Window.
        Here is the stuff:
}

Unit I29UnitA;

{ This Unit will trap Dos output which use Int 29h. Any other
  method of writing the scren, such as Direct Write which bypasses
  Int 29h call, will not be trapped. }

Interface

{ Initialize the view that will be use to output the Dos output.
  Will also draw basic Window frame. }
Procedure InitView(XX1, XY1, XX2, XY2 : Byte);
{ Clear the pre-defined view. }
Procedure ClearView;
{ Procedure to redirect the Turbo Pascal Write and WriteLn Procedure.
  (standard OutPut only).
  Do not call this Procedure twice in the row.
  More than once call to this Procedure will result Pascal's standard
  output Procedure will not be restored properly. }
Procedure TrapWrite;
{ Restore Pascal's Write and WriteLn Procedure into its original
  condition that was altered With TRAPWrite. (standard OutPut only). }
Procedure UnTrapWrite;

Implementation

Uses
  Dos;

Type
  VioCharType = Record
    Case Boolean Of
      True  : (Ch, Attr : Byte);
      False : (Content : Word);
    end;

  DrvFunc    = Function(Var F : TextRec) : Integer;
  VioBufType = Array [0..24, 0..79] Of VioCharType;

Var
  OldInt29     : Pointer;
  OldExit      : Pointer;
  OldIOFunc    : DrvFunc;
  OldFlushFunc : DrvFunc;
  TrapWriteVar : Boolean;
  X1, Y1, X2,
  Y2           : Byte;
  XVio         : Byte;
  YVio         : Byte;
  VioBuffer    : ^VioBufType;
  VioCurLoc    : Word Absolute $0040:$0050;

{$F+}
Procedure NewInt29(Flags, CS, IP, AX, BX, CX, DX, SI, DI, DS, ES, BP: Word);
Interrupt;
begin
  VioBuffer^[YVio, XVio].Attr := VioBuffer^[YVio, XVio].Attr And Not 112;
  if (Lo(AX) = 13) Then
  begin
    XVio := X1;
    AX := 0;
  end
  else
  if (Lo(AX) = 10) Then
  begin
    Inc(YVio);
    AX := 0;
  end;
  begin
    if (XVio > X2) Then
    begin
      XVio := X1;
      Inc(YVio);
    end;
    if (YVio > Y2) Then
    begin
      Asm
        Mov   AH, 06
        Mov   AL, YVio
        Sub   AL, Y2
        Mov   CH, Y1
        Mov   CL, X1
        Mov   DH, Y2
        Mov   DL, X2
        Mov   BH, 07
        Int   10h
      end;

      YVio := Y2;
    end;

    if (Lo(AX) = 32) Then
    begin
      if (Lo(VioCurLoc) < XVio) Then
      begin
        XVio := Lo(VioCurLoc);
        VioBuffer^[YVio, XVio].Ch := Lo(AX);
      end
      else
      begin
        VioBuffer^[YVio, XVio].Ch := Lo(AX);
        Inc(XVio);
      end;
    end
    else
    begin
      VioBuffer^[YVio, XVio].Ch := Lo(AX);
      Inc(XVio);
    end;
    VioCurLoc := YVio Shl 8 + XVio;
  end;
  VioBuffer^[YVio, XVio].Attr := VioBuffer^[YVio, XVio].Attr Or 112;
end;
{$F-}

{$F+}
Procedure RestoreInt29;
begin
  ExitProc := OldExit;
  SetIntVec($29, OldInt29);
  if TrapWriteVar Then
  begin
    TextRec(OutPut).InOutFunc := @OldIOFunc;
    TextRec(OutPut).FlushFunc := @OldFlushFunc;
  end;
end;
{$F-}

Procedure HookInt29;
begin
  GetIntVec($29, OldInt29);
  SetIntVec($29, @NewInt29);
  OldExit := ExitProc;
  ExitProc := @RestoreInt29;
end;

Procedure InitView(XX1, XY1, XX2, XY2: Byte);
Var
  I    : Byte;
begin
  X1 := XX1+1;
  Y1 := XY1+1;
  X2 := XX2-1;
  Y2 := XY2-1;
  XVio := X1;
  YVio := Y1;
  For I := XX1 To XX2 Do
  begin
    VioBuffer^[XY1, I].Ch := 205;
    VioBuffer^[XY2, I].Ch := 205;
  end;
  For I := XY1+1 To XY2-1 Do
  begin
    VioBuffer^[I, XX1].Ch := 179;
    VioBuffer^[I, XX2].Ch := 179;
  end;
  VioBuffer^[XY1, XX1].Ch := 213;
  VioBuffer^[XY2, XX1].Ch := 212;
  VioBuffer^[XY1, XX2].Ch := 184;
  VioBuffer^[XY2, XX2].Ch := 190;
  VioCurLoc := YVio Shl 8 + XVio;
end;

Procedure DoWriteStuff(F : TextRec);
Var
  I    : Integer;
  Regs : Registers;
begin
  For I := 0 To F.BufPos-1 Do
  begin
    Regs.AL := Byte(F.BufPtr^[I]);
    Intr($29, Regs);
  end;
end;

{$F+}
Function NewOutputFunc(Var F : TextRec) : Integer;
begin
  DoWriteStuff(F);
  F.BufPos := 0;
  NewOutPutFunc := 0;
end;
{$F-}

{$F+}
Function NewFlushFunc(Var F : TextRec) : Integer;
begin
  DoWriteStuff(F);
  F.BufPos := 0;
  NewFlushFunc := 0;
end;
{$F-}

Procedure TrapWrite;
begin
  if Not TrapWriteVar Then
  begin
    With TextRec(OutPut) Do
    begin
      OldIOFunc := DrvFunc(InOutFunc);
      InOutFunc := @NewOutPutFunc;
      OldFlushFunc := DrvFUnc(FlushFunc);
      FlushFunc := @NewFlushFunc;
    end;
    TrapWriteVar := True;
  end;
end;

Procedure UnTrapWrite;
begin
  if TrapWriteVar Then
  begin
    TextRec(OutPut).InOutFunc := @OldIOFunc;
    TextRec(OutPut).FlushFunc := @OldFlushFunc;
    TrapWriteVar := False;
  end;
end;

Procedure ClearView;
begin
  Asm
    Mov   AH, 06
    Mov   AL, 0
    Mov   CH, Y1
    Mov   CL, X1
    Mov   DH, Y2
    Mov   DL, X2
    Mov   BH, 07
    Int   10h
  end;
  XVio := X1;
  YVio := Y1;
  VioCurLoc := YVio Shl 8 + XVio;
end;

Procedure CheckMode;
Var
  MyRegs : Registers;
begin
  MyRegs.AH := $F;
  Intr($10, MyRegs);
  Case MyRegs.AL Of
    0, 1, 2, 3  : VioBuffer := Ptr($B800, $0000);
    7           : VioBuffer := Ptr($B000, $0000);
  end;
end;

begin
  X1 := 0;
  Y1 := 0;
  X2 := 79;
  Y2 := 24;
  XVio := 0;
  YVio := 0;
  VioCurLoc := YVio Shl 8 + XVio;
  HookInt29;
  TrapWriteVar := False;
  CheckMode;
end.


Program Int29Testing;

{$A+,B-,D+,E+,F-,G-,I+,L+,N-,O-,P-,Q-,R-,S+,T-,V+,X+}
{$M $800,0,0}

Uses
  Dos, Crt,
  I29UnitA;

Var
  CmdLine      : String;
  I            : Byte;

{ Function to convert a String to upper case.
  Return the upper-case String. }

Function Str2Upr(Str : String) : String; Assembler;
Asm
  Push DS
  CLD
  LDS  SI, Str
  LES  DI, @Result
  LodSB
  Or   AL, AL
  Jz   @Done
  StoSB
  Xor  CH, CH
  Mov  CL, AL
 @@1:
  LodSB
  Cmp  AL, 'a'
  JB   @@2
  Cmp  AL, 'z'
  JA   @@2
  Sub  AL, 20h
 @@2:
  StoSB
  Loop @@1
 @Done:
  Pop  DS
end;

begin
  ClrScr;
  GotoXY(1,1);
  WriteLn('Output interceptor.');
  { Initialize redirector's area. }
  InitView(0,2,79,24);
  Repeat
          { Redirect Turbo's output into the predefined Window. }
    TrapWrite;
    Write(#0,' Please enter Dos command (Done to Exit): ');
    ReadLn(CmdLine);
    WriteLn;
    { Restore Turbo's original Output routine. }
    UnTrapWrite;
    GotoXY(1,2);
    WriteLn('Command executed : ', CmdLine);
    CmdLine := Str2Upr(CmdLine);
    if (CmdLine <> 'DONE') And (CmdLine <> '') Then
    begin
      SwapVectors;
      Exec('C:\Command.Com', '/C'+CmdLine);
      SwapVectors;
    end;
    GotoXY(1,2);
    WriteLn('Command execution done. Press anykey to continue...');
    Repeat Until ReadKey <> #0;
    ClearView;
    GotoXY(1,2);
    WriteLn('                                                   ');
  Until (CmdLine = 'DONE');
  ClrScr;
end.

{
Both the testing Program and the Unit itself (expecially the Unit), is by no
mean perfect. Use With caution. It might not wise to use such redirector
(my int 29 Unit) in a Program that swaps itself out of memory. The above
Programs were not optimized in anyway (so it might slow your Program a
little). And I don't guarantee that this Program will work on your computer
(it work Without a problem on mine). if you like this Unit, you can use it
anyway you desire. Just remember I can guarantee nothing For this method.
}

