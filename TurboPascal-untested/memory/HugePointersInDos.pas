(*
  Category: SWAG Title: MEMORY/DPMI MANAGEMENT ROUTINES
  Original name: 0066.PAS
  Description: Huge Pointers in DOS
  Author: KARPOV SERGEY
  Date: 11-26-94  05:00
*)

{
Tel   : 7+(095) 333-9469
E-Mail: vad@glas.apc.org

>I'm wondering if anyone can tell me whether dynamic arrays have the same
>64Kbyte limit per field that static arrays do? If so can ayone suggest away
>to store data in memory that is sure to exceed this limit?

The first way is known to all serious TP programmers.
You could create large fragmental structure by control block.
Example:
}

Type
    Large =  Array [1 .. 65520] of Byte;
    PLarge = ^Large;
    Huge = Array [1 .. 16380] of Pointer; { control block }
    PHuge = ^Huge;
Var
   Hg : PHuge;
   MaxRow , MaxCol , r , c : Word;

begin
     Repeat ReadLn(MaxRow , MaxCol)
     Until (MaxCol > 0) and (MaxCol <= 65520) and
                              (MaxRow > 0) and (MaxRow <= 16380);
     GetMem(Hg , Sizeof(Pointer) * MaxRow);
     For r := 1 to MaxRow do GetMem(Hg^[r] , MaxCol);
     For r := 1 to MaxRow
     do For c := 1 to MaxCol
        do Hg^[r]^[c] := Random(255);
end.

{
This method creating huge structures is using Borland in object named
TColection.
This method has two defects.
 * You must use big control structure consists of pointers.
 * You haven't garant of unfrugmental of this structure.
This method have two advantages.
 * You can use standart pascal procedures & macros for operating with
   this structure (As Move, FillChar ets).
 * You can use standart TP heap menager for creating huge
   structure.

The second way for creating huge structure. It's my own method.
I use DOS memory menager.  I can create realy huge unfragmental
structure. It's more complicated way. I can't use standart TP
procedure & macros for operating with that structure, because
this structure greater than 64Kb. For remove huge structure I
write some procedure, function & inline macros. I used standart TP
heap menager for allocation small control structure and used
DOS memory menager for allocation huge data structure.
Example:
{$M 4096,10000,10000 <- It's very important option. Without
this option Your program should use all DOS memory for his TP
heap. You should write Your realy heap size. Use TpStack from
Turbo profesional for get this value.
}

function dosAlloc (Size : Longint) : Pointer; assembler;
asm 
   mov   ax , word ptr Size 
   mov   dx , word ptr Size[2] 
   add   ax , 000Fh 
   adc   dx , 0 
   mov   bx , 0010h 
   div   bx 
   mov   bx , ax 
   mov  ah , 48h 
   int  21h 
   jC  @@Error 
   mov  dx , ax 
   xor  ax , ax 
   jmp  @@Exit 
@@Error: 
   xor  ax , ax 
   xor  dx , dx 
@@Exit: 
end;
 
function dosFree (Var P) : Boolean; assembler; 
asm 
   les   di , P 
   mov   ax , es:[di] 
   mov   dx , es:[di][2] 
   mov   cl , 4 
   shr   ax , cl 
   add   ax , dx 
   or    ax , ax
   jZ    @@Exit 
   mov   es , ax 
   mov   ah , 49h 
   int   21h 
   jNC   @@Continue 
   mov   ax , False 
   jmp   @@Exit 
@@Continue: 
   xor    ax , ax 
   les    di , P 
   mov    es:[di] , ax 
   mov    es:[di][2] , ax 
   mov    ax , True 
@@Exit:
end; 
 
function dosResize (P : Pointer; NewSize : Longint) : Boolean; assembler; 
asm 
   mov   ax , False 
   mov   bx , word ptr P[2] 
   mov   es , bx 
   or    bx , word ptr P 
   jZ    @@Exit 
   mov   ax , word ptr NewSize 
   mov   dx , word ptr NewSize[2] 
   mov   bx , 16 
   div   bx 
   mov   bx , ax 
   or    dx , dx 
   jZ    @@Margin 
   inc   bx 
@@Margin: 
   mov  ah , 4Ah 
   int  21h 
   jC  @@Error 
   mov  ax , True 
   jmp  @@Exit 
@@Error: 
   mov  ax , False 
@@Exit: 
end; 
 
function dosAvail : Longint; assembler; 
asm 
   mov  bx , 0FFFFh
   mov  ah , 48h 
   int  21h 
   mov  ax , 16 
   mul  bx 
end; 
 
Var 
   Hg : Pointer; 
 
begin 
     Hg := dosAlloc(123456); 
end.         

{
   I don't want send more than 16Kb of my library. Because I don't test
   all procedure & function. But I can give You my idea.
   This way has one defect.
   * You should rewrite all low level memory access (As Move,
      FillChar ets.).
   This way has four advantages.
   * You can use all DOS memory functions: Allocation, Resize,
     Free (It's more powerfull that TP).
   * You recive paragraph align pointer.
   * You get unfragmental memory block.
   * You don't use big control structure.
}

