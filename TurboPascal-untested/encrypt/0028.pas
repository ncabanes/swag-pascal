{$q-,r-,s-,d-,l-,y-,x-,v-,t-,n-,e-}

uses dos;

const
  bytesperline=45;         { maximum bytes per encoded line }
  masque6bits=$3f;        { mask for six lower bits }

procedure encodebuffer(var buf; len:word; var res:string); assembler ;
asm
  push ds
  cld
  lds si,buf
  les di,res
  mov cx,len
  inc di
  mov al,cl
  add al,' '
  stosb
  mov dl,1
@1:
  lodsb
  mov bl,al
  shr al,2
  add al,' '
  stosb
  shl bl,4
  lodsb
  mov bh,al
  shr al,4
  or  al,bl
  and al,masque6bits
  add al,' '
  stosb
  lodsb
  mov bl,al
  and bh,$0f
  shl al,1
  rcl bh,1
  shl al,1
  rcl bh,1
  mov al,bh
  add al,' '
  stosb
  mov al,bl
  and al,masque6bits
  add al,' '
  stosb
  add dl,4
  sub cx,3
  ja  @1
  mov di,word ptr res
  mov es:[di],dl
  pop ds
end;

procedure replacespacewithbackquote(var str:string); assembler;
asm
  les di,str
  mov cl,es:[di]
  xor ch,ch
  cld
  inc di
  mov ax,'`'*256+' '
@1:
  jcxz @2
  repne scasb
  jne @2
  mov es:[di-1],ah
  jmp @1
@2:
end;

var
  inbuf:array[1..100*bytesperline]of byte;
  outbuf:array[1..8192] of char;

procedure encodefile(fname:string);
var
  inf:file;
  outf:text;
  outb:string[bytesperline*4 div 3+4];
  lus:word;
  inp:word;
  nb:word;
  rep:pathstr;
  nom:namestr;
  ext:extstr;
begin
  assign(inf,fname);
  {$i-} reset(inf,1); {$i+}
  if(ioresult<>0)then
  begin
    writeln('Can''t open ',fname);
    exit;
  end;
  fsplit(fname,rep,nom,ext);
  assign(outf,nom+'.uue');
  rewrite(outf);
  settextbuf(outf,outbuf,sizeof(outbuf));
  writeln(outf,'begin 644 ',nom,ext);
  while not eof(inf)do
  begin
    blockread(inf,inbuf,sizeof(inbuf),lus);
    inp:=1;
    if(lus<sizeof(inbuf))then
    fillchar(inbuf[lus+1],sizeof(inbuf)-lus,0);
    while(inp<=lus)do
    begin
      nb:=lus-inp+1;
      if(nb>bytesperline)then nb:=bytesperline;
      encodebuffer(inbuf[inp],nb,outb);
      replacespacewithbackquote(outb);
      writeln(outf,outb);
      inc(inp,nb);
    end;
  end;
  close(inf);
  writeln(outf,'`');
  writeln(outf,'end');
  close(outf);
end;

begin
  if(paramcount<>1)then
  begin
    writeln('uue2 <file name>');
    halt(1);
  end;
  encodefile(paramstr(1));
end.