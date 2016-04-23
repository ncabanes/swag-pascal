{
 PJ>    in PROG1.EXE i execute PROG2.EXE, ok...
 PJ>
 PJ>    in PROG2.EXE i want to check if PROG1.EXE is running,
 PJ>    PROG2.EXE can not start without PROG1.EXE starting it...
 PJ>
 PJ>    sounds crazy? :)
 PJ>
 PJ>    i need a routine for that (please help me!)

If you understand assembly and interrupts here is what I'm doing: I'm
hooking int 96h and using it as an installation check. When it is called
with AX = to a magic number (MagicNumber below) it will return another
magic number that says that it is installed (ReturnValue) below.

Try this:

PROG1 :
}

Uses Dos;

Const
   MagicValue=$1248;
   ReturnValue=$8421;

Label
   SaveInt96;

Var
   InstallSaveExitProc:Pointer;

Procedure InstallCheckIsr; Assembler;

Asm
   cmp ax,MagicValue {Is it an installation check?}
   je  @@InsCheck    {If so skip next part}
   db  EAh             {FAR JMP opcode}
SaveInt96:
   db  0 
   db  0
   db  0 
   db  0             {After program is running, this will jump to the

                         old interrupt handler} 
@@InsCheck: 
   mov ax,ReturnValue  {Return the ReturnValue in AX} 
   iret                     {Return from interrupt call}  
End; 
    
Procedure UnInstallCheck; 
 
Begin
   SetIntVector($96,POINTER(SaveInt96)); 
   ExitProc:=InstallSaveExitProc; 
End; 
    
Procedure InstallCheck;
 
Begin 
   GetIntVector($96,POINTER(SaveInt96)); 
   SetIntVector($96,@InstallCheckIsr); 
   InstallSaveExitProc:=ExitProc; 
   ExitProc:=@UnInstallCheck; 
End;
 
PROG 2: 
 
Uses Dos; 
 
Const 
   MagicValue=$1248; 
   ReturnValue=$8421; 
    
Function Installed:Boolean; Assembler; 
 
Asm
   mov ax,MagicValue    {Check to see if PROG1 installed} 
   int 96h 
   xor bl,bl                {BL temporarily holds the return value, the 
                            "xor bl,bl" sets it to 0 (False)} 
   cmp ax,ReturnValue   {Is PROG1 installed?} 
   jne @@Exit                 {if not skip next instruction} 
   inc bl                {set BL to true (0=False and 1=True for Boolean)} 
@@Exit: 
   mov al,bl                {return Boolean in AL} 
End; 
 
Now, in program 1, call InstallCheck when you start the program, it will
clean itself up when the program ends.  When program 2 loads, just have 
it call Installed, if it returns true then Program 1 is loaded.  Finally, 
make sure that the constants MagicValue and ReturnValue are the same in 
both programs, otherwise Program 2 will never think that Program 1 is 
installed.  (You might consider putting them in a unit to avoid confusion. 
One final note: These routines are untested, although they should work, 
I'm not perfect.  If you can't get these to work, let me know, or if you
want to know more about how they work, let me know.  Hope these help.

