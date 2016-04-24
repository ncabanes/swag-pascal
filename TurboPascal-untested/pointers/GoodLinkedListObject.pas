(*
  Category: SWAG Title: POINTERS, LINKING, LISTS, TREES
  Original name: 0049.PAS
  Description: Good Linked List Object
  Author: EMIL MIKULIC
  Date: 01-02-98  07:33
*)

unit llist;

interface

{ List item object }
{ by Emil Mikulic  }

type PItem=^TItem;
     TItem=object
       next:PItem;
       { Initialise item and add next }
       constructor init(nxt:PItem);
       { Insert an item between the current and the next }
       procedure insert(nxt:PItem);
       { Add an item on to the end of the list }
       procedure add(nxt:PItem);
       { Do something for every item }
       procedure foreach; virtual;
       { Do something for current item }
       procedure custom; virtual;
       { Get some value }
       function get:integer; virtual;
       { Destroy current item and all items after it }
       destructor done;
       end;

implementation

constructor TItem.init(nxt:PItem);
begin
 { Assign next item }
 next:=nxt;
end;

procedure TItem.insert(nxt:PItem);
var temp:PItem;
begin
 { Special case: no insert because we're the end of the list }
 if next=nil then
   { Set current next pointer to inserted item }
   next:=nxt

 else begin

 { Keep a temporary reference }
 temp:=next;
 { Set current next pointer to inserted item }
 next:=nxt;
 { Pass the buck }
 nxt^.insert(temp);
 end;
end;

procedure TItem.add(nxt:PItem);
begin
 { If at end of list, add the item }
 if next=nil then next:=nxt
 { If not, pass the buck }
 else next^.add(nxt);
end;

procedure TItem.foreach;
begin
end;

procedure TItem.custom;
begin
end;

function TItem.get:integer;
begin
end;

destructor TItem.done;
begin
 { If there is a next item }
 if next<>nil then
   { then dispose of it - it'll continue dismantling the list }
   dispose(next,done);
 { If not then your work is done }
end;

end.

{ ---------------------------------CUT------------------------------- }

LINKED LIST (LLIST)
Unit Documentation

by Emil Mikulic

The comments for the TItem object should explain how this works:

type PItem=^TItem;
     TItem=object
       next:PItem;
       { Initialise item and add next }
       constructor init(nxt:PItem);
       { Insert an item between the current and the next }
       procedure insert(nxt:PItem);
       { Add an item on to the end of the list }
       procedure add(nxt:PItem);
       { Do something for every item }
       procedure foreach; virtual;
       { Do something for current item }
       procedure custom; virtual;
       { Get some value }
       function get:integer; virtual;
       { Destroy current item and all items after it }
       destructor done;
       end;

Now, this linked list object is useless. All it can do is
add more items to itself and properly clean up by
disposing of all the items in order.

Here's how a linked list may look in the memory:
LEGEND
Letters = items
Lines (- / \ |) = links

A
 \                     - -E
   \    - -C - - - D /     \
    B /                      \-F


Now, here's what it would look like if we ADDED an item: 

A                                    X
 \                     - -E        /
   \    - -C - - - D /     \     /
    B /                      \-F

Now, let's take a simpler list:

A - - B - - C - - D

Here's what that list would look like if I was to INSERT an item
on to B:

A - - B           C - - D
        \       /
          \   /
            X

The items don't move around - just the links.

The linked list is useless unless you create an object BASED on
TItem. An excellent example of this is MENU.PAS which uses 
TItem as a base for its TMenuItem list.

Also, due to the limits of Turbo Pascal when it comes to
polymorphic objects, it may be very hard to use TItem unless
you do some custom modifications to it. If this is the case
then make sure you make a copy of LLIST.PAS and work on
the copy because MENU uses LLIST.

If you understood most of this document then you have
either just learned or already know:
        * Object-oriented programming
        * Database structuring
        * Polymorphism
        * Virtual functions



