 {***************************************************************************}
 {                                                                           }
 {   LFN  -  Free unit for long filename support.  100% asm code.            }
 {           All functions return an error code                              }
 {           and also store it in DosError in the Dos unit.                  }
 {           A demo program is at the end of this unit.                      }
 {                                                                           }
 {   Author: Pino Navato                                                     }
 {   E-Mail: pnavato@poboxes.com                                             }
 {           pnavato@geocities.com                                           }
 {           Pino Navato, 2:335/225.18  (The Bits BBS, Fidonet)              }
 {   WWW:    www.poboxes.com/pnavato                                         }
 {           (currently forwards to  www.geocities.com/SiliconValley/4421)   }
 {                                                                           }
 {   Advertisement:                                                          }
 {     Do you need new CHR fonts for the BGI?  Visit my home page!           }
 {                                                                           }
 {   Acknowledgments:                                                        }
 {     - This unit is partially based on the LDOS unit by Arne de Bruijn.    }
 {     - Technical info obtained from the Ralf Brown's Interrupt List.       }
 {                                                                           }
 {***************************************************************************}


Unit LFN;

interface

uses DOS;


type QuadWord   = array[0..3] of word;  { For W95 file date/time }

     LSearchRec = record
                     Attr            : LongInt;
                     CreationTime,
                     LastAccessTime,
                     LastModTime     : QuadWord; { See below for conversion }
                     HiSize,
                     LoSize          : LongInt;
                     reserved        : array[0..7] of byte;
                     name            : array[0..259] of char;
                     ShortName       : array[0..13] of char; { Only if longname exists }
                     Handle          : word;
                  end;


function LFileSystemInfo(RootName: PChar; FSName: PChar; FSNameBufSize: word;
                         var Flags, MaxFileNameLen, MaxPathLen: word): word;
{ Return File System Information, for FSName 32 bytes should be sufficient }
{ Rootname is, for example, 'C:\' }

{ WARNING: due to a bug in Windows95, this function returns MaxPathLen = 0 }
{          for CD-ROMs!                                                    }

{ Bitfields for long filename volume information flags:       }
{ Bit(s)  Description                                         }
{  0      searches are case sensitive                         }
{  1      preserves case in directory entries                 }
{  2      uses Unicode characters in file and directory names }
{  3-13   reserved (0)                                        }
{  14     supports DOS long filename functions                }
{  15     volume is compressed                                }


function LFindFirst(FileSpec: PChar; Attr: word; var SRec: LSearchRec): word;
{ Search for files }

function LFindNext(var SRec: LSearchRec): word;
{ Find next file }

function LFindClose(SRec: LSearchRec): word;
{ Free search handle }


function LGetTrueName(FileName, TrueName: PChar): word;
{ Return complete path, in buffer TrueName (261 bytes) }

function LGetShortName(FileName, ShortName: PChar): word;
{ Return complete short name/path for input file/path in buffer ShortName (128 bytes) }

function LGetLongName(FileName, LongName: PChar): word;
{ Return complete long name/path for input file/path in buffer LongName (261 bytes) }


function LRename(OldName, NewName: PChar): word;
{ Rename file }

function LErase(Filename: PChar): word;
{ Erase file }

function LMultiErase(FileMask: PChar; SearchAttr, MustMatchAttr: byte): word;
{ Erase files (wildcards allowed) }


function LMkDir(Dir: PChar): word;
{ Make directory }

function LRmDir(Dir: PChar): word;
{ Remove directory }

function LChDir(Dir: PChar): word;
{ Change current directory }

function LGetDir(Drive: byte; Dir: PChar): word;
{ Get current directory (no drive letter nor leading backslash).
  Drive: 0=current, 1=A: etc. }


function LGetFAttr(Filename: PChar; var Attr: word): word;
{ Get file attributes}

function LSetFAttr(Filename: PChar; Attr: word): word;
{ Set file attributes }

function LGetFTime(FileName: PChar; var FTime: LongInt): word;
{ Get last-write date/time }

function LSetFTime(FileName: PChar; FTime: LongInt): word;
{ Set last-write date/time }

function LGetCreationFTime(FileName: PChar; var CFTime: LongInt): word;
{ Get creation file date/time }

function LSetCreationFTime(FileName: PChar; CFTime: LongInt): word;
{ Set creation file date/time }

function LGetLastAccessFDate(FileName: PChar; var LAFDate: LongInt): word;
{ Get last-access file date }

function LSetLastAccessFDate(FileName: PChar; LAFDate: LongInt): word;
{ Set last-access file date }

function LTimeToDos(LTime: QuadWord; var DosTime: LongInt): word;
{ Convert 64-bit W95 file date/time to local DOS date/time (packed format) }

function LUnpackTime(LTime: QuadWord; var DT: DateTime): word;
{ Convert 64-bit time to date/time record }


function LGetPhysicalFSize(FileName: PChar; var Size: LongInt): word;
{ Get physical size of compressed file }



implementation

function LFileSystemInfo(RootName: PChar; FSName: PChar; FSNameBufSize: word;
                         var Flags, MaxFileNameLen, MaxPathLen: word): word; assembler;
{ Return File System Information }
{ WARNING: due to a bug in Windows95, this function returns MaxPathLen = 0 }
{          for CD-ROMs!                                                    }
asm
  push  ds
  lds   dx,RootName
  les   di,FSName
  mov   cx,FSNameBufSize
  mov   ax,71A0h
  stc
  int   21h
  lds   di,Flags
  mov   ds:[di],bx
  lds   di,MaxFileNameLen
  mov   ds:[di],cx
  lds   di,MaxPathLen
  mov   ds:[di],dx
  pop   ds
  sbb   bx,bx      { if CF=1 then BX:=$FFFF else BX:=0 }
  and   ax,bx
  mov   [DosError],ax
end;



function LFindFirst(FileSpec: PChar; Attr: word; var SRec: LSearchRec): word; assembler;
{ Search for files }
asm
  push  ds
  lds   dx,FileSpec
  mov   cx,Attr
  les   di,SRec
  xor   si,si
  mov   ax,714Eh
  stc
  int   21h
  pop   ds
  mov   es:[di].LSearchRec.Handle,ax
  sbb   bx,bx
  and   ax,bx
  mov   [DosError],ax
end;


function LFindNext(var SRec: LSearchRec): word; assembler;
{ Find next file }
asm
  les   di,SRec
  mov   bx,es:[di].LSearchRec.Handle
  xor   si,si
  mov   ax,714Fh
  stc
  int   21h
  sbb   bx,bx
  and   ax,bx
  mov   [DosError],ax
end;


function LFindClose(SRec: LSearchRec): word; assembler;
{ Free search handle }
asm
  les   di,SRec
  mov   bx,es:[di].LSearchRec.Handle
  mov   ax,71A1h
  stc
  int   21h
  sbb   bx,bx
  and   ax,bx
  mov   [DosError],ax
end;



function LGetTrueName(FileName, TrueName: PChar): word; assembler;
{ Return complete path, in buffer TrueName (261 bytes) }
asm
  push  ds
  lds   si,FileName
  les   di,TrueName
  mov   ax,7160h
  xor   cx,cx
  stc
  int   21h
  pop   ds
  sbb   bx,bx
  and   ax,bx
  mov   [DosError],ax
end;


function LGetShortName(FileName, ShortName: PChar): word; assembler;
{ Return complete short name/path for input file/path in buffer ShortName (128 bytes) }
asm
  push  ds
  lds   si,FileName
  les   di,ShortName
  mov   ax,7160h
  mov   cx,1    { Return a path containing true path for a SUBSTed drive letter }
  stc
  int   21h
  pop   ds
  sbb   bx,bx
  and   ax,bx
  mov   [DosError],ax
end;


function LGetLongName(FileName, LongName: PChar): word; assembler;
{ Return complete long name/path for input file/path in buffer LongName (261 bytes) }
asm
  push  ds
  lds   si,FileName
  les   di,LongName
  mov   ax,7160h
  mov   cx,2    { Return a path containing true path for a SUBSTed drive letter }
  stc
  int   21h
  pop   ds
  sbb   bx,bx
  and   ax,bx
  mov   [DosError],ax
end;



function LRename(OldName, NewName: PChar): word; assembler;
asm
  push  ds
  lds   dx,OldName
  les   di,NewName
  mov   ax,7156h
  stc
  int   21h
  pop   ds
  sbb   bx,bx
  and   ax,bx
  mov   [DosError],ax
end;


function LErase(Filename: PChar): word; assembler;
asm
  push  ds
  lds   dx,Filename
  xor   si,si        { Wildcards not allowed }
  mov   ax,7141h
  stc
  int   21h
  pop   ds
  sbb   bx,bx
  and   ax,bx
  mov   [DosError],ax
end;


function LMultiErase(FileMask: PChar; SearchAttr, MustMatchAttr: byte): word; assembler;
{ Erase files (wildcards allowed) }
asm
  push  ds
  lds   dx,FileMask
  mov   si,1        { Wildcards allowed }
  mov   cl,[SearchAttr]
  mov   ch,[MustMatchAttr]
  mov   ax,7141h
  stc
  int   21h
  pop   ds
  sbb   bx,bx
  and   ax,bx
  mov   [DosError],ax
end;



function LMkDir(Dir: PChar): word; assembler;
asm
  push  ds
  lds   dx,Dir
  mov   ax,7139h
  stc
  int   21h
  pop   ds
  sbb   bx,bx
  and   ax,bx
  mov   [DosError],ax
end;


function LRmDir(Dir: PChar): word; assembler;
asm
  push  ds
  lds   dx,Dir
  mov   ax,713Ah
  stc
  int   21h
  pop   ds
  sbb   bx,bx
  and   ax,bx
  mov   [DosError],ax
end;


function LChDir(Dir: PChar): word; assembler;
asm
  push  ds
  lds   dx,Dir
  mov   ax,713Bh
  int   21h
  pop   ds
  sbb   bx,bx
  and   ax,bx
  mov   [DosError],ax
end;


function LGetDir(Drive:byte; Dir: PChar): word; assembler;
asm
  push  ds
  mov   dl,[Drive]
  lds   si,Dir
  mov   ax,7147h
  stc
  int   21h
  pop   ds
  sbb   bx,bx
  and   ax,bx
  mov   [DosError],ax
end;



function LGetFAttr(Filename: PChar; var Attr: word): word; assembler;
asm
  push  ds
  lds   dx,Filename
  mov   ax,7143h
  xor   bl,bl
  stc
  int   21h
  lds   di,Attr
  mov   ds:[di],cx
  pop   ds
  sbb   bx,bx
  and   ax,bx
  mov   [DosError],ax
end;


function LSetFAttr(Filename: PChar; Attr: word): word; assembler;
asm
  push  ds
  lds   dx,Filename
  mov   cx,[Attr]
  mov   ax,7143h
  mov   bl,1
  stc
  int   21h
  pop   ds
  sbb   bx,bx
  and   ax,bx
  mov   [DosError],ax
end;


function LGetFTime(FileName: PChar; var FTime: LongInt): word; assembler;
{ Get last-write date/time }
asm
  push  ds
  lds   dx,Filename
  mov   ax,7143h
  mov   bl,4
  stc
  int   21h
  lds   bx,FTime
  mov   ds:[bx],cx
  mov   ds:[bx+2],di
  pop   ds
  sbb   bx,bx
  and   ax,bx
  mov   [DosError],ax
end;


function LSetFTime(FileName: PChar; FTime: LongInt): word; assembler;
{ Set last-write date/time }
asm
  push  ds
  lds   dx,Filename
  mov   cx,word ptr [FTime]
  mov   di,word ptr [FTime+2]
  mov   ax,7143h
  mov   bl,3
  stc
  int   21h
  pop   ds
  sbb   bx,bx
  and   ax,bx
  mov   [DosError],ax
end;


function LGetCreationFTime(FileName: PChar; var CFTime: LongInt): word; assembler;
{ Get creation file date/time }
asm
  push  ds
  lds   dx,Filename
  mov   ax,7143h
  mov   bl,8
  stc
  int   21h
  lds   bx,CFTime
  mov   ds:[bx],cx
  mov   ds:[bx+2],di
  pop   ds
  sbb   bx,bx
  and   ax,bx
  mov   [DosError],ax
end;


function LSetCreationFTime(FileName: PChar; CFTime: LongInt): word; assembler;
{ Set creation file date/time }
asm
  push  ds
  lds   dx,Filename
  mov   cx,word ptr [CFTime]
  mov   di,word ptr [CFTime+2]
  xor   si,si
  mov   ax,7143h
  mov   bl,7
  stc
  int   21h
  pop   ds
  sbb   bx,bx
  and   ax,bx
  mov   [DosError],ax
end;


function LGetLastAccessFDate(FileName: PChar; var LAFDate: LongInt): word; assembler;
{ Get last-access file date }
asm
  push  ds
  lds   dx,Filename
  mov   ax,7143h
  mov   bl,6
  stc
  int   21h
  lds   bx,LAFDate
  mov   ds:[bx],cx
  mov   ds:[bx+2],di
  pop   ds
  sbb   bx,bx
  and   ax,bx
  mov   [DosError],ax
end;


function LSetLastAccessFDate(FileName: PChar; LAFDate: LongInt): word; assembler;
{ Set last-access file date }
asm
  push  ds
  lds   dx,Filename
  mov   di,word ptr [LAFDate+2]
  mov   ax,7143h
  mov   bl,5
  stc
  int   21h
  pop   ds
  sbb   bx,bx
  and   ax,bx
  mov   [DosError],ax
end;


function LTimeToDos(LTime: QuadWord; var DosTime: LongInt): word; assembler;
{ Convert 64-bit W95 file date/time to local DOS date/time (packed format) }
asm
  push  ds
  lds   si,LTime
  mov   ax,71A7h
  xor   bl,bl
  stc
  int   21h
  lds   di,DosTime
  mov   ds:[di],cx
  mov   ds:[di+2],dx
  pop   ds
  sbb   bx,bx
  and   ax,bx
  mov   [DosError],ax
end;


function LUnpackTime(LTime: QuadWord; var DT: DateTime): word; assembler;
{ Convert 64-bit time to date/time record }
var DosTime : LongInt;
asm
  les   di,Ltime
  push  es
  push  di
  lea   di,DosTime
  push  ss
  push  di
  push  cs                    { PUSH CS + CALL NEAR is faster than CALL FAR }
  call  near ptr LTimeToDos   { LTimeToDos(Ltime, DosTime) }
  jc    @end
  push  word ptr [DosTime+2]
  push  word ptr [DosTime]
  les   di,DT
  push  es
  push  di
  call  UnpackTime            { UnpackTime(DosTime, DT) }
  xor   ax,ax
@end:
end;



function LGetPhysicalFSize(FileName: PChar; var Size: LongInt): word; assembler;
{ Get physical size of compressed file }
asm
  push  ds
  lds   dx,Filename
  mov   ax,7143h
  mov   bl,2
  stc
  int   21h
  lds   bx,Size
  mov   ds:[bx],ax
  mov   ds:[bx+2],dx
  pop   ds
  sbb   bx,bx
  and   ax,bx
  mov   [DosError],ax
end;


end.



{***************************************************************************}
{***************************************************************************}

Program LFN_demo;
{$M 4096,0,0}
{$X+}

uses LFN, strings, DOS;

type string2 = string[2];

const  RootName    = 'C:\';
       TempDirName = 'Temporary Directory';
       TempFile0   = 'temp$$$$.tmp';
       TempFile1   = 'Temporary File.tmp';
       TempFile2   = 'Another Temporary File.tmp';
       TempFile3   = 'Yet another temporary file.tmp';

var Buf        : array[0..1023] of char;
    W1, W2, W3 : word;
    f          : text;
    SRec       : LSearchRec;
    DT         : DateTime;
    LN, SN     : Pchar;
    size       : LongInt;
    PDT        : LongInt;  { Packed-format file date/time }


function Str0(B: byte): string2;  { Put a 0 in front of numbers <10 }
begin
   Str0[0] := #2;
   Str0[1] := char(B div 10 + 48);
   Str0[2] := char(B mod 10 + 48);
end;


begin { Main }
    writeln;
    writeln;
    if LFileSystemInfo(RootName, Buf, 32, W1, W2, W3) <> 0 then
       begin
          writeln('Long names not supported!');
          halt
       end;

    if Buf[0] = #0 then                         { This extra check is necessary    }
       begin                                    { if you run the demo from the IDE }
          writeln('Long names not supported!'); { under MS-DOS v6.22               }
          halt                                  { I don't know why.                }
       end;

    writeln('File System name: ', Buf, '   Max Filename Len: ', W2,
            '   Max Path Len: ', W3);
    writeln('Flags:');
    writeln('   Searches are case sensitive = ', W1 and 1 = 1);
    writeln('   Preserves case in directory entries = ', W1 and 2 = 2);
    writeln('   Uses Unicode chars for names = ', W1 and 4 = 4);
    writeln('   Support LFN functions = ', W1 and $4000 = $4000);
    writeln('   Volume is compressed = ', W1 and $8000 = $8000);
    writeln('   Reserved fields = ', W1 and $3FF8);

    writeln;
    writeln('Press ENTER to continue');
    readln;

    writeln('Creating temporary directory.');
    LMkDir(TempDirName);
    writeln('Changing default directory.');
    LChDir(TempDirName);
    write('Default directory is now  ');
    LGetDir(0, Buf);
    writeln(Buf);

    writeln;
    writeln('Creating temporary file #1.');
    assign(f, TempFile0);
    rewrite(f);
    writeln(f, TempFile1);
    close(f);
    writeln('Renaming file #1 to long name.');
    LRename(TempFile0, TempFile1);

    writeln('Creating temporary file #2.');
    rewrite(f);
    writeln(f, TempFile2);
    close(f);
    writeln('Renaming file #2 to long name.');
    LRename(TempFile0, TempFile2);

    writeln('Creating temporary file #3.');
    rewrite(f);
    writeln(f, TempFile3);
    close(f);
    writeln('Renaming file #3 to long name.');
    LRename(TempFile0, TempFile3);

    writeln;
    writeln;
    writeln('Directory of ', Buf);
    writeln;
    LFindFirst('*', AnyFile, SRec);
    while DosError = 0 do
       begin
          LUnpackTime(SRec.LastModTime, DT);
          if SRec.ShortName[0] = #0 then
             begin
                SN := @SRec.name;
                LN := nil
             end
          else
             begin
                SN := @SRec.shortname;
                LN := @SRec.name
             end;
          with DT do                              { Italian-style output }
             WriteLn(SN, '':13-StrLen(SN), SRec.LoSize:9, ' ',
                     Day:3, '/', Str0(Month), '/', Year, ' ',
                     Hour:2, '.', Str0(Min), ' ', LN);
          LFindNext(SRec)
       end;
    LFindClose(SRec);

    writeln;
    writeln('Press ENTER to continue');
    readln;

    writeln('True name of ', SN, ' =');
    LGetTrueName(SN, Buf);
    writeln('   ', Buf);
    writeln('Short name of ', Tempfile3, ' =');
    LGetShortName(TempFile3, Buf);
    writeln('   ', Buf);
    writeln('Long name of ', Buf, ' =');
    LGetLongName(Buf, Buf);
    writeln('   ', Buf);

    if LGetPhysicalFSize(SN, size) <> 0 then
       writeln('Physical size of ', SN, ' = ', size, ' bytes.');

    writeln;
    with DT do
       begin
          Day:= 1;
          Month := 2;
          Year := 1997;
          Hour := 0;
          Min := 1;
          Sec := 2
       end;
    PackTime(DT, PDT);
    LSetCreationFTime(TempFile1, PDT);
    write('Creation date/time of ', TempFile1, ' is now  ');
    LGetCreationFTime(TempFile1, PDT);
    Unpacktime(PDT, DT);
    with DT do                              { Italian-style output }
       WriteLn(Day:3, '/', Str0(Month), '/', Year, ' ',
               Hour:2, '.', Str0(Min), '.', Str0(sec));

    with DT do
       begin
          Day:= 3;
          Month := 4;
          Year := 1997;
          Hour := 4;
          Min := 5;
          Sec := 6
       end;
    PackTime(DT, PDT);
    LSetFTime(TempFile1, PDT);
    write('Last-write date/time of ', TempFile1, ' is now');
    LGetFTime(TempFile1, PDT);
    Unpacktime(PDT, DT);
    with DT do                              { Italian-style output }
       WriteLn(Day:3, '/', Str0(Month), '/', Year, ' ',
               Hour:2, '.', Str0(Min), '.', Str0(sec));

    with DT do
       begin
          Day:= 5;
          Month := 6;
          Year := 1997;
       end;
    PackTime(DT, PDT);
    LSetLastAccessFDate(TempFile1, PDT);
    write('Last-access date of ', TempFile1, ' is now    ');
    LGetLastAccessFDate(TempFile1, PDT);
    Unpacktime(PDT, DT);
    with DT do                              { Italian-style output }
       WriteLn(Day:3, '/', Str0(Month), '/', Year);

    writeln;
    writeln('Setting the hidden file-attribute of ', TempFile1);
    LSetFAttr(TempFile1, archive + hidden);
    write('Checking... ');
    LGetFAttr(TempFile1, W1);
    if W1 = archive + hidden then writeln('OK')
    else
       begin
          writeln('Error!');
          halt
       end;

    writeln;
    writeln('Deleting ', TempFile1);
    LErase(TempFile1);

    writeln('Deleting *.tmp');
    LMultiErase('*.tmp', Archive, Archive);
    LChDir('..');
    writeln('Deleting temporary directory.');
    LRmDir(TempDirName);

    writeln;
    writeln('Done.')
end.
