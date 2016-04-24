(*
  Category: SWAG Title: ARCHIVE HANDLING
  Original name: 0011.PAS
  Description: LZH File Viewer
  Author: STEVE WIERENGA
  Date: 05-28-93  13:33
*)

{
Author: Steve Wierenga
LZH Viewer
}

Unit Lzhv;
(**) Interface (**)
Uses
  Dos,Crt;

Type
  FileheaderType = Record  { Lzh File header }
    Headsize,
    Headchk   : Byte;
    HeadID    : packed Array[1..5] of Char;
    Packsize,
    Origsize,
    Filetime  : LongInt;
    Attr      : Word;
    Filename  : String[12];
    f32       : PathStr;
    dt        : DateTime;
  end;

Var
  Fh         : FileheaderType;
  Fha        : Array[1..sizeof(FileheaderType)] of Byte Absolute fh;
  crc        : Word;   { CRC value }
  crcbuf     : Array[1..2] of Byte Absolute CRC;
  crc_table  : Array[0..255] of Word; { Table of CRC's }
  inFile     : File; { File to be processed }
  registered : Boolean; { Is registered? }

Procedure Make_crc_table; { Create table of CRC's }
Function  Mksum : Byte;     { Get CheckSum }
Procedure ViewLzh(LZHFile : String);  { View the File }
Function  GAN(LZHFile : String) : String;  { Get the LZH Filename }


(**) Implementation (**)
Procedure Terminate; { Exit the Program }
begin
  Write('ARCHPEEK could not find specified File. Aborting...');
  Halt;
end;

Procedure Make_crc_table;
Var
  i,
  index,
  ax    : Word;
  carry : Boolean;
begin
  index := 0;
  Repeat
    ax := index;
    For i := 1 to 8 do
    begin
      carry := odd(ax);
      ax := ax shr 1;
      if carry then
        ax := ax xor $A001;
    end;
    crc_table[index] := ax;
    inc(index);
  Until index > 255;
end;

{ use this to calculate the CRC value of the original File }
{ call this Function afer reading every Byte from the File }
Procedure calccrc(data : Byte);
Var
  index : Integer;
begin
  crcbuf[1] := crcbuf[1] xor data;
  index := crcbuf[1];
  crc := crc shr 8;
  crc := crc xor crc_table[index];
end;


Function Mksum : Byte;  {calculate check sum For File header }
Var
  i : Integer;
  b : Byte;
begin
  b := 0;
  For i := 3 to fh.headsize+2 do
    b := b+fha[i];
  mksum := b;
end;

Procedure viewlzh(LZHFile : String); { View the LZH File }
Var
  l1,l2,
  oldFilepos,
  a,b,a1,b1,
  totalorig,
  totalpack : LongInt;
  count,z   : Integer;
  numread,
  i, year1,
  month1,
  day1,
  hour1,
  min1,
  sec1      : Word;
  s1        : String[50];
  s2        : String[20];
  l         : String[80];
  sss       :  String;
begin
  registered  :=  False; { Unregistered }
  if not registered then { Registered? }
  begin
    Writeln('ArchPeek 0.01Alpha [UNREGISTERED] Copyright 1993 Steve Wierenga');
    Delay(200);
  end;
  assign(inFile,LZHFile);
  {$I-}
  reset(inFile,1);   { Open LZH File }
  {$I+}
  If IOResult <> 0 then
    Terminate;   { Specified File exists? }
  sss :=  GAN(LZHFile);  { Get Filename of LZH File }
  Writeln( 'Lzh FileName: ',sss);
  WriteLn( '    Name           Length      Size  Saved    Date      Time    ');
  WriteLn('__________________________________________________________');
  oldFilepos := 0;       { Init Variables }
  count := 1;
  z  := 0;
  a1 := 0;
  Repeat
    z  :=  z + 1;
    seek(inFile,oldFilepos);                              {
    Goto start of File}
    blockread(inFile,fha,sizeof(FileheaderType),numread); {
    Read Fileheader}
    oldFilepos := oldFilepos+fh.headsize+2+fh.packsize;   {
    Where are we? }
    i := Mksum; { Get the checksum }
    if fh.headsize <> 0 then
    begin
      if i <> fh.headchk then
      begin
        Writeln('Error in File. Unable to read.  Aborting...');
        Close(inFile);
        Exit;
      end;
      Case Length(Fh.FileName) Of          { Straigthen out String }
        1  : Fh.FileName  :=  Fh.FileName + '           ';
        2  : Fh.FileName  :=  Fh.FileName + '          ';
        3  : Fh.FileName  :=  Fh.FileName + '         ';
        4  : Fh.FileName  :=  Fh.FileName + '        ';
        5  : Fh.FileName  :=  Fh.FileName + '       ';
        6  : Fh.FileName  :=  Fh.FileName + '      ';
        7  : Fh.FileName  :=  Fh.FileName + '     ';
        8  : Fh.FileName  :=  Fh.FileName + '    ';
        9  : Fh.FileName  :=  Fh.FileName + '   ';
        10 : Fh.FileName  :=  Fh.FileName + '  ';
        11 : Fh.FileName  :=  Fh.FileName + ' ';
        12 : Fh.FileName  :=  Fh.FileName + '';
      end;
      UnPackTime(Fh.FileTime,Fh.DT);
      a1 := a1 + Fh.OrigSize;            { Increase Uncompressed Size }
      Write('       ', fh.Filename : 2, fh.origsize : 9, fh.packSize : 10,
                   (100 - fh.packSize / fh.origSize * 100) : 5 : 0, '%');
       { Display info }
      Case fh.dt.month of  { Get date and time }
        1..9   : Write( '0':4,fh.dt.month);
        10..12 : Write( ' ',fh.dt.month:4);
      end;
      Write( '/');
      Case fh.dt.day of
        1..9   : Write( '0',fh.dt.day);
        10..31 : Write( fh.dt.day);
      end;
      Write( '/');
      Case fh.dt.year of
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
      Case fh.dt.hour of
        0..9   : Write( '0':3,fh.dt.hour,':');
        10..23 : Write( ' ',fh.dt.hour:3,':');
      end;
      Case fh.dt.min of
        0..9   : Write( '0',fh.dt.min,':');
        10..59 : Write( fh.dt.min,':');
      end;
      Case fh.dt.sec of
        0..9   : Writeln( '0',fh.dt.sec);
        10..59 : Writeln( fh.dt.sec);
      end;
    end;
  Until   (fh.headsize=0);
  Writeln( '===========================================================');
  GetFTime(inFile,l1);
  UnPackTime(l1,fh.dt);
  Write( '  ', z, ' Files  ', a1 : 12, FileSize(inFile) : 10,
          (100 - FileSize(inFile) / a1 * 100) : 5 : 0, '%');
  Case fh.dt.month of
    1..9   : Write( '0':4,fh.dt.month);
    10..12 : Write( ' ',fh.dt.month:4);
  end;
  Write( '/');
  Case fh.dt.day of
    1..9   : Write( '0',fh.dt.day);
    10..31 : Write( fh.dt.day);
  end;
  Write( '/');
  Case fh.dt.year of
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
  Case fh.dt.hour of
    0..9   : Write( '0':3,fh.dt.hour,':');
    10..23 : Write( ' ',fh.dt.hour:3,':');
  end;
  Case fh.dt.min of
    0..9   : Write( '0',fh.dt.min,':');
    10..59 : Write( fh.dt.min,':');
  end;
  Case fh.dt.sec of
    0..9   : Writeln( '0',fh.dt.sec);
    10..59 : Writeln( fh.dt.sec);
  end;
end;

Function GAN(LZHFile : String): String;
Var
  Dir  : DirStr;
  Name : NameStr;
  Exts : ExtStr;
begin
  FSplit(LZHFile,Dir,Name,Exts);
  GAN := Name + Exts;
end;


end.


