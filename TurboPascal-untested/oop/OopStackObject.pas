(*
  Category: SWAG Title: OOP/TURBO VISION ROUTINES
  Original name: 0032.PAS
  Description: OOP Stack Object
  Author: LARRY HADLEY
  Date: 01-27-94  12:22
*)

{
> If you want, I can post a few good and simple examples of OOP
> concepts to get you started.

{
  -- A simple stack object with the nice flexibility that only OOP
     can provide.

                       Data structures

     StackItem: node for a doubly linked list containing an untyped pointer
                to hold data. It is the responsibility of descendant types
                to type this pointer. (override push and pop)

     StackTop    :pointer to available stack item
     StackBottom :pointer to the bottom (end/root) of the stack
     StackHt     :number of items on stack
     StackST     :status variable

                             Methods

     Init - initializes the stack object, StackHt = 0, all pointers = nil
            *** YOU MUST CALL THIS BEFORE ACCESSING STACK ***

     done - destructor deallocates the stack by doing successive pops until
            the stack is empty.
            *** YOU MUST OVERRIDE THIS METHOD WHEN YOU OVERRIDE ***
            *** PUSH AND POP. ITEMS POPPED ARE NOT DEALLOCATED  ***

     Push - Pushes an item onto the stack by:
            1) Allocating a new StackItem (if StackHt>0)
            2) Assigning pointer dta to data field
            3) Incrementing StackHt

     Pop  - Pops by reversing push method:
            1) Recovering dta pointer from data field
            2) Deallocating "top" StackItem (if StackHt>1)
            3) Decrementing StackHt

 Most decendant types will override push and pop to type the data field, and
 call STACK.push or STACK.pop to do the "basic" operations.

 IsError - shows if an error condition exists

 MemoryOK - internally used function to check available heap.
}

Unit OSTACK;

INTERFACE

CONST
   MAX_STACK   = 100;
   MIN_MEMORY  = 4096;

   StatusOK    = 0;
   StatusOFlow = 1;
   StatusEmpty = 2;
   StatHeapErr = 3;

TYPE
   ItemPtr = ^StackItem;
   StackItem = RECORD
      data       :pointer;
      prev, next :ItemPtr;
   END; { StackItem }

   STACK = OBJECT
      StackTop, StackBottom :ItemPtr;
      StackST               :integer;
      StackHt               :byte;

      constructor init;
      destructor  done; virtual;
      procedure   push(var d); virtual;
      procedure   pop(var d); virtual;
      function    IsError:boolean;
   private
      function    MemoryOK:boolean;
   END; { STACK }

IMPLEMENTATION

constructor STACK.init;
   BEGIN
      New(StackBottom);
      StackTop := StackBottom;
      StackBottom^.prev := NIL;
      StackBottom^.next := NIL;
      StackBottom^.data := NIL;
      StackHt := 0; StackST := StatusOK;
   END;

destructor  STACK.done;
   VAR  val :pointer;
   BEGIN
      if StackHt>0 then
         repeat
            pop(val);
         until val = nil;
      Dispose(StackBottom);
   END;

procedure   STACK.push(var d);
   VAR TemPtr :ItemPtr;
       dta    :pointer ABSOLUTE d;
   BEGIN
      if not MemoryOK then EXIT;

      if (StackHt>=MAX_STACK) then
      begin
         StackST := StatusOFlow;
         EXIT;
      end;

      If StackHt>0 then
      BEGIN
         New(StackTop^.next);
         TemPtr := StackTop;
         StackTop := TemPtr^.next;
         StackTop^.prev := TemPtr;
         StackTop^.next := NIL;
      END;

      StackTop^.data := dta;
      Inc(StackHt);
   END;

procedure   STACK.pop(var d);
   VAR dta :pointer ABSOLUTE d;
   BEGIN
      if StackHt>1 then
      BEGIN
         dta := StackTop^.data;
         StackTop := StackTop^.prev;
         Dispose(StackTop^.next);
         StackTop^.next := NIL;
         Dec(StackHt);
         if StackST = StatusOFlow then StackST := StatusOK;
      END
      ELSE
      BEGIN
         if StackHt = 1 then
         BEGIN
            dta := StackBottom^.data;
            StackBottom^.data := nil;
            Dec(StackHt);
         END
         ELSE
         begin
            dta := StackBottom^.data;
            StackST := StatusEmpty;
         end;
      END;
   END;

function    STACK.IsError:boolean;
begin
   if StackST = StatusOK then
      IsError := FALSE
   else
      IsError := TRUE;
end;

function    STACK.MemoryOK:boolean;
begin
   if MaxAvail<MIN_MEMORY then
      MemoryOK := FALSE
   else
      MemoryOK := TRUE;
   StackST := StatHeapErr;
end;

END. { unit OSTACK }


{ Here's an example of how easy it is to extend the STACK object
  using iheritance and virtual methods. }


TYPE
   RegisterStack = OBJECT(STACK)
      destructor  Done; virtual;

      procedure   push(var d); virtual;
      procedure   pop(var d); virtual;
   end;

destructor  Done;
var
   tmp :OpRec;
begin
   if StackHt>0 then
      repeat
         pop(tmp);
      until tmp = NOREG;
end;

procedure  RegisterStack.push(var d);
var
   tmp :pOpRec;
   dta :OpRec ABSOLUTE d;
begin
   New(tmp);
   tmp^ := dta;
   inherited push(tmp);
end;

procedure  RegisterStack.pop(var d);
var
   tmp :pOpRec;
   dta :OpRec ABSOLUTE d;
begin
   inherited pop(tmp);
   if StackST = StatusEmpty then
   begin
      dta := NOREG;
      EXIT;
   end
   else
      if tmp<>nil then
      begin
         dta := tmp^;
         Dispose(tmp);
      end
      else
         dta := NOREG;
end;


