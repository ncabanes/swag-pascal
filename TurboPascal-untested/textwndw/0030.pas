{
                  =======================================

                         CRT-DEMO (c) AVC Software
                               Cardware

                   Souce in Pascal to  show how we can
                   manipulate  EGA/VGA  register   for
                   obtain  some  cool  effects in text
                   mode 80*25.


                  =======================================

   The purpose of this program is to show how we can make some cools effect
   in text mode by manipulating the EGA/VGA registers.

   I have writte almost all procedure in assembler for the quick effect and
   for the creation of OBJ file if you want.

   Some code cames from severall books.

   Sorry for the French comments.




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

{$G+}

Uses Crt;

Var I  : Byte;
   Ch  : Char;
   Delai : Byte;

Procedure Wait_Retrace; Assembler;

Asm

    Mov Dx, 3dah

  @Wait1:
    In   Al, Dx
    Test Al, 8h
    Jnz  @Wait1

   @Wait2:
    In   Al, Dx
    Test Al, 8h
    Jnz  @Wait2

End;

Procedure Wait_In_Retrace;

Begin

   Asm
           Mov Dx, 3dah
   @Wait2:
           In al, dx
           Test Al, 8h
           Jnz @Wait2
   End;

End;

Procedure Deplace_par_Pixel; Assembler;

Asm

 { Je m'adresse au contrôleur d'attributs (Attribute Controller : ATC)
   qui s'adresse via le port 3c0h.  Je lui envoi la valeur 110011b
   qui lui indique que je ne désire pas que le CPU accède à la mémoire
   de la palette et que le déplacement doit se faire au pixel près }

      Mov Dx, 3c0h
      Mov Al, 110011b
      Out Dx, Al

      Mov Al, 10100b
      Out Dx, Al

End;


Procedure Smooth_Scrolling (Sens : Byte);

{ Sens = 0 => défilement vers le bas
         1 => Défilement vers le haut  (1 ou tout autre) }

Var Tempo : Word;

Begin

  If Sens = 0 then Tempo := 1 Else Tempo := 9;

  Repeat

     Asm
          Mov Al, 8
          Mov Dx, 3d4h
          Out Dx, Al
          Mov Dx, 3d5h
          In  Al, Dx
          Inc Al
          And Al, 15
          Out Dx, Al


     { Les bits 0 à 4 représente le Initial Row Adress : indiquent au CRTC
       la ligne de déclenchement du retour du balayage vertical, normalement
       0.  Si on augmente ce paramètre, le CRTC commence par une ligne située
       plus bas, ce qui déplace le contenu de l'écran vers le haut.
       Ce registre fonctionne de la même façon en mode texte qu'en mode
       graphique, de sorte que grâce à lui on peut réaliser un défilement
       continu vertical (qu'on appelle Smooth Scrolling).

       Si la ligne de départ est égale à 15, cela signifie que je vais traiter
       le dernier pixel du caractère, et l'apparition de parasites se fera
       sentir.  Je réinitalise donc à 0 grâce à un AND 15. }

     End;

     Delay (Tempo);

  Until KeyPressed;

  Ch := ReadKey; If Ch = #0 then Ch := ReadKey;

  Asm
      xor al, al
      mov dx, 3d5h
      out dx, al
  End;


  { Réinitialisation à sa valeur d'origine pour éviter les mauvaises surprises}

End;

Procedure EGA2VGA (OnOff : Byte); Assembler;

{ 0 pour que les caractères aient 9 pixels ou 1 pour qu'il en aient 8 }

Asm

          Mov Al, 1
          Mov Dx, 3c4h
          Out Dx, Al
          Mov Dx, 3c5h
          In  Al, Dx
          Or  Al, OnOff
          Out Dx, Al

End;


Procedure Minimize_Char;

Begin

    Repeat

       Asm

          Mov Al, 9
          Mov Dx, 3d4h
          Out Dx, Al
          Mov Dx, 3d5h
          In  Al, Dx
          Inc Al
          And Al, 14
          Or  Al, 1
          Out Dx, Al

       End;

       Delay (100);

    Until KeyPressed;

    Ch := ReadKey; If Ch = #0 then Ch := ReadKey;

    Asm
           Mov Dx, 3d5h
           Mov Al, 15
           Out Dx, Al
    End;

End;

Procedure Mazimize_Char;

Begin

    Repeat

       Delay (100);

       Asm

            Mov Al, 9
            Mov Dx, 3d4h
            Out Dx, Al
            Mov Dx, 3d5h
            In  Al, Dx
            Inc Al
            Or  Al, 128
            Out Dx, Al

       End;

    Until KeyPressed;

    Ch := ReadKey; If Ch = #0 then Ch := ReadKey;

    Asm Mov Al, 15; Out Dx, Al; End;

End;

Procedure Dedouble;

Begin

  Port[$3d4] := $09;              { Je m'adresse au registre 08h du CRTC }

  Port[$3d5] := (Port[$3d5] or 128) ;

  { Positionne à 1 le bit 7 qui divise le rythme d'horloe vertical (clock
    rate) par deux, ce qui a pour effet de dédoubler l'affichage de chaque
    ligne.  Prévu pour la génération des modes 200 lignes dans une résolution
    physique de 400 lignes. }

  Ch := ReadKey; If Ch = #0 then Ch := ReadKey;

  Port[$3d5] := (Port[$3d5] and not 128) ;

  { Remet à 0 le bit 7 }

End;

Procedure Deplacement_Gauche;

{ Cette procédure décale tout l'écran vers la gauche pixel par pixel.

  Le début de la ligne qui commence à disparaitre fait place au début de la
  ligne suivante.  Par conséquent, la ligne n° 25 (non visible) doit contenir
  le même texte que la ligne 24 pour une question d'esthétique. }

Var Nbr : Word;

Begin

   Nbr := 0;

   Repeat

      Nbr := (Nbr + 1) mod 80;

      Asm

          Mov Dx, 3d4h                { Je m'adresse au port du CRTC : 3d4h }
          Mov Al, 0ch

          { Registre 0ch : Linear Starting Address : définit l'offset à
            l'intérieur de la mémoire d'écran où le CRTC commence à lire
            les données graphiques }

          Mov Ah, Byte Ptr Nbr + 1
          Out Dx, Ax

          { En manipulant cette adresse, on peut provoquer un défilement
            horizontal en incrémentant sans cesse cette valeur de une
            position supérieure }

          Mov Al, 0dh
          Mov Ah, Byte Ptr Nbr
          Out Dx, Ax

      End;

      Delay (Delai);

  Until KeyPressed;

  Ch := ReadKey; If Ch = #0 then Ch := ReadKey;

End;

Procedure Split (Row, Mouv : Byte); Assembler;

Asm

          Mov Bl, Row
          Xor Bh, Bh
          Shl Bx, 1

          Mov Cx, BX

          Mov Dx, 3d4h
          Mov Al, 07h
          Out Dx, Al

          Inc Dx
          In Al, Dx
          And Al, 11101111b

          Shr Cx, 4
          And Cl, 16
          Or Al, Cl
          Out Dx, Al

          Dec Dx
          Mov Al, 09h
          Out Dx, Al
          Inc Dx
          In Al, Dx
          And Al, 10111111b

          Shr Bl, 3
          And Bl, 64
          Or Al, Bl
          Out Dx, Al

          Dec Dx
          Mov Al, 18h
          Mov Ah, Row
          Shl Ah, 1
          Out Dx, Ax

          Cmp Mouv, 0
          Je @Fin

          Mov Al, 8
          Mov Dx, 3d4h
          Out Dx, Al
          Mov Dx, 3d5h
          In  Al, Dx
          Inc Al
          And Al, 15
          Out Dx, Al

@Fin:

End;

Procedure CopyPage (Source, Cible : Byte);

{ Copy le contenu de la page Source dans la page Cible.  Permet de sauver
  une page avant sa modification et de la restaurer le moment venu}

Type VRam = Array  [0..7,0..4095] of byte;
     Vptr = ^VRam;

Var RVideo   : Vptr;
    i        : Word;

Begin

     RVideo := ptr ($B800,$0000);

     Move (RVideo^[Source, 0],RVideo^[Cible, 0], 4096);

End;

Procedure Superpose (fond, active, buffer : byte);

{ Affiche en superposition la page écran active sur la page écran fond.
  La page écran buffer servira de zone de stockage temporaire.

  Ces deux pages écran doivent être préparées à l'avance }

Begin

  CopyPage(Fond,   Buffer);
  CopyPage(Active, Fond);
  CopyPage(Buffer, Active);

  { Change the active page }

  Asm

    Mov Ah, 05h
    Mov Al, Active

    Int 10h

  End;

  Repeat

      For I := 200 downto 50 do Begin

        Wait_Retrace;
        Split(I,I Xor 1);
        Wait_Retrace;
        Delay (Delai);

        If KeyPressed then Delai := 0;

      End;

      For i := 50 to 200 do Begin

        Wait_Retrace;
        Split(I,I xor 1);
        Wait_Retrace;
        Delay (Delai);

        If KeyPressed then Delai := 0;

      End;

  Until KeyPressed;

  Ch := ReadKey; If Ch = #0 then Ch := ReadKey;

End;

var tempo, row : byte;

Begin

  Delai := 15;

  TextAttr:= 19;

  For I := 0 to 25 Do
     Writeln ('Wow!!!  What a cool effect!!!   Ha! Ha! Ha! Yes, it''s possible in text mode!!!  ');


  EGA2VGA(1);

  Smooth_Scrolling(0);
  Smooth_Scrolling(1);

  Dedouble;

  Minimize_Char;
  Mazimize_Char;

  Deplace_par_Pixel;

  Deplacement_Gauche;

  TextAttr := 45;

  For I := 0 to 24 Do
     Writeln ('Hello to you, Man.   This demo has been coded by AVONTURE Christophe');

  SuperPose (0,1,2);

  EGA2VGA(0);

  { Pour réinitialiser correctement les paramètres du port 3d4h }

  Asm
     Mov Ax, 0003h
     Int 10h
  End;

  ClrScr;

  Writeln ('');
  Writeln ('Cette petite démo n''a aucune prétention si ce n''est celle de prouver');
  Writeln ('que le mode communément appelé texte n''est pas aussi idiot que cela.');
  Writeln ('');
  Writeln ('');
  Writeln ('Oui, on peut faire de jolies choses tout en restant dans le mode texte!!!');
  Writeln ('');


End.