{
From: ichbiah@jdi.tiac.net (Jean D. Ichbiah)

In a recent article, David Tannen asked me how to achieve information
in Borland Pascal.  Below is a technique that allows a degree of hiding
that is close to  that of Ada packages.

ACHIEVING INFORMATION HIDING WITH BORLAND PASCAL

How to achieve Information Hiding with Borland Pascal? This is
an outline of the technique that I have developed and used quite
systematically in my own programs.

To motivate the technique, here is the visible part of
a unit dealing with dictionaries:

----------------------------------------------------------------
}
unit Dico_Handling;

interface
uses Objects;

type Dictionary  = object
  public
    All_Words   : PCollection;
    All_Phrases : PCollection;

    function First_Word_Index   (C  : Char): Integer; virtual;
    function First_Phrase_Index (C  : Char): Integer; virtual;
  end;

type Dictionary_name   = ^Dictionary;

function   New_Dictionary   (File_Name : Pchar): Dictionary_name;
procedure  Close_Dictionary (G : Dictionary_name);

implementation
{
------------------------------------------------------------------

As you see it declares the type Dictionary, the function
New_Dictionary and the procedure Close_Dictionary. The section
between "public" and "end" is all you are allowed to know about
the type Dictionary.

Then, let us look at the implementation. I am giving a skeleton,
with enough to explain the reasons of the information hiding
technique:

------------------------------------------------------------------
}
implementation
uses ...;    {  -- several  other units      }

{ Many local decarations. }

const Sorting = true;

type Sorted_list = object(TSortedCollection)
  public
    function Compare(Key1, Key2: Pointer): Integer;  virtual;
  end;

type   Sorted_list_name = ^Sorted_list;

type   Starter = array [Byte] of Integer;

type  Full_Dictionary = object(Dictionary)                      {1}
  private
    constructor  Init (Filename : PChar);
    destructor   Done; virtual;
    ...
  private
    ...
    procedure  Read_Dictionary  (Filename: Pchar);
    procedure  Open_Dictionary  (Filename: Pchar);
  private
    ...
    Start_Phrases : Starter;
    Start_Words   : Starter;
  private
    procedure Print_Pairs(C: PCollection);
    procedure Test_Dictionary;
  end;

type   Full_Dictionary_name   = ^Full_Dictionary;

{ The three operations of Dico_Handling:  }

function New_Dictionary(File_Name : Pchar): Dictionary_name;    {4}
  var The_New_Dictionary  : Full_Dictionary_name;
begin
  ...
  The_New_Dictionary := new (Full_Dictionary_name, Init(File_Name));
  ...
  New_Dictionary := The_New_Dictionary;
end;

procedure  Close_Dictionary...; begin...end;

{ Methods of Dictionary :  }

function Dictionary.First_Phrase_Index(C: Char): Integer;        {2}
begin
  Abstract;
end;

function Dictionary.First_Word_Index(C: Char): Integer;          {3}
begin
  Abstract;
end;

{  Methods of Full_Dictionary    }

constructor  Full_Dictionary.Init (Filename : PChar);            {5}
begin
  ...
  if Sorting then
    begin
      All_Words   := new(Sorted_list_name, Init(1000, 500));
      All_Phrases := new(Sorted_list_name, Init(1000, 500));
    end
  else
    begin
      All_Words   := new(PCollection, Init(1000, 500));
      All_Phrases := new(PCollection, Init(1000, 500));
    end;

  Read_Dictionary(File_Name);

  Initialize_Starters;
end;

procedure Full_Dictionary.Read_Dictionary...; begin...end;
procedure Full_Dictionary.Open_Dictionary...; begin...end;

destructor  Full_Dictionary.Done;
begin
  if All_Words   <> nil then Dispose(All_Words,   Done);
  if All_Phrases <> nil then Dispose(All_Phrases, Done);
end;

procedure Full_Dictionary.Initialize_Starters; begin...end;

{ Methods of Sorted_list:  }

function Sorted_list.Compare...; begin...end;

end.  {  --  unit Dico_Handling  --  }
(*
-------------------------------------------------------------------

Now, let me explain what I have done:
=====================================

At {1} we have the declaration of the type Full_Dictionary,
derived from Dictionary. As you can see, it is a fully concrete
type (not an abstract one), with several methods and fields.

Full_Dictionary, is actually the type that matters for the
implementation and its methods will represent the bulk
of the text. On the other hand, at {2} and {3} you can see
that all methods of Dictionary - the externally visible type -
are abstract.

The final supporting leg of the technique happens at {4}:
in the function New_Dictionary. You are asking for a Dictionary
and you get a Full_Dictionary! Then the "virtuals" play their role
so that if you call First_Word_Index or First_Phrase_Index,
you obtain the effect of these functions as defined for
the full type: Full_Dictionary.

The key reason why this works is that the only outside way
to obtain a Full_Dictionary is by a call to the function
New_Dictionary, which only allocates Full_Dictionary.  So any
user of the Unit will be dealing only with objects of this type.

(Strictly speaking, one could write new(Dictionary_name) but
nothing could be achieved with such objects since the methods
are all abstract.)


Why hide the implementation?
============================

To answer, see what happens if I had made the full type visible.
This means showing several operations which I have kept hidden:

    constructor  Init (Filename : PChar);
    destructor   Done;    virtual;
    procedure    Read_Dictionary  (Filename: Pchar);
    procedure    Open_Dictionary  (Filename: Pchar);
    procedure    Print_Pairs(C: PCollection);
    procedure    Test_Dictionary;

Well, if they are visible, it means that other units can use them
and call them, so that I have to worry about the effect of these
outside calls. Moreover, if I decide to modify the signature of one of
them, or delete it, I have to worry about the impacty on outside units.

If this were not bad enough, consider the field declarations:

    Start_Phrases : Starter;
    Start_Words   : Starter;

If you had Full_Dictionary in the interface part, they would not be
allowed UNLESS you also moved the declaration of the type Starter to
the interface.

This is a SPAGHETTI effect: you show a field and now you have to show
its type. You show a type (for a more general example) and you may need
to show also the constants it is using, and ... whatever type its fields
need in turn ... Little by little - one spaghetti pulling another one -
you end up having over inflated interface parts.

An Additional Benefit
=====================

of the technique is illustrated at {5} in the Init constructor.
What is shown is that you can alternate the implementation
of the fields All_Words and All_Phrases without this influencing
outside units. You recompile the unit and relink to test the
alternate implementations.

Conclusions
============

I occasionally find myself in the situation of getting a unit
developed without these concerns for information hiding.
My first task is then to try to understand the program and this means,
in particular, to understand the relationship that the unit may
have with other units.

Whenever in this situation, I perform my favorite transformation
which consists in trying to hide as much as I can.  When the
transformation succeeds, then I know that I have full lattitude
of modification for the implementation, without fear of impacting
other outside units.

The key idea is that most programs are far too exhibitionist
and show too much in the interface part. So I start hiding as much as
I can about the types, the reason being to overcome the spaghetti
effect that I described before.

Summary of the technique
========================

To hide the types, I start declaring skeletal types such as:

  type Input_Editor = object (TDialog)
      public
      end;

So the interface of a typical unit will look as follows:

  type Input_Editor = object (TDialog)
      public
      end;

  type Input_Editor_name = ^Input_Editor;

  function New_Input_Editor...: Input_Editor_name;

(The public-end section is not strictly needed but helps
emphasize that we know nothing about the type.)  Then in the
implementation part you will find:

  type Full_Input_Editor_name = object (Input_Editor)
    private
     ...
    end;

  type Input_Editor_name = ^Input_Editor;

followed by the function

  function New_Input_Editor...: Input_Editor_name;
  begin
    New_Input_Editor := new(Full_Input_Editor_name, init(...));
    ...
  end;

This is it.  The net result is that the Interface part now exports
very little.  This means that as a reader, I know now that all
the rest is purely internal and I need not worry about other
units using these other constants and types.  As a maintainer,
it means that I can modify them if needed with well circumscribed
effects.
*)
