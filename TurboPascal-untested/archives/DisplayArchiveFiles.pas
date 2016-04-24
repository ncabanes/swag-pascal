(*
  Category: SWAG Title: ARCHIVE HANDLING
  Original name: 0002.PAS
  Description: Display Archive Files
  Author: MIKE COPELAND
  Date: 05-28-93  13:33
*)

{
   Hmmmm, I thought I responded to you on this before.  Whether I did or
not, I will post what I did before (in the next two messages), but I
don't want to post the entire Program - I'm building a ShareWare
progream I plan to market, and I don't think I should give it _all_
away.  The code I post is pertinent to reading the headers and Filename
info in the Various archive Types, and I Really think you can work out
the rest without much trouble.  If you can't, please post a specific
question...
}

Const
      BSize    = 4096;                                      { I/O Buffer Size }
      HMax     = 512;                                   { Header Maximum Size }
Var
      I,J,K        : Integer;
      CT,RC,TC     : Integer;
      RES          : Word;                                   { Buffer Residue }
      N,P,Q        : LongInt;
      C            : LongInt;                                 { Buffer Offset }
      FSize        : LongInt;                                     { File Size }
      DEVICE       : Char;                                      { Disk Device }
      F            : File;
      SNAME        : String;
      DATE         : String[8];                  { formatted date as YY/MM/DD }
      TIME         : String[5];                  {     "     time as HH:MM    }
      DirInfo      : SearchRec;                       { File name search Type }
      SR           : SearchRec;                       { File name search Type }
      DT           : DateTime;
      PATH         : PathStr;
      DIR          : DirStr;
      FNAME        : NameStr;
      EXT          : ExtStr;
      Regs         : Registers;
      BUFF         : Array[1..BSize] of Byte;

Procedure FDT (LI : LongInt);                       { Format Date/Time fields }
begin
  UnPackTime (LI,DT);
  DATE := FSI(DT.Month,2)+'/'+FSI(DT.Day,2)+'/'+Copy(FSI(DT.Year,4),3,2);
  if DATE[4] = ' ' then DATE[4] := '0';
  if DATE[7] = ' ' then DATE[7] := '0';
  TIME := FSI(DT.Hour,2)+':'+FSI(DT.Min,2);
  if TIME[4] = ' ' then TIME[4] := '0';
end;  { FDT }

Procedure  MY_FFF;
Var I,J,K : LongInt;

(**************************** ARJ Files Processing ***************************)
Type ARJHead = Record
                 FHeadSize : Byte;
                 ArcVer1,
                 ArcVer2   : Byte;
                 HostOS,
                 ARJFlags,
                 Method    : Byte;   { MethodType = (Stored, LZMost, LZFast); }
                 R1,R2     : Byte;
                 Dos_DT    : LongInt;
                 CompSize,
                 UCompSize,
                 CRC       : LongInt;
                 ENP, FM,
                 HostData  : Word;
               end;
Var ARJ1     : ARJHead;
    ARJId    : Word;                                     { 60000, if ARJ File }
    HSize    : Word;                                            { Header Size }
Procedure GET_ARJ_ENTRY;
begin
  FillChar(ARJ1,SizeOf(ARJHead),#0); FillChar(BUFF,BSize,#0);
  Seek (F,C-1); BlockRead(F,BUFF,BSIZE,RES);        { read header into buffer }
  Move (BUFF[1],ARJId,2);  Move (BUFF[3],HSize,2);
  if HSize > 0 then
    With ARJ1 do
      begin
        Move (BUFF[5],ARJ1,SizeOf(ARJHead));
        I := FHeadSize+5; SNAME := B40;
        While BUFF[I] > 0 do Inc (I);
        I := I-FHeadSize-5;
        Move (BUFF[FHeadSize+5],SNAME[1],I); SNAME[0] := Chr(I);
        FSize := CompSize; Inc (C,HSIZE);
      end;
end;  { GET_ARJ_ENTRY }

Procedure DO_ARJ (FN : String);
begin
  Assign (F,FN); Reset (F,1); C := 1;
  GET_ARJ_ENTRY;                                            { Process File
Header }
  Repeat
    Inc(C,FSize+10);
    GET_ARJ_ENTRY;
    if HSize > 0 then
      begin
        Inc (WPX); New(SW[WPX]);       { store Filename info in dynamic Array }
        With SW[WPX]^ do
          begin
            FSplit (SNAME,DIR,FNAME,EXT); F := FNAME; E := Copy(EXT+'    ',1,4)
            SIZE := ARJ1.UCompSize;
            RType := 4; D_T := ARJ1.Dos_DT; ANUM := ADX; VNUM := VDX;
            ADD_CNAME;
          end;
        Inc (CCT); SSL; Inc (ARCS[ADX]^.COUNT)
      end;
  Until HSize <= 0;
  Close (F);
end;  { DO_ARJ }

(**************************** ZIP Files Processing ***************************)
Type ZIPHead = Record
                 ExtVer : Word;
                 Flags  : Word;
                 Method : Word;
                 Fill1  : Word;
                 Dos_DT        : LongInt;
                 CRC32         : LongInt;
                 CompSize      : LongInt;
                 UCompSize     : LongInt;
                 FileNameLen   : Word;
                 ExtraFieldLen : Word;
               end;
Var ZIPCSize : LongInt;
    ZIPId    : Word;
    ZIP1     : ZIPHead;
Procedure GET_ZIP_ENTRY;
begin
  FillChar(ZIP1,SizeOf(ZIPHead),#0); Move (BUFF[C+1],ZIPId,2);
  if ZIPId > 0 then
    begin
      Move (BUFF[C+1],ZIP1,SizeOf(ZIPHead));
      Inc (C,43); SNAME := '';
      With ZIP1 do
        begin
          Move (BUFF[C],SNAME[1],FileNameLen); SNAME[0] := Chr(FileNameLen);
          FSize := CompSize;
        end;
    end;
end;  { GET_ZIP_ENTRY }

Procedure DO_ZIP (FN : String);
Const CFHS : String[4] = 'PK'#01#02;          { CENTRAL_File_HEADER_SIGNATURE }
      ECDS : String[4] = 'PK'#05#06;        { end_CENTRAL_DIRECTORY_SIGNATURE }
Var S4     : String[4];
    FOUND  : Boolean;
    QUIT   : Boolean;                            { "end" sentinel encountered }
begin
--- GOMail v1.1 [DEMO] 03-09-93
 * Origin: The Private Reserve - Phoenix, AZ (602) 997-9323 (1:114/151)
<<<>>>


Date: 03-23-93 (22:30)              Number: 16806 of 16859 (Echo)
  To: EDDIE BRAITER                 Refer#: NONE
From: MIKE COPELAND                   Read: NO
Subj: FORMAT VIEWER - PART 2 of     Status: PUBLIC MESSAGE
Conf: F-PASCAL (1221)            Read Type: GENERAL (+)

(**************************** ARC Files Processing ***************************)
Type ARCHead = Record
                 ARCMark   : Char;
                 ARCVer    : Byte;
                 FN        : Array[1..13] of Char;
                 CompSize  : LongInt;
                 Dos_DT    : LongInt;
                 CRC       : Word;
                 UCompSize : LongInt;
               end;
Const ARCFlag : Char = #26;                                        { ARC mark }
Var WLV   : LongInt;                               { Working LongInt Variable }
    ARC1  : ARCHead;
    QUIT  : Boolean;                             { "end" sentinel encountered }

Procedure GET_ARC_ENTRY;
begin
  FillChar(ARC1,SizeOf(ARCHead),#0); L := SizeOf(ARCHead);
  Seek (F,C); BlockRead (F,BUFF,L,RES);
  Move (BUFF[1],ARC1,L);
  With ARC1 do
    if (ARCMark = ARCFlag) and (ARCVer > 0) then
      begin
        SNAME := ''; I := 1;
        While FN[I] <> #0 do
          begin
            SNAME := SNAME+FN[I]; Inc(I)
          end;
        WLV := (Dos_DT Shr 16)+(Dos_DT Shl 16);              { flip Date/Time }
        FSize := CompSize;
      end;
    QUIT := ARC1.ARCVer <= 0;
end;  { GET_ARC_ENTRY }

Procedure DO_ARC (FN : String);
begin
  Assign (F,FN); Reset (F,1); C := 0;
  Repeat
    GET_ARC_ENTRY;
    if not QUIT then
      begin
        Inc (WPX); New(SW[WPX]);       { store Filename info in dynamic Array }
        With SW[WPX]^ do
          begin
            FSplit (SNAME,DIR,FNAME,EXT); F := FNAME; E := Copy(EXT+'    ',1,4)
            SIZE := ARC1.UCompSize; RType := 4;                   { comp File }
            D_T := WLV; ANUM := ADX; VNUM := VDX;
            ADD_CNAME;
          end;
        Inc (CCT); SSL; Inc (ARCS[ADX]^.COUNT)
      end;
    Inc (C,FSize+SizeOf(ARCHead))
  Until QUIT;
  Close (F);
end;  { DO_ARC }

(************************* LZH Files Processing ******************************)
Type LZHHead = Record
                 HSize       : Byte;
                 Fill1       : Byte;
                 Method      : Array[1..5] of Char;
                 CompSize    : LongInt;
                 UCompSize   : LongInt;
                 Dos_DT      : LongInt;
                 Fill2       : Word;
                 FileNameLen : Byte;
                 FileName    : Array[1..12] of Char;
               end;

Var LZH1     : LZHHead;

Procedure GET_LZH_ENTRY;
begin
  FillChar(LZH1,SizeOf(LZHHead),#0); FillChar (DT,SizeOf(DT),#0);
  L := SizeOf(LZHHead);
  Seek (F,C); BlockRead (F,BUFF,L,RES);
  Move (BUFF[1],LZH1,L);
  With LZH1 do
    if HSize > 0 then
      begin
        Move (FileNameLen,SNAME,FileNameLen+1);
        UnPackTime (Dos_DT,DT);
        FSize := CompSize;
      end
    else QUIT := True
end;  { GET_LZH_ENTRY }

Procedure DO_LZH (FN : String);
begin
  Assign (F,FN); Reset (F,1);
  FSize := FileSize(F); C := 0; QUIT := False;
  Repeat
    GET_LZH_ENTRY;
    if not QUIT then
      begin
        Inc (WPX); New(SW[WPX]);       { store Filename info in dynamic Array }
        With SW[WPX]^ do
          begin
            FSplit (SNAME,DIR,FNAME,EXT); F := FNAME; E := Copy(EXT+'    ',1,4)
            SIZE := LZH1.UCompSize;
            RType := 4; ANUM := ADX; VNUM := VDX; D_T := LZH1.Dos_DT;
            ADD_CNAME;
          end;
        Inc (CCT); SSL; Inc (ARCS[ADX]^.COUNT)
      end;
    Inc (C,FSize+LZH1.HSize+2)
  Until QUIT;
  Close (F);
end;  { DO_LZH }

