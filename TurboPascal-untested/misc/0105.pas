{
│ Now, just to bring this home, I want to make it take over the
│ debugging interrupts.  (INT 3, is it?)  I am just wondering if this
│ has been done and if anyone has some TP/TASM code already created for
│ this purpose.

in case the debugger executes an int1 or int 3, all you will get is the
message "OOPS". not really secure, but for most cases QUITE good enough.

}

Unit Nodebug;

Interface

{*************************************************}
{*                                               *}
{*  All actions will be handled by the           *}
{*  initialisation and the Exitprozedure         *}
{*  thus no exported declarations needed         *}
{*                                               *}
{*************************************************}

Implementation

Uses Dos,Crt;

Var
   Oldint1,
   Oldint3,
   Exitsave   : Pointer;

    Procedure Donotdebug; Interrupt;
    Begin
       Writeln ('OOPS??  pleeze no debuggung !!!!' );
       Writeln;
       Halt (255);
    End;

{$F+}
    Procedure Resetnodebug;
{$F-}
    Begin
       Setintvec ( 1, Oldint1 );
       Setintvec ( 3, Oldint3 );
       Exitproc  := Exitsave;
    End;

Begin
   Exitsave := Exitproc;
   Exitproc := @Resetnodebug;
   Getintvec ( 1, Oldint1 );
   Getintvec ( 3, Oldint3 );
   Setintvec ( 3, @Donotdebug );
   Setintvec ( 1, @Donotdebug );
End.


