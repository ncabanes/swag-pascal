(*
  Category: SWAG Title: TEXT FILE MANAGEMENT ROUTINES
  Original name: 0054.PAS
  Description: Display a Text File with Scrollback
  Author: ROB VAN GEEL
  Date: 05-26-95  23:28
*)

{
> I am writing a small replacement for the DOS command TYPE and one
> of the things I would like to add is a scroll back buffer...
> Q: How do I intercept the lines that are scrolling off page?
> Is there a interupt that I may hook in to or ...

Doesn't have a filesize check. Parts of it could be improved.

From: R.A.M.vGeel@kub.nl  (GEEL R.A.M.VAN)
}

program show;
 
uses dos, crt;
 
const
  NoMSG = 0;
  msgNoPar = 1;
  msgNoFile = 2;
  msgNoDrive = 152;
  msgNoClose = 10;
  msgWrongKey = 100;
 
type
  FileNameString = string[80];
 
  PNewLine = ^NewLine;
  NewLine = Record
              Line : string[79];
              Next, Prev : PNewLine;
            end;
 
  TFiler = object
             FileName : string[80];
             InFile : text;
             MSGStatus : byte;
 
             constructor Init;
             procedure DoMsg(MsgNr : byte); virtual;
             function GetFileName : FileNameString; virtual;
             function OpenIt : byte; virtual;
             function CloseIt : byte; virtual;
             destructor Done; virtual;
           end;
 
  TShower = object(TFiler)
              Screen : array[1..2000] of word;
              Xcor, Ycor : byte;
              CurSize : word;
              Text : PNewLine;
              ScrolFac : integer;
              Tmp : PNewLine;
 
              constructor Init;
              procedure DoMsg(MsgNr : byte); virtual;
              procedure Cursor; virtual;
              procedure NoCursor; virtual;
              procedure SaveScreen; virtual;
              procedure RestoreScreen; virtual;
              procedure ReadIn; virtual;
              procedure ShowText; virtual;
              function UpdatePointer: boolean; virtual;
              procedure Go; virtual;
              destructor Done; virtual;
            end;
 
var
  AShower : TShower;
 
constructor TFiler.Init;
begin
  FileName := GetFileName;
    if MSGStatus <> NoMsg then DoMsg(MSGStatus);
  MSGSTatus := OpenIt;
    if MSGStatus <> NoMSG then DoMSG(MSGStatus);
end;
 
procedure TFiler.DoMsg(MSGNr : byte);
begin
  case MSGNr of
    msgNoPar :
      begin
        writeln('* * SHOW (c) 1994 Robert van Geel * *');
        writeln;
        writeln('Usage: SHOW <filename>');
        halt(1);
      end;
    msgNoFile :
      begin
        writeln('File not found');
        halt(1);
      end;
    msgNoClose :
       begin
         writeln('Could not close file');
         MSGStatus := NoMsg;
       end;
    msgNoDrive :
       begin
         writeln('Drive not ready');
         halt(1);
       end;
  end;
end;
 
function TFiler.GetFileName : FileNameString;
begin
  If ParamCount > 0 then
    GetFileName := ParamStr(1)
  else MsgStatus := MSGNoPar;
end;
 
function TFiler.OpenIt : byte;
var
  nr : byte;
begin
  {$I-}
    assign(InFile, FileName);
    reset(InFile);
    nr := IOResult;
    OpenIt := nr;
  {$I+}
end;
 
function TFiler.CloseIt : byte;
begin
{$I-}
  close(InFile);
  CloseIt := IOResult;
{$I+}
end;
 
destructor TFiler.Done;
begin
  MsgStatus := CloseIt;
  if MSGStatus <> NoMSG
    then DoMsg(MSGStatus);
end;
 
{ ********************************************************************** }
 
constructor TShower.Init;
begin
  inherited init;
  SaveScreen;
  ReadIn;
  NoCursor;
  SaveScreen;
{  textcolor(yellow);
  textbackground(blue);
}  clrscr;
end;
 
procedure TShower.DoMsg(MSGNr : byte);
begin
  inherited DoMsg(MsgNr);
  case MSGNr of
      msgWrongKey :
        begin
          gotoxy(1, 24);
          writeln('KEY HAS NO FUNCTION HERE');
          MsgNr := NoMsg;
        end;
    end;
end;
 
procedure TShower.NoCursor;
var s : word;
begin
 asm
    mov ah,03h
    mov bh,0
    int 10h
    mov s,cx
 
    mov ah,01h
    mov bh,0
    mov cx,2000h
    int 10h 
  end;
  cursize := s;
end;
 
procedure TShower.Cursor;
var s:word;
begin
s:=CurSize;
  asm
    mov ah,01h
    mov bh,0
    mov cx,s
    int 10h
  end;
end;
 
procedure TShower.SaveScreen;
begin
  move(memw[$B800:$0], Screen, 4000);
  XCor := wherex;
  YCor := wherey;
end;
 
procedure TShower.RestoreScreen;
begin
  move(Screen, memw[$B800:$0], 4000);
  gotoxy(XCor, YCor);
end;
 
function TShower.UpdatePointer: boolean;
var
  k : integer;
  changed : boolean;
begin
  changed := false;
  while (ScrolFac > 0) and (Text^.Next <> nil) do
    begin
      changed := true;
      Text := Text^.Next;
      dec(ScrolFac);
    end;
  while (ScrolFac < 0) and (Text^.Prev <> nil) do
    begin
      changed := true;
      Text := Text^.Prev;
      inc(ScrolFac);
    end;
  Tmp := Text;
  UpdatePointer := changed;
end;
 
procedure TShower.ShowText;
var
  LinesWritten : integer;
  OneMore : boolean;
begin
  LinesWritten := 0;
  OneMore := true;
  gotoxy(1,1);
  while OneMore and (LinesWritten < 25) do
    begin
      write(tmp^.Line);
      clreol;
      inc(LinesWritten);
      if LinesWritten < 25 then
        begin
          writeln;
          clreol;
        end;
      if tmp^.next <> nil then tmp := tmp^.Next
        else OneMore := false;
    end;
  while LinesWritten < 24 do
    begin
      writeln;
      clreol;
      inc(LinesWritten);
    end;
end;
 
procedure TShower.Go;
var
  Ch : char;
begin
  tmp := Text;
  ShowText;
  while Ch <> #01 do
  begin
    Ch := ReadKey;
    case ch of
      #0  : ;
      #72 : ScrolFac := -1;   {omhoog}
      #80 : ScrolFac := 1;    {omlaag}
      #73 : ScrolFac := -25;  {page up}
      #81 : ScrolFac := 25;   {page down}
      else Ch := #01;
    end;
    if ScrolFac <> 0 then
      begin
        if UpdatePointer then ShowText;
      end;
  end;
end;
 
procedure TShower.ReadIn;
var
  cur : PNewLine;
begin
  new(Text);
  with Text^ do
    begin
      readln(InFile, Line);
      Next := nil;
      Prev := nil;
    end;
  cur := Text;
  while not EOF(InFile) do
    begin
      new(tmp);
      with tmp^ do
        begin
          readln(InFile, tmp^.line);
          tmp^.prev := cur;
          cur^.next := tmp;
          tmp^.next := nil;
        end;
      cur := tmp;
      tmp := nil;
    end;
  cur := nil;
  tmp := nil;
end;
 
destructor TShower.Done;
begin
  inherited Done;
  while text^.next <> nil do
    begin
      text := text^.next;
      dispose(text^.prev);
      text^.prev := nil;
    end;
  dispose(text);
  text := nil;
  Cursor;
  RestoreScreen;
end;
 
begin
  AShower.Init;
  AShower.Go;
  AShower.Done;
end.


