
{ Borland Pascal Extended Function Library - EFLIB (C) Johan Larsson, 1996
  Memory engine; handles allocation of data blocks; rewritten Usenet version

  EFLIB IS PROTECTED BY THE COPYRIGHT LAW AND MAY NOT BE COPIED, SOLD OR
  MANIPULATED. FOR MORE INFORMATION, SEE PROGRAM MANUAL!

  THIS IS A SPECIAL RELEASE OF EFLIBS MEMORY ENGINE TO BE PUBLISHED
  IN USENET / SWAGS. THE SOURCE CODE MAY FREELY BE USED NON-COMMERCIALY AS
  LONG AS CREDIT IS GIVEN TO THE PROGRAMMER. THIS UNIT IS INDEPENDENT OF
  OTHER EFLIB COMPONENTS AND DO NOT CONTAIN ALL THE FEATURES INCLUDED
  IN THE REAL VERSION.

  EFLIB is a free OOP toolkit for Borland Pascal. It's free for non-
  commerical use only, and not for business or educational use. EFLIB
  is available through Internet at http://www.ts.umu.se/~jola/EFLIB/.
  Johan Larsson can be reached via E-MAIL (jola@ts.umu.se) or common
  mail (Istidsgatan 33, 2tr., S-906 55 UMEA, Sweden). }


unit EFLIBMEM;


INTERFACE

type { Object that handles a dynamic DOS memory allocation }
     AllocationObjectPointerType       = ^AllocationObjectType;
     AllocationObjectType              = object
                                             public
                                               { Constructors and destructors }
                                               constructor Initialize (ThisSize : word);           { Initializes object }
                                               constructor InitializeEmpty;                        { Initializes empty object }
                                               destructor Intercept; virtual;                      { Intercepts object }
                                               { Miscellaneous methods }
                                               procedure Allocate (ThisSize : word); virtual;      { Allocates memory (bytes) }
                                               procedure Dispose; virtual;                         { Disposes memory }
                                               { Transferration methods }
                                               procedure MoveIn (Source : pointer; SourceSize,
                                                         Position : word); virtual;                { Moves data into object }
                                               procedure MoveOut (Destination : pointer;
                                                         DestinationSize, Position : word);
                                                         virtual;                                  { Moves data out of object }
                                               { Data access methods }
                                               function DataPointer (Position : word) : pointer;   { Returns a data pointer }
                                                        virtual;
                                               function DataSize : word; virtual;                  { Returns the data size }
                                               { Status methods }
                                               function IsAllocated : boolean;                     { Is memory allocated? }
                                             private
                                               { Fields }
                                               Data             : pointer;                         { Data allocation pointer }
                                               Size             : word;                            { Data size in bytes }
                                               { Internal methods }
                                               procedure Clear; virtual;                           { Clear memory }
                                               procedure Error; virtual;                           { Error handler }
                                         end;


{ This unit should compile in both real mode and protected mode Borland
  Pascal, but in protected mode, the following procedures must be
  replaced; }

procedure MoveFAST (var Source, Target; Size : word);
procedure FillWord (var Destination; Count, Data : word);


IMPLEMENTATION

{$B-} {$IFNDEF DEBUG} {$I-} {$S-} {$R-} {$Q-} {$ENDIF}


{ *** AllocationObjectType *** }

{ Initializes object and allocate specified bytes of memory }
constructor AllocationObjectType.Initialize (ThisSize : word);
begin
     { Prepare object (reset fields) }
     InitializeEmpty;
     { Allocate ThisSize number of bytes on the heap }
     Allocate (ThisSize);
end;

{ Initializes object without any data }
constructor AllocationObjectType.InitializeEmpty;
begin
     { Clear allocation variable and reset links }
     Data := NIL; Size := 0;
end;

{ Intercepts object }
destructor AllocationObjectType.Intercept;
begin
     { Dispose allocated data }
     if IsAllocated then Dispose;
end;


{ Allocate memory into AllocationObjectType }
procedure AllocationObjectType.Allocate (ThisSize : word);
begin
     { Allocate memory on the heap }
     GetMem (Data, ThisSize);
     Size := ThisSize; { Adjust size variable }
end;

{ Dispose memory from AllocationObjectType }
procedure AllocationObjectType.Dispose;
begin
     { Dispose memory from the heap }
     if Assigned(Data) then FreeMem (Data, Size);
     { Reset fields }
     Data := NIL; Size := 0;
end;


{ Move a data block into object data block }
procedure AllocationObjectType.MoveIn (Source : pointer; SourceSize, Position : word);
begin
     { Check that data pointer isn't NIL }
     if Assigned(Source) then begin
        { Allocate data if no allocation exists }
        if not IsAllocated then Allocate (SourceSize);

        { Move data from source to current object (prevent overflow) }
        if IsAllocated and (Size >= SourceSize + Position) then
           MoveFAST (Source^, DataPointer(Position)^, SourceSize)
           else Error; { Error; fatal memory allocation error }
      end else Error; { Error; couldn't access data resource }
end;

{ Move data out of object data block }
procedure AllocationObjectType.MoveOut (Destination : pointer; DestinationSize, Position : word);
begin
     if Assigned(Destination) then { Check that destination is valid }
        MoveFAST (DataPointer(Position)^, Destination^, DestinationSize)
     else Error; { Error; couldn't access data resource }
end;


{ Returns a pointer to a byte inside allocated data or NIL if no allocation
  exists. }
function AllocationObjectType.DataPointer (Position : word) : pointer;
begin
     if IsAllocated then DataPointer := Ptr(Seg(Data^), Ofs(Data^) + Position)
        else DataPointer := NIL; { No allocation exists! }
end;

{ Returns the size of the allocated data }
function AllocationObjectType.DataSize : word;
begin
     if IsAllocated then DataSize := Size else DataSize := 0;
end;


{ Returns TRUE if AllocationObjectType contains an allocated pointer }
function AllocationObjectType.IsAllocated : boolean;
begin
     IsAllocated := Assigned(Data) and (Size > 0);
end;


{ Clear allocated memory (set all bytes to zero) }
procedure AllocationObjectType.Clear;
begin
     if IsAllocated then FillChar (Data, Size, 0)
        else Error; { Error; no allocation exists }
end;


{ Method for memory allocation error handling }
procedure AllocationObjectType.Error;
begin
     RunError (203);
end;


{ Fast 16-bit memory moving routine with overlap protection. Performance
  is about 36% better than Borland Pascal 7.0's internal memory moving
  routine. }
procedure MoveFAST (var Source, Target; Size : word); assembler;
asm
   PUSH    DS
   PUSH    ES
   LDS     SI, Source
   LES     DI, Target
   MOV     CX, Size
   CLD
   { If an overlap of source and target occurs, copy data backwards }
   CMP     SI, DI
   JAE     @2
   ADD     SI, CX
   ADD     DI, CX
   DEC     SI
   DEC     DI
   STD
   SHR     CX, 1
   JAE     @1
   MOVSB
   @1:
   DEC     SI
   DEC     DI
   JMP     @3
   @2:
   SHR     CX, 1
   JNC     @3
   MOVSB
   @3:
   REP     MOVSW
   POP     ES
   POP     DS
end;

{ Fills a variable with word-sized data }
procedure FillWord (var Destination; Count, Data : word); assembler;
asm
   LES  DI, Destination
   MOV  CX, Count
   MOV  AX, Data
   CLD
   REP  STOSW
end;


end. { unit }


