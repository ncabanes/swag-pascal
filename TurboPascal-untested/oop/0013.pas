 My understanding of OOP revolves around three principles:

  ENCAPSULATION:  All data-Types, Procedures, Functions are placed
                  within a new Type of wrapper called an Object.

                  This new wrapper is very simillar to a standard
                  Record structure, except that it also contains
                  the routines that will act on the data-Types
                  within the Object.

                  The Object-oriented style of Programming requires
                  that you should ONLY use the routines within the
                  Object to modify/retrieve each Object's data-Types.
                  (ie: Don't access the Variables directly.)


      Structured Style                 OOP Style
      ================                 =========
      MyRecord = Record                MyObject = Object
                   1st Variable;                    1st Variable;
                   2nd Variable;                    2nd Variable;
                   3rd Variable                     3rd Variable;
                 end;                               Procedure One;
                                                    Procedure Two;
                                                    Function One;
                                                    Function Two;
                                                  end;

     inHERITANCE: This gives you the ability to make a new Object by
                  cloning an old Object. The new Object will contain
                  all the abilities of the old Object.
                  (ie: Variables, Procedures/Functions).

                   You can add additional abilities to this new Object,
                   or replace old ones.

                               +--------------+
                               |  New Object  |
                               |  +--------+  |
                               |  |  Old   |  |
                               |  | Object |  |
                               |  +--------+  |
                               +--------------+

                   With Inheritance, you don't have to go back and
                   re-Write old routines to modify them into new
                   ones. Instead, simply clone the old Object and
                   add or replace Variables/Procedures/Functions.

                   This makes the whole process of rewriting/modifying
                   a Program MUCH faster/easier. Also there is less
                   chance of creating new bugs from your old bug-free
                   source-code.


  POLYMorPHISM:    The name Sounds intimidating, but the concept is
                   simple.

                   Polymorphism allows one Procedure/Function to
                   act differently between one Object and all its
                   descendants. (Clones)

                   These Type of "polymorphic" Procedures/Functions
                   know which Object they are working on, and act
                   accordingly. For example:

                   Say you've created an Object (Object-1) that
                   contains a Procedure called DrawWindow, to draw
                   the main screen of a Program.

                   DrawWindow relies on another Procedure SetBorder
                   within Object-1, to set the borders used in the
                   main screen.

                   Now you clone Object-2 from Object-1.

                   You want to use Object-2 to handle pop-up Windows,
                   but you want the pop-ups to have a different border
                   style.

                  if you call the DrawWindow Procedure that Object-2
                   inherited from Object-1, you'll end up With a Window
                   With the wrong border-style.

                   to get around this you could change the SetBorder
                   Procedure to a "Virtual" Procedure, and add a
                   second identically named "Virtual" Procedure
                   (SetBorder) within Object-2.

                   A "Virtual" Procedure relies on a "Virtual Table"
                   (Which is basicly a Chart to indicate which
                    "Virtual" routine belongs to which Object)
                   to, indicate which version of the identically
                   named Procedures should be used within different
                   Objects.

                   So within Object-1, the DrawWindow routine will
                   use the SetBorder Procedure within Object-1.

                   Within Object-2, the inherited DrawWindow routine
                   will use the other SetBorder Procedure that belongs
                   to Object-2.

                   This works because the "Virtual Table" tells the
                   DrawWindow routine which SetBorder Procedure to
                   use For each different Object.

                   So a call to the SetBorder Procedure now acts
                   differently, depending on which Object called it.
                   This is "polymorphism" in action.


  OOP LANGUAGE LinGO: The following are some of the proper names For
                      OOP syntax.

     Structured Programming       OOP Programming
     ======================       ===============
      Variables                   Instances
      Procedures/Functions        Methods
      Types                       Classes
      Records                     Objects

{
> i have a parent Object defined With Procedure a and b.
> i have a child Object With Procedure a, b and c.

> when i declare say john being a child, i can use a, b, or c With no
> problem.  when i declare john as being a parent, i can use a or b.

> if i declare john as being a parent and initialise it with
> new (childPTR,init) it seems i have access to the parent fields

After reading twice, I understand you mean Object classes dealing With humans,
not trees (happen to have parents & childs too).

> parent a,b,c,d,e,f
 (bad)
> parent a,b
 (good)
> child a,b,c
> child2 a,b,d
> child3 a,b,e,f
 (redefine a, b For childs as Far as they differ from parent a,b)

Next example could be offensive For christians, atheists and media-people.
}

Type
  TParent = Object    { opt. (tObject) For Stream storage }
    Name : String;
    Constructor Init(AName: String);
    Procedure Pray;             { your A,
                                  they all do it the same way }
    Procedure Decease; Virtual; { your B, Virtual, some instances
                                  behave different (Heaven/Hell) }
    Destructor Done; Virtual;
  end;
  TChild1 = Object(TParent)
    Disciples : Byte;
    Constructor Init(AName: String; DiscipleCount: Byte);
    { do not override Decease } { calling it will result in a
                                  call to TParent.Decease }
    Procedure Resurrection;     { your C }
  end;
  TChild2 = Object(TParent)
    BulletstoGo : LongInt;
    Constructor Init(DisciplesCount: Byte; Ammo: LongInt);
    Procedure Decease; Virtual;         { override }
    Procedure Phone(Who: Caller);  { your D }
  end;

  Constructor TParent.Init(AName: String);
  begin
    Name := AName;
  end;
  Destructor TParent.Done;
  begin
    {(...)}
  end;
  Procedure TParent.Pray;
  begin
    ContactGod;
  end;
  Procedure TParent.Decease;
  begin
    GotoHeaven;
  end;

  Constructor TChild1.Init(AName: String; DiscipleCount: Byte);
  begin
    inherited Init(AName);
    Disciples := DiscipleCount;
  end;
  Procedure TChild1.Resurrection;
  begin
    RiseFromTheDead;
  end;

  Constructor TChild2.Init(AName: String;
                           DiscipleCount: Byte; Ammo: LongInt);
  begin
    inherited Init(DiscipleCount);
    BulletstoGo := Ammo;
  end;
  Procedure TChild2.Decease;
  begin
    EternalBurn;
  end;
  Procedure TChild2.Phone(Who: Caller);
  begin
    Case Who of
      AFT   : Ventriloquize;
      Media : Say('Burp');
    end;
  end;
{
In the next fragment all three Types of instances are put into a collection.
}
Var
  Christians : PCollection;

begin
  Christians := New(PCollection, Init(2,1));
  With Christians^ do begin
    Insert(PParent, Init('Mary'));
    Insert(PParent, Init('John'));
    Insert(PChild1, Init('Jesus', 12));
    Insert(PChild2, Init('Koresh', 80, 1000000));
  end;
{
Now you can have all instances pray ...
}
  Procedure DoPray(Item: Pointer); Far;
  begin
    { unTyped Pointers cannot have method tables. The PParent
      Typecast Forces a lookup of Pray in the method table.
      All instances With a TParent ancestor will point to
      the same (non-Virtual) method }
    PParent(Item)^.Pray;
  end;
  { being sure all Items in Christians are derived from TParent }
  Christians^.ForEach(@DoPray);
{
and because all mortals will die...
}
  Procedure endVisittoEarth(Item: Pointer); Far;
  begin
    { Decease is a Virtual method. The offset of a location in
      the VMT With the address of a Virtual method is determined by
      the Compiler. At run-time, For each Type of instance 1 VMT
      will be created, it's method-fields filled With the
      appropriate addresses to call.
      Each instance of an Object derived from TParent will have the
      address of it's VMT at the same location. Calling a Virtual
      method results in
         1) retrieving that VMT address at a known offset in
            the instance's data structure
         2) calling a Virtual method at a known offset in the
            VMT found in 1)
      ThereFor mr. Koresh will go to hell: PChild2's VMT contains
      at the offset For Decease the address of the overridden
      method. Mr. Jesus, a PChild1 instance, simply inherits the
      address of PParent's Decease method at that offset in the
      VMT.                                                        }
    PParent(Item)^.Decease;
  end;
  Christians^.ForEach(@endVisittoEarth);



->   ...I've no problem posting my code, but I'm still not Really happy
->   With it's present Implementation. I also don't think that dynamic
->   Array Objects are very good examples of OOP. (For example, what
->   do extend the dynamic-Array Object into, via inheiritance???)
->
->   ...Something more like a generic "Menu" or "Line-Editor" Object
->   might be a better example.

Well I don't know exactly what you are trying to do With your dynamic
Array but it can be OOP'ed.  Linked lists are a prime example (I hope
this is close)  By using OOP to Write link lists you can come up with
Objects such as:

Type
    ListPtr = ^List;
    NodePtr = ^ListNode;

    List (Object)
      TNode   : Pointer;  {Pointer to the top Record}
      BNode   : Pointer;  {Pointer ro the bottom Record}
      CurNode : Pointer;  {Current Pointer}

    Constructor Init;             {Initializes List Object}
    Destructor  Done;  Virtual;   {Destroys the list and all its nodes}

    Function top    (Var Node : ListNode) : NodePtr;
    Function Bottom (Var Node : ListNode) : NodePtr;
    Function Next   (Var Node : ListNode) : NodePtr;
    Function Prev   (Var Node : ListNode) : NodePtr;
    Function Current(Var Node : ListNode) : NodePtr;

    Procedure AttachBeFore (Var Node : ListNode);
    Procedure AttachAfter  (Var Node : ListNode);
    Procedure Detach       (Var NodePtr : Pointer);

  end;

  ListNode = Object;
    Prev : NodePtr;
    Next : NodePtr;

  Constructor Init;
  Destructor  Done;  Virtual;

  end;

The list Object is just that.  It has the basic operations you would do
with a list.  You can have more than one list but only one set of
methods will be linked in.  The List node Dosn't have much other than
the Pointers to link them into a list and an Init, done methods.  Sounds
like a ton of work just to implement a list but there is so much you can
do easely With OOP that you would have a hard time doing conventionally.
One example, because the ListNode's Done Destructor is Virtual the Done
of the list can accually tranvirs the list and destroy all Objects in
the list.  One list can accually contain Objects that are not the
same!!!  Yep it sure can.  As long as an Object is dirived from ListNode
the list can handel it.  Try to do that using conventional methods!!

I'm assuming that your dynamic Array will do something similar which is
why I suggested it.  A Menu and Line editor Objects are High level
Objects that should be based on smaller Objects.  I'd assume that a line
editor would be a Complex list of Strings so the list and ListNode
Objects would need to be built.  See what I mean???

then you get into Abstract Objects.  These are Objects that define
common methods For its decendants but do not accually have any code to
suport them.  This way you have set up a standard set of routines that
all decendants would have and Programs could be written using them.  THe
results of which would be a Program that could handel any Object based
on the abstract.

-> RM>I have mixed feeling on this. I see OOP and Object as tools For a
-> RM>Program to manipulate.
->
-> RM>  IE: File Objects, Screen Objects, ect then bind them together
-> RM>      in a Program using conventional style coding.
->
->   ...to my understanding of the OOP style of Programming, this would
->   be a "NO-NO".

OK well With the exception of TApplication Object in Turbo Vision a
Program is a speciaized code that more than likely can't be of any use
For decendants.  That was my reasioning at least.  and the Tapp Object
isn't a Program eather.  YOu have to over ride a ton of methods to get
it to do anything.
Unit OpFile;  {*******   Capture this For future referance   *******}

Interface

Type

DateTimeRec = Record
              {Define the fields you want For date and time routines}
              end;

AbstractFile = Object

  Function  Open : Boolean;                                   Virtual;
    {Opens the File in the requested mode base on internal Variables }
    {Returns True if sucessfull                                      }

  Procedure Close;                                            Virtual;
    {Flush all buffers and close the File                            }

  Function  Exists : Boolean;                                 Virtual;
    {Returns True is the File exists                                 }

  Function  Create : Boolean;                                 Virtual;
    {Will create the File or overWrite it if it already exists       }

  Procedure Delete;                                           Virtual;
    {Will delete the File.                                           }

  Function  Rename : Boolean;                                 Virtual;
    {Will rename the File returns True if successfull                }

  Function  Size : LongInt;                                   Virtual;
    {Returns the size of the File.                                   }

  Procedure Flush;                                            Virtual;
    {Will flush the buffers without closing the File.                }

  Function  Lock : Boolean;                                   Virtual;
    {Will attempt to lock the File in a network enviroment, returns  }
    {True if sucessfull                                              }

  Procedure Unlock;                                           Virtual;
    {Will unlock the File in a network enviroment                    }

  Function  Copy (PathName : String) : Boolean;               Virtual;
    {Will copy its self to another File, returns True is successfull.}

  Function  GetDateTime (Var DT : DateTimeRec) : Boolean;     Virtual;
    {Will get the File date/time stamp.                              }

  Function  SetDateTime (Var DT : DateTimeRec) : Boolean;     Virtual;
    {Will set the File date stamp.                                   }

  Function  GetAttr : Byte;                                   Virtual;
    {Will get the File attributes.                                   }

  Function  SetAttr (Atr : Byte) : Boolean;                   Virtual;
    {Will set a File's attributes.                                   }

end; {of AbstractFile Object}

Implementation

  Procedure Abstract;    {Cause a run time error of 211}
    begin
    Runerror (211);
    end;

  Function  AbstractFile.Open : Boolean;
    begin
    Abstract;
    end;

  Procedure AbstractFile.Close;
    begin
    Abstract;
    end;

  Function  AbstractFile.Exists : Boolean;
    begin
    Abstract;
    end;

  Function  AbstractFile.Create : Boolean;
    begin
    Abstract;
    end;

  Procedure AbstractFile.Delete;
    begin
    Abstract;
    end;

  Function  AbstractFile.Rename : Boolean;
    begin
    Abstract;
    end;

Ok theres a few things we have to talk about here.

1.  This is an ABSTRACT Object.  It only defines a common set of
routines that its decendants will have.

2.  notice the Procedure Abstract.  It will generate a runtime error
211.  This is not defined by TP.  Every Method of an Object has to do
somthing.  if we just did nothing we could launch our Program into
space.  By having all methods call Abstract it will error out the
Program and you will know that you have called and abstract method.

3.  I'm sure some may question why some are Procedures and some are
Functions ie Open is a Function and close is a Boolean.   What I based
them on is if an error check a mandatory it will be a Function Boolean;
This way loops will be clean.  Open in a network Open will require a
check because it may be locked.  Which brings up point 4.

4.  We are not even finished With this Object yet.  We still have to
define a standard error reporting / checking methods and also lock loop
control methods.  not to mention some kind of common data and methods to
manipulate that data.  Moving to point 5.

5.  Where does it end???  Well we hvae added quite a few Virtual methods
While thsi is not bad it does have a negative side.  All Virtual methods
will be linked in to the final EXE weather it is used or not.  There are
valid reasions For this but you don't want to make everything Virtual if
it Dosn't have to be.  My thinking is this.  if it should be a standard
routine For all decendants then it should be Virtual.  if required
methods call a method then why not make it Virtual (this will become
more apparent in network methods and expanding this Object)

Now personally I get a feeling that the DateTime and Attr methods
shouldnn't be there or at least not Virtual as the vast majority of
Programs will not need them and its pushing the limits of Operating
system spisific methods.  SO it will probly be a Dos only Object.  (Yes
there are others that have this but I think its over kill)  The same
goes For the copy and rename methods so I would lean to removing them
from this Object and define them in decendants.

So what do you think we need to have For error checking / reporting
methods???  Do you think we could use more / different methods???


{
 DW> I am trying to teach myself about Object orientated Programming and
 DW> about 'inheritence'. This is my code using Records.

The idea of Object oriented Programing is what is refered to as
encapsulation.  Your data and the Functions that manipulate it are
grouped together.  As an example, in a traditional Program, a linked
list would look something like:
}

Type
  Linked_List =
    Record
      Data : Integer; {Some data}
      Next : ^Linked_List; {Next data}
      Prev : ^Linked_List; {Prev data}
    end;

then you would have a whole slew of Functions that took Linked_List as a
parameter.  Under OOP, it would look more like

Type
  Linked_List =
    Object
      Data : Integer;
      Next : ^Linked_List;
      Prev : ^Linked_List;

      Constructor Init();   {Initializes Linked_List}
      Destructor  DeInit(); {Deinitializes Linked_List}
      Procedure AddItem(aData : Integer);
      Procedure GetItem(Var aData : Integer);
    end;

then, to add an item to a particular list, the code would look like:
This_Linked_List.AddItem(10);

This is easier to understand.  An easy way to think about this is that
an Object is an entity sitting out there.  You tell it what you want to
do, instead of calling a Function you can't identify.  Inheritance
allows you to make a linked list that holds a different Type, but Uses
the same Interface funtions.  More importantly, using the same method
and Pointers, you could have both Types in the same list, depending on
how you implemented it.

It helps debugging time, because if you wanted to add a Walk_List
Function, you could add it and get it working For the parent Object, and
(since the mechanics of it would be the same For ANY Linked List), you
could Write it once and use it without problems.  That is a clear
advantage.  Other Uses include:

(For a door Type Program) and Input/Output Object that serves as a base
For a console Object and a modem Object, and thusly allows you to treat
the two as the same device, allowing you to easily use both.

(For a BBS Message base kit) a Generic Message Object that serves as a
base For a set of Objects, each of which implements a different BBS'
data structures.  Using this kit, a Program could send a message to any
of the BBSes just by knowing the core Object's mechanics.

(For Windows) a Generic Object represents a Generic Window.  By
inheritance, you inherit the Functionality of the original Window.  By
creating an Object derived from the generic Window, you can add
additional Functionality, without having to first Write routines to
mirror existing Functionality.

(For Sound) a Generic Object represents a generic Sound device.
Specific child Object translate basic commands (note on, note off, etc)
to device specific commands.  Again, the Program doesn't have to know
whether there is a PC speaker or an Adlib or a SoundBlaster--all it has
to know is that it calls note_on to start a note and note_off to end a
note.

There are thousands on thousands of other examples.  if you read through
the turbo guides to turbovision or to Object oriented Programming, they
will help you understand.  Also, a good book on Object oriented
Programming doesn't hurt ;>.




{
> Now, the questions:
> 1. How do I discretly get the Lat & Long into separate
> Collections? In other Words (psuedocode):

No need For seperate collections, put all the inFormation in a Single
collection.

> Any hints would be appreciated. Thanks!

I'll not give any help With parsing the Text File, there will probably be a ton
of advice there, but here is a little Program that I threw together (and
tested) that will list the inFormation and present the additional data.
Have fun With it.
}

Program Test;
Uses Objects,dialogs,app,drivers,views,menus,msgbox;

Type
  (*Define the Data Element Type*)
  Data = Record
           Location : PString;
           Long,Lat : Real;
         end;
  PData = ^Data;

  (*Define a colection of the data elements*)
  DataCol = Object(TCollection)
              Procedure FreeItem(Item:Pointer); Virtual;
            end;
  PDC     =^DataCol;

  (*Define a list to display the collection*)
  DataList = Object(TListBox)
               Function GetText(item:Integer;maxlen:Integer):String; Virtual;
               Destructor done; Virtual;
             end;
  PDL = ^DataList;

  (*Define a dialog to display the list *)
  DataDlg = Object(TDialog)
              Pc : PDC;
              Pl : PDL;
              Ps : PScrollBar;
              Constructor Init(Var bounds:Trect;Atitle:TTitleStr);
              Procedure HandleEvent(Var Event:TEvent); Virtual;
            end;
  PDD     = ^DataDlg;

Const
  CmCo = 100;
  CmGo = 101;


Procedure DataCol.FreeItem(Item:Pointer);
   begin
     disposeStr(PString(PData(Item)^.Location));
     dispose(PData(Item));
   end;

Function DataList.GetText(item:Integer;maxlen:Integer):String;
   begin
     GetText := PString(PData(List^.At(item))^.Location)^;
   end;

Destructor DataList.Done;
   begin
     Dispose(PDC(List),Done);
     TListBox.Done;
   end;

Constructor DataDLG.Init(Var bounds:Trect;Atitle:TTitleStr);
   Var
   r  : trect;
   pd : pdata;
   begin
     TDialog.Init(bounds,ATitle);
     geTextent(r); r.grow(-1,-1); r.a.x := r.b.x - 1; dec(r.b.y);
     new(ps,init(r)); insert(ps);

     geTextent(r); r.grow(-1,-1); dec(r.b.x); dec(r.b.y);
     new(pl,init(r,1,ps)); insert(pl);

     geTextent(r); r.grow(-1,-1); r.a.y := r.b.y - 1;
     insert(new(pstatusline,init(r,
                newstatusdef(0,$FFFF,
                newstatuskey('~[Esc]~ Quit ',kbesc,CmGo,
                newstatuskey('   ~[Alt-C]~ Co-ordinates ',kbaltc,CmCo,
                newstatuskey('',kbenter,CmCo,nil))),nil))));

     new(Pc,init(3,0));
     With pc^ do        (*parse your File and fill the*)
       begin            (*collection here             *)
         new(pd);
         pd^.location := newstr('Port Arthur, Texas');
         pd^.long := 29.875; pd^.lat  := 93.9375;
         insert(pd);
         new(pd);
         pd^.location := newstr('Port-au-Prince, Haiti');
         pd^.long := 18.53; pd^.lat  := 72.33;
         insert(pd);
         new(pd);
         pd^.location := newstr('Roswell, New Mexico');
         pd^.long := 33.44118; pd^.lat  := 104.5643;
         insert(pd);
      end;
     Pl^.newlist(pc);
  end;

Procedure DataDlg.HandleEvent(Var Event:TEvent);
   Var
    los,las : String;
   begin
     TDialog.HandleEvent(Event);
     if Event.What = EvCommand then
        Case Event.Command of
          CmGo : endModal(Event.Command);
          CmCo : begin
             str(PData(Pl^.List^.At(Pl^.Focused))^.Long:3:3,los);
             str(PData(Pl^.List^.At(Pl^.Focused))^.Lat:3:3,las);
             MessageBox(
             #3+PString(PData(Pl^.List^.At(Pl^.Focused))^.Location)^ +
             #13+#3+'Longitude : '+los+#13+#3+'Latitude  : '+las,
             nil,mfinFormation+mfokbutton);
                 end;
         end;
    end;

Type  (*the application layer *)
  myapp = Object(Tapplication)
            Procedure run; Virtual;
          end;

Procedure myapp.run;
   Var r:trect;
       p:PDD;
   begin
     geTextent(r);
     r.grow(-20,-5);
     new(p,init(r,'Dialog by ken burrows'));
     if p <> nil then
        begin
          desktop^.execview(p);
          dispose(p,done);
        end;
   end;

Var
 a:myapp;

begin
  a.init;
  a.run;
  a.done;
end.




>   I am having a problem.  I would like to Write an editor.  The
> problem is I dont understand a thing about Pointers (which everyone
> seems to use For editors).

   I'm certainly no TP expert, but I might be able to help out With the
Pointers.  Pointers are just special 4-Byte Variables that contain (
point to) a specific position in memory.  You can also make a Pointer
act like the thing to which it is pointing is a particular Type of
Variable (Byte, String, etc).  Unlike normal Var Variables, however, these
Variables are what's referred to as Virtual -- they aren't fixed in the
.EXE code like Var Vars, so you can have as many of them as you like,
within memory Constraints.  Each is created when needed using the GetMem
statement.  This statement makes a request For some more memory to be
used in the heap (all left-over memory when the Program loads usually).

What you need in a editor is to be able to somehow link the Strings
that make up the document into what's called a list (first line, next,
... , last line).  The easiest way to visualize this is a bunch of people
in a line holding hands, each hand being a Pointer.  The hand is not the
entire person, it just connects to the next one.  So, what you do is
use a Record that contains one String For one line of Text, a Pointer to
the previous line of Text in the document, and a Pointer to the next line
in the document.  A Record like this should do it:
    {+------------------------- Usually used in starting a Type of Pointer}
    {|+------------------------ Points to a String in the document        }
    {||            +----------- This is usedto mean that PStringItem is   }
     ||            |            to be a Pointer pointing to a Record      }
     ||            |            known as TStringItem                      }
    {vv            v
Type PStringItem = ^TStringItem;
     TStringItem : Record
        LineOText : String [160]; {Double the screen width should do it}
        NextLine  : PStringItem;  {Points to the next line in memory}
        PrevLine  : PStringItem;  {Points to the previous line in memory}
        end;

In your editor main Program, use

Var FirstLine, LastLine, StartLine, CurrLine : PStringItem;

to create Varibles giving you `bookmarks' to the first line in the
File, last in the File, the one the cursor is on, and the one that
starts the screen.  All of these will change.

to create the first line in the document, use:

GetMem (FirstLine, Sizeof (TStringItem)); {get memory enough For one line}
CurrLine := FirstLine;   {of course, only one line in the doc so Far!}
LastLine := FirstLine;
StartLine := FirstLine;
FirstLine^.NextLine := nil; {nil means no particular place-- there's no}
FirstLine^.PrevLine := nil; {line beFore of after FirstLine yet        }

Now the Variable FirstLine will contain the address of the newly created
Variable.  to address that Variable, use the carrot (^), like this:

FirstLine^.LineOText := 'Hello World!');

to make a new line in the list just get more memory For another line:

GetMem (LastLine^.NextLine, Sizeof (TStringItem));
LastLine := LastLine^.NextLine;

This will get more memory and set the last line in the File's
next line Pointer to the new String, then make the new String the
last line.

Deleting a line is almost as simple.  You use the FreeMem Procedure
to release the memory used by a Variable.  if it's in the middle of the
list, just set the to-be-deleted's next line's previous line to the
to-be deleted's previous line, and the previous line's next to the one
after the one to be deleted, essentially removing it from the list and
then tieing the peices back together.  You can then kill off the memory
used by that line.

{Delete current line}
if CurrLine^.NextLine <> nil then {there's a line after this one}
   CurrLine^.NextLine^.PrevLine := CurrLine^.PrevLine;
if CurrLine^.PrevLine <> nil then {there's a line beFore this one}
   CurrLine^.PrevLine^.NextLine := CurrLine^.NextLine;
FreeMem (CurrLine, Sizeof (TStringItem));

to insert a line, just do about the opposite.

if you don't understand, I won't blame you, I'm half asleep anyway...
but I hoe it clears some of the fog.  if the manual isn't helpful
enough now, try tom Swan's _Mastering Turbo Pascal_, an excellent
book.
