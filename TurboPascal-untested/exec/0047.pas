unit exeend;

INTERFACE

var
  endofexe,sizeofdata:longint;
  data:boolean;

function getexeinfo(const name:string;var data:boolean; var endofexe,sizeofdata:longint):boolean;

IMPLEMENTATION

function getexeinfo(const name:string; var data:boolean; var endofexe,sizeofdata:longint):boolean;
const
  magic=$5a4d; {'mz'}
var
  header:array[1..3]of word; {id,bytemod,pages}
  br:word;
  f:file;
begin
  getexeinfo:=false;
  data:=false;
  endofexe:=0;
  sizeofdata:=0;
  if(name='.')or(name='')then exit;
  assign(f,name);
  {$i-} reset(f,1); {$i+}
  if(ioresult<>0)then exit;
  {$i-} blockread(f,header,sizeof(header),br); {$i+}
  if(ioresult<>0)then exit;
  if(br<>sizeof(header))or(header[1]<>magic)then exit;
  endofexe:=longint(header[3]-1)*512+header[2];
  sizeofdata:=(filesize(f)-endofexe);
  close(f);
  data:=(sizeofdata>0);
  getexeinfo:=true;
end;

function dosmajor:byte; assembler;
asm
  mov ah,030h
  int 21h
end;

begin
  if(dosmajor>=3)then getexeinfo(paramstr(0),data,endofexe,sizeofdata)else
     getexeinfo('.',data,endofexe,sizeofdata);
end.