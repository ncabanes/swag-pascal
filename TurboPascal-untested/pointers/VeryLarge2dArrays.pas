(*
  Category: SWAG Title: POINTERS, LINKING, LISTS, TREES
  Original name: 0039.PAS
  Description: Very Large 2d arrays
  Author: LEOPOLDO SALVO MASSIEU
  Date: 11-29-96  08:17
*)

> > I'm working on a program where it would be very convenient
> >to use very large 2d arrays (40X3000 elements of type real, or
> >thereabouts) Is there any way to do this in TP7?
> >
> See URL in sig, but you may need BP since you call for 720000 bytes or
> thereabouts.  See also #FloatTypes.
>

{

Leopoldo Salvo Massieu. e-mail lsm@teleline.es  -and-
a900040@zipi.fi.upm.es

Object Storage is a zero-based array, just tell how many elements you 
want to store and what's the size in bytes of each element (use sizeof). 
It can allocate all heap available (also in Protected Mode). There's a
little demo down.
}

unit ALMACEN;

interface
         USES GRAPH;

         const Not_enough_memory = -100;
               Element_too_big = -101;
               File_Not_Found = -102;
               Error_Writing_File = -103;

         type pointerarray = array [0..16200] of pointer;

              {Zero-based array}
              PStorage = ^Storage;
              storage = object
                          private
                             elements_x_pointer, elem_size : word;
                             num_pointers, last_pointer_size : word;
                             data : ^pointerarray;
                             max : longint;
                             out_of_mem : boolean;
                          public
                             constructor init (num_elements : longint;
                                               element_size : word);
                             destructor done;
                             procedure put (pos : longint; p : pointer);
                             procedure get (pos : longint; VAR p :
pointer);
                             function save (filename : string) :
integer; virtual;
                             function load (filename : string) : 
integer; virtual;
                        end;


implementation


(****************************************
object storage
****************************************)

const max_allocatable_ram : word = 65528;

constructor storage.init;
var memoria : longint;
    aux : longint;
    pneeded : word;
    i : integer;
begin
    memoria:=num_elements*element_size;
    elements_x_pointer:=max_allocatable_ram div element_size;
    max:=num_elements;
    pneeded:=(num_elements*element_size div max_allocatable_ram)+2;
    if (memoria+16000>memavail) or (elements_x_pointer=0)
       or (pneeded>16200) then
     begin
       Out_Of_Mem:=true;
       Fail;
     end;
    getmem (data, pneeded*sizeof(pointer));
    num_pointers:=0;
    for i:=1 to pneeded do data^[i]:=Nil;
    while num_elements>elements_x_pointer do
      begin
        getmem (data^[num_pointers], elements_x_pointer*element_size);
        fillchar (data^[num_pointers]^,elements_x_pointer*element_size,0);
        inc (num_pointers);
        dec (num_elements, elements_x_pointer);
      end;
    if (num_elements>0) then
     begin
       getmem (data^[num_pointers], num_elements*element_size);
       fillchar (data^[num_pointers]^, num_elements*element_size,0);
       last_pointer_size:=num_elements*element_size
     end
    else
       last_pointer_size:=elements_x_pointer*element_size;
    elem_size:=element_size;
end;

destructor storage.done;
var i : longint;
begin
   if num_pointers>0 then
    for i:=0 to num_pointers-1 do
     if data^[i]<>NIL then freemem (data^[i], elements_x_pointer*elem_size);
   if data^[num_pointers]<>nil then freemem (data^[num_pointers], last_pointer_size);
   if data<>NIL then freemem (data, num_pointers*sizeof(pointer));
   max:=-1;
end;

procedure storage.put;
type table = array [0..65528] of byte;
var numpunt : longint;
    desp : word;
begin
  if (pos>=0) and (pos<max) then
   begin
    numpunt:=pos div elements_x_pointer;
    desp:=(pos-numpunt*elements_x_pointer)*elem_size;
    move (p^, table(data^[numpunt]^)[desp], elem_size);
   end
  else
   inc(pos)
end;

procedure storage.get;
type table = array [0..65528] of byte;
var numpunt : longint;
    desp : word;
begin
  if (pos>=0) and (pos<max) then
   begin
    numpunt:=pos div elements_x_pointer;
    desp:=(pos-numpunt*elements_x_pointer)*elem_size;
    p:=addr(table(data^[numpunt]^)[desp]);
   end
  else
   halt (23)
end;

function storage.save;
var f : file;
    i, res : integer;
    escr : word;
begin
   assign (f, filename);
   {$I-}
      rewrite (f,1);
   {$I+}
   res:=ioresult;
   if res=0 then
    begin
     {$I-}
       blockwrite (f, elements_x_pointer, sizeof(elements_x_pointer));
       blockwrite (f, elem_size, sizeof(elem_size));
       blockwrite (f, num_pointers, sizeof(num_pointers));
       blockwrite (f, last_pointer_size, sizeof(last_pointer_size));
       blockwrite (f, max, sizeof(max));
     {$I+}
     res:=ioresult;
     if res<>0 then begin save:=res; exit; end;
     if num_pointers>0 then
      begin
        for i:=0 to num_pointers-1 do
         begin
          {$I-}
           blockwrite (f, data^[i]^, elements_x_pointer*elem_size,escr);
          {$I+}
          res:=ioresult; if res<>0 then begin write ('{#',res,',',escr,'}'); break; end
         end;
       if res=0 then
        begin
         {$I-}
           blockwrite (f, data^[num_pointers]^, last_pointer_size,  escr);
         {$I+}
         res:=ioresult; if res<>0 then begin write ('{@',res,',',escr,'}'); end
        end;
      end;
    end;
   save:=res;
   {$I-}
     close (f);
   {$I+}
   res:=ioresult;
end;

function storage.load;
var f : file;
    i, res : integer;
    lect,exp,es,np,lps :word;
    m : longint;
begin
   assign (f, filename);
   {$I-}
      reset (f,1);
   {$I+}
   res:=ioresult;
   if res<>0 then begin load:=res; exit; end;
   {$I-}
     blockread (f, exp, sizeof(elements_x_pointer));
     blockread (f, es, sizeof(elem_size));
     blockread (f, np, sizeof(num_pointers));
     blockread (f, lps, sizeof(last_pointer_size));
     blockread (f, m, sizeof(max));
   {$I+}
   res:=ioresult;
   if res<>0 then begin load:=res; exit; end;
   if ( (np>0) and (longint(exp)*(np-1)*es+lps+32000>memavail) ) or
      ( (np=0) and (lps+32000>memavail) ) then
       begin writeln; writeln ('np: ', np, 'exp: ', exp, 'es: ', es,' 
             lps: ',lps); out_of_mem:=true; exit; end;
   done;
   elements_x_pointer:=exp; elem_size:=es; num_pointers:=np;
   last_pointer_size:=lps; max:=m;
   getmem (data, num_pointers*sizeof(pointer));
   if num_pointers>0 then for i:=0 to num_pointers-1 do
         getmem (data^[i], elements_x_pointer*elem_size);
   getmem (data^[num_pointers], last_pointer_size);
   out_of_mem:=false;
   if num_pointers>0 then
    begin
     for i:=0 to num_pointers-1 do
      begin
       {$I-}
        blockread (f, data^[i]^, elements_x_pointer*elem_size, lect);
       {$I+}
       res:=ioresult; if res<>0 then begin write ('{&',res,',',lect,'}'); break; end
      end;
     if res=0 then
      begin
       {$I-}
        blockwrite (f, data^[num_pointers]^, last_pointer_size);
       {$I+}
       res:=ioresult; if res<>0 then begin write ('{&',res,',',lect,'}'); end
      end;
    end;
   load:=res;
   {$I-}
     close (f);
   {$I+}
   res:=ioresult;
end;

end. {of unit almacen}



{and now a little demo (compile under protected mode or there will be 
not enough heap}


uses almacen;

type  ptipe = ^tipe;
      tipe = real;

const rows : longint = 40;
      columns : longint = 30000;

var store : ^storage;

    y,x : longint; {y=1..40
                    x=1..30000}

    r : tipe;
    pr : ptipe;

begin
   new (store, init(rows*columns, sizeof(real)));
   if (store=nil) then
    begin
      writeln ('Out of memory.');
      exit;
    end;
   for y:=0 to rows-1 do
    for x:=0 to columns-1 do
     begin
      r:=y*columns+x;
      store^.put(y*columns+x, @r);
     end;
   for y:=0 to rows-1 do
    for x:=0 to columns-1 do
     begin
      store^.get(y*columns+x, pointer(pr));
      if (pr^<>y*columns+x) then
       begin
        writeln ('Error... (Hopefully Impossible)');
        break;
       end
      else write ('.');
     end;
   dispose (store, done);
end.


