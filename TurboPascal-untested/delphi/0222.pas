
In the old days writing to ports on your computer was easy; all you had
to do was use the port[ n ] command.

Delphi no longer supports the port[ n ] command, so you have to use
functions like:

function ReadPortB( wPort : Word ) : Byte;
begin
asm
mov dx, wPort
in al, dx
mov result, al
end;
end;

procedure WritePortB( wPort : Word; bValue : Byte );
begin
asm
mov dx, wPort
mov al, bValue
out dx, al
end;
end;



                                Of course, your operating system may not let you write to certain ports,
                                specially if you're running on Windows NT. 