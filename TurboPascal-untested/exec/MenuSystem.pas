(*
  Category: SWAG Title: EXECUTION ROUTINES
  Original name: 0025.PAS
  Description: Menu System
  Author: MIKE PERRY
  Date: 08-24-94  13:47
*)

{
 GG> Could somebody post a message with the Pascal 6.0 source for some
 GG> sort of a scrolling menu system?  I do NOT want TurboVision.  I
 GG> HATE OOP.  I don't mind records and arrays, but i don't want OOP.
 GG> I've done some programming for one myself....
}

UNIT MPMENU;
{
 Written and designed by Michael Perry, (c) 1990 Progressive Computer Serv.

 A basic, flexible, user-definable menu system using only the most basic
 functions in Turbo Pascal.  This unit is easily integratable into your
 applications and gives you more versatility than most "pull down"-type
 menu interfaces.

 License:  This unit should NOT be modified and redistributed in source
           or object/TPU form.  You can modify and use this in any non-
           commercial program free-of-charge provided that "Mike Perry"
           if credited either in the program or documentation.  Use of
           these routines in a commercially-sold package requires a
           one-time registration fee of $30 to be sent to:

             Progressive Computer Services
             P.O. Box 7638
             Metairie, LA 70010

           Non-commercial users are also invited to register the code.
           This insures that updates and future revisions are made
           available and users are kept informed via mail.


 Usage:    Implementing menus using the MPMENU unit involves just a
           few basic steps.  At any point in your program, add code
           to perform the following actions:

              1.  Define the menu by assigning values to the MENU_DATA
                  record.
              2.  Call the procedure MENU(MENU_DATA,RETURNCODE);
              3.  Implement a routine to evaluate the value of
                  RETURNCODE and act accordingly.  The values of
                  RETURNCODE are as follows:
                    0   = ESC pressed (menu aborted)
                    1-x = The appropriate option was selected, with 1
                          being the first menu choice, 2 the second,
                          etc.

 Example:  Here is a sample main menu using the MENU procedure:
-----------------------------------------------------------------------------
   Program DontDoMuch;
   Uses Crt,MPMenu;

   CONST     HELL_FREEZES_OVER=FALSE;
   VAR       CHOICE:BYTE;

   Begin
     REPEAT

     With Menu_Data Do Begin
       Menu_Choices[1]:='1 - First Option ';    - define menu choice onscreen
       Row[1]:=10; Column[1]:=30;               - where on screen displayed
       Menu_Choices[2]:='2 - Second Option';    - same thing for 2nd choice
       Row[2]:=12; Column[2]:=30;                 .
       Menu_Choices[3]:='X - Exit Program ';      .
       Row[3]:=14; Column[3]:=30;                 .
       Onekey:=TRUE;                            - enable 1-key execution
       Num_Choices:=3;                          - number of menu choices
       HiLighted:=112;                          - highlighted attribute
       Normal:=7;                               - normal attribute
     End;

     MENU(MENU_DATA,CHOICE);          - call the menu now and wait for user

     Case Choice Of                   - evaluate user response and act
       0:Halt;                        - ESC pressed
       3:Halt;                        - option 3, Exit, selected
       1:Begin
           - put code here to do menu option 1
         End;
       2:Begin
           - put code here to do menu option 2
         End;
     End

     UNTIL HELL_FREEZES_OVER;          - infinite loop - back to main menu
End.
-----------------------------------------------------------------------------
}
INTERFACE

  USES Crt;

  CONST
    MAX_CHOICES = 10;                            { MAX_CHOICES can be changed
                                                   depending upon the highest
                                                   number of options you will
                                                   have on any given menu }

  TYPE
    MENU_ARRAY = RECORD                          { record structure for menu }
      MENU_CHOICES : ARRAY[1..MAX_CHOICES] OF STRING[50];  { displayed option }
      COLUMN       : ARRAY[1..MAX_CHOICES] OF BYTE;        { column location }
      ROW          : ARRAY[1..MAX_CHOICES] OF BYTE;  { row location }
      NUM_CHOICES  : BYTE;                           { # choices on menu }
      HILIGHTED    : WORD;                           { attribute for hilight }
      NORMAL       : WORD;                           { attributed for normal }
      ONEKEY       : BOOLEAN;                        { TRUE for 1-key execution
}
    END;

  VAR
    MENU_DATA : MENU_ARRAY;                      { global menu variable }

{
  NOTE:  You can define many menu variables simultaneously, but since you
         can generally use only one menu at a time, you can conserve
         memory and program space by re-defining this one MENU_DATA record
         each time a menu is to be displayed.
}

{ internal procedures }
  PROCEDURE SHOW_MENU(MENU_DATA:MENU_ARRAY);
  PROCEDURE HILIGHT_CHOICE(MENU_DATA:MENU_ARRAY;CHOICENUM:BYTE);
  PROCEDURE UNHILIGHT_CHOICE(MENU_DATA:MENU_ARRAY;CHOICENUM:BYTE);
  FUNCTION GETKEY(VAR FUNCTIONKEY:BOOLEAN):CHAR;
  FUNCTION FOUND_CHOICE(MENU_DATA:MENU_ARRAY;VAR EXITCODE:BYTE;CH:CHAR):BOOLEAN;

{ basically, the ONE callable procedure }
  PROCEDURE MENU(MENU_DATA:MENU_ARRAY;VAR EXITCODE:BYTE);

IMPLEMENTATION


(*===========================================================================*)
PROCEDURE SHOW_MENU(MENU_DATA:MENU_ARRAY);
{ display defined menu array }
VAR I:BYTE;
BEGIN
  TEXTATTR:=MENU_DATA.NORMAL;
  FOR I:=0 TO (MENU_DATA.NUM_CHOICES-1) DO BEGIN
    GOTOXY(MENU_DATA.COLUMN[I+1],MENU_DATA.ROW[I+1]);
    WRITE(MENU_DATA.MENU_CHOICES[I+1]);
  END;
END;
(*===========================================================================*)
PROCEDURE HILIGHT_CHOICE(MENU_DATA:MENU_ARRAY;CHOICENUM:BYTE);
{ highlight the appropriate menu choice }
BEGIN
  GOTOXY(MENU_DATA.COLUMN[CHOICENUM],MENU_DATA.ROW[CHOICENUM]);
  TEXTATTR:=MENU_DATA.HILIGHTED;
  WRITE(MENU_DATA.MENU_CHOICES[CHOICENUM]);
  { below needed if direct screen writing not done }
  GOTOXY(MENU_DATA.COLUMN[CHOICENUM],MENU_DATA.ROW[CHOICENUM]);
END;
(*===========================================================================*)
PROCEDURE UNHILIGHT_CHOICE(MENU_DATA:MENU_ARRAY;CHOICENUM:BYTE);
{ highlight the appropriate menu choice }
BEGIN
  GOTOXY(MENU_DATA.COLUMN[CHOICENUM],MENU_DATA.ROW[CHOICENUM]);
  TEXTATTR:=MENU_DATA.NORMAL;
  WRITE(MENU_DATA.MENU_CHOICES[CHOICENUM]);
END;
(*===========================================================================*)
FUNCTION GETKEY(VAR FUNCTIONKEY:BOOLEAN):CHAR;
{ read keyboard and return character/function key }
VAR CH: CHAR;
BEGIN
  CH:=ReadKey;
  IF (CH=#0) THEN
    BEGIN
      CH:=ReadKey;
      FUNCTIONKEY:=TRUE;
    END
  ELSE FUNCTIONKEY:=FALSE;
  GETKEY:=CH;
END;
(*===========================================================================*)
FUNCTION FOUND_CHOICE(MENU_DATA:MENU_ARRAY;VAR EXITCODE:BYTE;CH:CHAR):BOOLEAN;
{ locate next occurance of menu choice starting with char CH }
VAR I:BYTE; TEMP:STRING;
BEGIN
  CH:=UPCASE(CH);
  IF EXITCODE=MENU_DATA.NUM_CHOICES THEN BEGIN
    TEMP:=MENU_DATA.MENU_CHOICES[1];
    IF UPCASE(TEMP[1])=CH THEN BEGIN
      UNHILIGHT_CHOICE(MENU_DATA,EXITCODE);
      EXITCODE:=1;
      HILIGHT_CHOICE(MENU_DATA,EXITCODE);
      FOUND_CHOICE:=TRUE;
      EXIT;
    END;
  END;

  FOR I:=EXITCODE+1 TO MENU_DATA.NUM_CHOICES DO BEGIN
    TEMP:=MENU_DATA.MENU_CHOICES[I];
    IF UPCASE(TEMP[1])=CH THEN BEGIN
      UNHILIGHT_CHOICE(MENU_DATA,EXITCODE);
      EXITCODE:=I;
      HILIGHT_CHOICE(MENU_DATA,EXITCODE);
      FOUND_CHOICE:=TRUE;
      EXIT;
    END;
  END;

  IF EXITCODE<>1 THEN BEGIN             { KILLER RECURSION }
    UNHILIGHT_CHOICE(MENU_DATA,EXITCODE);
    EXITCODE:=1;
    IF FOUND_CHOICE(MENU_DATA,EXITCODE,CH) THEN BEGIN
      HILIGHT_CHOICE(MENU_DATA,EXITCODE);
      FOUND_CHOICE:=TRUE;
      EXIT;
    END ELSE HILIGHT_CHOICE(MENU_DATA,EXITCODE);
  END ELSE BEGIN
    TEMP:=MENU_DATA.MENU_CHOICES[1];
    IF UPCASE(TEMP[1])=CH THEN BEGIN
      FOUND_CHOICE:=TRUE;
      EXIT;
    END;
  END;
  FOUND_CHOICE:=FALSE;
END;
(*===========================================================================*)
PROCEDURE MENU(MENU_DATA:MENU_ARRAY;VAR EXITCODE:BYTE);
{ display menu and return user's response:
   0   = ESC pressed
   1-x = appropriate choice selected

   during operation, variable EXITCODE holds number of currently-selected
   menu choice.
}
VAR
  FNC:BOOLEAN; TEMPATTR:WORD;
  CH:CHAR;
BEGIN
  TEMPATTR:=TEXTATTR;
  IF (EXITCODE=0) OR (EXITCODE>MENU_DATA.NUM_CHOICES) THEN
    EXITCODE:=1;
  SHOW_MENU(MENU_DATA);
  HILIGHT_CHOICE(MENU_DATA,EXITCODE);
  REPEAT
    CH:=GETKEY(FNC);
    IF FNC THEN BEGIN
      IF CH=#77 THEN CH:=#80 ELSE
      IF CH=#75 THEN CH:=#72;

      CASE CH OF
        #72:IF EXITCODE>1 THEN BEGIN                              { UP }
              UNHILIGHT_CHOICE(MENU_DATA,EXITCODE);
              EXITCODE:=EXITCODE-1;
            END;
        #80:IF EXITCODE<MENU_DATA.NUM_CHOICES THEN BEGIN          { DOWN }
              UNHILIGHT_CHOICE(MENU_DATA,EXITCODE);
              EXITCODE:=EXITCODE+1;
            END;
        #71:IF EXITCODE<>1 THEN BEGIN                             { HOME }
              UNHILIGHT_CHOICE(MENU_DATA,EXITCODE);
              EXITCODE:=1;
            END;
        #79:IF EXITCODE<MENU_DATA.NUM_CHOICES THEN BEGIN          { END }
              UNHILIGHT_CHOICE(MENU_DATA,EXITCODE);
              EXITCODE:=MENU_DATA.NUM_CHOICES;
            END;
      END; { functionkey CASE }
      HILIGHT_CHOICE(MENU_DATA,EXITCODE);
    END { if FNC }

    ELSE
      CASE CH OF
        #27:BEGIN
              EXITCODE:=0;
              TEXTATTR:=TEMPATTR;
              EXIT;
            END;
        #13:BEGIN
              TEXTATTR:=TEMPATTR;
              EXIT;
            END;
      ELSE
        IF FOUND_CHOICE(MENU_DATA,EXITCODE,CH) THEN
          IF (MENU_DATA.ONEKEY) THEN BEGIN
            TEXTATTR:=TEMPATTR;
            EXIT;
          END ELSE { nothing }
        ELSE
{          BEGIN
            GOTOXY(1,20);  used for debugging
            WRITELN('FNC=',FNC,'      KEYVAL=',ORD(CH));
          END;
 }
      END; {case}
  UNTIL FALSE;
END;
(*===========================================================================*)
END. { of unit MPMENU }


