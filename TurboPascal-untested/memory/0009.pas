{This is a Unit MEMALLOC.PAS For use With the .VOC player...}
Unit MemAlloc;

{ Purpose is to provide the ability to create (destroy) dynamic Variables  }
{ without needing to reserve heap space at Compile time.                   }

Interface

Function Malloc(Var Ptr; Size : Word) : Word;
{ Allocate free memory and return a Pointer to it.  The amount of memory
{ requested from Dos is calculated as (Size/4)+1 paraGraphs.  if the
{ allocation is successful, the unTyped Var parameter Ptr will be populated
{ With the address of the allocated memory block, and the Function will return}
{ a zero result.  Should the request to Dos fail, Ptr will be populated with
{ the value NIL, and the Function will return the appropriate Dos error code.
}

Function Dalloc(Var Ptr) : Word;
{ Deallocate the memory pointed to by the unTyped Var parameter Ptr
}

Function DosMemAvail : LongInt;
{ Return the size of the largest contiguous chuck of memory available For use
}

{ ---------------------------------------------------------------------------
}

Implementation

{ ---------------------------------------------------------------------------
}

Function Malloc(Var Ptr; Size : Word) : Word;
begin
   Inline(
     $8B/$46/<SIZE/         {            mov         ax,[bp+<Size]}
     $B9/$04/$00/           {            mov         cx,4}
     $D3/$E8/               {            shr         ax,cl}
     $40/                   {            inc         ax}
     $89/$C3/               {            mov         bx,ax}
     $B4/$48/               {            mov         ah,$48}
     $CD/$21/               {            int         $21             ;Allocate memory}
     $72/$07/               {            jc          AllocErr        ;if any errors ....}
     $C7/$46/$FE/$00/$00/   {NoErrors:   mov Word    [bp-2],0        ;Return 0 For successful allocation}
     $EB/$05/               {            jmp short   Exit}
     $89/$46/$FE/           {AllocErr:   mov         [bp-2],ax       ;Return error code}
     $31/$C0/               {            xor         ax,ax           ;Store a NIL value into the ptr}
     $C4/$7E/<PTR/          {Exit:       les         di,[bp+<Ptr]    ;Address of Pointer into es:di}
     $50/                   {            push        ax              ;Save the Segment part}
     $31/$C0/               {            xor         ax,ax           ;offset is always 0}
     $FC/                   {            cld                         ;Make sure direction is upward}
     $AB/                   {            stosw                       ;Store offset of memory block}
     $58/                   {            pop         ax              ;Get back segment part}
     $AB);                  {            stosw                       ;Store segment of memory block}

end {Malloc};

{ ---------------------------------------------------------------------------
}

Function Dalloc(Var Ptr) : Word;
begin
   if Pointer(Ptr) <> NIL then begin
      Inline(
        $B4/$49/               {            mov         ah,$49}
        $C4/$7E/<PTR/          {            les         di,[bp+<Ptr]}
        $26/$C4/$3D/           {        es: les         di,[di]}
        $CD/$21/               {            int         $21}
        $72/$02/               {            jc          Exit}
        $31/$C0/               {NoError:    xor         ax,ax}
        $89/$46/$FE);          {Exit:       mov         [bp-2],ax}
      Pointer(Ptr) := NIL;
   end {if}
   else
      Dalloc := 0;
end {Dealloc};

{ ---------------------------------------------------------------------------
}

Function DosMemAvail : LongInt;
begin
   Inline(
     $BB/$FF/$FF/           {         mov         bx,$FFFF}
     $B4/$48/               {         mov         ah,$48}
     $CD/$21/               {         int         $21}
     $89/$D8/               {         mov         ax,bx}
     $B9/$10/$00/           {         mov         cx,16}
     $F7/$E1/               {         mul         cx}
     $89/$46/$FC/           {         mov         [bp-4],ax}
     $89/$56/$FE);          {         mov         [bp-2],dx}
end; {DosMemAvail}

end. {Unit MemAlloc}

{Ok.. The Code can be rewritten to use GetMem and FreeMem (in fact I suggest
you do this). I rewrote it myself to do so, but this is the distribution copy.
(I made one change in line 316-318 of SBVOICE.PAS bumping up the driver size
from 3000 to 5000 to accomodate the SoundBlaster 2.0 driver)
This Program requires CT-VOICE.DRV which is distributed With the Soundblaster.
}
