{
From: CYRUS PATEL
Subj: Stuff...
>Does anyone have either ASM or TP (7.0) code to do vga scrolling, ie as
in BBS demos, loaders...

------------------------ SWAG snippet ---------------------------
{
 Here is some demo code showing how to use Smooth.Obj.  It offers
 vertical and horizontal smooth scrolling in Text or Graphics modes.

 NOTE:      Requires Smooth.Obj (see below)   EGA & VGA ONLY !!!!

 REQUIRES:  Smooth.Obj  Run the debug script through DEBUG to create
            Smooth.Obj.  The NEXT message has the debug script.

 ALSO:      Until last week, I'd never seen a line of Pascal code.
            So ForGIVE the rough edges of this code:  bear in mind
            the Complete novice status of its author <!!G!!>           }

Uses Crt;

{ NOTE:  SmoothScroll is a MEDIUM MODEL Asm/OBJ For use in
         **either** Pascal or most flavors of modern BASIC.

         It expects parameters to be passed by reference!  We handle
         that here by not including Var, then passing Ofs(parameter).

         Don't know if this is appropriate, but it works. Comments?   }

{$F+} Procedure SmoothScroll(Row, Column: Integer); external; {$F-}
{$L Smooth.Obj}

Var
   Row, Col, Speed, WhichWay : Integer;
   Ch : Char;
   s  : String [60];

begin
   TextColor (14); TextBackground (0); ClrScr;

   GotoXY (25,4);  Write ('Press <Escape> to move on.');

   ch := 'A';
   For Row := 10 to 24 do
       begin
         FillChar (s, Sizeof(s), ch);
         s[0] := #60;  Inc (ch);
         GotoXY (10, Row); Write (s);
       end;

   Speed := 1;                         { Change Speed!  See notes. }

   {The higher the Speed, the faster the scroll.
        Use Speed = 1 For subtle scrolling.
        Try Speed = 5 (10 in Graphics) For very fast scrolling.
        Try Speed = 10+ (25 in gfx) to see some **Real shaking**.

        Even in Text mode here, Row and Column use GraphICS MODE
        pixel coordinates (ie., begin w/ 0,0).   }

   {================================= demo vertical smooth scrolling}
   Row := 0; Col := 0;
   WhichWay := Speed;                   { start by going up }

   Repeat                               { press any key to end demo }
      GotoXY (2,10);  Write (Row, ' ');
      SmoothScroll(ofs(Row), ofs(Col));
      Row := Row + WhichWay;

      if (Row > 150) or (Row < 2) then  { try 400 here }
         WhichWay := WhichWay * -1;     { reverse direction }

      if Row < 1 then Row := 1;

   Until KeyPressed;

   ch := ReadKey; Row := 0; Col := 0;
   SmoothScroll ( ofs(Row), ofs(Col) ); { return to normal (sort of) }

   {================================= demo horizontal smooth scrolling}
   Row := 0; Col := 0;
   WhichWay := Speed;                   { start by going left }

   Repeat                               { press any key to end demo }
      GotoXY (38,3); Write (Col, ' ');
      SmoothScroll(ofs(Row), ofs(Col));
      Col := Col + WhichWay;

      if (Col > 65) or (Col < 0) then   { try 300 here }
         WhichWay := WhichWay * -1;     { reverse direction }
      if Col < 0 then Col := 0;
   Until KeyPressed;

   Row := 0; Col := 0; SmoothScroll(ofs(Row), ofs(Col));
end.

{ Capture the following to a File (eg. S.Scr).
 then:    DEBUG < S.SCR.

 Debug will create SMOOTH.OBJ.

 N SMOOTH.OBJ
 E 0100 80 0E 00 0C 73 6D 74 68 73 63 72 6C 2E 61 73 6D
 E 0110 87 96 27 00 00 06 44 47 52 4F 55 50 0D 53 4D 54
 E 0120 48 53 43 52 4C 5F 54 45 58 54 04 44 41 54 41 04
 E 0130 43 4F 44 45 05 5F 44 41 54 41 90 98 07 00 48 89
 E 0140 00 03 05 01 87 98 07 00 48 00 00 06 04 01 0E 9A
 E 0150 04 00 02 FF 02 5F 90 13 00 00 01 0C 53 4D 4F 4F
 E 0160 54 48 53 43 52 4F 4C 4C 00 00 00 A7 88 04 00 00
 E 0170 A2 01 D1 A0 8D 00 01 00 00 55 8B EC 06 56 33 C0
 E 0180 8E C0 8B 76 08 8B 04 33 D2 26 8B 1E 85 04 F7 F3
 E 0190 8B D8 8B CA 26 A1 4A 04 D0 E4 F7 E3 8B 76 06 8B
 E 01A0 1C D1 EB D1 EB D1 EB 03 D8 26 8B 16 63 04 83 C2
 E 01B0 06 EC EB 00 A8 08 74 F9 EC EB 00 A8 08 75 F9 26
 E 01C0 8B 16 63 04 B0 0D EE 42 8A C3 EE 4A B0 0C EE 42
 E 01D0 8A C7 EE 4A 83 C2 06 EC EB 00 A8 08 74 F9 83 EA
 E 01E0 06 B0 08 EE 8A C1 42 EE 83 C2 05 EC BA C0 03 B0
 E 01F0 33 EE 8B 76 06 8B 04 24 07 EE 5E 07 8B E5 5D CA
 E 0200 04 00 F5 8A 02 00 00 74
 RCX
 0108
 W
 Q

'========  end of Debug Script ========
