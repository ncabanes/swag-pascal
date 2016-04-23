
{ Updated MISC.SWG on May 26, 1995 }

{
> PROCEDURE test(portno: word; value: byte; VAR result: BYTE);
> ASSEMBLER;
> ASM
> mov dx, portno
> mov al, value
> out dx, al
> in dx, al
> mov di, OFS(result); (*)
> stosb
> END;

> (*): This is the problem: you can't use the OFS() function
> in an ASM statement.

No problem. You use les di,result.
}

procedure test(portno:word; value:byte; var result:byte);
assembler; asm
 mov dx,portno
 mov al,value
 out dx,al
 in dx,al
 les di,result
 mov es:[di],al
end;

{
es:di becomes segment:offset to Result. I think this would work as a
function better. It is similar but less code. Function results are in
AX for works, AL for bytes, AX:DX for pointers.
}

function test(portno:word; value:byte:byte;
assembler; asm
 mov dx,portno
 mov al,value
 out dx,al
 in dx,al
end;

{
All done. AL's value is returned as the Byte result right away.
}
