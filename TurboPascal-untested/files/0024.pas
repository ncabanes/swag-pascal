{
SEAN PALMER

I just ran some timings, which are gonna be affected by SMARTDRV.EXE
being loaded, but I took that into account (ran multiple times on same
file, and took timings on second/subsequent runs, to make sure always
got cache hits)

What I got was that FileExists below and my modified version of that
fileExist3 function that's been floating around this echo for a while
(no bug) both run neck and neck... it's amazing... both are slightly
faster than FileExist2 and lots lots faster than the 'reset,
fileExist=(ioresult=0)' type thing that most people still seem to use...

I'd recommend using the first one below as it's really short...
}

uses
  dos;

{ Tied for fastest }
function fileExists(var s : string) : boolean;
begin
  fileExists := fSearch(s, '') <> '';
end;

{ 2nd }
function fileExist2(var s : string) : boolean;
var
  r : searchrec;
begin
  findfirst(s, anyfile, r);
  fileExist2 := (dosError = 0);
end;

{ Tied for fastest }
function fileExist3(var s : string) : boolean; assembler;
asm
  push ds
  lds  si, s        { need to make ASCIIZ }
  cld
  lodsb             { get length; si now points to first char }
  xor  ah, ah
  mov  bx, ax
  mov  al, [si+bx]  { save byte before placing terminating null }
  push ax
  mov  byte ptr [si+bx],0
  mov  dx, si
  mov  ax, $4300    { get file attributes }
  int  $21
  mov  al, 1        { if carry set, fail }
  pop  dx
  mov  [si+bx], dl  { restore byte }
  pop  ds
end;

{ Slowest }
function fileExist4(var s : string) : boolean;
var
  f : file;
begin
  assign(f,s);
  {$I-}
  reset(f);
  {$I+}
  if ioresult = 0 then
  begin
    close(f);
    fileExist4 := true;
  end
  else
    fileExist4 := false;
end;

