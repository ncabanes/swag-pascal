(********************************************************)
(******************** PICK.PAS **************************)
(******* the pick unit; to select menu choice *******)

Unit Pick;

interface

{1} Function ScreenChar : Char; {return the char at the cursor}
{2} Procedure BlockCursor; {give us a block cursor; TP6 & 7 only}
{3} Procedure NormalCursor; {restore cursor to normal; TP6 & 7 only}

{4} Function PickByte(Left, Top, Bottom : Byte) : Byte;
    {return the number of the item chosen as a byte, or
    return ZERO if ESCape is pressed}

{5} Function PickChar(Left, Top, Bottom : Byte) : Char;
    {return the character at the cursor when ENTER is pressed}


{
Notes: for "Pick" functions
  One returns a Byte and the other returns a Char - use one
  or the other;

  Parameters:
  Left   = the left side of the menu list (left side of window+1)
  Top    = the top of the menu list       (top of window+1)
  Bottom = the bottom of the menu list;   (bottom of window-1)
}

implementation

uses
dos,
crt,
keyb;

{-----------------------------------------------------}
Function PickByte(Left,Top,Bottom : byte) : Byte;
{return the number of the item chosen as a byte, or
return ZERO if ESCape is pressed}

Var
x,y,x1,y1 : byte;
ch        : char;
int,total : byte;

begin
    PickByte := 0;              {default to ZERO}
    total := (Bottom - Top)+1;  {total number of items in list}
    x1 := WhereX; y1 := WhereY; {save the original location}

    x := Left; y := Top;
    BlockCursor;         {give us a block cursor}

    GotoXy(x, y);

    int := 1;

    Repeat
       Ch := GetKey;

       Case Ch of
          LeftArrow, UpArrow : {move up}
          begin
             If y = Top then
             begin
               y := Bottom;
               int := total;
             end
             else
             begin
               Dec(y);
               dec(int);
             end;

           GotoXy(x,y);
          end; {leftarrow}

          RightArrow, DownArrow :   {move down}
          begin
             If y = Bottom then
             begin
                y := Top;
                int := 1;
             end
             else
             begin
                Inc(y);
                inc(int);
             end;
             GotoXy(x,y);
          end; {rightarrow}

        PgUp, Home : {go to top of list}
        begin
            y := Top;
            int := 1;
            GotoXy(x,y);
        end;

        PgDn, EndKey :  {go to bottom of list}
        begin
            y := Bottom;
            int := total;
            GotoXy(x,y);
        end;

       #13 : PickByte := int; {return position of choice in the array}
     End; {Case Ch}

    Until (ch = #27) or (ch = #13); {loop until ESCape or ENTER}

    GotoXY(x1,y1);  {return to original location}
    NormalCursor;   {Restore the cursor}
end;
{---------------------------------------------}

Function PickChar(Left, Top,Bottom : byte) : Char;
{return the character at the cursor when ENTER is pressed}

Var
x,y,x1,y1 : byte;
ch    : char;

begin
    PickChar := #27;
    x1 := WhereX; y1 := WhereY;
    x := Left; y := Top;

    BlockCursor;         {give us a block cursor}
    GotoXy(x,y);

    Repeat
       Ch := GetKey;
       Case Ch of
          LeftArrow, UpArrow :
          begin
             If y = Top then y := Bottom else Dec(y);
             GotoXy(x,y);
          end; {leftarrow}

          RightArrow, DownArrow :
          begin
             If y = Bottom then y := Top else Inc(y);
             GotoXy(x,y);
          end; {leftarrow}

        PgUp, Home :
        begin
            y := Top;
            GotoXy(x,y);
        end;

        PgDn, EndKey :
        begin
            y := Bottom;
            GotoXy(x,y);
        end;

       #13 : PickChar := ScreenChar; {return the char under the cursor}
     End; {Case Ch}

    Until (ch = #27) or (ch = #13);
    GotoXY(x1,y1);
    NormalCursor;         {give us a block cursor}

end;
{-----------------------------------------------}

{----------------------------------------}
Function ScreenChar : Char; {return the character at the cursor}
Var
R : Registers;
begin
   Fillchar(R, SizeOf(R), 0);
   R.AH := 8;
   R.BH := 0;
   Intr($10, R);
   ScreenChar := Chr(R.AL);
end;
{--------------------------------------------------}


{---------------------------------}
Procedure NormalCursor; {restore cursor to normal; TP6 & 7 only}
BEGIN
 asm
  mov ah,1
  mov ch,5   { / You will want to fool around with these two}
  mov cl,6   { \ numbers to get the cursor you want}
  int $10
 END;
END;

{--------------------------------}
Procedure BlockCursor; {give us a block cursor; TP6 & 7 only}
BEGIN
 asm
  mov ah,1
  mov ch,5    { / You will want to fool around with these two}
  mov cl,8    { \ numbers to get the cursor you want; (1=big)}
  int $10
 END;
END;
{-------------------------------------}

End.

{----------------- end of PICK.PAS --------------------}




(********************************************************)
(******************** KEYB.PAS **************************)
(******* the keyboard unit; for GetKey() function *******)

Unit Keyb;

Interface

Uses Crt;

Const
        F1  = #187;
        F2  = #188;
        F3  = #189;
        F4  = #190;
        F5  = #191;
        F6  = #192;
        F7  = #193;
        F8  = #194;
        F9  = #195;
        F10 = #196;

        ALTF1  = #232;
        ALTF2  = #233;
        ALTF3  = #234;
        ALTF4  = #235;
        ALTF5  = #236;
        ALTF6  = #237;
        ALTF7  = #238;
        ALTF8  = #239;
        ALTF9  = #240;
        ALTF10 = #241;

        CTRLF1        = #222;
        CTRLF2        = #223;
        CTRLF3        = #224;
        CTRLF4        = #225;
        CTRLF5        = #226;
        CTRLF6        = #227;
        CTRLF7        = #228;
        CTRLF8        = #229;
        CTRLF9        = #230;
        CTRLF10 = #231;

        SHFTF1        = #212;
        SHFTF2        = #213;
        SHFTF3        = #214;
        SHFTF4        = #215;
        SHFTF5        = #216;
        SHFTF6        = #217;
        SHFTF7        = #218;
        SHFTF8        = #219;
        SHFTF9        = #220;
        SHFTF10 = #221;

        UPARROW    = #200;
        RIGHTARROW = #205;
        LEFTARROW  = #203;
        DOWNARROW  = #208;

        HOME           = #199;
        PGUP           = #201;
        ENDKEY           = #207;
        PGDN           = #209;
        INS                      = #210;
        DEL                      = #211;
        TAB                      = #9;
        ESC                      = #27;
        ENTER           = #13;
        SYSREQ           = #183;
        CTRLMINUS  = #31;
        SPACE           = #32;
        CTRL2           = #129;
        CTRL6           = #30;
        BACKSPACE  = #8;
        BS                      = #8; {2 NAMES FOR BACKSPACE}

        CTRLBACKSLASH         = #28;
        CTRLLEFTBRACKET  = #27;
        CTRLRIGHTBRACKET = #29;
        CTRLBACKSPACE         = #127;
        CTRLBS                          = #127;

        ALTA = #158;
        ALTB = #176;
        ALTC = #174;
        ALTD = #160;
        ALTE = #146;
        ALTF = #161;
        ALTG = #162;
        ALTH = #163;
        ALTI = #151;
        ALTJ = #164;
        ALTK = #165;
        ALTL = #166;
        ALTM = #178;
        ALTN = #177;
        ALTO = #152;
        ALTP = #153;
        ALTQ = #144;
        ALTR = #147;
        ALTS = #159;
        ALTT = #148;
        ALTU = #150;
        ALTV = #175;
        ALTW = #145;
        ALTX = #173;
        ALTY = #149;
        ALTZ = #172;

        CTRLA = #1;
        CTRLB = #2;
        CTRLC = #3;
        CTRLD = #4;
        CTRLE = #5;
        CTRLF = #6;
        CTRLG = #7;
        CTRLH = #8;
        CTRLI = #9;
        CTRLJ = #10;
        CTRLK = #11;
        CTRLL = #12;
        CTRLM = #13;
        CTRLN = #14;
        CTRLO = #15;
        CTRLP = #16;
        CTRLQ = #17;
        CTRLR = #18;
        CTRLS = #19;
        CTRLT = #20;
        CTRLU = #21;
        CTRLV = #22;
        CTRLW = #23;
        CTRLX = #24;
        CTRLY = #25;
        CTRLZ = #26;

        ALT1 = #248;
        ALT2 = #249;
        ALT3 = #250;
        ALT4 = #251;
        ALT5 = #252;
        ALT6 = #253;
        ALT7 = #254;
        ALT8 = #255;
        ALT9 = #167;
        ALT0 = #168;

        ALTMINUS = #169;
        ALTEQ         = #170;
        SHIFTTAB = #143;

Function GetKey : Char;
procedure unGetKey(C : char);
procedure FlushKbd;
procedure flushBuffer;

const
    hasPushedChar   : boolean = false;

implementation
var
    pushedChar            : char;


(******************************************************************************
*                                  FlushKbd                                  *
******************************************************************************)
procedure FlushKbd;
var
    C        : char;
begin
    hasPushedChar := False;
    while (KeyPressed) do
         C := GetKey;
end; {flushKbd}

(******************************************************************************
*                                 flushBuffer                                 *
* Same as above, but if key was pushed by eventMgr, know about it !!          *
******************************************************************************)
procedure flushBuffer;
var
   b : boolean;
begin
   b := hasPushedChar;
   flushKbd;
   hasPushedChar := b;
end; {flushBuffer}


(******************************************************************************
*                                  unGetKey                                   *
* UnGetKey will put one character back in the input buffer. Push-back buffer  *
* can contain only one character.                                                                  *
* To avoid problems DO NOT CALL UNGETKEY WITHOUT FIRST CALLING GETKEY. If two *
* characters are pushed, the first is discarded.                                          *
******************************************************************************)
procedure unGetKey;
begin
    hasPushedChar := True;
    pushedChar          := c;
end; {unGetKey}

(******************************************************************************
*                                   GetKey                                   *
******************************************************************************)
function GetKey : Char;
var
        c : Char;
Begin
    if (hasPushedChar) then begin
                GetKey              := pushedChar;
                hasPushedChar := False;
                exit;
    end;
    c := ReadKey;
    if (Ord(c) = 0) then Begin
                c := ReadKey;
                if c in [#128,#129,#130,#131]
                    then c := chr(ord(c) + 39)
                else c := chr(ord(c) + 128); {map to suit keyboard constants}
    End;
    GetKey := c; {return keyboard (my..) code }
End; {getKey}

End.
{--------------- End of KEYB.PAS ---------------}


(********************************************************)
(************************** TEST.PAS ********************)
(*************** to test the PICK unit ******************)
(*************** quit by pressing ESCape ****************)

Program Test;

uses crt,pick;

{--------------- test program -----------------}
const
max = 6;
s : array[1..max] of string[18] =
(
'1. Number One ',
'2. Number Two ',
'3. Number Three ',
'4. Number Four ',
'5. Number Five ',
'6. Number Six ');

var
i  : byte;
x  : byte;
ch : char;
j  : byte;

begin
    clrscr;
    x := 10; {left side of the list}


   {------------------------- test using PickByte() ----------------}
    for i := 1 to max do
    begin            {display the list of menu items}
      j := i+5;      {start from row 6}
      gotoxy(x,j);
      writeln(s[i]);
    end;

    i := j;
    repeat
      {ch := choice(x,1,i);}
      j := pickbyte(x,6,i);

      gotoxy(15,22);
      writeln('You chose ',j);
    until j = 0; {until Escape}

   {------------------------- test using PickChar() ----------------}
    ClrScr;

    ch := 'A';
    for i := 1 to max do
    begin
       s[i][1] := Ch; {change numbers to letters in menu list}
       Inc(Ch);
    end;

    for i := 1 to max do
    begin            {display the list of menu items}
      gotoxy(x,i);   {start from row 1}
      writeln(s[i]);
    end;

    repeat
      ch := PickChar(x,1,i);
      gotoxy(15,22);
      writeln('You chose ',ch);
    until ch = #27;  {until Escape}

end.
{------------------------ end of TEST.PAS ---------------------------}
