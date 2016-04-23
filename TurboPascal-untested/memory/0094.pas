
program XMS;

{ Functions to get to the XMS API }

var XMS_Driver : pointer;

function XMS_get_state : byte; assembler;
asm mov ax,4300h; int 2Fh end;

function XMS_get_entry_point : pointer; assembler;
asm mov ax,4310h; int 2Fh; mov ax,bx; mov dx,es end;


{ XMS API }

type MoveStruct = record
 length    : longint;
 srcHandle : word;
 srcOffset : longint;
 dstHandle : word;
 dstOffset : longint
end;

function XMS_get_version : word; assembler;
asm mov ah,00h; call XMS_Driver end;

function XMS_query : word; assembler;
asm mov ah,08h; call XMS_Driver end;

function XMS_alloc(size : word) : word; assembler;
asm mov ah,09h; call XMS_Driver; mul dx end;

function XMS_free(handle : word) : boolean; assembler;
asm mov ah,0Ah; mov dx,handle; call XMS_Driver end;

function XMS_move(var MoveStructPtr : MoveStruct) : boolean; assembler;
asm mov ah,0Bh; push ds; push ds; pop es; lds si,MoveStructPtr; call
es:XMS_Driver; pop ds end;

{ Main program }

var XMS_version, XMS_handle  : word;

    a : word;
    b : array[0..1999] of real;
    c : MoveStruct;
    d : boolean;

    x,y : word;

begin
 if XMS_get_state = $80 then begin
  XMS_driver := XMS_get_entry_point;

  XMS_version := XMS_get_version;
  writeln('XMS version           : ', hi(XMS_version), '.', lo(XMS_version));

  writeln('Largest available EMB : ', XMS_query, 'KB');
  if XMS_query > 0 then begin

   a := longint(XMS_query) * 1024 div sizeof(b);
   XMS_handle := XMS_alloc(XMS_query);
   if XMS_handle > 0 then begin

    writeln('Number of arrays      : ', a);

    c.length := sizeof(b);
    c.srcHandle := 0;
    c.srcOffset := longint(Addr(b));
    c.dstHandle := XMS_handle;

    for x := 0 to pred(a) do begin
     write('Filling array #       : ', x, #13);
     for y := 0 to 1999 do
      b[y] := x * y;
     c.dstOffset := longint(x) * sizeof(b);
     XMS_move(c);
    end;

    writeln;

    c.srcHandle := XMS_handle;
    c.dstHandle := 0;
    c.dstOffset := longint(Addr(b));

    for x := 0 to pred(a) do begin
     write('Checking array #      : ', x, #13);
     c.srcOffset := longint(x) * sizeof(b);
     XMS_move(c);
     d := true;
     for y := 0 to 1999 do
      d := d and (b[y] = x * y);
     if not d then
      writeln('Error in array #      : ', x)
    end;

    if not XMS_free(XMS_handle) then
     writeln('Error freeing EMB!')

   end else
    writeln('Error Allocating EMB!')

  end else
   writeln('No free XMS memory!')

 end else
  writeln('No XMS driver found!')
end.
