
{ NOTE :  DEMO at the bottom of this unit
          also UMOUSE needed here is in MOUSE.SWG }

{
  AUTHOR             : Christophe.AVONTURE@is.belgacom.be

  AIM                : Makes the creation of menu very, very easy.

  WRITTEN DATE       : Tuesday   March 12 1996
  LAST MODIFICATION  : Wednesday March 14 MARS 1996

  !!!  NEVER MODIFY THIS UNIT.  !!!

  -CONTACT ME IF YOU WANT TRANSLATION INTO ENGLISH-
}

Unit Menu;

INTERFACE

TYPE

   { Définition d'un type procedure }

   TProcedure     = Procedure;

   { Règlemente la longueur d'une option d'un menu. }

   TMenuOption    = String[25];

   { Les menus déroulants sont prévus pour fonctionner en mode texte 80*25 ou
     en mode graphique 640*480 }

   cgVideoMode = (cgTextMod, cgGraphMod);


CONST

   { C'est cette variable qui déterminera la fin du menu.  Le meilleur
     emploi est dans un menu File; option Exit }

   bEXIT : Boolean = FALSE;

   { Déclare au programme que le menu doit se faire en mode texte 80*25 }

   cgMode : cgVideoMode = cgTextMod;

   { Attribut couleur du menu principal }

   cgMainMenuAttr  : Byte = 112;

   { Attribut couleur du menu principal : Lettre surbrillance}

   cgMainMenuAttrS : Byte = 116;

   { Attribut couleur des sous-menus lorsqu'ils sont sélectionnés }

   cgSubMenuAttr   : Byte = 33;

   { Attribut couleur des sous-menus lorsqu'ils sont sélectionnés :
     Lettre surbrillance }

   cgSubMenuAttrS  : Byte = 44;

VAR

   { Cette variable servira à stocker le nom du sous-menu qui est
     actuellement déplié afin de ne pas le déplier à nouveau lorsqu'on
     sélectionne une autre option dans ce même sous-menu. }

   cgActualSubMenu   : TMenuOption;

   { Cette variable servira à stocker le nom de l'option qui est
     actuellement sélectionnée afin de remettre son attribut couleur en
     cgSubMenuAttr. }

   cgActualOption    : Byte;

   { Tableau global: contient le nom de toutes les options du menu général,
     c'est-à-dire qu'il contient tous les libéllés des différents sous-menus
     présents. }

   cgMenu            : Array[1..11,0..25] of TMenuOption;

   { Présentation sous forme de tableau du menu principal. Ce tableau sera
     complété dynamiquement lors du RUNTIME par le contenu de la constante
     cgMainMenu où les différents sous-menus sont séparés par des blancs. }

   cgSubMenu         : Array[1..11] OF TMenuOption;

   { Message qui viendra s'écrire dans la ligne de statut pour chacune des
     options ou chacun des sous-menus. }

   cgMessage         : Array[1..11,0..25] OF ^String;

   { Nombre de sous-menu apparraissant dans le menu principal.  Cette valeur
     est automatiquement calculé par le programme. }

   cgSubMenuNumber  : Byte;

   { Tableau global: contient toutes les procédures pour tous les sous-menus
     du menu général.  C'est via ce tableau que l'on pourra accéder aux
     handler des différentes options présentes dans le menu général. }

   cgMenuProc        : Array[1..11,1..25] of TProcedure;

   { Contiendra, pour un sous-menu donné, la liste de toutes les procédures
     qui sont associés aux options de ce sous-menu. }

   cgSubMenuProc     : Array[1..11] OF TProcedure;


PROCEDURE ShowSubMenu (cgSubMenu, cgOption : TMenuOption; cgMessage : Pointer);
PROCEDURE MainMenuHandle;
PROCEDURE WriteBarMenu;
PROCEDURE CopyPage (Source, Cible : Byte);
PROCEDURE Cursor_Hide;
PROCEDURE Cursor_Show;
PROCEDURE Run_Menu;

FUNCTION  GetOrderSubMenu (cgSubMenu : TMenuOption) : Byte;

IMPLEMENTATION

USES Crt, uMouse;  { FOUND IN MOUSE.SWG}

CONST

   { Sauvegarde du nombre de handler nouvellement ajouté afin de pouvoir les
     retirer lorsque l'on passera à un autre sous-menu. }

   OldNumberHandler : Byte = 0;

VAR

   { Menu principal.  Obligatoirement inférieur ou égal à 100 caractères.
     Théoriquement, cette taille devrait être de 80 caractères mais comme
     il se peut que l'on utilise des '&' pour préfixer certaines lettres,
     on devra alors tenir compte d'une taille plus grande que 80. }

   cgMainMenu        : String[100];
   cgMainMenu2       : String[100];

   { Cette variable servira à stocker le nom du sous-menu qui est
     actuellement déplié afin de ne pas le déplier à nouveau lorsqu'on
     sélectionne une autre option dans ce même sous-menu. }

   cgOldSubMenu      : TMenuOption;

   { Cette variable servira à stocker le nom de l'option qui est
     actuellement sélectionnée afin de remettre son attribut couleur en
     cgSubMenuAttr. }

   cgOldOption       : TMenuOption;


{ ************************************************************************ }
{ * Sauvegarde la page écran source dans la page écran destination.      * }
{ ************************************************************************ }

PROCEDURE CopyPage (Source, Cible : Byte);

BEGIN

    Move (Mem[$B800:Source Shl 12], Mem[$B800:Cible Shl 12], 4096);

END;

{ ************************************************************************ }
{ * Lorsque le clic de la souris se fait dans une surface non délimitée, * }
{ * on peut associer une procédure qui sera chargée de rafraîchir l'écran* }
{ * ou tout autre chose.  Dans ce cas, le sous-menu sera replié.         * }
{ ************************************************************************ }

PROCEDURE OtherArea;

BEGIN

{   CopyPage (1, 0);}

END;

{ ************************************************************************ }
{ * Ote les blancs se trouvant devant et derrière un mot                 * }
{ ************************************************************************ }

FUNCTION AllTrim (s : String) : String;

BEGIN

    WHILE s[1] = ' ' DO
       Delete (s, 1, 1);

    WHILE s[Length(s)] = ' ' DO
       Delete (s, Length(s), 1);

    AllTrim := s;

END;

{ ************************************************************************ }
{ * Procédure bidon: assignée par défaut à toutes les nouvelles options  * }
{ * créées ou à tous nouveaux sous-menus.                                * }
{ ************************************************************************ }

PROCEDURE hNULL;  FAR; BEGIN END;

{ ************************************************************************ }
{ * Affiche le texte fournit comme paramètre à la position courante du   * }
{ * curseur en prenant soin de retirer tous les "&".                     * }
{ ************************************************************************ }

PROCEDURE ShowText (S : String);

VAR
   OldAttr : Byte;

BEGIN

    { Sauvegarde l'attribut de couleur actuel }

    OldAttr := TextAttr;

    { Masque le curseur de la souris afin de ne pas écrire dessus. }

    Mouse_Hide;

    IF NOT (Pos('&', S) = 0) THEN
       BEGIN

          { Il faut traiter les différents '&' présents dans le texte. }

          REPEAT

                { Ecriture de la partie de texte se situant avant le '&' }

                TextAttr := OldAttr;
                Write (Copy (S, 1, Pos('&', S)-1));

                { Ecriture de la lettre préfixée par le '&' dans une autre
                  couleur. }

                IF OldAttr = cgMainMenuAttr THEN
                   TextAttr := cgMainMenuAttrS
                ELSE
                   TextAttr := cgSubMenuAttrS;

                Delete (S, 1, Pos('&', S));
                Write (S[1]);

                { Effacement du '&' }

                Delete (S, 1, 1);

          UNTIL Pos('&', S) = 0;

          TextAttr := OldAttr;
          Write (S);

       END
    ELSE
       Write (S);

    { Réaffiche le curseur de la souris. }

    Mouse_Show;

END;

{ ************************************************************************ }
{ * Retourne une chaîne de caractères sans les  "&".                     * }
{ ************************************************************************ }

FUNCTION Remove_Ampersand (s : String) : String;

BEGIN

   WHILE Pos ('&', s) > 0 DO
     Delete (s, (Pos('&', s)), 1);

   Remove_Ampersand := s;

END;

{ ************************************************************************ }
{ * Affiche le menu principal.                                           * }
{ ************************************************************************ }

PROCEDURE WriteBarMenu;

VAR
   S : String;
   I : Byte;

BEGIN

    S := cgMainMenu;
    GotoXy (1,1);
    TextAttr := cgMainMenuAttr;
    Mouse_Hide;
    ClrEol;
    Mouse_Show;

    ShowText (cgMainMenu);

    { Affiche la barre d'état }

    GotoXy (1,25);
    Mouse_Hide;
    ClrEol;
    Mouse_Show;

END;

{ ************************************************************************ }
{ * Cette fonction retourne la position du sous-menu dans la chaîne      * }
{ * cgMainMenu. Elle sera utile uniquement pour déterminer la colonne où * }
{ * débute le sous-menu à l'écran.                                       * }
{ ************************************************************************ }

FUNCTION GetPosSubMenu (cgSubMenu : TMenuOption) : Byte;

VAR
   I : Byte;

BEGIN

   GetPosSubMenu := Pos (Remove_Ampersand(cgSubMenu), cgMainMenu2);

END;

{ ************************************************************************ }
{ * Cette fonction va retourner 1 si c'est le tout premier sous-menu de  * }
{ * la barre de menus, 2 si c'est le second, ... indépendamment du X     * }
{ * (colonne) dans cette même barre.                                     * }
{ ************************************************************************ }

FUNCTION GetOrderSubMenu (cgSubMenu : TMenuOption) : Byte;

VAR
   I, J : Byte;
   s    : String;
   s2   : String;
   bFin : Boolean;

BEGIN

   s    := cgMainMenu;
   I    := 0;
   bFin := False;

   REPEAT

      Inc (I);

      WHILE s[1] = ' ' DO
         Delete (s, 1, 1);

      J  := 0;
      s2 := '';

      REPEAT
         Inc (J);
         s2 := s2 + s[J];
      UNTIL (s[J] = ' ') OR (J = Length(s));

      Delete (s2, Length(s2), 1);

      IF s2 = cgSubMenu THEN
         bFin := True
      ELSE
         IF I = cgSubMenuNumber THEN
            bFin := True
         ELSE
            Delete (s, 1, Length(s2));

   UNTIL bFin;

   GetOrderSubMenu := I;

END;

{ ************************************************************************ }
{ * Cette fonction va retourner 1 si c'est la toute première option du   * }
{ * sous-menu, 2 si c'est la seconde, ... indépendamment du X (colonne). * }
{ ************************************************************************ }

FUNCTION GetOrderOptionMenu (cgSubMenu, cgOption : TMenuOption) : Byte;

VAR
   I   : Byte;
   J   : Integer;
   Err : Integer;

BEGIN

   Val (cgMenu[GetOrderSubMenu(cgSubMenu),Low (cgMenu[GetOrderSubMenu (cgSubMenu)])],
        J, err);

   FOR I := (Low (cgMenu[GetOrderSubMenu (cgSubMenu)]) + 1) TO J DO
      IF cgMenu[GetOrderSubMenu (cgSubMenu),I] = cgOption THEN
         Break;

   GetOrderOptionMenu := I + 2;

END;

PROCEDURE hAllOption;   FAR;
BEGIN

   { Mise en surbrillance de l'option. }

   cgActualOption := (cgMouse_Y-1) Shr 3;
   ShowSubMenu (cgSubMenu[GetOrderSubMenu(cgActualSubMenu)],
                cgMenu[GetOrderSubMenu(cgSubMenu[GetOrderSubMenu(cgActualSubMenu)]),cgActualOption],
                cgMessage[GetOrderSubMenu(cgActualSubMenu),cgActualOption]);

   { Il ne faudra exécuter le code que si l'utilisateur a relâché le bouton
     gauche de la souris et pas autrement. }

   IF NOT Mouse_ReleaseButton (cgMouse_Left) THEN
      cgMenuProc[GetOrderSubMenu(cgActualSubMenu),cgActualOption];
END;

{ ************************************************************************ }
{ * Déplie un sous-menu.  Si le paramètre cgOption est spécifié (diffé-  * }
{ * rent de ''), alors le sous-menu est déplié et l'option donnée est    * }
{ * sélectionnée.                                                        * }
{ ************************************************************************ }

PROCEDURE ShowSubMenu (cgSubMenu, cgOption : TMenuOption; cgMessage : Pointer);

VAR
   I       : Byte;
   J       : Word;
   Max     : Byte;
   S       : String;
   Nbr     : Integer;
   Err     : Integer;
   Message : ^String;
   SubMenu : ^String;

BEGIN

   { On va faire un rafraichissement de l'écran uniquement s'il y a lieu d'en
     faire un. }


   IF NOT ((cgSubMenu = cgOldSubMenu) AND (cgOption = cgOldOption)) THEN
      BEGIN

         IF NOT (cgSubMenu = cgOldSubMenu) THEN
            BEGIN

               CopyPage (1, 0);

               { Retire les anciens handler d'un autre sous-menu }

               IF NOT (oldNumberHandler = 0) THEN
                  FOR I := 1 TO oldNumberHandler DO
                     Mouse_RemoveHandler;

               WriteBarMenu;

               { Mise en surbrillance du sous-menu }

               TextAttr := cgSubMenuAttr;

               J := GetPosSubMenu(Remove_Ampersand(cgSubMenu));

               IF (J > 1) AND (J < 79) THEN
                  BEGIN
                     GotoXy (J-1, 1);
                     ShowText (' '+cgSubMenu+' ');
                  END
               ELSE
                  IF (J > 1) THEN
                     BEGIN
                        GotoXy (J-1, 1);
                        ShowText (' '+cgSubMenu)
                     END
                  ELSE
                     BEGIN
                        GotoXy (J, 1);
                        ShowText (cgSubMenu+' ');
                     END;

               { Lecture du nombre d'options dans ce sous-menu }

               Val (cgMenu[GetOrderSubMenu(cgSubMenu),Low (cgMenu[GetOrderSubMenu (cgSubMenu)])],
                    Nbr, err);

               IF NOT (Nbr = 0) THEN
                  BEGIN

                     { Affichage des différentes options }

                     TextAttr := cgMainMenuAttr;

                     Max := 0;

                     FOR I := Low (cgMenu[GetOrderSubMenu (cgSubMenu)]) TO High (cgMenu[GetOrderSubMenu (cgSubMenu)]) DO
                        IF Max < Length (Remove_Ampersand(cgMenu[GetOrderSubMenu (cgSubMenu),I])) THEN
                           Max := Length (remove_ampersand(cgMenu[GetOrderSubMenu (cgSubMenu),I]));

                     { Se positionne correctement pour l'affichage }

                     IF (GetPosSubMenu (cgSubMenu) + Max + 4 > 80) THEN
                        GotoXy (80 - Max - 4 + 1, 2)
                     ELSE
                        IF (GetPosSubMenu (cgSubMenu) - 1 > 0) THEN
                           GotoXy (GetPosSubMenu (cgSubMenu) - 1, 2)
                        ELSE
                           GotoXy (GetPosSubMenu (cgSubMenu), 2);

                     FillChar(s, Max+4, '─');
                     s[0] := Chr(Max+4);
                     s[1] :=  '┌';
                     s[Length(s)] := '┐';
                     Mouse_Hide;
                     Write (S);
                     Mouse_Show;


                     FOR I := Low (cgMenu[GetOrderSubMenu (cgSubMenu)])+1 TO Nbr DO
                        BEGIN

                           { Se positionne correctement pour l'affichage }

                           IF (GetPosSubMenu (cgSubMenu) + Max + 4 > 80) THEN
                              GotoXy (80 - Max - 4 + 1, I+2)
                           ELSE
                              IF (GetPosSubMenu (cgSubMenu) - 1 > 0) THEN
                                 GotoXy (GetPosSubMenu (cgSubMenu) - 1, I+2)
                              ELSE
                                 GotoXy (GetPosSubMenu (cgSubMenu), I+2);

                           IF NOT (cgMenu[GetOrderSubMenu (cgSubMenu),I] = '─') THEN
                              BEGIN

                                 IF Pos('&', cgMenu[GetOrderSubMenu (cgSubMenu),I]) > 0 THEN
                                    FillChar(s, Max+5, ' ')
                                 ELSE
                                    FillChar(s, Max+4, ' ');

                                 s := '│ '+cgMenu[GetOrderSubMenu (cgSubMenu),I];

                                 IF Pos('&', cgMenu[GetOrderSubMenu (cgSubMenu),I]) > 0 THEN
                                    s[0] := Chr(Max+5)
                                 ELSE
                                    s[0] := Chr(Max+4);

                                 s[Length(s)] := '│';

                                 IF (GetPosSubMenu (cgSubMenu) + Max > 80) THEN
                                    Mouse_AddHandler (80 - (Max + 2), 80, I+1, I+1, hAllOption)
                                 ELSE
                                    Mouse_AddHandler (GetPosSubMenu (cgSubMenu)-1,
                                       GetPosSubMenu (cgSubMenu)-1+Max,
                                       I+1, I+1, hAllOption);
                              END
                           ELSE
                              BEGIN
                                 FillChar(s, Max+4, '─');
                                 s := '├'+cgMenu[GetOrderSubMenu (cgSubMenu),I];
                                 s[0] := Chr(Max+4);
                                 s[Length(s)] := '┤';
                             END;
                           ShowText (s);
                        END;

                     FillChar(s, Max+4, '─');
                     s[0] := Chr(Max+4);
                     s[1] :=  '└';
                     s[Length(s)] := '┘';

                     { Se positionne correctement pour l'affichage }

                     IF (GetPosSubMenu (cgSubMenu) + Max + 4 > 80) THEN
                        GotoXy (80 - Max - 4 + 1, Nbr + 3)
                     ELSE
                        IF (GetPosSubMenu (cgSubMenu) - 1 > 0) THEN
                           GotoXy (GetPosSubMenu (cgSubMenu) - 1, Nbr+3)
                        ELSE
                           GotoXy (GetPosSubMenu (cgSubMenu), Nbr+3);

                     Mouse_Hide;
                     Write (S);
                     Mouse_Show;

                     cgOldOption := '';

                     OldNumberHandler := Nbr;

                  END;

            END

         ELSE

            IF NOT (cgoldOption = '') THEN
               BEGIN

                  Max := 0;

                  FOR I := Low (cgMenu[GetOrderSubMenu (cgSubMenu)]) TO High (cgMenu[GetOrderSubMenu (cgSubMenu)]) DO
                     IF Max < Length (cgMenu[GetOrderSubMenu (cgSubMenu),I]) THEN
                        Max := Length (cgMenu[GetOrderSubMenu (cgSubMenu),I]);

                  { Rétablit l'attribut de l'option anciennement
                    sélectionnée }

                  TextAttr := cgMainMenuAttr;

                  { Se positionne correctement pour l'affichage }

                  IF (GetPosSubMenu (cgSubMenu) + Max > 80) THEN
                     GotoXy (80 - Max, GetOrderOptionMenu (cgSubMenu,cgOldOption))
                  ELSE
                     IF NOT (GetPosSubMenu (cgSubMenu) - 1 > 1) THEN
                        GotoXy (GetPosSubMenu (cgSubMenu) + 2, GetOrderOptionMenu (cgSubMenu,cgOldOption))
                     ELSE
                        GotoXy (GetPosSubMenu (cgSubMenu) + 1, GetOrderOptionMenu (cgSubMenu,cgOldOption));

                  ShowText (cgoldOption);

                  { Surligne la ligne jusqu'au cadre }

                  S := '';

                  FOR I := Length(cgoldOption)+1 TO Max DO
                      S := S + ' ';

                  Mouse_Hide;
                  Write (s);
                  Mouse_Show;

                END;

         cgOldSubMenu  := cgSubMenu;

         IF NOT (cgOption = '') THEN
            BEGIN

               { Surligne l'option }

               TextAttr := cgSubMenuAttr;

               Max := 0;

               FOR I := Low (cgMenu[GetOrderSubMenu (cgSubMenu)]) TO High (cgMenu[GetOrderSubMenu (cgSubMenu)]) DO
                  IF Max < Length (cgMenu[GetOrderSubMenu (cgSubMenu),I]) THEN
                     Max := Length (cgMenu[GetOrderSubMenu (cgSubMenu),I]);

               { Se positionne correctement pour l'affichage }

               IF (GetPosSubMenu (cgSubMenu) + Max > 80) THEN
                  GotoXy (80 - Max, GetOrderOptionMenu (cgSubMenu,cgOption))
               ELSE
                  IF NOT (GetPosSubMenu (cgSubMenu) - 1 > 1) THEN
                     GotoXy (GetPosSubMenu (cgSubMenu) + 2, GetOrderOptionMenu (cgSubMenu,cgOption))
                  ELSE
                     GotoXy (GetPosSubMenu (cgSubMenu) + 1, GetOrderOptionMenu (cgSubMenu,cgOption));

               ShowText (cgOption);

               { Surligne la ligne jusqu'au cadre }

               Max := 0;

               FOR I := Low (cgMenu[GetOrderSubMenu (cgSubMenu)]) TO High (cgMenu[GetOrderSubMenu (cgSubMenu)]) DO
                  IF Max < Length (cgMenu[GetOrderSubMenu (cgSubMenu),I]) THEN
                     Max := Length (cgMenu[GetOrderSubMenu (cgSubMenu),I]);

               S := '';

               FOR I := Length(cgOption)+1 TO Max DO
                   S := S + ' ';

               Mouse_Hide;
               Write (s);
               Mouse_Show;

               cgOldOption := cgOption;

            END;

         TextAttr := cgMainMenuAttr;
         GotoXy (2, 25);
         ClrEol;

         IF NOT (cgMessage = NIL) THEN
            BEGIN

                Message := cgMessage;
                TextAttr := cgMainMenuAttr;
                GotoXy (2, 25);
                Mouse_Hide;
                Write (Message^);
                Mouse_SHow;

            END;
      END;

END;

{ ************************************************************************ }
{ * Appel la procédure correspondant au sous-menu sélectionné.           * }
{ ************************************************************************ }

PROCEDURE HighLigthMainMenu (st : TMenuOption);

BEGIN

    IF NOT (st = cgActualSubMenu) THEN
       BEGIN
          TextAttr := cgMainMenuAttr;
          GotoXy (1,1);
          WriteBarMenu;
          TextAttr := cgSubMenuAttr;
       END;

    IF NOT (GetPosSubMenu (st) = 0) AND
       NOT (GetOrderSubMenu (st) > cgSubMenuNumber) THEN
       BEGIN

          { Déplie le sous-menu }

          cgActualSubMenu := cgSubMenu[GetOrderSubMenu (st)];

          ShowSubMenu (cgSubMenu[GetOrderSubMenu(cgActualSubMenu)],
                       '',cgMessage[GetOrderSubMenu(cgActualSubMenu),0]);

          { Appel au code qui se trouve sous le sous-menu uniquement si
            l'utilisateur a relâché le bouton de gauche de la souris }

          IF NOT Mouse_ReleaseButton (cgMouse_Left) THEN
             cgSubMenuProc[GetOrderSubMenu (st)];

        END;


END;

{ ************************************************************************ }
{ * Fournit le nom du sous-menu suivant (dans l'ordre de position) du    * }
{ * sous-menu dont le nom est fournit comme paramètre.                   * }
{ ************************************************************************ }

FUNCTION GetNextSubMenu (OldSubMenu : TMenuOption) : TMenuOption;

VAR
   s     : String;
   s1    : TMenuOption;
   I     : Byte;

BEGIN

   s := cgMainMenu;

   Delete (s, 1, Pos(OldSubMenu,cgMainMenu)+Length(OldSubMenu));

   WHILE S[1] = ' ' DO
      Delete (s, 1, 1);

   I := 1;

   s1 := '';

   WHILE NOT (s[I] = ' ') DO
      BEGIN
         IF NOT (I > Length (s)) THEN
            s1 := s1 + s[I];
         Inc (I);
      END;

   GetNextSubMenu := s1;

END;

{ ************************************************************************ }
{ * Fournit le nombre de sous-menu présent dans le menu principal.       * }
{ ************************************************************************ }

FUNCTION GetSubMenuNumber : Byte;

VAR
   s : String;
   I : Byte;

BEGIN

   I := 0;
   s := cgMainMenu;

   REPEAT
      Inc (I);

      WHILE s[1] = ' ' DO
         Delete (s, 1, 1);

      REPEAT
         Delete (s, 1, 1);
      UNTIL (s[1] = ' ') OR (Length(s) = 0);

   UNTIL Length(s) = 0;

   GetSubMenuNumber := I;

END;

{ ************************************************************************ }
{ * Cette procédure va se charger de lire le fichier MENU.INC afin de    * }
{ * compléter ses tableaux.                                              * }
{ ************************************************************************ }


PROCEDURE InitAllSubMenu;

VAR
   fMenu : Text;
   S     : String;
   SS    : TMenuOption;
   I     : Byte;

BEGIN

   Assign (fMenu, 'MENU.INC');
   FileMode := 0;
   Reset (fMenu);

   I := 0;

   REPEAT

      ReadLn (fMenu, s);

      IF (Copy (s,1, 2) = '  ') THEN

         { Il s'agit d'une option d'un sous-menu. }

         BEGIN

            { Ajoute l'option dans le sous-menu. }

            Inc (I);
            S := Alltrim(s);
            cgMenu[cgSubMenuNumber,I] := S;

            { Par défaut, lorsque l'utilisateur cliquera sur cette option,
              la procédure hNULL -càd qui ne fait absolument rien- sera
              appelée. }

            cgMenuProc[cgSubMenuNumber,I] := hNULL;

         END
      ELSE
         IF (Copy (s, 1, 2) = ' -') THEN

            { Il s'agit de la ligne d'aide du sous-menu ou de l'option qu'on
              vient tout juste de traiter }

            BEGIN

               { Retire le trait d'union. }

               Delete (s, 2, 1);

               { Ajoute la ligne d'aide. }

               S := Alltrim(s);
               GetMem (cgMessage[cgSubMenuNumber,I], Length(s)+1);
               cgMessage[cgSubMenuNumber,I]^:= S;

            END
      ELSE

         { Il s'agit d'un nouveau sous-menu. }

         BEGIN

            { Sauvegarde le nombre d'options appartenant à ce sous-menu en
              position 0. }

            IF NOT (cgSubMenuNumber = 0) THEN
               Str (I, cgMenu[cgSubMenuNumber,0]);

            { Ajoute le nouveau sous-menu. }

            Inc (cgSubMenuNumber);
            S := Alltrim(s);
            cgSubMenu[cgSubMenuNumber] := S;

            { Associe par défaut le clic sur ce sous-menu à la procédure
              hNULL }

            cgSubMenuProc[cgSubMenuNumber] := hNULL;

            I := 0;

         END;

   UNTIL Eof (fMenu);

   { Sauvegarde le nombre d'options appartenant à ce sous-menu en
     position 0. }

   IF NOT (cgSubMenuNumber = 0) THEN
      Str (I, cgMenu[cgSubMenuNumber,0]);

   Close (fMenu);

   { Crée la ligne de sous-menu. }

   cgMainMenu := '';

   FOR I := 1 TO cgSubMenuNumber DO
      cgMainMenu := cgMainMenu + cgSubMenu[I] + '  ';

   { Crée la ligne de sous-menus en prenant soin de retirer tous les '&'. }

   cgMainMenu2 := cgMainMenu;

   WHILE Pos ('&', cgMainMenu2) > 0 DO
      Delete (cgMainMenu2, Pos('&', cgMainMenu2), 1);;

END;

{ ************************************************************************ }
{ * Procédure de gestion du menu déroulant.  C'est elle qui sera appelée * }
{ * lorsque le clic de la souris se fera sur la toute première ligne de  * }
{ * l'écran.                                                             * }
{ ************************************************************************ }

PROCEDURE MainMenuHandle;

VAR
   Old : TMenuOption;
   I   : Byte;

BEGIN

   Old := '';

   FOR I := 1 TO cgSubMenuNumber DO
      BEGIN

         Old := GetNextSubMenu(Old);
         IF Mouse_InArea (GetPosSubMenu (Old) - 1,
              GetPosSubMenu (Old)+Length (Old), 0, 15) THEN
            BEGIN
               HighLigthMainMenu (Old);
               Break;
            END;
      END;

END;

{ ************************************************************************ }
{ * Masque le curseur en mode texte.                                     * }
{ ************************************************************************ }

PROCEDURE Cursor_Hide;  ASSEMBLER;

ASM

    Mov  Ah, 01h
    Mov  Ch, 20
    Int  10h

END;

{ ************************************************************************ }
{ * Rétablit le curseur en mode texte.                                   * }
{ ************************************************************************ }

PROCEDURE Cursor_Show;  ASSEMBLER;

ASM

    Mov  Ah, 01h
    Mov  Cl, 7
    Mov  Ch, 6
    Int  10h

END;

{ ************************************************************************ }
{ * Run_Menu va se faire fort de simplifier au MAXIMUM l'écriture d'un   * }
{ * menu puisqu'il suffira d'associer dans le programme une association  * }
{ * entre l'option et la procédure ad'hoc.  Une fois que les liens ont   * }
{ * été établi, il suffit d'appeler cette procédure.                     * }
{ ************************************************************************ }

PROCEDURE Run_Menu;

VAR
   Ch : Char;

BEGIN

   TextAttr := 31;
   ClrScr;

   Cursor_Hide;

   { Signale que nous allons travailler avec des données de type caractère }

   cgCoordonnees := cgCharacter;

   { Ajoute un handler à celui de la souris.  La région délimitée est celle
     de la barre de menus. }

   Mouse_AddHandler (0, 79, 0, 0, MainMenuHandle);

   { Affiche la barre de menu }

   TextAttr := cgMainMenuAttr;
   WriteBarMenu;

   CopyPage (0, 1);

   IF bMouse_Exist THEN
      BEGIN

         Mouse_Show;

         Repeat

            IF Mouse_Pressed = cgMouse_Left THEN
               Mouse_Handle
            ELSE
               IF Mouse_Pressed = cgMouse_Right THEN
                    bEXIT := TRUE
               ELSE IF KeyPressed THEN
                  BEGIN

                     Ch := ReadKey; IF Ch = #0 THEN Ch := Readkey;

                     CASE Ch OF
                       #72 : ; {UpArrow}
                       #80 : ; {DownArrow}
                       #75 : ; {LeftArrow}
                       #77 : ; {RightArrow}
                     END;

                  END;

         Until bEXIT;

         Delay (250);

         Mouse_Hide;
         Mouse_Flush;

      END;

   Cursor_Show;

   TextAttr := 7;
   ClrScr;

END;


VAR
   I   : Word;
   Old : String;

BEGIN

   IF bMouse_Exist THEN
      BEGIN
         Old := '';
         FOR I := 1 TO cgSubMenuNumber DO
            BEGIN
               Old := GetNextSubMenu(Old);
               cgSubMenu[I] := Old;
            END;

         InitAllSubMenu;

         hClicNotInArea := @OtherArea;
      END
   ELSE
      BEGIN
         Writeln  ('');
         Writeln  ('');
         Writeln  ('');
         Writeln  ('Sorry, but a mouse driver is absolutly needed to run this program.');
         Writeln  ('So, please load a driver such as MOUSE.COM');
         Writeln  ('');
         Writeln  ('');
         Halt (0);
      END;

END.

{ -------------------   DEMO  ---------------------- }
{   This program also needs MENU.INC which is below !! }

{ $A+,B-,D+,E+,F-,G-,I+,L+,N-,O-,P-,Q-,R-,S+,T-,V+,X+}
{$M 8384,0,655360}

USES Crt, uMouse, Menu;  {uMOUSE is found in MOUSE.SWG }

{ ************************************************************************ }
{ * This procedure set the bExit variable to TRUE : this tell to the menu* }
{ * engine to stop the process.                                          * }
{ ************************************************************************ }

PROCEDURE hFileExit; FAR; BEGIN bEXIT := True; END;

{ ************************************************************************ }
{ * This procedure is the "About the author" code                        * }
{ ************************************************************************ }

PROCEDURE hAboutMe; FAR;
VAR
   wOldAttr : Byte;
BEGIN

   { Hide the mouse pointer }

   Mouse_Hide;

   { Save the screen }

   CopyPage (0, 3);

   { Show a little About text. }

   wOldAttr := TextAttr;
   TextAttr := 18;
   GotoXy (25,5);
   Write ('╔════════════════════════════╗');
   GotoXy (25,6);
   Write ('║                            ║░');
   GotoXy (25,7);
   Write ('║    AVONTURE CHRISTOPHE     ║░');
   GotoXy (25,8);
   Write ('║        AVC  SOFTWARE       ║░');
   GotoXy (25,9);
   Write ('║   BD EDMOND MACHTENS 157   ║░');
   GotoXy (25,10);
   Write ('║       BOITE 53             ║░');
   GotoXy (25,11);
   Write ('║      B-1080 BRUXELLES      ║░');
   GotoXy (25,12);
   Write ('║         BELGIQUE           ║░');
   GotoXy (25,13);
   Write ('║                            ║░');
   GotoXy (25,14);
   Write ('╚════════════════════════════╝░');
   GotoXy (25,15);
   Write ('░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░');
   GotoXy (20,18);
   Write ('This program has been written by AVONTURE Christophe.');
   GotoXy (20,19);
   Write ('   And I distribute it *FREELY* *WITH ALL SOURCES*');
   GotoXy (20,21);
   Write (' Please email me if you use it or anything else:');
   GotoXy (25,22);
   Write ('Christophe.AVONTURE@is.belgacom.be');

   { Restore the text color attribute }

   TextAttr := wOldAttr;

   { Wait until the user pressed a mouse button }

   REPEAT
   UNTIL NOT (Mouse_Pressed = cgMouse_None);

   { And clear the mouse buffer }

   Mouse_Flush;

   { Restore the screen }

   CopyPage (3,0);

   { And reshow the mouse pointer }

   Mouse_Show;

END;

{ ************************************************************************ }
{ *                                                                      * }
{ *                              MAIN PROGRAM                            * }
{ *                                                                      * }
{ ************************************************************************ }

BEGIN

   ClrScr;

   TextAttr := 15;

   Writeln ('Christophe.AVONTURE@is.belgacom.be');
   Writeln ('');
   Writeln (' Try the ''■'' menu and ''About the author'' option.');
   Writeln ('');
   Writeln (' You can quit this program by File|Exit or right clic.');
   Writeln ('');
   Writeln ('');
   Writeln ('');
   Writeln (' Sorry but the keyboard isn''t handle: only mouse events are');
   Writeln (' accepted.');
   Writeln ('');
   Writeln ('');
   Writeln (' The menu is coded into MENU.INC file and all modifications of');
   Writeln (' this file implies that you need to recompile the unit and your');
   Writeln (' program.');
   Writeln ('');
   Writeln ('');

   REPEAT
   UNTIL KeyPressed;
   ReadKey;

   {
     The cgMenuProc array will contains all procedure references to your
     code.

     You must always respect the following call :

        cgMenuProc[GetOrderSubMenu (cgSubMenu[x]),xx] := xxx;

     The cgSubMenu[x] will return the indice of the menu option and the
     xx returns the submenu option.  The xxx is the name of the procedure.

     So, if you tried this examples, the first menu option is '■' and the
     second is 'File'.

     In the '■' menu, there are two submenu option : 'About' and 'About the
     author'.  So If I want access to the first submenu option of the '■'
     menu option, I only need to call the
        cgMenuProc[GetOrderSubMenu (cgSubMenu[1]),1]

     The cgSubMenu[1] indentifies the '■' menu option and the last 1
     identifies the submenu option.

     OK, if you have understand, the following assignation
        cgMenuProc[GetOrderSubMenu (cgSubMenu[1]),2] := hAboutMe;
     tells to the menu engine that you assign to the '■' "About the author"
     the procedure hAboutMe.

   }

   cgMenuProc[GetOrderSubMenu (cgSubMenu[2]),11] := hFileExit;
   cgMenuProc[GetOrderSubMenu (cgSubMenu[1]),2]  := hAboutMe;

   {
     Once the cgMenuProc array fill in, you can call the Run_Menu engine.
   }

   Run_Menu;

   {
     You can only arrived here if the bExist boolean value is set to TRUE.
     See the hFileExit procedure.
   }


END.

{ -------------------   CUT  ---------------------- }
{ -------  SAVE AS MENU.INC -------- }
&■
 -System box
  &About
 -Show general informations about this program
  A&bout the author
 -Show general informations about author of this program
&File
 -File utilities
  &New
 -Create a new file
  &Open...
 -Open an existing file
  &Save
 -Save the file
  Save &as...
 -Save the current file under a different name
  Save a&ll
 -Save all modified files
  ─
  &Change dir...
 -Choose a new default directory
  &Print
 -Print the contents of the active window
  P&rint setup...
 -Choose printer filter to use for printing
  &Dos shell
 -Temporarily exit to DOS
  E&xit
 -Exit Turbo Pascal
&Edit
 -Edit utilities
  &Undo
 -Undo the previous editor operation
  &Redo
 -Redo the previous editor operation
  ─
  Cu&t
 -Remove the selected text and put in into the clipboard
  &Copy
 -Copy the selected text into the clipboard
  &Paste
 -Insert selected text from the clipboard at the cursor position
  C&lear
 -Delete the selected text
  ─
  &Show clipboard
 -Open the clipboard window
&Search
 -Search utilities
  &Find...
 -Search for text
  &Replace...
 -Search for text and replace it with new text
  &Search again
 -Repeat the last Find or Replace command
  ─
  &Go to line number...
 -Move the cursor to a specified line number
  S&how last compile error
 -Move the cursor to the position of the last compile error
  Find &error...
 -Move the cursor to the position of a runtime error
  Find &procedure...
 -Search for a procedure or function declaration while debugging
&Run
 -Run utilities
  &Run
 -Run the current program
  &Step over
 -Execute next statement, skipping over the current procedure
  &Trace into
 -Execute next statement, stopping within the current procedure
  &Go to cursor
 -Run program from the run bar to the cursor position
  &Program reset
 -Halt debugging session and release memory
  P&arameters...
 -Set command line parameters to be passed to the program
&Compile
 -Compile utilities
  &Compile
 -Compile source file
  &Make
 -Rebuild source file and all other files that have been modified
  &Build
 -Rebuild source file and all other files
  ─
  &Destination Memory
 -Specify wheter source file is compiled to memory or disk
  &Primary file...
 -Define the file that is the focus of Make or Build
  C&lear primary file
 -Clear the file previously set with Primary file
  ─
  &Information...
 -Show status information
&Debug
 -Debug utilities
  &BreakPoints...
 -Set conditionnal breakpoints
  &Call stack
 -Show the procedures the program called to reach this point
  &Register
 -Open the register window
  &Watch
 -Open the Watch window
  &Output
 -Open the Output window
  &User screen
 -Swithc to the full-screen user output
  ─
  &Evaluate/Modify...
 -Evaluate a variable or expression and display or modify the value
  &Add watch...
 -Insert a watch expression into the Watch window
  Add break&points...
 -Add a breakpoint expression
&Tools
 -Tools utilities
  &Messages
 -Open the message window
  &Go to next
 -Go to the next source position
  &Go to previous
 -Go to the previous source position
  ─
  &Grep
 -User installed tool
&Options
 -Options utilities
  &Compiler...
 -Set default compiler directives
  &Memory sizes...
 -Set default stack and heap sizes for generated programs
  &Linker...
 -Set linker options (link buffer; .MAP file options)
  De&bugger...
 -Set debugger options (standalone, integrated, display swapping)
  &Directories...
 -Set path for units, inlude files, OBJs, and generated files
  &Tools...
 -Create or change tools
  ─
  &Environment
 -Specify environment settings
  ─
  &Open...
 -Load options previously create with Save Options
  &Save
 -Save all the settings you've made in the Options Menu
  Save &as...
 -Save all the settings in the Options Menu to another file
&Window
 -Window utilities
  &Tile
 -Arrange windows on desktop by tiling
  C&ascade
 -Arrange windows on desktop by cascading
  Cl&ose all
 -Close all windows on desktop
  &Refresh display
 -Redraw the screen
  ─
  &Size/Move
 -Change the size or position of the active window
  &Zoom
 -Enlarge or restore the size of the active window
  &Next
 -Make the next window active
  &Previous
 -Make the previous window active
  &Close
 -Close the active window
  ─
  &List...
 -Show a list of all open windows
&Help
 -Help utilities
  &Contents
 -Show table of contents for online help
  &Index
 -Show index for online help
  ─
  &Topic search
 -Display help on the word at the cursor
  &Previous topic
 -Redisplay the last-viewed online Help screen
  Using &help
 -How to use online help
  &Files...
 -Add or delete installated help files
  ─
  Compiler &directives
 -Display help above the compiler directives
  &Reserved word
 -Display Turbo Pascal's reserved words
  Standard &units
 -Display help about standard Turbo Pascal units
  Turbo Pascal &Language
 -Display help about Turbo Pascal language
  &Error messages
 -Display help about the error messages
  ─
  &About...
 -Show version and copyright information
