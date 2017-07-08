(*
  Category: SWAG Title: DIRECTORY HANDLING ROUTINES
  Original name: 0010.PAS
  Description: Directory Viewer
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:37
*)

{
Well, here goes...a directory viewer, sorry it has no box but the
command that i used to create the box was from a Unit. Weel, the Program
is very "raw" but i think it's enough to give you an idea...
}

Program ListBox;

Uses
  Crt, Dos;

Const
  S = '           ';

Var
  List         : Array[1..150] of String[12];
  AttrList     : Array[1..150] of String[15];
  Pos, First   : Integer;
  C            : Char;
  Cont         : Integer;
  DirInfo      : SearchRec;
  NumFiles     : Integer;

begin
  TextBackground(Black);
  TextColor(LightGray);
  ClrScr;

  For Cont := 1 to 15 do
  begin
    List[Cont] := '';
    AttrList[Cont] := '';
  end;

  NumFiles := 0;
  FindFirst('C:\*.*', AnyFile, DirInfo);

  While DosError = 0 do
  begin
    Inc(NumFiles, 1);
    List[NumFiles] := Concat(DirInfo.Name,
                      Copy(S, 1, 12 - Length(DirInfo.Name)));
    If (DirInfo.Attr = $10) Then
      AttrList[NumFiles] := '<DIR>'
    Else
      Str(DirInfo.Size, AttrList[NumFiles]);
    AttrList[NumFiles] := Concat(AttrList[NumFiles],
                          Copy(S, 1, 9 - Length(AttrList[NumFiles])));
    FindNext(DirInfo);
  end;

  First := 1;
  Pos   := 1;

  Repeat
    For Cont := First To First + 15 do
    begin
      If (Cont - First + 1 = Pos) Then
      begin
        TextBackground(Blue);
        TextColor(Yellow);
      end
      Else
      begin
        TextBackGround(Black);
        TextColor(LightGray);
      end;
      GotoXY(30, Cont - First + 3);
      Write(' ', List[Cont], '  ', AttrList[Cont]);
    end;
    C := ReadKey;
    If (C = #72) Then
      If (Pos > 1) Then
        Dec(Pos, 1)
      Else
      If (First > 1) Then
        Dec(First,1);

    If (C = #80) Then
      If (Pos < 15) Then
        Inc(Pos, 1)
      Else
      If (First + 15 < NumFiles) Then
        Inc(First,1);
  Until (Ord(c) = 13);
end.
