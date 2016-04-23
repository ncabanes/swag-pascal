{$M 4000, 0, 0}
program Directory_Of_Executables;
uses DOS, CRT;

var DirInfo : SearchRec;
    Files : Array[0..255] of String[40];
    Size, Date, Time : String[10];
    StrVar, SV : String;
    Index, last : Integer;
    TotalSize : LongInt;
    done : boolean;
    Dir : DirStr;
    Path : String;

function LeadingZero(w : Word) : String;
var
  s : String;
begin
  Str(w:0,s);
  if Length(s) = 1 then
    s := '0' + s;
  LeadingZero := s;
end;
function Commas (S : String) : String;
var Num, Cnt, e : Integer;
begin
  Val(S, Num, e);
  If (e <> 0) or (Length(S) <= 3) then exit;
  Cnt := Length(S);
  For e := Cnt downto 3 do
    If (e / 3) = (e div 3) then Insert(',', S, e);
  COmmas := S;
end;

function RightJustify(S : String; N : Integer) : String;
var cnt : Integer;
begin
  While Length(S) < N do S := ' ' + S;
  RightJustify := S;
end;

function ExpandFName (s: String) : String;
begin
     while Pos('.', s) < 9 do insert(' ', s, Pos('.', s));
     s[9] := ' ';
     ExpandFName := s;
end;

begin
     If ParamCount > 1 then Path := ParamStr(1) else Path := '';
     last := 0; totalsize := 0; index := 1;
     FindFirst(Path + '*.EXE', Archive, DirInfo);
     While DosError = 0 do
       begin
            Str(DirInfo.Size, Size); {Size := Commas(Size);}
            Files[Index] := ExpandFName(DirInfo.Name);
            While Length(Files[Index]) < 22
                  do Files[Index] := Files[Index] + ' ';
            Files[Index] := Files[Index] + RightJustify(Size, 8) + '  ';
            Files[Index] := Files[Index] + Date + '  ' + Time;
            inc(Index);
            Totalsize := TotalSize + DirInfo.Size;
            Inc(last);
            FindNext(DirInfo);
       end;
     FindFirst(Path + '*.BAT', Archive, DirInfo);
     While DosError = 0 do
       begin
            Str(DirInfo.Size, Size);
            Files[Index] := ExpandFName(DirInfo.Name);
            While Length(Files[Index]) < 22
                  do Files[Index] := Files[Index] + ' ';
            Files[Index] := Files[Index] +RightJustify(Size, 8) + '  ';
            Files[Index] := Files[Index] + Date + '  ' + Time;
            inc(Index);
            Totalsize := TotalSize + DirInfo.Size;
            Inc(last);
            FindNext(DirInfo);
       end;
     FindFirst(Path + '*.COM', Archive, DirInfo);
     While DosError = 0 do
       begin
            Str(DirInfo.Size, Size);
            Files[Index] := ExpandFName(DirInfo.Name);
            While Length(Files[Index]) < 22
                  do Files[Index] := Files[Index] + ' ';
            Files[Index] := Files[Index] + RightJustify(Size, 8) + '  ';
            Files[Index] := Files[Index] + Date + '  ' + Time;
            inc(Index);
            Totalsize := TotalSize + DirInfo.Size;
            Inc(last);
            FindNext(DirInfo);
       end;
     repeat
       done := True;
       For Index := 1 to last - 1 do
         if files[index] > files[index + 1] then
           begin
                files[0] := files[index]; files[index] := files[index + 1];
                files[index + 1] := files[0]; Done := False;
           end;
     until done;
     writeln;
     for index := 1 to last do
       begin
         writeln(files[index]);
         if (index / 23) = Trunc(index /  23) then
            begin
                 WriteLn('Press any key to continue...');
                 if readkey = #0 then readkey;
            end;
       end;
     writeln;
     WriteLn('Directory of Executables ', Path);
     Str(last, StrVar);
     While Length(StrVar) < 9 do StrVar := ' ' + StrVar;
     StrVar := StrVar + ' file(s)  ';
     Str(TotalSize, SV);
     StrVar := StrVar + SV;
     While Length(StrVar) < 32 do Insert(' ', StrVar, 19);
     StrVar := StrVar + ' used';
     WriteLn(StrVar);
     Str(DiskFree(0), StrVar);
     While Length(StrVar) < 32 do StrVar := ' ' + StrVar;
     WriteLn(StrVar, ' bytes free');
     Str(DiskSize(0), StrVar);
     While Length(StrVar) < 32 do StrVar := ' ' + StrVar;
     WriteLn(StrVar, ' bytes capacity');
end.