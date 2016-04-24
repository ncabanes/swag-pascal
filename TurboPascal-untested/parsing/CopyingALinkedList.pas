(*
  Category: SWAG Title: PARSING/TOKENIZING ROUTINES
  Original name: 0013.PAS
  Description: Copying a linked list
  Author: CLIF PENN
  Date: 08-30-96  09:35
*)


Program Copy_Linked_List;
{ <clifpenn@airmail.net>  May 31, 1996
  Turbo v.6.0 but no TPU's used so should work in many versions.
  For test purposes, a test string is parsed into words and each
  word and its length is stored in the cell of a linked list of
  the queue type (first-in-first-out, FIFO). The first linked list
  is preserved while its data is copied to another linked list.
  As a check on correct execution, the data of both lists are
  displayed on screen side by side.  }

CONST
     TestStr = 'The quick brown fox jumped over the lazy dogs back';

TYPE
    link = ^cell;
    cell =
         Record
               Next:link;
               StrWord:String[6];
               WordLen:Integer;
         End;
VAR
    head1, head2:link;

Procedure String_To_List(VAR head:link);
VAR   Wrd:Array[1..10] of String[6];
      s:String[80];
      p1, tail1:link;
      n, p:Integer;
Begin
(* make an array of words for test purposes *)
      s := TestStr + ' '; (* trailing space makes it easier to parse *)
      n := 0;
      While Length(s) <> 0 do
      Begin
           p := Pos(' ', s);   (* position of first space *)
           Inc(n);
           Wrd[n] := Copy(s, 1, p - 1); (* copies chars less space *)
           Delete(s, 1, p)  (* deletes trailing space, too *);
      End;
      (* n now contains the number of elements in the array *)

(* make linked list and transfer array data to cells *);
      p := 0;
      p1 := nil;
      While p < n do
      Begin
           Inc(p);
           New(tail1);
           With tail1^ do
           Begin
                next := nil;
                StrWord := Wrd[p];
                WordLen := Length(Wrd[p]);
           End;
           (* change global variable head1 to point to first cell *)
           If p1 = nil then head := tail1;
           p1^.next := tail1;  (* p1 is still nil for first cell *)
           p1 := tail1; (* p1 to hold old link after a new tail *)
      End;
End;

Procedure Copy_List_To_List(hd1:link; VAR hd2:link);
VAR  prev1, prev2, next2:link;
Begin
     prev1 := hd1;    prev2 := nil;
     While prev1 <> nil do
     Begin
         New(next2);
         With next2^ do   (* copy data *)
         Begin
              next := nil; (* not a copy *)
              StrWord := prev1^.StrWord;
              WordLen := prev1^.WordLen;
         End;
         If prev2 = nil then hd2 := next2; (* assigns global head2 *)
         prev2^.next := next2;
         prev2 := next2;

         (* advance to new cell of original list. Terminate
            copying if prev1^.next = nil *)

         prev1 := prev1^.next;
     End; (* while *)
End;

Procedure Show_List_Comparison(h1, h2:link);
Begin
     Writeln; Writeln; Writeln;
     Writeln('Original':15, 'Copy':15);
     Writeln;
     While h1 <> nil do
     Begin
           Write(  h1^.StrWord:10, h1^.WordLen:5, '     ');
           Writeln(h2^.StrWord:10, h2^.WordLen:5);
           h1 := h1^.next;
           h2 := h2^.next;
     End;
     Writeln; Writeln; Writeln('<< Press Enter >>');
     Readln;
End;


BEGIN { main program -- Copy_Linked_List }
      String_To_List(head1);
      Copy_List_To_List(head1, head2);
      Show_List_Comparison(head1, head2);
END.

