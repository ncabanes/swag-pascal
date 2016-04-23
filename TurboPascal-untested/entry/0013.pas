Unit InputUn;

{ This is a small unit with crash proof user input routines and some
  string formating functions. Compile the DemoInput program for more
  information on how to use these functions.

   Robert Mashlan [71160,3067]  3/11/89 }

Interface

Uses Crt;

const
   DefaultSet = [' '..'}'];

Var
   InverseOn    : boolean;
   UpcaseOn     : boolean;
   ValidCharSet : set of char;

Procedure Inverse;
Procedure UnderLine;
Procedure Normal;
Procedure Goback;
Function ReadString( Prompt : string; Width : byte; var Escape : boolean ) : string;
Function ReadNum( Prompt : real; Width : byte; var Escape : boolean ) : real;
Function ReadInt( Prompt : longint; Width : byte; var Escape : boolean ) : longint;
Function Left( AnyString : string; Width : byte ) : string;
Function Center( AnyString : string; Width : byte ) : string;

Implementation

const
   esc = #27;

Procedure Inverse;
begin
   textbackground(white);
   textcolor(black);
end;

Procedure UnderLine;
begin
   textbackground(white);
   textcolor(blue);
end;

Procedure Normal;
begin
   textbackground(black);
   textcolor(white);
end;


Procedure Goback;
begin
   GotoXY(WhereX,WhereY-1);
   ClrEol;
end;

Function Left( AnyString : string; Width : byte ) : string;
var
   len  : byte absolute AnyString;
   loop : byte;
begin
   while length( AnyString ) < Width do
      AnyString:=AnyString+' ';
   len:=Width;      { truncate AnyString if Needed }
   Left:=AnyString;
end;

Function Center( AnyString : string; Width : byte ) : string;
begin
   repeat
      if length( AnyString ) < Width
         then AnyString:=AnyString+' ';
      if length( AnyString ) < Width
         then AnyString:=' '+AnyString;
   until length( AnyString ) >= Width;
   Center:=AnyString;
end;


Function ReadString( Prompt : string; Width : byte; var Escape : boolean ) : string;
var
   NewString    : string;
   InKey,InKey2 : char;
   Start        : byte;
   index        : integer;
   InsertMode   : boolean;

   Procedure Display;
   begin
      GotoXY(Start,WhereY);
      if InverseOn
         then Inverse;
      write(left(NewString,Width));
      if InverseOn
         then Normal;
      GotoXY(Start+index,WhereY);
   end;

   Procedure StripSpaces( var AnyString : string );
   { decrease length of AnyString until a character until a char other than a space is found }
   begin
      while AnyString[ ord(AnyString[0]) ]=' ' do
         dec(AnyString[0]);
   end; { Procedure }



begin
   InsertMode:=false;
   Start:=WhereX;
   index:=0;
   NewString:=Prompt;
   Display;
   index:=1;
   if UpCaseOn
      then Inkey:=UpCase(ReadKey)
      else InKey:=ReadKey;
   if InKey=#0
      then begin
         InKey2:=ReadKey;
         if InKey2 in [#77,#82]
            then NewString:=Prompt
            else NewString:='';
         if Inkey2=#82
            then begin
               InsertMode:=true;
               index:=0;
            end;
      end { then }
      else if InKey in ValidCharSet
         then NewString:=InKey
         else begin
            NewString:='';
            index:=0;
         end;
   if InKey=esc
      then begin
         ReadString:=Prompt;
         Escape:=true;
         ValidCharSet:=defaultSet;
         exit;
      end;
   if InKey=#13
      then begin
         Escape:=false;
         ReadString:=Prompt;
         ValidCharSet:=DefaultSet;
         exit;
      end;
   Display;
   repeat
     if UpCaseOn
        then Inkey:=Upcase(readkey)
        else InKey:=ReadKey;
     if (InKey in ValidCharSet)
       then begin
           if not InsertMode
              then Delete(NewString,index+1,1);
           insert(InKey,NewString,index+1);
           if index<> Width then inc(index)
        end;
     if (length(NewString)<>0) and (InKey=#8)  { backspace }
        then begin
           Delete(NewString,index,1);
           if index<>0
              then dec(index);
        end;
     if InKey=#0
        then begin
           InKey:=ReadKey;
           case InKey of
              #77 : if (index<>length(NewString)) and (' ' in ValidCharSet)
                     then inc(index)
                     else if (index+1<>Width) and (' ' in ValidCharSet)
                        then begin
                           NewString:=NewString+' ';
                           inc(index);
                        end;
              #75 : if index<>0
                       then if length(NewString)+1<>index
                          then dec(index)
                          else if NewString[index]=' '
                             then begin
                                NewString[0]:=succ(NewString[0]);
                                dec(index);
                             end
                             else dec(index);
              #83 : if length(NewString)>0 then Delete(NewString,index+1,1);
              #82 : if InsertMode
                       then InsertMode:=false
                       else InsertMode:=true;
           end; { case }
        end; { then }
     if Length(NewString)>width then dec( NewString[0] );
     if index >= width then dec(index);
     Display;
   until (InKey=#13) or (InKey=esc);
   ValidCharSet:=DefaultSet;
   if not ( (InKey=esc) or (length(NewString)=0))
      then begin
         StripSpaces(NewString);
         ReadString:=NewString
      end
      else ReadString:=Prompt;
   if InKey=esc
      then Escape:=true
      else Escape:=false;

end; { Procedure }

Function ReadNum( Prompt : real; Width : byte; var Escape : boolean ) : real;
var
   NewString : string;
   code      : integer;
   OldNum    : real;
   Start     : byte;
begin
   OldNum:=Prompt;
   Start:=WhereX;
   repeat
      GotoXY(Start,WhereY);
      str( Prompt:0:2, NewString );
      ValidCharSet:=['0'..'9','.','-',' '];
      NewString:=ReadString( NewString, Width, Escape );
      val(NewString,Prompt,code);
   until Escape or (code=0);
   if Escape or (code<>0)
      then ReadNum:=OldNum
      else ReadNum:=Prompt;
end;

Function ReadInt( Prompt : longint; Width : byte; var Escape : boolean ) : longint;
var
   NewString : string;
   code      : integer;
   OldNum    : longint;
   Start     : byte;
begin
   OldNum:=Prompt;
   Start:=WhereX;
   repeat
      GotoXY(Start,WhereY);
      str( Prompt, NewString );
      ValidCharSet:=['0'..'9','-',' '];
      NewString:=ReadString( NewString, Width, Escape );
      val(NewString,Prompt,code);
   until Escape or (code=0);
   if Escape
      then ReadInt:=OldNum
      else ReadInt:=Prompt;
end;

begin
   InverseOn:=true;
   UpcaseOn:=false;
   ValidCharSet:=DefaultSet;
end.

{ -----------------------------   DEMO PROGRAM ----------------------- }
Program DemoInputUnit;

Uses
   Crt, InputUn;

var
   InKey     : char;
   AnyString : string;
   AnyInt    : longint;
   AnyNum    : real;
   Escape    : boolean;

begin
   ClrScr;
   writeln;
   Inverse;
   writeln(' Text in Inverse mode ');
   writeln;
   Underline;
   writeln(' Text in Underline mode ( if using a monochrome monitor)');
   writeln;
   normal;
   writeln(' Back to normal ');
   writeln;
   writeln(' The GoBack procedure is used...(press any key)................ ');
   Inkey:=readkey;
   goback;
   writeln(' To erase a line and write a new one  (press any key) ');
   InKey:=readkey;
   ClrScr;
   writeln(' The ReadString function takes 3 parameters');
   writeln(' Function ReadString( Prompt : string; width : byte; var Escape : boolean )');
   writeln('                                                                    : string;');
   writeln(' Prompt is the string that is first put into the edit field.');
   writeln(' This is the string that the function returns if the function is exited with');
   writeln(' an Esc at any time, or a return while it is there.');
   writeln(' This prompt may be edited if the right arrow or the insert key is pressed');
   writeln(' on the first input, otherwise the prompt will disappear.  The return key ');
   writeln(' will input all the visible characters in the field and exit the function.');
   writeln(' The Del, left and right arrow keys work as does the backspace.');
   writeln(' The Ins key toggles the insert mode where new characters are inserted ');
   writeln(' instead of written over.  It is initially off.');
   writeln(' Esc will also exit the function, return the prompt as the result and set ');
   writeln(' the Escape parameter to true (otherwise set to false with a return');
   writeln(' the width parameter sets the maximum length of the string');
   writeln(' This field is highlighted in Inverse. It may be turned off by setting the');
   writeln(' InverseOn to true. Another Global varible that affects this function is');
   writeln(' ValidCharSet which is initially set to the set of all printable characters.');
   writeln(' You can change it before calling this function, and is reset to the ');
   writeln(' DefaultSet const after calling it.  The InverseOn varible will convert');
   writeln(' all letters to uppercase if set to true. It is initially set to false');
   writeln;
   repeat
      write('Input a string->');
      AnyString:=ReadString('This is your prompt',20,escape);
      writeln;
      goback;
      if escape
         then write(' Escape Exit  ');
      writeln('Your string is ''',AnyString,'''');
      inkey:=readkey;
      goback;
      write('Input an integer ( ReadInt )->');
      AnyInt:=ReadInt(123,5,Escape);
      writeln;
      goback;
      if escape
         then write(' Escape Exit  ');
      writeln('Your integer is ',AnyInt);
      if escape then exit;
      inkey:=readkey;
      goback;
      write('Input a real number ( ReadNum )->');
      AnyNum:=ReadNum(1.23,8,escape);
      writeln;
      goback;
      if escape
         then write(' Escape Exit  ');
      writeln('Your Number is ',AnyNum:0:5);
      if escape then exit;
      if not escape
         then begin
            Inkey:=readkey;
            goback;
         end;
   until escape;
end.





