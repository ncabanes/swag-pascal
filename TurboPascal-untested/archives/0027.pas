{
The following code is a cheezy way to read the structures that exist in a
zip file. it does not compress or decompress; it just reads the file
information included in the file. It is not finished and has a bug that has
been compensated for.
Enjoy -some code is not my own, i.e. the structures themselves.
}

USES dos;   {Structure signatures}
CONST  LOCAL   = $04034B50; CENTRAL = $02014B50;END_OF  = $06054B50;
{THE following three structures are found in the zip file }
{A signature WILL tell you WHICH follows the signature in the file}
TYPE ZLOCALtype  = record      { Zip File Header          }
VerReqd        : Word;                       { ..Version reqd to unzip  }
BitFlag        : Word;                       { ..Bit Flag                  }
Method        : Word;                       { ..Compress Method          }
LModTime: Word;                       { ..Last Mod Time          }
LModDate: Word;                       { ..Last Mod Date          }
CRC32        : LongInt;               { ..File CRC                  }
CmpSize : LongInt;               { ..Compressed Size          }
UncmpSz        : LongInt;               { ..Uncompressed Size          }
FNLen        : Word;                       { ..File Name Length          }
EFLen        : Word;                       { ..Extra Field Length          }
end;
 
TYPE ZCENTRALtype  = record     { Zip File Header            }
MadeBy  : Word;
VerReqd        : Word;                        { ..Version reqd to unzip   }
BitFlag        : Word;                        { ..Bit Flag                   
 }
Method        : Word;                        { ..Compress Method           
}
LModTime: Word;                        { ..Last Mod Time            }
LModDate: Word;                        { ..Last Mod Date            }
CRC32        : LongInt;                { ..File CRC                    }
CmpSize : LongInt;                { ..Compressed Size            }
UncmpSz        : LongInt;                { ..Uncompressed Size            }
FNLen        : Word;                        { ..File Name Length           
}
EFLen        : Word;                        { ..Extra Field Length           
 }
end;
zCENTRAL2type=record
DiskNo        : Word;                        { ..Starting Disk Number    }
IFAttr        : Word;                        { ..Internal File Attributes}
EFAttr        : LongInt;                { ..External File Attributes}
LHOff        : LongInt;                { ..Offset of local header  }
end;
 
zENDType = Record               { Directory End Record            }
DiskNo        : Word;                        { ..Number of this disk         
   }
ZDDisk        : Word;                        { ..Disk w/ start of dir    }
ZDETD        : Word;                        { ..Dir ents this disk           
 }
ZDEnts        : Word;                        { ..Total dir ents            }
ZDSize        : LongInt;                { ..Dir size                    }
ZDStart        : LongInt;                { ..Offset to start of Dir  }
CmtLen        : Word;                        { ..Zip Comment Length          
  }
end;
 
VAR zLOCAL   : zLOCALtype;
    zCENTRAL : zCENTRALtype;
    zCENTRAL2: zCENTRAL2type;
    zEND     : zENDtype;
    Fi : File;
    FIlename:String[12];
    temp : array[1..16] of char;
    zSignature: longInt;
    I : integer;
{$I files.inc}   {for opening files easy}
{$I buffer.inc}  {Using a full buffer and fake disk reads}
                 {Nice when you don't know what structure follows}
                 {Fill the buffer and move the info to the structure
                  that fits}
Function num2Hex(L : LongInt) : String;
CONST   HexChar  : Array [0..15] of Char = '0123456789ABCDEF';
VAR   hexs       : string;
      tByte, I,J : byte;
      start      : boolean;
Begin
   HexS:='';
   HexS     := HexChar[(L AND $F0000000) SHR 28] +
               HexChar[(L AND $0F000000) SHR 24] +
               HexChar[(L AND $00F00000) SHR 20] +
               HexChar[(L AND $000F0000) SHR 16] +
               HexChar[(L AND $0000F000) SHR 12] +
               HexChar[(L AND $00000F00) SHR  8] +
               HexChar[(L AND $000000F0) SHR  4] +
               HexChar[(L AND $0000000F)       ];
 Start:=False;                 {init}
 j:=0;
  FOR I:=1 to 8 DO BEGIN        {rid of leading zeros}
    IF hexS[i]<>'0' then Start:=true;
    IF start then BEGIN
       Inc(j,1);
       HexS[j]:=HexS[i];
    END;
  END;
  move(j,hexS[0],1);            {reset string to new size}
  num2Hex:=HexS;
end; {HexLInt}
BEGIN {-==<SKELETON>==-}
  {Open the file if it exists; else OpenFile returns FALSE}
  IF not OpenFile(fi, paramStr(1)) then BEGIN
    Writeln('File ', paramStr(1) ,' not found. Check syntax');
    halt;
  END;
  BRead(Fi, Zsignature, 4); {Fills the buffer}
                            {Moves 4 bytes into zSignature}
  IF (Zsignature<>LOCAL) and (zSignature<>CENTRAL) THEN BEGIN
     Writeln('File ',ParamStr(1),' does not appear to be a ZIP file.');
     HALT
  END;
  WHILE 1<>0  DO BEGIN
  {Read the structure that fits the zSignature}
   IF zSignature=  LOCAL   THEN BEGIN
      Bread(fi,Zlocal,SizeOf(Zlocal) );
      Writeln('LOCAL');
   END;
   IF zSignature=  CENTRAL THEN BEGIN
      Bread(fi,ZCentral,SizeOf(Zlocal) );
      WriteLN('CENTRAL');
   END;
   IF zSignature=  END_OF  THEN BEGIN
      Bread(fi,zEnd,SizeOf(zEnd) );
      WriteLN('END');
   END;
   {ALL three have a signature}
  { Writeln('long test ',num2hex(981347578));}
   Write('Pksignature:        ');
   write(      ((Zsignature and $F0000000) shr 28) );
   write(' ',  ((Zsignature and $0F000000) shr 24) );
   write(' ',  ((Zsignature and $00F00000) shr 20) );
   write(' ',  ((Zsignature and $000F0000) shr 16) );
   write(' ',  ((Zsignature and $0000F000) shr 12) );
   write(' ',  ((Zsignature and $00000F00) shr 8) );
   write(' ',  ((Zsignature and $000000F0) shr 4) );
   write(' ',  ((Zsignature and $0000000F) ) );
   writeln;
   IF (zSignature=Local) THEN BEGIN
     WITH zLOCAL DO BEGIN
      Write('Version Required:   ',(verReqd div 10),'.' );
      writeln(VerReqd mod 10);
      writelN('BitFlag [?]:        ',(bitflag) );
      WriteLN('Method Used:        ',(method)  );
      WriteLN('Last mod Time:      ',num2hex(LmodTime));
      WriteLN('Last mod Date:      ',num2hex(LmodDate));
      WriteLN('CRC32:              ',num2hex(Crc32)); {Correct}
      Writeln('Compressed Size:    ',CmpSize);  {correct}
      WriteLn('Original Size:      ',UnCmpSz);  {correct}
      Writeln('File name Length:   ',FNlen);    {correct}
      Writeln('Extra field Length: ',EFlen);
      BRead(Fi,Filename[1],FNlen);
      move (FNlen,FileName[0],1);     {init the string length}
      WriteLN('FileName:           ',FileName); {correct}
      Bskip(fi,CmpSize);                    {skip the actual zipped part}
     END;
   END;
   IF (zSignature=CENTRAL) THEN BEGIN
     WITH zCENTRAL DO BEGIN
      Writeln('MAde by version :   ',madeBy);
      Write('Version Required:   ',(verReqd div 10),'.' );
      writeln(VerReqd mod 10);
      writelN('BitFlag [?]:        ',(bitflag) );
      WriteLN('Method Used:        ',(method)  );
      WriteLN('Last mod Time:      ',num2hex(LmodTime));
      WriteLN('Last mod Date:      ',num2hex(LmodDate));
      WriteLN('CRC32:              ',num2hex(Crc32));
      Writeln('Compressed Size:    ',CmpSize);
      WriteLn('Original Size:      ',UnCmpSz);
      Writeln('File name Length:   ',FNlen);
      Writeln('Extra field Length: ',EFlen);
     END;
     WITH zCENTRAL2 DO BEGIN
      BSkip(fi,4); {There's blanks?? why?}
      Bread(Fi,zCentral2,SizeOf(zCentral2));
       Writeln('Starting Disk #:      ',DiskNo);
       WriteLN('Internal File Attr:   ',IFAttr);
       WriteLN('External File Attr:   ',EFAttr);
       Writeln('Local header offset:  ',LHoff);
      BRead(Fi,Filename[1],zCENTRAL.FNlen);
      move (zCENTRAL.FNlen,FileName[0],1);
       WriteLN('FileName:           ',FileName);
     END;
   END;
   IF (zSignature=END_OF) THEN BEGIN
     WITH zEND DO BEGIN
       WriteLN('Disk Number:         ',DiskNo);
       WriteLN('Start of directory:  ',ZDDisk);
       WriteLN('Total entries, disk: ',ZDETD);
       WriteLN('Total Entries:       ',ZDEnts);
       WriteLN('Directory Size:      ',ZDSize);
       WriteLN('Directory Offset:    ',ZDStart);
       WriteLN('Zip Comment Length:  ',CmtLen);
       halt;
     END;
   END;
   ReadLN;
   Bread(fi,zSignature,4);               {read next Zsignature}
  END; {WHILE NOT EOF}
  Close(fi);
END.

{ FILES.INC}
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
 

{BUFFER.INC}
CONST zBufSize=8192;
TYPE zBufferType = array[1..zBufSize] of byte;
VAR zBuffer: zBufferType;
    zCurrent: integer;
    nSeen : Word;
PROCEDURE READBUFFER(Var f:file;nRead, Position: integer);
BEGIN
 IF zCurrent=0 then zCurrent:=1;
 BlockRead(f,zBuffer[Position],nRead,nSeen);
END;

PROCEDURe bREAD(var f: file;var userObj; nRead: integer);
VAR temp:integer;          {^^^^^^^^^^^what ever the user is using!}
BEGIN
 IF zCurrent=0 then ReadBUFFER(F, ZBufsize ,1);  {init the buffer}
 IF zcurrent+nRead>zBufSize THEN BEGIN         {Part Missing??}
    Temp:=ZbufSize+1-zCurrent;                   {Size of whats left in
buffer}
   { Writeln('What is left in the buffer ',temp);}
    move(zBuffer[zCurrent], zBuffer[1], Temp); {move unread to start}
    ReadBUFFER(F, ZBufsize-(Temp) ,Temp);     {total minus what's left}
    zCurrent:=1;                              {at position end of temp}
    move(zBuffer[zCurrent],userOBJ,nREAD);
 END
 else BEGIN
 move(ZBuffer[zCurrent],UserOBJ,nREad);
 zCurrent:=zCurrent+nRead;
 END;
END;
 
PROCEDURe bSkip(var f: file; nRead: integer);
VAR temp:integer;  {SKIPS A PART OF THE BUFFER}
BEGIN
 IF zCurrent=0 then ReadBUFFER(F, ZBufsize ,1);  {init the buffer}
 IF nRead>zBufSize then BEGIN
    Seek(f,FilePos(f)+nRead-(ZbufSize+1-zCurrent));
    {Remeber there may still be bytes ALREADY read in the buffer}
    {You need not skip what's already there}
    {Just seek to position - already read}
    zCurrent:=0;
 END
 ELSE
 IF zcurrent+nRead>zBufSize THEN BEGIN         {Part Missing??}
    Temp:=ZbufSize+1-zCurrent;                 {Size of whats left in
buffer}
    move(zBuffer[zCurrent], zBuffer[1], Temp);    {move unread to start}
    ReadBUFFER(F, ZBufsize-(Temp) ,Temp);{refill} {total minus what's left}
    zCurrent:=1+temp;                             {at position end of temp}
 END
 ELSE zCurrent:=zCurrent+nRead;
END;
