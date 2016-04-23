unit MiscLib;
interface
uses crt,dos;

const
 MaxFiles = 30;
 MaxChoices = 8;

type
 STRING79 = string[79];
 TOGGLE_REC = record
   NUM_CHOICES: integer;
   STRINGS    : array [0..8] of STRING79;
   LOCATIONS  : array [0..8] of integer;
 end;
 RESPONSE_TYPE = (NO_RESPONSE, ARROW, KEYBOARD, RETURN);
 MOVEMENT = (NONE, LEFT, RIGHT, UP, DOWN);
 FnameType = string[12];
 FileListType = array[1..MaxFiles] of FnameType;
 ScrMenuRec = record
   Selection  : array[1..MaxChoices] of STRING79;
   Descripts  : array[1..MaxChoices,1..3] of STRING79;
 end;
 ScrMenuType = object
   NumChoices : integer;
   Last       : integer;
   Line, Col  : integer;
   MenuData   : ScrMenuRec;
   procedure Setup(MData: ScrMenuRec);
   function  GetChoice : integer;
 end;


procedure Set_Video (ATTRIBUTE: integer);
procedure Put_String (OUT_STRING: STRING79; LINE, COL, ATTRIB: integer);
procedure Put_Text (OUT_STRING: STRING79; LINE, COL: integer);
procedure Put_Colored_Text (OUT_STRING: STRING79;
                            LINE, COL, TXTCLR, BKGCLR: integer);
procedure Put_Centered_String (OUT_STRING: STRING79; LINE, ATTRIB: integer);
procedure Put_Centered_Text (OUT_STRING: STRING79; LINE: integer);
procedure Put_Error (OUT_STRING: STRING79; LINE, COL: integer);
procedure End_Erase (LINE, COL: integer);
procedure Put_Prompt (OUT_STRING: STRING79; LINE, COL: integer);
procedure Get_Response (var RESPONSE    : RESPONSE_TYPE;
                        var DIRECTION   : MOVEMENT;
                        var KEY_RESPONSE: char);
procedure Get_String (var IN_STRING: STRING79;
                      LINE, COL, ATTRIB, STR_LENGTH: integer);
procedure Get_Integer (var NUMBER: integer;
                       LINE, COL, ATTRIB, NUM_LENGTH: integer);
procedure Get_Prompted_String (var IN_STRING: STRING79;
                          INATTR, STR_LENGTH: integer;
                                     STRDESC: STRING79;
                           DESCLINE, DESCCOL: integer;
                                      PROMPT: STRING79;
                               PRLINE, PRCOL: integer);
procedure Put_1col_Toggle (TOGGLE: TOGGLE_REC; COL, CHOICE: integer);
procedure Get_1col_Toggle (    TOGGLE: TOGGLE_REC;
                                  COL: integer;
                           var CHOICE: integer;
                               PROMPT: STRING79;
                        PRLINE, PRCOL: integer);
procedure Box_Text (TopX, TopY, BotX, BotY, BoxColor: integer);
procedure Solid_Box (TopX, TopY, BotX, BotY, BoxColor: integer);
procedure swap_fnames(var A,B: FnameType);
procedure FileSort(var fname: FileListType; NumFiles: integer);
function  Get_Files_Toggle (choices: FileListType;
                            NumChoices,NumRows,row,col:integer): FnameType;
function Get_File_Menu(mask: string;NumRows,Row,Col: integer): FnameType;


{-------------------------------------------------------------------------}
implementation

procedure Set_Video (ATTRIBUTE: integer);
{
NOTES:
      The attribute code, based on bits, is as follows:
          0 - normal video         1 - reverse video
          2 - bold video           3 - reverse and bold
          4 - blinking video       5 - reverse and blinking
          6 - bold and blinking    7 - reverse, bold, and blinking
}

var
   BLINKING,
   BOLD: integer;

begin
   BLINKING := (ATTRIBUTE AND 4)*4;
   if (ATTRIBUTE AND 1) = 1 then
      begin
         BOLD := (ATTRIBUTE AND 2)*7;
         Textcolor (1 + BLINKING + BOLD);
         TextBackground (3);
      end
   else
      begin
         BOLD := (ATTRIBUTE AND 2)*5 DIV 2;
         Textcolor (7 + BLINKING + BOLD);
         TextBackground (0);
      end;
end;

{-------------------------------------------------------------------------}

procedure Put_String (OUT_STRING: STRING79;
                     LINE, COL, ATTRIB: integer);

begin
   Set_Video (ATTRIB);
   GotoXY (COL, LINE);
   write (OUT_STRING);
   Set_Video (0);
end;

{-------------------------------------------------------------------------}

procedure Put_Text (OUT_STRING: STRING79;
                   LINE, COL: integer);

begin
   GotoXY (COL, LINE);
   write (OUT_STRING);
end;

{-------------------------------------------------------------------------}

procedure Put_Colored_Text (OUT_STRING: STRING79;
                           LINE, COL, TXTCLR, BKGCLR: integer);

begin
   GotoXY (COL, LINE);
   TextColor (TXTCLR);
   TextBackground (BKGCLR);
   write (OUT_STRING);
end;

{-------------------------------------------------------------------------}

procedure Put_Centered_String (OUT_STRING: STRING79;
                              LINE, ATTRIB: integer);

begin
   Put_String (OUT_STRING, LINE, 40-Length(OUT_STRING) div 2, ATTRIB);
end;

{-------------------------------------------------------------------------}

procedure Put_Centered_Text (OUT_STRING: STRING79;
                            LINE: integer);

begin
   Put_Text (OUT_STRING, LINE, 40-Length(OUT_STRING) div 2);
end;

{-------------------------------------------------------------------------}

procedure Put_Error (OUT_STRING: STRING79;
                     LINE, COL: integer);

var
   ANY_CHAR : char;

begin
repeat
   Put_String (OUT_STRING, LINE, COL, 6);
until keypressed = true;
end;

{-------------------------------------------------------------------------}

procedure End_Erase (LINE, COL: integer);

begin
   GotoXY (COL, LINE);
   ClrEol;
end;

{-------------------------------------------------------------------------}

procedure Put_Prompt (OUT_STRING: STRING79;
                     LINE, COL: integer);

begin
   GotoXY (COL, LINE);
   ClrEol;
   Put_String (OUT_STRING, LINE, COL, 3);
end;

{-------------------------------------------------------------------------}


procedure Get_Response (var RESPONSE    : RESPONSE_TYPE;
                        var DIRECTION   : MOVEMENT;
                        var KEY_RESPONSE: char);

const
   BELL            = 7;
   CARRIAGE_RETURN = 13;
   ESCAPE          = 27;
   RIGHT_ARROW     = 77;
   LEFT_ARROW      = 75;
   DOWN_ARROW      = 80;
   UP_ARROW        = 72;

var
   IN_CHAR: char;

begin
   RESPONSE := NO_RESPONSE;
   DIRECTION := NONE;
   KEY_RESPONSE := ' ';
   repeat
      IN_CHAR := ReadKey;
      if IN_CHAR = #0 then
      begin
         RESPONSE := ARROW;
         IN_CHAR := ReadKey;
         if Ord(IN_CHAR) = LEFT_ARROW then
            DIRECTION := LEFT
         else if Ord(IN_CHAR) = RIGHT_ARROW then
            DIRECTION := RIGHT
         else if Ord(IN_CHAR) = DOWN_ARROW then
            DIRECTION := DOWN
         else if Ord(IN_CHAR) = UP_ARROW then
            DIRECTION := UP
         else
         begin
            RESPONSE := NO_RESPONSE;
            write (Chr(BELL));
         end
      end
      else if Ord(IN_CHAR) = CARRIAGE_RETURN then
         RESPONSE := RETURN
      else
      begin
         RESPONSE := KEYBOARD;
         KEY_RESPONSE := UpCase (IN_CHAR);
      end;
   until RESPONSE <> NO_RESPONSE;
end;

{-------------------------------------------------------------------------}

procedure Get_String (var IN_STRING: STRING79;
                     LINE, COL, ATTRIB, STR_LENGTH: integer);

var
   OLDSTR : STRING79;
   IN_CHAR: char;
   I      : integer;

const
   BELL            = 7;
   BACK_SPACE      = 8;
   CARRIAGE_RETURN = 13;
   ESCAPE          = 27;
   RIGHT_ARROW     = 77;

begin
   OLDSTR := IN_STRING;
   Put_String (IN_STRING, LINE, COL, ATTRIB);
   for I := Length(IN_STRING) to STR_LENGTH-1 do
      Put_String (' ', LINE, COL + I, ATTRIB);
   GotoXY (COL, LINE);
   IN_CHAR := ReadKey;
   if Ord(IN_CHAR) <> CARRIAGE_RETURN then
      IN_STRING := '';
   while Ord(IN_CHAR) <> CARRIAGE_RETURN do
   begin
      if Ord(IN_CHAR) = BACK_SPACE then
      begin
         if Length(IN_STRING) > 0 then
         begin
            IN_STRING[0] := Chr(Length(IN_STRING)-1);
            write (Chr(BACK_SPACE));
            write (' ');
            write (Chr(BACK_SPACE));
         end;
      end  { if BACK_SPACE }
      else if IN_CHAR = #0 then
      begin
         IN_CHAR := ReadKey;
         if Ord(IN_CHAR) = RIGHT_ARROW then
         begin
            if Length(OLDSTR) > Length(IN_STRING) then
            begin
               IN_STRING[0] := Chr(Length(IN_STRING) + 1);
               IN_CHAR := OLDSTR[Ord(IN_STRING[0])];
               IN_STRING[Ord(IN_STRING[0])] := IN_CHAR;
               write (IN_CHAR);
            end
         end      { RIGHT_ARROW }
            else
               write (Chr(BELL));
      end   { IN_CHAR = #0 }
   else if Length (IN_STRING) < STR_LENGTH then
      begin
         IN_STRING[0] := Chr(Length(IN_STRING) + 1);
         IN_STRING[Ord(IN_STRING[0])] := IN_CHAR;
         TextColor (15);
         TextBackGround (11);
         write (IN_CHAR);
      end
      else
         write (Chr(BELL));
      IN_CHAR := ReadKey;
   end;
   Put_String (IN_STRING, LINE, COL, ATTRIB);
   for I := Length(IN_STRING) to STR_LENGTH - 1 do
      Put_String (' ', LINE, COL+I, ATTRIB);
end;

{-------------------------------------------------------------------------}

procedure Get_Integer (var NUMBER: integer;
                      LINE, COL, ATTRIB, NUM_LENGTH: integer);

const
   BELL = 7;

var
   VALCODE      : integer;
   ORIGINAL_STR,
   TEMP_STR     : STRING79;
   TEMP_INT     : integer;

begin
   Str (NUMBER:NUM_LENGTH, ORIGINAL_STR);
   repeat
      TEMP_STR := ORIGINAL_STR;
      Get_String (TEMP_STR, LINE, COL, ATTRIB, NUM_LENGTH);
      while TEMP_STR[1] = ' ' do
         TEMP_STR := Copy (TEMP_STR, 2, Length (TEMP_STR));
      Val (TEMP_STR, TEMP_INT, VALCODE);
      if (VALCODE <> 0) then
         write (Chr(BELL));
   until VALCODE = 0;
   NUMBER := TEMP_INT;
   Str (NUMBER:NUM_LENGTH, TEMP_STR);
   Put_String (TEMP_STR, LINE, COL, ATTRIB);
end;

{-------------------------------------------------------------------------}

procedure Get_Prompted_String (var IN_STRING: STRING79;
                          INATTR, STR_LENGTH: integer;
                                     STRDESC: STRING79;
                           DESCLINE, DESCCOL: integer;
                                      PROMPT: STRING79;
                               PRLINE, PRCOL: integer);

begin
   Put_String (STRDESC, DESCLINE, DESCCOL, 2);
   Put_Prompt (PROMPT, PRLINE, PRCOL);
   Get_String (IN_STRING, DESCLINE, DESCCOL + Length(STRDESC),
               INATTR, STR_LENGTH);
   Put_String (STRDESC, DESCLINE, DESCCOL, 0);
end;

{-------------------------------------------------------------------------}

procedure Put_1col_Toggle (TOGGLE: TOGGLE_REC;
                           COL, CHOICE: integer);

var
   I: integer;

begin
   with TOGGLE do
   begin
      Put_String (STRINGS[0], LOCATIONS[0], COL, 0);
      for I := 1 to NUM_CHOICES do
         Put_String (STRINGS[I], LOCATIONS[I], COL, 0);
      if (CHOICE <1) or (CHOICE > NUM_CHOICES) then
         CHOICE := 1;
      Put_String (STRINGS[CHOICE], LOCATIONS[CHOICE], COL, 1);
   end;
end;

{-------------------------------------------------------------------------}

procedure Get_1col_Toggle (    TOGGLE: TOGGLE_REC;
                                  COL: integer;
                           var CHOICE: integer;
                               PROMPT: STRING79;
                        PRLINE, PRCOL: integer);

var
   RESP : RESPONSE_TYPE;
   DIR  : MOVEMENT;
   KEYCH: char;

begin
   Put_Colored_Text (PROMPT, PRLINE, PRCOL, 15, 0);
   with TOGGLE do
   begin
      Put_String (STRINGS[0], LOCATIONS[0], COL, 2);
      if (CHOICE < 1) or (CHOICE > NUM_CHOICES) then
         CHOICE := 1;
      Put_String (STRINGS[CHOICE], LOCATIONS[CHOICE], COL, 1);
      RESP := NO_RESPONSE;
      while RESP <> RETURN do
      begin
         Get_Response (RESP, DIR, KEYCH);
         case RESP of
            ARROW:
               if DIR = UP then
               begin
                  Put_String (STRINGS[CHOICE], LOCATIONS[CHOICE], COL, 0);
                  if CHOICE = 1 then
                     CHOICE := NUM_CHOICES
                  else
                     CHOICE := CHOICE - 1;
                  Put_String (STRINGS[CHOICE], LOCATIONS[CHOICE], COL, 1);
               end
               else if DIR = DOWN then
               begin
                  Put_String (STRINGS[CHOICE], LOCATIONS[CHOICE], COL, 0);
                  if CHOICE = NUM_CHOICES then
                     CHOICE := 1
                  else
                     CHOICE := CHOICE + 1;
                  Put_String (STRINGS[CHOICE], LOCATIONS[CHOICE], COL, 1);
               end
            else
               write (Chr(7));
            KEYBOARD:  write (Chr(7));
            RETURN: ;
         end;
      end; {while}
   Put_String (STRINGS[0], LOCATIONS[0], COL, 0);
   end;
end;

{-------------------------------------------------------------------------}

procedure Box_Text (TopX, TopY, BotX, BotY, BoxColor: integer);

var
   i     : integer;
   width : integer;
   height: integer;

begin
   TextBackGround (BoxColor);
   height := BotY - TopY;
   width := BotX - TopX;
   GotoXY (TopX, TopY);
   for i := 1 to width do
      write (' ');
   for i := TopY to (TopY+height) do
      begin
         GotoXY (TopX, i);
         write ('  ');
         GotoXY (BotX-1, i);
         write ('  ');
      end;
   GotoXY (TopX, BotY);
   for i := 1 to width do
      write (' ');
end;

{-------------------------------------------------------------------------}

procedure Solid_Box (TopX, TopY, BotX, BotY, BoxColor: integer);

var
   i     : integer;
   j     : integer;
   width : integer;

begin
   TextBackGround (BoxColor);
   GotoXY (TopX, TopY);
   width := BotX - TopX;
   for i := TopY to BotY do
      begin
         for j := 1 to width do
            write (' ');
         GotoXY (TopX, i);
      end;
end;

procedure swap_fnames(var A,B: FnameType);
var
  Temp : FnameType;
begin
  Temp := A;
  A := B;
  B := Temp;
end;

procedure FileSort(var fname: FileListType;NumFiles: integer);
var
  i,j : integer;
begin
  for j := NumFiles downto 2 do
    for i := 1 to j-1 do
      if fname[i]>fname[j] then
        swap_fnames(fname[i],fname[j]);
end;

function Get_Files_Toggle (choices:FileListType;
                           NumChoices,NumRows,row,col:integer): FnameType;
var
  i,r   : integer;
  Resp  : Response_Type;
  dir   : movement;
  keych : char;

procedure Put_Files_Toggle (choices: FileListType; First,NumRows,row,col: integer);
var
  i : integer;
begin
  for i := 0 to NumRows-1 do
    Put_string (choices[First+i],row+i,col,0);
end;

procedure Padnames;
var
  i,p : integer;
begin
  for i := 1 to MaxFiles do
    begin
      p := 12-length(choices[i]);
      while p>0 do
        begin
          choices[i] := choices[i]+' ';
          p := p-1;
        end;
    end;
end;

begin
  Padnames;
  i := 1;
  r := 1;
  if NumChoices < NumRows then
    NumRows := NumChoices;
  Put_Files_Toggle (choices,1,NumRows,row,col);
  Get_Files_Toggle := choices[i];
  Put_string(choices[i],row,col,1);
  resp := No_Response;
  while resp <> Return do
    begin
      Get_response (resp,dir,keych);
      case resp of
        ARROW: if dir=UP then
                 begin
                   Put_string(choices[i],row+r-1,col,0);
                   if i=1 then
                     begin
                       i := NumChoices;
                       r := NumRows;
                       Put_Files_Toggle(choices,i+1-NumRows,NumRows,row,col);
                     end
                   else if r=1 then
                     begin
                       i := i-1;
                       Put_Files_Toggle(choices,i,NumRows,row,col);
                     end
                   else
                     begin
                       i := i-1;
                       r := r-1;
                     end;
                   Put_string(choices[i],row+r-1,col,1);
                 end
               else if dir=DOWN then
                 begin
                   Put_string(choices[i],row+r-1,col,0);
                   if i=NumChoices then
                     begin
                       i := 1;
                       r := 1;
                       Put_Files_Toggle(choices,i,NumRows,row,col);
                     end
                   else if r=NumRows then
                     begin
                       i := i+1;
                       Put_Files_Toggle(choices,i+1-NumRows,NumRows,row,col);
                     end
                   else
                     begin
                       i := i+1;
                       r := r+1;
                     end;
                   Put_string(choices[i],row+r-1,col,1);
                 end
               else
                 write (chr(7));
        KEYBOARD:  write (chr(7));
        end; { case }
    end;
  Get_Files_toggle := choices[i];
end;

function Get_File_Menu(mask: string;NumRows,Row,Col: integer): FnameType;
var
  i : integer;
  NumFiles : integer;
  FileList : FileListType;
  dirinfo  : SearchRec;
begin
  i := 1;
  FindFirst(mask,Archive,dirinfo);
  while (DosError=0) AND (i<MaxFiles+1) do
    begin
      FileList[i] := dirinfo.name;
      FindNext(dirinfo);
      i := i+1;
    end;
  NumFiles := i-1;
  FileSort(FileList,NumFiles);
  Get_File_Menu := Get_Files_Toggle(FileList,NumFiles,NumRows,Row,Col);
end;

procedure ScrMenuType.Setup(MData : ScrMenuRec);
var i : integer;
begin
  with MenuData do
    for i := 1 to MaxChoices do
      begin
        selection[i] := MData.selection[i];
        Descripts[i,1] := MData.descripts[i,1];
        Descripts[i,2] := MData.descripts[i,2];
        Descripts[i,3] := MData.descripts[i,3];
      end;
end;

function ScrMenuType.GetChoice : integer;
var
  i : integer;
  Resp  : Response_Type;
  Dir   : Movement;
  KeyCh : char;

procedure PutDescripts;
var i : integer;
begin
  window(0,0,79,24);
  Solid_Box(3,21,79,24,lightgray);
  for i := 1 to 3 do
    Put_Colored_Text(MenuData.Descripts[last,i],20+i,4,white,lightgray);
end;

begin
with MenuData do
begin
  for i := 0 to NumChoices-1 do
    Put_String(Selection[i+1],Line+i,Col,0);
  Put_String(Selection[Last],Line+Last-1,Col,1);
  Resp := No_Response;
  while Resp <> Return do
    begin
      PutDescripts;
      Get_Response(Resp,Dir,KeyCh);
      case Resp of
        Arrow :
          if Dir = Up then
            begin
              Put_String(Selection[Last],Line+Last-1,Col,0);
              if Last = 1 then
                Last := NumChoices
              else
                Last := Last-1;
              Put_String(Selection[Last],Line+Last-1,Col,1);
            end
          else if Dir = Down then
            begin
              Put_String(Selection[Last],Line+Last-1,Col,0);
              if Last = NumChoices then
                Last := 1
              else
                Last := Last+1;
              Put_String(Selection[Last],Line+Last-1,Col,1);
            end;
        end;
    end;
end;
end;
{ Initialization Area }
begin
end.

{------------------------------------  TEST PROGRAM   ------------------- }

program testdir;
{ program attempts to read directory }
{ shows filenames as column }

uses dos,crt,miscLib;

var
  Fchoice  : FnameType;
  i,n      : integer;



{ *************** MAIN PROGRAM *************** }

begin
  ClrScr;
  Fchoice := Get_File_Menu('*.*',8,10,30);
  Put_string(Fchoice,24,1,0);
  ReadLn;
end.


{------------------------------------  TEST PROGRAM   ------------------- }

program TestMenu;
uses crt,MiscLib;

const
  ChoiceData : ScrMenuRec =
    (selection : ('Choice 1','Choice 2','Choice 3','Choice 4','','','','');
     Descripts : (('This is','No 1','The First Choice'),
                  ('Number 2','The Second Choice and default',''),
                  ('Number 3','Last Choice, for now...','Last Line'),
                  ('Number 4','An added Selection','How bout that?'),
                  ('','',''),
                  ('','',''),
                  ('','',''),
                  ('','','')));
var
  ScrMenu : ScrMenuType;
  Choice : integer;

begin
  TextColor(white);
  TextBackGround(Blue);
  ClrScr;
  ScrMenu.NumChoices := 4;
  ScrMenu.Last := 2;
  ScrMenu.Line := 6;
  ScrMenu.Col  := 30;
  ScrMenu.Setup(ChoiceData);
  Choice := ScrMenu.GetChoice;
  ReadLn;
end.