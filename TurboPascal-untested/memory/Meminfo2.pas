(*
  Category: SWAG Title: MEMORY/DPMI MANAGEMENT ROUTINES
  Original name: 0011.PAS
  Description: MEMINFO2.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:50
*)


 I need the proper syntax For a Pascal Program that will execute a Dos
 prog (a small one) and then resume the Pascal Program when the Dos prog
 is finished.  Any suggestions gladly accepted...

   TP method:

   Assumes Programe name is \PROGPATH\PROGNAME.EXE, and the command
   line parameters are /R

   Exec('\PROGPATH\PROGNAME.EXE','/R');

   You need to make sure that you have the Heap set With the $M
   directives, so that you have enough memory to execute the
   porgram.

   example (this Program doesn't use the heap at all):

   {$M 1024, 0, 0} { 1 kb stack, 0k min, 0k max }

   (this Program needs 20k minimum heap to run, and can use up to
   100k)

   {$M 1024, 20480, 102400}  { 1k stack, 20k min, 100k max }

   A Turbo Pascal Program will always use as much RAM as there is
   avaiable, up to the "max" limit. if you do not put a $M directive
   in your Program, the heap will be the entire available memory of
   your machine, so no memory will be available For your external
   Program to run.

   It is also a good idea to bracket your Exec command with
   "SwapVector;" statements.

