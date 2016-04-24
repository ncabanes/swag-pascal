(*
  Category: SWAG Title: POINTERS, LINKING, LISTS, TREES
  Original name: 0047.PAS
  Description: Queue in an Array
  Author: WILLIAM HOBDAY
  Date: 08-30-97  10:08
*)

Unit Q;

(***************************************************************************)
(*   Unit Name: Queue                                                      *)
(*   Author: William Hobday                                                *)
(*   Last Modified: March 2, 1989                                          *)
(*                                                                         *)
(*   Description: This unit implements a queue in an array implementation  *)
(*   using the following documented procedures:                            *)
(*                          NewQueue : queue                               *)
(*                          EnQueue( queue,value )                         *)
(*                          DeQueue( queue ) : value                       *)
(*                          Empty( queue ) : boolean                       *)
(***************************************************************************)

interface

Const Max_Q = 50;

type Queue = record
           Data: array[1..max_Q] of char;
           Head,
           Tail,
           Length: integer;
        end;

Procedure NewQueue( var Q: Queue );
Procedure EnQueue( var Q: Queue; Name : char );
Function DeQueue( var Q: Queue ) : char;
Function Empty( Q: Queue ) : boolean;

implementation

(***************************************************************************)
(*   Name: NewQueue                                                        *)
(*                                                                         *)
(*   Purpose: Creates a new empty Queue                                    *)
(*   Input: Q - the Q to be created                                        *)
(*   Output: Q - a new empty Q                                             *)
(***************************************************************************)

Procedure NewQueue(var Q: Queue);

begin
   With Q do
      begin
         Head := 1;
         Tail := 0;
         Length := 0
      end
end;



(***************************************************************************)
(*   Name: EnQueue                                                         *)
(*                                                                         *)
(*   Purpose: Creates a new node containing the given info and places it   *)
(*            on the end of the Q                                          *)
(*   Input: Q - Q to be appended on                                        *)
(*          Name - data to be added to Q                                   *)
(*   Output: Q - the modified Q                                            *)
(***************************************************************************)

Procedure EnQueue(var Q: Queue; Name: char);

begin
   with Q do
      if length < Max_Q
         then
            begin
               inc( Length );
               Tail := ( Tail+1 ) mod Max_Q;
               Data[ Tail ] := Name
            end
         else writeln('Error --- Queue Overflow ---')
end;



(***************************************************************************)
(*   Name: DeQueue                                                         *)
(*                                                                         *)
(*   Purpose: Removes node at the head of the queue and returns data       *)
(*   Input: Q - Queue to be modified                                       *)
(*   Output: DeQueue - Name deleted from list                              *)
(***************************************************************************)

Function DeQueue(var Q: Queue) : char;

begin
   with Q do
      if length > 0
         then begin
               dec( length );
               DeQueue := Data[head];
               head := ( head+1 ) mod Max_Q
            end
         else writeln('Error --- Queue underflow ---')
end;



(***************************************************************************)
(*   Name: Empty                                                           *)
(*                                                                         *)
(*   Purpose: Returns TRUE if Q is empty                                   *)
(*   Input: Q - Queue to be evaluated                                      *)
(*   Output: Empty - Result of Function                                    *)
(***************************************************************************)

Function Empty( Q: Queue ) : boolean;

begin
   if Q.length > 0
      then Empty := false
      else Empty := true
end;

end.

