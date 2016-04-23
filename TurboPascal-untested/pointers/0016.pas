
{ Links Unit - Turbo Pascal 5.5
  Patterned after the list processing facility in Simula class SIMSET.
  Simula fans will note the same naming conventions as Simula-67.

  Written by Bill Zech @CIS:[73547,1034]), May 16, 1989.

  The Links unit defines objects and methods useful for implementing
  list (set) membership in your own objects.

  Any object which inherits object <Link> will acquire the attributes
  needed to maintain that object in a doubly-linked list.  Because the
  Linkage object only has one set of forward and backward pointers, a
  given object may belong to only one list at any given moment.  This
  is sufficient for many purposes.  For example, a task control block
  might belong in either a ready list, a suspended list, or a swapped
  list, but all are mutually exclusive.

  A list is defined as a head node and zero or more objects linked
  to the head node.  A head node with no other members is an empty
  list.  Procedures and functions are provided to add members to the
  end of the list, insert new members in position relative to an
  existing member, determine the first member, last member, size
  (cardinality) of the list, and to remove members from the list.

  Because your object inherits all these attributes, your program
  need not concern itself with allocating or maintaining pointers
  or other stuff.  All the actual linkage mechanisms will be
  transparent to your object.

  *Note*
          The following discussion assumes you have defined your objects
          as static variables instead of pointers to objects.  For most
          programs, dynamic objects manipulated with pointers will be
          more useful.  Some methods require pointers as arguments.
          Example program TLIST.PAS uses pointer type variables.

  Define your object as required, inheriting object Link:

                type
                        myObjType = object(Link)
                                xxx.....xxxx
                        end;

  To establish a new list, declare a variable for the head node
  as a type Head:

                var
                        Queue1        :Head;
                        Queue2        :Head;

        Define your object variables:

                var
                        X    : myObjType;
                        Y    : myObjType;
                        Z    : myObjType;
                        P    :^myObjType;

        Make sure the objects have been Init'ed as required for data
        initialization, VMT setup, etc.

                        Queue1.Init;
                        Queue2.Init;
                        X.Init;
                        Y.Init;
                        Z.Init;

        You can add your objects to a list with <Into>:
        (Note the use of the @ operator to make QueueX a pointer to the
         object.)

                begin
                        X.Into(@Queue1);
                        Y.Into(@Queue2);

        You can insert at a specific place with <Precede> or <Follow>:

                        Z.Precede(@Y);
                        Z.Follow(@Y);

        Remove an object with <Out>:

                        Y.Out;

        Then add it to another list:

                        Y.Into(@Queue1);

        Note that <Into>, <Precede> and <Follow> all have a built-in
        call to Out, so to move an object from one list to another can
        be had with a single operation:

                        Z.Into(@Queue1);

        You can determine the first and last elements with <First> and <Last>:
        (Note the functions return pointers to objects.)

                        P := Queue1.First;
                        P := Queue1.Last;

        The succcessor or predecessor of a given member can be found with
        fucntions <Suc> and <Pred>:

                        P := X.Pred;
                        P := Y.Suc;
                        P := P^.Suc;

        The number of elements in a list is found with <Cardinal>:

                        N := Queue1.Cardinal;

        <Empty> returns TRUE is the list has no members:

                        if Queue1.Empty then ...

        You can remove all members from a list with <Clear>:

                        Queue1.Clear;

        GENERAL NOTES:

                The TP 5.5 type compatibility rules allow a pointer to a
                descendant be assigned to an ancestor pointer, but not vice-versa.
                So although it is perfectly legal to assign a pointer to
                type myObjType to a pointer to type Linkage, it won't let
                us do it the opposite.

                We would like to be able to assign returned values from
                Suc, Pred, First, and Last to pointers of type myObjType,
                and the least fussy way is to define these pointer types
                internal to this unit as untyped pointers.  This works fine
                because all we are really doing is passing around pointers
                to Self, anyway.  The only down-side to this I have noticed
                is you can't do:  P^.Suc^.Pred because the returned pointer
                type cannot be dereferenced without a type cast.
}

unit Links;

interface

type

  pLinkage = ^Linkage;
  pLink = ^Link;
  pHead = ^Head;

  Linkage = object
          prede :pLinkage;
          succ  :pLinkage;
          function Suc  :pointer;
          function Pred :pointer;
          constructor Init;
  end;

  Link = object(Linkage)
          procedure Out;
          procedure Into(s :pHead);
          procedure Follow (x :pLinkage);
          procedure Precede(x :pLinkage);
  end;

  Head = object(Linkage)
          function First :pointer;
          function Last  :pointer;
          function Empty :boolean;
          function Cardinal :integer;
          procedure Clear;
          constructor Init;
  end;



implementation

constructor Linkage.Init;
begin
  succ := NIL;
  prede := NIL;
end;

function Linkage.Suc :pointer;
begin
  if TypeOf(succ^) = TypeOf(Head) then
         Suc := NIL
  else Suc := succ;
end;

function Linkage.Pred :pointer;
begin
  if TypeOf(prede^) = TypeOf(Head) then
         Pred := NIL
  else Pred := prede;
end;

procedure Link.Out;
begin
        if succ <> NIL then
        begin
          succ^.prede := prede;
          prede^.succ := succ;
          succ := NIL;
          prede := NIL;
        end;
end;

procedure Link.Follow(x :pLinkage);
begin
        Out;
        if x <> NIL then
        begin
          if x^.succ <> NIL then
          begin
                  prede := x;
                  succ := x^.succ;
                  x^.succ := @Self;
                  succ^.prede := @Self;
          end;
        end;
end;


procedure Link.Precede(x :pLinkage);
begin
        Out;
        if x <> NIL then
        begin
                if x^.succ <> NIL then
                begin
                        succ := x;
                        prede := x^.prede;
                        x^.prede := @Self;
                        prede^.succ := @Self;
                end;
        end;
end;

procedure Link.Into(s :pHead);
begin
        Out;
        if s <> NIL then
        begin
                succ := s;
                prede := s^.prede;
                s^.prede := @Self;
                prede^.succ := @Self;
        end;
end;


function Head.First :pointer;
begin
        First := suc;
end;

function Head.Last :pointer;
begin
        Last := Pred;
end;

function Head.Empty :boolean;
begin
  Empty := succ = prede;
end;

function Head.Cardinal :integer;
var
        i   :integer;
        p   :pLinkage;
begin
        i := 0;
        p := succ;
        while p <> @Self do
          begin
                  i := i + 1;
                  p := p^.succ;
          end;
        Cardinal := i;
end;

procedure Head.Clear;
var
        x  : pLink;
begin
        x := First;
        while x <> NIL do
          begin
                  x^.Out;
                  x := First;
          end;
end;

constructor Head.Init;
begin
  succ := @Self;
  prede := @Self;
end;

end.

{------------------------   DEMO PROGRAM --------------------- }

program tlist;

uses Links;

type
        NameType = string[10];
        person = object(link)
                name :NameType;
                constructor init(nameArg :NameType);
        end;
        Pperson = ^person;

constructor person.init(nameArg :NameType);
begin
        name := nameArg;
        link.init;
end;

var
        queue : Phead;
        man   : Pperson;
        man2  : Pperson;
        n     : integer;
        tf    : boolean;

begin
        new(queue,Init);
        tf := queue^.Empty;
        new(man,Init('Bill'));
        man^.Into(queue);
        new(man,Init('Tom'));
        man^.Into(queue);
        new(man,Init('Jerry'));
        man^.Into(queue);

        man := queue^.First;
        writeln('First man in queue is ',man^.name);
        man := queue^.Last;
        writeln('Last man in queue is ',man^.name);

        n := queue^.Cardinal;
        writeln('Length of queue is ',n);
        if not queue^.Empty then writeln('EMPTY reports queue NOT empty');

        new(man2,Init('Hugo'));
        man2^.Precede(man);

        new(man2,Init('Alfonso'));
        man2^.Follow(man);
        { should now be: Bill Tom Hugo Jerry Alfonso }
        writeln('After PRECEDE and FOLLOW calls, list should be:');
        writeln('  {Bill, Tom, Hugo, Jerry, Alfonso}');
        writeln('Actual list is:');

        man := queue^.First;
        while man <> NIL do
          begin
                  write(man^.name,' ');
                  man := man^.Suc;
          end;
          writeln;

        man := queue^.Last;
        writeln('The same list backwards is:');
        while man <> NIL do
          begin
                 write(man^.name,' ');
                 man := man^.Pred;
          end;
          writeln;

        n := queue^.Cardinal;
        writeln('Queue size should be 5 now, is: ', n);

        queue^.Clear;
        writeln('After clear operation,');
        n := queue^.Cardinal;
        writeln('   Queue size is ',n);
        tf := queue^.Empty;
        if tf then writeln('    and EMTPY reports queue is empty.');
        writeln;
        writeln('Done with test.');
end.

