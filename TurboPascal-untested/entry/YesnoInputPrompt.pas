(*
  Category: SWAG Title: INPUT AND FIELD ENTRY ROUTINES
  Original name: 0034.PAS
  Description: Yes/No Input Prompt
  Author: BRIAN PETERSEN
  Date: 05-31-96  09:17
*)

{
Here is just what you're looking for.  I don't know if you have learned about
"functions" yet, but it's what I'm giving to you.  :-)  A function is just a
procedure which returns a variable (of the type you choose) that is set within
the function before it terminates.  Anyway, here goes...
}

function yesno(const s:string):boolean;
var c:char;
begin
  write(s);
  repeat
    asm
      xor ax,ax
      int 16h
      mov dl,al
      mov ax,6520h
      int 21h
      mov c,dl
    end;
  until c in ['Y','N'];
  writeln(c);
  yesno:=(c='Y');
end;

And now, here is an example of how you use it.

begin
  if yesno('Put "HELLO" on the screen? (y/n) : ') then begin
    writeln('HELLO');
  end else begin
    writeln('Fine, then!  Forget it.');
  end;
end.


