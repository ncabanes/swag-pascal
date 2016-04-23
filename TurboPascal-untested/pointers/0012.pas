{
       PROTOTYPE PROCEDURES FOR CREATING AND ACCESSING SORTED
                 LINKED LISTS IN EXPANDED MEMORY

                  GARRY J. VASS [72307,3311]

The procedures and functions given below present a prototype
method for creating and accesing linked lists in expanded memory.
Although pointer variables are used in a way that appears to
conform to the TPascal pointer syntax, there are several major
differences:

            -  there are none of the standard NEW, GETMEM,
               MARK, RELEASE, DISPOSE, FREEMEM, and MAXAVAIL
               calls made.  These are bound to the program's
               physical location in memory, and have no
               effect in expanded memory.  Attempting to
               use these here, or to implement standard
               linked procedures by altering the HeapPtr
               standard variable is dangerous and highly
               discouraged.
            -  pointer variables are set and queried by
               a simulation of TPascal's internal procedures
               that is specially customized to the EMS
               page frame segment.
            -  the MEMAVAIL function is useless here.  These
               procedures will support a list of up to 64K.

The general pseudo-code for creating a linked list in expanded
memory is:

      1.  Get a handle and allocate memory from the EMM.
      2.  Get the page frame segment for the handle to
          mark the physical beginning of the list in
          expanded memory.
      3.  Initialize the root pointer to the page frame
          segment.
      4.  For each new record (or list member):

          a.  Calculate a new physical location for the
              record using a simulated normalization
              procedure.
          b.  Set the appropriate values to the
              pointers using a simulated pointer
              assignment procedure.
          c.  Assure that the last logical record
              contains a pointer value of NIL.

Accessing the list is basically the same as the standard algorithms.

The procedures here assume that each list record (or member) is composed
of three elements:

        -  a pointer to the next logical record.  If the member is the
           last logical record, this pointer is NIL.
        -  an index, or logical sort key.  This value determines the
           logical position of the record in the list.  These routines
           and the demo use an integer type for index.  The index,
           however, can be of any type where ordinal comparisons
           can be made, including pointers.
        -  an area for the actual data in each record.  These routines
           and the demo use a string of length 255, but this area can
           be of any type, including pointers to other lists.

Please note that these routines are exploratory and prototype.  In no way
are they intended to be definitive, accurate, efficient, or exemplary.

Areas for further analysis are:

      1.  A reliable analog to the MEMAVAIL function.
      2.  Creating linked lists that cross handle boundaries.
      3.  Creating linked lists that begin in heapspace and
          extend to expanded memory.
      4.  A reliable method for assigning the standard
          variable, HeapPtr, to the base page.

Please let me know of your progress in these areas, or improvements
to the routines below via the BORLAND SIG [72307,3311] or my PASCAL/
PROLOG SIG at the POLICE STATION BBS (201-963-3115).

}
PROGRAM LINKED_LISTS;
Uses dos,crt;
CONST
     ALLOCATE_MEMORY =   $43;
     EMS_SERVICES    =   $67;
     FOREVER:BOOLEAN = FALSE;
     GET_PAGE_FRAME  =   $41;
     LOGICAL_PAGES   =     5;
     MAP_MEMORY      =   $44;
     RELEASE_HANDLE  =   $45;
TYPE
    ANYSTRING = STRING[255];
    LISTPTR   = ^LISTREC;
    LISTREC   = RECORD
                      NEXT_POINTER : LISTPTR;
                      INDEX_PART   : INTEGER;
                      DATA_PART    : ANYSTRING;
                END;
VAR
   ANYINTEGER : INTEGER;
   ANYSTR     : ANYSTRING;
   HANDLE     : INTEGER;    { HANDLE ASSIGNED BY EMM }
   LIST       : LISTREC;
   NEWOFFSET  : INTEGER;    { PHYSICAL OFFSET OF RECORD }
   NEWSEGMENT : INTEGER;    { PHYSICAL SEGMENT OF RECORD }
   REGS1      : Registers;
   ROOT       : LISTPTR;    { POINTER TO LIST ROOT }
   SEGMENT    : INTEGER;    { PAGE FRAME SEGMENT }

{--------------------- GENERAL SUPPORT ROUTINES  ----------------------}
FUNCTION HEXBYTE(N:INTEGER):ANYSTRING;
CONST H:ANYSTRING='0123456789ABCDEF';
BEGIN
     HEXBYTE:=H[((LO(N)DIV 16)MOD 16)+1]+H[(LO(N) MOD 16)+1];
END;

FUNCTION HEXWORD(N:INTEGER):ANYSTRING;
BEGIN
     HEXWORD:= HEXBYTE(HI(N))+HEXBYTE(LO(N));
END;

FUNCTION CARDINAL(I:INTEGER):REAL;
BEGIN
     CARDINAL:=256.0*HI(I)+LO(I);
END;

PROCEDURE  PAUSE;
VAR CH:CHAR;
BEGIN
     WRITELN;WRITELN('-- PAUSING FOR KEYBOARD INPUT...');
     READ(CH);
     WRITELN;
END;

PROCEDURE DIE(M:ANYSTRING);
BEGIN
     WRITELN('ERROR IN: ',M);
     WRITELN('HALTING HERE, SUGGEST REBOOT');
     HALT;
END;
FUNCTION EXIST(FILENAME:ANYSTRING):BOOLEAN;VAR FILVAR:FILE;BEGIN ASSIGN(FILVAR,FILENAME);{$I-}
RESET(FILVAR);{$I+}EXIST := (IORESULT = 0);END;
{--------------------- END OF GENERAL SUPPORT ROUTINES  ----------------}

{----------------------  EMS SUPPORT ROUTINES  -------------------------}

FUNCTION EMS_INSTALLED:BOOLEAN;         { RETURNS TRUE IF EMS IS INSTALLED }
BEGIN                                   { ASSURED DEVICE NAME OF EMMXXXX0  }
     EMS_INSTALLED := EXIST('EMMXXXX0');{ BY LOTUS/INTEL/MS STANDARDS      }
END;

FUNCTION NEWHANDLE(NUMBER_OF_LOGICAL_PAGES_NEEDED:INTEGER):INTEGER;
BEGIN
     REGS1.AH := ALLOCATE_MEMORY;
     REGS1.BX := NUMBER_OF_LOGICAL_PAGES_NEEDED;
     INTR(EMS_SERVICES, REGS1);
     IF REGS1.AH <> 0 THEN DIE('ALLOCATE MEMORY');
     NEWHANDLE := REGS1.DX;
END;

PROCEDURE KILL_HANDLE(HANDLE_TO_KILL:INTEGER);  { RELEASES EMS HANDLE.    }
BEGIN                                           { THIS MUST BE DONE IF    }
     REPEAT                                     { OTHER APPLICATIONS ARE  }
          WRITELN('RELEASING EMS HANDLE');      { TO USE THE EM ARES.  DUE}
          REGS1.AH := RELEASE_HANDLE;            { TO CONCURRENT PROCESSES,}
          REGS1.DX := HANDLE_TO_KILL;            { SEVERAL TRIES MAY BE    }
          INTR(EMS_SERVICES, REGS1);             { NECESSARY.              }
     UNTIL REGS1.AH = 0;
     WRITELN('HANDLE RELEASED');
END;

FUNCTION PAGE_FRAME_SEGMENT:INTEGER;         { RETURNS PFS }
BEGIN
     REGS1.AH := GET_PAGE_FRAME;
     INTR(EMS_SERVICES, REGS1);
     IF REGS1.AH <> 0 THEN DIE('GETTING PFS');
     PAGE_FRAME_SEGMENT := REGS1.BX;
END;

PROCEDURE MAP_MEM(HANDLE_TO_MAP:INTEGER);  {MAPS HANDLE TO PHYSICAL}
CONST PHYSICAL_PAGE = 0;                 {PAGES.}
BEGIN
     REGS1.AH := MAP_MEMORY;
     REGS1.AL := PHYSICAL_PAGE;
     REGS1.BX := PHYSICAL_PAGE;
     REGS1.DX := HANDLE_TO_MAP;
     INTR(EMS_SERVICES, REGS1);
     IF REGS1.AH <> 0 THEN DIE('MAPPING MEMORY');
END;

PROCEDURE GET_EMS_MEMORY(NUMBER_OF_16K_LOGICAL_PAGES:INTEGER);
VAR TH:INTEGER;                     { REQUESTS EM FROM EMM IN 16K INCREMENTS }
BEGIN
     HANDLE :=  NEWHANDLE(NUMBER_OF_16K_LOGICAL_PAGES);
     SEGMENT := PAGE_FRAME_SEGMENT;
     MAP_MEM(HANDLE);
END;
{----------------- END OF EMS SUPPORT ROUTINES  -----------------------}

{----------------- CUSTOMIZED LINKED LIST SUPPORT ---------------------}
FUNCTION ABSOLUTE_ADDRESS(S, O:INTEGER):REAL;   { RETURNS THE REAL }
BEGIN                                           { ABSOLUTE ADDRESS }
     ABSOLUTE_ADDRESS :=  (CARDINAL(S) * $10)   { FOR SEGMENT "S"  }
                         + CARDINAL(O);         { AND OFFSET "O".  }
END;

PROCEDURE NORMALIZE(VAR S, O:INTEGER); { SIMULATION OF TURBO'S INTERNAL }
VAR                                    { NORMALIZATION ROUTINES FOR     }
   NEW_SEGMENT: INTEGER;               { POINTER VARIABLES.             }
   NEW_OFFSET : INTEGER;               { NORMALIZES SEGMENT "S" AND     }
BEGIN                                  { OFFSET "O" INTO LEGITAMATE     }
     NEW_SEGMENT := S;                 { POINTER VALUES.                }
     NEW_OFFSET  := O;
     REPEAT
           CASE NEW_OFFSET OF
              $00..$0E   : NEW_OFFSET := SUCC(NEW_OFFSET);
              $0F..$FF   : BEGIN
                               NEW_OFFSET := 0;
                               NEW_SEGMENT := SUCC(NEW_SEGMENT);
                           END;
           END;
     UNTIL  (ABSOLUTE_ADDRESS(NEW_SEGMENT, NEW_OFFSET) >
             ABSOLUTE_ADDRESS(S, O) + SIZEOF(LIST));
     S := NEW_SEGMENT;
     O := NEW_OFFSET;
END;

FUNCTION VALUEOF(P:LISTPTR):ANYSTRING;  { RETURNS A STRING IN   }
                                        { SEGMENT:OFFSET FORMAT }
                                        { WHICH CONTAINS VALUE  }
BEGIN                                   { OF A POINTER VARIABLE }
     VALUEOF := HEXBYTE(MEM[SEG(P):OFS(P) + 3]) +
                HEXBYTE(MEM[SEG(P):OFS(P) + 2]) +':'+
                HEXBYTE(MEM[SEG(P):OFS(P) + 1]) +
                HEXBYTE(MEM[SEG(P):OFS(P) + 0]);
END;

PROCEDURE SNAP(P:LISTPTR);                   { FOR THE RECORD BEING         }
BEGIN                                        { POINTED TO BY "P", THIS      }
     WRITELN(VALUEOF(P):10,                  { PRINTS THE SEGMENT/OFFSET    }
             VALUEOF(P^.NEXT_POINTER):20,    { LOCATION, THE SEGMENT/       }
             P^.INDEX_PART:5,                { OFFSET OF THE RECORD PONTER, }
             '     ',P^.DATA_PART);          { RECORD INDEX, AND DATA.      }
END;

PROCEDURE PROCESS_LIST;               { GET AND PRINT MEMBERS OF A LIST }
VAR M1:LISTPTR;                       { SORTED IN INDEX ORDER.          }
BEGIN
     PAUSE;
     M1 := ROOT;
     WRITELN;
     WRITELN('---------------- LINKED LIST ---------------------------------');
     WRITELN('MEMBER LOCATION           MEMBER CONTENTS');
     WRITELN('IN MEMORY             POINTER    INDEX  DATA   ');
     WRITELN('---------------       -----------------------------------------');
     WRITELN;
     REPEAT
           SNAP(M1);
           M1 := M1^.NEXT_POINTER;
     UNTIL M1 = NIL;
     WRITELN('------------ END OF LIST----------');
END;

PROCEDURE LOAD_MEMBER_HIGH (IND:INTEGER; DAT:ANYSTRING);
VAR M1:LISTPTR;
     P:LISTPTR;                  { INSERTS A RECORD AT THE HIGH }
BEGIN                            { END OF THE LIST.             }
     M1 := ROOT;
     REPEAT
           IF M1^.NEXT_POINTER <> NIL THEN M1 := M1^.NEXT_POINTER;
     UNTIL M1^.NEXT_POINTER = NIL;
     NORMALIZE(NEWSEGMENT, NEWOFFSET);
     M1^.NEXT_POINTER := PTR(NEWSEGMENT, NEWOFFSET);
     P := M1^.NEXT_POINTER;
     P^.INDEX_PART := IND;
     P^.DATA_PART := DAT;
     P^.NEXT_POINTER := NIL;
END;

PROCEDURE LOAD_MEMBER_MIDDLE (IND:INTEGER; DAT:ANYSTRING);
VAR M1:LISTPTR;
    M2:LISTPTR;
    P :LISTPTR;
    T :LISTPTR;
BEGIN                         { INSERTS A MEMBER INTO THE MIDDLE }
     M1 := ROOT;              { OF A LIST.                       }
     REPEAT
           M2 := M1;
           IF M1^.NEXT_POINTER <> NIL THEN M1 := M1^.NEXT_POINTER;
     UNTIL (M1^.NEXT_POINTER = NIL) OR (M1^.INDEX_PART >= IND);
     IF (M1^.NEXT_POINTER = NIL) AND
        (M1^.INDEX_PART <   IND) THEN
        BEGIN
             LOAD_MEMBER_HIGH (IND, DAT);
             EXIT;
        END;
     T := M2^.NEXT_POINTER;
     NORMALIZE(NEWSEGMENT, NEWOFFSET);
     M2^.NEXT_POINTER := PTR(NEWSEGMENT, NEWOFFSET);
     P := M2^.NEXT_POINTER;
     P^.INDEX_PART := IND;
     P^.DATA_PART := DAT;
     P^.NEXT_POINTER := T;
END;

PROCEDURE LOAD_MEMBER (IND:INTEGER; DAT:ANYSTRING);
VAR  M1:LISTPTR;
BEGIN
     WRITELN('ADDING:  ',DAT,' WITH AGE OF ',IND);
     WRITELN('TURBO`S HEAP POINTER:  ',VALUEOF(HEAPPTR),
             ', MEMAVAIL = ',MEMAVAIL * 16.0:8:0);
     WRITELN;
     PAUSE;
     WRITELN('... SEARCHING FOR ADD POINT ...');
     IF ROOT^.INDEX_PART <= IND THEN             { ENTRY POINT ROUTINE FOR }
        BEGIN                                    { ADDING NEW LIST MEMBERS }
             LOAD_MEMBER_MIDDLE(IND, DAT);       { ACTS ONLY IF NEW MEMBER }
             EXIT;                               { SHOULD REPLACE CURRENT  }
        END;                                     { ROOT.                   }
     M1 := ROOT;
     NORMALIZE(NEWSEGMENT, NEWOFFSET);
     ROOT := PTR(NEWSEGMENT, NEWOFFSET);
     ROOT^.INDEX_PART   := IND;
     ROOT^.DATA_PART    := DAT;
     ROOT^.NEXT_POINTER := M1;
END;

PROCEDURE INITIALIZE_ROOT_ENTRY(IND:INTEGER; DAT:ANYSTRING);
BEGIN
     ROOT := PTR(NEWSEGMENT, NEWOFFSET);       { INITIALIZES A LIST AND }
     ROOT^.INDEX_PART   := IND;                { ADDS FIRST MEMBER AS   }
     ROOT^.DATA_PART    := DAT;                { "ROOT".                }
     ROOT^.NEXT_POINTER := NIL;
END;

BEGIN
     TEXTCOLOR(15);
     IF NOT EMS_INSTALLED THEN DIE('LOCATING EMS DRIVER');
     CLRSCR;
     WRITELN('DEMO OF LINKED LIST IN EXPANDED MEMORY...');
     WRITELN('SETTING UP EMS PARAMETERS...');
     GET_EMS_MEMORY(LOGICAL_PAGES);
     WRITELN;
     WRITELN('ASSIGNED HANDLE:  ',HANDLE);
     NEWSEGMENT := SEGMENT;
     NEWOFFSET  := 0;
     WRITELN('EMS PARAMETERS SET.  BASE PAGE IS:  ',HEXWORD(SEGMENT));
     WRITELN;
     WRITELN('TURBO`S HEAP POINTER IS ',VALUEOF(HEAPPTR));
     WRITELN('READY TO ADD RECORDS...');
     PAUSE;

{ Demo:  Create a linked list of names and ages with age as the index/sort
  key.  Use random numbers for the ages so as to get a different sequence
  each time the demo is run.}

     INITIALIZE_ROOT_ENTRY(RANDOM(10) + 20, 'Anne Baxter (original root)');
     LOAD_MEMBER(RANDOM(10) + 20,  'Rosie Mallory  ');
     LOAD_MEMBER(RANDOM(10) + 20,  'Sue Perkins    ');
     LOAD_MEMBER(RANDOM(10) + 20,  'Betty Williams ');
     LOAD_MEMBER(RANDOM(10) + 20,  'Marge Holly    ');
     LOAD_MEMBER(RANDOM(10) + 20,  'Lisa Taylor    ');
     LOAD_MEMBER(RANDOM(10) + 20,  'Carmen Abigail ');
     LOAD_MEMBER(RANDOM(10) + 20,  'Rhonda Perlman ');
     PROCESS_LIST;
     KILL_HANDLE(HANDLE);
END.
