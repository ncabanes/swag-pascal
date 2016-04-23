{
>Could someone post the structures For a QWK mail packet, and could
>someone, post how to make a BBS Fido-Net compatible, in other Words the
>File structures..Thanks in advance..
}

{$V-}

Program ReadQWKRepFile;

Uses
  Crt;

Const
  Seperator = '---------------------------------------------------------------------------';

Type
  ConfType = ^Conference;
  Conference = Record
    Number : Byte;
    Name   : Array [1..10] of Char;
  end;
  CONDATHdr = Record
    BBSName  : Array [1..25] of Char;
    Location : Array [1..25] of Char;
    Number   : Array [1..12] of Char;
    SysopName: Array [1..25] of Char;
    SerialNum: Array [1..5] of Char;
    BBSID    : Array [1..8] of Char;
    Date     : Array [1..10] of Char;
    Time     : Array [1..8] of Char;
    UserName : Array [1..25] of Char;
    NumConfs : Byte;
    Confs    : Array [1..30] of ConfType;
  end;
  MSGDATHdr = Record
    Status   : Char;
    MSGNum   : Array [1..7] of Char;
    Date     : Array [1..8] of Char;
    Time     : Array [1..5] of Char;
    UpTO     : Array [1..25] of Char;
    UpFROM   : Array [1..25] of Char;
    Subject  : Array [1..25] of Char;
    PassWord : Array [1..12] of Char;
    ReferNum : Array [1..8] of Char;
    NumChunk : Array [1..6] of Char;
    Alive    : Byte;
    LeastSig : Byte;
    MostSig  : Byte;
    Reserved : Array [1..3] of Char;
  end;
  MSSingle = Array[0..3] of Byte;

Var
  F           : File;
  DefSaveFile : String;
  ConfNum     : String [8];
  Number      : Word;



Function Valu2 (S : String) : Word;
Var
  C  : Word;
  E  : Integer;
begin
  Val (S, C, E);
  If E = 0 then
    Valu2 := C
  else
    Valu2 := 0;
end;

Procedure ParseCommandLine;
Var
  I : Byte;
  C : Char;
  S : String;
begin
  For I := 1 to ParamCount do
  begin
    S := ParamStr (I);
    If S [1] = '/' then
    begin
      C := UpCase (S [2]);
      Delete (S, 1, 2);
      Case C of
        'C' : ConfNum := S;
        'S' :
              begin
                While Length (S) <> 3 do
                  S := '0' + S;
                DefSaveFile := S;
              end;

        'N' : Number := Valu2 (S);
      end;
    end;
  end;
end;


Function MStoIEEE (MS : MSSingle) : Real;
{ Converts a 4 Byte Microsoft format single precision Real Variable as
  used in earlier versions of QuickBASIC and GW-BASIC to IEEE 6 Byte Real }
Var
  r      : Real;
  ieee   : Array[0..5] of Byte Absolute r;
begin
  FillChar(r,sizeof(r),0);
  ieee[0] := MS[3];
  ieee[3] := MS[0];
  ieee[4] := MS[1];
  ieee[5] := MS[2];
  MStoIEEE  := r;
end;  { MStoIEEE }

Function Valu (S : String) : LongInt;
Var
  C     : LongInt;
  T, E  : Integer;
  I     : Byte;
  Place : LongInt;
begin
  Place := 1;
  C := 0;
  For I := 6 downto 1 do
  begin
    Val (S [I], T, E);
    If T <> 0 then
    begin
      C := C + T * Place;
      Place := Place * 10;
    end;
  end;
  Valu := C - 1;
end;

Procedure ReadMSG (NumChunks : LongInt);
Var
  Buff : Array [1..128] of Char;
  J    : LongInt;
  I    : Byte;

begin
  For J := 1 to NumChunks do
  begin
    BlockRead (F, Buff, 128);
    For I := 1 to 128 do
      If Buff [I] = #$E3 then
        Writeln
      else
        Write (Buff [I]);
  end;
end;

Procedure ReadWriteHdr (Var HDR : MSGDatHdr);
begin
  BlockRead (F, Hdr, SizeOf (Hdr));
  With Hdr do
  begin
    Write ('Date: ', Date, ' (', Time, ')');
    Writeln ('' : 23, 'Number: ', MSGNum);
    Write ('From: ', UpFROM);
    Writeln ('' : 14, 'Refer#: ', ReferNum);
    Write ('  To: ', UpTO);
    Write ('' : 15, 'Recvd: ');
    If Status in ['-', '`', '^', '#'] then
      Writeln ('YES')
    else
      Writeln ('NO');
    Write ('Subj: ', Subject);
    Writeln ('' : 16, 'Conf: ', '(', LeastSig, ')');
    Writeln;
  end;
end;

Procedure ReadMessage (HDR : MSGDatHdr; REPorDAT : Boolean);
begin
  ReadWriteHdr (HDR);
  ReadMsg (Valu (HDR.NumChunk));
end;

Procedure ReadControlFile (Var Control : CONDatHdr);
Var
  CFile    : Text;

  Procedure ReadToEOLN (Var FNAME; Length : Byte; Down : Boolean);
  Var
    I : Byte;
    C : Char;
  begin
    I := 0;
    Repeat
      Read (CFile, C);
      Mem [Seg (FNAME) : Ofs (FNAME) + I] := Ord (C);
      Inc (I);
    Until EOLN (CFile) or (I > Length) or (Not Down and (C = ','));
    If Not Down then
      Dec (I);
    For I := I to Length do
      Mem [Seg (FNAME) : Ofs (FNAME) + I] :=32;
    If Down then
      Readln (CFile);
  end;

Var
  TempChar : Char;
  S        : String;
  I        : Byte;
begin
  Assign (CFile, 'CONTROL.DAT');
  Reset (CFile);
  With Control do
  begin
    ReadToEOLN (BBSName, 25, True);
    ReadToEOLN (Location, 25, True);
    ReadToEOLN (Number, 12, True);
    ReadToEOLN (SysopName, 25, False);
    Readln (CFile);
    ReadToEOLN (SerialNum, 5, False);
    ReadToEOLN (BBSID, 8, True);
    ReadToEOLN (Date, 10, False);
    ReadToEOLN (Time, 8, True);
    ReadToEOLN (UserName, 25, True);
    For I := 1 to 4 do
      Readln (CFile, S);
    NumConfs := Valu (S) + 1;
    For I := 1 to NumConfs do
    begin
      New (Confs [I]);
      Readln (CFile, S);
      Confs [I]^.Number := Valu2 (S);
      ReadToEOLN (Confs [I]^.Name, 10, True);
    end;
  end;
  Close (CFile);
end;

Function GetSaveFile : String;
Var
  S : String;
begin
  Writeln ('Enter the name of the File to save it in (GIVE A DIRECTORY!) or [Return] for');
  Writeln ('C:\SLMR\SAVE.TXT');
  Readln (S);
  If S = '' then
    S := 'C:\SLMR\SAVE.TXT';
  GetSaveFile := S;
end;

Function GetYN (S : String) : Boolean;
Var
  X  : Char;
begin
  Repeat
    Write (S);
    X := UpCase (ReadKey);
    Writeln (X);
  Until X in ['Y', 'N'];
  GetYN := X = 'Y';
end;

Procedure ScanMessages (REPorDAT : Boolean);
Var
    HDR : MSGDatHdr;
    S  : String [3];
    I  : Byte;
    F2 : File;
    MS : MSSingle;
    YN  : Boolean;
begin
  ClrScr;
  Repeat
    If ConfNum = '' then
    begin
      Writeln;
      Write ('Enter the name/number For the conference : ');
      Readln (ConfNum);
      Writeln;
    end;
    While (Length (ConfNum) < 3) do
      ConfNum := '0' + ConfNum;
    Writeln (ConfNum);
    Assign (F2, ConfNum + '.NDX');
    {$I-}
    Reset (F2, 1);
    {$I+}
    If IOResult <> 0 then
      RunError (2);

    Repeat
      Repeat

        Writeln;
        If Number = 0 then
        begin
          Writeln ('Enter the SLMR number ( ??? / XXX ) of the message to pull, or 0 to quit : ');
          Readln (Number);
        end;
        If Number = 0 then
        begin
          Close (F2);
          Close (F);
          Halt;
        end;

        Writeln;
        Seek (F2, (Number - 1) * 5);
        BlockRead (F2, MS, 4);

        Seek (F, Round (MStoIEEE (MS) - 1) * 128);
        ReadWriteHdr (HDR);

        YN := GetYN ('Capture this message ? ');
        Number := 0;

      Until YN;

      Seek (F, Round (MStoIEEE (MS) - 1) * 128);
      Writeln;
      Writeln;
      If Not GetYN ('Extract to Screen ? [Y/N] (N sends to File): ') then
        Assign (Output, GetSaveFile);
      {$I-}
      Reset (Output);
      {$I+}
      If IOResult <> 0 then
        ReWrite (Output)
      else
        Append (Output);
      Writeln;
      Writeln (Seperator);
      Writeln;
      ReadMessage (Hdr, REPorDAT);
      Writeln;
      Writeln;
      Close (Output);
      Assign (Output, '');
      ReWrite (Output);
      YN := GetYN ('Extract more messages? [Y/N] ');
    Until Not YN;

    Close (F2);
    YN := GetYN ('Select another message base? [Y/N] ');
  Until Not YN;
end;


Var
  Control  : CONDatHdr;
  MSGHdr   : MSGDatHdr;
  REPorDAT : Boolean;

begin
  DefSaveFile := '';
  ConfNum := '';
  Number := 0;
  ParseCommandLine;
  DirectVideo := False;
  ReadControlFile (Control);
  { Assign (F, Control.BBSID + '.MSG');}
  Assign (F, 'MESSAGES.DAT');
  Reset (F, 1);
  BlockRead (F, MSGHdr, SizeOf (MSGHdr));
  REPorDAT := (MSGHdr.Status + MSGHdr.MSGNum = Control.BBSID);
  ScanMessages (REPorDAT);
  { While Not EOF (F) do ReadMessage (MSGHdr, REPorDAT);}
  Close (F);
end.
