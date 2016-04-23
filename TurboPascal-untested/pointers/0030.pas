(* Program to test link lists. Traverse, add, delete.*)
(* I wrote this program for Pascal 2 to play around with link lists *)
(* It is mostly bullet proof and rather simple, but it works!!! *)
(* I used Pascal 5. BTW, any pointers would be appreciated.     *)
(*                                                 J.C. Wise    *)

PROGRAM Link_List (Output, Data);

USES
  Crt,Dos,Printer;

TYPE
  Line_Str     = String[80];
  Node_Pointer = ^Node_Type;
  Node_Type    = RECORD
                   Component : String;
                   Link      : Node_Pointer
                 END;

VAR
  Head,                     (* External pointer to Head *)
  New_Node,                 (* Pointer to the newest node *)
  Current:                  (* Pointer to the last node  *)
     Node_Pointer;
  Data:                     (* File of characters, one per line *)
     Line_Str;
  Line_Num,
  Counter:
     Integer;
  Choice,
  Wait1,
  Item:
     Char;



(**********************************************************************)
PROCEDURE Print_List (VAR Head : Node_pointer);


BEGIN (* Print_List *)
  CLRSCR;
  Current := Head;
  Line_Num := 1;
  WHILE Current <> NIL DO
     BEGIN
        Write(Line_Num, '. ');
        Line_Num := Line_Num + 1;
        Writeln(Current^.Component);
        Current := Current^.Link;
     END;
END; (* print_list *)

(**********************************************************************)
PROCEDURE Printer_List (VAR Head : Node_pointer);


BEGIN (* Printer_List *)
  CLRSCR;
  Current := Head;
  Line_Num := 1;
  WHILE Current <> NIL DO
     BEGIN
        Write(Lst,Line_Num, '. ');
        Line_Num := Line_Num + 1;
        Writeln(Lst,Current^.Component);
        Current := Current^.Link;
     END;
END; (* Printer_List *)



(**********************************************************************)
PROCEDURE Insrt_List (VAR Head: Node_pointer;
                     Data    : Line_Str );

VAR
  Found : Boolean;             (* True when insertion place found *)
  Previous: Node_pointer;      (* Node before current             *)

BEGIN (* Insert *)
  New(New_Node);
  New_Node^. Component := Data;
  New_Node^.Link := NIL;
  Previous := NIL;
  Current := Head;
  Found := False;
  Counter := 0;
  WHILE (Current <> NIL) AND NOT Found DO
     BEGIN
        Counter := Counter + 1;
        IF Line_Num > Counter
           THEN
              BEGIN
                 Previous := Current;
                 Current := Current^.Link
              END
           ELSE
              Found := True;
        New_Node^.Link := Current;
     END;
  IF Previous = NIL
     THEN
        Head := New_Node
     ELSE
        Previous^.Link := New_Node;
END; (* Insrt_List *)


(**********************************************************************)

PROCEDURE Delete_List (Line_Num: Integer);

VAR
  Current,
  Temp_Pointer:
     Node_pointer;

BEGIN (* Delete *)
  Counter := 1;
  IF Line_Num = Counter
     THEN
        BEGIN
           Temp_Pointer := Head;
           Head  := Head^.Link;
           Dispose(Temp_Pointer);
        END
  ELSE
     BEGIN
        Current := Head;
        WHILE (Counter <> Line_Num) AND (Current <> NIL) DO
           BEGIN
              Temp_Pointer := Current;
              Current := Current^.Link;
              Counter := Counter + 1;
           END;(* while *)
        IF (Counter = Line_Num) AND (Current <> NIL)
           THEN
              BEGIN
                 Temp_Pointer^.Link := Current^.Link;
                 Dispose(Current);
              END
        ELSE
           BEGIN
              Writeln('Line # not found');
              Readln(wait1);
              CLRSCR;
           END;
     END;
END; (* delete_list *)

(*********************************************************************)


BEGIN (* Link List *)
  ClrScr;
  Line_Num := 1;
  Head := NIL;
  Writeln('Just start typing!');
  Item := 'A';
  Choice := ' ';
  WHILE UPCASE(Item) <> 'X'  DO
     BEGIN
        CASE UPCASE(Item) of
        'A' :
           BEGIN
              Write(Line_Num, '. ');
              Readln(data);
              WHILE (length(data) <> 0 ) DO
                 BEGIN
                    Insrt_List(Head,data);
                    Line_Num := Line_Num + 1;
                    Write(Line_Num, '. ');
                    Readln(data);
                 END;
           END;
        'D' :
           BEGIN
              Write('Enter the line # to delete ');
              Readln(Line_Num);
              Delete_List(Line_Num);
              Print_List(Head);
           END;
        'I' :
           BEGIN
              Write('Enter the line # to insert before ');
              Readln(Line_Num);
              Write(Line_Num,'. ');
              Readln(Data);
              WHILE (length(data) <> 0 ) DO
                 BEGIN
                    Insrt_List(Head,data);
                    Line_Num := Line_Num + 1;
                    Write(Line_Num, '. ');
                    Readln(data);
                 END;
              Print_List(Head);
           END;
        'P' :
           BEGIN
              Writeln('Send to (P)rinter or (S)creen?');
              Readln(choice);
              CASE UPCASE(choice) OF
                 'P':
                     BEGIN
                        Writeln('Be sure printer is on, enter to continue');
                        Readln(wait1);
                        Printer_List(Head);
                     END ;
                 'S':
                     BEGIN
                        Print_List(Head);
                     END;
              END; (* CASE *)
           END;
        END (* CASE *);
     Writeln('Would you like to (A)dd, (D)elete, (I)nsert, (P)rint or e(X)it? ');
     Readln(Item);
     END;
END.
