(*
  Category: SWAG Title: MENU MANAGEMENT ROUTINES
  Original name: 0017.PAS
  Description: Vertical Menu Unit
  Author: AVONTURE CHRISTOPHE
  Date: 03-04-97  13:18
*)

{

   Vertical menu unit.

   You can find my horizontal menu unit in the SWAG (since November 96).


               ╔════════════════════════════════════════╗
               ║                                        ║░
               ║          AVONTURE CHRISTOPHE           ║░
               ║              AVC SOFTWARE              ║░
               ║     BOULEVARD EDMOND MACHTENS 157/53   ║░
               ║           B-1080 BRUXELLES             ║░
               ║              BELGIQUE                  ║░
               ║                                        ║░
               ╚════════════════════════════════════════╝░
               ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░


    This is one of my very best unit.  Please send me a postcard if you find
    it usefull.  Thanks in advance!

    ==> Hey, is there somebody  in the United States of America?  I have <==
    ==> received postcard from severall country but none from the States <==
    ==>                           Be the first!                          <==

}

Unit Menu;

Interface

Uses Crt;

Type TCadre     = Array [1..8] of Char;

Const Choixxx   : Byte = 0;
      Double    : Tcadre = ('╔','═','╗','║','║','╚','═','╝'); { Cadre }

Var TMenu, TMenu2 : Array [1..25,1..2] of string[80];

{ Show a menu option.  Equivalent of @X,Y Prompt "Texte" of Clipper
}

Procedure Prompt (X,Y : Word; Option, Aide : String);

{ This function allowed the selection of an option.  You must first call
  the Prompt procedure and display all wanted options.  Then the MChoix
  function will made everything.

  If the user press the escape Key, the result will be 255
                        F1 key                         59
                        F2                             60
                        ..
                        F10                            68

  The return result is the index of the option in the TMenu array
}

Function MChoix (X, Y, Nombre : Word) : Byte;

{ This procedure show an animated line at the specified screen coordinates

  For example,
     Scroll (25, 10, 70, 'You are a very good Pascal Programmer');
}

Procedure Scroll (X, Y0, Y1 : Byte; Texte : String);

{ Draw a cadre
}

Procedure Cadre (ColD, LigD, ColF, LigF, Attr, Back : Byte; Cad : TCadre);

{ Write a string at the specified screen coordinates and with the given
  color attribut
}

Procedure WriteStrXY (X, Y, TAttr, TBack : Word; Texte : String);

Implementation

Var
   TextBack  : Byte;
   Ch        : Char;
   sBlankLine: String;

{ Draw a cadre
}

Procedure Cadre (ColD, LigD, ColF, LigF, Attr, Back : Byte; Cad : TCadre);

Var
   X, Y, I, Longueur, Hauteur : Byte;
   sLine : String;

Begin

     X := WhereX;  Y := WhereY;
     Longueur := (ColF-ColD)-1;
     Hauteur  := (LigF-LigD)-1;

     WriteStrXy (ColD, LigD, Attr, Back, Cad[1]);

     FillChar (sLine[1], Longueur, Cad[2]);
     sLine [0] := Chr(Longueur);
     WriteStrXy (ColD+1, LigD, Attr, Back, sLine);

     WriteStrXy (ColD+1+Longueur, LigD, Attr, Back, Cad[3]);

     For i:= 1 To Hauteur Do Begin
         WriteStrXy (ColD, LigD+I, Attr, Back, Cad[4]);

         FillChar (sLine[1], Longueur, ' ');
         sLine [0] := Chr(Longueur);
         WriteStrXy (ColD+1, LigD+I, Attr, Back, sLine);

         WriteStrXy (ColD+1+Longueur, LigD+I, Attr, Back, Cad[5]);
     End;

     WriteStrXy (ColD, LigF, Attr, Back, Cad[6]);

     FillChar (sLine[1], Longueur, Cad[7]);
     sLine [0] := Chr(Longueur);
     WriteStrXy (ColD+1, LigF, Attr, Back, sLine);

     WriteStrXy (ColD+1+Longueur, LigF, Attr, Back, Cad[8]);

     GotoXy (X, Y);

End;

{ Write a string at the specified screen coordinates and with the given
  color attribut
}

Procedure WriteStrXY (X, Y, TAttr, TBack : Word; Texte : String);

Var Offset   : Word;
    i        : Byte;
    Attr     : Word;

Begin

    offset := Y * 160 + X Shl 1;
    Attr := ((TAttr+(TBack Shl 4)) shl 8);

    For i:= 1 to Length (Texte) do Begin
        MemW[$B800:Offset] := Attr or Ord(Texte[i]);
        Inc (Offset,2);
    End;

End;

{ Show a menu option.  Equivalent of @X,Y Prompt "Texte" of Clipper
}

Procedure Prompt (X,Y : Word; Option, Aide : String);
Begin
   WriteStrXy (X,Y, TextAttr,TextBack,Option);
   WriteStrXy (0,24,TextAttr,TextBack,sBlankLine);
   WriteStrXy (2,24,TextAttr,TextBack,Aide);
End;

{ This function allowed the selection of an option.  You must first call
  the Prompt procedure and display all wanted options.  Then the MChoix
  function will made everything.

  If the user press the escape Key, the result will be 255
                        F1 key                         59
                        F2                             60
                        ..
                        F10                            68

  The return result is the index of the option in the TMenu array
}

Function MChoix (X, Y, Nombre : Word) : Byte;

Begin

    GotoXy (X, Y+Choixxx-1);
    TextBack := 5;
    Repeat
        Prompt (X, Y+Choixxx, TMenu [Choixxx+1,1], TMenu [Choixxx+1,2]);
        TextBack := 1;
        Ch := Readkey; If Ch = #0 then Ch := Readkey;
        Prompt (X, Y+Choixxx, TMenu [Choixxx+1,1], TMenu [Choixxx+1,2]);
        TextBack := 05;
        If (Ch = #72) then begin
          If Not (Choixxx = 0) then Begin
            GotoXy (X,Y-1);                                          {UpKey}
            Dec (choixxx);
          End
          Else Begin
            Choixxx := Nombre - 1;
            GotoXy (X,Y+Choixxx);
          End
        End
        Else If (Ch = #80) then begin
          If not (Choixxx = Nombre-1) then Begin
            GotoXy (X,Y+1);
            Inc (Choixxx);                                          {DownKey}
          End
          Else Begin
            Choixxx := 0;
            GotoXy (X,Y);
          End
        End
        Else If (Ch = #71) then Begin
           GotoXy (X,Y);                                               {Home}
           Choixxx := 0;
        End
        Else If (Ch = #79) then Begin
           GotoXy (X,Y+Nombre);                                         {End}
           Choixxx := Nombre-1;
        End;
    Until ((ch = #13) or (ch = #27) or (Ch in [#59..#68]));
    If Ch = #27 then MChoix := 255
    Else If Ch in [#59..#68] then MChoix := Ord(Ch)
    Else MChoix := Choixxx + 1;

End;

{ This procedure show an animated line at the specified screen coordinates

  For example,
     Scroll (25, 10, 70, 'You are a very good Pascal Programmer');
}

Procedure Scroll (X, Y0, Y1 : Byte; Texte : String);

Type TCell = Record
         C : Char;
         A : Byte;
     End;
     TScreen = array[1..25, 1..80] of TCell;

Var Scr    : TScreen Absolute $B800:0;
    I, J   : Byte;
    Tour   : LongInt;

Begin

   I := 1;
   Repeat
     While (port[$3da] and 8) <> 0 Do;  { wait retrace }
     While (port[$3da] and 8) = 0 Do;
     For J := Y0 To (Y1-1) Do
        Scr[X, J] := Scr[X, J+1];  { shift cell left }
     Scr[X, Y1].C := Texte[I];      { add new cell }
     Scr[X, Y1].A := 14 + (1 * 16);
     I := 1 + (I mod Length(Texte));
   Until Keypressed;

End;

Begin
   FillChar (sBlankLine[1], 80, ' ');
   sBlankLine[0] := #80;
End.

{ ----------------------------- cut here --------------------------------- }
{

   Example of the vertical menu unit


               ╔════════════════════════════════════════╗
               ║                                        ║░
               ║          AVONTURE CHRISTOPHE           ║░
               ║              AVC SOFTWARE              ║░
               ║     BOULEVARD EDMOND MACHTENS 157/53   ║░
               ║           B-1080 BRUXELLES             ║░
               ║              BELGIQUE                  ║░
               ║                                        ║░
               ╚════════════════════════════════════════╝░
               ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

}

Uses Crt, Menu;

Const
    TextColor = 15;   { Color Fore and Back color }
    BackColor = 01;

Var Choix, I : Byte;
    Lig      : String;

Begin

   { Draw the screen }

   TextAttr := TextColor + (BackColor Shl 4);

   ClrScr;

   Cadre  (02, 01, 78, 05, TextColor, BackColor, Double);

   WriteStrXy (04, 03, TextColor, BackColor, 'Vertical Unit Menu Sample.');
   WriteStrXy (04, 04, TextColor, BackColor, 'Try the '+
               'horizontal Menu Unit of AVONTURE Christophe -see in the SWAG- ');

   Cadre (41, 07, 78, 20, TextColor, BackColor, Double);

   WriteStrXy (43, 09, TextColor, BackColor,
              'This is a little example to show');

   WriteStrXy (43, 10, TextColor, BackColor, 'you the feature of the menu unit.');

   WriteStrXy (43, 13, TextColor, BackColor,
               'This menu unit has been written by');

   WriteStrXy (50, 14, TextColor, BackColor, 'AVONTURE Christophe');

   Cadre (02, 07, 38, 15, TextColor, BackColor, Double);

   WriteStrXy (00, 24, TextColor, BackColor, ' ');

   { Set the menu option.  The first index is the option and the second, the
     help line
   }

   TMenu [1,1] := 'This is the first option';
   TMenu [1,2] := 'This option can be used in order to ...    :=) ';
   TMenu [2,1] := 'Send a postcard';
   TMenu [2,2] := '... for me?  This idea is very good!  I wait news from you...';
   TMenu [3,1] := 'This unit is great, isn''t it?';
   TMenu [3,2] := 'Happy to see that you can find this unit usefull...';
   TMenu [4,1] := 'Nice to meet you';
   TMenu [4,2] := 'Hello, How are you?';
   TMenu [5,1] := 'Terminate this example';
   TMenu [5,2] := 'You can also use the Escape key';

   { Put the options on the screen: Column, line, option, help.
   }

   Prompt (04, 09, TMenu [1,1], TMenu [1,2]);
   Prompt (04, 10, TMenu [2,1], TMenu [2,2]);
   Prompt (04, 11, TMenu [3,1], TMenu [3,2]);
   Prompt (04, 12, TMenu [4,1], TMenu [4,2]);
   Prompt (04, 13, TMenu [5,1], TMenu [5,2]);

   { Show a little string animation...
   }

   Scroll (25, 01, 79, 'WOW!!!   What a cool vertical menu unit...'+
           '                                                      ');

   Repeat Until KeyPressed; ReadKey;

   { Clear the last line of the screen
   }

   GotoXy (1, 25);
   ClrEol;

   { Process the menu option selection
   }

   Repeat

        { Call the menu handler with three argument :
            the first  is the start column of the first option
            the second is the start line of the first option
            the last   is the number of option in our menu
        }

        Choix := MChoix (4,9,5);

        { Once the user has been pressed on a function key (F1 to F10), the
          escape key or the enter key, then the MChoix function will return
          a numeric value:

              59 to 68 if a function key has been pressed (59 = F1, ...)
              255 if the Escape key has been pressed
              a number from 1 to the option number; so if the user has
                 pressed the enter key on the third option, the return value
                 will be equal to 3.
        }

        Str (Choix, Lig);
        Lig := 'The selected option is : '+ Lig;
        WriteStrXy (43, 17, 15, 01, Lig);

        { I continue until the escape key is pressed or the 'Quit' option has
          been selected (this is the 5 option)
        }

   Until ((Choix = 5) or (Choix = 255));

   ClrScr;


End.
