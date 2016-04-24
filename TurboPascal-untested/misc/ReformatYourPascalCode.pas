(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0139.PAS
  Description: Reformat Your Pascal Code!
  Author: CAMERON CLARK
  Date: 05-26-95  23:03
*)

{
The following 3 messages will include two units [files,freebuff] and one
driver program [CTP]. The purpose of CTP is to reformate you source code's
case use, Exampe:   change 'writeln' to 'WriteLn'. It includes all reserved
words.

FREEBUFF is where most of the speed increase comes from. It is a free
read buffer styled much like blockRead and BlockWrite. It does the job of a
disk cache by NOT writing until the write buffer is full, and NOT reading
until the read buffer is empty. It can be used for any program in place of
blockread&write where small pieces of information need to be extracted.
    remeber memory is fast, drives are slow.

    CTP still needs some optimizing [and inclusion of the (* *) comments
Words in quotes '' or Comments {  WILL be skipped. If you can speed it up,
re-post the optimized version.
}

UNIT FILES;
INTERFACE
USES DOS;
FUNCTION FileExists(FileName: String): Boolean;
FUNCTION OpenFile(VAR f: file; fileName:string): Boolean;
FUNCTION FileExistsWild(FileName: String): Boolean;

IMPLEMENTATION

FUNCTION FileExists(FileName: String): Boolean;
VAR   F: file;
begin
  {$I-}
  Assign(F, FileName);
  Reset(F);
  Close(F);
  {$I+}
  FileExists:=(IOResult = 0) and (FileName <> '')
 end;  { FileExists }
FUNCTION OpenFile(VAR f: file; fileName:string): Boolean;
BEGIN
   IF fileExists(FileName) then BEGIN
      Assign(f,filename);
      Reset(f,1);
      Openfile:=True;
   END
   ELSE OpenFile:=False;
END;
 
FUNCTION FileExistsWild(FileName: String): Boolean;
VAR   Fil: SearchRec;
begin
  FindFirst(FileName,anyFile,Fil);
  FileExistsWild:=(DosError=0) and (FileName <> '');
end;  { FileExists }
 
BEGIN
END.

{UNIT FREEBUFF}
{12/7/94}
{v4.0 ... Changing into a unit }
Unit FreeBuff;
INTERFACE
VAR TrueFileEnd : Boolean;
PROCEDURE B_Read( var F: file; var userObject;
                  ObjSize: Word; VAR bytesREAD: Word);
PROCEDURE B_Write( var FW: file; var userObject; ObjSize: Word);
PROCEDURE B_Skip( var F: File; SkipSize: Integer);
            {user may skip any size}
PROCEDURE InitBuffers(Var F: File; Var FW : File);
PROCEDURE FlushWRITEBuffer(Var FW : File);
IMPLEMENTATION
CONST rBufSize=8192;                        {buffer size for B_read}
      wBufSize=8192;                          {buffer size for B_write}
VAR rBuffer: array [1..rBufSize] of char; {buffer for B_read}
    rCurrent: word;   {8192 < word max}   {current position in rBuffer}
    rEnd: Integer;                        {Logical end of buffer}
    FileEnd: Boolean;                     {Actual file end}
    wBuffer: array [1..wBufSize] of char; {buffer for B_Write}
    wCurrent: word;                       {current position in wBuffer}
Function WhatsLeft : Word;
BEGIN
  If  rEnd> (rCurrent -1) THEN BEGIN
      WhatsLeft:= rEnd - (rCurrent - 1);  {last position - (Current-1)   }
  END ELSE BEGIN
      WhatsLeft:=0;
  END;
END;
FUNCTION WhatsLeftinWRITE: Word;
BEGIN
   WhatsLeftinWRITE:=wBufSize - (wCurrent - 1);
END;
PROCEDURE  ReadBuffer(Var f: file; Var UserObject;
                      ObjSize: Word; VAR BytesRead: word);
BEGIN
   BLockRead(F,UserObject,ObjSize,BytesRead);
   rEnd:=(rCurrent-1) + BytesRead;
   IF (BytesRead <> ObjSize) Then BEGIN
      FileEnd:=True;
   END;
END;
PROCEDURE WriteBuffer(Var FW: File; var UserObject; ObjSize: word);
VAR wDummy: Word;
BEGIN
     BlockWrite(FW,UserObject,ObjSize,wDummy);
END;
PROCEDURE InitReadBuffer(Var F: File);
VAR Dummy: Word;
BEGIN
   rCurrent:=1;
   ReadBuffer(F,rBuffer[1],rBufSize,Dummy);
END;
PROCEDURE InitWRITEBuffer;
BEGIN
   wCurrent:=1;
END;
PROCEDURE  InitBuffers(Var F: File; Var FW : File);
BEGIN
   FileEnd:=False;
   TrueFileEnd:=False;
   InitReadBuffer(F);
   InitWriteBuffer;
END;
PROCEDURE FlushWRITEBuffer(Var FW : File);
BEGIN
   WriteBuffer(FW, wBuffer[1], wCurrent-1);
   initWriteBuffer;
END;
PROCEDURE B_Read( var F: file; var userObject;
                  ObjSize: Word; VAR bytesREAD:Word);
VAR LeftInBuf: Word;  Temp: Word; BytesMoved: Word;
BEGIN
  LeftInBuf:= WhatsLeft;
  IF  ObjSize < LeftInBuf then BEGIN     {Same case for if FileEnd}
      {CASE 1  MOST COMMON}
      Move(rBuffer[rCurrent], UserObject, ObjSize);
      rCurrent:=rCurrent+ ObjSize;
      BytesRead:=ObjSize;
  END ELSE IF  ObjSize > LeftInBuf then BEGIN
      {CASE 2  SECOND MOST COMMON}
      IF  FileEnd then BEGIN
          LeftInBuf:=WhatsLeft;
          Move(rBuffer[rCurrent], UserObject, LeftInBuf);
          BytesRead:=LeftInBuf;
          TrueFileEnd:=true;
      END ELSE BEGIN
          LeftInBuf:=WhatsLeft;
          BytesMoved:=LeftInBuf;
          Move(rBuffer[rCurrent], rBuffer[1], LeftInBuf);
          rCurrent:=LeftInBuf+1; rEnd:= rBufSize;
          LeftInBuf:=WhatsLeft;
          ReadBuffer(F, rBuffer[rCurrent], LeftInBuf, BytesRead);
          IF  FIleEnd Then BEGIN
              BytesRead:=BytesRead+BytesMoved;
              IF  BytesRead < ObjSize THEN BEGIN
                  move(rBuffer[1],UserObject, BytesRead);
                  TrueFileEnd:=True;
              END ELSE BEGIN
                  move(rBuffer[1],UserObject, ObjSize);
                  rCurrent:=ObjSize+1;
                  BytesRead:=ObjSize;
              END;
          END ELSE BEGIN
              move(rBuffer[1],UserObject, ObjSize);
              BytesRead:=ObjSize;
              rCurrent:=ObjSize+1;
          END;
      END;
  END ELSE IF  ObjSize = LeftInBuf then BEGIN
      {CASE 3 MOST UNCOMMON}
      IF  FileEnd then BEGIN
          move(rBuffer[rCurrent], UserObject, objSize);
          BytesRead:=ObjSize;
          TrueFileEnd:=True;
      END ELSE BEGIN
          move(rBuffer[rCurrent], UserObject, objSize);
          InitReadBuffer(f);
          BytesREad:=ObjSize;
      END;
  END;
END;
PROCEDURE B_Skip( var F: File; SkipSize: Integer); {user may skip any size}
var LeftInBuffer :Word;
BEGIN
   LeftInBuffer:= WhatsLeft;
   IF  LeftInBuffer > SkipSize THEN BEGIN
       Seek(F, FilePos(F) + ( SkipSize - LeftINBuffer));
       InitREADBuffer(F);
   END ELSE BEGIN
       IF  LeftINBuffer = SkipSize THEN BEGIN
           InitREADBuffer(F);
       END ELSE BEGIN
           rCurrent:=rCurrent + SkipSize;
       END;
   END;
END;
PROCEDURE B_Write( var FW: file; var userObject; ObjSize: Word);
var LeftINBuffer: Word;
BEGIN
     LeftInBuffer:=WhatsLeftinWRITE;
     IF ObjSize < LeftInBuffer THEN BEGIN
        move(UserObject, wBuffer[wCurrent], ObjSize);
        wCurrent:=wCurrent+ ObjSize;
     END ELSE BEGIN
         IF  ObjSize=LeftInbuffer THEN BEGIN
             move(UserObject, wBuffer[wCurrent], ObjSize);
             wCurrent := wCurrent + ObjSize;
             FlushWriteBuffer(FW);
         END ELSE BEGIN
             FlushWriteBuffer(FW);
             move(UserObject, wBuffer[wCurrent], ObjSize);
             wCurrent:=wCurrent+ ObjSize;
         END;
     END;
END;
BEGIN
END.

{PROGRAM C-TP-format} {SLOWWWWWWWW}
{$A+,B-,D+,E-,F-,G-,I-,K-,L-,N-,P-,R+,S-,T-,V-,W-,X+,Y-}
{12/07/94 FIXED FreeBuff : and used it as a unit!!!!!!!!!!!!!!!}
{         Passes Dos's comp test for a 200k file }

Uses crt,dos,FREEbuff,FILES;
CONST BufSize=8192;
      ResSize=53;{Words to Reformat}
      {Edit these to fit personal capital & lowerCase mixture preferences}
TYPE  rWords = array[1..ResSize]  OF String;
{Crt,Graph,Graph3,Overlay,Printer,Strings,System,Turbo3,WinAPI,WinCrt
WinDOS,WinPrn,WinProcs,WinTypes ...}
{BOOCOOS of typing!!}
CONST  Reserved      : rWords =(
'ABSOLUTE','AND','ASM','ARRAY','BEGIN','CASE','CONST','CONSTRUTOR',
'DESTRUCTOR','DIV','DO','DOWNTO','ELSE','END','EXPORTS','FILE','FOR',
'FUNCTION','GOTO','IF','IMPLEMENTATION','IN','INHERITED','INLINE',
'INTERFACE','LABEL','LIBRARY','MOD','NIL','NOT','OBJECT','OF','OR','PACKED',
'PROCEDURE','PROGRAM','RECORD','REPEAT','SET','SHL','SHR','STRING','THEN',
'TO','TYPE','UNIT','UNTIL','USES','VAR','WHILE','WriteLN','WITH','XOR');
VAR F,OUTf        : file;
    tB            : array[1..BufSize] of CHAR;
    {I, J          : integer;}
    Quote         : Boolean;   {temp boolean use to skip quoted material}
    Path,Name,Ext : String;    {used for opening input file}
    Look          : SearchRec; {used for opening input file}
    Dummy         : String;    {Built string to search for}
    TB1           : Char;      {Temp B_READ byte}
    tb2           : integer;   {Counter}
    BytesRead     : Word;      {Dummy: not used in logic}
    INPUTsize,                 { used to compare final sizes}
    OUTPUTsize    : LongInt;
    Capitals      : rWords;   {used to capitalize all reserved words for}
                              {Speed efficient ONLY comparison }
PROCEDURE Announce;
BEGIN
  Writeln('C-TP-Format v1.0    coded by    ■Mr. Krinkle■');
  Writeln('Property of Clark Enterprizes.    Sept 5 1994');
  WriteLN;
END;
PROCEDURE NEEDhelp;
BEGIN
  WriteLN('Usage:    CTP [FileName.in] [FileName.out]');
  WriteLN('Example:  CTP Onefile.pas NewOne.pas');
  HALT;
END;
PROCEDURE INITcapitals;
{Make a Capitalized array of reserved word}
VAR I,J :integer;
BEGIN
FOR I:=1 to ResSize DO BEGIN
    Capitals[I][0]:=Reserved[i][0]; {init lengths}
    FOR J:=1 to ORD(Reserved[I][0]) {LENGTH} DO
        Capitals[I][j]:= UPCASE(Reserved[I][J]);
END;
END;
 
FUNCTION Sfind( Name : string; Dum:String): boolean;
VAR k : integer; ch: char;
BEGIN
  IF  Name[0] = Dum[0] THEN BEGIN        {Size Check :Speed Efficient}
      FOR k:=1 To ord(Dum[0]) DO BEGIN   {CHar by CHar comparison}
          IF not ( Name[k] = Dum[k] ) Then BEGIN
             Sfind:=False;               {When FIRST FALSE CASE}
             EXIT;                       {Speed Efficient}
          END;
      END;
  END ELSE BEGIN
    SFINd:=FALSE;                        {Failed Size Check}
    EXIT;
  END;
  SFind:=True;                           {The Two are the Same}
END;
FUNCTION SCANandUPdate(Dummy:String) : String;
{needs to be changed to boyerMoore type search string tech}
VAR J : integer;
    Dummy2 : string;
BEGIN
 Dummy2[0]:=Dummy[0]; {length}
 FOR J:=1 to ord(Dummy[0]) DO Dummy2[J]:=UpCase( Dummy[j] ); {Capitalize}
 
 FOR j:=1 to ResSize DO BEGIN
     IF Sfind(Capitals[j], Dummy2) then BEGIN    {check with Capitals array}
        SCANandUpdate:=Reserved[j];
        exit;
     END;{IF}
 END;
 SCANandUPdate:=Dummy;     {Return original if not found}
END;
BEGIN {MAIN SKELETION}
Announce;
 IF ParamStr(1)='' then NEEdhelp;
 IF ParamStr(2)='' then NEEDhelp;
 IF ParamStr(1)=ParamStr(2) then NEEDhelp;
 Fsplit(ParamStr(1), Path, name, ext);
 If path<>'' then path:=path+'\';    {writeln(path,' ',name,' ',ext);}
FINDFIRST(ParamStr(1), AnyFile, LOOK);
  IF dosError<>0 then NeedHelp;
  IF not OpenFile(F,path+Look.Name) THEN BEGIN
      WriteLN('Unable to open ',Look.Name,' : Halting.'); HALT;
  END;
INITcapitals;
   Assign(OUTf,ParamStr(2));                     {open and write output}
   ReWrite(OUTf,1);                              {NO preExistance check
done}
   WRITeLN('=< C-TP-Formating ',Look.name,' >=');
   InitBuffers(F,OUTf); {MUST Initialize the READ and WRITE buffers}
   b_READ(F,TB1,1,BytesREAD);       {initialize tb1}
   REPEAT
   REPEAT
     IF  (tb1=#39) THEN BEGIN               {ignore initial quote}
         Quote:=FALSE;
         WHILE (not Quote) and (not TrueFileEnd) do BEGIN           
            b_write(OUTf,tb1,1);            {NO need to check for reserved}
            b_read(f, tb1, 1,BytesREAD);
            IF tb1=#39 THEN Quote:=Not Quote;
         END;
         b_write(OUTf,tb1,1);                {write the closing quote}
         b_read(f, tb1, 1,BytesREAD);                  {re-init tb1}
     END else IF  ( tb1 ='{')  THEN BEGIN
         WHILE (tb1<> '}')  and (not TrueFileEnd) do BEGIN           {spit
out info until nex comment}
            b_write(OUTf,tb1,1);            {NO need to check for reserved}
            b_read(f, tb1, 1,BytesREAD);
         END;
         b_write(OUTf,tb1,1);                {write the closing comment}
         b_read(f, tb1, 1,BytesREAD);                  {re-init tb1}
     END;
   UNTIL (tb1 <> #39) and (TB1<> '{') or TrueFileEnd;      {tb1 might be
another Q or C}
        IF (tb1 in ['A'..'Z','a'..'z']) THEN BEGIN      {build String}
           Dummy:='';
           While (tb1 in ['A'..'Z','a'..'z'])  and (not TrueFileEnd) DO
BEGIN      
              Dummy:=Dummy+tb1;
              b_READ(f,tb1,1,BytesREAD);
           END;
           Dummy:=SCANandUPDATE(DUMMY);               {Scan for reserved}
          { gotoXY(1,25);
           CLReol;
           write(Dummy,' '); }
           b_WRITE(OUTf,DUMMY[1],ord(DUMMY[0]));      
        END ELSE BEGIN
             b_write(OUTf,tb1,1);
             b_read(F,tb1,1,BytesREAD);
        END; {IF}
    INC(tb2);
    CASE TB2 of
     1 : BEGIN
         write(#8#8); Write('.');END;
     400 : BEGIN
         write(#8#8);Write('*');END;
     700 : BEGIN
         write(#8#8);Write(#127);END;
     1000 : BEGIN
         write(#8#8);Write(#30);END;
     1300 : BEGIN
         write(#8#8);write(#254);END;
     1600 : tb2:=0;
     END;
   UNTIL TrueFileEnd;
   b_WRite(OUTf,TB1,1);  {hopefully spit out the last char}
   FLushWriteBuffer(OUTf);
   INPUTsize:= FileSize(F);
   OUTPUTsize:= FileSize(OUTf);
   Close(OUTf);
   Close(F);
IF  INPUTsize <> OUTPUTsize THEN BEGIN
    write(#8#8);
    WriteLN('ERROR (1): Finished file sizes do not match.');
END Else BEGIN
    write(#8#8);
    Writeln('Done.');
END;
END.

(*
    The previous sources are to format the Case of you TP code.
    It will skip all words within Quotes '' or Comments {}.

    The two units are FILES and FREEbuff.
    The FREEbuff unit is my attempt to uses disk cache logic in my programs.
    The logic is simple: don't read until read buffer empty
                         don't write until write buffer full.

    To use FREEbuff do the following

    INITbuffer( INfile, OUTfile) [must be opened]
    repeat
      b_read( INfile, buffer[1], sizeOF(buffer), bytesRead);
      b_write( OUTfile, buffer[1], BytesRead);
    until TrueFileEnd;
    FlushWriteBuffer(Outfile);

    set it all up
    Flush empties the write buffer before the file is closed.
    Syntax is very clock to BlockRead&write.

    BytesRead is the amount of bytes actually moved to the Buffer [or object]

    Instead of using blockRead for one byte reading, B_Read will fill the
    buffer with 8192 bytes and then only give the object one byte. This
    is extremely efficient when you only need small part of a file.
*)

