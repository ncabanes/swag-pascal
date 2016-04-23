
Unit Xalloc; { EXPanded Memory Unit }

Interface

Const nilpage=$ff;

type xaddress = record
      page:byte;
      pos :word;
      end;

function  xalloc_init:boolean;
procedure xgetmem(var x:xaddress;size:word);
procedure xfreemem(var x:xaddress;size:word);
function  xpage_in(var x:xaddress):pointer;
function  xmaxavail:longint;
function  xmemavail:longint;
procedure xalloc_done;

implementation

uses dos,crt;

const
  emm_int = $67;
  dos_int = $21;
  maxfreeblock = 4000;
  xblocksize = $4000;
  _get_frame = $41;
  _unalloc_cound = $42;
  _alloc_pages = $43;
  _map_page = $44;
  _dealloc_pages = $45;
  _change_alloc = $51;

type
    xheap = array[0..1000] of word;
    fblock = record
     page:byte;
     start,stop:word;
     end;
    fblockarray = array[1..maxfreeblock] of fblock;
var
   regs:registers;
   handle,tot_pages:word;
   xheapptr:^xheap;
   xfreeptr:^fblockarray;
   last_page,lastptr:integer;
   map: array[0..3] of integer;
   frame:word;

function ems_isntalled: boolean;
  const device_name: string[8]='EMMXXXX0';
  var i:integer;
  begin
  ems_installed:=false;
  with regs do
     begin
     ah:=$35;
     al := emm_int;
     intr(dos_int,regs);
     for i:=1 to 8 do if device_name[i]<>chr(mem[es:i+9]) then exit;
     end;
  ems_installed:=true;
  end;

function unalloc_count(var available: word):boolean;
 begin
 with regs do
  begin
  ah := _unalloc_count;
  intr(emm_int,regs);
  available := bx;
  unalloc_count := ah = 0;
  end;
 end; 
  
Function alloc_pages(needed:integer):boolean;
 begin
 with regs do
   begin
   ah := _alloc_pages;
   bx := needed;
   intr(emm_int,regs);
   handle := dx;
   alloc_pages := ah = 0;
   end;
 end;  

function xdealloc_pages: boolean;
 begin
 with regs do begin
   ah := _dealloc_pages;
   dx := handle;
   intr(emm_int,regs);
   xdealloc_pages := ah = 0;
   end;
 end;
 
function change_alloc(needed: integer): boolean;
 begin
 with regs do begin
   ah := _change_alloc;
   bx := needed;
   dx := handle;
   intr(emm_int,regs);
   change_alloc := ah=0;
   end;
 end;
 


 
