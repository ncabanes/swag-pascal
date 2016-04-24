(*
  Category: SWAG Title: MAIL/QWK/HUDSON FILE ROUTINES
  Original name: 0009.PAS
  Description: Read SWG or QWK Files
  Author: GAYLE DAVIS
  Date: 10-28-93  11:39
*)

{$V-,S-}
{ this SIMPLE little ditty let's you read SWAG or QWK files which have
  EXACTLY the same format }
Program ReadQWKORSWAGFile;

Uses
  Crt;

Const
  Seperator = '---------------------------------------------------------------------------';

Type

  CharArray = ARRAY[1..6] OF CHAR;  { to read in chunks }

  MSGDATHdr = Record  { ALSO the format for SWAG files !!! }
    Status   : Char;
    MSGNum   : Array [1..7] of Char;
    Date     : Array [1..8] of Char;
    Time     : Array [1..5] of Char;
    UpTO     : Array [1..25] of Char;
    UpFROM   : Array [1..25] of Char;
    Subject  : Array [1..25] of Char;
    PassWord : Array [1..12] of Char;
    ReferNum : Array [1..8] of Char;
    NumChunk : CharArray;
    Alive    : Byte;
    LeastSig : Byte;
    MostSig  : Byte;
    Reserved : Array [1..3] of Char;
  end;

Var
  F           : File;
  DefSaveFile : String;
  Number      : Word;

FUNCTION ArrayTOInteger(B : CharArray; Len : BYTE) : LONGINT;

VAR I : Byte;
    S : STRING;
    E  : Integer;
    T  : Integer;

BEGIN
    S := '';
    FOR I := 1 TO PRED(Len) DO IF B[i] <> #32 THEN S := S + B[i];
    Val (S, T, E);
    IF E = 0 THEN ArrayToInteger := T;
END;

Procedure ReadMSG (NumChunks : INTEGER);
Var
  Buff : Array [1..128] of Char;
  J    : INTEGER;
  I    : Byte;

begin
  For J := 1 to PRED(NumChunks) do
  begin
    BlockRead (F, Buff, 1);
    For I := 1 to 128 do
      If Buff [I] = #$E3 then
        Writeln
      else
        Write (Buff [I]);
  end;
end;

Procedure ReadWriteHdr (Var HDR : MSGDatHdr);
begin
  BlockRead (F, Hdr, 1);
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
    Writeln(Seperator);
  end;
end;

Procedure ReadMessage (HDR : MSGDatHdr; RelNum : LONGINT; VAR Chunks : INTEGER);
begin
  Seek(F,RelNum-1);
  ReadWriteHdr (HDR);
  Chunks := ArrayToInteger(HDR.NumChunk,6);
  ReadMsg (Chunks);
end;

Var
  MSGHdr   : MSGDatHdr;
  REPorDAT : Boolean;
  ch       : CHAR;
  count    : INTEGER;
  chunks   : INTEGER;

begin

  DefSaveFile := '';
  DirectVideo := False;
  Assign (F, '\SWAG\FILES\EGAVGA.SWG'); { whatever file ..    }
                                        { MESSAGES.DAT for .QWK}
  Reset (F, SizeOf(MsgHdr));
  Count := 2;  { start at RECORD #2 }
  WHILE (Count < FileSize(F)) DO
        BEGIN
        ClrScr;
        ReadMessage (MSGHdr, Count, Chunks);
        Writeln;
        WriteLn('..any key to continue .. (any FN Key quits)');
        ch := Readkey;  { any FN key quits }
        IF Ch = #0 THEN HALT;
        INC(Count,Chunks);
        END;
  Close (F);

end.

