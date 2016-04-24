(*
  Category: SWAG Title: COMMUNICATIONS/INT14 ROUTINES
  Original name: 0058.PAS
  Description: Mail Manager
  Author: ANGUS C. MARCH
  Date: 08-25-94  09:08
*)

{
From: ac_march@ECE.Concordia.CA (Angus C. March)

I have this grave problem where when I use this certain program that calls a
function that I defined in a unit, the program shortly hangs up. Oddly enough
if I start peppering the regions of code about where the hang up occurs it is
delayed. As another interesting piece of information: pushing ctrl-break
causes the hangup as well.
     Anyway, the following is a Turbo Pascal 6.0 partially written in
Borland.  It's REAL LONG, so I'm not going to expect anyone to sift through
all the code, that is why I have COMMENTED THE KEY POINTS IN CODE w/UPPERCASE
LETTERS, so it will be MUCH EASER TO FIND. Just like a comic book advert for
a martial arts course.

     Anyway, here is all the code.
}

Program mailManager;

Uses DOS, CRT, AngusU; {AngusU= A UNIT WITH MY OWN ROUTINES, SEE END IF
                                POST}

Const
     background = Blue;
     foreground = LightGray;

     scrX = 80;
     scrY = 25;
     scrXY = 80*25;


Type          {screen save types}
    scrXRange = 1..scrX;  {x-axis range of my screen}
    scrYRange = 1..scrY;  {y-  "    "   "  "    "}
    scrXYRange = 1..scrXY;
    scrElementRecord = Record  {attributes of a cell on the text screen}
                       element: Char;
                       colour: Byte;
    end;
    scrPointer = ^scrNode;
    scrNode = Record          {linked list of window to be put on the stack}
              cell: scrElementRecord;
              next: scrPointer;
    end;
    scrStackPointer = ^stackNode;       {These set the stack}
    stackNode = Record
                scrWindowPointer: scrPointer; {pointer to window to be saved}
                cursorX, {where cursor was left}
                left, right: scrXRange; {boundries of the window to be saved}
                cursorY, {where cursor was left}
                top, bottom: scrYRange; {boundries of the window to be save}
                winMax, winMin: Word; {boundries of the window}
                colour: Byte;  {textAttr}
                downward: scrStackPointer; {pointer to next place in stack}
    end;

                      {menuTypes}
    stringPointer = ^stringNode;
    stringNode = Record
         prev,next: stringPointer;  {strings passed to menu}
         streng: String;
    end;


Var
   dummy, menuAnswer: Char;
   p: DirPointer;
   head, bufferPointer, q: stringPointer;
   menuCand: String;
   COUNTER: Byte;
   EXTENDED: BOOLEAN;

   {screen save vars}
   scrStack: scrStackPointer;


{Procedure colorWindow;
Var
   i: Word;

Begin
     TextBackground(White);
     For i:= 1 To 2000 Do
         Write(' ');
end;}


Function strg(x: Longint): String;
Var
   carry: String;

Begin
     Str(x, carry);
     strg:= carry;
end;


Procedure message(messg: String);
Var
   carryWindMax, carryWindMin: Word;
   carryWhereX: scrXRange;
   carryWhereY: scrYRange;

Begin
     carryWhereX:= WhereX; carryWhereY:= WhereY;
     carryWindMax:= WindMax; carryWindMin:= WindMin;
     Window(1, 25, 80, 25);
     Write(messg);
     WindMax:= carryWindMax; WindMin:= carryWindMin;
     GotoXY(carryWhereX, carryWhereY);
end;


Procedure shiftWindow(xShift, yShift: Shortint);
Begin
     Window(Lo(WindMin) + 1 + xShift, Hi(WindMin) + 1 + yShift, Lo(WindMax) +
1 + xShift, Hi(WindMax) + 1 + yShift);
end;


Procedure getCursorChar(Var attrib, charCode: Byte);
{THIS THING DOESN'T WORK VERY WELL BUT IT ISN'T CAUSING THE PROBLEM
BECAUSE THE PROBLEM REMAINS WHEN THIS PROCEDURE IS REMOVED FROM THE CODE}
Var
   reg: Registers;{regPack}

Begin
     Reg.AH := 8;  {Function 8 = Read attribute and character at cursor.}
     Reg.BH := 0;  {Use display page = 0}

     Intr(10,Reg); {Call Interrupt 10 (BIOS)}

     attrib := Reg.AH;  {Get atrribute value from result.}
     charCode:= Reg.AL; {Get character code from result.}
end;


Procedure getChar(x: scrXRange; y: scrYRange; Var cell: scrElementRecord);
Var
   xCarry: scrXRange;
   yCarry: scrYRange;
   colour, charOrd: Byte;

Begin
     xCarry:= WhereX; yCarry:= WhereY;
     GotoXY(x, y);
     getCursorChar(colour, charOrd);
     cell.colour:= colour;
     cell.element:= Chr(charOrd);
dummy:= WriteRead('');  {THIS IS INSTRUMENTAL IN THE PROBLEM! IF I TAKE THIS
OUT THE PROBLEM GOES AWAY... FOR A WHILE. SEE THE END OF THE PROGRAM FOR
THE IMPLEMENTATION OF THE ANGUSU UNIT}
     GotoXY(xCarry, yCarry);
end;


Function oneString(counter: Byte): String;
Var
   i: Byte;
   beg, j: Word;
   theString, letters: String;

Begin
     j:= 1;
     letters:= '';
     theString:= 'Hi I''m Wayne Gretzky I scored 92 goals 10 years ago and
anyone who sez n that I''m a homosexual can go';
{     theString:= ConCat(theString, ' get run over by a starship. Max, you sly
puss. Good grief this could take for Moncton');}
{     theString:= ConCat(theString, ' ever I mean all the things that we have
to write');}
     For i:= 1 To counter Do
     Begin
          beg:= j;
          While Not(thestring[j] = ' ') And (j < Length(theString)) Do
                j:= j + 1;
          j:= j + 1;
     end;
     If j > Length(theString) Then
        letters:= ''
     Else
         For i:= beg To j - 1 Do
             letters:= Concat(letters,theString[i]);
     oneString:= letters;
end;


{Procedure scrSaveParam;}


Procedure initStack;
Begin
     scrStack:= Nil;
end;


Procedure scrPush(scr: scrPointer; left, right: scrXRange;
                         top, bottom: scrYRange);
Var
   carryStackPointer: scrStackPointer;
   carryWindMax, carryWindMin: Word;

Begin
     carryWindMax:= WindMax; carryWindMin:= WindMin;

     Window(1, 1, 80, 25);
     carryStackPointer:= scrStack;
     New(scrStack);
     scrStack^.cursorX:= WhereX; scrStack^.cursorY:= WhereY;
     scrStack^.winMax:= carryWindMax; scrStack^.winMin:= carryWindMin;
     scrStack^.colour:= TextAttr;
     scrStack^.scrWindowPointer:= scr;
     scrStack^.left:= left; scrStack^.right:= right; scrStack^.top:= top;
scrStack^.bottom:= bottom;
     scrStack^.downward:= carryStackPointer;
     WindMax:= carryWindMax; WindMin:= carryWindMin;
end;


Procedure scrPop(Var scr: scrPointer; Var left, right: scrXRange;
                        Var top, bottom: scrYRange);
Var
   carry: scrStackPointer;

Begin
     Window(1, 1, 80, 25);
     GotoXY(scrStack^.cursorX, scrStack^.cursorY);
     WindMax:= scrStack^.winMax; WindMin:= scrStack^.winMin;
     TextAttr:= scrStack^.colour;
     scr:= scrStack^.scrWindowPointer;
     left:= scrStack^.left; right:= scrStack^.right; top:= scrStack^.top;
bottom:= scrStack^.bottom;
     carry:= scrStack;
     scrStack:= scrStack^.downward;
     Dispose(carry);
end;


Procedure initWindowPointer(Var pointer: scrPointer);
Begin
     pointer:= Nil;
end;


Procedure scrStoreElement(Var pointer: scrPointer; Var cell: scrElementRecord);
Var
   buffer: scrPointer;
   messg: Char;

Begin
     New(buffer);
     buffer^.cell:= cell;
{messg:= buffer^.cell.element;
message(messg);
Write('We are now saving ',Ord(messg));}
     buffer^.next:= Nil;
     If pointer = Nil Then
        pointer:= buffer
     Else
         pointer^.next:= buffer;
end;

Procedure scrRetrieveElement(Var pointer: scrPointer; Var charChar: Char);
Var
   carry: scrPointer;

Begin
     If pointer= Nil Then
        WriteLn('hey this is Nil!')
     Else
     Begin
     charChar:= pointer^.cell.element;
     TextAttr:= pointer^.cell.colour;
     carry:= pointer;
     pointer:= pointer^.next;
     Dispose(carry);
     end;
end;


Procedure windowSave;
Var
   x: scrXRange;
   y: scrYRange;
   windowPointer: scrPointer;
   cell: scrElementRecord;

Begin
     initWindowPointer(windowPointer);
     For y:= Hi(WindMin) + 1 To Hi(WindMax) + 1 Do
         For x:= Lo(WindMin) + 1 To Lo(WindMax) + 1 Do
         Begin
              getChar(x, y, cell);
              WriteLn('Ok, I get here',x,' ',y,' ',cell.colour,'
',Ord(cell.element));
              scrStoreElement(windowPointer, cell);
         end;
     scrPush(windowPointer, Lo(WindMin) + 1, Lo(WindMax) + 1, Hi(WindMin) + 1,
Hi(WindMax) + 1);
end;


Procedure windowRetrieve;
Var
   x, left, right: scrXRange;
   y, top, bottom: scrYRange;
   windowPointer: scrPointer;
   element: Char;

Begin
     scrPop(windowPointer, left, right, top, bottom);
     scrPush(windowPointer, 1, 1, 1, 1);
     Window(1, 1, 80, 25);
     For y:= top To bottom Do
         For x:= left To right Do
         Begin
              GotoXY(x, y);
If Not(windowPointer = Nil) Then
              scrRetrieveElement(windowPointer, element);
              Write(element);
         end;
     scrPop(windowPointer, left, right, top, bottom);
end;


Procedure drawMenu(head: stringPointer; Var extended: Boolean);
{THIS PROCEDURE IS PASSED A SET OF STRINGS, LINKED-LISTED, AND MAKE A MENU
OF THEM}
Var
   size, longest: Word;

   bufferPointer: stringPointer;
   menuWidth, x, middleX: scrXRange;
   menuHeight, y,middleY: scrYRange;

Begin

     bufferPointer:= head;
     size:= 0; longest:= 0;

     While Not(bufferPointer = Nil) Do
     Begin
          size:= size + 1;
          If (Length(bufferPointer^.streng) > longest) Then longest:=
Length(bufferPointer^.streng);
          bufferPointer:= bufferPointer^.next;
     end;
     extended:= ((size + 1) Div 2) > (Hi(WindMax) - Hi(WindMin) - 3);

     middleX:= (Lo(WindMax) - Lo(WindMin) + 1) Div 2;
     middleY:= (Hi(WindMax) - Hi(WindMin) + 1) Div 2;
     If extended Then
        Window(middleX - (longest + 1), Hi(WindMin) + 1, middleX + longest + 2,
                       Hi(WindMax) + 1)
     Else
         Window(middleX - (longest + 1), (middleY - 1) - (size - 1) Div 4,
                        middleX + longest + 2, (middleY + 1) + (size + 1) Div
4);
     shiftWindow(-25, -4);
     windowSave;
     menuWidth:= Lo(WindMax) - Lo(WindMin) - 1;
     menuHeight:= Hi(WindMax) - Hi(WindMin) + 1;
     If extended Then menuHeight:= menuHeight - 1;
     middleX:= (Lo(WindMax) - Lo(WindMin)) Div 2;
     middleY:= (Hi(WindMax) - Hi(WindMin) + 1) Div 2;
     GotoXY(1, 1);
     TextColor(White); Write('╔'); For x:= 1 To menuWidth - 2 Do Write('═');
WriteLn('╗');
     For y:= 2 To menuHeight - 1 Do
     Begin
          TextColor(White); Write('║'); TextColor(Yellow);
          Write(head^.streng);
          clrEol;
          If Not(head^.next = Nil) Then
          Begin
               GotoXY(middleX + 2, y);
               Write(head^.next^.streng);
          end;
          head:= head^.next^.next;
          GotoXY(menuWidth, y);
          TextColor(White); WriteLn('║'); TextColor(Yellow);
     end;
     TextColor(White);
     If extended Then
     Begin
          Write('║');
          GotoXY(middleX - 8, WhereY);
          Write('Page Up/Page Down');
          GotoXY(menuWidth, WhereY);
          WriteLn('║');

     end;
     Write('╚'); For x:= 1 To menuWidth - 2 Do Write('═'); Write('╝');
end;


Procedure writeLnHighLight(streng: String; foreground, background: Byte);
Var
   i: Shortint;
   textStart: Byte;

Begin
     textStart:= TextAttr;
     TextBackground(background);
     TextColor(foreground);
     For i:= 1 To Length(streng) Do
     Begin
          If streng[i] = '(' Then
             TextColor(White)
          Else
              If streng[i] = ')' Then
                 TextColor(foreground)
              Else
                  Write(streng[i]);
     end;
     WriteLn;
     TextAttr:= textStart;
end;


Begin
     COUNTER:= 1;
     menuAnswer:= ' ';
     TextBackground(background);
     TextColor(foreground);
     ClrScr;

     writeLnHighLight(' Mailing (L)ist             (C)onfigure Schedual       
      (M)ail             E(x)it',
                               LightBlue, LightGray);
     Window(1, 2, 80, 25);

     menuCand:= 'Wayne Gretzky';
     WriteLn('Ok tell Santa what you want to put in the menu');
     New(bufferPointer);
     head:= bufferPointer;
     q:= Nil;
     While Not(menuCand = '') Do
     Begin
          menuCand:= oneString(COUNTER);
          COUNTER:= COUNTER + 1;
          If Not(menuCand = '') Then
          Begin
               q^.next:= bufferPointer; bufferPointer^.prev:= q;
bufferPointer^.next:= Nil;
               bufferPointer^.streng:= menuCand;
               q:= bufferPointer;
               New(bufferPointer);
          end;
     end;
{THIS PART OF THE PROGRAM IS JUST TRYING TO DRAW A MENU AND SEE IF IT CAN BE
READ OFF THE SCREEN. SO FAR I HAVEN'T HAD MUCH LUCK.}
     drawMenu(head, extended);
     dummy:= WriteRead('Just lemme know when you''re tired of looking at it
(Anykey)');
     windowRetrieve;
     While Not(menuAnswer = 'X') Do
     Begin
          menuAnswer:= WriteRead('');
     end;
end.



Unit AngusU;

Interface
         Uses DOS, CRT;

         Type
             RealDecimalRange = 0..38;

             DirPointer = ^listpointer;
             listpointer = Record
                         results: SearchRec;
                         next: DirPointer;
             end;

         Function WriteRead(message: String): Char;
         {Outputs messages, and waits for a single key input}

         Function WriteReadLn(message: String): String;
         {Outputs message, and waits for entered keyboard input}

         Procedure Dir(pathway: PathStr; Var list: DirPointer);
         {Do the Gilligan's directory thing, and return attributes in linked
list}

         Function AllUpCase(streng: String): String;

         Function Log(argu: Real): Real;
         {Returns common logrithm}

         Function DeScience(input: Real; decimal: RealDecimalRange): String;
         {Reads a real number and outputs it in string}


Implementation
              Function WriteRead(message: string): Char;
{SO FAR, OTHER THAN ONE OF THE TYPES THIS IS THE ONLY THING FROM THIS UNIT
THAT I INVOKE. AGAIN, IF I REMOVE THE CODE FROM MY CALLER PROGRAM (I FORGET THE
PROGRAMMER JARGON FOR IT) THE PROBLEM SEEM TO DECREASE}.
              {Outputs messages, and waits for a single key input}
              Begin
                   Write(message);
                   WriteRead:= UpCase(ReadKey);
              end;


              Function WriteReadLn(message: String): String;
              {Outputs message, and waits for entered keyboard input}
              Var
                 buffer: String;

              Begin
                   Write(message);
                   ReadLn(buffer);
                   WriteReadLn:= buffer;
              end;


              Procedure Dir(pathway: PathStr; Var list: DirPointer);
              {Do the Gilligan's directory thing, and return attributes in
linked list}
              Var
                 carry, buffer: DirPointer;
                 searchBuff: SearchRec;
                 i, j: Integer;

              Begin
                   New(list);
                   FindFirst(pathway, AnyFile, searchBuff);
                   If DosError = 0 Then
                      list^.results:= searchBuff;

                   New(buffer);
                   list^.next:= buffer;
                   carry:= list;
                   While DosError = 0 Do
                   Begin
                        FindNext(searchBuff);
                        buffer^.results:= searchBuff;
                        If DosError = 0 Then
                        Begin
                             carry:= buffer;
                             New(buffer);
                             carry^.next:= buffer;
                        end;
                   end;
                   carry^.next:= Nil;
              end;


              Function AllUpCase(streng: String): String;
              Var
                 i: Integer;

              Begin
                   For i:= 1 To Length(streng) Do
                   streng[i]:= UpCase(streng[i]);
                   AllUpCase:= streng
              end;


              Function Log(argu: Real): Real;
              Begin
                   Log:= Ln(argu)/Ln(10);
              end;


              Function DeScience(input: Real; decimal: realDecimalRange):
String;
              {Reads a real number and outputs it in string}
              Var
                 buffer: String;
              Begin
                   Str(input: trunc(Log(input) + 1): decimal, buffer);
                   DeScience:= buffer;
              end;
end.

