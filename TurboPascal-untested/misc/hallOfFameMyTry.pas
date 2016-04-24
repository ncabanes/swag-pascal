(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0094.PAS
  Description: hall of fame - my try
  Author: RODNEY JOHNSON
  Date: 05-25-94  08:15
*)


Unit HighScr;
Interface
Procedure HS_Init(iNum: byte; ifn: string; icode: byte);
{Initializes the highscore manager}
{  iNum: byte -  The number of scores to keep track of.  Setting iNum to 0}
{                makes the program use however many scores it finds in the}
{                list file}
{  ifn: string - The filename of the list file.  If the file exists, it is
                 opened; otherwise, a new file is created.  If iNum if set to
                 more names than are in ifn, extra spaces are left blank.  If
                 ifn has too many, the extras are ignored.
                 NOTE:  do not make inum=0 if you are creating a new list
                 file}
{  icode: byte - encoding number, where 0=no encoding.  The higher the
                 number, the less recognizable the output file}

Function HS_CheckScore(score: longint): boolean;
{Checks to see if a score would make the highscore list}
{  score: longint - the score to check}
{Returns TRUE if the score made the list}

Function HS_NewScore(name: string; score: longint): boolean;
{Adds a new score to the list if it belongs}
{  name: string -   the name of the player}
{  score: longint - the player's score}
{Returns TRUE if the score made the list}

Procedure HS_Clear;
{Clears the highscore list, setting all names to dashes, all scores to 0}

Function HS_Name(i: byte): string;
{Returns the name from the Ith place of the list}
{  i: byte - the rank to check}

Function HS_Score(i: byte): longint;
{Returns the score from the Ith place of the list}
{  i: byte - the rank to check}

Procedure HS_Done;
{Disposes of the highscore manager and saves the highscore list}

Implementation
Uses
  Dos;
Type
  PHSItem = ^THSItem;
  THSItem = record
              name:                     string[25];
              score:                    longint;
            end;
  PHSItemList = ^THSItemList;
  THSItemList = array[1..100] of THSItem;
Var
  numitems, code:                       byte;
  item:                                 PHSItemList;
  fn:                                   string[50];
Procedure FlipBit(var Buf; len, code: byte);
Type
  TBuf = array[0..255] of byte;
var
  i:                                    byte;
begin
  for i:=0 to len-1 do
    TBuf(Buf)[i]:=TBuf(Buf)[i] XOR Code;
end;
Function GetStr(var f: file): string;
var
  s:                                    string;
begin
  BlockRead(f, s[0], 1);
  BlockRead(f, s[1], ord(s[0]));
  GetStr:=s;
end;
Function Exist(fn: string): boolean;
Var
  SRec:                                 SearchRec;
Begin
  FindFirst(fn, $3F, SRec);
  If DosError>0 then Exist:=False else Exist:=True;
End;
Procedure HS_Init(iNum: byte; ifn: string; icode: byte);
var
  f:                                    file;
  i, found:                             byte;
begin
  fn:=ifn;
  code:=icode;
  numitems:=iNum;
  GetMem(item, 30*numitems);
  HS_Clear;
  if exist(fn) then
  begin
    Assign(f, fn);
    Reset(f, 1);
    BlockRead(f, found, 1);
    if numitems=0 then numitems:=found;
    if found>numitems then found:=numitems;
    for i:=1 to found do
    begin
      item^[i].name:=GetStr(f);
      FlipBit(item^[i].name[1], ord(item^[i].name[0]), code);
      BlockRead(f, item^[i].score, 4);
      FlipBit(item^[i].score, 4, code);
    end;
  end;
  if numitems=0 then numitems:=1;
end;
Function HS_CheckScore(score: longint): boolean;
begin
  if score>item^[numitems].score then HS_CheckScore:=TRUE else HS_CheckScore:=FALSE;
end;
Function HS_NewScore(name: string; score: longint): boolean;
var
  i, j:                                 byte;
  on:                                   boolean;
begin
  HS_NewScore:=FALSE;
  for i:=1 to numitems do
    if score>item^[i].score then
    begin
      for j:=numitems downto i+1 do
        item^[j]:=item^[j-1];
      item^[i].name:=name;
      item^[i].score:=score;
      score:=0;
      i:=numitems;
      HS_NewScore:=TRUE;
    end;
end;
Procedure HS_Clear;
var
  i:                                    byte;
begin
  for i:=1 to numitems do
  begin
    item^[i].name:='-------------------------';
    item^[i].score:=0;
  end;
end;
Function HS_Name(i: byte): string;
begin
  HS_Name:=item^[i].name;
end;
Function HS_Score(i: byte): longint;
begin
  HS_Score:=item^[i].score;
end;
Procedure HS_Done;
var
  f:                                    file;
  i:                                    byte;
begin
  Assign(f, fn);
  Rewrite(f, 1);
  BlockWrite(f, numitems, 1);
  for i:=1 to numitems do
  begin
    FlipBit(item^[i].name[1], ord(item^[i].name[0]), code);
    BlockWrite(f, item^[i].name, ord(item^[i].name[0])+1);
    FlipBit(item^[i].score, 4, code);
    BlockWrite(f, item^[i].score, 4);
  end;
  FreeMem(item, 30*numitems);
end;
End.

