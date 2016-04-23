
The non-general use registers, What are they for?

***********************************************************************
*GENERAL REGISTERS *register*               definition                *
*                  *   AX   *  accumulator                   (16 bit) *
*                  *   AH   *  accumulator high-order byte   ( 8 bit) *
*                  *   AL   *  accumulator low order byte    ( 8 bit) *
*                  *   BX   *  base                          (16 bit) *
*                  *   BH   *  base high-order byte          ( 8 bit) *
*                  *   BL   *  base low-order byte           ( 8 bit) *
*                  *   CX   *  count                         (16 bit) *
*                  *   CH   *  count high order byte         ( 8 bit) *
*                  *   CL   *  count low order byte          ( 8 bit) *
*                  *   DX   *  data                          (16 bit) *
*                  *   DH   *  date high order byte          ( 8 bit) *
*                  *   DL   *  data low order byte           ( 8 bit) *
***********************************************************************
*SEGMENT REGISTERS *register*               definition                *
*                  *   CS   *  code  segment (16 bit)                 *
*                  *   DS   *  data  segment (16 bit)                 *
*                  *   SS   *  stack segment (16 bit)                 *
*                  *   ES   *  extra segment (16 bit)                 *
***********************************************************************
*INDEX REGISTERS   *register*               definition                *
*                  *   DI   *  destination index (16 bit)             *
*                  *   SI   *  source      index (16 bit)             *
***********************************************************************
*POINTERS          *register*               definition                *
*                  *   SP   *  stack       pointer (16 bit)           *
*                  *   BP   *  base        pointer (16 bit)           *
*                  *   IP   *  instruction pointer (16 bit)           *
***********************************************************************
*FLAGS               AF, CF, DF, IF, OF, PF, SF, TF, ZF               *
 
     Once again here is the list of registers [and flags] on you 80xxx
     processor. As was said before registers AX-DX are general use;
     however they do have some other special uses. In part II we saw
     that CX is known as the counting register because in is can be
     automatically inc/dec durring a loop. It can also be used to
     repeat a single type of machine instruction. [scambling for Doc]
     The "prefix" and the instructions are as follows:
 
     Prefix = REP
 
     Instructions = Movs,Lods,Stos,Ins, or outs
 
     We already know that Mov is used to move a value to a register or
     a register value some address, but what's a (lod,sto,ins,out)?
     That's were are other registers come into play.
 
     In order to do operation like in pascal, you must use to special
     pointers to get information that is far away from the current
     code being executed. These pointers can be thought of as [es:di],
     and [ds:si]. I like to label them as

     [es:di] -> put
     [ds:si] -> get
 
     These two are used to get or put the value that they point to.
     Notice that DS is called the data segment register, and it is
     used to "get" values from where DS points. To get back to pascal,
     lets use some examples.
 
     var x : array[1..22] of byte;
     [...]
     fillchar(X,32,#0); {I may have this in reverse}
 
     This procedure takes the address of X and fills is with 32 zero
     values.
     now...
     asm
       push es
       push di
 
       mov ax,seg X
       mov es,ax
       mov di,offset X
 
       mov cx,32d  {number of times to repeat}
       mov ax,0    {the "char" we want to move}
 
       REP         {tells the processor to repeat the next repeatable}
                   {instruction CX times                             }
           stosB   {store whats in AX to [es:di] and increment di}
 
       pop di
       pop es
     end;
 
     There's alot of extra stuff there and you may want to know why.
     The non-general use registers are used by pascal and they
     _must_ remain the same value in order for pascal to run correctly.
     That's why we push and pop
 
     what's push & pop? If you know, skip the next paragraph.
     Push and pop "Push" and "pop" values onto the stack. The stack is
     part of the operation system and it is used by most calling programs.
     Misuse of the stack can cause you program to crash the computer.
     Think of the stack as like a deck of cards. IF you put a Jack, then
     and Ace, and then a King in a pile you have just pushed Jack,Ace, and
     King. Know when you pick up the cards you "pop" King,Ace,Jack. This
     is known as a "last in first out" way of storage, and any storage
     using the scheme can be called a stack. A stack must always take
     the last value first and it can't jump around. What you put into
     the stack always comes out in reverse order. That's why when I
     push ES and DI, I must Pop Di then ES. The stack is a quick way
     of storing and retrieving values.
 
     Next, whats that "Seg" and "offset"?
     These are Key words that tell the compiler to substitute at that
     position the absolute address of the Variable refrenced. It's kinda
     like pascal's Addr(variable) procedure. In order for you to access
     variables that aren't part of a procedure call, its best to use
     this method. Remeber that ES:DI must point to the variable you
     are wanting to change in the code about - so you must tell the
     compiler - "I want you to give the location of this variable, and
     not the variables value" using the segment and offset key words.
 
     Why didn't you move the segment of array X dirrectly to DS?
     Answer, you can't. You can move the value of a register to a
     segment register, but you can't move immediate values.
     Illegal
        mov DS,938d
        mov DS,seg X
        mov CS,832d
        mov ES,21h
     Legal
        mov ax,938d
        mov ds,ax
        mov ax,seg X
        mov ds,ax
     or also legal
        push 938d
        pop  DS
        push seg X
        pop  DS

Tpas -> asmb
part III      [2 of 2]

This section may have a bit too much information for now. If you don't
quite get all of it, don't worry! Most of this section will be repeated
and explain in greater detail in the next upcomming sections.


var x : array[1..22] of byte;
 
[...]
 
asm
 push es
 push di
 
 mov ax,seg X
 mov es,ax
 mov di,offset X
 
 mov cx,32d  {number of times to repeat}
 mov ax,0    {the "char" we want to move}
 
 REP         {tells the processor to repeat the next repeatable}
             {instruction CX times                             }
    stosB   {store whats in AX to [es:di] and increment di}
 
 pop di
 pop es
end;
 
  Starting from the top, we know that we should push the original
  values of registers that aren't general use [non AX-DX]. Next,
  we know that we are telling the compiler to give us the address
  that X is located at and not to give us the value of X. Segment
  registers can only be assinged values by a Register or a Pop.
 
  That bring us to CX gets the number of times we want to REPeat,
  and AX get the value we want to move to X. We are know at the
  meaty instruction and that is STOSB. STOSB does a lot at once.
 
  First,  it moves the byte located in AL to [es:di].
  Second, it increments DI so it points to the next byte of X.
  Third,  CX is decremented
  fourth, if CX in not Zero then the process is repeated
 
  When you have a simple loop like
  " for I := 1 to 32 do x[i] := 0; ";
  then, the above is a _really_quick_ way to do the same thing.
  Unlike in Part II, this loop is not as general, and cant as
  easily be used to do many things durring a loop. The REP only
  works for certain instruction and can only repeat that instruction
  CX times.
 
  "OK, now what's LOD,INS,OUT ?"
  First off, the STOS can be use two other ways. There is a STOSW
  that moves a word at a time [AX] and advances DI two bytes. The
  other one is STOS and truthfully, I haven't and don't know how
  to use it yet.
 
  LODS is kinda the oposite of STOS. IF stosB, it moves the byte at
  DS:SI into AL, and if stosW, it moves the word at DS:SI into AX.
 
  !Unless you know your hardware ports, skip INS and OUT for now.!
  ]INS is not part of the 8088 and 8086 processor and won't execute.
  ]IT takes a byte or word [insB, insW] from the port listed in DX
  ]and moves it the addess located in [ES:ID].
  ]
  ]OUT takes a byte or word and moves it to a port. It can be done
  ]as follows
  ]
  ]OUT 13h,AL  {moves byte in AL to port 13h}
  ]OUT 13h,AX  {moves word in AX to port 13h}
  ]OUT DX,al   {move byte in al to port listed DX}
  ]out DX,ax   {move word in ax to port listed DX}
  ]
  ]outs, outsB,outsW are not part of the 8088 and 8086 instruction
  ]outsB moves byte [ds:si] to port listed in DX and advances SI
  ]outsW moves word [ds:si] to port listed in DX and advances SI
  ]I've not used OUTS & don't yet know how.
 
 
  That brings us back to the rest of the special use registers,
  And they are
     CS   *  code  segment (16 bit)                 *
     SS   *  stack segment (16 bit)                 *.
 
  My best advice is DON'T TOUCH! Your processor uses pointers
  just like you so it knows what to execute next and where the
  top of the stack is. CS:IP points the next instuction to execute
  and SS:SP points to the top of the stack.
  CS:IP are changed by jumps and calls.
  SS:SP are changed by pushes and pops
 
  -------------------------------------------------------------
  I screwed up a little bit in order so I need to rectify this
  now.
 
  I need to define immediate values, effective addresses, and so forth.
 
  mov ax,983d
  An immediate value is a byte or word that is part of the instruction.
  In the example above, 938d is the immediate value that is going to
  be moved into ax.
  "mov ax,bx" has no immediate values. The value is stored in BX and
  the word associated is not part of the instruction.
 
 
  mov ax,[0000]
  An effective address can be a word value that is part of the instuction
  but is a location and an immediate value. When this is compiled
  0000 is not moved into ax, the word pointed to by cs:[0000] is moved
  into ax. Why CS? If you don't overide the segment the compiler used
  defaults. Unfortunatly I don't readily know which are which, but
  seeing that you might be a beginner, this won't be a problem that
  has to be delt with know. In other word ignore for now.
 
  mov ax,[bx]
  This has [bx] as the effective address. The value in BX is thought
  of as an address and the word pointed to by BX is moved into ax.
 
  There are several addressing modes and I will try to explain them as
  I get to them and as they are needed.
 
 
  _I HIGHLY suggest that we start out with assembler procedure and
  functions in Pascal and leave it at that_! I think that asm should
  be used only for critical procedures that are too slow in pascal
  or are things not supported by native pascal. This way you code can
  be effiecient and still easily understandable.
 
  Next section Part IV - assembler functions and procedures in pascal.

tpas -> asmb
part IV - assembler functions and procedures in pascal.
     [1 of 2]
 
     Now that we know just a little bit, let learn through example.
     Translation from tpas to asm is not an exact science. There
     are several way to do about the same structure as pascal and
     it is this reason that ASM procedures can be so efficient. You
     can completetly eliminate the legnthy and general machine code
     that pascal produces when things like overflow,range checking,
     and so forth, are not as important as speeding things up.
 
     For the first example, we are going to write a procedure in
     Tpascal that clears the screen in mode $13. We will assume
     that we are already in mode $13.
 
     mov ax,13h
     int 10h    {bios call}
 
 
 
     procedure ClearScrn13;
     var i,j : word;
     begin
       for I := 0 to 199 do
           For J := 0 to 319 do
                 mem[$a000:(i*320) + j] := 0;
 
     end;
 
 
     First off, I assume you know that in ram at $a000:0000 is
     were the vga screen memory is stored. I can be thought of
     as an array of 64,000 bytes, and you must do the Row_Major
     math to access it by Row and Column.
     For every row there are 320 bytes, in order to access [2,2]
     of a [320,200] array we must pass up 320 bytes in the first row
     and and 1 more byte to get to [2,2].
 
     In this case, who cares about rows and colums. We know the
     size of the 1 dimesional array so when can just loop 64000 times.
     This keeps us from having to do any math - which will slow every-
     thing down.
 
     procedure clearScrn13asm;
     begin
     asm
       push es  {remeber to store the values of non-general}
       push di
 
       mov ax,0a000h
       mov es,ax      {es := $a000}
       xor di,di      {di := 0}
 
       mov cx,32000d   {cx := 64000 div 2;}
       xor ax,ax      {ax := 0;}
 
       rep stosW
 
       pop di
       pop es
     end;
     end;
 
     I know, you saying "what the f..?". Remember first we point our
     "put" pointer [es:di] to where we are going to store stuff. So what
     is "xor di,di"? "Xor" or is "exclusive or". It means either A or B
     but not A and B. The truth table is as follows
 
     true  xor false = true
     false xor true  = true
     false xor false = false
     true  xor true  = false
 
     in bits
     1 xor 0 = 1
     0 xor 1 = 1
     0 xor 0 = 0
     1 xor 1 = 0
 
     So any number xor'd it self is zero. For example, 48 decimal is 30
     hexidecimal. In binary 30 is 00110000. Now if you xor each
     individual bit by using the table above you get
 
     0 0 1 1 0 0 0 0   |
 xor 0 0 1 1 0 0 0 0   |
 -------------------   v
   = 0 0 0 0 0 0 0 0
 
     For each column use the table. From left to right 0 xor 0 is 0,
     0 xor 0 is 0, 1 xor 1 is 0 and so forth.
 
     "Why not mov di,0 ? or mov ax,0 ?"
     Code size. Mov di,0 will produce 3 bytes of code and "xor di,di"
     should produce 1 byte of code. For more information, get the
     opcode list from "ftp.intel.com". It list all possible and valid
     instructions.
 
 
     "Why is is mov cx,32000 and not mov cx,64000?"
     Well If you look at the repeated instruction, is will move
     a word at a time, and a word is two bytes. So moving 32000
     words is the same as moving 64000 bytes but just much
     quicker.
 
     Remeber the "REP stosW" will automatically mov ax to es:di
     and increment di and decrement cx until repeated 32000 times.
 
 
     Know lets use an example that won't let us use the repeat prefix.
     Lets mov a virtual screen to the physical screen.
 
     type V_scrn : array[0..319,0..199] of byte;
     var V_P : ^V_scrn;
 
     procedure Paste_scrn( P : V_P );
     var i,j : word;
     begin
       for I := 0 to 199 do
           For J := 0 to 319 do
                 mem[$a000:(i*320) + j] := V^[j,i];; {or ist ^V[j,i]?}
     end;
 
part IV - assembler functions and procedures in pascal.
      [2 of 2]
 
procedure Paste_scrnASM( P : V_P );
     begin
     asm
        push es
        push di
        push ds
        push si
 
        {: Setup or Get and Put pointers :}
 
        {get}
        mov ax,word ptr P[2]  {ds:si -> V_screen }
        mov ds,ax
        mov si,word ptr P
 
        {put}
        mov ax,0a000h         {es:di -> screen}
        mov es,ax
        xor di,di
 
        mov cx,32000d         { for I := 1 to 32000 do begin }
     @looper:
        lodsW                 {  ax  := -> get } { inc si }
        stosW                 {  put := ax     } { inc di }
        loop @looper          { end;           } { dec CX }
 
        pop si
        pop ds
        pop di
        pop es
     end;
     end;
 
 
     OK lets start with "P[2]" a Pointer type is 4 bytes in legnth.
     The first 2 bytes are the offset that it points to and the
     second 2 bytes are the segment that it point to.
     The "[]" symbols also mean indexing - much like an 1 dimensional
     array in pascal. Seeing that the Segment is 2 bytes passed the
     begining of the pointer, we tell th copmiler that we are talking
     about the word 2 bytes passed the begining of the 4 byte pointer.
 
     "word ptr?"
     If we didn't tell the copmiler that we want that this is a word
     and it an effective address and not a varialbe, we'd have a
     problem. We can't use the Offset and Seg key words; becuase, we
     we want the value of the of the pointer and not its location.
 
 
 
     Pascal takes all the parameters of the procedure and
     pushes them on the stack write before a call to the procedure.
     In a procedure when you use one of those variables you are actually
     using a values that is on the stack. When you use the "VAR" keyword
     is pushes the address of the variable on the stack, and therefore
     any changes made to that variable are actually chaning the value
     of the original variable. Otherwise, is just pushes the value of
     the variable on the stack and any changes to that value are made
     only in the stack and are thrown away after completion.
 
     example
 
     Procedure test(VAR X : byte; Y,Z : byte);
     begin
     end;
 
 
 
     a:= 1;
     b:= 2;
     c:= 3;
 
     When you call test(a,b,c);
 
     It pushed all the paramters starting backwards with C
 
     STACK
     SP ->   [ addr(A) ]   a
             [    2    ]   b
             [    3    ]   c
 
     to move C's value into AX you could say
        mov ax,word ptr Z
     to move B's value into AX you could say
        mov ax,word ptr Y
     to move A's value into AX you could say
        mov ax,word ptr X[2]
        mov ds,ax
        mov si,word ptr X     {[ds:si] -> A}
        lodsB                 {ax := [ds:si] }
 
     because the value of A is not on the stack, but A's address is.
 
 
     !Back to the code!
 
     Next es:di points to the vga memory in ram.
 
     This...
 
       mov cx,32000d         { for I := 1 to 32000 do begin }
     @looper:
        lodsW                 {  ax  := -> get } { inc si }
        stosW                 {  put := ax     } { inc di }
        loop @looper          { end;           } { dec CX }
 
     sets up our loop counter CX
     lodsW gets from out virtual screen the first word and increments si 2
     bytes [word size in bytes]
     AX holds the word
 
     stosW takes the word in AX and puts it to the screen and increments
     di 2 bytes.
 
     Loop decrements CX and compares it to zero, if its not equal to zero
     it jumps to @Looper [this changes the values of CS:IP].
 
     You get all that done with just a tinty bit of speedy code.
 
 
 
     I didn't get to functions this time, but in part V I'll get to functions
     and how to acccess pascal variables like a string.
 
 
     As always, I'll be glad to answer any questions. Just one warning,_all
     the code in these section have _NOT_ been compiled and are sure to have
     errors. If you find these errors then maybe these lessons are too simple
     for you and you may be ready to start learning from an intermediate to
     advanced asm book. However, I'll try to be as unassuming as possible,
     but if I loose you on some concept, just mail me.
 
     Later
     **%CpC%**
