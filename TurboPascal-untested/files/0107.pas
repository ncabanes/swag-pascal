{
Hi,
  here's another contribution - an LFN unit which is actually useful. It
allows working with near-normal TP/TPW commands, transparently on LFN
and non-LFN disks. Enjoy.

Eyal Doron
}

{$IFDEF WINDOWS}
{$N-,V-,W-,G+}
{$ELSE}
{N-,V-,G+}
{$ENDIF}

Unit lfnunit;

{========================================================================}
{ LFNUnit - A long filename support unit for TP6 and TPW1.5.             }
{ Written by Eyal Doron, doron@physics,technion.ac.il, June 1997.        }
{ Released into the public domain.                                       }
{                                                                        }
{ This is a unit to support long filenames in Win95 and WinNT, for use   }
{ in ordinary 16-bit programs in Turbo Pascal 6.0 and Turbo Pascal for   }
{ Windows 1.5. It should be a simple matter to adapt to TP/BP 7 as well. }
{ The unit is built to support LFN if available, and the usual FAT16     }
{ format if not, in a transparent manner, i.e. the programmer should not }
{ worry whether LFN is supported or not, the routines work the same in   }
{ both cases. The unit is not complete, in the sense that not all of the }
{ interrupts are supported, but the main thrust is the enhancement of    }
{ the Turbo Pascal I/O scheme to support LFN in as natural a way as      }
{ possible.                                                              }
{                                                                        }
{ The unit contains three families of procedures and functions:          }
{ 1) Basic LFN API: This is a set of procedures and functions that give  }
{    access to the LFN interrupts: FindFirst/Next/Close, short and long  }
{    names, time, attributes and creation.                               }
{ 2) Service routines. These routines make use of the LFN API to mimic   }
{    the operation of the DOS or WinDos supplied routines, only with LFN }
{    support. I chose to mimic the TP6.0 routines, rather than the TPW   }
{    ones, because I prefer Pascal-type strings to C-type strings, but   }
{    its a simple matter to add these as well. All the routines return   }
{    their error codes inside the DOS/WinDos global "DosError".          }
{ 3) Input-output support. This set of procedures and functions defines  }
{    the paradigm for LFN support in Turbo Pascal. It "rides" on top of  }
{    the usual file variables ("file", "file of" and "text"), and stores }
{    the additional LFN info in the UserData field of the file records.  }
{    The routines have an interface which is similar to the TP ones,     }
{    namely "LFNAssign" is equivalent to "Assign", "LFNRewrite" to       }
{    "Rewrite", and so on. This paradigm enables use of the usual Pascal }
{    I/O scheme and routines with long file names, in an almost          }
{    transparent manner. The differences are:                            }
{    a) Before using a file variable it has to be initialized by calling }
{       LFNNew. After you are done with it, you should call LFNDispose   }
{       to free the allocated memory.                                    }
{    b) You MUST consistently use LFNNew, LFNAssign, LFNRewrite,         }
{       LFNRename and LFNDispose in order to support LFN. The other      }
{       routines are optional, providing error detection and consistent  }
{       error trapping, but the TP equivalents should also work.         }
{    c) LFNReset, LFNRewrite and LFNAppend always accept a RecLen        }
{       parameter, which is optional in Reset and Rewrite and missing in }
{       Append. This is because TP does not support overloading. The     }
{       parameter is ignored for text files and when it is zero.         }
{    d) LFNAppend differs from Append also in that if the file does not  }
{       exist, Append reports a DOS error, while LFNAppend creates it    }
{       using LFNRewrite.                                                }
{    e) LFNFindFirst/LFNFindNext return the name as an AsciiZ string,    }
{       not a Pascal string, even in TP6, for the sake of consistency.   }
{    f) All the routines return the error code in the DosError global    }
{       Dos/WinDos variable, and most of them also return it as a        }
{       functional result. Additionally, the "LFNRuntimeErrors" global   }
{       boolean variable controls the generation of runtime errors.      }
{                                                                        }
{ Comments, bug reports, etc. are welcome.                               }
{========================================================================}


Interface

Uses
{$IFDEF WINDOWS}
  WinDos,WObjects,WinTypes,WinProcs,strings;
{$ELSE}
  Dos,Objects;
{$ENDIF}

const
  ShortPathName = 79;
  LFNRuntimeErrors: boolean = false; { Determines if runtime errors are generated }

  LFNErr_Uninitialized = 120; { LFN routines called before LFNAssign }
  LFNErr_NotAllocated  = 121; { LFN routines called before LFNNew    }
  LFNErr_NotATextFile  = 122; { Appending to a non-text file         }

{$IFDEF WINDOWS}
  ofn_LongNames = $00200000;  { Required to support LFN in the common dialogs. }
                              { OR it into the Flags record of TOpenFilename.  }
{$ENDIF}

type
  ShortPathStr = string[ShortPathName];
{$IFNDEF WINDOWS}
  TSearchRec = SearchRec;
  TDateTime = DateTime;
  PChar = ^Char;
{$ENDIF}

  TLFNSearchRec = record
    Attr         : longint;                      
    Creation     : comp;                     
    LastAccess   : comp;                   
    LastMod      : comp;             
    HighFileSize : longint; { high 32 bits }             
    Size         : longint; { low 32 bits  }              
    Reserved     : comp;                     
    Name         : array[0..259] of char;        
    ShortName    : array[0..13] of char;    
    Handle       : word;                       
  end;
  PLFNSearchRec = ^TLFNSearchRec;
  { Form used for old-style searches, with an embedded TSearchRec }
  TLFNShortSearchRec = record
    Attr         : longint;
    Creation     : comp;                     
    LastAccess   : comp;                   
    LastMod      : comp;             
    HighFileSize : longint;              
    Size         : longint;               
    Reserved     : comp;                     
    Name         : array[0..13] of char;
    SRec         : TSearchRec;
    Filler       : array[1..260-14-sizeof(TSearchRec)] of byte;       
    ShortName    : array[0..13] of char;    
    Handle       : word;                       
  end;
  PLFNShortSearchRec = ^TLFNShortSearchRec;

  { A record to isolate the UserData parameters } 
  TLFNFileParam = record
    Handle     : word;                   { The file handle                  }
    Mode       : word;                   { The file mode                    } 
    Res1       : array[1..28] of byte;   { Everything else up to UserData   }
    { Begin UserData }
    lfname     : PString;                { The long filename in String form }
    plfname    : PChar;                  { The long filename in AsciiZ form }
    TextFile   : boolean;                { Is it a text or binary file      }
    Initialized: boolean;                { Has it been LFNAssigned          }
    Magic      : string[3];              { ID to check LFNNew               }
    Res2       : array[0..1] of byte;    { 2 bytes left in UserData         }
    { End UserData }
    SName      : array[0..79] of char;   { The short filename               }
  end;
  PLFNFileParam = ^TLFNFileParam;

var
  LFNAble: boolean;   { Is LFN supported or not. Upon startup it is determined }
                      { by the OS, but can be switched off later if need be.   }

function LFNToggleSupport(on: boolean): boolean;

{$IFNDEF WINDOWS}
{ I need these to access the Srec.Name field properly }
function PCharOf(var F): Pchar;
function StrPas(P: PChar): string;
{$ENDIF}

function PChar2Pstring(F: Pchar): PString;
function PString2PChar(F: Pstring): PChar;

{ Basic API calls }
function  LFNTimeToDos(var LTime: comp): longint;
function  DosTimeToLFN(var Time: longint; var LTime: comp): word;
function  LGetAttr(Filename: PChar; var Attr: word): word;
function  LRenameFile(FromName,ToName: PChar): word; 
function  LCreateEmpty(fname: PChar): word;
function  LFNFindFirst(filespec: string; attr: word; var S: TLFNSearchRec): word;
function  LFNFindNext(var S: TLFNSearchRec): word;
function  LFNFindClose(var S: TLFNSearchRec): word;
function  LFNShortName(LongName: string): ShortPathStr;
function  LFNLongName(ShortName: ShortPathStr): string;

{ Service routines }
procedure LFNUnpackTime(var LTime: comp; var DT: TDateTime);
function  LFNGetFAttr(var F; var Attr: word): integer;
function  LFNFileExist(fname: string): boolean;
function  LFNFSearch(Path,DirList: string): string;
procedure LFNFSplit(Path: string; Dir,Name,Ext: PString);
function  LFNFExpand(Path: string): string;
procedure CanonicalFname(var S: string);
function  CanonicalFilename(Fname: PChar): Pchar;

{ Interface to the Pascal Input/Output routines }
procedure LFNNew    (var F; IsText: boolean);
function  LFNAssign (var F; name: string): integer;
function  LFNRewrite(var F; RecLen: word): integer;
function  LFNAppend (var F; RecLen: word): integer;
function  LFNReset  (var F; RecLen: word): integer;
function  LFNErase  (var F): integer;
function  LFNClose  (var F): integer;
procedure LFNDispose(var F);
function  LFNRename (var F; NewName: string): integer;


implementation

const
{$IFNDEF WINDOWS}
  faReadOnly      =  ReadOnly;
  faHidden        =  Hidden;
  faSysFile       =  SysFile;                
  faVolumeID      =  VolumeID;
  faDirectory     =  Directory;                
  faArchive       =  Archive;                
  faAnyFile       =  AnyFile;
{$ENDIF}

  LFNMagic = 'LFN';

type
  PSearchRec = ^TSearchRec;
  TByteArray = array[0..$FFF0-1] of char;
  PByteArray = ^TByteArray;

{$IFNDEF WINDOWS}
function PCharOf(var F): Pchar;
{ A very simple function which returns a pointer to its argument. }
{ Its main use is in turning array[...] of char in to PChar, to   }
{ simulate the TPW/TP7/BP7 extended syntax.                       }
begin
  PCharOf:=@F;
end;

function StrPas(P: PChar): string;
var
  i: integer;
  tmp: PString;
begin
  New(tmp); tmp^:=''; if P=Nil then Exit;
  i:=0;
  while (length(tmp^)<256) and (PByteArray(P)^[i]<>#0) do
  begin
    tmp^:=tmp^+PByteArray(P)^[i]; inc(i);
  end;
  StrPas:=tmp^; Dispose(tmp);
end;

function StrLen(P: PChar): integer;
var
  i: integer;
begin
  i:=0;
  if P<>Nil then while (i<$7FFF) and (PByteArray(P)^[i]<>#0) do inc(i);
  StrLen:=i;
end;
{$ENDIF}

function PChar2Pstring(F: Pchar): PString;
{ This routine changes a PChar (AsciiZ) string to a }
{ Pascal-type string, in the same memory location.  }
var
  i,len: integer;
begin
  len:=StrLen(F); if len>255 then len:=255;
  for i:=len downto 1 do PByteArray(F)^[i]:=PByteArray(F)^[i-1];
  F^:=Chr(len);
  PChar2PString:=PString(F);
end;                   { PChar2Pstring }

function PString2PChar(F: Pstring): PChar;
{ This routine changes a Pascal-type string to an }
{ AsciiZ string, in the same memory location.     }
var
  i,len: integer;
begin
  len:=length(F^);
  for i:=1 to len do F^[i-1]:=F^[i]; F^[len]:=#0;
  PString2PChar:=PChar(F);
end;                 { PString2PChar }

{$IFDEF WINDOWS}
function SupportsLFN: boolean;
var
  WinVersion: word;
begin
{  SupportsLFN:=false; Exit;}
  WinVersion := LoWord(GetVersion);
  SupportsLFN:=true;
  If ((Lo(WinVersion) =  3)  and                    {windows 95 first}
      (Hi(WinVersion) < 95)) or                     {version is 3.95 }
      (Lo(WinVersion) <  3)  then SupportsLFN := False;
end;
{$ELSE}
function SupportsLFN: boolean; assembler;
asm
  mov ax, $160a
  int $2f
  cmp ax, 0 
  jne @no         { Not running under Windows   }
  cmp bh, 2
  jle @no         { Major version <3            }
  cmp bh, 4
  jge @yes        { Major version >3            }
  cmp bl, 94
  jle @no         { Major version =3, minor <95 }
@yes:
  mov al, true
  jmp @exit
@no:
  mov al, false
@exit:
end;                 { SupportsLFN }
{$ENDIF}

function LFNToggleSupport(on: boolean): boolean;
{ This routine toggles LFN support on and off, provided }
{ the OS supports it. It returns the previous status.   }
begin
  LFNToggleSupport:=LFNAble;
  LFNAble:=on and SupportsLFN;
end;

{==============================================================}
{ BASIC LFN API CALLS.                                         }
{ This is a set of routines which implement the WIn95 LFN API, }
{ in Turbo Pascal form.                                        }
{==============================================================}

function LFNTimeToDos(var LTime: comp): longint; assembler;
{ Convert 64-bit number of 100ns since 01-01-1601 UTC to local DOS format time}
{ (LTime is var to avoid putting it on the stack) }
asm
  push ds
  lds si,LTime
  xor bl,bl
  mov ax,71a7h
  int 21h
  pop ds
  mov ax,cx
  cmc
  sbb cx,cx
  and ax,cx
  and dx,cx
end;                { LFNTimeToDos }

function DosTimeToLFN(var Time: longint; var LTime: comp): word;
{ Convert DOS time to the 64-bit Win95 format }
var
  DosTime,DosDate: word;
  DT: TDateTime;
begin
  UnpackTime(Time,DT); FillChar(LTime,sizeof(LTime),0);
  with DT do
  begin
    DosTime:=(sec div 2) or (min shl 5) or (hour shl 11);
    DosDate:=day or (Month shl 5) or ((Year-1980) shl 9);
  end;
  asm
    mov ax, $71A7
    mov bl, 1
    mov cx, DosTime
    mov dx, DosDate
    mov bh, 0
    les di, LTime
    int $21
    jnc @1
    mov [DosError],ax
@1:
  end;
  DosTimeToLFN:=DosError;
end;                 { DosTimeToLFN }

function LGetAttr(Filename: PChar; var Attr: word): word; assembler;
{ Get the attributes of a file, PChar syntax }
asm
  push ds
  lds dx,Filename
  mov ax,7143h
  xor bl,bl
  int 21h
  pop ds
  les di,Attr
  mov es:[di],cx
  sbb bx,bx
  and ax,bx
  mov [DosError],ax
end;                      { LGetAttr }

function LFindFirst(FileSpec: pchar; Attr: word; var SRec: TLFNSearchRec): word;
assembler;
{ Search for files }
asm
  push ds
  lds dx,FileSpec
  les di,SRec
  mov cx,Attr
  xor si,si
  mov ax,714eh
  int 21h
  pop ds
  sbb bx,bx
  mov es:[di].TLFNSearchRec.Handle,ax
  and ax,bx
  mov [DosError],ax
end;

function LFindNext(var SRec: TLFNSearchRec): word; assembler;
{ Find next file }
asm
  mov ax,714fh
  xor si,si
  les di,SRec
  mov bx,es:[di].TLFNSearchRec.Handle
  int 21h
  sbb bx,bx
  and ax,bx
  mov [DosError],ax
end;

function LFindClose(var SRec: TLFNSearchRec): word; assembler;
{ Free search handle }
asm
  mov ax,714fh
  mov bx,es:[di].TLFNSearchRec.Handle
  int 21h
  sbb bx,bx
  and ax,bx
  mov [DosError],ax
end;

function LGetShortName(FileName: pchar; Result: pchar): word; assembler;
{ Return complete short name/path for input file/path in buffer }
{ Result (79 bytes) }
asm
  push ds
  lds si,FileName
  les di,Result
  mov ax,7160h
  mov cx,1
  int 21h
  pop ds
  sbb bx,bx
  and ax,bx
  mov [DosError],ax
end;

function LGetLongName(FileName: PChar; Result: PChar): word; assembler;
{ Return complete long name/path for input file/path in buffer }
{ Result (261 bytes) }
asm
  push ds
  lds si,FileName
  les di,Result
  mov ax,7160h
  mov cx,2
  int 21h
  pop ds
  sbb bx,bx
  and ax,bx
  mov [DosError],ax
end;

function LRenameFile(FromName,ToName: PChar): word; assembler;
{ Rename a file, supports long filenames. }
asm
  push ds
  mov ax, $7156
  lds dx, FromName
  les di, ToName
  int $21
  jc @1
  mov ax, 0
@1:
  pop ds
  mov [DosError],ax
end;           { LRenameFile }

function LCreateEmpty(fname: PChar): word; assembler;
{ Create an empty file with the given (long) name. }
asm
  push ds
  mov ax, $716C 
  mov bx, 000010b     { Open long file name for writing }
  mov cx, 0
  mov dx, 10001b      { Open if exists, create of not.  }
  lds si, fname
  mov di, 0
  int $21
  jc @1               { error creating file }
  mov bx, ax          { ok, close it again  }
  mov ah, $3E
  int $21
  jc @1               { error closing file }
  mov ax, 0           { ok, return zero    }
@1:
  pop ds
  mov [DosError],ax
end;                { LCreateEmpty }

{ Pascal-string based interface routines }

function LFNFindFirst(filespec: string; attr: word; var S: TLFNSearchRec): word;
{ Implement the FindFirst procedure. This routine will call the TP }
{ FindFirst if LFN is not supported, and will translate the result }
{ into the TLFNSearchRec variable.                                 }
{ NOTE: Under Win95, the filespec will be checked against both the }
{ long and the short filenames, so an additional check may be      }
{ necessary.                                                       } 
begin
  If LFNAble then
  begin
    filespec := filespec + #0;
    LFindFirst(PChar(@Filespec[1]),Attr,S);
    if (DosError=0) and (S.shortname[0]=#0) then
    begin
      move(S.name,S.shortname,sizeof(S.shortname)-1);
      S.shortname[sizeof(S.shortname)-1]:=#0;
    end;
  end else
  begin
    FillChar(S,sizeof(S),0);
{$IFDEF WINDOWS}
    FileSpec:=FileSpec+#0;
    FindFirst(PChar(@FileSpec[1]),Attr,PLFNShortSearchRec(@S)^.SRec);
{$ELSE}
    FindFirst(FileSpec,Attr,PLFNShortSearchRec(@S)^.SRec);
{$ENDIF}
    if DosError=0 then
    begin
{$IFDEF WINDOWS}
      Move(PLFNShortSearchRec(@S)^.SRec.name,S.Name,13); S.name[13]:=#0;
{$ELSE}
     FillChar(S.Name,14,0);
     Move(PLFNShortSearchRec(@S)^.SRec.name[1],S.Name,
          byte(PLFNShortSearchRec(@S)^.SRec.name[0]));
{$ENDIF}
      DosTimeToLFN(PLFNShortSearchRec(@S)^.SRec.Time,S.LastMod);
      S.Attr:=PLFNShortSearchRec(@S)^.SRec.Attr;
      S.Size:=PLFNShortSearchRec(@S)^.SRec.Size;
    end;
  end;
  LFNFindFirst:=DosError;
end;     { LFNFindFirst }

function LFNFindNext(var S: TLFNSearchRec): word;
{ Implement the FindNext procedure. This routine will call the TP  }
{ FindNext if LFN is not supported, and will translate the result  }
{ into the TLFNSearchRec variable.                                 }
{ NOTE: Under Win95, the filespec will be checked against both the }
{ long and the short filenames, so an additional check may be      }
{ necessary.                                                       } 
begin
  If LFNAble then 
  begin
    LFindNext(S);
    if (DosError=0) and (S.shortname[0]=#0) then
    begin
      move(S.name,S.shortname,sizeof(S.shortname)-1);
      S.shortname[sizeof(S.shortname)-1]:=#0;
    end; 
  end else
  begin
    FindNext(PLFNShortSearchRec(@S)^.SRec);
    if DosError=0 then
    begin
{$IFDEF WINDOWS}
      Move(PLFNShortSearchRec(@S)^.SRec.name,S.Name,13); S.name[13]:=#0;
{$ELSE}
      FillChar(S.Name,14,0);
      Move(PLFNShortSearchRec(@S)^.SRec.name[1],S.Name,
           byte(PLFNShortSearchRec(@S)^.SRec.name[0]));
{$ENDIF}
      DosTimeToLFN(PLFNShortSearchRec(@S)^.SRec.Time,S.LastMod);
      S.Attr:=PLFNShortSearchRec(@S)^.SRec.Attr;
      S.Size:=PLFNShortSearchRec(@S)^.SRec.Size;
    end;
  end;
  LFNFindNext:=DosError;
end;   { LFNFindNext }                                             
                                                 
function LFNFindClose(var S: TLFNSearchRec): word;
{ Close the Win95 TLFNSearchRec structure. if LFN is not suppported, }
{ this routine does nothing.                                         }
begin
  If LFNAble then LFNFindClose:=LFindClose(S)
  else LFNFindClose:=0;
end;  {function}

function LFNShortName(LongName: string): ShortPathStr;
{ Returns the short name of the specified file. If LFN is not }
{ supported, returns the input filename.                      }
var
  P,Q: PChar;
  i,len: integer;
begin
  if not LFNAble then
  begin
    LFNShortName:=LongName; Exit;
  end;
  len:=length(LongName);
  for i:=1 to len do LongName[i-1]:=LongName[i]; LongName[len]:=#0;
  P:=@Longname;
  GetMem(Q,270); Q^:=#0;
  if LGetShortName(P,Q)=0 then
  begin
    if Q^=#0 then LFNShortName:=LongName
    else LFNShortName:=StrPas(Q);
  end else LFNShortName:='';
  FreeMem(Q,270);
end;                     { ShortName }

function LFNLongName(ShortName: ShortPathStr): string;
{ Returns the long name of the specified file. If LFN is not }
{ supported, returns the input filename.                     }
var
  SRec: PLFNSearchRec;
  P: PChar;
  P0,D,N,E: PString;
  i,len: integer;
begin
  LFNLongName:=ShortName; if not LFNAble then Exit;
  len:=length(ShortName); if len=0 then Exit;
  New(D); LFNFSplit(ShortName,D,Nil,Nil);
  for i:=1 to len do ShortName[i-1]:=ShortName[i]; ShortName[len]:=#0;
  GetMem(P0,270); P:=@PByteArray(P0)^[1]; P0^:=''; P^:=#0;
  LGetLongName(PChar(@ShortName),P); PByteArray(P)^[256]:=#0;
  P0^[0]:=Chr(StrLen(P));
  Dispose(D);
  if P^=#0 then LFNLongName:=ShortName
  else LFNLongName:=StrPas(P);
  FreeMem(P0,270);
end;               { LFNLongName }

{====================================================================}
{ DERIVATIVE SERVICE ROUTINES.                                       }
{ This is a set of routines which mimic, as closely as possible, the }
{ equivalent routines in Turbo Pascal, except that they support      }
{ long filenames. In many cases, they are drop-in replacements, but  }
{ some are new.                                                      }
{====================================================================}

procedure LFNUnpackTime(var LTime: comp; var DT: TDateTime);
{ Convert 64-bit time to date/time record }
begin
  UnpackTime(LFNTimeToDos(LTime),DT);
end;

function LFNGetFAttr(var F; var Attr: word): integer;
{ Get the attributes of a file, using its File variable. }
{ The file should have been LFNAssign'ed first. Its not  }
{ strictly required, except for error checking.          }
{ Returns the DOS error code.                            }                      
begin
  LFNGetFAttr:=0; DosError:=0;
  with PLFNFileParam(@F)^ do
    if (Magic<>LFNMagic) or (not Initialized) then
    begin
      DosError:=2; LFNGetFAttr:=2; Exit;
    end;
  GetFAttr(F,Attr); LFNGetFAttr:=DosError;
end;               { LFNGetFAttr }

function LFNFileExist(fname: string): boolean;
{ Returns TRUE if the file exists, and FALSE otherwise. }
var
  fl: file;
  attr,i,len: word;
  P: PChar;
begin
  if fName='' then
  begin
    LFNFileExist:=false; Exit;
  end;
  if LFNAble then
  begin
    len:=length(fname); for i:=1 to len do fname[i-1]:=fname[i];
    fname[len]:=#0; LGetAttr(PChar(@fname),Attr)
  end else
  begin
    Assign(fl,fname); GetFAttr(fl,Attr);
  end;
  LFNFileExist:=(DosError=0);
end;                    { LFNFileExist }

function LFNFSearch(Path,DirList: string): string;
{ Search for a file in a semicolon-delimited list of directories. }
{ This is a drop-in replacement for FSearch (TP6), which I        }
{ personally find more useful than the later FileSearch.          }
var
  i,len,Ind: integer;
  which: PChar;
  tmp: PString;
  found: boolean;
begin
  LFNFSearch:=''; if Path='' then Exit;
  if LFNAble then
  begin
    if (DirList='') and not LFNFileExist(Path) then Exit;
    if DirList='' then
    begin
      LFNFSearch:=Path; Exit;
    end;
    Ind:=1; New(tmp); found:=false;
    while (DirList<>'') and (DirList[1]=';') do delete(DirList,1,1);
    repeat
      tmp^:='';
      while (Ind<=length(DirList)) and (DirList[Ind]<>';') do
      begin
        tmp^:=tmp^+DirList[Ind]; inc(Ind);
      end;
      while (Ind<=length(DirList)) and (DirList[Ind]=';') do inc(Ind);
      if Ind>length(DirList) then Ind:=0 else inc(Ind);
      if tmp^<>'' then
      begin
        if tmp^[length(tmp^)]<>'\' then tmp^:=tmp^+'\';
        if LFNFileExist(tmp^+Path) then
        begin
          LFNFSearch:=LFNFExpand(tmp^+Path); found:=true;
        end;
      end;
    until found or (Ind=0);
    Dispose(tmp);
  end else
  begin
{$IFDEF WINDOWS}
    GetMem(Which,256);
    len:=length(Path); for i:=1 to len do Path[i-1]:=Path[i]; Path[len]:=#0;
    len:=length(DirList); for i:=1 to len do DirList[i-1]:=DirList[i]; DirList[len]:=#0;
    FileSearch(which,PChar(@Path),PChar(@DirList));
    LFNFSearch:=StrPas(Which); FreeMem(Which,256);
{$ELSE}
    LFNFSearch:=FSearch(Path,DirList);
{$ENDIF}
  end;
end;                     { LFNFSearch }

procedure LFNFSplit(Path: string; Dir,Name,Ext: PString);
{ An almost drop-in replacement for the TP6 FSplit, which supports LFN.   }
{ The additional difference is that the arguments are passed as pointers, }
{ rather than VAR variables. This is so that if a file segment is not     }
{ needed, one can pass NIL in the respective variable, and it will not    }
{ be returned.                                                            }
var
  StrPt,StrSlash,StrEnd: integer;
begin
  StrEnd:=length(Path);
  StrPt:=StrEnd; StrSlash:=0;
  while(StrPt>0) and (Path[StrPt]<>'.') and (Path[StrPt]<>'\') do dec(StrPt);
  if (StrPt>0) and (Path[StrPt]='.') then  { found extension }
  begin
    StrSlash:=StrPt-1;
    while (StrSlash>0) and (Path[StrSlash]<>'\') do dec(StrSlash);
  end else if (StrPt>0) and (Path[StrPt]='\') then  { No extension }
  begin
    StrSlash:=StrPt; StrPt:=StrEnd+1;
  end else if StrPt=0 then   { All name }
  begin
    StrPt:=StrEnd+1; StrSlash:=0;
  end;

  if Dir<>Nil then
  begin
    Dir^:='';
    if StrSlash>0 then Dir^:=Copy(Path,1,StrSlash);
  end;
  if Name<>Nil then
  begin
    Name^:='';
    if StrPt>StrSlash+1 then Name^:=Copy(Path,StrSlash+1,StrPt-StrSlash-1);
  end;
  if Ext<>Nil then
  begin
    Ext^:='';
    if StrPt<=StrEnd then Ext^:=Copy(Path,StrPt,255);
  end;
end;                   { LFNFSplit }

function LFNFExpand(Path: string): string;
{ Drop-in replacement for the TP6 FExpand, which supports LFN. }
{ Personally, I prefer it to the later FileExpand.             }
var
  D,N,E,P: PString;
  i,j,ndots: integer;
begin
  for i:=1 to length(Path) do if Path[i]='/' then Path[i]:='\';
  LFNFExpand:='';
  GetMem(P,270);
{$IFDEF WINDOWS}
  FileExpand(PChar(P)+1,'.'); P^[0]:=chr(StrLen(PChar(P)+1));
{$ELSE}
  P^:=FExpand('.'); 
{$ENDIF}
  if (P^<>'') and (P^[length(P^)]<>'\') then P^:=P^+'\';
  P^:=LFNLongName(P^);
  ndots:=0;
  while (ndots<length(Path)) and (Path[Ndots+1]='.') do inc(ndots);
  if (length(Path)>1) and (UpCase(Path[1]) in ['A'..'Z']) and (Path[2]=':') then
    P^:=Path         { Fully qualified }
  else if Path[1]='\' then        { Only drive missing }
    P^:=Copy(P^,1,2)+Path
  else begin
    for i:=1 to ndots-1 do    { relative filenames, multiple dots }
    begin
      if length(P^)>3 then
      begin
        j:=length(P^)-1;
        while (j>3) and (P^[j]<>'\') do dec(j);
        P^[0]:=Chr(j);
      end;
      delete(Path,1,1);
    end;
    if Pos('.\',Path)=1 then Delete(Path,1,2)
    else if Pos('.',Path)=1 then Delete(Path,1,1);
    P^:=P^+Path;
  end;
  LFNFExpand:=P^;
  FreeMem(P,270);
end;                     { LFNFExpand }

procedure CanonicalFname(var S: string);
{ This routine takes a filename and changes its case to a canonical form: }
{ 1. Without LFN support, lowercase.                                      }
{ 1. For existing short filenames, or dir names, lowercase.               }
{ 2. For existing long filenames, the system-supplied case.               }
{ 3. For non-existing filenames, expand the existing part of the path,    }
{    and leave the rest unchanged.                                        }
{ In all cases '/' is changed to '\'.                                     }
type
  TBf = array[1..3] of string;
var
  lname,sname,res: Pstring;
  Buf: ^TBf;
  i,j: integer;
  exists: boolean;

procedure StrLwr(var L: string);
var
  i: integer;
begin
  for i:=1 to length(L) do if L[i] in ['A'..'Z'] then
    L[i]:=Chr(Ord(L[i])-Ord('A')+Ord('a'));
end;

begin
  for i:=1 to length(S) do if S[i]='/' then S[i]:='\';
  if LFNAble then
  begin
    New(Buf);
    Buf^[1]:='';
    repeat
      i:=Pos('\',S); if i=0 then i:=length(S);
      if S[i]='\' then exists:=LFNFileExist(Buf^[1]+Copy(S,1,i)+'.')
      else exists:=LFNFileExist(Buf^[1]+Copy(S,1,i));
      if exists then
      begin
        Buf^[2]:=LFNShortName(Buf^[1]+Copy(S,1,i));
        Buf^[3]:=LFNLongName(Buf^[2]);
        j:=length(Buf^[2])-1; while (j>0) and (Buf^[2][j]<>'\') do dec(j);
        Delete(Buf^[2],1,j);
        j:=length(Buf^[3])-1; while (j>0) and (Buf^[3][j]<>'\') do dec(j);
        Delete(Buf^[3],1,j);
        if Buf^[3]=Buf^[2] then StrLwr(Buf^[3]);
        Buf^[1]:=Buf^[1]+Buf^[3];
        delete(S,1,i);
      end;
    until (not exists) or (S='');
    S:=Buf^[1]+S;
    Dispose(Buf);
  end else StrLwr(S);
end;                { CanonicalFname }

function CanonicalFilename(fname: PChar): PChar;
begin
  CanonicalFName(PChar2PString(fname)^);
  fname:=PString2PChar(PString(fname));
  CanonicalFilename:=fname;
end;

{=========================================================================}
{ BINARY AND TEXT FILE INPUT/OUTPUT ROUTINES.                             }
{ This set of routines is an interface between the LFN API and the Pascal }
{ style input/output routines. It uses ordinary text and file variables,  }
{ storing special info in the UserData field. The variable is then fully  }
{ compatible with the Pascal read(ln), write(ln), BlockRead, BlockWrite,  }
{ etc input/output routines.                                              }
{ All the functions return the DOS error code, and also put it into       }
{ DOSERROR. The global "LFNRuntimeError" determines if runtime errors     }
{ will be generated (by default, no.)                                     }                    
{=========================================================================}

procedure LFNNew(var F; IsText: boolean);
{ This routine prepares a text or file variable for LFN use. It allocates }
{ memory for the long name, and initializes the entries in the UserData.  }
{ It must be called before any other.                                     }
{ The "IsText" flag tells if the variable is of type "file" or "text".    }
begin
  with PLFNFileParam(@F)^ do
  begin
    TextFile:=IsText;
    Initialized:=false;
    Magic:=LFNMagic;
    lfname:=Nil; plfname:=Nil;
    if LFNAble then
    begin
      GetMem(lfname,270); FillChar(lfname^,270,0);
      plfname:=PChar(@PByteArray(lfname)^[1]);
    end;
  end;
end;                    { LFNNew }

function LFNAssign(var F; name: string): integer;
{ This routine replaces the Pascal "Assign" routine. For existing files, }
{ it first determines the short name, and then invokes "Assign". If the  }
{ file does not exist, it only stores the information in the UserData    }
{ fields, since the equivalent short name is not known. The assign       }
{ operation is then deferred to the first "LFNRewrite" call.             }
{ LFNAssign may be called for the same variable for different filenames, }
{ so long as the type (file or text) is the same.                        }
var
  tmp,fname: PString;
  IsText: boolean;
  P: PChar;
begin
  if PLFNFileParam(@F)^.Magic<>LFNMagic then
  begin
    DosError:=LFNErr_NotAllocated;
    LFNAssign:=DosError;
{$IFDEF WINDOWS}
    MessageBox(0,'Bug, LFNAssign',Nil,mb_ok);    { for debugging }
{$ENDIF}
    Exit;
  end;   
  LFNAssign:=0; DosError:=0;
  if LFNAble then
  begin
    GetMem(fname,270);
    if LFNFileExist(name) then
    begin
      fname^:=LFNShortName(name);
      PByteArray(fname)^[length(fname^)+1]:=#0;
    end else fname^:='';
  end else fname:=@name;
  with PLFNFileParam(@F)^ do
  begin
    if fname^='' then Initialized:=false
    else begin
      IsText:=TextFile; tmp:=lfname; P:=plfname;
      if IsText then Assign(text(F),fname^) else assign(file(F),fname^);
      Initialized:=true;
      TextFile:=IsText; lfname:=tmp; plfname:=P;
      Magic:=LFNMagic;
    end;
    if LFNAble then
    begin
      lfname^:=name;
      PByteArray(lfname)^[length(lfname^)+1]:=#0;
    end;
  end;
  if LFNAble then FreeMem(fname,270);
end;                       { LFNAssign }

function LFNRewrite(var F; RecLen: word): integer;
{ This routine readies a file for output. If the file does not yet exist, }
{ it creates an empty file to get the system-determined short name, and   }
{ performs a deferred Assign, since at Assign time a short name was not   }
{ yet available (see description of LFNAssign).                           }
{ The routine returns 0 if successful, and the DOS errorcode if not.      } 
var
  tmp,fname: PString;
  IsText: boolean;
  P: PChar;

function Err(e: byte): byte;
begin
  LFNRewrite:=e; DosError:=e; Err:=e;
  if LFNRuntimeErrors and (e<>0) then RunError(e);
end;
 
begin
  Err(0);
  if PLFNFileParam(@F)^.Magic<>LFNMagic then
  begin
{$IFDEF WINDOWS}
    MessageBox(0,'Bug, LFNRewrite',Nil,mb_ok);   { for debugging }
{$ENDIF}
    Err(LFNErr_NotAllocated); Exit;
  end;   
  if LFNAble then
  with PLFNFileParam(@F)^ do
  begin
    if not Initialized then    { create the file, so we can get a valid short name }
    begin
      if Err(LCreateEmpty(plfname))=0 then
      begin
        New(fname);
        fname^:=LFNShortName(lfname^);
        IsText:=TextFile; tmp:=lfname; P:=plfname;
        if IsText then Assign(text(F),fname^) else assign(file(F),fname^);
        Initialized:=true;
        TextFile:=IsText; lfname:=tmp; plfname:=P;
        Magic:=LFNMagic;
      end;
    end;
    if Initialized then
    begin
      {$I-}
      if TextFile then Rewrite(text(F))
      else if RecLen=0 then Rewrite(file(F))
      else Rewrite(file(F),RecLen);
      Err(IoResult);
      {$I+}
    end;
  end else with PLFNFileParam(@F)^ do
  if Initialized then
  begin
    {$I-}
    if TextFile then Rewrite(text(F))
    else if RecLen=0 then rewrite(file(F))
    else Rewrite(file(F),RecLen);
    Err(IoResult);
    {$I+}
  end;
end;               { LFNRewrite }

function LFNAppend(var F; RecLen: word): integer;
{ This routines opens a previously LFNAssigned for output at the EOF. }
{ Its not really necessary, except that it performs additional error  }
{ checking to make  sure that the file was properly initialized.      }
{ Also, in contrast to the TP Append, if the file does not exist the  }
{ routine calls LFNRewrite to create and open it.                     }
{ The routine returns 0 if successful, and the DOS errorcode if not.  }

function Err(e: byte): byte;
begin
  LFNAppend:=e; DosError:=e; Err:=e;
  if LFNRuntimeErrors and (e<>0) then RunError(e);
end;

begin
  Err(0);
  if PLFNFileParam(@F)^.Magic<>LFNMagic then
  begin
    Err(LFNErr_NotAllocated); Exit;
  end;
  with PLFNFileParam(@F)^ do
  begin
    if Magic<>LFNMagic then
    begin
      Err(LFNErr_NotAllocated); Exit;
    end else if not TextFile then
    begin
      Err(LFNErr_NotATextFile); Exit;
    end else if not Initialized then Err(LFNRewrite(F,RecLen))
    else begin
      {$I-}
      Append(text(F)); Err(IoResult);
      {$I+}
    end;
  end;
end;             { LFNAppend }

function LFNReset(var F; RecLen: word): integer;
{ This routines opens a file for input, instead of "reset". Its not really }
{ necessary, except that it performs additional error checking to make     }
{ sure that the file was properly initialized.                             }
{ The routine returns 0 if successful, and the DOS errorcode if not.       }

procedure Err(e: byte);
begin
  LFNReset:=e; DosError:=e;
  if LFNRuntimeErrors and (e<>0) then RunError(e);
end;
 
begin
  Err(0);
  if PLFNFileParam(@F)^.Magic<>LFNMagic then
  begin
{$IFDEF WINDOWS}
    MessageBox(0,'Bug, LFNReset',Nil,mb_ok);   { for debugging }
{$ENDIF}
    Err(LFNErr_NotAllocated); Exit;
  end;
  with PLFNFileParam(@F)^ do
  begin
    if not Initialized then LFNReset:=LFNErr_UnInitialized
    else begin
      {$I-}
      if TextFile then Reset(text(F))
      else if RecLen=0 then Reset(file(F))
      else Reset(file(F),RecLen);
      Err(IoResult);
      {$I+}
    end;
  end;
end;             { LFNReset }

function LFNErase(var F): integer;
{ This routines erases a previously LFNAssigned, but not opened, file. }
{ Its not really necessary, except that it performs additional error   }
{ checking to make  sure that the file was properly initialized. Also, }
{ it re-assignes the file so it will be properly ready for a rewrite.  }
{ The routine returns 0 if successful, and the DOS errorcode if not.   }
var
  S: PString;
  S1: PChar;

function Err(e: byte): byte;
begin
  LFNErase:=e; DosError:=e; Err:=e;
  if LFNRuntimeErrors and (e<>0) then RunError(e);
end;

begin
  with PLFNFileParam(@F)^ do
  begin
    LFNErase:=0;
    if (Magic<>LFNMagic) then
    begin
      Err(LFNErr_NotAllocated); Exit;
    end else if (not Initialized) then
    begin
      Err(LFNErr_UnInitialized); Exit;
    end;
    LFNClose(F);
    if not LFNAble then
    begin
      GetMem(S,81); S1:=PChar(@PByteArray(S)^[1]);
      Move(SName,S1^,80); S^:=Chr(StrLen(S1));
    end;
    {$I-}
    if TextFile then Erase(text(F)) else Erase(file(F));
    if Err(IoResult)=0 then
    begin
      if LFNAble then LFNAssign(F,lfname^)
      else begin
        LFNAssign(F,S^); FreeMem(S,81);
      end;
    end;
    {$I+}
  end;
end;                   { LFNErase }

function LFNClose(var F): integer;
{ This routines closes a previously LFNAssigned and opened file.     }
{ Its not really necessary, except that it performs additional error }
{ checking to make  sure that the file was properly initialized.     }
{ The routine returns 0 if successful, and the DOS errorcode if not. }

function Err(e: byte): byte;
begin
  LFNClose:=e; DosError:=e; Err:=e;
  if LFNRuntimeErrors and (e<>0) then RunError(e);
end;

begin
  Err(0);
  with PLFNFileParam(@F)^ do
  begin
    if Magic<>LFNMagic then
    begin
      Err(LFNErr_NotAllocated); Exit;
    end else if not Initialized then
    begin
      Err(LFNErr_UnInitialized); Exit;
    end;
    {$I-}
    if TextFile then close(text(F)) else close(file(F));
    Err(IoResult);
    {$I+}
  end;
end;                   { LFNClose }

procedure LFNDispose(var F);
{ This routine disposes of the additional memory allocated by LFNNew, }
{ and cleans up the UserData fields. If the file is open, it also     }
{ closes it, so that there is no need to call LFNClose previously.    }
begin
  with PLFNFileParam(@F)^ do
  begin
    if (Magic<>LFNMagic) or (not Initialized) then Exit;
    LFNClose(F);
    if lfname<>Nil then FreeMem(lfname,270);
    lfname:=Nil; plfname:=Nil; Initialized:=false; Magic:='';
  end;
end;                 { LFNDispose }

function LFNRename(var F; NewName: string): integer;
{ This routines renames a previously LFNAssigned, but not opened, file. }
{ The file variable is then re-assigned to the new name.                }
{ The routine returns 0 if successful, and the DOS errorcode if not.    }
var
  i,len: integer;

function Err(e: byte): byte;
begin
  LFNRename:=e; DosError:=e; Err:=e;
  if LFNRuntimeErrors and (e<>0) then RunError(e);
end;

begin
  Err(0);
  if NewName='' then Exit;
  with PLFNFileParam(@F)^ do
  begin
    if Magic<>LFNMagic then
    begin
      Err(LFNErr_NotAllocated); Exit;
    end else if not Initialized then
    begin
      Err(LFNErr_UnInitialized); Exit;
    end;
    if not LFNAble then   { The usual TP stuff }
    begin
      {$I-}
      if TextFile then Rename(text(F),NewName) else Rename(file(F),NewName);
      Err(IoResult);
      {$I+}
    end else                       { LFN }
    begin
      len:=length(NewName);
      for i:=1 to len do NewName[i-1]:=NewName[i]; NewName[len]:=#0;
      if Err(LRenameFile(plfname,PChar(@NewName)))=0 then
      begin
        for i:=len downto 1 do
          NewName[i]:=NewName[i-1]; NewName[0]:=chr(len);
        LFNAssign(F,NewName);
      end;
    end;
  end;
end;                    { LFNRename }

begin
  LFNAble:=SupportsLFN;
end.
