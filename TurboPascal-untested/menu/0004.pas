(*
  [ NOTES ]

  -- Desc --
    RmMenu has been created to allow easy, fast, and efficient menu's
    that are very versatile and configurable to be created without
    the usual amount of bulky, cryptic code and time consuming
    initialization, in fact, RmMenu uses and needs NO initalization
    of any variables.


  -- Legal --
    RmMenu was created by Brad Zavitsky and all rights are reserved.

    Use at your own risk, the author(s) will not take any responsibility.

    SWAG use and commercial use is fine, RmMenu is FreeWare.

    Use of RmMenu is allowed free of charge provided that the CopyRight
    procedure is not altered and is not removed at the initialization
    part of the unit and optionally credit is given to me, the author
    for the unit.


  -- Switches --
    DEBUG : Define this to use the compiler directives for use with
            debugging.  RmMenu has already been debugged so you should
            not have to use this at all.

    FASTW : This is on by default, remove it below to use CRT's slower
            writes instead of the special FASTWRITE procedure.


 -- Info --
   Code size      : 1121 bytes
   Data size      : 0 bytes
   Stack size     : 0 bytes
   Min heap       : 0 bytes
   Max heap       : 0 bytes

*)

{$DEFINE FASTW}

{$IFDEF DEBUG}
{$A+,B-,D+,F-,G-,I+,K-,L+,N-,O-,E-,P-,Q+,R+,S+,T-,V-,W-,X+,Y-}
{$ELSE}
{$A+,B-,D-,F-,G-,I-,K-,L-,N-,O-,E-,P-,Q-,R-,S-,T-,V-,W-,X+,Y-}
{$ENDIf}

Unit RmMenu;

Interface

Uses Crt;

Const
 Max_Choices = 10;

Type  Menu_Typ = Record
                  Options  : array[1..max_choices] of string[20];
                  Key      : array[1..max_choices] of char;
                  X        : array[1..max_choices] of byte;
                  Y        : array[1..max_choices] of byte;
                  Num_Opt  : byte;
                  Hi_Col   : byte;
                  Norm_Col : byte;
                  HotKey   : boolean; { This option allows a choice to be higlighted by pressing it's KEY }
                  HotExit  : boolean; { This option allows exit on HotKey }
                 End;

  Procedure Menu(Menu_Dat : Menu_Typ; Var CChoice : Byte;Change : Boolean);
  far;

Implementation

Procedure Copyright; Near; Assembler;
{ This MAY NOT be removed }
 asm
   JMP @@1
   DB 13,10,'RmMenu Unit (C)1995 by Brad Zavitsky.  All rights reserved.',13,10
 @@1:
 end;


PROCEDURE FastWrite(Col, Row, Attr : Byte; Str : String); NEAR; ASSEMBLER;
{ This procedure is the only one which is not mine }
  ASM
    PUSH   DS           {Save DS}
    MOV    DL,CheckSnow {Save CheckSnow Setting}
    MOV    ES,SegB800   {ES = Colour Screen Segment}
    MOV    SI,SegB000   {SI = Mono Screen Segment}
    MOV    DS,Seg0040   {DS = ROM Bios Segment}
    MOV    BX,[49h]     {BL = CRT Mode, BH = ScreenWidth}
    MOV    AL,Row       {AL = Row No}
    MUL    BH           {AX = Row * ScreenWidth}
    XOR    CH,CH        {CH = 0}
    MOV    CL,Col       {CX = Column No}
    ADD    AX,CX        {(Row*ScreenWidth)+Column}
    ADD    AX,AX        {Multiply by 2 (2 Byte per Position)}
    MOV    DI,AX        {DI = Screen Offset}
    CMP    BL,7         {CRT Mode = Mono?}
    JNE    @@DestSet    {No  - Use Colour Screen Segment}
    MOV    ES,SI        {Yes - ES = Mono Screen Segment}
    XOR    DX,DX        {Force jump to FWrite}
  @@DestSet:            {ES:DI = Screen Destination Address}
    LDS    SI,Str       {DS:SI = Source String}
    CLD                 {Move Forward through String}
    LODSB               {Get Length Byte of String}
    MOV    CL,AL        {CX = Input String Length}
    JCXZ   @@Done       {Exit if Null String}
    MOV    AH,Attr      {AH = Attribute}
    OR     DL,DL        {Test Mono/CheckSnow Flag}
    JZ     @@FWrite     {Snow Checking Disabled or Mono - Use FWrite}
{Output during Screen Retrace's}
    MOV    DX,003DAh    {6845 Status Port}
  @@WaitLoop:           {Output during Retrace's}
    MOV    BL,[SI]      {Load Next Character into BL}
    INC    SI           {Update Source Pointer}
    CLI                 {Interrupts off}
  @@Wait1:              {Wait for End of Retrace}
    IN      AL,DX       {Get 6845 status}
    TEST    AL,8        {Vertical Retrace in Progress?}
    JNZ     @@Write     {Yes - Output Next Char}
    SHR     AL,1        {Horizontal Retrace in Progress?}
    JC      @@Wait1     {Yes - Wait until End of Retrace}
  @@Wait2:              {Wait for Start of Next Retrace}
    IN      AL,DX       {Get 6845 status}
    SHR     AL,1        {Horizontal Retrace in Progress?}
    JNC     @@Wait2     {No - Wait until Retrace Starts}
  @@Write:              {Output Char and Attribute}
    MOV     AL,BL       {Put Char to Write into AL}
    STOSW               {Store Character and Attribute}
    STI                 {Interrupts On}
    LOOP   @@WaitLoop   {Repeat for Each Character}
    JMP    @@Done       {Exit}
{Ignore Screen Retrace's}
  @@FWrite:             {Output Ignoring Retrace's}
    TEST   SI,1         {DS:SI an Even Offset?}
    JZ     @@Words      {Yes - Skip (On Even Boundary)}
    LODSB               {Get 1st Char}
    STOSW               {Write 1st Char and Attrib}
    DEC    CX           {Decrement Count}
    JCXZ   @@Done       {Finished if only 1 Char in Str}
  @@Words:              {DS:SI Now on Word Boundary}
    SHR    CX,1         {CX = Char Pairs, Set CF if Odd Byte Left}
    JZ     @@ChkOdd     {Skip if No Pairs to Store}
  @@Loop:               {Loop Outputing 2 Chars per Loop}
    MOV    BH,AH        {BH = Attrib}
    LODSW               {Load 2 Chars}
    XCHG   AH,BH        {AL = 1st Char, AH = Attrib, BH = 2nd Char}
    STOSW               {Store 1st Char and Attrib}
    MOV    AL,BH        {AL = 2nd Char}
    STOSW               {Store 2nd Char and Attrib}
    LOOP   @@Loop       {Repeat for Each Pair of Chars}
  @@ChkOdd:             {Check for Final Char}
    JNC    @@Done       {Skip if No Odd Char to Display}
    LODSB               {Get Last Char}
    STOSW               {Store Last Char and Attribute}
  @@Done:               {Finished}
    POP    DS           {Restore DS}
END;


  Procedure Hilight(Menu_Dat : Menu_Typ; ChoiceNum : byte); Near;
    Begin
    With Menu_Dat do
    {$IFDEF FASTW}
      FastWrite(X[ChoiceNum],Y[ChoiceNum],Hi_Col,Options[choiceNum]);
    {$ELSE}
     Begin
      Gotoxy(X[choiceNum],Y[ChoiceNum]);
      TextAttr := Hi_Col;
      Write(Options[ChoiceNum]);
     End;{With Menu_Dat}
    {$ENDIF}
    End;

  Procedure UnHilight(Menu_Dat : Menu_Typ; ChoiceNum : byte); Near;
    Begin
    With Menu_Dat do
    {$IFDEF FASTW}
      FastWrite(X[ChoiceNum],Y[ChoiceNum],Norm_Col,Options[choiceNum]);
    {$ELSE}
     Begin
      Gotoxy(X[choiceNum],Y[ChoiceNum]);
      TextAttr := Norm_Col;
      Write(Options[ChoiceNum]);
     End;{With Menu_Dat}
    {$ENDIF}
    End;

  Procedure ShowMenu(Menu_Dat : Menu_Typ); Near;
   Var B : Byte;
    Begin
      For B := 1 to Menu_Dat.Num_Opt do unhilight(Menu_Dat,B);
    End;

  Function HotKeyFound(Menu_Dat : Menu_Typ; Ch : Char) : byte; Near;
   Var B : Byte;
    Begin
      HotKeyFound := 0; {Not found}
      CH := UpCase(Ch);
      For B := 1 to menu_dat.num_opt do
       Begin
          if upcase(Menu_Dat.key[b]) = CH then
           Begin
              HotKeyFound := B;
              Exit;
           End;
      End;
    End;

  Procedure Menu(Menu_Dat : Menu_Typ; Var CChoice : Byte;Change : Boolean);
  { returns choice, 0 if <Esc> or Tab ; }
  { Change means allow change field, ie.. Allows TAB/ESC to end }
   Var
     Ch : Char;
     Done : Boolean;
     oldC, B   : Byte;
    Begin
       Done := False;
       IF (CCHoice = 0) or (CChoice > Menu_Dat.num_Opt) then CChoice := 1;
       OldC := CChoice;
       ShowMenu(Menu_Dat);
       Hilight(menu_dat, CChoice);
       Repeat
         Ch := Readkey;
         If CH = #0 then
          Begin{function key}
            CH := Readkey;
            If CH=#77 then CH:=#80;
            IF CH=#75 then CH:=#72;

            Case CH of
              #72 : {Up}
                   If CChoice > 1 then
                    begin
                     unhilight(menu_dat, CChoice);
                     dec(CChoice);
                    End Else
                     Begin
                      unhilight(menu_dat, CChoice);
                      CChoice := menu_dat.num_opt;
                     End;

              #80 : {Down}
                   If CChoice < Menu_Dat.num_opt then
                    begin
                     unhilight(menu_dat, CChoice);
                     inc(CChoice);
                    End Else
                     Begin
                      unhilight(menu_dat, CChoice);
                      CChoice := 1;
                     End;

              #71 : {Home}
                   If CChoice <> 1 then
                    begin
                     unhilight(menu_dat, CChoice);
                     CChoice := 1;
                    End;

              #79 : {End}
                   If CChoice < Menu_Dat.Num_Opt then
                    begin
                     unhilight(menu_dat, CChoice);
                     CChoice := Menu_Dat.Num_Opt;
                    End;

            End;{Case}
          End Else
          Case CH of
            #27,#9 : If Change then
                  Begin
                   CChoice := 0;
                   Exit;
                  End;
            #13 :
                  Begin
                   Exit;
                  End;
           Else if menu_dat.hotkey then
            Begin
             B := HotKeyFound(Menu_Dat, ch);
             If (B <> 0) then
              Begin
               If (B <> CChoice) then
                Begin
                 Unhilight(menu_dat, CChoice);
                 CChoice := B;
                 HiLight(Menu_dat,CChoice);
                 OldC := CChoice;
                End;{(B <> CChoice)}
               If menu_dat.hotexit then Exit;
              End;{ (B <> 0) }
            End; { menu_dat.hotkey }
          End;{Case}
       If OldC <> CChoice then HiLight(Menu_Dat, CChoice);
       OldC := CChoice;
       Until Done;
    End;


Begin
 Copyright;
End.


--[ Sample Program ]--

Program test;
Uses Crt, RMMENU;

Var
 MenuC : Menu_Typ;
 B : byte;
 TempS : String;

begin

 With MenuC do
  Begin

   options[1] := 'Continue';
   options[2] := 'Quit';
   options[3] := 'Abort';
   key[1] := 'C';
   key[2] := 'Q';
   key[3] := 'A';
   y[1] := 2;
   y[2] := y[1];
   y[3] := y[1];
   x[1] := 2;
   x[2] := X[1] + length(options[1])+1;
   x[3] := x[2] + length(options[2])+1;
   Num_Opt := 3;
   Hi_Col := 30;
   HotKey := True;  {This allows one keypress picks}
   HotExit := False;  {This allows to exit on Hotkey}
   Norm_Col := 31;
  End;

 TextAttr := 80;
 ClrScr;
 B := 1;
 Repeat
  Menu(MenuC, B, True);
 Until B <> 1;
 writeln;
 Writeln;
 If B <> 0 then Writeln('You have picked choice number ', B,'.')
  else writeln('You have either pressed <ESC> or TAB to change fields');
 Readln;
End.
