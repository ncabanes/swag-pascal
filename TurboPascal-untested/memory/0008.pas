{$S-,R-,V-,I-,N-,B-,F-}

{$IFNDEF Ver40}
{Allow overlays}
{$F+,O-,X+,A-}
{$ENDIF}

UNIT MemAlloc;

  { Purpose is to provide the ability to create (destroy) dynamic variables  }
  { without needing to reserve heap space at compile time.                   }

INTERFACE

FUNCTION Malloc(VAR Ptr; Size : Word) : Word;
  { Allocate free memory and return a pointer to it.  The amount of memory      }
  { requested from DOS is calculated as (Size/4)+1 paragraphs.  If the          }
  { allocation is successful, the untyped VAR parameter Ptr will be populated   }
  { with the address of the allocated memory block, and the function will return}
  { a zero result.  Should the request to DOS fail, Ptr will be populated with  }
  { the value NIL, and the function will return the appropriate DOS error code. }

FUNCTION Dalloc(VAR Ptr) : Word;
  { Deallocate the memory pointed to by the untyped VAR parameter Ptr           }

IMPLEMENTATION

  FUNCTION Malloc(VAR Ptr; Size : Word) : Word;
  BEGIN
    INLINE(
      $8B / $46 / <Size /         {            mov         ax,[bp+<Size]}
      $B9 / $04 / $00 /           {            mov         cx,4}
      $D3 / $E8 /                 {            shr         ax,cl}
      $40 /                       {            inc         ax}
      $89 / $C3 /                 {            mov         bx,ax}
      $B4 / $48 /                 {            mov         ah,$48}
      $CD / $21 /                 {            int         $21             ;Allocate memory}
      $72 / $07 /                 {            jc          AllocErr        ;If any errors ....}
      $C7 / $46 / $FE / $00 / $00 / {NoErrors:   mov word    [bp-2],0        ;Return 0 for successful allocation}
      $EB / $05 /                 {            jmp short   Exit}
      $89 / $46 / $FE /           {AllocErr:   mov         [bp-2],ax       ;Return error code}
      $31 / $C0 /                 {            xor         ax,ax           ;Store a NIL value into the ptr}
      $C4 / $7E / <Ptr /          {Exit:       les         di,[bp+<Ptr]    ;Address of pointer into es:di}
      $50 /                       {            push        ax              ;Save the Segment part}
      $31 / $C0 /                 {            xor         ax,ax           ;Offset is always 0}
      $FC /                       {            cld                         ;Make sure direction is upward}
      $AB /                       {            stosw                       ;Store offset of memory block}
      $58 /                       {            pop         ax              ;Get back segment part}
      $AB);                       {            stosw                       ;Store segment of memory block}
    
  END {Malloc} ;

  FUNCTION Dalloc(VAR Ptr) : Word;
  BEGIN
    IF Pointer(Ptr) <> NIL THEN BEGIN
      INLINE(
        $B4 / $49 /               {            mov         ah,$49}
        $C4 / $7E / <Ptr /        {            les         di,[bp+<Ptr]}
        $26 / $C4 / $3D /         {        es: les         di,[di]}
        $CD / $21 /               {            int         $21}
        $72 / $02 /               {            jc          Exit}
        $31 / $C0 /               {NoError:    xor         ax,ax}
        $89 / $46 / $FE);         {Exit:       mov         [bp-2],ax}
      Pointer(Ptr) := NIL;
    END {if} ;
  END {Dealloc} ;

END {Unit MemAlloc} .

