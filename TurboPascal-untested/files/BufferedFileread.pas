(*
  Category: SWAG Title: FILE HANDLING ROUTINES
  Original name: 0054.PAS
  Description: Buffered Fileread
  Author: MARTIN ISREALSEN
  Date: 05-26-94  06:11
*)


(************************************************************************)
(*                                                                      *)
(*  Program ex. to      : "Tips & Tricks in Turbo Pascal", SysTime 1993 *)
(*                                                                      *)
(*  By                  : Martin Israelsen                              *)
(*                                                                      *)
(*  Title               : BUFFER.PAS                                    *)
(*                                                                      *)
(*  Chapter             : 5                                             *)
(*                                                                      *)
(*  Description         : Quicker than Turbo fileread                   *)
(*                                                                      *)
(************************************************************************)
(*$I-*)  (* Iocheck off         *)
(*$F+*)  (* Force FAR call      *)
(*$V-*)  (* Relaxed VAR check   *)
(*$R-*)  (* Range check off     *)
(*$S-*)  (* Stack check off     *)
(*$Q-*)  (* Overflow off        *)
(*$D-*)  (* Debug off           *)
(*$L-*)  (* Linenumber off      *)

Unit
  Buffer;

Interface

Type

  PByte     = ^Byte;
  PWord     = ^Word;
  PLong     = ^Longint;

  PByteArr  = ^TByteArr;
  TByteArr  = Array[1..64000] Of Byte;
  PfStr     = String[100];

  PBuffer       = ^TBuffer;
  TBuffer       = Record
                     BufFil   : File;
                     BufPtr   : PByteArr;

                     BufSize,
                     BufIndex,
                     BufUsed  : Word;

                     BufFPos,
                     BufFSize : Longint;
                  End;

Function  BufferInit(Var Br: PBuffer; MemSize: Word;
                      FilName: PfStr): Boolean;
Procedure BufferClose(Var Br: PBuffer);

Function  BufferGetByte(Br: PBuffer): Byte;
Function  BufferGetByteAsm(Br: PBuffer): Byte;

Function  BufferGetWord(Br: PBuffer): Word;
Procedure BufferGetBlock(Br: PBuffer; Var ToAdr; BlockSize: Word);
Function  BufferGetStringAsm(Br: PBuffer): String;

Function  BufferEof(Br: PBuffer): Boolean;

Implementation

(*$I-,F+*)

Function BufferInit(Var Br: PBuffer; MemSize: Word;
                    FilName: PfStr): Boolean;
Begin
   BufferInit:=False;

   (* Check if there's enough memory               *)

   If MemSize<500 Then Exit;
   If MaxAvail<Sizeof(TBuffer)+MemSize+32 Then Exit;

   New(Br);

   With BR^ Do
   Begin
      BufSize:=MemSize; BufIndex:=1; BufFPos:=0;

      (* Open the filen. Exit if there's an error *)

      Assign(BufFil,Filname); Reset(BufFil,1);

      If IoResult<>0 Then
      Begin
         Dispose(Br);
         Exit;
      End;

      (* Ok, the file is there, and there's enough *)
      (* memory. So allocate the memory and read   *)
      (* as much as possible                       *)

      GetMem(BufPtr,BufSize);
      BlockRead(BufFil,BufPtr^,BufSize,BufUsed);

      BufFSize:=FileSize(BufFil); Inc(BufFPos,BufUsed);
   End;

   BufferInit:=True;
End;

Procedure BufferClose(Var Br: PBuffer);
Begin
   With Br^ Do
   Begin
      Close(BufFil);
      Freemem(BufPtr,BufSize);
   End;

   Dispose(Br);
End;

Procedure BufferCheck(Br: PBuffer; ReqBytes: Word);
Var
   W,Rest: Word;
Begin
   With Br^ Do
   Begin
      If (BufIndex+ReqBytes>BufUsed) And (BufUsed=BufSize) Then
      Begin
         Rest:=Succ(BufSize-BufIndex);

         Move(BufPtr^[BufIndex],BufPtr^[1],Rest);
         BufIndex:=1;

         BlockRead(BufFil,BufPtr^[Succ(Rest)],BufSize-Rest,W);
         BufUsed:=Rest+W; Inc(BufFPos,W);
      End;
   End;
End;

Function BufferGetByte(Br: PBuffer): Byte;
Begin
   With Br^ Do
   Begin
      BufferCheck(Br,1);

      BufferGetByte:=BufPtr^[BufIndex];
      Inc(BufIndex);
   End;
End;

Function BufferGetByteAsm(Br: PBuffer): Byte; Assembler;
Asm
   Les   Di,Br                              (* ES:DI ->  BRecPtr         *)

   Mov   Ax,Es:[Di.TBuffer.BufIndex]        (* Check wheather the buffer should be updated *)
   Cmp   Ax,Es:[Di.TBuffer.BufUsed]
   Jle   @@NoBufCheck                       (* If not jump on            *)

   Push  Word Ptr Br[2]                     (* Push BR to BufferCheck   *)
   Push  Word Ptr Br
   Mov   Ax,0001                            (* Check for one byte           *)
   Push  Ax                                 (* Push it                      *)
   Push  CS                                 (* Push CS, and make a          *)
   Call  Near Ptr BufferCheck               (* NEAR call - it's quicker     *)

   Les   Di,Br                              (* ES:DI-> BRecPtr              *)

 @@NoBufCheck:

   Mov   Bx,Es:[Di.TBuffer.BufIndex]        (* BufferIndex in BX            *)
   Inc   Es:[Di.TBuffer.BufIndex]           (* Inc BufferIndex directly     *)
   Les   Di,Es:[Di.TBuffer.BufPtr]          (* ES:DI -> BufPtr              *)

   Xor   Ax,Ax                              (* Now get the byte             *)
   Mov   Al,Byte Ptr Es:[Di+Bx-1]
End;

Function BufferGetWord(Br: PBuffer): Word;
Begin
   With Br^ Do
   Begin
      BufferCheck(Br,2);

      BufferGetWord:=PWord(@BufPtr^[BufIndex])^;
      Inc(BufIndex,2);
   End;
End;

Procedure BufferGetBlock(Br: PBuffer; Var ToAdr; BlockSize: Word);
Begin
   With Br^ Do
   Begin
      BufferCheck(Br,BlockSize);

      Move(BufPtr^[BufIndex],ToAdr,BlockSize);
      Inc(BufIndex,BlockSize);
   End;
End;

Function BufferGetStringAsm(Br: PBuffer): String; Assembler;
Asm
   Push   Ds

   Les    Di,Br                        (* es:di -> Br *)
   Mov    Bx,Es:[Di.TBuffer.BufUsed]   (* check for buffercheck *)
   Sub    Bx,Es:[Di.TBuffer.BufIndex]
   Cmp    Bx,257
   Jae    @NoBufCheck                  (* Jump on if not        *)

   Push   Word Ptr Br[2]
   Push   Word Ptr Br

   Mov    Ax,257
   Push   Ax

   Push   Cs
   Call   Near Ptr BufferCheck

   Les    Di,Br

 @NoBufCheck:

   Mov    Bx,Es:[Di.TBuffer.BufIndex]  (* Get index in buffer     *)
   Dec    Bx                           (* Adjust for 0            *)

   Les    Di,Es:[Di.TBuffer.BufPtr]    (* Point to the buffer     *)
   Add    Di,Bx                        (* Add Index               *)
   Push   Di                           (* Save currect position   *)

   Mov    Al,$0a                       (* Search for CR = 0ah     *)
   Mov    Cx,$ff                       (* max. 255 chars          *)

   Cld                                 (* Remember                *)
   RepNz  Scasb                        (* and do the search       *)
   Jz     @Fundet                      (* Jump if we found one    *)

   Mov    Cx,0                         (* Otherwise set length to 0  *)
 @Fundet:
   Sub    Cx,$ff                       (* Which will be recalculated *)
   Neg    Cx                           (* to nomal length            *)
   Dec    Cx                           (* Dec, to avoid CR           *)

   Push   Es                           (* DS:SI->Buffer              *)
   Pop    Ds
   Pop    Si

   Les    Di,@Result                   (* ES:DI->result string        *)
   Mov    Ax,Cx

   Stosb                               (* Set length                  *)

   Shr    Cx,1                         (* Copy the string             *)
   Rep    MovSw
   Adc    Cx,Cx
   Rep    MovSb

   Pop    Ds                           (* Restore DS                  *)

   Les    Di,Br                        (* ES:DI->Br                   *)
   Inc    Ax                           (* Inc Ax, point to LF         *)

   Add    Es:[Di.TBuffer.BufIndex],Ax  (* and set BufferIndex         *)
End;


Function BufferEof(Br: PBuffer): Boolean;
Begin
   With Br^ Do
   BufferEof:=(BufIndex>BufUsed) And (BufFPos=BufFSize);
End;

End.


