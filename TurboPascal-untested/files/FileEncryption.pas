(*
  Category: SWAG Title: FILE HANDLING ROUTINES
  Original name: 0062.PAS
  Description: File Encryption
  Author: KANDA'JALEN EIRSIE
  Date: 11-26-94  05:03
*)

{
> Is there out there that has any good encription code.. something like rsa?

{****************************************************************************}
{                Unit to Compute in a Very Pascal Way                        }
{****************************************************************************}
{                      Incredible File Utilities                             }
{****************************************************************************}
{              Version : 1.0                  Dec  1990                      }
{****************************************************************************}
Unit FileUtil ;
{****************************************************************************}
Interface uses dos ;
{****************************************************************************}
Const
     Crea  = 'UNIT FILEUTIL.TPU V.1.0 By: Jeffrey N. Thompson' ;
     Creat = '(C) Copywrite 1990,1991 By KJE Software Opportunities
Exclusively' ;{ Procedure and function List }
Function  FileExists(pathname:string):boolean ;
function  KillFile(pathname : string):boolean ;
Procedure cryptB(var Rec ; size : word ; Sym : Byte) ;
Procedure CryptStr(var Rec ; Size : Word ; Ecrypt : string) ;
Procedure CryptS(Var Rec ; Size : Word ; Seed : longint) ;
Function  CryptfileStr(Fname:string; Ecrypt : string) : integer ;
Function  CryptfileWithFile(Fname,Keyname : String) : Integer ;
Function  CryptFileS(Fname : string ; Seed : longint) : integer ;
{****************************************************************************}
Implementation    { Uses }
{ Procedures and functions follow }
{****************************************************************************}
{ Check if a filename Exists in the current drive and directory. }
Function FileExists(pathname : string) : boolean ;
Var
        search : searchrec ;
        exists : boolean ;
Begin   { Exists }
     exists := false ;
     findfirst(pathname,anyfile,search) ;
     exists := (doserror = 0) and (search.name <> '') ;
     fileexists := exists ;
End ;  { Exists }
{****************************************************************************}
 { Destroys a file.  Unrecoverably }
function  KillFile(pathname : string):boolean ;
var
   kfile : file ;
   buffer : array[1..2048] of byte ;
   numread,numwritten : word ;
   I  : integer ;
   j2 : longint ;
   found : boolean ;

begin
{$F-}
   if fileexists(pathname) then
   begin
        found := true ;
        assign(kfile,pathname) ;
        setfattr(kfile,0) ;
        reset(kfile,1) ;
        repeat
             Blockread(kfile,buffer,sizeof(buffer),numread) ;
             j2 := filepos(kfile) ;
             for I := 1 to numread do buffer[i] := random(255) ;
             seek(kfile,j2-numread) ;
             blockwrite(kfile,buffer,numread,numwritten) ;
             seek(kfile,j2) ;
        until (numread = 0) or (numwritten <> numread) ;
        close(kfile) ;
        erase(kfile) ;
   end else found := false ;
{$F+}
     killfile := (ioresult=0) and (found) ;
  end ;
{****************************************************************************}
 { Encrypt a record of SIZE with a Byte Sized SYMbol }
procedure cryptb(var Rec ; size : word ; Sym : Byte) ;

type
    buffers = array[1..65535] of byte ;
var
   I : word ;
   buffer : ^buffers ;

begin
     buffer := nil ;
     buffer := @rec ;
     for I := 1 to size do buffer^[I] := buffer^[i] xor sym ;
end ;

{****************************************************************************}
 { Encrypts a record of SIZE with a Sliding String method }
procedure CryptStr(var Rec ; Size : Word ; Ecrypt : string) ;
type
    buffers = array[1..65535] of byte ;
var
   I,J : word ;
   buffer : ^buffers ;
   l : integer ;
   c1 : char ;

begin
     l := length(ecrypt) ;
     if l = 1 then
     begin
          c1 := ecrypt[1] ;
          cryptb(rec,size,byte(c1)) ;
          exit ;
     end ;
     if l<2 then exit ;
     buffer := nil ;
     buffer := @rec ;
     j := 1 ;
     for I := 1 to size do
     begin
          buffer^[I] := buffer^[i] xor byte(ecrypt[j]) ;
          inc(j) ;
          if j > l then
          begin
               j := 1 ;
               c1 := ecrypt[1] ;
               move(ecrypt[2],ecrypt[1],l-1) ;
               ecrypt[l] := c1 ;
          end ;
     end ;
end ;
{****************************************************************************}
 { Encrypts a record of SIZE  with a list of random numbers produced by
 Initial Seeding with SEED }
procedure cryptS(var Rec ; size : word ; Seed : longint) ;

type
    buffers = array[1..65535] of byte ;
var
   I : word ;
   buffer : ^buffers ;

begin
     randseed := seed ;
     buffer := nil ;
     buffer := @rec ;
     for I := 1 to size do buffer^[I] := buffer^[i] xor byte(random(254)+1) ;
end ;

{****************************************************************************}
{ Encrypts a file, with a string using a sliding string method }
{ String em up! }
function CryptfileStr(Fname:string; Ecrypt : string) : integer ;
const
     tempfilename = 'KJETLHM.DS2' ;
var
   fromfile,tofile : file ;
   buffer : array[1..2048] of byte ;
   numread,numwritten,attr : word ;
   error : boolean ;
   I,J,L : integer ;
   j2 : longint ;
   c1 : char ;

begin
     if not fileexists(fname) then
     begin
          cryptfileStr := 1 ;
          exit ;
     end ;
     if length(ecrypt) <= 1 then
     begin
          cryptfileStr := 2 ;
          exit ;
     end ;
     l := length(ecrypt) ;
{$I-}
     assign(fromfile,fname) ;
     assign(tofile,tempfilename) ;
     getfattr(fromfile,attr) ;
     setfattr(fromfile,0) ;
     reset(fromfile,1) ;
     rewrite(tofile,1) ;
     repeat
          blockread(fromfile,buffer,sizeof(buffer),numread) ;
          j := 1 ;
          for I := 1 to sizeof(buffer) do
          begin
               buffer[I] := buffer[I] xor byte(ecrypt[j]) ;
               inc(j) ;
               if j > l then
               begin
                    j := 1 ;
                    c1 := ecrypt[1] ;
                    move(ecrypt[2],ecrypt[1],l-1) ;
                    ecrypt[l] := c1 ;
               end ;
          end ;
          blockwrite(tofile,buffer,numread,numwritten) ;
     until (numread = 0) or (numwritten <> numread) ;
     close(tofile) ;
     close(fromfile) ;
     error := killfile(fname) ;
     rename(tofile,fname) ;
     setfattr(tofile,attr) ;
{$I+}
     cryptfileStr := (IOresult)
end ;
{****************************************************************************}
 { encrypts a file with another file as the key, using a sliding method
 }
{ File this sucker! }
Function CryptfileWithFile(Fname,Keyname : String) : Integer ;
const
     Tempfilename = 'KJETLHM.DS3' ;
var
   Infile,Keyfile,Outfile : file ;
   Bfile : File of Byte ;
   inBuffer,keybuffer,outbuffer : array[1..2048] of byte ;
   attr,kattr : word ;
   I,J : longint ;
   numread,numwritten,numkread : word ;
   error : boolean ;

begin
     if not fileexists(fname) then
     begin
          cryptfilewithfile := 1 ;
          exit ;
     end ;
     if not fileexists(keyname) then
     begin
          cryptfilewithfile := 2  ;
          exit ;
     end ;
     {$I-}
     Assign(infile,fname) ;
     assign(keyfile,keyname) ;
     assign(outfile,tempfilename) ;
     getfattr(infile,attr) ;
     getfattr(keyfile,kattr) ;
     setfattr(infile,0) ;
     setfattr(keyfile,0) ;
     reset(infile,1) ;
     reset(keyfile,1) ;
     rewrite(outfile,1) ;
     repeat
          { Fill the input buffer }
          blockread(infile,inbuffer,sizeof(inbuffer),numread) ;
          { Fill the key buffer }
          blockread(keyfile,keybuffer,sizeof(keybuffer),numkread) ;
          j := numkread ;
          if numkread < numread then { The Keyfile is smaller }
          repeat  { Keep resetting and reading until the buffer is full }
               reset(keyfile,1) ;
               blockread(keyfile,keybuffer[j+1],numread-j,numkread) ;
               j := j + numkread ;
               if j > numread then HALT(3) ;
          until j = numread ;
          for I := 1 to numread do
           outbuffer[I] := inbuffer[I] XOR keybuffer[I] ;
          blockwrite(outfile,outbuffer,numread,numwritten) ;
     until (numread = 0) or (numwritten <> numread) ;
     close(keyfile) ;
     setfattr(keyfile,kattr) ;  { Restore the attributes }
     close(infile) ;
     close(outfile) ;
     { Now destroy the old file }
     error := killfile(fname) ;
     rename(outfile,fname) ;
     setfattr(outfile,attr) ;
{$I+}
     cryptfilewithfile := IoResult ;
end ;
{****************************************************************************}
 { Encrypts a file, using a list of random numbers generated with an
 initial SEED.   The Seed is your key } 
function CryptfileS(Fname:string; Seed : Longint) : integer ;
const
     tempfilename = 'KJETLHM.DS4' ;
var
   fromfile,tofile : file ;
   buffer : array[1..2048] of byte ;
   numread,numwritten,attr : word ;
   I : integer ;
   error : boolean ;

begin
     if not fileexists(fname) then
     begin
          cryptfileS := 1 ;
          exit ;
     end ;
     randseed := seed ;
{$I-}
     assign(fromfile,fname) ;
     assign(tofile,tempfilename) ;
     getfattr(fromfile,attr) ;
     setfattr(fromfile,0) ;
     reset(fromfile,1) ;
     rewrite(tofile,1) ;
     repeat
          blockread(fromfile,buffer,sizeof(buffer),numread) ;
          for I := 1 to numread do
           buffer[I] := buffer[I] xor byte(random(254)+1) ;
          blockwrite(tofile,buffer,numread,numwritten) ;
     until (numread = 0) or (numwritten <> numread) ;
     close(tofile) ;
     close(fromfile) ;
     error := killfile(fname);
     rename(tofile,fname) ;
     setfattr(tofile,attr) ;
{$I+}
     cryptfileS := IOresult  ;
end ;
{****************************************************************************}
{****************************************************************************}
end. { Unit }

{
These are not weird math methods of encryption.  They are simple
 Extreemly fast XOR methods.  By using multiple methods on various parts
 of a file, or database, you can foil any attempt at cracking.  This is
 true because the cracker has no way of knowing where to start, even if
 he possesses the keys..

     I have a standing challenge, if anyone cares to take it...  Here
 are the methods, I'll post a small file, and even give you the keys I
 used to ecrypt a simple one line sentence.  If you can crack it, I'll
 buy you a pentium computer!
}
