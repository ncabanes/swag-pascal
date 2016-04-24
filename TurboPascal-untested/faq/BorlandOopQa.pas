(*
  Category: SWAG Title: FREQUENTLY ASKED QUESTIONS/TUTORIALS
  Original name: 0008.PAS
  Description: BORLAND - OOP QA
  Author: SWAG SUPPORT TEAM
  Date: 06-01-93  06:59
*)


TP 5.5 OOP - OBJECT EXE FILE SIZE OVERHEAD
Q. How much overhead will result in the *.EXE file from using the
   object oriented style?
A. The overhead will result from the pointer from the object to
   its method.  This is a 4 byte pointer, so there isn't that
   much extra code generated.


TP 5.5 OOP - PROTECTED AND PRIVATE FIELDS
Q. Does Turbo Pascal 5.5 support Protected or Private fields?
A. No it does not.


TP 5.5 OOP - RECORDS VS. OBJECTS
Q. What things can be done with Records that can not be done with
   Objects?
A. You cannot have:

     1. Variant Objects.
     2. Objects with absolutes.
     3. Directly nested Objects.

   You can have:

       1. Pointers to objects.

TP 5.5 OOP - EXTERNAL METHODS
Q. Can methods within an object be external?
A. Yes. Virtual and Static methods can be written as external
   code. There is no difference between an external Virtual or
   Static method. External Constructors and Destructors are
   difficult to write due to the Prolog and Epilog code within
   them.

TP 5.5 OOP - CONSTRUCTOR USE
Q. What are the three purposes of a Constructor?
A. 1. Insert the address of the VMT into the Object variable.
        (Implicit)
   2. To allocate memory for the Object variable. 
        (Implicit)
   3. To initialize the Object variable. 
        (Explicit)

TP 5.5 OOP - DESTRUCTOR HEAP CORRUPTION
Q. Why is my destructor fragging my heap?
A. Use: 
     
     Dispose(ptr,done);

   instead of:
   
     ptr^.done;
     Dispose(done);

TP 5.5 OOP - SAVING OBJECTS TO DISK
Q. Can I save my objects to a disk file like I can a record
   structure?
A. We have provided an example program on the distribution
   diskette, STREAMS, which documents how to save an object to
   disk.

TP 5.5 OOP - FILES OF OBJECT TYPE
Q. Why can't I make a file of ObjectType?
A. Because by the rules of polymorphism, any descendant of
   ObjectType would be type compatible and be able to be written 
   to disk as well. The problem with this is that the descendants
   may be (and usually are) of a larger size than the ObjectType 
   itself.  Pascal's file structure require all records to be 
   the same size, otherwise, how do you know which size object 
   do you read in? For an example on how to do Object disk I/O, 
   please see the STREAMS example on the distribution diskettes.

TP 5.5 OOP - SIZEOF OBJECTS CONSTRUCTOR
Q. Why does Sizeof(MyObject) return a size 2 bytes larger than I
   expect when no virtual methods are used?
A. By placing a constructor in your object, you're making the 
   object virtual.

TP 5.5 OOP - LINKER STRIPS UNUSED STATIC METHODS
Q. It appears that my static methods are getting stripped from 
   my program by the smart linker when they are unused. Yet, 
   my virtual methods are not. How come?
A. Static methods can be stripped because it can be determined at
   link time what methods will be called. Virtual methods can 
   not be stripped because the program will not know what methods
   will be used, and what will not, until run time. This is 
   because of late binding.

TP 5.5 OOP - CONSTRUCTOR CALL TO ANCESTOR WITH VIRTUALS
Q. If a descendant of a virtual object defines no virtual
   methods of its own, does it need to call the ancestor's
   constructor?
A. If an object is a descendant of a virtual object, it must call
   that ancestor's constructor or it's own constructor. Even if
   the new object does not define any virtuals of its own. For
   example:

     Type
       A = Object 
             Constructor Init; 
             Procedure AA; Virtual; 
       End; 
       B = Object ( A ) 
       End; 

   For each instance of A and of B, Init must be called or the
   Virtual Method Table pointer will not be loaded correctly.

TP 5.5 OOP - OVERRIDE VIRTUAL METHOD CALLING ANCESTOR
Q. Can I override a virtual method and force a call to the
   ancestor objects method?
A. No. Late binding will always call the current method and it
   defeats the purpose of object oriented program to go around 
   this feature.

TP 5.5 OOP - CONSTRUCTOR CALL WITHIN METHOD
Q. I am calling my constructor from within a method, why am I
   having problems?
A. The problem will arise when the constructor loads the new VMT
   pointer. It loads the pointer to the VMT for the constructor's
   table, not the instances. Therefore if a descendant calls an
   ancestor's constructor, the descendant's VMT will now point to
   the ancestors VMT. The problem now occurs when the descendant
   tries to call a method that was defined after the ancestor.
   The VMT entry for this method is unknown. Look at the
   following example: 

     Type 
       L1 = Object 
              Constructor Init;
              Procedure First; Virtual; 
       End; 
       L2 = Object ( L1 ); 
              Constructor Init; 
              Procedure Second; Virtual; 
       End;

     Constructor L1.Init;
     Begin
     End;

     Constructor L2.Init;
     Begin
     End;

     Procedure L1.First;
     Begin
       Init;
     End;

     Procedure L2.Second;
     Begin
       Init;
     End;

     Var
       L : L2;

     Begin
       L.Init;   { This calls L2.Init and loads a pointer to }
                 { the L2 VMT into L.                        }
       L.First;  { This will call L1.First, which in turn calls }
                 { L1.Init because as far as the procedure is   }
                 { concerned, the Self pointer is a pointer     }
                 { to an object of type L1.                     }
       L.Second; { This is undefined. Since the VMT now       }
                 { pointed to by L is L1's, the pointer to    } 
                 { method Second is undefined. Therefore, the }
                 { call to this method is undefined.          }
       ...

TP 5.5 OOP - CONSTRUCTOR CALL WITHIN POLYMORPHIC METHOD
Q. Does the previous question apply to polymorphic procedures?
A. Yes. The previous question and answer apply to every case
   where the compiler may think of an object as its ancestor. A
   polymorphic example that is incorrect follows:

     Procedure Init ( var x : L1 );
     Begin
       x.Init;  { This will ALWAYS call L1.Init }
     End;

TP 5.5 OOP - CONSTRUCTOR CALLING ANCESTOR'S CONSTRUCTOR
Q. Should my current object's constructor call it's ancestor's
   constructors?
A. As a rule of thumb, this is the correct thing to do. It is
   okay to not do it, but it does allow initialization of
   whatever the previous constructors did.

TP 5.5 OOP - CALLING ANCESTORS CONSTRUCTOR
Q. How do you call a constructor from an ancestor's object?
A. You can call an ancestor's constructor directly from within
   the constructor of the current object.  For example:

     Type
       Type1 = Object
                 Constructor Init;
       End;
       Type2 = Object ( Type1 )
                 Constructor Init;
       End;

     Constructor Type1.Init;
     Begin
     End;

     Constructor Type2.Init;
     Begin
       Type1.Init;
     End;
     ...


