{
 IH> About detecting Windows 95, is it possible to detect
 IH> it even when the "prevent program to detect windows"
 IH> flag is set to "ON"?

Ummm... Perhaps you could check environment for "winbootdir=" entry (note
lowercase!). Additionally, in DPMI programs you might check DPMI provider to
see if it's Win95.Generally, from early betas of Win95 up to now, the
following sequence appears to be working OK:
1.  Check DOS version, if 7.0, may be Win95.
2.  Check "winbootdir" in environment, it's always there in Win95.
3.  Check for long file names to see if Win95 GUI is loaded.

If all three tests are OK, you can safely assume running under Win95, in a
windowed or full-screen DOS session, regardless of "detect windows" setting.

DOS version can be obtained by standard means (DOSVersion in TP/BP).
To check environment for lovercase "winbootdir", you must be sure that your
searching function does not convert strings to uppercase (TP's DOS unit does,
yet BP's WinDOS does not). For BP7, the following code might be useful:
}

uses Strings;

function GetAnyCaseEnv(VarName: PChar): PChar;
var
  L: Word; P: PChar;
begin
  L := StrLen(VarName);
  P := Ptr(Word(Ptr(PrefixSeg, $2C)^), 0);
  while P^ <> #0 do begin
    if (StrLIComp(P, VarName, L) = 0) and (P[L] = '=') then begin
      GetAnyCaseEnv := P + L + 1; Exit;
    end;
    Inc(P, StrLen(P) + 1);
  end;
  GetAnyCaseEnv := nil;
end;
{
if GetAnyCaseEnv('winbootdir') returns non-NIL string, you might check for
long names, as these are supported by Win95 in GUI mode only (not in
DOS-mode).
}

function GetCurLongDir(Dir: PChar; Drive: Byte): PChar; assembler;
asm
     mov al,Drive
     or al,al
     jne @@1
     mov ah,19h
     int 21H
     inc ax
@@1: mov dl,al
     push ds
     lds si,Dir
     push ds
     push si
     mov byte ptr es:[si],0
     mov ax,7147h   { note AH=$71, AL=$47, not AH=$47 as in standard DOS }
     int 21h
     pop ax
     pop dx
     pop ds
end;

To check for long names, use e.g.:

var p:PChar;
...
  GetMem(p,256);
  If StrLen(GetCurLongDir(p,0)) > 0 then { Long names supported };
  FreeMem(p,256);


