(* This keyboard input unit will compile on ALL versions of TP & BP from
   Version 5.0 to Ver 7.0 - you can easily recode the interrupts in BASM
   for users of TP & BP versions that support BASM *)

(* This unit provided by Pedt Scragg 101322,2153. Part of a forthcoming
   Pascal Toolbox for Real and Protected Mode programmers for Turbo & 
   Borland Pascal Programmers - versions 5.0 to 8.0 *)

unit ExtKey;

interface

uses dos, crt;

(* No keyboard code*)

Const   KbNoKey         = chr(0);

(* Keyboard Timeout *)

        KbTimeOut       = chr(255);

(* Normal Keycodes returned in FirstCode *)

        KbCtrlA         = chr(1);
        KbCtrlB         = chr(2);
        KbCtrlC         = chr(3);
        KbCtrlD         = chr(4);
        KbCtrlE         = chr(5);
        KbCtrlF         = chr(6);
        KbCtrlG         = chr(7);
        KbCtrlH         = chr(8);
        KbCtrlI         = chr(9);
        KbTab           = chr(9);
        KbCtrlJ         = chr(10);
        KbCtrlK         = chr(11);
        KbCtrlL         = chr(12);
        KbCtrlM         = chr(13);
        KbEnter         = chr(13);
        KbCtrlN         = chr(14);
        KbCtrlO         = chr(15);
        KbCtrlP         = chr(16);
        KbCtrlQ         = chr(17);
        KbCtrlR         = chr(18);
        KbCtrlS         = chr(19);
        KbCtrlT         = chr(20);
        KbCtrlU         = chr(21);
        KbCtrlV         = chr(22);
        KbCtrlW         = chr(23);
        KbCtrlX         = chr(24);
        KbCtrlY         = chr(25);
        KbCtrlZ         = chr(26);
        KbEsc           = chr(27);
        KbLeftBracket   = chr(27);
        KbRightBracket  = chr(29);
        KbCtrl6         = chr(30);
        KbCtrlMinus     = chr(31);
        KbSpace         = chr(32);

(* Extended Keycodes from all keyboards *)

        KbCtrl2         = chr(3);
        KbShiftTab      = chr(15);
        KbAltQ          = chr(16);
        KbAltW          = chr(17);
        KbAltE          = chr(18);
        KbAltR          = chr(19);
        KbAltT          = chr(20);
        KbAltY          = chr(21);
        KbAltU          = chr(22);
        KbAltI          = chr(23);
        KbAltO          = chr(24);
        KbAltP          = chr(25);
        KbAltA          = chr(30);
        KbAltS          = chr(31);
        KbAltD          = chr(32);
        KbAltF          = chr(33);
        KbAltG          = chr(34);
        KbAltH          = chr(35);
        KbAltJ          = chr(36);
        KbAltK          = chr(37);
        KbAltL          = chr(38);
        KbAltZ          = chr(44);
        KbAltX          = chr(45);
        KbAltC          = chr(46);
        KbAltV          = chr(47);
        KbAltB          = chr(48);
        KbAltN          = chr(49);
        KbAltM          = chr(50);
        KbF1            = chr(59);
        KbF2            = chr(60);
        KbF3            = chr(61);
        KbF4            = chr(62);
        KbF5            = chr(63);
        KbF6            = chr(64);
        KbF7            = chr(65);
        KbF8            = chr(66);
        KbF9            = chr(67);
        KbF10           = chr(68);
        KbHome          = chr(71);
        KbUpArrow       = chr(72);
        KbPageUp        = chr(73);
        KbLeftArrow     = chr(75);
        KbRightArrow    = chr(77);
        KbEnd           = chr(79);
        KbDownArrow     = chr(80);
        KbPageDown      = chr(81);
        KbInsert        = chr(82);
        KbDelete        = chr(83);
        KbShiftF1       = chr(84);
        KbShiftF2       = chr(85);
        KbShiftF3       = chr(86);
        KbShiftF4       = chr(87);
        KbShiftF5       = chr(88);
        KbShiftF6       = chr(89);
        KbShiftF7       = chr(90);
        KbShiftF8       = chr(91);
        KbShiftF9       = chr(92);
        KbShiftF10      = chr(93);
        KbCtrlF1        = chr(94);
        KbCtrlF2        = chr(95);
        KbCtrlF3        = chr(96);
        KbCtrlF4        = chr(97);
        KbCtrlF5        = chr(98);
        KbCtrlF6        = chr(99);
        KbCtrlF7        = chr(100);
        KbCtrlF8        = chr(101);
        KbCtrlF9        = chr(102);
        KbCtrlF10       = chr(103);
        KbAltF1         = chr(104);
        KbAltF2         = chr(105);
        KbAltF3         = chr(106);
        KbAltF4         = chr(107);
        KbAltF5         = chr(108);
        KbAltF6         = chr(109);
        KbAltF7         = chr(110);
        KbAltF8         = chr(111);
        KbAltF9         = chr(112);
        KbAltF10        = chr(113);
        KbCtrlPrint     = chr(114);
        KbCtrlLeftArrow = chr(115);
        KbCtrlRightArrow= chr(116);
        KbCtrlEnd       = chr(117);
        KbCtrlPageDown  = chr(118);
        KbCtrlHome      = chr(119);
        KbAlt1          = chr(120);
        KbAlt2          = chr(121);
        KbAlt3          = chr(122);
        KbAlt4          = chr(123);
        KbAlt5          = chr(124);
        KbAlt6          = chr(125);
        KbAlt7          = chr(126);
        KbAlt8          = chr(127);
        KbAlt9          = chr(128);
        KbAlt0          = chr(129);
        KbAltMinus      = chr(130);
        KbAltEquals     = chr(131);
        KbCtrlPageUp    = chr(132);

(* Extended Keycodes from Enhanced Keyboards *)

        KbAltBackSpace  = chr(14);
        KbAltLeftBracket= chr(26);
        KbAltRightBracket=chr(27);
        KbAltEnter      = chr(28);
        KbAltSemiColon  = chr(39);
        KbAltPound      = chr(43);
        KbAltComma      = chr(51);
        KbAltFullStop   = chr(53);
        KbAltKeyPadStar = chr(55);
        KbAltKeyPadMinus= chr(74);
        KbAltKeyPadPlus = chr(78);
        KbF11           = chr(133);
        KbF12           = chr(134);
        KbShiftF11      = chr(135);
        KbShiftF12      = chr(136);
        KbCtrlF11       = chr(137);
        KbCtrlF12       = chr(138);
        KbAltF11        = chr(139);
        KbAltF12        = chr(140);
        KbCtrlUpArrow   = chr(141);
        KbCtrlKeyPadMinus=chr(142);
        KbCtrlKeyPad5   = chr(143);
        KbCtrlKeyPadPlus= chr(144);
        KbCtrlDownArrow = chr(145);
        KbCtrlInsert    = chr(146);
        KbCtrlDelete    = chr(147);
        KbCtrlTab       = chr(148);
        KbCtrlKeyPadSlash=chr(149);
        KbCtrlKeyPadStar= chr(150);
        KbAltHome       = chr(151);
        KbAltUpArrow    = chr(152);
        KbAltPageUp     = chr(153);
        KbAltLeftArrow  = chr(155);
        KbAltRightArrow = chr(157);
        KbAltEnd        = chr(159);
        KbAltDownArrow  = chr(160);
        KbAltPageDown   = chr(161);
        KbAltInsert     = chr(162);
        KbAltDelete     = chr(163);
        KbAltKeyPadSlash= chr(164);
        KbAltTab        = chr(165);
        KbAltKeyPadEnter= chr(166);

(* End of Enhanced Keycodes *)

        keyb_head : ^integer = ptr($40,$1A);
        keyb_tail : ^Integer = ptr($40,$1C);
        keyb_buff : ^char    = ptr($40,$0);
        keyb_start: ^integer = ptr($40,$80);
        keyb_end  : ^integer = ptr($40,$82);

var     IsEnhanced : boolean;

Procedure NextKey(var FirstCode,ExtendedCode:char);
Procedure KeyCode(var FirstCode,ExtendedCode:char);
Procedure Keywait;
Procedure FlushKeys;
Procedure WaitKey(Time:word);
Procedure DelayKey(Time:word;var Firstcode,ExtendedCode:Char);

implementation

VAR
    ShiftState : Byte ABSOLUTE $40:$17;

(* EnhancedKeyboard returns TRUE is an enhanced keyboard is present
   and FALSE if not present. Note this will return FALSE is an enhanced
   keyboard is present but the BIOS cannot handle it. The function result
   is available outside the unit in the IsEnhanced boolean variable *)

FUNCTION EnhancedKeyboard : Boolean;
VAR StateFrom16 : Byte;
var regs : registers;
BEGIN
  EnhancedKeyboard := FALSE;
  regs.ah := $12;
  intr($16,regs);
  statefrom16 := regs.al;
  IF StateFrom16 <> ShiftState THEN Exit;
  ShiftState := ShiftState XOR $20;
  regs.ah := $12;
  intr($16,regs);
  statefrom16 := regs.al;
  EnhancedKeyboard := StateFrom16 = ShiftState;
  ShiftState := ShiftState XOR $20;
END;

(* KeyWait will wait for a keypress then discard it *)

Procedure KeyWait;
begin
if IsEnhanced then Inline($B4/$11/$CD/$16/$74/$06/$B4/$10/$CD/$16/$EB/$F4/$B4/$10/$CD/$16) else
                   Inline($B4/$01/$CD/$16/$74/$06/$B4/$00/$CD/$16/$EB/$F4/$B4/$00/$CD/$16)
end;

(* Keypress works like the crt unit keypressed function and, if an enhanced
   keyboard is not available, will call the crt unit. This was programmed
   in case there is an enhanced keyboard but the BIOS cannot handle it. The
   buffer *may* contain the extended keycode but the BIOS would never
   recognise it when the ReadKey or this unit's KeyCode procedure was called *)

function KeyPress : boolean;
var fpkeyhead, fpkeytail : pointer;
begin
     if IsEnhanced then
     begin
          fpkeyhead := keyb_head;
          fpkeytail := keyb_tail;
          KeyPress := (integer(fpkeytail^) <> integer(fpkeyhead^));
     end
     else
         KeyPress := CRT.KeyPressed;
end;

(* Quickest way to flush the keyboard buffer is to set the pointers
   to the keyboard to read the same value *)

procedure FlushKeys;
var fpkeyhead, fpkeytail : pointer;
begin
      inline($FA);
      fpkeyhead := keyb_head;
      fpkeytail := keyb_tail;
      integer(fpkeyhead^) := integer(fpkeytail^);
      inline($FB);
end;

(* KeyCode reads the keyboard for the next key pressed and returns the values
   in FirstCode and ExtendedCode. If the key is a normal key, then ExtendedCode
   is set to #0 and FirstCode contains the character from the keyboard.

   If FirstCode is #0 then an Extended Code has been input and the Scan Code
   will be found in the ExtendedCode variable

   If there is no key waiting, KeyCode will wait for the next key pressed.

   Note that this procedure returns both normal codes and extended codes
   within one procedure and you do not need to call the procedure twice to
   get extended codes like when using the CRT ReadKey function. *)

procedure KeyCode(var FirstCode,ExtendedCode : char);
var regs:registers;
begin
     if IsEnhanced then regs.ah := $10 else regs.ah := $00;
     Intr($16,regs);
     if regs.al = 224 then regs.al := $00;
     if regs.al > $00 then regs.ah := $00;
     if regs.ax = 0 then regs.al := 224;
     FirstCode := chr(regs.al);
     ExtendedCode := chr(regs.ah);
end;

(* NextKey will read the next key pressed as with the KeyCode procedure
   above. However, if there is no key waiting in the buffer, both
   FirstCode and ExtendedCode will be set to #255 *)

Procedure NextKey(var FirstCode,ExtendedCode:char);
var regs:registers;
begin
     if IsEnhanced then regs.ah := $11 else regs.ah := $01;
     Intr($16,regs);
     if (regs.flags and fzero <> 0) then regs.ax := $FFFF;
     if regs.al = 224 then regs.al := $00;
     if regs.al > $00 then regs.ah := $00;
     if regs.ax = 0 then regs.al := 224;
     FirstCode := chr(regs.al);
     ExtendedCode := chr(regs.ah);
end;

(* DelayKey waits for specified time in milliseconds. If a key is pressed
   within the time specified then the FirstCode and ExtendedCode will
   have the Key pressed (see KeyCode above). If no key was pressed within the
   time, both FirstCode and ExtendedCode will have the #255 (KbTimeOut) code *)

Procedure DelayKey(Time:word;var Firstcode,ExtendedCode:Char);
var count : word;
begin
     FlushKeys;
     Time := Time div 10;
     count := 1;
     Firstcode := #255; ExtendedCode := #255;
     While count < Time do
     begin
         Delay(10);
         inc(count);
         If KeyPress then
         begin
             count := Time;
             KeyCode(FirstCode,ExtendedCode);
         end;
     end;
end;

(* WaitKey waits for the specified time or when a key is pressed if the
   key is pressed earlier than the specified time in milliseconds. The
   keystroke is thrown away *)

Procedure WaitKey(Time:word);
var count : word;
begin
     Flushkeys;
     time := time div 10;
     count := 1;
     While count < time do
     begin
          delay(10);
          inc(count);
          If KeyPress then count := time;
          FlushKeys;
     end;
end;

begin
     IsEnhanced := EnhancedKeyboard;
end.

{ ----------------------- DEMO --------------- CUT HERE ---------- }
program KeyTest;

uses ExtKey;

var Key1, Key2 : char;

begin
     Write('Extended Keyboard is ');
     If not IsEnhanced then Write('not ');
     Writeln('available');

     Key1 := #0;
     Key2 := #0;

     Writeln;
     Writeln('Press the ESC to end or press any key combination to get '+
             'Key pressed');

     While Key1 <> KbEsc do
     begin
          KeyCode(Key1,Key2);
          if Key1 = KbNoKey then
               Writeln('Extended Key, value = ',ord(Key2))
          else
          if Key1 < KbSpace then
               Writeln('Normal Key - Control Key, ESC or Bracket')
          else
               Writeln('Normal Key - key is "',Key1,'"');
     end;
end.
