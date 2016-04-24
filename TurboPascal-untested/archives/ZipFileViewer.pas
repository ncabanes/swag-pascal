(*
  Category: SWAG Title: ARCHIVE HANDLING
  Original name: 0012.PAS
  Description: Zip File Viewer
  Author: STEVE WIERENGA
  Date: 05-28-93  13:33
*)

{
Author: Steve Wierenga
ZIP Viewer
}

Unit ZipV;

(**) Interface (**)

Uses
  Dos,Crt;
Procedure ZipView(ZIPFile:String);
Function GAN(ZIPFile : String) : String;

(**) Implementation (**)

Procedure Terminate;
begin
  Write('ARCHPEEK could not find specified File. Aborting...');
  Halt;
end;

Procedure ZipView(ZIPFile : String);  { View the ZIP File }
Const
  SIG = $04034B50;                  { Signature }
Type
  ZFHeader = Record                 { Zip File Header }
    Signature  : LongInt;
    Version,
    GPBFlag,
    Compress,
    Date,Time  : Word;
    CRC32,
    CSize,
    USize      : LongInt;
    FNameLen,
    ExtraField : Word;
  end;

Var
  z       : Integer;
  x,
  totalu,
  totalc  : LongInt;
  Hdr     : ^ZFHeader;
  F       : File;
  S,sss   : String;
  own     : Text;
  dt1     : DateTime;
  l       : String[80];
  registered : Boolean;  { Is registered? }

Const
  CompTypes : Array[0..7] of String[9] =
              ('Stored ','Shrunk   ','Reduced1','Reduced2','Reduced3',
               'Reduced4','Imploded ','Deflated');
  { Method used to compress }
  r = #196;
  q = #205;

begin
  z := 0; totalu := 0; totalc := 0; { Init Variables }
  registered := False; { Unregistered }
  if not registered then   { Is registered? }
  begin
    Writeln('ArchPeek 0.01Alpha [UNREGISTERED] Copyright 1993 Steve Wierenga');
    Delay(200);
  end;
  New(Hdr);
  Assign(F,ZIPFile);
  {$I-}
  Reset(F,1);                   { Open File }
  {$I+}
  If IOResult <> 0 then Terminate;  { Couldn't open Zip File }
  sss := GAN(ZipFile);              { Get the Zip Filename }
  Writeln('Zip FileName: ',sss);
  WriteLn( '   Name           Length      Size  Saved Method');
  WriteLn(r,r,r,r,r,r,r,r,r,r,r,r,r,r,r,r,r,r,r,r,r,r,r,r,r,r,r,r,r,r,r,
          r,r,r,r,r,r,r,r,r,r,r,r,r,r,r,r,r,r,r,r,r,r,r,r,r,r);
  Repeat
    FillChar(S,SizeOf(S), #0);  { Pad With nulls }
    BlockRead(F,Hdr^,SizeOf(ZFHeader));
    { Read File Header }
    BlockRead(F,Mem[Seg(S) : Ofs(S) + 1], Hdr^.FNameLen);
    s[0] := Chr(Hdr^.FNameLen);
    Case Length(S) Of    { Straighten String }
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
      If (Hdr^.Signature = Sig) Then { Is a header }
    begin
      z := z + 1;
      WriteLn(S,Hdr^.USize:9,Hdr^.CSize:10,(100-Hdr^.CSize/Hdr^.USize*100):5:0,'%',
              CompTypes[Hdr^.Compress]:16);
      Inc(TotalU,Hdr^.USize);  { Increment size uncompressed }
      Inc(TotalC,Hdr^.CSize);  { Increment size compressed }
    end;
    Seek(F,FilePos(F) + Hdr^.CSize + Hdr^.ExtraField);
  Until Hdr^.Signature <> SIG; { No more Files }
  GetFTime(F,x);
  UnPackTime(x,DT1);
  WriteLn(q,q,q,q,q,q,q,q,q,q,q,q,q,q,q,q,q,q,q,q,q,q,q,q,q,q,q,q,q,q,q,q,q,q,q,q,q,q,
          q,q,q,q,q,q,q,q,q,q,q,q,q,q,q,q,q,q,q,q);
  Write( z:4,' Files ',TotalU:12,TotalC:10,(100-TotalC/TotalU*100):5:0,'%');
  Case dt1.month of        { Get Zip File date and time }
    1..9   : Write( '0':4,dt1.month);
    10..12 : Write( dt1.month:4);
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
    0..9   : Write( '0':3,dt1.hour,':');
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
  Close(F);
  Dispose(Hdr);
end;


Function GAN(ZIPFile:String): String;
Var
  Dir  : DirStr;
  Name : NameStr;
  Exts : ExtStr;
begin
  FSplit(ZIPFile,Dir,Name,Exts);
  GAN := Name + Exts;
end;

end.

