{
Okay everyone, a temporary kludge.. it works at least.  I'll try releasing a
full Windows 95 unit later on which will replace all the DOS functions with
new ones or something along those lines.  I ended up buying _Programmer's
Guide to Microsoft Windows 95_ from Microsoft Press.
*** D:\BP\WORK\LFN.PAS }

program LFNDir;
{$N+}

{si=1 instead of 0 gives a normal DOS date/time instead of the 100ns
stuff}

uses DOS, Strings;

const

{ File attribute constants }

  ReadOnly  = $0001;
  Hidden    = $0002;
  SysFile   = $0004;
  VolumeID  = $0008;
  Directory = $0010;
  Archive   = $0020;
  AnyFile   = $003F;
  TempFile  = $0100;

var

{ Error status variable }

LFNError: word;

type

  FindData = record
Attributes: longint;
  CreationTime,
  LastAccessTime,
  ModificationTime: comp;  {<- old MS-DOS one}
  FileSizeHigh,
  FileSizeLow: longint;
  Reserved: array[1..8] of byte;
  LongFileName: array[1..260] of char;
  FileName: array[1..14] of char;
  End;

function ASCIZToString (ASCIZ: array of Char): String;
begin
ASCIZToString := StrPas (@ASCIZ);
end;

function FindFirst (Path: String; Attr: word; var F: FindData): word;
assembler;
asm
  mov     LFNError, 0

push    ds
  lds     si, Path
  mov     dx, si
  inc     dx
  mov     cl, [si]

@@StringToPChar:
  inc     si
  dec     cl
  jnz     @@StringToPChar

  inc     si
  mov     byte ptr [si], 0

  les     di, F

  mov     cx, Attr
  mov     ax, 714Eh
  mov     si, 1

  int     21h                          ;{CF set on error}
  pop     ds
  jnc     @@NoCarry

  mov     LFNError, ax
  jmp     @@Exit

@@NoCarry:
cmp     ax, 7100h
  jne     @@Exit

  mov     LFNError, ax

@@Exit:
end;

procedure FindNext (var F: FindData; FileFindHandle: word); assembler;
asm
  mov     LFNError, 0

  mov     ax, 714Fh
  mov     si, 1
  mov     bx, FileFindHandle
  les     di, F

  int     21h

  jnc     @@NoCarry

  mov     LFNError, ax
  jmp     @@Exit

@@NoCarry:
cmp     ax, 7100h
  jne     @@Exit

  mov     LFNError, ax

@@Exit:
end;

procedure FindClose (FileFindHandle: word); assembler;
asm
  mov     LFNError, 0

  mov     ax, 71A1h
  mov     bx, FileFindHandle

  int     21h

  jnc     @@NoCarry

  mov     LFNError, ax
  jmp     @@Exit

@@NoCarry:
cmp     ax, 7100h
  jne     @@Exit

  mov     LFNError, ax

@@Exit:
end;

const
nshpers: longint = 1000000000 div 100;
sixty:word=60;
  thirtysixhundred:word=3600;
  hoursconst:longint=86400;

{procedure extime (time:comp;var dt:DateTime); assembler;
asm
  les     di, dt
  add     di, OFFSET DateTime. Minute
  mov     ax, es:[di]
end;}
(*
procedure expandtime (time: comp; var dt:DateTime);
assembler;
{
time = number of 100 nanosecond intervals since midnight, 1st January, 1601
yes, 1601.
second = (time / 10000000) mod 60
minute = ((time / 10000000) mod 3600) div 60

}
var
Dummy: Word;

asm

;{
COMMENT ENDCOMMENT
  blah
  blah
ENDCOMMENT
;}

  les     di, dt
  add     di, OFFSET DateTime. Sec

  ;{find seconds}
  finit                                ;{clear the stack for me!}
  fild    time                         ;{load the time into ST(0)}
  fidiv   nshpers                      ;{get the number of seconds since..}
  fst     ST(1)                        ;{save a copy for later..}
  fild    sixty                        ;{ST(0) := 60; (time -> ST(1))}
  fxch                                 ;{swap ST(1) and (0)}
  fprem                                ;{ST(0) := ST(0) mod ST(1);}
  fistp   word ptr es:[di]             ;{dt. sec := ST(0)}
  sub     di, 2                        ;{es:[di] points to dt. min}

  ;{find minutes}
  fistp   Dummy                        ;{get rid of ST(0) (60)}
  fst     ST(2)                        ;{save a copy of new time for later..}
  fild    thirtysixhundred             ;{ST(0) := 3600; (time -> ST(1))}
  fxch                                 ;{exchange ST0/1}
  fprem                                ;{ST(0) := ST(0) mod ST(1);}
  fxch                                 ;{exchange ST0/1}
  fistp   Dummy                        ;{get rid of ST(0) (3600)}
  fidiv   sixty                        ;{ST(0) := ST(0) / ST(1) (60)}
  fst     ST(1)                        ;{make a copy of minutes for later..}
  frndint                              ;{round off ST(1) to nearest int.}
  fcom                                 ;{compare rounded & unrounded}
  fstsw   ax                           ;{store FPU status to ax}
  sahf                                 ;{store ah to CPU status}
{ jp      Error}                       ;{C2 (->parity) set on compare error}
  jc      @@NotGreater                 ;{C0 (->carry) set on less or error}
  jz      @@NotGreater                 ;{C3 (->zero) set on equal or error}
                                       ;{correct for rounding up! (no trunc)}
  fld1                                 ;{ST(0) := 1 (round (minutes) -> ST(1))
  fsub                                 ;{ST(0) := ST(0) - ST(1) (minutes-1)}
@@NotGreater:                          ;{minutes was rounded down, or cont.}
  fistp   word ptr es:[di]             ;{dt. min := ST(0)}
  sub     di, 2                        ;{es:[di] points to dt. hour}

  ;{find hours}
  fistp   Dummy                        ;{get rid of ST(0) (60)}
  fst     ST(2)                        ;{save a copy of new time for later..}
  fild    hoursconst                   ;{ST(0) := 3600*24; (time -> ST(1))}
  fxch                                 ;{exchange ST0/1}
  fprem                                ;{ST(0) := ST(0) mod ST(1);}
  fxch                                 ;{exchange ST0/1}
  fistp   Dummy                        ;{get rid of ST(0) (3600)}
  fidiv   thirtysixhundred             ;{ST(0) := ST(0) / ST(1) (3600)}
  fst     ST(1)                        ;{make a copy of minutes for later..}
  frndint                              ;{round off ST(1) to nearest int.}
  fcom                                 ;{compare rounded & unrounded}
  fstsw   ax                           ;{store FPU status to ax}
  sahf                                 ;{store ah to CPU status}
{ jp      Error}                       ;{C2 (->parity) set on compare error}
  jc      @@NotGreater2                ;{C0 (->carry) set on less or error}
  jz      @@NotGreater2                ;{C3 (->zero) set on equal or error}
                                       ;{correct for rounding up! (no trunc)}
  fld1                                 ;{ST(0) := 1 (round (minutes) -> ST(1))
  fsub                                 ;{ST(0) := ST(0) - ST(1) (minutes-1)}
@@NotGreater2:                         ;{minutes was rounded down, or cont.}
  fistp   word ptr es:[di]             ;{dt. min := ST(0)}
  sub     di, 2                        ;{es:[di] points to dt. hour}

end;


{  fxchg
  fild    nshpers

  fdiv}

{begin
  time := trunc (time / (1000*1000*1000/100));
  second := time mod 60;
  minute := time mod (60*60) div 60;
  hour := time mod (60*60*60) div (60*60);
end;}
*)
function long (c: comp):word; assembler;
asm
mov dx, word ptr c[2]
  mov ax, word ptr c[0]
end;

var
Find: FindData;
  FileFindHandle: Word;
  dt: DateTime;

begin
  { change this to suit your drive !! }
  FileFindHandle := FindFirst ('d:\PROGRAM FILES\*.*', 255, Find);

  repeat
  If Not (LFNError = 0) Then begin
      halt;
    end;
    unpacktime (long (find. modificationtime), dt);
    {expandtime (find. modificationtime, dt);}

  WriteLn (ASCIZToString (Find. FileName),
ASCIZToString (Find. LongFileName), dt. hour, ':', dt. min, ':', dt. sec);
{    writeln (x);}
    FindNext (Find, FileFindHandle);
  Until (LFNError <> 0);

  FindClose (FileFindHandle);
End.
