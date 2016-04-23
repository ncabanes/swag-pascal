SECTION 18 - Turbo Vision
--------------------------------

This document contains information that is most often provided
to users of this section.  There is a listing (when available)
of common Technical Information Documents and example files that
can be downloaded from the libraries, and a listing of the most
frequently asked questions and their answers.


TECHNICAL INFORMATION DOCUMENTS AND EXAMPLE FILES
-------------------------------------------------

TI1721   Determining input focus on Turbo Vision
TI1725   Local Menus in Turbo Vision
TI1729   Simultaneous Dialogs in Turbo Vision 
TI1779   Adding and Removing items from a Turbo Vision Listbox
TI469    Turbo Vision program to go into 132 column mode
TI991    Multiple variations of TInputLine for Turbo Vision
TI993    Use different color combinations in Turbo Vision

TVG110.ZIP   Graphics Mode Version of Turbo Vision


FREQUENTLY ASKED QUESTIONS AND ANSWERS
--------------------------------------

Q:   "Can Turbo Vision be run in graphics mode?"

A:   Turbo Vision was not designed to support graphics. However,
     there is a file in this library 1 (TVG110.ZIP), which gives
     you a graphics-mode version of Turbo Vision.  There may be
     others uploaded periodically, it's best to search the
     libraries.

Q:   "Are there any books that cover Turbo Vision?"

A:   Books that cover Turbo Vision are:

      "A Programmer Guide to Turbo Vision"
         by Freddy Etrl, Ralph Machholz and Andi Golgath
         Addison-Wesley ISBN 0-201-62401-X

      "Turbo Pascal 6.0 Techniques and Utilities"
         by Neil J. Rubenking
         Ziff Davis Press ISBN 1-56276-010-6

      "Clean Coding in Turbo Pascal 6"
         by Amrik Dhillon
         M&T Books ISBN 1-55851-228-4

Q:   "I don't seem to be getting all the memory used by
     collections after disposing them.  What could be going
     wrong?"

A:   If you don't seem to be getting back all your memory when
     disposing of a collection, then there are several things you
     may be doing wrong:

     *  You are allocating the collection with 
    
             MyColl := New(PMyColl, init(...))

        but are only destroying it with
        
             MyColl^.Done

        instead of 

             Dispose(MyColl, Done).

     *  You have a memory leak in your TObject descendant that
        you are placing in the collection (check your allocations
        in the Init constructor and the deallocs in your Done
        destructor).

     *  You are not putting TObject descendants in the
        collection at all (this generally creates program
        crashes.

     *  If you call the delete method, the delete method just
        removes the object from the collection but does NOT
        destroy the object, Free removes the object from the
        collection and then destroys it by calling FreeItem
        (which normally calls Dispose(Item, Done)).

Q:   "What is the proper way to switch from TVision to graphics
     and back?"

A:   For an example you can ook at the DosShell code in APP.PAS
     (or in TVDEMO, if you're using TP6). Follow the same steps,
     but replace the Exec statement with your graphics stuff.
     If you're using TP7/BP7, you may find that you need to
     replace the DoneDosMem/InitDosMem with
     DoneMemory/InitMemory.

Q:   "How do you make change the default background of a TVision
     application?"

A:   The TBackground object is designed to use only 1 ascii
     character. You could create a new type of background
     object.

    Type
       PMyBackground = ^TMyBackground;
       TMyBackground = Object(TView)
         { Variables go here to support your box or text or whatever }
        Procedure Draw; virtual;
        Function GetPalette: PPalette; virtual; { You override this }
         { Other methods here like Load and Store }
       End;

    Procedure TMyBackground.Draw;
    Begin
      { Your drawing routine which draws over the whole view }
    End;

    
    Also, you will have to override TDesktop.

    Type
       PMyDesktop = TMyDesktop;
       TMyDesktop = Object(TDesktop)
        Procedure InitBackground; virtual;
    End;

    Procedure TMyDesktop.InitBackground;
    Var
       P: PView;
       R: TRect;
    Begin
       GetExtent(R);
       P := New(PMyBackground, Init(R));
       If ValidView(P) Then
           Insert(P);
    End;

    
    You must also override InitDesktop in your main TApplication.

    Type
       PMyApp = ^TMyApp;
       TMyApp = Object(TApplication)
        Procedure InitDesktop; virtual;
       End;

    Procedure TMyApp.InitDesktop;
    Var
       P: PView;
    Begin
       GetExtent(R);
       Inc(R.A.Y);
       Dec(R.B.Y);
       P := New(PDesktop, Init(R));
       If ValidView(P) Then
           Insert(P);
    End;
