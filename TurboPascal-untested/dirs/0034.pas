Program GIFDIR(Input, Output);

Uses Dos, Crt;

Const
  ProSoft = ' Gif DIRectory - Version 2.0 (C) ProSoft '+Chr(254)+' Phil R. Overman 02-02-92';
  gifliteheader                       = chr($21)+chr($FF)+chr(11)+'GIFLITE';
  giflitesearch                       = 100;
  ScreenLines                         = 23;
  Maxlinelength                       = 80;
  test0                               = false;
  test1                               = true;
(*
    {$I-}
*)
Type
  String12                            = String[12];
  LineType                            = Packed Array[1..Maxlinelength] of char;
  LengthType                          = 0..Maxlinelength;
  String2                             = String[2];
  String3                             = String[3];
  String8                             = Packed Array[1..8] of char;
{ String12                            = Packed Array[1..12] of char; }
  String15                            = String[15];

Var
  dodate, dotime, domegs, doextension : boolean;
  doversion, dopalette, doGCT         : boolean;
  dofiledot, doall, dogiflite         : boolean;
  CmtFound, Pause, ShowZips, isgif    : Boolean;
  CmtSize, FileCount, LinesWritten    : Word;
  attr, height, width, colors         : Word;
  fileattr                            : word;
  TotalSize, position                 : Longint;
  filesize, filedate                  : longint;
  icount, jcount                      : integer;
  count, clen                         : Byte;
  megs                                : real;
  DirInfo, gifdirinfo                 : Searchrec;
  Path, Gifpath, filein               : PathStr;
  Dir                                 : DirStr;
  Name, infdatestring, gifname        : NameStr;
  Ext                                 : ExtStr;
  A, B, C, cc, ch, eoname             : Char;
  Abyte                               : Byte;
  cs                                  : String[1];
  meg                                 : String2;
  gversion, gheader                   : String3;
  filename                            : String[12];
  infile, outfile                     : text;
  giffile                             : file;
  infdt, filedt                       : datetime;
  giffilein                           : String15;
  Drive                               : String2;
  GCTF                   {1 Bit}      : boolean;
  ColorResolution        {3 Bits}     : byte;
  SortFlag               {1 Bit}      : boolean;
  SizeOfGCT              {3 Bits}     : byte;
  giflite                             : boolean;
  BackgroundColorIndex                : Byte;
  PixelAspectRatio                    : Byte;
  SizeofPalette                       : Longint;
{ Cmt                                 : CmtType; }
(***************************************************************)
Procedure BadParms;
begin
  writeln(' Program syntax: GDIR [d:\Path][Filename[.GIF]] [/p/a/d/t/m/f/v/g/r/?|h]');
{  writeln; }
  writeln(' Displays standard DOS DIR of GIF files, but with height, width, and colors');
{  writeln; }
  writeln(' Output looks like this (with no parameters):');
{  writeln; }
  writeln(' GIFNAME  GIF   178152   5-11-91  640h 400w 256c');
  writeln;
  { writeln('Enter *.* to display all files (normal Dir).'); }
  writeln(' Parameters:');
  writeln(' /P Pauses the display, just as in the DOS Dir command.');
  writeln(' /A Displays complete information, except time.');
  writeln(' /D turns display of the file Date off.');
  writeln(' /T turns display of the file Time on.');
  writeln(' /M shows size in Megabytes instead of bytes.');
  writeln(' /F displays GIFNAME.GIF instead of GIFNAME  GIF');
  writeln(' /E suppress display of the extension.');
  writeln(' /G Check if file optimized by GIFLITE and display it if so.');
  writeln(' /V displays the Version of the GIF file - GIF87a, GIF89a, etc.');
  writeln(' /C displays "GCM" if the file has a Global Color Map');
  writeln(' /R Resolution - displays the total number of colors in the pallette');
  writeln(' /H or /? displays this Help screen.');
  if Doserror >  0 then writeln;
  If Doserror = 18 then Writeln(' File not found');
  If Doserror =  3 then writeln(' Path not found');
  if Doserror >  0 then writeln;
  halt(98);
end;
(************************************************)
Procedure FlipB(Var f : boolean);
Begin
  If f then f := false else f := true;
End;
(************************************************)
Procedure ProcessParms(s : string);
var sr : searchrec;
Begin
  If (pos('/',s) = 1) Then
    Begin
      If (Copy(s,2,1) = 'P') or (Copy(s,2,1) = 'p') then Pause := true;
      If (Copy(s,2,1) = 'D') or (Copy(s,2,1) = 'd') then Flipb(dodate);
      If (Copy(s,2,1) = 'T') or (Copy(s,2,1) = 't') then Flipb(dotime);
      If (Copy(s,2,1) = 'M') or (Copy(s,2,1) = 'm') then Flipb(domegs);
      If (Copy(s,2,1) = 'F') or (Copy(s,2,1) = 'f') then Flipb(dofiledot);
      If (Copy(s,2,1) = 'V') or (Copy(s,2,1) = 'v') then Flipb(doversion);
      If (Copy(s,2,1) = 'R') or (Copy(s,2,1) = 'r') then Flipb(dopalette);
      If (Copy(s,2,1) = 'G') or (Copy(s,2,1) = 'g') then Flipb(dogiflite);
      If (Copy(s,2,1) = 'C') or (Copy(s,2,1) = 'c') then Flipb(doGCT);
      If (Copy(s,2,1) = 'E') or (Copy(s,2,1) = 'e') then Flipb(doextension);
      If (Copy(s,2,1) = 'A') or (Copy(s,2,1) = 'a') then
        Begin
          Flipb(doall);
          dodate := true; dotime := false; dofiledot := false;
          domegs := false; doversion := true; dopalette := false;
          doGCT := true; doextension := true; dogiflite := true;
        End;
      If (Copy(s,2,1) = 'H') or (Copy(s,2,1) = 'h') or (Copy(s,2,1) = '?') then Badparms;
    End
  Else
    Begin
      Path := FExpand(s);
{      If Copy(Path,Length(Path),1) = '\' then Path := Path + '*.GIF'; }
{      If Pos('.',path) = 0 then path := path + '.GIF'; }
{      If Pos('*',Path) + Pos('?',path) + Pos('.GIF',path) = 0
        then
          begin
            FindFirst(Path,$10,sr);
            If Doserror = 0 then Path := Path + '\*.gif';
          end; }
    End;
End;
(*******************)
Function Exponential(A:integer; B:byte):longint;
Var yyy : longint;
(* Returns A to the Bth *)
Begin
  yyy := A;
  For count := 2 to B Do yyy := yyy * A;
  If b=0 then Exponential := 1 else Exponential := yyy;
End;
(**********************************)
Function BV(A:byte; b:byte):byte; {BitValue}
var aa : byte;
(* A is the byte value - b is the bit # for which the value is desired 1-8 *)
Begin
  aa := a;
  While aa >= Exponential(2,b) do dec(aa,Exponential(2,b));
  If aa < Exponential(2,b-1) then BV := 0 else BV := 1;
End;
(***********************)
Procedure ClearName;
Begin
  For count := 1 to 12 do DirInfo.name[count] := ' ';
End;
(**************************)
Procedure ClearABC;
Begin
  A := ' '; B := ' '; C := ' ';
End;
(*******************)
{
Procedure ClearCmt;
Begin
  CmtFound := False;
  for count := 1 to MaxCmtSize do Cmt[count] := ' ';
End;
}
(*******************)
Procedure WriteName(n : String12);
Var p, q, qq, r : byte;
Begin
  p := 0;  q := 0;  r := 0;
  If doextension then qq :=12 else qq := 8;
  While r < length(n) DO
    Begin
      inc(p);
      inc(r);
      if (n[p] = '.') and not dofiledot
        then
          Begin
              If p < 9 then write(' ':9-p);
              inc(q, 9-p);
              If doextension then
                Begin
                  write(' ');
                  inc(q);
                End;
          End
        else
            begin
              If (p<9) or doextension then
                begin
                  write(n[p]);
                  inc(q);
                end;
            end;
    End;
  If q < qq then write(' ':qq-q);
End;
(********************************)
Procedure WriteDate(i : longint);
Var d : datetime;
Begin
  Unpacktime(i,d);
  If d.month > 9 then Write(d.month,'-') else Write('0',d.month,'-');
  If d.day > 9 then Write(d.day) else Write('0',d.day);
  Write('-',d.year mod 100);
  Write(' ');
End;
(********************************)
Procedure WriteTime(i : longint);
Var d : datetime;
Begin
  Unpacktime(i,d);
  Write(' ');
  if d.hour = 0 then Write('12') else if d.hour mod 12 > 9 then Write(d.hour mod 12) else write(' ',d.hour mod 12);
  if d.min = 0 then Write(':00') else if d.min > 9 then write(':',d.min) else Write(':0',d.min);
  If d.hour > 11 then Write('p ') else Write('a ');
End;
(*****************************************************)
Procedure Writeline(s : Searchrec);
Var xx : byte; ss: string[1];
Begin
  Writename(s.name);
  If domegs or doextension then
    Begin
      xx := (s.size+5120) div 10240;
      If xx < 10
        then
          begin
            Str(xx:1, ss);
            meg := '0' + ss
          end
        else
          Str(xx:2, meg)
    End;
  If domegs    then Write('  .',meg,' ') else Write(s.size:10);
                    Write(' ');
  If dodate    then Writedate(s.time);
  If dotime    then WriteTime(s.time);
  If isgif     then
    Begin
      Write(height:4,'h',width:4,'w',colors:4,'c ');
      If dopalette then Write(sizeofpalette,'R ');
      If doversion then Write (' ',gversion,' ');
      If doGCT then begin if GCTF then Write(' GCM ') else write('     ') end;
      If doGIFLITE then begin if GIFLITE then Write(' GL ') else write(' ng ') end;
    End;
  Writeln;
End;
(****************************************************)
Procedure ProcessGifFile;
Var result : word;
BEGIN
  Assign(GifFile, Concat(Dir,DirInfo.name));
  Reset(GifFile, 1);
  isgif := false;
  inc(filecount);
  inc(totalsize,dirinfo.size);
  ClearABC;
(* See if it's a GIF file. *)
  Result := Pos('.',Dirinfo.name);
  If (result > 0) and
    (Copy(DirInfo.name,result,Length(DirInfo.name)-result+1) = '.GIF')
    then isgif := true;
{  Result := Filesize; }
  If isgif { and (result>12) }
    then
      Begin
        blockread(GifFile, A, 1, result);
        blockread(GifFile, B, 1, result);
        blockread(GifFile, C, 1, result);
        gheader := A + B + C;
      End;
  If gheader = 'GIF'
    Then
      Begin {GifFileFound!}
        blockread(GifFile, A, 1, result);
        blockread(GifFile, B, 1, result);
        blockread(GifFile, C, 1, result);
        gversion := A + B + C;
        blockread(GifFile, height, 2, result);
        blockread(GifFile, width, 2, result);
        blockread(GifFile, Abyte, 1, result);
        SizeOfGCT := BV(Abyte,1) + BV(Abyte,2)*2 + BV(Abyte,3)*4 +1;
        colors := Exponential(2,SizeOfGCT);
        If BV(Abyte,4) = 1 then SortFlag := true else SortFlag := false;
        ColorResolution := BV(Abyte,5) + BV(Abyte,6)*2 + BV(Abyte,7)*4 +1;
        SizeOfPalette := Exponential(2,ColorResolution);
        SizeOfPalette := Exponential(SizeofPalette,3);
        If BV(Abyte,8) = 1 then GCTF := true else GCTF := false;
        Blockread(GifFile, BackgroundColorIndex, 1);
        Blockread(GifFile, PixelAspectRatio, 1);
        If dogiflite
          then
            Begin
              giflite := false;
              icount := 0;
              count := 1;
              jcount := giflitesearch;
              If GCTF then inc(jcount,3*colors);
              While (icount < jcount) and not giflite do
                Begin
                  Blockread(Giffile, A, 1, result);
                  If A = Copy(gifliteheader, count, 1) then
                    Begin
                      If count = length(gifliteheader)
                        then
                           giflite := true
                        else
                          inc(count)
                    End;
                  Inc(icount);
                End;
            End;
      End;
  Writeline(DirInfo);
  Close(GifFile);
  Inc(LinesWritten);
END;
(**********************)
Procedure WriteVolLabel;
Var v : searchrec; c : byte;
Begin
  FindFirst(Copy(Path,1,3)+'*.*',VolumeID,v);
  Write(' Volume in drive ',Copy(Path,1,1),' is ');
  For c := 1 to length(v.name) do if v.name[c] <> '.' then write(v.name[c]);
  Writeln;
  Write(' Directory of ',Copy(Dir,1,Length(Dir)-1));
  If Copy(Dir,2,1) = ':' then Write('\');
  Writeln;
  Writeln;
End;
(***************************************)
Procedure ParseParms(pps : string);
Begin { This only gets parms with a slash / in them. }
If Pos('/',pps) <> 1 Then { This is the filename with a slash appended }
  Begin
{    ProcessParms(Copy(pps,1,Pos('/',pps)-1)); }
    Path := Fexpand(Copy(pps,1,Pos('/',pps)-1));
    pps := Copy(pps,Pos('/',pps),Length(pps)-Pos('/',pps)+1)
  End;
While (Pos('/',pps) > 0) and (Length(pps) > 1) Do
  Begin
    ProcessParms(Copy(pps,1,2));
    pps := Copy(pps,2,Length(pps)-1);
    If Pos('/',pps) > 0 then
      pps := Copy(pps,Pos('/',pps),Length(pps)-Pos('/',pps)+1);
  End;
End;
(***************************************)
Procedure Initialize;
Var sr : searchrec;
Begin
  Assign(Input,'');   Reset(Input);
  Assign(Output,'');  Rewrite(Output);
  Writeln;
  Writeln(ProSoft);
  Writeln;
  dodate := true;  dotime := false;  domegs := false;  doextension := true;
  dopalette := false; doGCT := false; doversion := false; pause := false;
  dofiledot := false; dogiflite := true; doall := false;
  gheader := '  '; gversion := '   ';
  ClearABC; Clearname;
  FileCount := 0;  TotalSize := 0;  LinesWritten := 0;
  For count := 1 to Sizeof(path) do Path[count] := ' ';
  For count := 1 to Sizeof(Dir)  do Dir[count]  := ' ';
  For Count := 1 to Sizeof(Name) do Name[count] := ' ';
  For count := 1 to Sizeof(Ext)  do Ext[count]  := ' ';
  If paramcount = 0
    then
      Path := FExpand('*.GIF')
    else
      If Pos('/',paramstr(1)) = 1 then path := FExpand('*.GIF');
      For Count := 1 to paramcount do If Pos('/',paramstr(count)) > 0
        then
          ParseParms(paramstr(count))
        else
          Path := Fexpand(paramstr(count));
{
  FindFirst(Path,$10,sr);
  If (Doserror = 0) and (sr.attr = $10) then
    begin
      Path := Path + '\*.gif';
      Path := FExpand(Path)
    end;
}
  Fsplit(Path,Dir,Name,Ext);
  If (name = '') or (name = '        ') then name := '*';
  If (Ext = '') or (Ext = '    ') then Ext := '.GIF';
  Path := Dir + Name + Ext;
End;
(******************> Main <*********************)
Begin    { Main }
  Initialize;
  FindFirst(Path,$21,DirInfo);
  If Doserror = 0
    then
      Begin
        WriteVolLabel;
        While DosError < 1 do
          Begin
            If (dirinfo.name = '.') or (dirinfo.name = '..')
              then
                For count := 1 to 12 do DirInfo.name[count] := ' '
              else
                ProcessGifFile;
            FindNext(DirInfo);
            If pause and (LinesWritten = ScreenLines) and (DosError < 1)
              then
                Begin
                  Writeln('Press any key to continue . . .');
                    AssignCrt(Input);   Reset(Input);
                    AssignCrt(Output);  Rewrite(Output);
                  ch := Readkey;
                    Assign(Input,'');   Reset(Input);
                    Assign(Output,'');  Rewrite(Output);
                  Writeln;
                  LinesWritten := 1;
                End;
          End;
        Write(FileCount:9,' file');
        If Filecount = 1 then Write('  ') else Write('s ');
        cs := Copy(Path,1,1);
        cc := cs[1];
        count := ord(cc)-64;
        Writeln(totalsize:12,' bytes');
        Writeln(' ':16,diskfree(count):12,' bytes free ');
        Writeln;
      End
    Else
      Badparms;
End.
