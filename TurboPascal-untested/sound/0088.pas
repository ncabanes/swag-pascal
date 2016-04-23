{
                         -- Adlib Unit  --
 
                         1995 - CJ Cliffe
               Programmer's Reference BBS - 382-8503
 
        Note --  This Unit is not an EXACT Sound() emulation,
         Sound(); is emulated as close as possible, and will
                  sound remarkably like Sound();
 
 
               This file is most welcome in SWAG!!  ;->
 
               The  _SB functions are by Cathy Nicoloff       }
 
       {------------------------------------------------------}
       {--                  }Unit ADLIB;{                   --}
       {------------------------------------------------------}
       {--                   }Interface{                    --}
       {------------------------------------------------------}
 
Uses Crt;
 
Procedure Play_SB(N, M : Byte);
Procedure Init_SB;
Procedure Reset_SB;
Function  Detect_SB : Boolean;
 
Procedure ADLSound(Hz: Longint);
Procedure AdlNoSound;
 
Var Inited : Boolean;
 
Implementation
 
Const
SBNotes   : Array[1..12] Of Byte =
      ($AE, $6B, $81, $98, $B0, $CA, $E5, $02, $20, $41, $63, $87);
SBOctaves : Array[1..84] Of Byte =
      ($22, $25, $25, $25, $25, $25, $25, $26, $26, $26, $26, $26,
       $26, $29, $29, $29, $29, $29, $29, $2A, $2A, $2A, $2A, $2A,
       $2A, $2D, $2D, $2D, $2D, $2D, $2D, $2E, $2E, $2E, $2E, $2E,
       $2E, $31, $31, $31, $31, $31, $31, $32, $32, $32, $32, $32,
       $32, $35, $35, $35, $35, $35, $35, $36, $36, $36, $36, $36,
       $36, $39, $39, $39, $39, $39, $39, $3A, $3A, $3A, $3A, $3A,
       $3A, $3D, $3D, $3D, $3D, $3D, $3D, $3E, $3E, $3E, $3E, $3E);
Notes     : Array[1..84] Of Integer =
    { C    C#,D-  D    D#,E-  E     F    F#,G-  G    G#,A-  A    A#,B-  B  }
    (0065, 0070, 0073, 0078, 0082, 0087, 0093, 0098, 0104, 0110, 0117, 0123,
     0131, 0139, 0147, 0156, 0165, 0175, 0185, 0196, 0208, 0220, 0233, 0247,
     0262, 0277, 0294, 0311, 0330, 0349, 0370, 0392, 0415, 0440, 0466, 0494,
     0523, 0554, 0587, 0622, 0659, 0698, 0740, 0784, 0831, 0880, 0932, 0987,
     1047, 1109, 1175, 1245, 1329, 1397, 1480, 1568, 1661, 1760, 1865, 1976,
     2093, 2217, 2349, 2489, 2637, 2794, 2960, 3136, 3322, 3520, 3729, 3951,
     4186, 4435, 4699, 4978, 5274, 5588, 5920, 6272, 6645, 7040, 7459, 7902);
(***********************)
Procedure Play_SB(N, M : Byte);
Var Loop  : Integer; Temp  : Integer;
Begin
  Port[$0388] := N;
  For Loop := 1 To 6 Do Temp := Port[$0388];
  Port[$0389] := M;
  For Loop:=1 To 35  Do Temp := Port[$0388];
End;
(***********************)
Procedure Init_SB;
Var  A : Integer;
Begin
 For A := 1 to 244 Do  Play_SB(A,$00);
 Play_SB($01,32);   Play_SB($B0,$11);
 Play_SB($04,$60);  Play_SB($04,$80);
End;
(***********************)
Procedure Reset_SB;
Begin
   Play_SB($20,$41);   Play_SB($40,$10);
   Play_SB($60,$F0);   Play_SB($80,$77);
   Play_SB($23,$41);   Play_SB($43,$00);
   Play_SB($63,$F0);   Play_SB($83,$77);
   Play_SB($BD,$10);
End;

(***********************)
Function Detect_SB : Boolean;
Var
   Dummy1,
   Dummy2  : Byte;
Begin
   Play_SB($04,$60);   Play_SB($04,$80);
   Dummy1 := Port[$388];
   Play_SB($02,$FF);   Play_SB($04,$21);   Delay(8);
   Dummy2 := Port[$388];
   Play_SB($04,$60);   Play_SB($04,$80);
   If ((Dummy1 AND $E0) = $00) And ((Dummy2 AND $E0) = $C0) Then
   Detect_SB := True    Else   Detect_SB := False;
End;
(*********My Stuff Starts here***********)
Procedure ADLSound(Hz: Longint);
Var  Noteval,Notecomp: LongInt;
Begin
  If Not Inited then begin         { If Adlib is still Deinited, Init it! }
   Init_SB;                        { Inits the Adlib  }
  Reset_SB;                        { Clears the Adlib }
   Inited := True;                 { Stops from Re-Initing more than once }
  End;
  For Noteval := 1 to 84 do Begin                 { Find the closest note }
    Notecomp := Noteval;                   {  Keep a copy for the Octaves }
      If Hz < Notes[Noteval] then begin              { Found that's close }
        {^^^^^^^^^^^^^^^^^^^  If it doesn't make sense, just take my word }
                                                  {       for it..        }
          While Noteval > 12 do dec(Noteval,12);  { Decrease it to a Note }
          Play_SB($A0,   SBnotes[Noteval]  );     {   Output Note value   }
          Play_SB($B0, Sboctaves[Notecomp] );     {  Tell it what octave  }
          Exit;                                   { Quit the NOTEVAL loop }
      End;
   End;
End;
 
Procedure AdlNoSound;  { Not good for loops !! }
Begin
  Init_Sb;
  Reset_Sb;
End;


Begin
Inited := False;
End.
