{
> Basically all I'm asking For are SaveScreen and RestoreScreen Procedures.
> Procedures capable of just partial screen saves and restores would be
> even better, but anything will do!  :-)
}

Unit ScrUnit;

Interface

Const
  MaxPages  = 20;
Type
  PageType  = Array [1..50,1..80] Of Word;
  PageArray = Array [1..MaxPages] Of ^PageType;
Var
  Screen    : ^PageType;
  ScrPages  : PageArray;
  PageInMem : Array [1..MaxPages] Of Boolean;
  VideoMode : ^Byte;
  UseDisk   : Boolean;

Procedure InitPages(Pages : Byte);
Procedure DeInitPages;
Procedure StoreScreen(Page : Byte);
Procedure RestoreScreen(Page : Byte);

Implementation
{$IFNDEF VER70}
Const Seg0040      = $0040;
      SegB000      = $B000;
      SegB800      = $B800;
{$endIF}

Var
  MPages       : Byte;
  SaveExitProc : Pointer;

Function FStr(Num : LongInt) : String;
Var Dummy : String;
begin
  Str(Num,Dummy);
  FStr := Dummy;
end;

Procedure InitPages;
Var
  Loop : Byte;
begin
  If Pages>MaxPages Then
    Pages := MaxPages;
  For Loop:=1 To Pages Do
  If (MaxAvail>=SizeOf(PageType)) And (Not UseDisk) Then
  begin
    PageInMem[Loop] := True;
    GetMem(ScrPages[Loop],SizeOf(PageType));
  end
  Else
  begin
    PageInMem[Loop] := False;
    ScrPages[Loop]  := NIL;
  end;
  MPages := Pages;
end;

Procedure DeInitPages;
Var Loop : Byte;
begin
  If MPages>0 Then
    For Loop:=MPages DownTo 1 Do
      If PageInMem[Loop] Then
      begin
        Release(ScrPages[Loop]);
        PageInMem[Loop] := False;
      end;
  MPages := 0;
end;

Procedure StoreScreen;
Var
  F : File Of PageType;
begin
  If Page<=MPages Then
  begin
    If PageInMem[Page] Then
      Move(Screen^,ScrPages[Page]^,SizeOf(PageType))
    Else
    begin
      Assign(F,'SCR'+FStr(Page)+'.$$$');
      ReWrite(F);
      If IOResult=0 Then
      begin
        Write(F,Screen^);
        Close(F);
      end;
    end;
  end;
end;

Procedure RestoreScreen;
Var
  F : File Of PageType;
begin
  If Page<=MPages Then
  begin
    If PageInMem[Page] Then
      Move(ScrPages[Page]^,Screen^,SizeOf(PageType))
    Else
    begin
      Assign(F,'SCR'+FStr(Page)+'.$$$');
      Reset(F);
      If IOResult=0 Then
      begin
        Read(F,Screen^);
        Close(F);
      end;
    end;
  end;
end;

{$F+}
Procedure ScreenExitProc;
Var
  Loop : Byte;
  F    : File;
begin
  ExitProc := SaveExitProc;
  If MPages>0 Then
    For Loop:=1 To MPages Do
    begin
      Assign(F,'SCR'+FStr(Loop)+'.$$$');
      Erase(F);
      If IOResult<>0 Then;
    end;
end;
{$F-}

begin
  VideoMode := Ptr(Seg0040,$0049);
  If VideoMode^=7 Then
    Screen := Ptr(SegB000,$0000)
  Else
    Screen := Ptr(SegB800,$0000);
  MPages := 0;
  UseDisk := False;
  SaveExitProc := ExitProc;
  ExitProc := @ScreenExitProc;
end.

(*
This simple Unit is able to store up to 20 screens. If there is enough free
heap all screens are stored to heap which is Really fast. If there is not
enough free heap or UseDisk=True all screens are stored virtually to disk. This
method isn't very fast, of course, but it helps you to save heap.

Use this Unit as follows:

Program ThisIsMyProgram;
Uses Screen;
begin
  InitPages(5);        { initialize 5 pages }
  {...}                { this is on you }
end.
*)
