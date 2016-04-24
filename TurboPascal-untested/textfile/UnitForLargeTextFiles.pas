(*
  Category: SWAG Title: TEXT FILE MANAGEMENT ROUTINES
  Original name: 0042.PAS
  Description: Unit for Large Text Files
  Author: BJ�RN FELTEN
  Date: 11-26-94  04:57
*)

{
> Unfortunately this won't work, for some reason BP ignores the FileMode
> variable when dealing with a file of type Text.  I modified one of the
> RTL files to correct this problem

   This is not directed specifically to you, but to anyone that's interested in
a unit that can read big textfiles (like loggfiles, nodelists and so on) in a
fast way. It can only handle one file at a time and with later versions of TP/
BP the speed increase isn't as dramatic as it was in older versions, that
hadn't stuff like buffered textfiles. I use it a lot (even in network
environments -- with FileMode set to $40).
}

unit FileUtil; { unit for fast reading of large textfiles }

{ Donated to the PD by Björn Felten @ 2:203/208 -- Nov 1994 }
{ From the package BF_UTIL.ZIP }

interface

var
    Line    :string; { where the read line is returned }
                     { a global is used for higher speed }
    XEof    :boolean;

procedure XReset;
procedure XReadLn(var FileHandle: file);
procedure XOpen(var FileHandle: file; FileName: string);
procedure XClose(var FileHandle: file);

implementation

const
    BufSiz = $e000;

type
    Buffer = array[1..BufSiz+2] of char;
    BufPtr = ^Buffer;

var
    TempLine    :string;
    Buff        :BufPtr;
    Segm,Offs,
    NumRead,
    LastPos,
    FirstPos    : Word;

procedure XReset;
begin
   FirstPos:=0;
   LastPos:=FirstPos;
   XEof:=false
end
;

procedure XReadLn(var FileHandle: file);
begin
    asm
      mov  es,Segm      { just to be sure }
      mov  bx,es
      mov  dx,ds
      cld
      mov  di,LastPos   { start within file }
      add  di,Offs
      mov  al,13        { set up a search for CR }
      mov  cx,257       { max 255 char plus overhead }
      mov  si,di
      repnz scasb       { look for CR }
      mov  di,offset Line   { put it into string }
      neg  cl           { get string length }
      mov  [di],cl      { put it in first position }
      je   @empty
      inc  di
      mov  ds,bx        { swap es and ds}
      mov  es,dx
      rep  movsb        { move it }
@empty:
      lodsw             { skip CR/LF }
      mov  ds,dx        { restore ds }
      sub  si,Offs
      mov  LastPos,si   { save last position }
 end
 ;
 if LastPos>=BufSiz then
 begin
   TempLine:=Line; { handle partial line at block boundary }
   blockread(FileHandle,Buff^,BufSiz,NumRead);
   XReset;
   XReadLn(FileHandle);
   Line:=TempLine+Line
 end
 ;
 XEof:=(LastPos>=NumRead)
end;

procedure XOpen(var FileHandle: file; FileName: string);
begin
  assign(FileHandle,FileName);
  (*$I-*) reset(FileHandle,1) (*$I+*)
  ;
  if IoResult<>0 then
  begin
     writeln;
     writeln('Can''t find ',FileName,' in this directory!');
     writeln;
     halt(2)
  end
  ;
  if memavail<BufSiz+$400 then
  begin
     writeln;
     writeln('Need at least ',BufSiz shr 10,'kb RAM!');
     writeln;
     halt(3)
  end
  ;
  new(Buff);
  Segm:=seg(Buff^);
  Offs:=ofs(Buff^);
  Buff^[BufSiz+1]:=#13;  { stuff some CR's in to avoid running }
  Buff^[BufSiz+2]:=#13;  { off limits if unlucky w/ boundaries }
  blockread(FileHandle,Buff^,BufSiz,NumRead);
  Buff^[NumRead+1]:=#13;
  Buff^[NumRead+2]:=#13;
  XReset
end
;
procedure XClose(var FileHandle: file);
begin
   close(FileHandle);
   dispose(Buff)
end
;

end.

