(*
  Category: SWAG Title: POINTERS, LINKING, LISTS, TREES
  Original name: 0027.PAS
  Description: Stacks
  Author: DEAVON EDWARDS
  Date: 08-25-94  09:11
*)

{
From: Deavon@sound.demon.co.uk (Deavon Edwards)

I am having some problem with this program. I would like to modified it to
do the following....
 i). To simulate the operation of a queue (Last In First Out).
 ii) To use a linked list instead of arrays(simulating a stack and queue).
If anyone out there can help it would be greatly appreciated.

 This program will simulate the operation of a stack and a queue with a
 10 items maximum. It will give the user the opportunity to insert and
 delete items from the data structures, display the data on screen,
 it on a printer, and save and load the data from a disk
}

PROGRAM StackSimulation(input, output);

USES CRT,DOS,PRINTER;

VAR
  Stack      : ARRAY [1..10] OF STRING[20];
  StackFull  : BOOLEAN;
  StackEmpty : BOOLEAN;
  Pointer    : INTEGER;
  Choice     : CHAR;

    {*******************************************************************}

PROCEDURE PressAKey;
BEGIN

  WRITELN;
  WRITELN;
  WRITELN ('                 ************************************');
  WRITELN ('                 ***   PRESS RETURN TO CONTINUE   ***');
  WRITELN ('                 ************************************');
  READLN;
  CLRSCR;
END;
    {*******************************************************************}
PROCEDURE Jump_a_Line(Jump: INTEGER);
VAR
   Skip : INTEGER;

BEGIN
   FOR Skip := 1 TO Jump DO
   WRITELN;
END;
    {*******************************************************************}

Procedure Introduction;              {Display an introduction message to user}
  BEGIN
  CLRSCR;
  gotoxy (1,10);
  Textcolor(Cyan);
  writeln('        ********************************************************');
  writeln('        ********************************************************');
  writeln('        *                                                      *');
  writeln('        *     WELCOME TO STACK & QUEUE SIMULATION PROGRAM      *');
  writeln('        *                                                      *');
  writeln('        ********************************************************');
  writeln('        ********************************************************');
  Jump_a_line(3);
  DELAY (1000);
  end;

    {*******************************************************************}

PROCEDURE Initialise (VAR StackFull, StackEmpty : BOOLEAN);

BEGIN
  CLRSCR;
  gotoxy (1,10);
  Jump_a_line(2);
  WRITELN ('        ******************************************************');
  WRITELN ('        THE STACK IS INITIALISING...........PLEASE WAIT.......');
  WRITELN ('        ******************************************************');
  Jump_a_line(3);
  SOUND (240);
  DELAY (1000);
  CLRSCR;
  NOSOUND;
  Pointer := 0;
  StackFull := FALSE;
  StackEmpty := TRUE;
END;

    {*******************************************************************}

PROCEDURE Add (VAR StackFull, StackEmpty : BOOLEAN);
BEGIN
 IF StackFull THEN
   BEGIN
     gotoxy (1,10);
     Jump_a_line(2);
     WRITELN ('************************************************************');
     WRITELN ('** SORRY, THE STACK IS FULL, NO MORE DATA CAN BE ENTERED ***');
     WRITELN ('************************************************************');
     Jump_a_line(3);
     PressAKey;
   END
 ELSE
   BEGIN
     INC (Pointer);
     Jump_a_line(3);
     WRITE ('PLEASE ENTER THE ITEM TO BE ADDED TO THE STACK :=>  ');
     READLN (Stack [Pointer]);
     CLRSCR;
     IF StackEmpty THEN StackEmpty := FALSE;
     IF Pointer = 10 THEN StackFull := TRUE;
   END;
END;

    {*******************************************************************}

PROCEDURE Take (VAR StackFull, StackEmpty : BOOLEAN);
BEGIN
  IF StackEmpty THEN
    BEGIN
      gotoxy (1,10);
      Jump_a_line(3);
      WRITELN ('    *******************************************************');
      WRITELN ('    *** THE STACK IS EMPTY, NO MORE DATA CAN BE REMOVED ***');
      WRITELN ('    *******************************************************');
      Jump_a_line(3);
      PressAKey;
    END
  ELSE
    BEGIN
      gotoxy (1,10);
      Jump_a_line(3);
      WRITE ('THE FOLLOWING ITEM HAVE BEEN REMOVE FROM THE STACK :=>  ');
      WRITELN (Stack [Pointer]);
      DEC (Pointer);
      IF Pointer = 0 THEN StackEmpty := TRUE;
      IF StackFull THEN StackFull := FALSE;
      Jump_a_line(3);
      PressAKey;
    END;
END;

    {*******************************************************************}

PROCEDURE Display_to_Screen (StackEmpty : BOOLEAN);
VAR
  Counter : INTEGER;
BEGIN
  CLRSCR;
  GOTOXY (1,10);
  IF StackEmpty THEN
    WRITELN ('                      THE STACK IS CURRENTLY EMPTY ');
    Jump_a_Line (3);
  FOR Counter := 1 TO Pointer DO
  WRITELN (Counter:2 ,'     ', Stack [Counter]);
  Jump_a_Line(2);
  PressAKey;
END;

    {*******************************************************************}
PROCEDURE Print_to_Printer (StackEmpty : BOOLEAN);
VAR
  Counter : INTEGER;
BEGIN
  CLRSCR;
  GOTOXY (1,10);
  {$I-}
  WRITELN (lst,#0);
  IF IORESULT <> 0 THEN
  WRITELN ('       >>>>>>   PRINTING ERROR.......PRINTER OFF LINE   <<<<<<  ')
  ELSE
   BEGIN
    IF StackEmpty THEN
    WRITELN ('THE STACK IS CURRENTLY EMPTY, THERE IS NO DATA TO BE PRINTED.')
    ELSE
    WRITELN (' THE CONTENTS OF THE STACK IS PRINTING........');
    FOR Counter := Pointer DOWNTO 1 DO
    WRITELN (Lst,Counter:2 ,'     ', Stack [Counter]);
   END;
   {$I+}
   PressAKey;
END;


      {****************************************************}

PROCEDURE Save_to_File;

VAR
    Write_to_File       : TEXT;
    Output_to_File      : STRING[20];
    Read_File           : BOOLEAN;
    Counter             : INTEGER;

BEGIN
  CLRSCR;
  Jump_a_Line(3);
  WRITE('PLEASE ENTER THE NAME YOU WISH TO CALLED THE FILE :=> ');
  READLN(Output_to_File);
  ASSIGN(Write_to_File,Output_to_File);
  REWRITE(Write_to_File);
  FOR Counter := 1 TO Pointer DO
    BEGIN
      Writeln(Write_to_File,Stack[Counter]);
      Writeln('SAVING... ',Counter:2,' ... ',Stack[Counter]);
    END;
    CLOSE(Write_to_File);
    PressAKey;
End;

                {**************************************************}

PROCEDURE Open_A_File (StackEmpty : BOOLEAN);

VAR
    Read_File       : TEXT;
    Input_to_File   : STRING[20];

 BEGIN
   CLRSCR;
   Jump_a_Line(3);
   WRITE ('PLEASE ENTER THE NAME OF THE FILE YOU WHICH TO OPENED :=> ');
   READLN(Input_to_File);
   ASSIGN(Read_File,Input_to_File);
   {$I-}
   RESET(Read_File);
   IF IOResult = 0 THEN
    BEGIN
     Jump_a_Line(2);
     Pointer := 0;
     WHILE NOT EOF(Read_File) DO
       BEGIN
         INC (Pointer);
         READLN(Read_File,Stack [Pointer]);
         WRITELN(Pointer:2,' : ',Stack[Pointer]);
       END;
       CLOSE(Read_File);
       StackEmpty := FALSE;
       END
       ELSE
       CLRSCR;
       Jump_a_Line(2);
       WRITELN ('                 ***********************************');
       WRITELN ('                 ***   FILE NAME DOES NOT EXIT   ***');
       WRITELN ('                 ***********************************');
       {$I+}
       PressAKey;
END;

               {****************************************************}

PROCEDURE Menu;

 BEGIN
    gotoxy (1,10);
    Textcolor(White);
    WRITELN ('           **************************************************');
    WRITELN ('           **************************************************');
    WRITELN ('           ****       A : Add to Stack                  *****');
    WRITELN ('           ****       T : Take from Stack               *****');
    WRITELN ('           ****       D : Display Stack List to Screen  *****');
    WRITELN ('           ****       P : Print Stack List              *****');
    WRITELN ('           ****       I : Initialise Stack List         *****');
    WRITELN ('           ****       S : Save Stack to disk            *****');
    WRITELN ('           ****       L : Load Stack from disk          *****');
    WRITELN ('           ****       Q : Quit program                  *****');
    WRITELN ('           **************************************************');
    WRITELN ('           **************************************************');
    WRITELN;
    WRITELN;
    WRITELN ('           PLEASE ENTER AN OPTION >> ');
    Choice := READKEY;

 END;

PROCEDURE QuitProgram;

BEGIN
  gotoxy (1,10);
  WRITELN ('                  ***********************************');
  WRITELN ('                  """""""""""""""""""""""""""""""""""');
  WRITELN ('                  [[[[[      GOODBYE!!!!!!     ]]]]] ');
  WRITELN ('                  """""""""""""""""""""""""""""""""""');
  WRITELN ('                  ***********************************');
  WRITELN;
  WRITELN;
END;

    {*******************************************************************}
    {*******************************************************************}

BEGIN
   Introduction;
   Initialise (StackFull, StackEmpty);
  REPEAT
    Menu;
    CLRSCR;
    CASE Choice OF
     'A', 'a' : Add (StackFull, StackEmpty);
     'T', 't' : Take (StackFull, StackEmpty);
     'D', 'd' : Display_to_Screen (StackEmpty);
     'P', 'p' : Print_to_Printer (StackEmpty);
     'I', 'i' : Initialise (StackFull, StackEmpty);
     'S', 's' : Save_to_File;
     'L', 'l' : Open_a_File(StackEmpty);
     'Q', 'q' : QuitProgram
    ELSE
      BEGIN
        gotoxy (1,10);
        WRITELN ('                       **************************');
        WRITELN ('                       **  Invalid key pressed **');
        WRITELN ('                       **************************');
        WRITELN;
        PressAKey;
      END;
    END;
  UNTIL (Choice = 'Q') OR (Choice = 'q');
END.

