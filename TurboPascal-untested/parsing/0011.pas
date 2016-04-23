{
I am trying to write an algorithm(in pseudocode or Pascal)  that
converts a nonparenthesized infix expression to the equivalent postfix
expression.

For example, the infix expression

3 - 6 * 7 + 2 / 4 * 5 - 8

converts to the postfix expression
------ message termination by server was premature----

but postfix notation would be:  3 6 7 * - 2 4 / + 5 * 8 -

In the program that follows, the input is a character string which is
then converted to a linked list. If numeric values are desired, the
VAL function can be used at the time the list is made.

The advantage of the linked list approach is the ease with which the
order of the terms may be rearranged. The disadvantage is the "write
only" looking code that results--very un-Pascal like. Hopefully, the
comments make it clearer.

The conversion of infix to postfix notation follows these rules:

1. Multiplication and division take precedence over addition and
subtraction.

2. Where operations are of equal precedence, they are performed in
sequential order from left to right.

The algorithm uses two linked lists. One is a queue, or FIFO, type
list. Each node of this list is linked to the next and each node
stores a "word" from the original math string in the same order as
written. The other op linked list is a short list of one or two nodes
which stores the math operations in order of their postfix execution.
In both these lists, the last node points to nil. The math list is
parsed from the front. Each operation is placed in the op list and
removed from the longer list. The longer list is relinked and the op
list is inserted in the proper position for postfix notation.

<clifpenn@airmail.net>   11:12PM  3/1/96
--------------------------- }

Program InFixToPostFix;
{ Written in Turbo Pascal v6.0 by Clif Penn, Mar 1, 1996  }

Uses CRT;
Label finis;

TYPE   link = ^node;   { link is a pointer to a node }
       node = record
            nxt:link;  { points to next node (or nil) }
            dat:string[12];   {length of 12 is arbitrary}
       end;
VAR
head, p1, p2, op:link;
s, postfix:string;

Procedure MakeWrdList(ss:string);
VAR
wrd:string[12];   { 12 is arbitrary }
s1, s2, len:integer;
pt1, pt2:link;

Begin
     pt1 := nil;
     s1 := 1;
     len := Length(ss);

     While s1 < len do
     Begin
          { skip spaces }
          While (ss[s1] = ' ') AND (s1 < len) Do Inc(s1);
          s2 := s1;   {start of word}
          { parse to next space }
          While (ss[s2] <> ' ') AND (s2 <= len) Do Inc(s2);
          wrd := Copy(ss, s1, s2 - s1);   {extract wrd sans spaces}
          s1 := s2;  {advance string index}

          pt2 := pt1;  {initially pt2 to nil, normally move down list}
          new(pt1) ;   {get address for pt1 from heap}
          if pt2 = nil then head := pt1;    {head-->first node}
          pt2^.nxt := pt1;      {links old node to new}
          pt1^.nxt := nil;      {last node in list points to nil}
          pt1^.dat := wrd;      {stores wrd in node}
     End;

{ After above:  pt1 and pt2 no longer used
         head-->[arg1]-->[op1]-->[arg2]-->[ .... ]-->nil       }
End;

Procedure ShowList;
VAR tmp:link;
Begin
     tmp := head;
     postfix := '';
     While tmp <> nil do
     begin
          postfix := postfix + tmp^.dat + ' ';  {concatanate string}
          tmp := tmp^.nxt;  {traverse the list head to tail}
     end;
     Writeln(postfix);
End;

Procedure InsertOp;
{Inserts Op node(s) into PostFix linked list}
Begin
     p1^.nxt := op;  {insert op, the last op node points to nil}
     While p1^.nxt <> nil do p1 := p1^.nxt;
     p1^.nxt := p2^.nxt;  {remove p2 node from list}
     p1 := p1^.nxt;  {last node of prev op now linked to list}
     op := p2;       {new op becomes p2}
     op^.nxt := nil;
     p2 := p1;  {both now point to next argument}
End;

Procedure ExtendOp;
{Extracts math symbol node from PostFix list and extends Op list}
Begin
     p1^.nxt := p2^.nxt;    {remove p2 from list}
     p1 := p1^.nxt;         {relink arg-->arg}
     p2^.nxt := op;         {place p2 in front of old op}
     op := p2;              {now op linked list has 2 nodes}
     p2 := p1 ;             {both now point to next argument}
End;

Procedure DoPostFix(st:string);
Const
Hi = ['*', '/'];   {Hi, Lo are math precedence rank of symbols}
Lo = ['-', '+'];

Begin
     MakeWrdList(st);
     p1 := head;       {After this initialization, }
     op := nil;        {p1, p2, arg1 --> arg2      }
     p2 := p1^.nxt;    {op --> op1 --> nil         }
     ExtendOp;

     While p2^.nxt <> nil Do    {last node points to nil}
     Begin
          p2 := p2^.nxt;  {p2 now pointing to math operation}
          {Conditional char comparisons follow}
          If (op^.dat[1] in Hi) OR (p2^.dat[1] in Lo) then
                InsertOp
          Else  ExtendOp;
     End;
     p1^.nxt := op;  {links final math operation(s)}
End;

BEGIN  {main program}
     ClrScr;
     Writeln('Just press Enter to quit.'); Writeln;
     { Example }
     s := '3 - 6 * 7 + 2 / 4 * 5 - 8';

     DoPostFix(s);
     Writeln('In postfix notation, the infix string:');
     Writeln(s, ' becomes:');
     ShowList;
Repeat
     Writeln;
     Writeln('Infix math string (spaces between everything):');
     Readln(s);
     If Length(s) < 5 then goto finis;

     DoPostFix(s);
     ShowList;
Until Length(s) < 5;

finis:
END.
