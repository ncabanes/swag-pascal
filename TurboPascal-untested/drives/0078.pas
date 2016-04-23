{SWAG=DOS.SWG,BJÖRN FELTEN,TRUENAME (BASM)}

{ Updated DOS.SWG on August 24, 1994 }



program TName;  { to test the TrueName function }

function TrueName(var P: string): string; assembler;
{ returns TrueName just like the DOS command does }
{ if error, returns a zero length string }
{ will probably crash for DOS versions < 3.0 }
{ donated to the Public Domain by Björn Felten @ 2:203/208 }
asm
   push  ds
   lds   si,P
@strip:
   inc   si     { skip length byte ... }
   cmp   byte ptr [si],' '
   jle   @strip { ... and trailing white space }

   les   di,@Result
   inc   di     { leave room for byte count }
   mov   ah,60h { undocumented DOS call }
   int   21h
   pop   ds
   jc    @error

   mov   cx,80  { convert ASCIZ to Pascal string }
   xor   ax,ax
   repnz scasb  { find trailing zero }
   mov   ax,80
   sub   ax,cx  { get length byte }
   jmp   @ret

@error:
   xor   ax,ax  { return zero length string }

@ret:
   les   di,@Result
   stosb
end;


var S:string;
begin
   S:=paramstr(1);
   if paramcount<>1 then
      writeln('Usage: tname <filename>')
   else
      writeln('TrueName of ',S,' is ',TrueName(S))
end.
