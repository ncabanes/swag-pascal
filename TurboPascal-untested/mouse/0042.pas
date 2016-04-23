
{ AUTEUR            : AVONTURE Christophe
  BUT DE L'UNITE    : FOURNIR LES FONCTIONS DE GESTION DE LA SOURIS

  DATE DE REDACTION : 8 MARS 1996
  DERNIERE MODIF.   : 8 MARS 1996 }

UNIT uMouse;

INTERFACE

TYPE

   cgCoord = (cgPixel, cgCharacter);

CONST

   { Nombre de Handle actuellement associé au Handler de la souris }

   cgCurrentProc : Byte = 0;

   { Autorise l'appel aux différentes procédures créées par les Handler ou
     interdit leur appel. }

   cgEnableMouseProc : Boolean = True;

   { Définit si les coordonnées sont à considérer comme étant relatifs à des
     pixels ou bien relatifs à des caractères }

   cgCoordonnees : cgCoord = cgPixel;

TYPE

   { Constantes Boutons enfoncés }

   cgMouse_Key = (cgMouse_None, cgMouse_Left, cgMouse_Right, cgMouse_Both);

   { Structure permettant d'associer une procédure lorsque le clic de la
     souris se fait dans le rectangle délimité par
           (XMin, YMin) -------------- (XMax, YMin)
                :                            :
                :                            :
           (XMin, YMax) -------------- (XMax, YMax) }

   TProcedure = PROCEDURE;

   TMouseHandle = RECORD
      XMin, XMax, YMin, YMax : Word;
      Adress_Proc            : TProcedure;
   END;

   { Lorsque l'utilisateur clic en un certain endroit, si cet endroit est
     compris dans le rectangle spécifié ci-dessus, alors il faudra exécuter
     une certaine procédure.

     On va pouvoir spécifier autant de surfaces différentes. La seule
     restriction sera la mémoire disponible.

     Ainsi, on pourra dessiner un bouton OK, un bouton CLOSE, ... et leur
     associer un évènement qui leur est propre.

     Cela sera obtenu par la gestion d'un liste chaînée vers le haut. }

   TpListMouseHandle = ^TListMouseHandle;
   TListMouseHandle  = RECORD
      Next : TpListMouseHandle;
      Item     : TMouseHandle;
   END;

VAR

   { Liste chaînée des différents handles associés au handler de la souris }

   MouseProc      : TpListMouseHandle;  { Zone de travail }
   MouseProcFirst : TpListMouseHandle;  { Tout premier évènement }
   MouseProcOld   : TpListMouseHandle;  { Sauvegarde de l'ancien évènement }

   { True si un gestionnaire de souris est présent }

   bMouse_Exist : Boolean;

   { Coordonnées du pointeur de la souris }

   cgMouse_X    : Word;
   cgMouse_Y    : Word;

   { Correspondant du LastKey.  Contient la valeur du dernier bouton
     enfoncé }

   cgMouse_LastButton : cgMouse_Key;

   { Lorsque le clic ne se fait pas dans une des surfaces couvertes par les
     différents handlers (voir AddMouseHandler); on peut exécuter une
     certaine procédure. }

   hClicNotInArea     : Pointer;

PROCEDURE Mouse_Show;
PROCEDURE Mouse_Hide;
PROCEDURE Mouse_GoToXy (X, Y : Word);
PROCEDURE Mouse_Window (XMin, XMax, YMin, YMax : Word);
PROCEDURE Mouse_AddHandler (XMin, XMax, YMin, YMax : Word; Adress : TProcedure);
PROCEDURE Mouse_RemoveHandler;
PROCEDURE Mouse_Handle;
PROCEDURE Mouse_Flush;

FUNCTION  Mouse_Init    : Boolean;
FUNCTION  Mouse_Pressed : cgMouse_Key;
FUNCTION  Mouse_InArea (XMin, XMax, YMin, YMax : Word) : Boolean;
FUNCTION  Mouse_ReleaseButton (Button : cgMouse_Key) : Boolean;

{ ------------------------------------------------------------------------ }

IMPLEMENTATION

{ Teste si un gestionnaire de souris est présent }

FUNCTION Mouse_Init : Boolean;

BEGIN

   ASM

      Xor  Ax, Ax
      Int  33h

      Mov  Byte Ptr bMouse_Exist, Ah

   END;

END;

{ Cache le pointeur de la souris }

PROCEDURE Mouse_Hide; ASSEMBLER;

ASM

    Mov  Ax, 02h
    Int  33h

END;

{ Montre le pointeur de la souris }

PROCEDURE Mouse_Show; ASSEMBLER;

ASM

    Mov  Ax, 01h
    Int  33h

END;

{ Retourne une des constantes équivalents aux boutons enfoncés.  Retourne 0
  si aucun bouton n'a été enfoncé }

FUNCTION Mouse_Pressed : cgMouse_Key;  ASSEMBLER;

ASM

    Mov  Ax, 03h
    Int  33h

    { Bx contiendra 0 si aucun bouton n'a été enfoncé
                    1          bouton de gauche
                    2          bouton de droite
                    3          bouton de gauche et bouton de droite
                    4          bouton du milieu }

    Mov  Ax, Bx
    Mov  cgMouse_X, Cx
    Mov  cgMouse_Y, Dx
    Mov  cgMouse_LastButton, Al

END;

{ Positionne le curseur de la souris }

PROCEDURE Mouse_GoToXy (X, Y : Word); ASSEMBLER;

ASM

    Mov  Ax, 04h
    Mov  Cx, X
    Mov  Dx, Y
    Int  33h

END;

{ Définit la fenêtre dans laquelle le curseur de la souris peut évoluer }

PROCEDURE Mouse_Window (XMin, XMax, YMin, YMax : Word); ASSEMBLER;

ASM

    Mov  Ax, 07h
    Mov  Cx, XMin
    Mov  Dx, XMax
    Int  33h

    Mov  Ax, 08h
    Mov  Cx, YMin
    Mov  Dx, YMax
    Int  33h

END;

{ Teste si le curseur de la souris se trouve dans une certaine surface }

FUNCTION  Mouse_InArea (XMin, XMax, YMin, YMax : Word) : Boolean;

BEGIN

    IF NOT bMouse_Exist THEN 
       Mouse_InArea := False
    ELSE
       BEGIN

          { Les coordonnées sont-elles à considérer comme pixels ou comme
            caractères }

          IF cgCoordonnees = cgPixel THEN
             BEGIN

                IF NOT (cgMouse_X < XMin) AND NOT (cgMouse_X > XMax) AND
                   NOT (cgMouse_Y < YMin) AND NOT (cgmouse_y > YMax) THEN
                    Mouse_InArea := True
                ELSE
                    Mouse_InArea := False

             END
          ELSE
             BEGIN

                { Il s'agit de caractères.  Or un caractère fait 8 pixels de long.
                  Donc, lorsque l'on programme (0,1,0,1, xxx), il s'agit du
                  caractère se trouvant en (0,0) qui se trouve en réalité en
                  0..7,0..15 puisqu'il fait 8 pixels de long sur 16 de haut. }

                IF NOT (cgMouse_X Shr 3 < XMin ) AND
                   NOT (cgMouse_X Shr 3 > XMax ) AND
                   NOT (cgMouse_Y Shr 3 < YMin ) AND
                   NOT (cgmouse_y Shr 3 > YMax ) THEN
                     Mouse_InArea := True
                  ELSE
                     Mouse_InArea := False;
               END;
       END;

END;

{ Ajoute un évènement. }

PROCEDURE Mouse_AddHandler (XMin, XMax, YMin, YMax : Word; Adress : TProcedure);

BEGIN

    IF bMouse_Exist THEN
       BEGIN

          { On peut ajouter un évènement pour autant qu'il reste de la mémoire
            disponible pour le stockage du pointeur sur la procédure et de la
            sauvegarde des coordonnées de la surface délimitée pour son action. }

          IF MemAvail > SizeOf(TListMouseHandle) THEN
             BEGIN

                Inc (cgCurrentProc);

                IF cgCurrentProc = 1 THEN
                   BEGIN

                      { C'est le tout premier évènement.  Sauvegarde du pointeur
                        pour pouvoir ensuite fabriquer la liste. }

                      New (MouseProc);
                      MouseProcFirst := MouseProc;

                      { Sauvegarde du pointeur courant pour pouvoir fabriquer la
                        liste. }

                      MouseProcOld   := MouseProc;

                      { Etant donné que le liste se rempli de bas en haut -le
                        premier introduit est le moins prioritaire, ...-; seul le
                        premier aura un pointeur vers NIL.  Cette méthode permettra
                        à un évènement de recouvrir une surface déjà délimitée par
                        un autre objet. }

                      MouseProc^.Next := NIL;
                   END
                ELSE
                   BEGIN

                      { Ce n'est pas le premier.  Il faut que je crée le lien avec
                        le pointeur NEXT de l'évènement précédent. }

                      MouseProcOld := MouseProc;
                      New (MouseProc);
                      MouseProc^.Next := MouseProcOld;
                      MouseProcFirst := MouseProc;
                   END;

                { Les liens créés, je peux en toute sécurité sauvegarder les
                  données. }

                MouseProc^.Item.XMin    := XMin;
                MouseProc^.Item.XMax    := XMax;
                MouseProc^.Item.YMin    := YMin;
                MouseProc^.Item.YMax    := YMax;
                MouseProc^.Item.Adress_Proc := Adress;

             END;
       END;
END;

{ Cette procédure retire le tout dernier évènement introduit tout en
  conservant la cohérence de la liste. }

PROCEDURE Mouse_RemoveHandler;

BEGIN

    IF bMouse_Exist THEN
       BEGIN

          IF NOT (MouseProc^.Next = NIL) THEN
             BEGIN

               MouseProcFirst := MouseProc^.Next;
               Dispose (MouseProc);
               MouseProc := MouseProcFirst;
               Dec (cgCurrentProc);

             END;
       END;

END;


{ Examine si le clic s'est fait dans une surface délimitée par un évènement.

  Si c'est le cas, alors appel de l'évènement en question. }

PROCEDURE Mouse_Handle;

VAR
   bFin : Boolean;
   bNotFound : Boolean;

BEGIN

    IF bMouse_Exist THEN
       BEGIN

          { Il doit y avoir un process uniquement si on a associé des éléments au
            handler de la souris.  ET SEULEMENT SI LES APPELS AUX DIFFERENTES
            PROCEDURES SONT AUTORISES OU NON. }

          IF cgEnableMouseProc AND (cgCurrentProc > 0) THEN
             BEGIN

                bFin := False;

                { bNotFound sera mis sur True lorsque le clic s'est fait dans une
                  surface non couverte par un handler. }

                bNotFound := False;

                { Pointe sur le tout premier évènement }

                MouseProcOld := MouseProcFirst;

                REPEAT

                   IF Mouse_InArea (MouseProcOld^.Item.XMin, MouseProcOld^.Item.XMax,
                      MouseProcOld^.Item.YMin, MouseProcOld^.Item.YMax) THEN
                      BEGIN

                         { Le clic s'est fait dans une surface à surveiller.  Appel
                           de l'évènement ad'hoc. }

                         MouseProcOld^.Item.Adress_Proc;
                         bFin := True;
                      END
                   ELSE
                      IF (MouseProcOld^.Next = NIL) THEN
                         BEGIN
                            bNotFound := True;
                            bFin := True
                         END
                      ELSE
                         MouseProcOld := MouseProcOld^.Next;

                UNTIL bFin;

       {         IF bNotFound THEN
                   ASM
                      Call hClicNotInArea;
                   END;}

             END;
       END;
END;

{ Retourne TRUE lorsque l'utilisateur maintien le bouton xxx enfoncé et
  renvoi FALSE lorsque ce bouton est relâché. }

FUNCTION Mouse_ReleaseButton (Button : cgMouse_Key) : Boolean; ASSEMBLER;

ASM
   Mov  Ax, 06h
   Mov  Bx, 01h
   Int  33h
END;

{ Cette procédure va attendre jusqu'à ce que le dernier bouton enfoncé ne
  le soit plus; autrement dit jusqu'à ce que l'utilisateur relâche ce même
  bouton.  Ce qui aura pour effet de vider le buffer de la souris. }

PROCEDURE Mouse_Flush;

BEGIN


    IF bMouse_Exist THEN
       REPEAT
       UNTIL NOT (Mouse_ReleaseButton(cgMouse_LastButton));

END;

{ Initialisation }

BEGIN

   { Initialise le boolean d'existence d'un gestionnaire de souris }

   Mouse_Init;

   { Positionne le curseur de la souris en (0,0) }

   Mouse_GotoXy (0,0);

END.
