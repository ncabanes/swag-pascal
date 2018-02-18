(*
  Category: SWAG Title: ARCHIVE HANDLING
  Original name: 0010.PAS
  Description: ARJ File Viewer
  Author: STEVE WIERENGA
  Date: 05-28-93  13:33
*)

{
Author: Steve Wierenga
ARJ Viewer
}
{Hello All:
I am releasing these Units to the public domain.  They are Units to view Arj,
Lzh, and Zip Files.  They are by no means professional, and probably have some
bugs.  If you use these in your Programs and feel like giving me credit, I
won't Object...  Here goes: }

(*
Unit ArjV;

Interface
*)
Uses
  Dos,Crt;

Type
  AFHeader = Record  { ArjFileHeader }
    HeadID,
    HdrSize   : Word;
    HeadSize,
    VerNum,
    MinVerNum,
    HostOS,
    ArjFlag,
    Method,
    FType,
    Reserved  : Byte;
    FileTime,
    PackSize,
    OrigSize,
    FileCRC   : LongInt;
    FilePosF,
    FileAcc,
    HostData  : Word;
  end;

Var
  ff     : Integer;
  b      : Byte;
  f      : File;
  sl     : LongInt;
  NR     : Word;
  FHdr   : ^AFHeader;
  s,sss  : String;
  Method : String[8];
  l      : String[80];
  Z,
  totalu,
  totalc : LongInt;
  x,d    : LongInt;
  Dt1,dt2: DateTime;
  i,e    : Integer;
  registered : Boolean;

(*
Procedure ArjView(ArjFile : String);
Function GAN(ArjFile : String): String;
*)
(* Implementation *)

Procedure Terminate;
begin
  Write('ARCHPEEK could not find specified File. Aborting...');
  Halt;
end;

Procedure ArjView(ArjFile : String);
begin
  New(FHdr);
  Assign(f, arjFile);
  {$I-}
  Reset(F, 1);                     { Open File }
  {$I+}
  If IOResult <> 0 then
    Terminate; { Specified File exists?}
  registered := False;             { Unregistered }
  if not registered then
  begin
    Writeln('ArchPeek 0.01Alpha [UNREGISTERED] Copyright 1993 Steve Wierenga');
    Delay(200);
  end;
  SL := 0;z := 0;TotalU := 0; TotalC := 0;   { Init  Variables }
  sss := (*GAN*)(ArjFile);                       { Get the Arj Filename }
  Writeln('Arj FileName: ',SSS);
  Write('   Name           Length      Size       Saved     Method     Date Time      ');
  WriteLn('____________________________________________________________________________');
  ff := 0;
  Repeat
    ff := ff + 1;
    Seek(F,SL);
    BlockRead(F,FHdr^,SizeOf(AFHeader),NR);     { Read the header }
    If (NR = SizeOf(AFHeader)) Then
    begin
      s := '';
      Repeat
        BlockRead(F,B,1);               { Get Char For Compressed Filename }
        If B <> 0 Then
          s := s + Chr(b);              { Put Char in String }
      Until B = 0;                      { Until no more Chars }
      Case Length(S) Of                 { Straighten out String }
        0  : s := s + '            ';
        1  : S := s + '           ';
        2  : s := s + '          ';
        3  : S := S + '         ';
        4  : S := S + '        ';
        5  : S := S + '       ';
        6  : S := S + '      ';
        7  : S := S + '     ';
        8  : S := S + '    ';
        9  : S := S + '   ';
        10 : S := S + '  ';
        11 : S := S + ' ';
        12 : S := S;
      end;
      z := z + 1;
      UnPackTime(FHdr^.FileTime,dt2);  { Get the time of compressed File }
      Case FHdr^.Method Of             { Get compression method }
        0 : Method := 'Stored  ';
        1 : Method := 'Most    ';
        2 : Method := '2nd Most';
        3 : Method := '2nd Fast';
        4 : Method := 'Fastest ';
      end;
      Write( ' ',S,FHdr^.OrigSize:9,FHdr^.PackSize:10);
      { Write Filesizes }
      If ff > 1 then
        { Don't get first Arj File in Arj File }
        Write( (100-FHdr^.PackSize/FHdr^.OrigSize*100):9:0,'%',Method:15)
         { Write ratios, method }
        Else
          Write( Method:25);
      Case dt2.month of               { Show date of compressed File }
        1..9   : Write( '0':4,dt2.month);
        10..12 : Write( dt2.month:4);
      end;
      Write( '/');
      Case dt2.day of
        1..9   : Write( '0',dt2.day);
        10..31 : Write( dt2.day);
      end;
      Write( '/');
      Case dt2.year of
        1980 : Write( '80');
        1981 : Write( '81');
        1982 : Write( '82');
        1983 : Write( '83');
        1984 : Write( '84');
        1985 : Write( '85');
        1986 : Write( '86');
        1987 : Write( '87');
        1988 : Write( '88');
        1989 : Write( '89');
        1990 : Write( '90');
        1991 : Write( '91');
        1992 : Write( '92');
        1993 : Write( '93');
        1994 : Write( '94');
        1995 : Write( '95');
        1996 : Write( '96');
      end;
      Case dt2.hour of                          { Show time of compressed File }
        0..9   : Write( '0':2,dt2.hour,':');
        10..23 : Write( dt2.hour:3,':');
      end;
      Case dt2.min of
        0..9   : Write( '0',dt2.min,':');
        10..59 : Write( dt2.min,':');
      end;
      Case dt2.sec of
        0..9   : Writeln( '0',dt2.sec);
        10..59 : Writeln( dt2.sec);
      end;
      TotalU := TotalU + FHdr^.OrigSize; { Increase total uncompressed size }
      TotalC := TotalC + FHdr^.PackSize; { Increase total compressed size }
      Repeat
        BlockRead(F,B,1);
      Until b = 0;
      BlockRead(F,FHdr^.FileCRC,4);      { Go past File CRC }
      BlockRead(f,NR,2);
      Sl := FilePos(F) + FHdr^.PackSize; { Where are we in File? }
    end;

  Until (FHdr^.HdrSize = 0);  { No more Files? }
  GetFTime(F,x);
  UnPackTime(x,dt1);
  WriteLn('============================================================================');
  Write( (z-1):4,' Files',TotalU:12,TotalC:10,(100-TotalC/TotalU*100):9:0,'%');
  Case dt1.month of                  { Get date and time of Arj File }
    1..9   : Write( '0':19,dt1.month);
    10..12 : Write( dt1.month:20);
  end;
  Write( '/');
  Case dt1.day of
    1..9   : Write( '0',dt1.day);
    10..31 : Write( dt1.day);
  end;
  Write( '/');
  Case dt1.year of
    1980 : Write( '80');
    1981 : Write( '81');
    1982 : Write( '82');
    1983 : Write( '83');
    1984 : Write( '84');
    1985 : Write( '85');
    1986 : Write( '86');
    1987 : Write( '87');
    1988 : Write( '88');
    1989 : Write( '89');
    1990 : Write( '90');
    1991 : Write( '91');
    1992 : Write( '92');
    1993 : Write( '93');
    1994 : Write( '94');
    1995 : Write( '95');
    1996 : Write( '96');
  end;
  Case dt1.hour of
    0..9   : Write( '0':2,dt1.hour,':');
    10..23 : Write( dt1.hour:3,':');
  end;
  Case dt1.min of
    0..9   : Write( '0',dt1.min,':');
    10..59 : Write( dt1.min,':');
  end;
  Case dt1.sec of
    0..9   : Writeln( '0',dt1.sec);
    10..59 : Writeln( dt1.sec);
  end;
  Close(f);
  Dispose(FHdr);  { Done }
end;

Function GAN(ARJFile:String): String;
Var
  Dir  : DirStr;
  Name : NameStr;
  Exts : ExtStr;
begin
  FSplit(ARJFile,Dir,Name,Exts);
  GAN := Name + Exts;
end;

begin
    ArjView('example.arj');
end.

