(*
  Category: SWAG Title: FREQUENTLY ASKED QUESTIONS/TUTORIALS
  Original name: 0021.PAS
  Description: Reading Array from REGS
  Author: MARK OUELLET
  Date: 11-02-93  06:12
*)

{
MARK OUELLET

>  How  can  I  read what appears to be an Array from the Registers value
>  (this is after  making  the  interrupt  call,  and  is  returned  With
>  information...   I'll   be   durned   if   I  know  how  to  use  it):

> values upon return
> AX    = clear on successful (or whatever ... not important)
> ES:DX = see table 2.1
>
> table 2.1
> offset - info (size)
> -----------------------------
> 00h    - blah blah (4 Bytes)
> 03h    - blah blah (16 Bytes)
> etc ....
>
> And the ES:DX usually points to what appears to be a Record, or a buffer
> of data using an offset to identify what's what.  How can I use and/or
> access this info?
}

 Type
    TablePtr = ^Table
    Table = Record
      BlahBlah1 : LongInt; { 4Bytes }
      BlahBlah2 : Array[1..16] of Byte;
      .
      .
      etc....
    end;
{
    if using Intr() or MSDos() and the Registers  structure  defined  in
Dos.tpu then:
}
Var
  Regs    : Registers;   {Defined in Dos.tpu}
  MyTable : TablePtr;

begin
  Regs.AX := ??;
  Regs.BX := ??;
  Intr(Regs);
  TablePtr := Ptr(Regs.ES, Regs.DX);

  Write(TablePtr^.BlahBlah1);
  .
  .
  etc...



