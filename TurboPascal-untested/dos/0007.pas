
------------------------------------------------------------------------

Echo Flag :         Permanent: N       Export: N      Personal Read: N

 BBS: IN-TECH         Conference: PASCAL          Imported: 11/14/1991
  To: DAVID HICKEY                    Num: 1442       Date: 10/31/1991
From: MARK OUELLET                     Re: 0          Time: 10:51 pm
Subj: >NUL REDIRECTION               Prvt: N          Read: N

    On 27 Oct 91, you, David Hickey, of 1:261/1108.0 wrote...

 DH> From the DOS prompt, I can redirect things easily.  But when I try it in 
 DH> my program, it doesn't work at all.  Here's what I'm doing:
 DH> 
 DH> EXEC ('C:\Pkzip.Exe', '-o c:\ra\ra.zip c:\ra\ralogs\ra.log >nul');
 DH> 
 DH> The problem is that the information from Pkzip is not being redirected 
 DH> to NUL
 DH> like I want it to.  It's obviously got to be something I'm not doing 
 DH> right. Anyone know what it is?  I've tried everything I can think of.

David,
        This might help you,

Msg#:20994 *> PASCAL  Echo <*
03/17/89 03:15:00
From: ROSS WENTWORTH
  To: NORBERT LANGE
Subj: REPLY TO MSG# 20986 (RE: REDIRECTING STDERR)
 > I'd appreciate seeing some code.  I've tried this before,
 > using a couple different methods, and couldn't seem to get
 > DOS to like redirecting StdErr.  I tried the $45 (Duplicate
 > File Handle) function as well with no success.

Ok, here's a routine that can be easily modified to do the job. It replaces 
EXEC from the DOS unit and checks the "command line" for the redirection 
symbols ('>' and '<').  One minor change and it will redirect STDERR to the 
file (see comment below).
{=============================================================}
Unit Execute;

Interface

Procedure Exec(Path,CmdLine : String);

Implementation

Uses
  Dos;

Function ExtractFileName(Var Line : String;Index : Integer) : String;

Var
  Temp : String;

Begin
  Delete(Line,Index,1);
  While (Index <= Length(Line)) AND (Line[Index] = ' ')
    Do Delete(Line,Index,1);
  Temp := '';
  While (Index <= Length(Line)) AND (Line[Index] <> ' ') Do
  Begin
    Temp := Temp + Line[Index];
    Delete(Line,Index,1);
  End;
  ExtractFileName := Temp;
End;

Procedure CloseHandle(Handle : Word);

Var
  Regs : Registers;

Begin
  With Regs Do
  Begin
    AH := $3E;
    BX := Handle;
    MsDos(Regs);
  End;
End;

Procedure Duplicate(SourceHandle : Word;Var TargetHandle : Word);

Var
  Regs : Registers;

Begin
  With Regs Do
  Begin
    AH := $45;
    BX := SourceHandle;
    MsDos(Regs);
    TargetHandle := AX;
  End;
End;

Procedure ForceDuplicate(SourceHandle : Word;Var TargetHandle : Word);

Var
  Regs : Registers;

Begin
  With Regs Do
  Begin
    AH := $46;
    BX := SourceHandle;
    CX := TargetHandle;
    MsDos(Regs);
    TargetHandle := AX;
  End;
End;

Procedure Exec(Path,CmdLine : String);

Var
  StdIn   : Word;
  Stdout  : Word;
  Index   : Integer;
  FName   : String[80];
  InFile  : Text;
  OutFile : Text;

  InHandle  : Word;
  OutHandle : Word;
         { ===============>>>> }   { change below for STDERR }
Begin
  StdIn := 0;
  StdOut := 1;                    { change to 2 for StdErr       }
  Duplicate(StdIn,InHandle);      { duplicate standard input     }
  Duplicate(StdOut,OutHandle);    { duplicate standard output    }
  Index := Pos('>',CmdLine);
  If Index > 0 Then               { check for output redirection }
  Begin
    FName := ExtractFileName(CmdLine,Index);  { get output file name }
    Assign(OutFile,FName);                    { open a text file      }
    Rewrite(OutFile);                         { .. for output         }
    ForceDuplicate(TextRec(OutFile).Handle,StdOut);{ make output same }
  End;
  Index := Pos('<',CmdLine);
  If Index > 0 Then               { check for input redirection }
  Begin
    FName := ExtractFileName(CmdLine,Index);  { get input file name }
    Assign(InFile,FName);                     { open a text file    }
    Reset(InFile);                            { for input           }
    ForceDuplicate(TextRec(InFile).Handle,StdIn);  { make input same }
  End;
  DOS.Exec(Path,CmdLine);           { run EXEC }
  ForceDuplicate(InHandle,StdIn);   { put standard input back to keyboard }
  ForceDuplicate(OutHandle,StdOut); { put standard output back to screen  }
  CloseHandle(InHandle);            { close the redirected input file     }
  CloseHandle(OutHandle);           { close the redirected output file    }
End;

End.

{===============================================================}

Use it exactly as you would the normal EXEC procedure:

  Exec('MASM.EXE','mystuff.asm');

To activate redirection simply add the redirection symbols, etc:

  Exec('MASM.EXE',mystuff.asm >err.lst');


One note of caution.  This routine temporarily uses extra handles.  It'
s either
two or four more.  The various books I have are not clear as two whether 
duplicated handles 'count' or not. My guess is yes.  If you don't plan on 
redirecting STDIN then remove all the code for duplicating it to cut your
handle overhead in half.

                                    Ross Wentworth

+++ FD 2.00
 Origin: St Dymphna's Retreat via Torrance BBS 213-370-9027 (1:102/345.1)

        Best regards,
        Mark Ouellet.


--- ME2
 * Origin: The Doctor's Tardis, A point in time!! (Fidonet 1:240/1.4)
==============================================================================
 BBS: «« The Information and Technology Exchan
  To: BUTCH ADAMS                  Date: 12-10─91 (18:00)
From: RUSS PARKS                 Number: 3982   [101] PASCAL
Subj: EXEC()                     Status: Public
------------------------------------------------------------------------------
* In a bleating, agonizing plea to All, Butch Adams groaned:

BA>       I'm wondering if I can get some insight as to how to
BA>use the Exec() command in TP6. What I'm trying to do is this:
BA> Exec('Type Filename|sort > newfilename', '');
BA>I've even tried this:
BA> Exec('Type', 'filename|sort > newfilename');

 Close, but no cigar :-) Try something like this:
        Exec('command.com', '/c type filename | sort > newfilename');

 The first parameter is the path to the program to be run. In this
case, 'TYPE' is an internal DOS command so you need to run
COMMAND.COM. The second parameter is a string with the command
line arguments you want to pass to the program.
  P.S.: The '/c' part of the parameters tells COMMAND.COM to execute
the command, then exit back to the program that originally
called the COMMAND.COM. It's like loading COMMAND.COM, running
a program, then typing 'EXIT'.
Besta'Luck,
Russ

---
 * Origin: Objectively.Speak('Turbo Pascal 6.0, YEAH!'); (1:170/212)
==============================================================================
 BBS: «« The Information and Technology Exchan
  To: BUTCH ADAMS                  Date: 12-10─91 (21:07)
From: MIKE COPELAND              Number: 4000   [101] PASCAL
Subj: EXEC()                     Status: Public
------------------------------------------------------------------------------
 BA>       I'm wondering if I can get some insight as to how to use the
 BA>Exec() command in TP6. What I'm trying to do is this:

 BA> Exec('Type Filename|sort > newfilename', '');

 BA>I've even tried this:

 BA> Exec('Type', 'filename|sort > newfilename');

 BA>But still no result. Are we able to execute internal commands from
 BA>within a TP program? I've tried loading Command.Com first but all I get
 BA>is the shell to come up and sit there with a C> staring back at me. I
 BA>would appreciate any help with this.

   The process to execute any DOS-callable program/command is more than
you're doing/showing here. Try the following:

{$M 4096,0,0}  { allocate space for the child process }

  SwapVectors;
  Exec (GetEnv('COMSPEC'),'/C Type filename|sort > newfile');
  SwapVectors;
  if DosError > 0 then  { check the result of Exec }
    You_Have_A_Problem;
  if DosExitCode <> 0 then
    You_Have_A_Different_Problem;
  { If you get here, everything's okay... }

   Read the manual about SwapVectors, DosError, DosExitCode, GetEnv,
Exec, the $M parameter, and all the stuff you don't understand here...


--- msged 2.07
 * Origin: Hello, Keyboard, my old friend... (1:114/18.10)
==============================================================================
 BBS: «« The Information and Technology Exchan
  To: ANDREW PARK                  Date: 12-10─91 (21:15)
From: MIKE COPELAND              Number: 4001   [101] PASCAL
Subj: PASCAL                     Status: Public
------------------------------------------------------------------------------
 AP>It's quite simple.
 AP>Here's an example
 AP>{$M,1025,0,0}  <-- I don't know what this means but you need anyways

   Well, it's very important: it states how much Stack, Heap_Min, and
Heap_Max space you're reserving for the program to use (and how
much space you're leaving for the child process to execute in).
The last (2nd 0) is the most important, since failing to reduce
this from the default of ALL memory will PREVENT the Exec from
having any memory to do its work within. So, setting it to 0
will say "reserve ALL of available memory (except for what's
used by my program itself) for the DOS call I'm going to make
from within my program".
   If you don't do this, it defaults to 640K - meaning "reserve NO
memory for the exec".

 AP>Program Copying;
 AP>Uses dos;
 AP>begin
 AP>  exec ('Command.com','copy a:*.* b:');
      Exec (GetEnv('COMSPEC'),'/C copy a:* b:*');
 AP>end.
 AP>Something like that.  See the manual for Exec section.

   You should also wrap that Exec call within a pair of SwapVectors
statements...before and after. Furthermore, it's a good idea to
check DosError and DosExitCode after the action, so see if any
problems occurred.
   Exec is very useful, but it carries a lot of "baggage" when used...

--- msged 2.07
 * Origin: Hello, Keyboard, my old friend... (1:114/18.10)
==============================================================================
 BBS: «« The Information and Technology Exchan
  To: KEVIN HIGGINS                Date: 01-04─92 (09:58)
From: MARK OUELLET               Number: 4088   [101] PASCAL
Subj: RE: HEAP KNOWLEDGE         Status: Public
------------------------------------------------------------------------------
    On 29 Dec 91, you, Kevin Higgins, of 1:128/74.0 wrote...

 KH> I still don't understand full use of the {$M} compiler directive.
 KH> The Pascal tome I have says nothing other than if you don't use New() or
 KH> GetMem() to set the HeapMin and HeapMax to 0. But it never says what to
 KH> set it to if you DO you New or GetMem. Nor could I find any reference on
 KH> ideal settings for a small program which Exec's another fairly small
 KH> program....

Kevin,
        New() and GetMem() are used to allocate space
(memory) off the heap (That which is left of the 640 K of
dos memory after your program is loaded and DOS and your
TSRs ect...) for variables that are created AT RUNTIME.
Variables you declare in the usual way ie: Var X : Integer;
allready have space allocated to them.

        The heap is used to allocate memory to dynamic
variables ie: variables accessed through the use of
pointers. These need to have memory allocated to them
(Unless you are using the pointer to access a region of
memory that allready contains information such as the
keyboard buffer etc... those allready have memory allocated
to them so you need NO MORE MEMORY TO USE THEM.) Those that
*YOU* create such as linked lists need memory. Your program
when compiled will only allocate 4 bytes for each pointer
(Pointers need 2 words, one for the segment, one for the
offset in that segment) thus the 4 bytes.

As a rule of thumb, if you don't create dynamic variables
then you can set the $M to: {$M 16384, 0, 0} which is the
minimum.

{$MStack space, minimum heap required to run, Max heap needed}

Stack space is the memory needed to hold the stack of your
program, each time you call a function or procedure from
another one, the old adress is pushed onto the stack, it
will pulled off when the called procedure finishes to find
out where to go back and continue executing. Local
variables, parameters are also saved on the stack so they
are not lost or modified while the other procedure is
running.

So if you have recursive procedures (procedures that call
themselfes) or use lots of parameters you could set a large
stack. you will find this out through trial and error. If it
doesn't run properly and halts with a *STACK OVERFLOW* error
(TP runtime error 202) then you know you need to increase
the stack space allocated to your program.

The second parameter is use IF you create dynamic variables,
it tells TP you need at least this much heap memory free to
run correctly and that it should return to DOS with an error
if at least that much is not free when you try to load your
program.

The last paramater is the Maximum heap memory you expect to
use, it can be calculated if you know how much you are going
to use like a big array. If you are using linked lists,
which can not allways be evaluated as to how many items the
list will contain, then you might decide to use it all.
Setting the 3rd parameter to 655360. This won't leave any
room to EXEC another program though.

So if you intend to run another program from yours, say
running PKUNZIP from a TP program of yours, then you should
set Maximum Heap to a value lower than 655360. If you know
PKUNZIP needs 55k to run without problems then you could
simply say:

        655360 - (55 * 1024) = 599040

and set $M to

{$M 16384, 0, 599040} this will ensure you have at least 55k
free for PKUNZIP yet giving you the maximum heap space at
the same time.

As allways if you don't use dynamic variables at all don't
bother with it simply use

{$M 16384, 0, 0} and you will allways have enough memory to
run other programs from your TP programs (Unless you don't
have enough memory to run them from DOS to begin with ;-) )


        Best regards,
        and a very Happy New Year
        Mark Ouellet.


--- ME2
 * Origin: BaseBall for Windows, use the disks as bases ;-) (Fidonet 1:240/1.4)
==============================================================================
 BBS: «« The Info-Tech BBS »»
  To: SHANE RUSSO                  Date: 01-24─92 (15:00)
From: MIKE COPELAND              Number: 5922   [101] $_PASCAL
Subj: TP 6.0 -- MEMORY ALLOCATI  Status: Public
------------------------------------------------------------------------------
 SR>    Could anyone inform me how to use the $M directive correctly, and
 SR>    what it does exactly?

 SR>    Also, what the stack size, heap min and heap max are? (How do you
 SR>    calculate the stack size, heap min and heap max)

   There is no absolute, exact answer to this question, since every TP
program has different characteristics and requirements.
However, I will try to give you (and others) some basics, from
which you can probably adjust and use as you learn what's right
for _you_ (every programmer has different styles, which also
affect the way the $M is used):

  {$M Stack,Heap_Min,Heap_Max}

   The Stack is used within your program for calls to subprograms
(functions and procedures). Its size is dependent on (1) how
deep your calls go (or recurse) and (2) how much parameter and
local data is referenced during these calls. The worst case
I've encountered is a recursive sort of strings, where each
level of call requires all the resident data of the routine and
the parameters passed (string data being so big) are saved on
the Stack - too many levels of such action will exceed the max.
available Stack value, 64K.
   So, if you're not making heavily-nested (or recursive) calls in your
program, you won't need much Stack space - 8192 is probably plenty.

   Heap is data _you_ explicitly ask for (unlike the implicit data used
by subprogram calls) - by New, GetMem (in TP), or by calling
library routines which do (therefore, you're not always in
control of this if you're using subroutine libraries you didn't
create). The two parameters stated in the $M are for (1) the
minimum value you want to reserve and (2) the maximum you want to allow.
   I don't know a good reason to ever use any value > 0 for the
Heap_Min parameter, since the runtime will allocate what's
needed (providing the Heap_Max still has something left) -
perhaps performance. So, it's the Heap_Max that's critical for
your consideration.
   I see 2 distinct things here, which are in conflict (and thus
require management of this parameter): dynamic memory use in
your program, and use of the Exec procedure to spawn a child
process. If you don't ever do one of these things, then you have
maximum use of the other; it's that simple 8<}}.
   However (!), doing this is not simple, if you're doing anything
sophistocated with TP. For instance, if you must use data >64K,
you've _got_ to use pointers - which implies dynamic memory
allocation (and consumes the Heap. If, OTOH, you Exec to DOS to
run other programs or DOS calls from within your program, you
must leave sufficient memory for DOS to load that other
program, etc. This, of course, depends on what you're Exec-ing.
   In either case, your program logic and application must determine
how much Heap_Max to reserve. The default is 640K (all of
conventional memory), which prevents _any_ child process
Exec-ing. This default will allow maximum possible use of
dynamic memory (New, GetMem); any need to Exec will require a
reduced value for Heap_Max.
   I often do a bit of both in my programs, and I typically use the
following $M parameter:

   {$M 8192,0,128000}

and I change either Stack or Heap_Max as I encounter runtime errors
during development. Everyone must do the same, for the reasons
I stated above.
   Note that you _won't_ be able to play with this during development
in the IDE, since that's a program already consuming a LOT of
available memory.
   Hope I made some sense/cleared up some confusion/helped.


--- msged 2.07
 * Origin: Hello, Keyboard, my old friend... (1:114/18.10)


------------------------------------------------------------------------

Echo Flag :         Permanent: N       Export: N      Personal Read: N

 BBS: IN-TECH         Conference: PASCAL          Imported: 11/11/1991
  To: ZAK SMITH                       Num: 1295       Date: 11/03/1991
From: TREVOR CARLSEN                   Re: 0          Time:  1:58 am
Subj: >NUL REDIRECTION               Prvt: N          Read: N

 ZS> Change that to
 ZS> EXEC ('C:\COMMAND.COM','c:\pkzip.exe -o ..... >nul');

I'd reckon that will not work on a majority of systems.  Better is ...

  exec(GetEnv('COMSPEC'),'c:\pkzip...etc');

That way it is not command.com specific.

TeeCee

--- TC-ED   v2.01  
 * Origin: The Pilbara's Pascal Centre (+61 91 732569) (3:690/644)
 
