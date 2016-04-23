{
I love it when people actually post there hard slaved code. I've
seen a number of people wanting to write tsr's, and all the examples
in BP that I've ever come across are pathetic and above 6K of mem!
So for those serious here is some flexible and easy to use code.
Drowning in comments ;-) It's extremely efficient on memory (1040)
bytes! I  can write it in pascal using 550 bytes put then I decided
to make it user friendly to a degree ;-) Shout if you need to know
more info on tsr writing eg. making it be polite to dos etc ;-))
Cheers.
Matt
}

{$A-}{$R-}{$S-}{$D-}{$F-}{$L-}{$Q-}{$T-}{$V-}{$X-}{$Y-}{$G+}
{$B-}{$N-}{$P-}
{$M 1024,0,0}
(* Ulti-Tsr-Demo-Proggie Coded: Matthew Tagg Jan '95                    *)

(* The beauty of this is that your init code, eg paramter parsing etc.  *)
(* does NOT effect the size in memory! Unlike crappy BP's attemp at a   *)
(* tsr! Another beautiful thing is that for you who hate the technical  *)
(* stuff can let the program work out what to keep in memory!           *)
(* USES *)                          (* There is no USES, so don't       *)
                                    (* use units, they suck. Use include*)
                                    (* files if you want but units      *)
                                    (* create new segments AARG         *)
                                    (* NOT for tsr's!                   *)
Const
   CharSEG  = $B800;                (* $B800 = COLOUR or $B000 for Mono *)
   DSegSize = 128;                  (* Data Segment Size                *)
   SSegSize = 256;                  (* Stack Segmetn Size               *)
   SSize    = SSegSize-16;          (* This is the value of the Stack   *)
                                    (* pointer (sp) and bp              *)
   DSegOff  = 2;                    (* This is added to the value copied*)
                                    (* from cs and written to ds ie DS  *)
                                    (* points to 32 bytes ahead of CS   *)
                                    (* I do this so that that pointers  *)
                                    (* Are not overriden                *)
   DatOffs  = DSegOff*16;           (* Offset relocation number         *)
                                    (* Use this to reference your data  *)
                                    (* ie. say you want to move the var *)
                                    (* NUM int the ax >                 *)
                                    (*   mov ax, CS:datoffs+NUM         *)
                                    (*           ^^^ Must use segment   *)
                                    (* override! OR easier to set       *)
                                    (*  DS = CS+DSegoff   default=2     *)
                                    (* When in a pascal routine you can *)
                                    (* reference it normally            *)

   CodeOffs = 16;                   (* Were OUR Code/Data starts, first *)
                                    (* 16 bytes of the int09 proc are   *)
                                    (* used for pushing stuff but we    *)
                                    (* don't need that crap!            *)

                                    (* PS Typed Constants use up memory *)
                                    (* They just another name for       *)
                                    (* initialised data.                *)
                                    (* Untyped are the same as EQU in   *)
                                    (* asm.  Untyped = No memory        *)

   PSize = 8;                       (* The amount of bytes used by the  *)
                                    (* Pointers                         *)
   NewSSegLoc = (CodeOffs+PSize+DsegSize+16) div 16;
                                    (* This says were the stack must    *)
                                    (* start (+16 so no code is over-   *)
                                    (* ridden)                          *)
Var
(* VARIABLES TO BE USED IN THE ACTUAL TSR                               *)
   Bob            : Byte;           (* Just test variables              *)
   Obo            : Word;           (* Used by the i.s.r (you can use   *)
                                    (* your own)      `                 *)

   EndData        : Word;           (* Insert all data to be saved,     *)
                                    (* ie data use in the i.s.r,        *)
                                    (* BEFORE this statement all init   *)
                                    (* data can come after  Saves Mem!  *)

(* VARIABLES TO BE USED IN THE INIT PART                                *)
   ProgSize       : Word;           (* Memory required in 16 byte       *)
                                    (* Paragraphs                       *)

   ThisDoes       : Byte;           (* Eg....                           *)
   NotGetSaved    : Char;
   ButCanBe       : Pointer;
   UsedInThe      : Longint;
   InitCode       : PChar;

   LastVar        : Word;           (* WARNING DO NOT CHANGE THIS       *)
                                    (* Do Not Insert Any Variable After *)
{$F+}
Procedure Int09; Interrupt; Assembler;
Asm
   Dw 0,0                              (* Pointers 4*2 bytes = 8     *)
   Dw 0,0
(* Data Seg (8*16=128bytes Not Bad) *) (* Bp7 Chews up the first 80  *)
   Db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0  (* bytes for whatever AAARG   *)
   Db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0  (* Change the size according  *)
   Db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0  (* to the amount of data your *)
   Db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0  (* prog uses                  *)
   Db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
   Db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
   Db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
   Db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
(* Stack Seg (8*16=128*)            (* Temp Stack                 *)
   Db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 (* You can make the stack size    *)
   Db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 (* whatever you want, but remember*)
   Db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 (* to change the const SSize,     *)
   Db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 (* Default=256                    *)
   Db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
   Db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
   Db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
   Db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
(* Stack Seg (8*16+8*16=256) *)     (* Temp Stack                       *)
   Db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
   Db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
   Db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
   Db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
   Db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
   Db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
   Db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
   Db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

   Nop                              (* Used for to ensure safety        *)
   Sti                              (* Interupts allowed                *)

   Pushf                            (* Pushf simulates and interrupt    *)
   Call Dword Ptr CS:[CodeOffs]     (* Calls the saved INT8             *)

   Inc   CS:DatOffs+Bob             (* Has a second passed? If not exit *)
   Cmp   CS:DatOffs+Bob,18          (* else call our interrupt WRT      *)
   Jne @Finnish

   Mov   Cs:DatOffs+Bob,0           (* Rests it for the next time       *)
   Inc   Cs:DatOffs+Obo             (* Obo is the number we write to the*)
                                    (* screen.                          *)
   Pushf
   Call Dword Ptr Far [CS:Codeoffs+4]; (* Call our routine              *)
   Sti
@Finnish:
   iret
End;

(* You can delete this procedure (for demo purposes only)               *)
Procedure PWord(Num,Pos,Base:Word); (* Proc. to write a number in any   *)
                                    (* base                             *)
Const
   AlphaNum : Array[0..35] of Byte =

(48,49,50,51,52,53,54,55,56,57,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,
81,82,83,84,85,86,87,88,89,90);Begin   Asm
      Push  CharSEG                 (* Set ES to our text segment addr  *)
      Pop   Es                      (* Text Graphics segment            *)
      Mov   Ax, Num                 (* Ax to be divided                 *)
   @l1:
      Xor   Dx, Dx                  (* Clear                            *)
      Div   Base                    (* Dx = Remainder, Ax = Quotient    *)
      Cmp   Dx,0                    (* Remainder                        *)
      Jnz   @l2                     (* Finnished?                       *)
      Cmp   Ax,0                    (* Quotient                         *)
      Jz    @Fin
   @l2:
      Mov   Si, Dx
      Mov   Di, Pos                 (* Load offs                        *)
      Mov   Dl, Byte Ptr [AlphaNum+Si]
      Mov   [Es:Di], Dl
      Sub   Pos,2                   (* Inc bx by 2                      *)
      Jmp   @l1
@Fin:
      Pop   Pos                     (* Maintain stack                   *)
   End;
End;

Procedure Wrt;Interrupt; (* This Is Our Interrupt Service Routine       *)
Begin
   Asm
      Mov   Ax, Cs                  (* ALWAYS include these three       *)
      Add   Ax, DSegOff             (* instructions if you want to use  *)
      Mov   Ds, Ax                  (* your pascal declared variables.  *)
   End;
   (* DO WHAT YOU WANT HERE                                             *)
   PWord(Obo,158,10);               (* Write a number in the top left   *)
                                    (* hand column, demo purposes only! *)
End;
{$F-}{ <-----------------------------
                                    |                                   }
(* Init Procedures follow, note the {$f-} means these are now local     *)
(* BTW if you make your own init procedures make sure you place them    *)
(* after the Getvec or you can place them before the getvec but then    *)
(* change the line further down that needs the name of the first init   *)
(* procedure to your own name (currently the first init proc is GetVec  *)

Procedure GetVec(VecNo :Word; Var SavPoint :Pointer); (* DOS Sucks      *)
Var
   SavSeg, SavOff :Word;            (* Temp variables for pointer       *)
Begin
   Asm
      Push  Es                      (* Save Es                          *)
      Shl   VecNo, 2                (* Multiply num by 4 to get address *)
      Mov   Es, Word Ptr 0h         (* Zero Es. Vect Int's start at 0:0 *)
      Mov   Di, VecNo               (* Di = Num * 4                     *)
      Mov   Ax, Word Ptr [Es:Di]    (* Copy offset word of int,         *)
      Mov   SavOff, Ax              (* and save it                      *)
      Add   Di, 2                   (* Point to next word (segment)     *)
      Mov   Ax, Word Ptr [Es:Di]    (* Ax = Offset                      *)
      Mov   SavSeg, Ax              (* Save in temporary variable       *)
      Pop   Es                      (* Retrieved stored value           *)
   End;
   SavPoint := Ptr(SavSeg, SavOff); (* Convert Seg:Offset to pointer    *)
End;

Procedure SetVec(VecNo :Word; NewPoint :Pointer);  (* Don't use units   *)
Type                                (* Revectors the interrupts         *)
   PType          = Array[0..1] of Word;
Var
   NtPoint        : ^PType;
Begin
   Asm Cli End;                     (* No interrupts can be generated   *)
   NtPoint := @NewPoint;            (* during the process               *)
   MemW[0:VecNo*4] := NtPoint^[0];
   MemW[0:VecNo*4+2] := NtPoint^[1];
   Asm Sti End;                     (* Enable Interrupts                *)
End;

Begin
   If (Ofs(Int09) <> 0) Then Halt;  (* Used to ensure the proc is       *)
                                    (* included                         *)
                                    (* If pascal doesn't see a reference*)
                                    (* to a proc. or var. it excludes   *)
                                    (* it!                              *)

   EndData := Ofs(EndData);         (* Basicly finds the size of the    *)
                                    (* DS to be kept in memory          *)
   GetVec($8, Pointer(MemL[Cseg:CodeOffs]));
                                    (* Vector 8 is the timer interrupt  *)
                                    (* generated every 18.2 times a sec *)
   SetVec($8, Ptr(Cseg, CodeOffs+PSize+DSegSize+SSegSize));
   (*                   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^            *)
                                    (* This is where the CODE actually  *)
                                    (* starts in the code segment       *)
   MemW[Cseg:Codeoffs+4] := Ofs( WRT );
   MemW[Cseg:Codeoffs+6] := Seg( WRt );
   (*           -----------------^^^                                    *)
   (* Substitute your own i.s.r routine name over here, if you want     *)

   (* This next stuff copies the data we defined and places it in       *)
   (* our new data segment                                              *)
   Asm
      Mov   Ax, Cs                  (* Seeing as you can't say          *)
      Add   Ax, DSegOff             (* Mov Es, Cs ..this is a way round *)
      Mov   Es, Ax                  (* Inc Ax, so no code overriden ;)  *)
      Xor   Di, Di                  (* Di = 0                           *)
      Xor   Si, Si                  (* Si = 0                           *)
      Mov   Cx, EndData             (* # of bytes to copy               *)
      Rep   Movsb                   (* ... and copy it                  *)
   End;

   (* What I am actually doing is having all three segments in the code *)
   (* segment, risky if you don't be careful but worth the space (g)    *)
   Asm
      Mov   Ax, Cs                  (* Get the current Code Seg         *)
      Add   Ax, NewSSegLoc          (* Add the New Stack Segment Locat  *)
      Mov   Ss, Ax                  (* Adjust SS                        *)
      Mov   Sp, SSize               (* The stack pointer, is SSegSize-16*)
      Mov   Bp, SSize               (*   (-16) to allow for segment     *)
                                    (* alignment.                       *)
      Push  Bp
   End;

   (* This allocates the amount of memory to be used in 16 byte         *)
   (* paragraphs. The variable progsize is the memory used by our prog. *)
   (* @GetVec is the FIRST of the init procdures so it gets that address*)
   (* and uses it as the size of our code, it adds 256 because of the   *)
   (* PSP (Program Segment Prefix) and then divides by 16 to get        *)
   (* paragraphs and adds on 1 more to to be safe.                      *)
   ProgSize := (Ofs(GetVec)+256) div 16 + 1;
   Asm                              (* Uses dos int 31.. *KEEP*         *)
      Mov   Dx, ProgSize
      Mov   Al, 0                   (* Return code ei ERRORLEVEL        *)
      Mov   Ah, 31h                 (* Dos Func 31h                     *)
      Int   21h
   End;
End.
