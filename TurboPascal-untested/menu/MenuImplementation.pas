(*
  Category: SWAG Title: MENU MANAGEMENT ROUTINES
  Original name: 0016.PAS
  Description: Menu Implementation
  Author: LOUIS MONGRAIN
  Date: 03-04-97  13:18
*)

{Menu pour le Multi-jeux # }

Program Game_Menu;
{$M $4000,0,0 }   { 16K stack, no heap }
Uses crt, dos, Printer;

const FormFeed = #12;
      PathLength  = 79;
{----------------------------------------------------------------------------}
  Name1 =''; Megs1 =0; Path1 ='';
  Txt_file1 =''; Run_file1 ='';
  Destination_drive1 = #0 ; Destination_directory1 ='';
  OSystem1 ='Dos, Windows, Windows 95'; Modification_file1 ='';
{----------------------------------------------------------------------------}
  Name2 =''; Megs2 =0; Path2 ='';
  Txt_file2 =''; Run_file2 ='';
  Destination_drive2 = #0; Destination_directory2 = '';
  OSystem2 ='Dos, Windows, Windows 95'; Modification_file2 ='';
{----------------------------------------------------------------------------}
  Name3 =''; Megs3 =0; Path3 ='';
  Txt_file3 =''; Run_file3 ='';
  Destination_drive3 = #0 ; Destination_directory3 = '';
  OSystem3 ='Dos, Windows, Windows 95'; Modification_file3 ='';
{----------------------------------------------------------------------------}
  Name4 =''; Megs4 =0; Path4 ='';
  Txt_file4 =''; Run_file4 ='';
  Destination_drive4 = #0; Destination_directory4 = '';
  OSystem4 ='Dos, Windows, Windows 95'; Modification_file4 ='';
{----------------------------------------------------------------------------}
  Name5 =''; Megs5 =0; Path5 ='';
  Txt_file5 =''; Run_file5 ='';
  Destination_drive5 = #0; Destination_directory5 = '';
  OSystem5 ='Dos, Windows, Windows 95'; Modification_file5 ='';
{----------------------------------------------------------------------------}
  Name6 =''; Megs6 =0; Path6 ='';
  Txt_file6 =''; Run_file6 ='';
  Destination_drive6 = #0; Destination_directory6 = '';
  OSystem6 ='Dos, Windows, Windows 95'; Modification_file6 ='';
{----------------------------------------------------------------------------}
  Name7 =''; Megs7 =0; Path7 ='';
  Txt_file7 =''; Run_file7 ='';
  Destination_drive7 = #0; Destination_directory7 = '';
  OSystem7 ='Dos, Windows, Windows 95'; Modification_file7 ='';
{----------------------------------------------------------------------------}
  Name8 =''; Megs8 =0; Path8 ='';
  Txt_file8 =''; Run_file8 ='';
  Destination_drive8 = #0; Destination_directory8 = '';
  OSystem8 ='Dos, Windows, Windows 95'; Modification_file8 ='';
{----------------------------------------------------------------------------}
  Name9 =''; Megs9 =0; Path9 ='';
  Txt_file9 =''; Run_file9 ='';
  Destination_drive9 = #0; Destination_directory9 = '';
  OSystem9 ='Dos, Windows, Windows 95'; Modification_file9 ='';
{----------------------------------------------------------------------------}
  Name10=''; Megs10=0; Path10='';
  Txt_file10=''; Run_file10='';
  Destination_drive10= #0; Destination_directory10= '';
  OSystem10='Dos, Windows, Windows 95'; Modification_file10='';
{----------------------------------------------------------------------------}
  Name11=''; Megs11=0; Path11='';
  Txt_file11=''; Run_file11='';
  Destination_drive11= #0; Destination_directory11= '';
  OSystem11='Dos, Windows, Windows 95'; Modification_file11='';
{----------------------------------------------------------------------------}
  Name12=''; Megs12=0; Path12='';
  Txt_file12=''; Run_file12='';
  Destination_drive12= #0; Destination_directory12= '';
  OSystem12='Dos, Windows, Windows 95'; Modification_file12='';
{----------------------------------------------------------------------------}
  Name13=''; Megs13=0; Path13='';
  Txt_file13=''; Run_file13='';
  Destination_drive13= #0; Destination_directory13= '';
  OSystem13='Dos, Windows, Windows 95'; Modification_file13='';
{----------------------------------------------------------------------------}
  Name14=''; Megs14=0; Path14='';
  Txt_file14=''; Run_file14='';
  Destination_drive14= #0; Destination_directory14= '';
  OSystem14='Dos, Windows, Windows 95'; Modification_file14='';
{----------------------------------------------------------------------------}
  Name15=''; Megs15=0; Path15='';
  Txt_file15=''; Run_file15='';
  Destination_drive15= #0; Destination_directory15= '';
  OSystem15='Dos, Windows, Windows 95'; Modification_file15='';
{----------------------------------------------------------------------------}
  Name16=''; Megs16=0; Path16='';
  Txt_file16=''; Run_file16='';
  Destination_drive16= #0; Destination_directory16= '';
  OSystem16='Dos, Windows, Windows 95'; Modification_file16='';
{----------------------------------------------------------------------------}
  Name17=''; Megs17=0; Path17='';
  Txt_file17=''; Run_file17='';
  Destination_drive17= #0; Destination_directory17='';
  OSystem17='Dos, Windows, Windows 95'; Modification_file17='';
{----------------------------------------------------------------------------}
  Name18=''; Megs18=0; Path18='';
  Txt_file18=''; Run_file18='';
  Destination_drive18= #0; Destination_directory18='';
  OSystem18='Dos, Windows, Windows 95'; Modification_file18='';
{----------------------------------------------------------------------------}
  Name19=''; Megs19=0; Path19='';
  Txt_file19=''; Run_file19='';
  Destination_drive19= #0; Destination_directory19='';
  OSystem19='Dos, Windows, Windows 95'; Modification_file19='';
{----------------------------------------------------------------------------}
  Name20=''; Megs20=0; Path20='';
  Txt_file20=''; Run_file20='';
  Destination_drive20= #0; Destination_directory20= '';
  OSystem20='Dos, Windows, Windows 95'; Modification_file20='';
{----------------------------------------------------------------------------}
  Name21=''; Megs21=0; Path21='';
  Txt_file21=''; Run_file21='';
  Destination_drive21= #0; Destination_directory21= '';
  OSystem21='Dos, Windows, Windows 95'; Modification_file21='';
{----------------------------------------------------------------------------}
  Name22=''; Megs22=0; Path22='';
  Txt_file22=''; Run_file22='';
  Destination_drive22= #0; Destination_directory22= '';
  OSystem22='Dos, Windows, Windows 95'; Modification_file22='';
{----------------------------------------------------------------------------}
  Name23=''; Megs23=0; Path23='';
  Txt_file23=''; Run_file23='';
  Destination_drive23= #0; Destination_directory23= '';
  OSystem23='Dos, Windows, Windows 95'; Modification_file23='';
{----------------------------------------------------------------------------}
  Name24=''; Megs24=0; Path24='';
  Txt_file24=''; Run_file24='';
  Destination_drive24= #0; Destination_directory24= '';
  OSystem24='Dos, Windows, Windows 95'; Modification_file24='';
{----------------------------------------------------------------------------}
  Name25=''; Megs25=0; Path25='';
  Txt_file25=''; Run_file25='';
  Destination_drive25= #0; Destination_directory25= '';
  OSystem25='Dos, Windows, Windows 95'; Modification_file25='';
{----------------------------------------------------------------------------}
  Name26=''; Megs26=0; Path26='';
  Txt_file26=''; Run_file26='';
  Destination_drive26= #0; Destination_directory26= '';
  OSystem26='Dos, Windows, Windows 95'; Modification_file26='';
{----------------------------------------------------------------------------}
  Name27=''; Megs27=0; Path27='';
  Txt_file27=''; Run_file27='';
  Destination_drive27= #0; Destination_directory27= '';
  OSystem27='Dos, Windows, Windows 95'; Modification_file27='';
{----------------------------------------------------------------------------}
  Name28=''; Megs28=0; Path28='';
  Txt_file28=''; Run_file28='';
  Destination_drive28= #0; Destination_directory28= '';
  OSystem28='Dos, Windows, Windows 95'; Modification_file28='';
{----------------------------------------------------------------------------}
  Name29=''; Megs29=0; Path29='';
  Txt_file29=''; Run_file29='';
  Destination_drive29= #0; Destination_directory29= '';
  OSystem29='Dos, Windows, Windows 95'; Modification_file29='';
{----------------------------------------------------------------------------}
  Name30=''; Megs30=0; Path30='';
  Txt_file30=''; Run_file30='';
  Destination_drive30= #0; Destination_directory30= '';
  OSystem30='Dos, Windows, Windows 95'; Modification_file30='';
{----------------------------------------------------------------------------}
  Name31=''; Megs31=0; Path31='';
  Txt_file31=''; Run_file31='';
  Destination_drive31= #0; Destination_directory31= '';
  OSystem31='Dos, Windows, Windows 95'; Modification_file31='';
{----------------------------------------------------------------------------}
  Name32=''; Megs32=0; Path32='';
  Txt_file32=''; Run_file32='';
  Destination_drive32= #0; Destination_directory32= '';
  OSystem32='Dos, Windows, Windows 95'; Modification_file32='';
{----------------------------------------------------------------------------}
  Name33=''; Megs33=0; Path33='';
  Txt_file33=''; Run_file33='';
  Destination_drive33= #0; Destination_directory33= '';
  OSystem33='Dos, Windows, Windows 95'; Modification_file33='';
{----------------------------------------------------------------------------}
  Name34=''; Megs34=0; Path34='';
  Txt_file34=''; Run_file34='';
  Destination_drive34= #0; Destination_directory34= '';
  OSystem34='Dos, Windows, Windows 95'; Modification_file34='';
{----------------------------------------------------------------------------}
  Name35=''; Megs35=0; Path35='';
  Txt_file35=''; Run_file35='';
  Destination_drive35= #0; Destination_directory35= '';
  OSystem35='Dos, Windows, Windows 95'; Modification_file35='';
{----------------------------------------------------------------------------}
  Name36=''; Megs36=0; Path36='';
  Txt_file36=''; Run_file36='';
  Destination_drive36= #0; Destination_directory36= '';
  OSystem36='Dos, Windows, Windows 95'; Modification_file36='' ;
{----------------------------------------------------------------------------}
  Name37=''; Megs37=0; Path37='';
  Txt_file37=''; Run_file37='';
  Destination_drive37= #0; Destination_directory37= '';
  OSystem37='Dos, Windows, Windows 95'; Modification_file37='';
{----------------------------------------------------------------------------}
  Name38=''; Megs38=0; Path38='';
  Txt_file38=''; Run_file38='';
  Destination_drive38= #0; Destination_directory38= '';
  OSystem38='Dos, Windows, Windows 95'; Modification_file38='';
{----------------------------------------------------------------------------}
  Name39=''; Megs39=0; Path39='';
  Txt_file39=''; Run_file39='';
  Destination_drive39= #0; Destination_directory39= '';
  OSystem39='Dos, Windows, Windows 95'; Modification_file39='';
{----------------------------------------------------------------------------}
  Name40=''; Megs40=0; Path40='';
  Txt_file40=''; Run_file40='';
  Destination_drive40= #0; Destination_directory40= '';
  OSystem40='Dos, Windows, Windows 95'; Modification_file40='';
{----------------------------------------------------------------------------}
Type  FileName  = string[PathLength];

VAR  Name : String[30];
     Megs : integer;
     Path : Filename;
     Txt_file : String[12];
     Run_file : String[12];
     OSystem : String[30];
     Source_drive : Char;
     Destination_drive : Char;
     Destination_drive_Access : Boolean;
     Destination_directory_Access : Boolean;
     Destination_directory : String;
     Modification_file : String[12];
     SpaceDisk : LongInt;
     PathFileName: FileName;
     ProgramCommandCom : String;
     ProgramName, CmdLine: string;
     Fichier : Text;
     Source: PathStr;
     Choice : integer;
     Cnt : integer;
     I, J, K : integer;
     Ch, Choix : Char;
     IOError : integer;
     Quit : Boolean;
     Erreur : Boolean;
     Touche_F1 : Boolean;
     Touche_tab : Boolean;
     Touche_Esc : Boolean;
     Touche_Bas : Boolean;
     Touche_haut : Boolean;
     Touche_insert : boolean;
{----------------------------------------------------------------------------}
Procedure CursorInsert;     { Curseur formé de 7 lignes(de pixels)#1 }
  VAR
    Regs : registers;
  BEGIN
      { Code d'interruption pour indiquer changement de curseur }
      regs.AH:=$01;
      regs.CH:=$0;  { CH (High): haut du curseur, ligne (de pixels) #0 }
      regs.CL:=$7;  { CL (Low): bas du curseur, ligne (de pixels) #7 }
      { Interruption niveau machine #10 pour changer le curseur }
      intr($10,Regs);
  END;
{----------------------------------------------------------------------------}
Procedure Normalcursor;     { Curseur formé de 2 lignes(de pixels)#6 }
  VAR
    Regs : registers;
  BEGIN
      { Code d'interruption pour indiquer changement de curseur }
      regs.AH:=$01;
      regs.CH:=$6;  { CH (High): haut du curseur, ligne (de pixels) #6 }
      regs.CL:=$7;  { CL (Low): bas du curseur, ligne (de pixels) #7 }
      { Interruption niveau machine #10 pour changer le curseur }
      intr($10,Regs);
  END;
{----------------------------------------------------------------------------}
Procedure Effacecursor;         { Pour effacer le curseur }
  VAR
    Regs : registers;
  BEGIN
      { Code d'interruption pour indiquer changement de curseur }
      regs.AH:=$01;
      regs.CH:=$20;  { Valeur nulle }
      regs.CL:=$20;  { Valeur nulle }
      { Interruption niveau machine #10 pour changer le curseur }
      intr($10,Regs);
  END;
{----------------------------------------------------------------------------}
Procedure fin (Erreur:Boolean);         { Quitte le programme principal }

  Begin  { Procedure Fin }
    Window (1, 1, 80, 25);      {Création de fenetre (1, 1) à (80, 25)}
    Textcolor (7);              {Couleur du texte à la sortie Lightgray}
    TextBackground (0);         {Couleur du background black}
    ClrScr;                     { Pour effacer l'écran }
    NormalCursor;
    Gotoxy(3,2); Writeln('Thank you to choose The CD-ROM Master''s');
    Halt(1)
  End;  { Procedure Fin }
{----------------------------------------------------------------------------}
Procedure BoitePourQuitter(Var ChoixMenuPrecedent : Char);
 Begin
   EffaceCursor;
   Window (32, 20, 73, 20);    {Création de fenetre (28, 5) à (74, 6)}
   Textbackground (1);       { Couleur de la boite bleu }
   Clrscr;                      { Pour effacer l'écran }
   TextColor (15);                  { Couleur du texte blanc }
   Write ('Do you really want to Quit? (Y)es or (N)o');
   Textcolor (14);                    {Couleur des réponses yellow}
   Gotoxy (30, 1);   Write ('Y');
   Gotoxy (39, 1);   Write ('N');
   Repeat
     ChoixMenuPrecedent := Readkey;
   Until (Upcase(ChoixMenuPrecedent) = char(78)) or
         (Upcase(ChoixMenuPrecedent) = char(89));
   Clrscr;
   Choix := ChoixMenuPrecedent;
   NormalCursor;
 end;
{----------------------------------------------------------------------------}
Procedure DessineBoite
     (x1,y1,x2,y2,Background:integer ;
      LigneContour:Boolean ; LigneContourGauche,LigneContourDroite:integer ;
       Shadow:Boolean ; ShadowBackgroundDroite,ShadowBackgroundBas:integer);
Begin
  Window (x1,y1,x2,y2);
  TextBackground (Background);
  ClrScr;
  Window (x1,y1,x2+1,y2+1);

  If LigneContour = true then
  Begin
    TextColor (LigneContourDroite);
    Gotoxy(1,1); Write('┌');
    For I := 2 to (x2-x1) do
    Begin Gotoxy(I,1); Write('─'); end;
    Writeln;
    For J := 2 to (y2-y1) do
    Begin Gotoxy(1,J); Write('│'); end;
    Writeln;
    Gotoxy(1,y2-y1+1); Write('└');
    TextColor (LigneContourGauche);
    Gotoxy(x2-x1+1,1); Write('┐');
    For J := 2 to (y2-y1) do
    Begin Gotoxy(x2-x1+1,J); Write('│'); end;
    Writeln;
    For I := 2 to (x2-x1) do
    Begin Gotoxy(I,y2-y1+1); Write('─'); end;
    Writeln;
    Gotoxy(x2-x1+1,y2-y1+1); Write('┘');
  end;

  If Shadow = true then
  Begin
    Window (x1,y1,x2+2,y2+1);
    TextColor (0);
    TextBackground(ShadowBackgroundDroite);
    Gotoxy (x2-x1+2,1); Write ('▄');
    For J := 2 to (y2-y1+1) do
    Begin Gotoxy(x2-x1+2,J); Write ('█'); end;
    TextBackground(ShadowBackgroundBas);
    For I := 2 to (x2-x1+2) do
    Begin Gotoxy(I,y2-y1+2); Write ('▀'); end;
  end;
end;
{----------------------------------------------------------------------------}
Procedure Read_Char(x1,y1,x2,y2,Background:integer;KindData:String);
Label Escape, Fleche_bas, Fleche_haut, Tabulation,
      En_attente_de_commande;

Begin
Touche_tab := False;
Touche_Esc := False;
Touche_bas := False;
Touche_haut := False;
Goto En_attente_de_commande;

Escape :
  Begin Touche_Esc := true; exit; end;

Fleche_bas :
  Begin Touche_bas := true; exit; end;

Fleche_haut :
  Begin Touche_haut := true; exit; end;

Tabulation :
  Begin Touche_tab := true; exit; end;

En_attente_de_commande:
  Begin
    Repeat
      TextColor(14);
      Window (x1,y1,x2,y2);
      Textbackground (Background);
      ClrScr;                          { Pour effacer l'écran }
      K := 1;
      If (KindData='Letter') then
      Begin Repeat
              If (K=3) then K:=1;
              choix := Readkey;
              If Choix = char(27) then goto Escape
              Else If Choix = char(9) then goto Tabulation
              Else If Choix = char(0) then
              Begin
                Choix := Readkey;
                If Choix = char(80) then goto Fleche_bas
                Else If Choix = char(72) then goto Fleche_haut
                Else inc(K);
              end;
              If (K=2) and (Upcase(Choix) in ['A'..'Z']) then inc(K);
            Until (Upcase(Choix) in ['A'..'Z']) and (K=1); end

      Else If (KindData='Number') then
                Begin Repeat
                        If (K=3) then K:=1;
                        choix := Readkey;
                        If Choix = char(27) then goto Escape;
                        If Choix = Char(0) then inc(K);
                        If (K=2) and (Upcase(Choix) in ['A'..'Z']) then inc(K);
                      Until (Upcase(Choix) in ['1'..'9']) and (K=1) ; end
      Else If (KindData='All') then
                Begin Repeat
                        If (K=3) then K:=1;
                        choix := Readkey;
                        If Choix = char(27) then goto Escape;
                        If Choix = Char(0) then inc(K);
                        If (K=2) and (Upcase(Choix) in ['A'..'Z']) then inc(K);
                      Until (Upcase(Choix) in ['1'..'9']) or
                            (Upcase(Choix) in ['A'..'Z']) and (K=1); end;
      Write (Upcase(Choix));
      ch := Readkey;
      If (ch=Char(0)) then ch:=Readkey;
    Until (ch = char(13));
  end;
end;
{----------------------------------------------------------------------------}
Procedure Read_integer (Var NumdataFinal:Integer);
Label Backspace, Effacement, Escape, Fleche_droite, Fleche_gauche,
      Insertion, Key_F1, Tabulation, En_attente_de_commande;


Const Base = 10;
      Sentinel = char(13);
var Touche : char;
    Digit : integer;
    NumData : integer;
    Position : integer;
    String_data : String;
    Fleche_active : Boolean;

Begin
   I := 1;
   Digit := 0;
   Numdata := 0;
   String_data := '';
   Touche_F1 := False;
   Touche_Esc := False;
   Fleche_active := false;
   Goto En_attente_de_commande;

   Backspace :
     Begin
       If Fleche_active = true then
       Begin
         Delete(String_data,I-1,1);
         Gotoxy((I-1),1);
         For Position := (I-1) to Length(String_data) do
         Begin Write(String_data[Position]) end;
         Write(' '); Gotoxy((I-1),1); Dec(I);
       end
       Else If I >= 2 then
            Begin
              Delete(String_data,I-1,1);
              Gotoxy(I-1,1); Write(char(0));
              Gotoxy(I-1,1); Dec(I);
            end;
       goto En_attente_de_commande;
     end;

   Effacement :
     Begin
         Delete(String_data,I,1);
         For Position := I to Length(String_data) do
         Begin Write(String_data[Position]) end;
         Write(' '); Gotoxy(I,1);
         goto En_attente_de_commande
       end;

   Escape :
     Begin Touche_Esc := true; exit; end;

   Fleche_droite :
     Begin
       Fleche_active := True;
       If I <= Length(String_data) then
       Begin Gotoxy(I+1,1); Inc(I); end;
       goto En_attente_de_commande
     end;

   Fleche_gauche :
     Begin
       Fleche_active := True;
       If I > 1 then
       Begin Gotoxy(I-1,1); Dec(I); end;
       goto En_attente_de_commande
     end;

   Insertion :
     Begin
       If Touche_insert = False then
       Begin touche_insert := true; CursorInsert; end
       Else If Touche_insert = true then
       Begin touche_insert := false; Normalcursor; end;
       goto En_attente_de_commande
     end;

   Key_F1 :
     Begin Touche_F1 := true ; exit; end;

   En_attente_de_commande :
   Begin
     Repeat
     Touche := Readkey;
     ch := Touche;
     If (I > Length(String_data)) then Fleche_active := false;
     If ((Touche >= '0') and (Touche <= '9')) then
     Begin
       If ((Touche_insert = True) and (Fleche_active = True)) then
       Begin
         Insert(Touche,String_data,I);
         For Position := I to Length(String_data) do
         Begin Write(String_data[Position]) end;
         Gotoxy(I+1,1); Inc(I);
       end
       Else If ((Touche_insert = False) or (Fleche_active = false)) then
            Begin
              String_data[I] := Touche;
              If Fleche_active = false then String_data := String_data + String_data[I];
              Write(String_data[I]);
              Inc(I);
            end;
     end
     Else If ch = char(27) then goto Escape
     Else If ch = char(8) then goto Backspace
     Else If ch = char(0) then
          Begin
            ch := Readkey;
                 If ch = char(75) then goto Fleche_gauche
            Else If ch = char(59) then goto Key_F1
            Else If ch = char(77) then goto Fleche_droite
            Else If ch = char(83) then goto Effacement
            Else If ch = char(82) then goto Insertion
          end;
     Until (ch = Sentinel);
     For Position := 1 to Length(String_data) do
     Begin
       Digit := ORD(String_data[Position]) - ORD('0');
       Numdata := base * Numdata + Digit;
     end;
   end;
   NumDataFinal := Numdata;
 End;
{----------------------------------------------------------------------------}
Procedure Read_string (Var RepFinal:String);
Label Backspace, Effacement, Escape, Fleche_droite, Fleche_gauche, Fleche_bas,
      Fleche_haut, Insertion, Key_F1, Tabulation, En_attente_de_commande;

Const Sentinel = char(13);
var Rep : String;
    Touche : char;
    Position : integer;
    Fleche_active : Boolean;

Begin
   I := 1;
   Rep := '';
   Touche_tab := False;
   Touche_Esc := False;
   Touche_bas := False;
   Touche_haut := False;
   Fleche_active := false;
   Goto En_attente_de_commande;

   Backspace :
     Begin
       If Fleche_active = true then
       Begin
         Delete(Rep,I-1,1);
         Gotoxy((I-1),1);
         For Position := (I-1) to Length(Rep) do
         Begin Write(Rep[Position]) end;
         Write(' '); Gotoxy((I-1),1); Dec(I);
       end
       Else If I >= 2 then
            Begin
              Delete(Rep,I-1,1);
              Gotoxy(I-1,1); Write(char(0));
              Gotoxy(I-1,1); Dec(I);
            end;
       goto En_attente_de_commande;
     end;

   Effacement :
     Begin
         Delete(Rep,I,1);
         For Position := I to Length(Rep) do
         Begin Write(Rep[Position]) end;
         Write(' '); Gotoxy(I,1);
         goto En_attente_de_commande
       end;

   Escape :
     Begin Touche_Esc := true; exit; end;

   Fleche_bas :
     Begin Touche_bas := true; exit; end;

   Fleche_haut :
     Begin Touche_haut := true; exit; end;

   Fleche_droite :
     Begin
       Fleche_active := True;
       If I <= Length(Rep) then
       Begin Gotoxy(I+1,1); Inc(I); end;
       goto En_attente_de_commande
     end;

   Fleche_gauche :
     Begin
       Fleche_active := True;
       If I > 1 then
       Begin Gotoxy(I-1,1); Dec(I); end;
       goto En_attente_de_commande
     end;

   Insertion :
     Begin
       If Touche_insert = False then
       Begin touche_insert := true; CursorInsert; end
       Else If Touche_insert = true then
       Begin touche_insert := false; Normalcursor; end;
       goto En_attente_de_commande
     end;

   Tabulation :
     Begin Touche_tab := true; exit; end;

   En_attente_de_commande :
   Begin
     Repeat
     Touche := Readkey;
     ch := Touche;
     If (I > Length(Rep)) then Fleche_active := false;
     If ((Touche >= char(32)) and (Touche <= char(255))) then
     Begin
       If ((Touche_insert = True) and (Fleche_active = True)) then
       Begin
         Insert(Touche,Rep,I);
         For Position := I to Length(Rep) do
         Begin Write(Rep[Position]) end;
         Gotoxy(I+1,1); Inc(I);
       end
       Else If ((Touche_insert = False) or (Fleche_active = false)) then
            Begin
              Rep[I] := Touche;
              If Fleche_active = false then Rep := Rep + Rep[I];
              Write(Rep[I]);
              Inc(I);
            end;
     end
     Else If ch = char(27) then goto Escape
     Else If ch = char(8) then goto Backspace
     Else If ch = char(9) then goto Tabulation
     Else If ch = char(0) then
          Begin
            ch := Readkey;
                 If ch = char(75) then goto Fleche_gauche
            Else If ch = char(77) then goto Fleche_droite
            Else If ch = char(83) then goto Effacement
            Else If ch = char(82) then goto Insertion
            Else If ch = char(80) then goto Fleche_bas
            Else If ch = char(72) then goto Fleche_haut
          end;
     Until (ch = Sentinel);
   end;
   RepFinal := Rep;
 End;
{---------------------------------------------------------------------------}
Procedure Centrer(Phrase:String ; x1,x2,Ligne:integer);
Begin
  Gotoxy(2,Ligne);
  For I := 1 to (((x2-x1)-Length(Phrase)) div 2) do Write (' ');
  Write(Phrase);
end;
{----------------------------------------------------------------------------}
Procedure Message_erreur (Message:integer;CouleurFond:integer);
Var DosError_Message : String[80];
    IOResult_Message : String[80];
Begin
  EffaceCursor;
  DessineBoite(9,7,72,19,4,true,0,12,True,CouleurFond,CouleurFond);
  DessineBoite(12,8,69,10,4,true,12,0,False,12,12);
  TextColor (14); Centrer('Errors Messages',12,69,2);
  DessineBoite(12,11,69,18,4,true,12,0,False,12,12);
  TextColor (15);
  Case Message of
  1: Begin
  Case DosError of
     2 : DosError_Message := 'File not found';
     3 : DosError_Message := 'Path not found';
     5 : DosError_Message := 'Access denied';
     6 : DosError_Message := 'Invalid handle';
     8 : DosError_Message := 'Not enough memory';
    10 : DosError_Message := 'Invalid environment';
    11 : DosError_Message := 'Invalid format';
    18 : DosError_Message := 'No more files';
  end;
       Gotoxy(22,3);
       Write('Dos Error number: ', DosError);
       Centrer(DosError_Message,12,69,4);
       DosError:=0;
     end;

  2: Begin
  Case IOError of
     1 : IOResult_message := 'Invalid function number';
     2 : IOResult_message := 'File not found';
     3 : IOResult_message := 'Path not found';
     4 : IOResult_message := 'Too many open files';
     5 : IOResult_message := 'File access denied';
     6 : IOResult_message := 'Invalid file handle';
    12 : IOResult_message := 'Invalid file access code';
    15 : IOResult_message := 'Invalid drive number';
    16 : IOResult_message := 'Cannot remove current directory';
    17 : IOResult_message := 'Cannot rename across drives';
    18 : IOResult_message := 'No more files';
   100 : IOResult_message := 'Disk read error';
   101 : IOResult_message := 'Disk write error';
   102 : IOResult_message := 'File not assigned';
   103 : IOResult_message := 'File not open';
   104 : IOResult_message := 'File not open for input';
   105 : IOResult_message := 'File not open for output';
   106 : IOResult_message := 'Invalid numeric format';
   150 : IOResult_message := 'Disk is write-protected';
   151 : IOResult_message := 'Bad drive request struct length';
   152 : IOResult_message := 'Drive not ready';
   154 : IOResult_message := 'CRC error in data';
   156 : IOResult_message := 'Disk seek error';
   157 : IOResult_message := 'Unknown media type';
   158 : IOResult_message := 'Sector Not Found';
   159 : IOResult_message := 'Printer out of paper';
   160 : IOResult_message := 'Device write fault (Printer may be off-line!)';
   161 : IOResult_message := 'Device read fault';
   162 : IOResult_message := 'Hardware failure';
   200 : IOResult_message := 'Division by zero';
   201 : IOResult_message := 'Range check error';
   202 : IOResult_message := 'Stack overflow error';
   203 : IOResult_message := 'Heap overflow error';
   204 : IOResult_message := 'Invalid pointer operation';
   205 : IOResult_message := 'Floating point overflow';
   206 : IOResult_message := 'Floating point underflow';
   207 : IOResult_message := 'Invalid floating point operation';
   208 : IOResult_message := 'Overlay manager not installed';
   209 : IOResult_message := 'Overlay file read error';
   210 : IOResult_message := 'Object not initialized';
   211 : IOResult_message := 'Call to abstract method';
   212 : IOResult_message := 'Stream registration error';
   213 : IOResult_message := 'Collection index out of range';
   214 : IOResult_message := 'Collection overflow error';
   215 : IOResult_message := 'Arithmetic overflow error';
   216 : IOResult_message := 'General Protection fault';
  end;
       Gotoxy(20,3);
       Write('IO Error number: ', IOError);
       Centrer(IOResult_message,12,69,4);
     end;

  3: Begin
       Centrer('You don''t have enough free space on drive "'+Destination_Drive+'"',12,69,3);
     end;

  4: Begin
       Centrer('Please enter the source drive.',12,69,3);
     end;
  5: Begin
       Centrer('Please Enter the destination drive',12,69,3);
     end;
  6: Begin
       Centrer('Please enter the destination directory',12,69,3);
     end; end;

  TextColor (15);

  Centrer ('Press <Enter> to continue!',12,69,7);
  Readln;
 end;
{----------------------------------------------------------------------------}
Procedure Barre_menu_bas(Ecran:String; Couleur:integer);
Begin
  Window (1, 25, 80, 25);
  Textbackground (Couleur);
  Clrscr;
  If (Ecran = 'Principal') then
     Begin
       TextColor(15);
       Gotoxy(51,1); Write ('Made by: ');
       TextColor(14);
       Gotoxy(60,1); Write ('The CD-ROM Master''s');

       TextColor(15);
       Gotoxy(3,1); Write ('  : More games');
       TextColor(14);
       Gotoxy(3,1); Write ('F1');

       TextColor(15);
       Gotoxy(20,1); Write ('   : Quit');
       TextColor(14);
       Gotoxy(20,1); Write ('ESC');
     end
  Else Begin
         TextColor(15);
         Gotoxy(68,1); Write ('   : Cancel');
         TextColor(14);
         Gotoxy(68,1); Write ('ESC');
       end;
end;
{----------------------------------------------------------------------------}
Procedure BackGroundPrincipal(Couleur : integer);
Begin
  Window (1, 1, 80, 25);
  Textbackground (7);
  Clrscr;

  Window (1, 1, 80, 1);
  Textbackground (Couleur);
  Clrscr;
  TextColor(15);
  Centrer('Installation menu for the Multi-Jeux Tome  ',1,80,1);
end;
{----------------------------------------------------------------------------}
 Function Open(PathFileName:FileName;CouleurFond:integer): boolean;
 var fp : Text;
 begin
   {$I-}
   Assign(fp,PathFileName);
   Reset(fp);
   IOError := IOResult;
   {$I+}
   IF IOError <> 0 then Begin Open:=False; Message_Erreur(2,CouleurFond); end
   Else Begin Open:=True; Close(fp); end;
 end { Open };
{----------------------------------------------------------------------------}
Procedure Message_Traitement(PathFileName:FileName);
Begin
  EffaceCursor;
  BackGroundPrincipal(1);
  DessineBoite(9,7,72,19,1,true,0,9,True,7,7);
  DessineBoite(12,8,69,10,1,true,9,0,False,9,9);
  TextColor (14); Gotoxy (22,2);
  Write ('Status Information');
  DessineBoite(12,11,69,18,1,true,9,0,False,9,9);
  TextColor (15); Centrer('Applying modification',12,69,2);
  TextColor(14);  Centrer(PathFileName,12,69,3);
  TextColor (15) ; Centrer('Please Wait',12,69,7);
  Delay(1500);
end;

{----------------------------------------------------------------------------}
Procedure Modification_Ds_Fichier(PathFileName:FileName;
                                  OriginalString, NewString : String);
Var Match : Boolean;
    ResetTab : Integer;
    OldFile : File of Char;
    NewFile : File of Char;
    StringReadLine : String;
    TabReadLine : Array [1..255] of Char;
    Path : DirStr;
    FileName : NameStr;
    Extension : ExtStr;

Begin
  Assign(OldFile,PathFileName);
  Message_Traitement(PathFileName);
  If (open(PathFileName,7)) then
  Begin
    Fsplit(PathFileName,Path,FileName,Extension);
    Assign(NewFile,Path+FileName+'.TMP');
    Rewrite(NewFile);
    Reset(OldFile);
    While not EOF(OldFile) do
    Begin
      For ResetTab:= 1 to 255 do TabReadLine[ResetTab]:=#0;
      I:=1;
      Repeat
        Read(OldFile, ch);
        TabReadLine[I]:=ch;
        inc(I);
      until (ch=Char(10)) or EOF(OldFile);
      StringReadLine:=TabReadLine;
      For J := 1 to I do
      Begin
        If Upcase(OriginalString[1])=Upcase(TabReadLine[J]) then
        Begin
          Inc(J);
          K:=2;
          Match := True;
          While Match and (K <= Length(OriginalString)) do
          Begin
            If Upcase(OriginalString[K])=Upcase(TabReadLine[J]) then
            Begin Inc(J); Inc(K); end
            Else Match:=False;
          end;
          If Match then
          Begin
            J := J-Length(OriginalString);
            Delete(StringReadLine,J,Length(OriginalString));
            Insert(NewString,StringReadLine,J);
            J := J+(Length(OriginalString)-1);
          end;
        end;
      end;
      K:=1;
      For ResetTab:= 1 to 255 do TabReadLine[ResetTab]:=#0;
      Repeat
        TabReadLine[K]:=StringReadLine[K];
        Inc(K);
      Until StringReadLine[K]=#0;
      I:=1;
      Repeat
        Write(NewFile,TabReadLine[I]);
        inc(I);
      until (TabReadLine[I]=#0);
    end;
  Close(OldFile);
  Close(NewFile);
  Rename(OldFile,Path+FileName+'.OLD');
  Rename(NewFile,PathFileName);
  Delay(1500);
  TextColor (15) ; Centrer('Press <Enter> to continue!',12,69,7);
  Readln;
  end;
end;
{----------------------------------------------------------------------------}
Procedure Manual_installation(TypeOfInstallation:integer);
Begin
  EffaceCursor;
  BackGroundPrincipal(1);
  DessineBoite(9,7,72,19,1,true,0,9,True,7,7);
  DessineBoite(12,8,69,10,1,true,9,0,False,1,1);
  TextColor (14);
  Centrer('Special installation',12,69,2);
  DessineBoite(12,11,69,18,1,true,9,0,False,1,1);
  TextColor (15); Centrer('Please start in '+OSystem,12,69,3);
  If (TypeOfInstallation=1) then Begin
  TextColor(14);  Centrer(Source_drive+':\'+Path+'\'+Run_file,12,69,4); end
  Else Begin
   TextColor(14);
   Centrer(Destination_drive+':\'+Destination_directory+'\'+Run_file,12,69,4);
       end;
  TextColor (15) ; Centrer('Press <Enter> to continue!',12,69,7);
  Readln;
end;
{----------------------------------------------------------------------------}
Procedure ExecuteExec(ProgramName,CmdLine:String);
  Begin
    BackGroundPrincipal(1);
    Window(1,2,80,25); TextBackGround(0); TextColor(7); ClrScr;
    SwapVectors;
    ChDir(Source_drive+':\'+Path);
    Exec(ProgramName,CmdLine);
    SwapVectors;
    IF DOSError <> 0 then Begin Message_Erreur(1,0); exit; end;
  end;
{----------------------------------------------------------------------------}
Procedure Install_game;

Begin
  NormalCursor;
                {---------------------------------------------}
  If (Name=Name1 ) then Begin
                        end
                {---------------------------------------------}
  Else If (Name=Name2 ) then Begin
                             end
                {---------------------------------------------}
  Else If (Name=Name3 ) then Begin
                             end
                {---------------------------------------------}
  Else If (Name=Name4 ) then Begin
                             end
                {---------------------------------------------}
  Else If (Name=Name5 ) then Begin
                             end
                {---------------------------------------------}
  Else If (Name=Name6 ) then Begin
                             end
                {---------------------------------------------}
  Else If (Name=Name7 ) then Begin
                             end
                {---------------------------------------------}
  Else If (Name=Name8 ) then Begin
                             end
                {---------------------------------------------}
  Else If (Name=Name9 ) then Begin
                             end
                {---------------------------------------------}
  Else If (Name=Name10) then Begin
                             end
                {---------------------------------------------}
  Else If (Name=Name11) then Begin
                             end
                {---------------------------------------------}
  Else If (Name=Name12) then Begin
                             end
                {---------------------------------------------}
  Else If (Name=Name13) then Begin
                             end
                {---------------------------------------------}
  Else If (Name=Name14) then Begin
                             end
                {---------------------------------------------}
  Else If (Name=Name15) then Begin
                             end
                {---------------------------------------------}
  Else If (Name=Name16) then Begin
                             end
                {---------------------------------------------}
  Else If (Name=Name17) then Begin
                             end
                {---------------------------------------------}
  Else If (Name=Name18) then Begin
                             end
                {---------------------------------------------}
  Else If (Name=Name19) then Begin
                             end
                {---------------------------------------------}
  Else If (Name=Name20) then Begin
                             end
                {---------------------------------------------}
  Else If (Name=Name21) then Begin
                             end
                {---------------------------------------------}
  Else If (Name=Name22) then Begin
                             end
                {---------------------------------------------}
  Else If (Name=Name23) then Begin
                             end
                {---------------------------------------------}
  Else If (Name=Name24) then Begin
                             end
                {---------------------------------------------}
  Else If (Name=Name25) then Begin
                             end
                {---------------------------------------------}
  Else If (Name=Name26) then Begin
                             end
                {---------------------------------------------}
  Else If (Name=Name27) then Begin
                             end
                {---------------------------------------------}
  Else If (Name=Name28) then Begin
                             end
                {---------------------------------------------}
  Else If (Name=Name29) then Begin
                             end
                {---------------------------------------------}
  Else If (Name=Name30) then Begin
                             end
                {---------------------------------------------}
  Else If (Name=Name31) then Begin
                             end
                {---------------------------------------------}
  Else If (Name=Name32) then Begin
                             end
                {---------------------------------------------}
  Else If (Name=Name33) then Begin
                             end
                {---------------------------------------------}
  Else If (Name=Name34) then Begin
                             end
                {---------------------------------------------}
  Else If (Name=Name35) then Begin
                             end
                {---------------------------------------------}
  Else If (Name=Name36) then Begin
                             end
                {---------------------------------------------}
  Else If (Name=Name37) then Begin
                             end
                {---------------------------------------------}
  Else If (Name=Name38) then Begin
                             end
                {---------------------------------------------}
  Else If (Name=Name39) then Begin
                             end
                {---------------------------------------------}
  Else If (Name=Name40) then Begin
                             end;
                {---------------------------------------------}
end;
{----------------------------------------------------------------------------}
Procedure Menu_texte;

Var Question_Answer : Char;
    Printer_Device : String[4];

Begin
  If Txt_file <> '' then Begin
  EffaceCursor;
  DessineBoite(9,7,72,19,5,true,0,13,True,3,3);
  DessineBoite(12,8,69,10,5,true,13,0,False,13,13);
  TextColor (14); Centrer('Text file Menu',12,69,2);
  DessineBoite(12,11,69,18,5,true,13,0,False,13,13);
  TextColor(15);
  Centrer('Before the installation, you must read',12,69,2);
  Centrer('the text file for more informations about the game.',12,69,3);
  TextColor(14); Centrer('('+Txt_file+')',12,69,4); TextColor(15);
  Centrer ('Press <Enter> to continue!',12,69,7);
  Readln;

  Source := FSearch('COMMAND.COM','C:\WINDOWS');
  if Source = '' then ProgramCommandCom := 'c:\command.com'
  Else ProgramCommandCom := 'c:\windows\command.com';

  CmdLine := '/c Edit '+Source_drive+':\'+ Path +'\'+ Txt_file;
  If (Open(Source_drive+':\'+Path+'\'+Txt_file,3)) then
  Begin
    DessineBoite(12,11,69,18,5,true,13,0,False,13,13);
    TextColor(15); Centrer('Processing!',12,69,4); TextColor(15);
    Delay(1500);
    SwapVectors;
    Exec(ProgramCommandCom, CmdLine) ;
    SwapVectors;
    If DOSError <> 0 then Begin Message_Erreur(1,0); exit; end;
    Install_game; end
  Else Begin Erreur := True; exit; end;
                         end
  Else Install_game;
end;
{----------------------------------------------------------------------------}
Procedure Fill_the_blanks;

Label SourceDrive, DestinationDrive, DestinationDirectory;
var DiskNumber : integer;
    SpaceDiskString : String[10];

function IntToStr(I: Longint): String;
{ Convert any integer type to a string }
var
 S: string[10];
begin
 Str(I, S);
 IntToStr := S;
end;

Procedure Write_Space_Disk;
begin
  If Destination_Drive <> 'φ' then
  Begin
    I := 1;
    For I := 1 to ((Length(SpaceDiskString))-2) do
    Write(SpaceDiskString[I]);
    If (Length(SpaceDiskString) >= 3 ) then Write(',')
    Else Write('0,');
    If (Length(SpaceDiskString) >= 2 ) then Begin
    For J := ((Length(SpaceDiskString)-1)) to (Length(SpaceDiskString)) do
    Write(SpaceDiskString[J]); end
    Else If (Length(SpaceDiskString) = 1 ) then Begin
    Write('0'); Write(SpaceDiskString); end;
    Write(' Megs');
  end;
end;

Begin
If (Destination_drive_Access = False) then Begin
   Window(26,18,30,18); TextBackground(3); Clrscr; TextColor(14);
   If (Destination_drive='φ') then Write('---')
   Else Write(Destination_drive,':\');
   Window(50,20,70,20); TextBackground(3); Clrscr; TextColor(14);
   DiskNumber := ord(Upcase(Destination_drive)) - 64;
   SpaceDisk := (Diskfree(DiskNumber)div 10000);
   SpaceDiskString := IntToStr(SpaceDisk);
   EffaceCursor; Write_Space_Disk; NormalCursor; end;
If (Destination_directory_Access = False) then Begin
   Window(30,19,72,19); TextBackground(3); Clrscr; TextColor(14);
   If (Destination_directory='φ') then Write('--------')
   Else Write(Destination_directory); end;

SourceDrive:
  Begin
    Read_Char(21,17,25,17,0,'Letter');
    If ((Touche_Esc=False)and(Touche_Tab=False)and(Touche_Bas=False)
       and(Touche_Haut=False)) then Source_drive := Upcase(Choix);
    Window(21,17,25,17); TextBackground(3); Clrscr; TextColor(14);
    If Touche_Esc = True then Exit;
    If Source_drive <> #0 then Write(Source_drive,':\');
    If Touche_Tab = True then goto DestinationDrive
    Else If Touche_Bas = True then goto DestinationDrive
    Else If Touche_Haut = True then goto DestinationDirectory
  end;

DestinationDrive:
  Begin
  If (Destination_drive_Access = True) then Begin
    If (Destination_drive_Access = True) then Read_Char(26,18,30,18,0,'Letter');
    If ((Touche_Esc=False)and(Touche_Tab=False)and(Touche_Bas=False)
       and(Touche_Haut=False)) then Destination_drive := Upcase(Choix);
    Window(26,18,30,18); TextBackground(3); Clrscr; TextColor(14);
    If Touche_Esc = True then Exit;
    If (Destination_drive <> #0) then Write(Destination_drive,':\');
    If Touche_Tab = True then goto DestinationDirectory
    Else If Touche_Bas = True then goto DestinationDirectory
    Else If Touche_Haut = True then goto SourceDrive;
    Window(50,20,70,20); TextBackground(3); Clrscr; TextColor(14);
    DiskNumber := ord(Upcase(Destination_drive)) - 64;
    SpaceDisk := (Diskfree(DiskNumber)div 10000);
    SpaceDiskString := IntToStr(SpaceDisk);
    EffaceCursor; Write_Space_Disk; NormalCursor;
                                          end;
  end;


DestinationDirectory:
  Begin
  If (Destination_directory_Access = True) then Begin
    If (Destination_directory_Access = True) then begin
        Window(30,19,72,19); TextBackground(0); Clrscr; TextColor(14);
        Read_String(Destination_Directory); end;
    Window(30,19,72,19); TextBackground(3); Clrscr; TextColor(14);
    If Touche_Esc = True then Exit;
    If Destination_directory <> '' then Write(Destination_directory);
    If Touche_Tab = True then goto SourceDrive
    Else If Touche_Bas = True then goto SourceDrive
    Else If Touche_Haut = True then goto DestinationDrive
                                               end;
  end;

   EffaceCursor;
   Window (7, 16, 61, 16);
   Textbackground (3);
   Clrscr;                      { Pour effacer l'écran }
   TextColor (15);                  { Couleur du texte blanc }
   Write ('Are you ready to start the installation? (Y)es or (N)o');
   Textcolor (14);                    {Couleur des réponses yellow}
   Gotoxy (43, 1);   Write ('Y');
   Gotoxy (52, 1);   Write ('N');
   Repeat
     ch := Readkey;
   Until (Upcase(Ch)=char(78)) or (Upcase(Ch)=char(89));
   Clrscr;
   NormalCursor;

  Case (Upcase(ch)) of
  'Y': Begin
  If (Source_drive=#0) then Begin Message_Erreur(4,3); Erreur:=True; end
  Else If (Destination_drive = #0) and (Destination_drive=#0) then
          Begin Message_Erreur(5,3); Erreur:=True; end
  Else If (Destination_directory = '') and (Destination_directory=#0) then
          Begin Message_Erreur(6,3); Erreur:=True; end
  Else If ((SpaceDisk div 100) < Megs) and (Destination_drive <> 'φ') then
          Begin Message_Erreur(3,3); Erreur := True; end
  Else Menu_Texte; end;
  'N' : Begin Clrscr; Fill_The_Blanks end;
  end;
end;
{----------------------------------------------------------------------------}
Procedure Installation_Menu;

Begin
  NormalCursor;
  Touche_insert := false;
  BackGroundPrincipal(3);
  Barre_menu_bas('Autre',3);
  DessineBoite(2,4,78,22,3,true,0,11,True,7,7);
  DessineBoite(5,5,75,7,3,true,11,0,False,13,13);
  TextColor (15); Centrer('Installation Menu',5,75,2);

  Window(5,8,75,8); TextColor (14); Centrer(Name,5,75,1);

  DessineBoite(5,9,75,13,3,true,11,0,False,13,13);
  TextColor(15);
  Gotoxy(3,2);Write('Space required: ');
  TextColor(14); Write(Megs,' Megs'); TextColor(15);
  Gotoxy(3,3);Write('Operating system: ');
  TextColor(14); Write(OSystem); TextColor(15);
  Gotoxy(3,4);Write('Reference text file: ');
  TextColor(14); Write(Txt_file);

  DessineBoite(5,14,75,21,3,true,11,0,False,13,13);

  TextColor(15);
  Gotoxy(3,2);Write('Please fill all the blanks.');
  Gotoxy(3,4);Write('Source drive: ');
  Gotoxy(3,5);Write('Destination drive: ');
  Gotoxy(3,6);Write('Destination directory: ');
  Gotoxy(3,7);Write('Space disk available on destination drive: ');
  Fill_the_blanks;
  If Erreur = True then begin
                          Erreur := False;
                          Installation_Menu; end;
end;
{----------------------------------------------------------------------------}
Procedure InitiationVariables(VarName:String; VarMegs:integer;
          VarPath:Filename; VarOSystem, VarTxt_file, VarRun_file:String;
          VarModification_file:String; VarDestination_drive:Char;
          VarDestination_directory:String);
Begin
  Name:=VarName ;
  Megs:=VarMegs ;
  Path:=VarPath ;
  OSystem:=VarOSystem ;
  Txt_file:=VarTxt_file ;
  Run_file:=VarRun_file ;
  Modification_file:=VarModification_file ;
  Destination_drive:=VarDestination_drive ;
  If (Destination_drive=#0) then Destination_drive_Access:=True
  Else Destination_drive_Access:=False;
  Destination_directory:=VarDestination_directory ;
  If (Destination_directory='') then Destination_directory_Access:=True
  Else Destination_directory_Access:=False;
  Installation_Menu;

end;
{----------------------------------------------------------------------------}
Procedure Choix_du_Jeux;
Label Page1, Page2;

Begin
  NormalCursor;
  Touche_insert := false;
  BackGroundPrincipal(1);
  Barre_menu_bas('Principal',1);
  DessineBoite(2,4,78,22,1,true,0,9,True,7,7);
  DessineBoite(5,5,75,7,1,true,9,0,False,13,13);
  TextColor (15); Centrer('Main Menu (Multi-Jeux tome  )',5,75,2);
  Goto Page1;

Page1: Begin
  Choice:=0;
  Touche_Esc := False;
  DessineBoite(5,8,75,21,1,true,9,0,False,13,13);
  TextColor (15);
  Gotoxy(4,2)  ; Write(' - '+Name1 );
  Gotoxy(4,3)  ; Write(' - '+Name2 );
  Gotoxy(4,4)  ; Write(' - '+Name3 );
  Gotoxy(4,5)  ; Write(' - '+Name4 );
  Gotoxy(4,6)  ; Write(' - '+Name5 );
  Gotoxy(4,7)  ; Write(' - '+Name6 );
  Gotoxy(4,8)  ; Write(' - '+Name7 );
  Gotoxy(4,9)  ; Write(' - '+Name8 );
  Gotoxy(4,10) ; Write(' - '+Name9 );
  Gotoxy(4,11) ; Write(' - '+Name10);
  Gotoxy(38,2) ; Write(' - '+Name11);
  Gotoxy(38,3) ; Write(' - '+Name12);
  Gotoxy(38,4) ; Write(' - '+Name13);
  Gotoxy(38,5) ; Write(' - '+Name14);
  Gotoxy(38,6) ; Write(' - '+Name15);
  Gotoxy(38,7) ; Write(' - '+Name16);
  Gotoxy(38,8) ; Write(' - '+Name17);
  Gotoxy(38,9) ; Write(' - '+Name18);
  Gotoxy(38,10); Write(' - '+Name19);
  Gotoxy(38,11); Write(' - '+Name20);
  TextColor(14);
  Gotoxy(3,2)   ; Write(' 1') ; Gotoxy(3,3)   ; Write(' 2');
  Gotoxy(3,4)   ; Write(' 3') ; Gotoxy(3,5)   ; Write(' 4');
  Gotoxy(3,6)   ; Write(' 5') ; Gotoxy(3,7)   ; Write(' 6');
  Gotoxy(3,8)   ; Write(' 7') ; Gotoxy(3,9)   ; Write(' 8');
  Gotoxy(3,10)  ; Write(' 9') ; Gotoxy(3,11)  ; Write('10');
  Gotoxy(37,2)  ; Write('11') ; Gotoxy(37,3)  ; Write('12');
  Gotoxy(37,4)  ; Write('13') ; Gotoxy(37,5)  ; Write('14');
  Gotoxy(37,6)  ; Write('15') ; Gotoxy(37,7)  ; Write('16');
  Gotoxy(37,8)  ; Write('17') ; Gotoxy(37,9)  ; Write('18');
  Gotoxy(37,10) ; Write('19') ; Gotoxy(37,11) ; Write('20');
  TextColor (15);
  Gotoxy(3,13); Write('Your choice : ');
  TextColor(14);
  Repeat
     Repeat
       Window (21, 20, 30, 20);
       Textbackground (1);
       ClrScr;
       Read_integer(Choice);
     Until (Choice in [1..20]) or (Ch = Char(27)) or (Touche_F1 = True);
     If Touche_Esc = True then BoitePourQuitter(Choix)
     Else If (Touche_F1 = True) then goto page2;
     If (Upcase(Choix) = 'Y') then Quit := True
     Else Begin
            Quit := false;
            Window (28, 20, 74, 20);
            Textbackground (1);
            Clrscr; end;
  Until (Choice in [1..20]) or (Quit <> False);
  If (Quit=True) then Exit;
  Case (Choice) of
  1 : Begin InitiationVariables( Name1 ,Megs1 ,Path1 ,OSystem1 ,Txt_file1 ,Run_file1 ,
            Modification_file1 , Destination_drive1 ,Destination_directory1 ); end;
  2 : Begin InitiationVariables( Name2 ,Megs2 ,Path2 ,OSystem2 ,Txt_file2 ,Run_file2 ,
            Modification_file2 , Destination_drive2 ,Destination_directory2 ); end;
  3 : Begin InitiationVariables( Name3 ,Megs3 ,Path3 ,OSystem3 ,Txt_file3 ,Run_file3 ,
            Modification_file3 , Destination_drive3 ,Destination_directory3 ); end;
  4 : Begin InitiationVariables( Name4 ,Megs4 ,Path4 ,OSystem4 ,Txt_file4 ,Run_file4 ,
            Modification_file4 , Destination_drive4 ,Destination_directory4 ); end;
  5 : Begin InitiationVariables( Name5 ,Megs5 ,Path5 ,OSystem5 ,Txt_file5 ,Run_file5 ,
            Modification_file5 , Destination_drive5 ,Destination_directory5 ); end;
  6 : Begin InitiationVariables( Name6 ,Megs6 ,Path6 ,OSystem6 ,Txt_file6 ,Run_file6 ,
            Modification_file6 , Destination_drive6 ,Destination_directory6 ); end;
  7 : Begin InitiationVariables( Name7 ,Megs7 ,Path7 ,OSystem7 ,Txt_file7 ,Run_file7 ,
            Modification_file7 , Destination_drive7 ,Destination_directory7 ); end;
  8 : Begin InitiationVariables( Name8 ,Megs8 ,Path8 ,OSystem8 ,Txt_file8 ,Run_file8 ,
            Modification_file8 , Destination_drive8 ,Destination_directory8 ); end;
  9 : Begin InitiationVariables( Name9 ,Megs9 ,Path9 ,OSystem9 ,Txt_file9 ,Run_file9 ,
            Modification_file9 , Destination_drive9 ,Destination_directory9 ); end;
  10: Begin InitiationVariables( Name10,Megs10,Path10,OSystem10,Txt_file10,Run_file10,
            Modification_file10, Destination_drive10,Destination_directory10); end;
  11: Begin InitiationVariables( Name11,Megs11,Path11,OSystem11,Txt_file11,Run_file11,
            Modification_file11, Destination_drive11,Destination_directory11); end;
  12: Begin InitiationVariables( Name12,Megs12,Path12,OSystem12,Txt_file12,Run_file12,
            Modification_file12, Destination_drive12,Destination_directory12); end;
  13: Begin InitiationVariables( Name13,Megs13,Path13,OSystem13,Txt_file13,Run_file13,
            Modification_file13, Destination_drive13,Destination_directory13); end;
  14: Begin InitiationVariables( Name14,Megs14,Path14,OSystem14,Txt_file14,Run_file14,
            Modification_file14, Destination_drive14,Destination_directory14); end;
  15: Begin InitiationVariables( Name15,Megs15,Path15,OSystem15,Txt_file15,Run_file15,
            Modification_file15, Destination_drive15,Destination_directory15); end;
  16: Begin InitiationVariables( Name16,Megs16,Path16,OSystem16,Txt_file16,Run_file16,
            Modification_file16, Destination_drive16,Destination_directory16); end;
  17: Begin InitiationVariables( Name17,Megs17,Path17,OSystem17,Txt_file17,Run_file17,
            Modification_file17, Destination_drive17,Destination_directory17); end;
  18: Begin InitiationVariables( Name18,Megs18,Path18,OSystem18,Txt_file18,Run_file18,
            Modification_file18, Destination_drive18,Destination_directory18); end;
  19: Begin InitiationVariables( Name19,Megs19,Path19,OSystem19,Txt_file19,Run_file19,
            Modification_file19, Destination_drive19,Destination_directory19); end;
  20: Begin InitiationVariables( Name20,Megs20,Path20,OSystem20,Txt_file20,Run_file20,
            Modification_file20, Destination_drive20,Destination_directory20); end;
       end;
  exit;
       end;

Page2: Begin
  Touche_Esc := False;
  DessineBoite(5,8,75,21,1,true,9,0,False,13,13);
  TextColor (15);
  Gotoxy(4,2)  ; Write(' - '+Name21);
  Gotoxy(4,3)  ; Write(' - '+Name22);
  Gotoxy(4,4)  ; Write(' - '+Name23);
  Gotoxy(4,5)  ; Write(' - '+Name24);
  Gotoxy(4,6)  ; Write(' - '+Name25);
  Gotoxy(4,7)  ; Write(' - '+Name26);
  Gotoxy(4,8)  ; Write(' - '+Name27);
  Gotoxy(4,9)  ; Write(' - '+Name28);
  Gotoxy(4,10) ; Write(' - '+Name29);
  Gotoxy(4,11) ; Write(' - '+Name30);
  Gotoxy(38,2) ; Write(' - '+Name31);
  Gotoxy(38,3) ; Write(' - '+Name32);
  Gotoxy(38,4) ; Write(' - '+Name33);
  Gotoxy(38,5) ; Write(' - '+Name34);
  Gotoxy(38,6) ; Write(' - '+Name35);
  Gotoxy(38,7) ; Write(' - '+Name36);
  Gotoxy(38,8) ; Write(' - '+Name37);
  Gotoxy(38,9) ; Write(' - '+Name38);
  Gotoxy(38,10); Write(' - '+Name39);
  Gotoxy(38,11); Write(' - '+Name40);
  TextColor(14);
  Gotoxy(3,2)   ; Write('21') ; Gotoxy(3,3)   ; Write('22');
  Gotoxy(3,4)   ; Write('23') ; Gotoxy(3,5)   ; Write('24');
  Gotoxy(3,6)   ; Write('25') ; Gotoxy(3,7)   ; Write('26');
  Gotoxy(3,8)   ; Write('27') ; Gotoxy(3,9)   ; Write('28');
  Gotoxy(3,10)  ; Write('29') ; Gotoxy(3,11)  ; Write('30');
  Gotoxy(37,2)  ; Write('31') ; Gotoxy(37,3)  ; Write('32');
  Gotoxy(37,4)  ; Write('33') ; Gotoxy(37,5)  ; Write('34');
  Gotoxy(37,6)  ; Write('35') ; Gotoxy(37,7)  ; Write('36');
  Gotoxy(37,8)  ; Write('37') ; Gotoxy(37,9)  ; Write('38');
  Gotoxy(37,10) ; Write('39') ; Gotoxy(37,11) ; Write('40');
  TextColor (15);
  Gotoxy(3,13); Write('Your choice : ');
  TextColor(14);
  Repeat
     Repeat
       Window (21, 20, 30, 20);
       Textbackground (1);
       ClrScr;
       Read_integer(Choice);
     Until (Choice in [21..34]) or (Ch = Char(27)) or (Touche_F1 = True);
     If Touche_Esc = True then BoitePourQuitter(Choix)
     Else If (Touche_F1 = True) then goto page1;
     If (Upcase(Choix) = 'Y') then Quit := True
     Else Begin
            Quit := false;
            Window (28, 20, 74, 20);
            Textbackground (1);
            Clrscr; end;
  Until (Choice in [21..34]) or (Quit <> False);
  If (Quit=True) then Exit;
  Case (Choice) of
  21: Begin InitiationVariables( Name21,Megs21,Path21,OSystem21,Txt_file21,Run_file21,
            Modification_file21, Destination_drive21,Destination_directory21); end;
  22: Begin InitiationVariables( Name22,Megs22,Path22,OSystem22,Txt_file22,Run_file22,
            Modification_file22, Destination_drive22,Destination_directory22); end;
  23: Begin InitiationVariables( Name23,Megs23,Path23,OSystem23,Txt_file23,Run_file23,
            Modification_file23, Destination_drive23,Destination_directory23); end;
  24: Begin InitiationVariables( Name24,Megs24,Path24,OSystem24,Txt_file24,Run_file24,
            Modification_file24, Destination_drive24,Destination_directory24); end;
  25: Begin InitiationVariables( Name25,Megs25,Path25,OSystem25,Txt_file25,Run_file25,
            Modification_file25, Destination_drive25,Destination_directory25); end;
  26: Begin InitiationVariables( Name26,Megs26,Path26,OSystem26,Txt_file26,Run_file26,
            Modification_file26, Destination_drive26,Destination_directory26); end;
  27: Begin InitiationVariables( Name27,Megs27,Path27,OSystem27,Txt_file27,Run_file27,
            Modification_file27, Destination_drive27,Destination_directory27); end;
  28: Begin InitiationVariables( Name28,Megs28,Path28,OSystem28,Txt_file28,Run_file28,
            Modification_file28, Destination_drive28,Destination_directory28); end;
  29: Begin InitiationVariables( Name29,Megs29,Path29,OSystem29,Txt_file29,Run_file29,
            Modification_file29, Destination_drive29,Destination_directory29); end;
  30: Begin InitiationVariables( Name30,Megs30,Path30,OSystem30,Txt_file30,Run_file30,
            Modification_file30, Destination_drive30,Destination_directory30); end;
  31: Begin InitiationVariables( Name31,Megs31,Path31,OSystem31,Txt_file31,Run_file31,
            Modification_file31, Destination_drive31,Destination_directory31); end;
  32: Begin InitiationVariables( Name32,Megs32,Path32,OSystem32,Txt_file32,Run_file32,
            Modification_file32, Destination_drive32,Destination_directory32); end;
  33: Begin InitiationVariables( Name33,Megs33,Path33,OSystem33,Txt_file33,Run_file33,
            Modification_file33, Destination_drive33,Destination_directory33); end;
  34: Begin InitiationVariables( Name34,Megs34,Path34,OSystem34,Txt_file34,Run_file34,
            Modification_file34, Destination_drive34,Destination_directory34); end;
  35: Begin InitiationVariables( Name35,Megs35,Path35,OSystem35,Txt_file35,Run_file35,
            Modification_file35, Destination_drive35,Destination_directory35); end;
  36: Begin InitiationVariables( Name36,Megs36,Path36,OSystem36,Txt_file36,Run_file36,
            Modification_file36, Destination_drive36,Destination_directory36); end;
  37: Begin InitiationVariables( Name37,Megs37,Path37,OSystem37,Txt_file37,Run_file37,
            Modification_file37, Destination_drive37,Destination_directory37); end;
  38: Begin InitiationVariables( Name38,Megs38,Path38,OSystem38,Txt_file38,Run_file38,
            Modification_file38, Destination_drive38,Destination_directory38); end;
  39: Begin InitiationVariables( Name39,Megs39,Path39,OSystem39,Txt_file39,Run_file39,
            Modification_file39, Destination_drive39,Destination_directory39); end;
  40: Begin InitiationVariables( Name40,Megs40,Path40,OSystem40,Txt_file40,Run_file40,
            Modification_file40, Destination_drive40,Destination_directory40); end;
       end; end;
end;
{----------------------------------------------------------------------------}
Begin
  Clrscr;
  NormalCursor;
  Source := '';
  Quit := False;
  Erreur := False;
  Touche_insert := false;
  Repeat
  Choix_du_Jeux;
  Until Quit = True;
  fin(False);
END.

