{******************************************************************
 * Create a function for returning a fully qualified path/file    *
 * string, with the *'s replaced by the appropriate number of ?'s.*
 *                                                                *
 * (C) Daniel A. Bronstein, Michigan State University, 1991.      *
 *     May be used freely with acknowledgement.                   *
 *****************************************************************}

unit qualify;

Interface
uses dos;                    {for pathstr definition}

function fqualify(var ps:pathstr):pathstr;

Implementation

{$F+} {Far call so loading of the variable is simplified for asm.}
function fqualify(var ps:pathstr):pathstr;
begin
  asm
    push  ds                 {Save DS, else will crash after exit}
    push  si                 {and just to be safe, save SI too.}
    lds   si,ps              {Load address of pathstring,}
    xor   ax,ax              {clear AX,}
    cld                      {set direction flag and}
    lodsb                    {get length byte, incrementing SI.}
    mov   bx,ax              {Move length to BX and add}
    mov   byte ptr[si+bx],0  {a #0 to end to create ASCIIZ string.}
    les   di,@result         {Load address of the output string}
    mov   bx,di              {and save it in BX.}
    inc   di                 {Point past length byte of result}
    mov   ah,60h             {and call DOS function 60h.}
    int   21h
    jnc   @ok                {If no carry then ok, else return}
    mov   byte ptr[es:bx],0  {a 0 length string.}
    jmp   @xit
@ok:
    xor   cx,cx              {Clear CX and}
@0loop:
    inc   di                 {loop until find end of returned}
    inc   cx                 {ASCIIZ string.}
    cmp   byte ptr[es:di],0  {**Note that on 286 & 386 inc/cmp is faster}
    jne   @0loop             {**than CMPSB, so used here.}
    mov   byte ptr[es:bx],cl {Set the length byte of the result.}
@xit:
    pop   si                 {Restore SI and}
    pop   ds                 {DS, then}
  end;                       {exit.}
end;
{$F-}

begin
end.

{ ==================================  DEMO    ============================}

PROGRAM Qualtest;

USES DOS, Qualify;

VAR
  MyString, YourString : PathStr;

BEGIN
  MyString := 'Foo*.*';
  YourString := FQualify(MyString);
  Writeln(YourString);
  Readln;

END.