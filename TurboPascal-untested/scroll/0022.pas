unit scroll;

INTERFACE

procedure scroff(const soffset:word);
procedure vfine(const y:byte);
procedure vait;
procedure smooth;
procedure scrpage(const p1,p2:byte);

IMPLEMENTATION

procedure scroff(const soffset:word); assembler;
asm 
  mov dx,03dah
@W1:
  in  al,dx
  test al,8
  jnz @W1
  mov dx,03d4h
  mov bx,soffset
  mov ah,bh
  mov al,00ch
  out dx,ax
  mov ah,bl
  inc al
  out dx,ax
  mov dx,03dah
@W2:
  in  al,dx
  test al,8
  jnz @W2
end;

procedure vfine(const y:byte); assembler;
asm
  mov dx,03dah
@W2:
  in  al,dx
  test al,8
  jz  @W2
  mov dx,03d4h
  mov ah,Y
  mov al,8
  out dx,ax
end;

procedure vait; assembler;
asm
  mov cx,1
  mov ax,250
  @@l1:
    @@l2:
    dec ax
    jnz @@l2
  dec cx
  jnz @@l1
end;

procedure smooth;
var a,i:word;
begin
  for i:=0 to 25 do
  begin
    scroff(i*80);
    for a:=0 to 15 do
    begin
      vfine(a);
      vait;
    end;
  end;
  for i:=25 downto 0 do
  begin
    scroff(i*80);
    for a:=15 downto 0 do
    begin
      vfine(a);
      vait;
    end;
  end;
end;

procedure scrpage(const p1,p2:byte);
var a,i:word;
begin
  if(p1<p2)then
  begin
    for i:=(p1*25)to(p2*24)do
    begin
      scroff(i*80);
      for a:=0 to 15 do
      begin
        vfine(a);
        vait;
      end;
    end;
  end else
  begin
    for i:=(p1*24)downto (p2*24)do
    begin
      scroff(i*80);
      for a:=15 downto 0 do
      begin
        vfine(a);
        vait;
      end;
    end;
  end;
end;

end.