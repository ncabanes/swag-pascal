

const
      BSize    = 4096;                                      { I/O Buffer Size }
      HMax     = 512;                                   { Header Maximum Size }
      DLM      = #32#179;
      HexDigits: array[0..15] of char = '0123456789ABCDEF';
type
      MEDBUF       = array[1..4096] of char;
var
      DISKNUM      : Word;                     { Disk # - offset to Disk Info }
      WVN          : Word;                                 { Working Volume # }
      DIDX         : Word;                              { Files Display Index }
      VIDX         : Word;                            { Volumes Display Index }
      AIDX         : Word;                           { Archives Display Index }
      CIDX         : Word;                   { Compressed Files Display Index }
      ADX          : Word;                            { comPressed file Index }
      RES          : Word;                                   { Buffer Residue }
      N,P,Q        : Longint;
      ASZ,USZ,FSZ  : LongInt;              { Disk Available, Used, Free sizes }
      SEQNUM       : LongInt;                               { File Sequence # }
      C            : LongInt;                                 { Buffer Offset }
      FSize        : LongInt;                                     { File Size }
      CH, CH1      : char;
      DEVICE       : char;                                      { Disk Device }
      BIN,BOUT,
      BWORK        : ^MEDBUF;
      F            : File;
      SNAME        : String;
      DATE         : string[8];                  { formatted date as YY/MM/DD }
      TIME         : string[5];                  {     "     time as HH:MM    }
      X1,X2,X3,X4,
      X5,X6,X7,X8,
      X9,X10,X11,
      X12          : string;
      DISKNAME     : string[15];
      CMD          : string;                             { DOS Command string }
      INDENT       : string;                        { Report Indention string }
      GARB         : string[6];                        { extraneous device id }
      PRIORAN      : STR12;                              { Prior Archive Name }
      DirInfo      : SearchRec;                       { File name search type }
      SR           : SearchRec;
      DT           : DateTime;
      PATH         : PathStr;
      DIR          : DirStr;
      FNAME        : NameStr;
      EXT          : ExtStr;
      Regs         : Registers;
      Temp         : String[1];
      BUFF         : array[1..BSize] of Byte;
      IB           : InfoBuffer;
      S            : string[11];
      SNAME        : string[12];

Var I,J,K : LongInt;
(**************************** ARJ Files Processing ***************************)
Type  AHMain = record                                           { ARJ Headers }
                 HeadId  : Word;                                      { 60000 }
                 BHdrSz  : Word;                          { Basic Header Size }
                 FHdrSz  : Byte;                           { File Header Size }
                 AVNo    : Byte;
                 MAVX    : Byte;
                 HostOS  : Byte;
                 Flags   : Byte;
                 SVer    : Byte;
                 FType   : Byte;                 { must be 2 for basic header }
                 Res1    : Byte;
                 DOS_DT  : LongInt;
                 CSize   : LongInt;                         { Compressed Size }
                 OSize   : LongInt;                           { Original Size }
                 SEFP    : LongInt;
                 FSFPos  : Word;
                 SEDLgn  : Word;
                 Res2    : Word;
                 NameDat : array[1..120] of char;       { start of Name, etc. }
                 Res3    : array[1..10] of char;
               end;
Var ARJ1     : AHMain;
procedure GET_ARJ_ENTRY;
begin
  FillChar(ARJ1,SizeOf(AHMain),#0); FillChar(BUFF,BSize,#0);
  Seek (F,C-1); BlockRead(F,BUFF,BSIZE,RES);        { read header into buffer }
  Move (BUFF[1],ARJ1,SizeOf(AHMain)); FSize := 0;
  with ARJ1 do
    begin
      if BHdrSz > 0 then
        begin
          I := 1; SNAME := B40;
          while NameDat[I] > #0 do Inc (I);       { scan for end of file name }
          Move (NameDat[1],SNAME[1],I-1); SNAME[0] := Chr(I-1);
          FSize := BHdrSz+CSize;
          if FType = 2 then FSize := BHdrSz;
          if BHdrSz = 0 then FSize := 0;
        end;  { if }
    end;  { with }
end;  { GET_ARJ_ENTRY }

procedure DO_ARJ (FN : string);
begin
  Assign (F,FN); Reset (F,1); C := 1;
  GET_ARJ_ENTRY;                                        { Process file Header }
  while FSize > 0 do
    begin
      Inc(C,FSize+10); GET_ARJ_ENTRY;                         { get file info }
      if FSize > 0 then
        begin
          with ARJ1 do
            begin
              FSplit (SNAME,DIR,FNAME,EXT);
              if Length(EXT) <= 0 then EXT := '    ';
              while Pos(#00,FNAME) > 0 do FNAME[Pos(#00,FNAME)] := ' ';
              F := Copy(FNAME+B40,1,8); E := Copy(EXT+'    ',1,4);
              SIZE := OSize; RTYPE := 4; D_T := DOS_DT;
              ANUM := ADX; VNUM := VDX;
            end;
        end;  { if }
    end;  { while }
  Close (F);
end;  { DO_ARJ }

