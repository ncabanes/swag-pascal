
program test {also untested};

var
  testbyte: byte;

function testbit(testbyte,bit:byte):boolean; assembler;
asm
  mov  cl,bit
  mov  ah,1
  shl  ah,cl
  mov  al,testbyte
  and  al,ah
end;

procedure setbit(var testbyte:byte; bit:byte); assembler;
asm
  mov  cl,bit
  mov  al,1
  shl  al,cl
  les  di,[testbyte]
  or   [es:di],al
end;

procedure clearbit(var testbyte:byte; bit:byte); assembler;
asm
  mov  cl,bit
  mov  al,1
  shl  al,cl
  not  al
  les  di,[testbyte]
  and  [es:di],al
end;

begin
  testbyte := 0;
  setbit(testbyte,2);
  setbit(testbyte,5);
  if testbit(testbyte,2) then writeln('2 is ON');
  if not testbit(testbyte,3) then writeln('3 is OFF');
end.

