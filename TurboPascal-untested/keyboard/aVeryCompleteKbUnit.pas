(*
  Category: SWAG Title: KEYBOARD I/O ROUTINES
  Original name: 0053.PAS
  Description: a VERY Complete KB Unit
  Author: JAN DOGGEN
  Date: 11-02-93  05:58
*)

Unit KeybFAQ;
(* This is version 0.90 of KEYBFAQ, a Unit that answers two questions
 * often asked in the Pascal message area's:
 * - How do I change my cursor ?
 * - How can I perform input of String With certain limitations
 *   (such as 'maximum length', 'only numbers' etc.)
 *
 * I will distribute this Unit *ONCE* in message form (three messages)
 * because it takes up 500 lines of code. It is untested code, cut from
 * my Unit library, and distributed *as is* With no other documentation
 * than these initial lines. You can use this code in your apps as you like,
 * and you can redistribute it, provided you:
 * - redistribute *source* code;
 * - do not Charge anything For the source code;
 * - give me credit For the original code if you change anything;
 * - keep this 'documentation' With it.
 * (Loosely translated: common decency is enough)
 * Copyright will formally remain mine.
 *
 * Please do not respond about this code. I am going away For a few weeks
 * and will distribute version 1.0 in ZIP form after that. That package
 * will have *tested* code, docs and examples.
 *
 * Some notes about this code:
 * - Use it always, or don't use it. I.e. if you start using GetKey
 *   you should use that throughout your Program, and drop all ReadKeys.
 * - The redefinition of Char into Key has two reasons:
 *   - it allows better Type checking
 *   - it allows future changes to the internal representation of the
 *     Key Type (I plan to make it a Word Type to handle the overlap
 *     in key definitions that is still present, and/or adapt Unicode
 *     Character definitions)
 * - The overlap in the Constant key definitions may look
 *   problematic, but in the years I have been using this, it has not
 *   posed any problems, generally because you only allow those keys
 *   that have a meaning For your app.
 *
 * Happy Pascalling,
 * Jan Doggen, 27/8/93 *)

Interface

Type
  Key    = Char;
  KeySet = Set of Key;
  (* See later in this Interface section For defined sets *)

Var
  BlankChar : Char;    (* Char used by GetStr to fill the bar; default ' ' *)

Procedure FlushKeyBuf;
(* Clears the BIOS keyboard buffer *)

Function  InsertStatus : Boolean;
Procedure SetInsertStatus(On : Boolean);

Procedure NiceBeep;
(* Replaces the system beep With a more pleasant one. *)

Type
  CursType = (NOCUR, LINECUR, BLOCKCUR);

Procedure SetCursor(CType: CursType);
(* SetCursor sets a block or line cursor, or no cursor. *)

Function GetVidMode : Byte;
(* Return BIOS video mode *)

Function MonoChrome(Vmode : Byte) : Boolean;
(* Returns True if a monochrome video mode is specified *)

Function WinLeft   : Byte;
Function WinRight  : Byte;
Function WinTop    : Byte;
Function WinBottom : Byte;
(* Return Absolute co-ordinates of current Window *)

Function RepeatStr(Str : String; N : Integer) : String;
(* Returns a String consisting of <N> repetitionsof <Str>. *)

Function GetKey : Key;
(* Returns a Variable of Type Key; see the table below For the definitions.
 * GetKey also accepts the <Alt-numeric keypad> ASCII codes. *)

Var
  ClearOnFirstChar,
  WalkOut,
  StartInFront : Boolean;
 (* These Booleans influence the way in which GetStr operates:
  *
  * With WalkOut = True: the left and right arrow keys also act as ExitKeys
  * when they bring us 'outside' of the Word (we Exit the Procedure).
  *
  * With ClearOnFirstChar = True: if the first key Typed is a Character,
  * the initial Str is cleared.
  *
  * With StartInFront = True: the cursor will be positioned at the first
  * Character when we start the Procedure (instead of after the last)
  *
  * Default settings For these Booleans are False. *)

Procedure GetStr(Xpos, Ypos,
                 MaxLen,
                 Ink, Paper   : Byte;
                 AllowedKeys,
                 ExitKeys     : KeySet;
                 BeepOnError  : Boolean;
                 Var Str      : String;
                 Var ExitKey  : Key);
(* Reads a String of max. <MaxLen> Characters starting at relative position
 * <XPos,YPos>. A bar of length <MaxLen> is placed there With colors
 * <Ink> on <Paper>. An initial value For the String returned can be
 * passed With <Str>.
 *
 * - BeepOnError indicates audio feedback on incorrect keypresses
 * - AllowedKeys is a set of Keys that may be entered. if AllowedKeys = [],
 *   all keys are allowed.
 * - ExitKeys is a set of Keys that stop the Procedure; <Str> will then
 *   contain the edited String and <ExitKey> will be key that made us Exit.
 *   if ExitKeys is [], it will be replaced by [Enter,Escape].
 *   The keys you specify in ExitKeys, do not have to be specified in
 *   AllowedKeys. *)

Function WaitKey(LegalKeys : Keyset; Flush : Boolean) : Key;
(* Waits For one of the keys in LegalKeys to be pressed, then returns this.
 * if <Flush> = True, the keyboard buffer is flushed first. *)

Const
  Null      = #0;    CtrlA = #1;   F1       = #187;  Home       = #199;
  BSpace    = #8;    CtrlB = #2;   F2       = #188;  endKey     = #207;
  Tab       = #9;    CtrlC = #3;   F3       = #189;  PgUp       = #201;
  Lfeed     = #10;   CtrlD = #4;   F4       = #190;  PgDn       = #209;
  Ffeed     = #12;   CtrlE = #5;   F5       = #191;  Left       = #203;
  CReturn   = #13;   CtrlF = #6;   F6       = #192;  Right      = #205;
  Escape    = #27;   CtrlG = #7;   F7       = #193;  Up         = #200;
  ShiftTab  = #143;  CtrlH = #8;   F8       = #194;  Down       = #208;
  CtrlPrtsc = #242;  CtrlI = #9;   F9       = #195;  Ins        = #210;
  Enter     = #13;   CtrlJ = #10;  F10      = #196;  Del        = #211;
  Esc       = #27;   CtrlK = #11;  ShiftF1  = #212;  CtrlLeft   = #243;
  Space     = #32;   CtrlL = #12;  ShiftF2  = #213;  CtrlRight  = #244;
                     CtrlM = #13;  ShiftF3  = #214;  CtrlendKey = #245;
  { Note the     }   CtrlN = #14;  ShiftF4  = #215;  CtrlPgdn   = #246;
  { overlap of   }   CtrlO = #15;  ShiftF5  = #216;  CtrlPgup   = #127;
  { Ctrl-keys    }   CtrlP = #16;  ShiftF6  = #217;  CtrlHome   = #247;
  { and others ! }   CtrlQ = #17;  ShiftF7  = #218;
                     CtrlR = #18;  ShiftF8  = #219;
                     CtrlS = #19;  ShiftF9  = #220;
                     CtrlT = #20;  ShiftF10 = #221;
                     CtrlU = #21;  CtrlF1   = #222;
                     CtrlV = #22;  CtrlF2   = #223;
                     CtrlW = #23;  CtrlF3   = #224;
                     CtrlX = #24;  CtrlF4   = #225;
                     CtrlY = #25;  CtrlF5   = #226;
                     CtrlZ = #26;  CtrlF6   = #227;
                     AltQ  = #144; CtrlF7   = #228;
                     AltW  = #145; CtrlF8   = #229;
                     AltE  = #146; CtrlF9   = #230;
                     AltR  = #147; CtrlF10  = #231;
                     AltT  = #148; AltF1    = #232;
                     AltY  = #149; AltF2    = #233;
                     AltU  = #150; AltF3    = #234;
                     AltI  = #151; AltF4    = #235;
                     AltO  = #152; AltF5    = #236;
                     AltP  = #153; AltF6    = #237;
                     AltA  = #158; AltF7    = #238;
                     AltS  = #159; AltF8    = #239;
                     AltD  = #160; AltF9    = #240;
                     AltF  = #161; AltF10   = #241;
                     AltG  = #162;
                     AltH  = #163;
                     AltJ  = #164;
                     AltK  = #165;
                     AltL  = #166; Alt1     = #248;
                     AltZ  = #172; Alt2     = #249;
                     AltX  = #173; Alt3     = #250;
                     AltC  = #174; Alt4     = #251;
                     AltV  = #175; Alt5     = #252;
                     AltB  = #176; Alt6     = #253;
                     AltN  = #177; Alt7     = #254;
                     AltM  = #178; Alt8     = #255;  { No Alt9 or Alt0 ! }

{ SETS }
  LetterKeys   : KeySet = ['A'..'Z','a'..'z'];
  SpecialKeys  : KeySet =
    ['!','?','b','a','a','a','a','a','A','a','A','A','e','e','e',
     'e','E','i','i','i','i','o','o','o','o','o','O','u','u','u',
     'u','U','c','C','n','N'];
  UpKeys       : KeySet = ['A'..'Z'];
  LowKeys      : KeySet = ['a'..'z'];
  VowelKeys    : KeySet = ['a','e','i','o','u','A','E','I','O','U'];
  DigitKeys    : KeySet = ['0'..'9'];
  OperatorKeys : KeySet = ['*','/','+','-'];
  YNKeys       : KeySet = ['y','n','Y','N'];
  JNKeys       : KeySet = ['j','n','J','N'];
  BlankKeys    : KeySet = [#0..#32];
  AllKeys      : KeySet = [#0..#255];
  FKeys        : KeySet = [F1..F10];
  ShiftFKeys   : KeySet = [ShiftF1..ShiftF10];
  AltFKeys     : KeySet = [AltF1..AltF10];
  CtrlFKeys    : KeySet = [CtrlF1..CtrlF10];
  AllFKeys     : KeySet = [F1..F10,ShiftF1..AltF10];

Implementation

Uses Crt,Dos;

Procedure NiceBeep; (* Replaces the system beep With a more pleasant one. *)
begin
  Sound(300);
  Delay(15);
  NoSound;
end;


Procedure FlushKeyBuf;
Var
  Ch : Char;
begin
  While KeyPressed do
    Ch := ReadKey;
end;


Function InsertStatus : Boolean;
Var
  Regs : Registers;
begin
  Regs.AH := 2;
  Intr($16, Regs);
  InsertStatus := ((Regs.AL and 128) = 128);
end;


Procedure SetInsertStatus(On: Boolean);
begin
  if ON then
    Mem[$0040:$0017] := Mem[$0040:$0017] or 128
  else
    Mem[$0040:$0017] := Mem[$0040:$0017] and 127;
end;


Function GetVidMode: Byte;
Var
  Regs : Registers;
begin
  Regs.AH := $0F;
  Intr($10, Regs);
  GetVidMode := Regs.AL;
end;


Function MonoChrome(Vmode : Byte) : Boolean;
begin
  MonoChrome := (VMode in [0,2,5,6,7,15,17]);
end;


Function WinLeft : Byte;
begin
  WinLeft := Lo(WindMin) + 1;
end;


Function WinRight : Byte;
begin
  WinRight := Lo(WindMax) + 1;
end;


Function WinTop : Byte;
begin
  WinTop := Hi(WindMin) + 1;
end;


Function WinBottom : Byte;
begin
  WinBottom := Hi(WindMax) + 1;
end;


Function RepeatStr(Str : String; N : Integer) : String;
Var
  Result : String;
  I, J,
  NewLen,
  Len    : Integer;
begin
  Len    := Length(Str);
  NewLen := N * Length(Str);
  Result[0] := Chr(NewLen);
  J := 1;
  For I := 1 to N DO
  begin
    Move(Str[1], Result[J], Len);
    Inc(J, Len);
  end;
  RepeatStr := Result;
end;


Procedure SetCursor(CType : CursType);
Var
  VM   : Byte;
  Regs : Registers;
begin
  VM := GetVidMode;
  With Regs DO
  Case CType OF
    NOCUR :
    begin
      Regs.CX := $2000;      { Off-screen cursor position }
      Regs.AH := 1;
    end;

    LINECUR : begin
      AX := $0100;
      BX := $0000;
      if MonoChrome(VM) then
        CX := $0B0C
      else
        CX := $0607
    end;

    BLOCKCUR :
    begin
      AX := $0100;
      BX := $0000;
      if MonoChrome(VM) then
        CX := $010D
      else
        CX := $0107;
    end;
  end;
  Intr($10, Regs);
end;


Function GetKey : Key;
Var
  Ch : Char;
begin
  Ch := ReadKey;
  if Ch = #0 then
  begin
    Ch := ReadKey;
    if Ch <= #127 then
      GetKey := Chr(Ord(Ch) or $80)
    else
    if Ch = #132 then
      GetKey := CtrlPgUp
    else
      GetKey := Null;
  end
  else
    GetKey := Ch;
end;

Procedure GetStr(XPos, YPos, MaxLen, Ink, Paper : Byte; AllowedKeys,
                 ExitKeys : KeySet; BeepOnError : Boolean;
                 Var Str : String; Var ExitKey : Key);
Var
  CursPos,
  LeftPos,
  TopPos,
  RightPos,
  BottomPos,
  X, Y        : ShortInt;
  InsFlag,
  OAFlag,
  FirstKey    : Boolean;
  InKey       : Key;
  OldTextAttr : Byte;
  OldWindMin,
  OldWindMax  : Word;

  Procedure CleanUp;
  { Second level; called when we leave }
  begin
    WindMin  := OldWindMin;
    WindMax  := OldWindMax;
    TextAttr := OldTextAttr;
    ExitKey  := InKey;
  end;

begin
  LeftPos   := WinLeft;
  RightPos  := WinRight;
  TopPos    := WinTop;
  BottomPos := WinBottom;
  X         := XPos + LeftPos - 1;
  Y         := YPos + TopPos - 1;
  InsFlag   := InsertStatus;
  if ExitKeys = [] then
    ExitKeys := [Enter, Escape];
  if AllowedKeys = [] then
    AllowedKeys := AllKeys;
 (* Save old settings here; restore them in proc CleanUp when Exiting *)
  OldWindMin := WindMin;
  OldWindMax := WindMax;
  WindMin := 0;             { Set Absolute Window co-ordinates and     }
  WindMax := $FFFF;         { prevent scroll at lower right Character. }
  OldTextAttr := TextAttr;
  TextAttr := ((Paper SHL 4) or Ink) and $7F;
  { Note: the 'AND $F' ensures that blink is off }
  if StartInFront then
    CursPos := 1
  else
  if Length(Str)+1 < MaxLen then
    CursPos := Length(Str) + 1
  else
    CursPos := MaxLen;
  FirstKey := True;
  if InsFlag then
    SetCursor(BLOCKCUR)
  else
    SetCursor(LINECUR);
  Repeat
    if CursPos < 1 then
      if WalkOut then
      begin
        CleanUp;
        Exit;
      end
      else
      if BeepOnError then
      begin
        NiceBeep;
        CursPos := 1;
      end;

    if (CursPos > Length(Str) + 1) then
      if WalkOut then
      begin
        CleanUp;
        Exit;
      end
      else
      if BeepOnError then
      begin
        NiceBeep;
        CursPos := Length(Str) + 1;
      end;

    if CursPos > MaxLen then
      if WalkOut and (InKey = Right) then
      begin
        CleanUp;
        Exit;
      end
      else
      begin
        if BeepOnError then
          NiceBeep;
        CursPos := MaxLen;
      end;

    GotoXY(X, Y);
    Write(Str + RepeatStr(BlankChar, MaxLen - Length(Str)));
    GotoXY(X + CursPos - 1, Y);
    InKey := GetKey;

    if InKey in ExitKeys then
    begin
      CleanUp;
      Exit;
    end;

    Case InKey OF
      Left              : Dec(CursPos);
      Right             : Inc(CursPos);
      CtrlLeft, Home    : CursPos := 1;
      CtrlRight, endKey : CursPos := Length(Str) + 1;
      Tab               : Inc(CursPos,8);
      ShiftTab          : Dec(CursPos,8);

      Ins :
      begin
        InsFlag := not InsFlag;
        if InsFlag then
          SetCursor(BLOCKCUR)
        else
          SetCursor(LINECUR);
      end;

      Del :
      if CursPos > Length(Str) then
      begin
        if BeepOnError then
          NiceBeep;
      end
      else
        Delete(Str, CursPos, 1);

      BSpace :
      if CursPos = 1 then
        if Length(Str) = 1 then
          Str := ''
        else
        begin
          if BeepOnError then
            NiceBeep;
        end
        else
        begin
          Delete(Str, CursPos - 1, 1);
          Dec(CursPos);
        end;
      else
      begin
        (* Note that 'AllowedKeys' that also have a
        * meaning as a control key have already been
        * processed, so they will not be handled here. *)
        if InKey in AllowedKeys then
        begin
          if ClearOnFirstChar and FirstKey then
          begin
            Str     := '';
            CursPos := 1;
          end;
          if (CursPos = MaxLen) then
          begin
            Str[CursPos] := InKey;
            Str[0]       := Chr(MaxLen);
          end
          else
          if InsFlag then
          begin
            Insert(InKey,Str,CursPos);
            if Length(Str) > MaxLen then
              Str[0] := Chr(MaxLen);
          end
          else
          begin
            Str[CursPos] := InKey;
            if CursPos > Length(Str) then
              Str[0] := Chr(CursPos);
          end;

          Inc(CursPos);
        end
        else
        if BeepOnError then
          NiceBeep;
      end;
    end;

    FirstKey := False;
  Until 0 = 1;
end;


Function WaitKey(LegalKeys : Keyset; Flush : Boolean) : Key;
Var
  K : Key;
begin
  if Flush then
    FlushKeybuf;
  Repeat
    K := GetKey;
  Until K in LegalKeys;
  WaitKey := K;
end;


begin
  BlankChar        := ' ';
  WalkOut          := False;
  ClearOnFirstChar := False;
  StartInFront     := False;
end.

