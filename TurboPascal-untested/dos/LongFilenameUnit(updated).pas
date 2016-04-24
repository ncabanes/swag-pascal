(*
  Category: SWAG Title: DOS & ENVIRONMENT ROUTINES
  Original name: 0110.PAS
  Description: Long Filename unit (updated)
  Author: ARNE DE BRUIJN
  Date: 05-30-97  18:16
*)


{
I've made a Windows 95 long filename DOS unit. The file opening part is
missing, maybe I will add it someday. A simple test program is after the end
of part 2. }

{ Long filename DOS unit, Arne de Bruijn, 19960402, Public Domain }
{ All functions return the errorcode, and store it in DosError in }
{ the Dos unit. }
{ The functions work only if Windows 95 is loaded! }

unit ldos;
interface
uses dos;
type
 TLSearchRec=record
  Attr:longint;
  CreationTime,LastAccessTime,LastModTime:comp; { See below for conversion }
  HiSize,LoSize:longint;
  Reserved:comp;
  Name:array[0..259] of char;
  ShortName:array[0..13] of char; { Only if longname exists }
  Handle:word;
 end;

function LFindFirst(FileSpec:pchar; Attr:word; var SRec:TLSearchRec):word;
{ Search for files }

function LFindNext(var SRec:TLSearchRec):word;
{ Find next file }

function LFindClose(var SRec:TLSearchRec):word;
{ Free search handle }

function LTruename(FileName:pchar; Result:pchar):word;
{ Return complete path, if relative uppercased longnames added, }
{ in buffer Result (261 bytes) }

function LGetShortName(FileName:pchar; Result:pchar):word;
{ Return complete short name/path for input file/path in buffer }
{ Result (79 bytes) }

function LGetLongName(FileName:pchar; Result:pchar):word;
{ Return complete long name/path for input file/path in buffer }
{ Result (261 bytes) }

function LFileSystemInfo(RootName:pchar; FSName:pchar; FSNameBufSize:word;
 var Flags,MaxFileNameLen,MaxPathLen:word):word;
{ Return File System Information, for FSName 32 bytes should be sufficient }
{ Rootname is for example 'C:\' }
{ Flags: }
{ bit
{  0   searches are case sensitive }
{  1   preserves case in directory entries }
{  2   uses Unicode characters in file and directory names }
{ 3-13 reserved (0) }
{ 14   supports DOS long filename functions }
{ 15   volume is compressed }


function LErase(Filename:pchar):word;
{ Erase file }

function LMkDir(Directory:pchar):word;
{ Make directory }

function LRmDir(Directory:pchar):word;
{ Remove directory }

function LChDir(Directory:pchar):word;
{ Change current directory }

function LGetDir(Drive:byte; Result:pchar):word;
{ Get current drive and directory. Drive: 0=current, 1=A: etc. }

function LGetAttr(Filename:pchar; var Attr:word):word;
{ Get file attributes}

function LSetAttr(Filename:pchar; Attr:word):word;
{ Set file attributes }

function LRename(OldFilename,NewFilename:pchar):word;
{ Rename file }

function LTimeToDos(var LTime:comp):longint;
{ Convert 64-bit number of 100ns since 01-01-1601 UTC to local DOS format time
}{ (LTime is var to avoid putting it on the stack) }

procedure UnpackLTime(var LTime:comp; var DT:DateTime);
{ Convert 64-bit time to date/time record }
implementation
function LFindFirst(FileSpec:pchar; Attr:word; var SRec:TLSearchRec):word;
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
 mov es:[di].TLSearchRec.Handle,ax
 and ax,bx
 mov [DosError],ax
end;

function LFindNext(var SRec:TLSearchRec):word; assembler;
{ Find next file }
asm
 mov ax,714fh
 xor si,si
 les di,SRec
 mov bx,es:[di].TLSearchRec.Handle
 int 21h
 sbb bx,bx
 and ax,bx
 mov [DosError],ax
end;

{ corrects bug in LDOS .. }
function LFindClose(var SRec:TLSearchRec):word; assembler;
{ Free search handle }
asm
 {mov ax,714fh}
 mov ax,71A1h
 mov bx,es:[di].TLSearchRec.Handle
 int 21h
 sbb bx,bx
 and ax,bx
 mov [DosError],ax
end;

function LTrueName(FileName:pchar; Result:pchar):word; assembler;
{ Return complete path, if relative uppercased longnames added, }
{ in buffer Result (261 bytes) }
asm
 push ds
 mov ax,7160h
 xor cx,cx
 lds si,FileName
 les di,Result
 int 21h
 pop ds
 sbb bx,bx
 and ax,bx
 mov [DosError],ax
end;

function LGetShortName(FileName:pchar; Result:pchar):word; assembler;
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


function LGetLongName(FileName:pchar; Result:pchar):word; assembler;
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

function LFileSystemInfo(RootName:pchar; FSName:pchar; FSNameBufSize:word;
 var Flags,MaxFileNameLen,MaxPathLen:word):word; assembler;
{ Return File System Information, for FSName 32 bytes should be sufficient }
asm
 push ds
 lds dx,RootName
 les di,FSName
 mov cx,FSNameBufSize
 mov ax,71a0h
 int 21h
 pop ds
 les di,Flags
 mov es:[di],bx
 les di,MaxFileNameLen
 mov es:[di],cx
 les di,MaxPathLen
 mov es:[di],dx
 sbb bx,bx
 and ax,bx
 mov [DosError],ax
end;

function LTimeToDos(var LTime:comp):longint; assembler;
{ Convert 64-bit number of 100ns since 01-01-1601 UTC to local DOS format time
}{ (LTime is var to avoid putting it on the stack) }
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
end;

procedure UnpackLTime(var LTime:comp; var DT:DateTime);
{ Convert 64-bit time to date/time record }
begin
 UnpackTime(LTimeToDos(LTime),DT);
end;

function LMkDir(Directory:pchar):word; assembler;
asm
 push ds
 lds dx,Directory
 mov ax,7139h
 int 21h
 pop ds
 sbb bx,bx
 and ax,bx
 mov [DosError],ax
end;

function LRmDir(Directory:pchar):word; assembler;
asm
 push ds
 lds dx,Directory
 mov ax,713ah
 int 21h
 pop ds
 sbb bx,bx
 and ax,bx
 mov [DosError],ax
end;

function LChDir(Directory:pchar):word; assembler;
asm
 push ds
 lds dx,Directory
 mov ax,713bh
 int 21h
 pop ds
 sbb bx,bx
 and ax,bx
 mov [DosError],ax
end;

function LErase(Filename:pchar):word; assembler;
asm
 push ds
 lds dx,Filename
 mov ax,7141h
 int 21h
 pop ds
 sbb bx,bx
 and ax,bx
 mov [DosError],ax
end;

function LGetAttr(Filename:pchar; var Attr:word):word; assembler;
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
end;

function LSetAttr(Filename:pchar; Attr:word):word; assembler;
asm
 push ds
 lds dx,Filename
 mov ax,7143h
 mov bl,1
 mov cx,Attr
 int 21h
 pop ds
 sbb bx,bx
 and ax,bx
 mov [DosError],ax
end;

function LGetDir(Drive:byte; Result:pchar):word; assembler;
asm
 cld
 les di,Result
 mov al,Drive
 mov dl,al
 dec al
 jns @GotDrive
 mov ah,19h
 int 21h
@GotDrive:
 add al,41h
 mov ah,':'
 stosw
 mov ax,'\'
 stosw
 push ds
 push es
 pop ds
 mov si,di
 dec si
 mov ax,7147h
 int 21h
 pop ds
 sbb bx,bx
 and ax,bx
 mov [DosError],ax
end;

function LRename(OldFilename,NewFilename:pchar):word; assembler;
asm
 push ds
 lds dx,OldFilename
 les di,NewFilename
 mov ax,7156h
 int 21h
 pop ds
 sbb bx,bx
 and ax,bx
 mov [DosError],ax
end;

end.


=== LDOSTEST.PAS
{ Simple sample for LDOS unit, Arne de Bruijn, 19960402, Public Domain }
uses ldos,strings,dos;
type string2=string[2];
function Str0(B:byte):string2;
begin Str0[0]:=#2; Str0[1]:=char(B div 10+48); Str0[2]:=char(B mod 10+48);
end;
var
 Buf,BufO:array[0..261] of char;
 SRec:TLSearchRec;
 DT:DateTime;
 LN,SN:pchar;
 W1,W2,W3:word;
begin
 Write('Enter path:'); ReadLn(Buf);
 WriteLn('LFileSystemInfo:',LFileSystemInfo(Buf,BufO,32,W1,W2,W3),
  ' = ',BufO,',',W1,',',W2,',',W3);
 WriteLn('LTruename:',LTrueName(Buf,BufO),' = ',BufO);
 WriteLn('LGetShortName:',LGetShortName(Buf,BufO),' = ',BufO);
 WriteLn('LGetLongName:',LGetLongName(Buf,BufO),' = ',BufO);
 LFindFirst(Buf,16,SRec);
 while DosError=0 do begin
   UnpackLTime(SRec.lastmodtime,DT);
   if SRec.ShortName[0]=#0 then
    begin SN:=@SRec.name; ln:=nil; end
   else
    begin SN:=@SRec.shortname; ln:=@SRec.name; end;
   with DT do WriteLn(SN,'':13-StrLen(SN),SRec.LoSize:9,
     ' ',Day:3,'-',Str0(Month),'-',Year,' ',Hour:2,':',Str0(Min),' ',LN);
   LFindNext(SRec); end;
 LFindClose(SRec);
end.

