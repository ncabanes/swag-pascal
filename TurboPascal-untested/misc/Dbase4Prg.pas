(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0003.PAS
  Description: DBASE4.PRG
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:51
*)

{
Hello every one... Guys and gals is there any such a thing that you can
use turbp pascal 6 with Dbase IV.. what I heard is I can.
if yes tell me how you export or whatever to use two of thewm
together,,,

Yes there is! I have been using it for some time now in dBase as I use
an XT and dBase's editor is too slow when the program has quite a few
lines (some are 5,000) and the system just kind of dies. When I use TP's
IDE the editor is FAST!!!! So after reading the books I designed a
program in order to use TP as using it in the TEDIT CONFIG.DB command
wouldn't work as it needed more memory (I only have 640k).
}


In dBase's setup program, under the FILES MENU enter in either
PRGAPPLIC (overrides Application Control in the ASSIST menu only!) or
 Entry  - C:\DBASEIV\EDIT2.PRG
 Exit   - empty
 Layout - empty
PRGCC (allows you to use OPEN CUSTOM UTILIY option under Catalog Menu).
 Entry  - empty
 Exit   - empty
 Layout - C:\DBASEIV\EDIT2.PRG

I am currently using PRGAPPLIC as I do most of my work in the Control
Center anyhow and don't need the Application Generator. Note - PRGCC
will not pull in a PRG file unless you change the source code to ask for
one.

Here is the dBase program that calls Turbo Pascal:

* <T>Program ----> EDIT2.PRG
* <D>Language ---> dBase IV 1.5
* <P>Author -----> P.A.T. Systems° C.1993
* <T>Creation date -> 07/22/1992
* <L>Last update ---> 01/06/1993

* <G>From-> Control Center
* <N>To---> None
* <T>Subs-> None

* This program invokes an External Editor such as Turbo Pascal 6.0's
* (TP) Desktop Editor by using the PRGAPPLIC setup in the Config.db
* file. Even though it is only for Entry Programs, with some tricky
* commands we can get it to invoke an External Editor such as TP.

* Although I can't do any Compiling or Help Lookup (another use for the
* Manuals), it still is a great and FAST!!!! Editor to work with.

* This program will work with any editor that will accept a filename
* as a parameter.

* Example  TURBO filename.prg  (Turbo Pascal) OR
* WP filename.prg     (Word Perfect)

* As I am used to TP's Editor, I wished I could use it when I wanted to
* edit a program.  Especially a long program that when loaded into
* dBase's editor is extremely slow, but in TP, editing is FAST!!! And
* with dBase IV 1.5's NEW Open Architecture, I now have a way to do it.

* This program uses the RUN() function to swap out memory to disk so
* that the editor can load in.  With the TEDIT command in the Config.db
* setup, there wasn't enough memory (on an XT) to load in the editor.
* So I read the manuals (Yes, I do read them occasionally!) and figured
* out a way to use an External Editor by utilizing the Control Center's
* NEW Open Architecture.

* First, copy this program into dBase's Startup Directory.

* You next have to change dBase's setup using DBSETUP at the DOS prompt
* and load in the current configuration and then on the Files Menu
* change the option of PRGAPPLIC so that it reads
* "C:\DBASEIV\EDIT2.PRG". Once done, save the new configuration and
* exit to DOS.  Then enter dBase in your usual way.  Next, create or
* edit an existing program through the Control Center's Application
* Menu.  The Control Center will execute this .PRG file (it will
* automatically compile it) and load up your Editor with the program
* ready to edit!

* ***Note***
*  This program will only work through the Control Center.  If you type
*  "MODI COMM filename" at the DOT PROMPT, the original editor will be
*  loaded as the Open Architecture only works with the Control Center
*  applications.

* Hope you enjoy this program!!!!

* Parameters passed from Control Center to Application Designer
* Panel Name, Filename (Programming in dBase IV - Chapter 17, pg 4)

PARAMETERS cPanelName, cFileName

* Clear screen and turn on cursor
* (MODI COMM turns off cursor when loading and then turns it back
* on when editing - Why? I don't know. When I invoked my editor, I
* found that the cursor had disappeared, so I included this Command
* and my cursor came back!)

CLEAR
SET CURSOR ON

* Store Editor's filename and dBase .PRG Filename to variable for
* Macro Execution

* (You can enter your own Editor's file name here if you wish, just
* include the FULL PATH NAME just in case, and don't forget the SPACE!)

* uncomment this line for PRGCC or it will load CATALOG FILE
* STORE "" TO cFileName
STORE "D:\TP\TURBO " + cFileName TO cExecEdit

* Invoke RUN() function to swap out memory

STORE RUN("&cExecEdit",.T.) TO nRun

* Change filename so we can erase .DBO file for proper compiling
* If creating a new file, no need to erase .DBO file

IF .NOT. ISBLANK(cFileName)
   STORE SUBSTR(cFileName, 1, AT(".PRG", cFileName)) + "DBO" TO ;
    cExecEdit

* Erase the .DBO file

   ERASE &cExecEdit
ENDIF

* Return directly to Control Center instead of invoking Command Editor

RETURN TO MASTER

* End

