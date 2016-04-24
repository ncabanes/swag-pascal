(*
  Category: SWAG Title: PRINTING/PRINTER MANAGEMENT ROUTINES
  Original name: 0031.PAS
  Description: Bar Code Matrix Printers
  Author: MAYNARD PHILBROOK
  Date: 01-27-94  17:30
*)

{
From: MAYNARD PHILBROOK
Subj: Re: bar codes
---------------------------------------------------------------------------
 HB> I'm in need of bar code type code.   I want to print custom bar codes
 HB> and be able to scan them into an application.  I also want to be able
 HB> to do this directly from my application, not via a third party or a tsr
 HB> program.
}

{$F-,D-,S-,R-,V-,I-}
{  Prints 3 Of 9 Bar Codes other wise known as Code 39 }
{  May only work on EPSON or IBM Dot Matrix Printer !! }
Uses   Printer;
{$V-}
Const           { Set up Defalt Settings }
       Resolution:Byte = 2;            { Vertical Grid Width per Line }
        Hight    :Byte = 3;            { Number of rows to Print }
        Passes    :Byte = 2;           { Number for Passing for Darkness }
        Density   :Byte = 1;            { Printer Graphic Mode L or Z }
    Graphic_Mode:Array[1..2] of String[1] = ('L','Z');
    grid :array[0..43] of string[12] =
  ('110100101011',  {1}
   '101100101011',  {2}
   '110110010101',  {3}
   '101001101011',  {4}
   '110100110101',  {5}
   '101100110101',  {6}
   '101001011011',  {7}
   '110100101101',  {8}
   '101100101101',  {9}
   '101001101101',  {0}
   '110101001011',  {A}
   '101101001011',  {B}
   '110110100101',  {C}
   '101011001011',  {D}
   '110101100101',  {E}
   '101101100101',  {F}
   '101010011011',  {G}
   '110101001101',  {H}
   '101101001101',  {I}
   '101011001101',  {J}
   '110101010011',  {K}
   '101101010011',  {L}
   '110110101001',  {M}
   '101011010011',  {N}
   '110101101001',  {O}
   '101101101001',  {P}
   '101010110011',  {Q}
   '110101011001',  {R}
   '101101011001',  {S}
   '101011011001',  {T}
   '110010101011',  {U}
   '100110101011',  {V}
   '110011010101',  {W}
   '100101101011',  {X}
   '110010110101',  {Y}
   '100110110101',  {Z}
   '100101011011',  {-}
   '110010101101',  {.}
   '100110101101',  { }
   '100101101101',  {*}
   '100100100101',  {'$'}
   '100100101001',  {/}
   '100101001001',  {+}
   '101001001001');  {%}
Function Get_Grid(Yup:Char):String;   { Translations Function }
Var
PT     :Word;
Begin
       Get_Grid := '';
       Case Yup Of
        '1'..'9':Get_Grid := Grid[ Ord( Yup) -$31];
        '0'    :Get_Grid := Grid[9];
        'A'..'Z':Get_Grid := Grid[10+Ord(Yup)-65];
         '-'   :Get_Grid := Grid[36];
         '.'   :Get_grid := Grid[37];
         ' '   :Get_Grid := Grid[38];
         '*'   :Get_Grid := Grid[39];
         '$'   :Get_Grid := Grid[40];
         '/'   :Get_Grid := Grid[41];
         '+'   :Get_Grid := Grid[42];
         '%'   :Get_Grid := Grid[43];
         End;
End;
Procedure Send_Char(Yup :Char);
Var
Hold   :String;
L, G   :Word;
Out_Bar :Byte;
Begin

 Hold := Get_Grid(Upcase(Yup));
 If Hold <> '' Then
  Begin
   Write(Lst,#27,Graphic_Mode[ Density ]);         { Printer in Graph Mode }
   Write(Lst,Char((Resolution * 12)+Resolution),#0); { How many Bytes ?}
   For L := 1 To 12 Do   { All 12 Chars }
    Begin
     If Hold[L] ='1' Then Out_bar := 255 Else Out_bar := 0;
     For G := 1 To Resolution Do Write(Lst, Char(Out_Bar));
    End;
   For L := 1 To Resolution Do Write(Lst, #0); { Charactor Separator }
  End;
End;

Var
 Number_IN :String[15];
 L,LC, DS  :Word;
 T        :Byte;
Begin
 Val(ParamStr(1), T, DS        );   { Adjust Parameters if Needed }
 If DS = 0 Then Resolution := T;    { Width Ratio }
 Val(ParamStr(2), T, DS );
 If DS = 0 Then Hight := T;         { Vertical Size of Label }
 Val(ParamStr(3), T, DS );
 If DS = 0 THen Passes := T;        { For Darkness adjust }
 Val(ParamStr(4), T, DS );
 If (DS = 0)and( T in [1..2]) Then Density := T;  { Printer Mode }
 Repeat
  ReadLn(Number_IN);
   If Number_IN <> '' Then
    Begin
     Write(Lst,#27+'1');    { Set  7/72 Line Spacing }
      For LC := 1 to Hight Do   {Hight Loop }
       Begin
        For DS := 1 To Passes Do   { Double Strike }
         Begin
          Send_Char('*');     { Must Create a '*' @ start & end }
          For L := 1 To Byte(Number_IN[0]) Do Send_Char(Number_IN [ L ]);
          Send_Char('*');
          Write(Lst,#13);
         End;
        If Lc < Hight Then WriteLn(Lst) else WriteLn(Lst,#27,'2');
       End;
     { Print Number underneath Bars in center or close to it any ways }
     WriteLn(Lst,' ':Resolution,Number_IN:((Byte(Number_IN[0])*(Resolution Div (Byte(Number_In[0])) div 2))));
    End;
Until Number_In = '';
End.

