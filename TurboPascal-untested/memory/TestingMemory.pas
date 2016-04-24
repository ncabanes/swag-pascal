(*
  Category: SWAG Title: MEMORY/DPMI MANAGEMENT ROUTINES
  Original name: 0041.PAS
  Description: Testing Memory
  Author: TODD HOLMES
  Date: 01-27-94  12:14
*)

{
> I have a rather irritating problem with TP:
>
> When I set my memory requirements ($M compile-time directive) to
> 16384, 0, 655360 [stack, heapmin and heapmax, respectively] I can't
> shell to DOS as there's no heap free for it [and you can't change the
> mem requirements on the fly] to do so, however, when my information
> screen displays itself, it correctly shows MemAvail. [a longint
> containing the amount of RAM free]  As I decrease heapmax, the MemAvail
> output also decreases, which is not good, especially since shelling and
> running MEM /C directly contradicts it.  If somebody can make sense of
> this mess, can you fix my problem?  Thanks a bunch...

Have you checked out the Memory Unit that comes with TP 7 (maybe 6). It has
several procs that may help you out, notable  SetMemTop() which allows you
to decrease your heap on the fly. I haven't actually played with this
commands yet, but it may be worth your while to check'em out.}

{$A-,B-,D+,E-,F-,G+,I+,L+,N-,O-,P-,Q-,R+,S+,T-,V+,X+,Y+}
{$M 16384,0,655360}

{$Tested with TP 7}

Program TestMem;

Uses Memory,Dos;

Type PStruct = ^TStruct;
     TStruct = Record
       Name: String;
       Age : Byte;
     end;

Var
   PS: PStruct;
begin
  New(PS);
  SetMemTop(HeapPtr);   {Without this, the shell fails}
  SwapVectors;
  Exec(GetEnv('Comspec'),'');
  SwapVectors;
  SetMemTop(HeapEnd);   {Restore your heap}
  Dispose(PS);
end.

