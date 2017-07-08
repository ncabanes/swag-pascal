(*
  Category: SWAG Title: POINTERS, LINKING, LISTS, TREES
  Original name: 0014.PAS
  Description: Linked List of Text
  Author: KEN BURROWS
  Date: 02-03-94  16:08
*)

{
From: KEN BURROWS
Subj: Linked List Problem
---------------------------------------------------------------------------
Here is a short Linked List example. It loads a file, and lets you traverse the
list in two directions. It's as simple as it gets. You may also want to look
into the TCollection objects associated with the Objects unit of Borlands
version 6 and 7.
}

Program LinkedListOfText; {tested}
Uses Dos,CRT;
Type
  TextListPtr = ^TextList;
  TextList    = Record
                 line : string;
                 next,
                 prev : TextListPtr;
                end;
Const
  first : TextListPtr = nil;
  last  : TextListPtr = nil;

Procedure FreeTheList(p:TextListPtr);
   var hold:TextListPtr;
   begin
     while p <> Nil do
       begin
         hold := p;
         p := p^.next;
         dispose(hold);
       end;
   end;

Procedure ViewForward(p:TextListPtr);
   begin
     clrscr;
     while p <> nil do
       begin
         writeln(p^.line);
         p := p^.next;
       end;
   end;

Procedure ViewReverse(p:TextListPtr);
   begin
     clrscr;
     while p <> nil do
       begin
         writeln(p^.line);
         p := p^.prev;
       end;
   end;

Procedure Doit(fname:string);
   var f    :Text;
       s    :string;
       curr,
       hold : TextListPtr;
       stop : boolean;
   begin
     assign(f,fname);
     reset(f);
     if ioresult <> 0 then exit;
     curr := nil;
     hold := nil;

     while (not eof(f)) {and
           (maxavail > SizeOf(TextList))} do
       begin          {load the list forward and link the prev fields}
         readln(f,s);
         new(curr);
         curr^.prev := hold;
         curr^.next := nil;
         curr^.line := s;
         hold := curr;
      end;
     close(f);

     while curr^.prev <> nil do   {traverse the list backwards}
       begin                      {and link the next fields}
         hold := curr;
         curr := curr^.prev;
         curr^.next := hold;
       end;

     first := curr;               {set the first and last records}
     while curr^.next <> Nil do curr := curr^.next;
     last := curr;

     Repeat   {test it}
       clrscr;
       writeln(' [F]orward view : ');
       writeln(' [R]everse view : ');
       writeln(' [S]top         : ');
       write('enter a command : ');
       readln(s);
       stop := (s = '') or (upcase(s[1]) = 'S');
       if   not stop
       then case upcase(s[1]) of
             'F' : ViewForward(first);
             'R' : ViewReverse(last);
            end;
     Until Stop;

     FreeTheList(First);
   end;

{var m:longint;}
Begin
  if   paramcount > 0
  then doit(paramstr(1))
  else writeln('you need to supply a filename');
End.

