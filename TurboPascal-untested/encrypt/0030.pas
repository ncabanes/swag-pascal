{
 EH> But if it isn't a VAR parameter it IS copied afterwards (out of the
 EH> manual, Inside Turbo Pascal): Value parameters are passed by value or
 EH> by reference depending on the size and type of the parameter. (deleted
 EH> when passed by value). Otherwise a pointer to the value is pushed and
 EH> the procedure or function THEN COPIES the value into a LOCAL storage
 EH> location. (my capitalisation)

Yeah, well that's fine and dandy in theory, but...

 EH> So the startup code of the procedure WILL make local copies of all
 EH> "non-VAR" parameters that are passed "by reference".

get a load of this.
}

program crypt;

procedure cipher2 (s:string; dest:string); assembler;
asm
  push ds;
  lds si, s;
  les di, dest;
  lodsb;
  stosb;
  mov cl, al;
  xor ch, ch;
@@EncryptionLoop:
  lodsb;
  rol al, 2;
  stosb;
  loop @@EncryptionLoop;
  pop ds;
end;

procedure decipher2 (s:string; dest:string); assembler;
asm
  push ds;
  lds si, s;
  les di, dest;
  lodsb;
  stosb;
  mov cl, al;
  xor ch, ch;
@@EncryptionLoop:
  lodsb;
  ror al, 2;
  stosb;
  loop @@EncryptionLoop;
  pop ds;
end;

var notsecret, notsecret2, secret:string;

begin
  notsecret:='This is the secret stuff.';
  writeln;
  writeln('This should NOT be encrypted: "'+notsecret+'"');
  cipher2 (notsecret, secret);
  writeln('This SHOULD be encrypted....: "'+secret+'"');
  decipher2 (secret, notsecret2);
  writeln('This SHOULD NOT be encrypted....: "'+notsecret2+'"');
end.

