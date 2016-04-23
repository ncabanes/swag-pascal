{
I've enclosed 2 SCROLL functions....
Hope it'll help.
These source are FREEWARE. So then can only be used in a Freeware or Shareware
. ( It'll be great if you give me a copy of your freeware).
These sources can be added to SWAGS....

<==== Cut =====> }

Uses CRT,DOS ...

Procedure Cadre (X1,X2,Y1,Y2,FG,BG:Integer);

{ Trace un Cadre entre les Coordonnées X1,Y1 et X2,Y2
  avec FG= Couleur du Cadre , BG= Couleur du Fond }

Var
   corner1,
   corner2,
   corner3,
   corner4,
   horizline,
   vertline : String;
   a,b: integer;


   Begin
               corner1:='┌';
               corner2:='┐';
               corner3:='└';
               corner4:='┘';
               horizline:='─';
               vertline:='│';

        TextColor (FG);                  { Fixe les couleurs }
        TextBackground (BG);

        GotoXY ( X1,Y1 );                { Positionne le curseur }
      Write (Corner1);

      For a:= (X1+1) to (X2-1) do
       Begin                             { Ecrit le Cadre }
        Write (Horizline);
       end;

      Write (Corner2);


       For a:= (Y1+1) to (Y2-1) do
        Begin
         GotoXY(X1,a);
         Write (VertLine);
         For b:= (X1+1) to (X2-1) do
          Begin
           Write (' ');
          end;
         Write(Vertline);
        end;

      GotoXY(X1,Y2);
      Write (Corner3);

      For a:= (X1+1) to (X2-1) do
       Begin
        Write (Horizline);
       end;

       Write (Corner4);
end;

Procedure Explode_Cadre (X1,X2,Y1,Y2,FG,BG,Delai: Integer);

{ Rédaction: Explode_Cadre (X1,X2,Y1,Y2,FG,BG,Delai) }

  Var

         gauche,droite,MilieuX,
            a,b: Integer;

  Begin


   MilieuX:= (X1+X2) div 2;         { Calcul des paramètres de position }
   gauche:= (X2-X1) div 2;
   droite:= gauche;
   if ((X2-X1) Mod 2) > 0 then Droite:= Droite +1;

                                    { Début du Tracé }

   For a:= 1 to Gauche do
    Begin
     Cadre ((MilieuX-a),(MilieuX+a),Y1,Y2,FG,BG);
     delay (Delai);
    end;

   if Gauche <> Droite then Cadre (X1,X2,Y1,Y2,FG,BG);

   End;


Procedure Scroll (x1,x2,Y:Byte;S:String;fg,bg,vitesse:integer);

{ Avec
      x1 et x2 position x de la fenètre de scrolling
      Y        position Y de la fenètre de scrolling
      S        Chaine de caractères à faire défiler
      fg       ForeGround (Couleur du Texte)
      bg       BackGround (Couleur du Fond)
      vitesse  Vitesse du scrolling


 Tout appui sur une touche arrete le scrolling et vide le buffer clavier

}

 Var
    a,b,LonFenetre,LonStr: Byte;
    ch,dh: String;

 Begin

  Ch:='';
  LonFenetre:=(x2-x1);
  LonStr:=Length(S);

  For b:=1 to (LonFenetre) do ch:=concat (ch,' ');  { Rajoute N epaces avant
et apres la chaine S}  dh:=ch;
  ch:= concat(ch,S,ch);
  b:= 1;

  Repeat
   Begin
    b:=b+1;
    Ecris(x1,Y,Copy(ch,b,LonFenetre),fg,bg);
    delay(Vitesse);
    end;

  Until (Keypressed) or (b>(LonFenetre+LonStr+1));
  Vide_Buffer_Clavier;
  Ecris(x1,Y,dh,fg,bg);
 end;

Procedure Scroll_Inverse (x1,x2,Y:Byte;S:String;fg,bg,vitesse:integer);

 Var
    a,b,LonFenetre,LonStr: Byte;
    ch,dh: String;

 Begin

  Ch:='';
  LonFenetre:=(x2-x1);
  LonStr:=Length(S);

  For b:=1 to (LonFenetre) do ch:=concat (ch,' ');  { Rajoute N epaces avant
et apres la chaine S}  dh:=ch;
  ch:= concat(ch,S,ch);
  b:= 1;

  Repeat
   Begin
    b:=b+1;
    Ecris(x1,Y,Copy(ch,(LonFenetre+LonStr)-b,LonFenetre),fg,bg);
    delay(Vitesse);

   end;
  Until (Keypressed) or (b>(LonFenetre+LonStr+1));
  Vide_Buffer_Clavier;
  Ecris(x1,Y,dh,fg,bg);
 end;

Procedure Scroll_No_Exit (x1,x2,Y:Byte;S:String;fg,bg,vitesse:integer);

{ Procédure identique à Scroll mais sans possibilité d'Echap.}

 Var
    a,b,LonFenetre,LonStr: Byte;
    ch: String;

 Begin

  Ch:='';
  LonFenetre:=(x2-x1);
  LonStr:=Length(S);

  For b:=1 to (LonFenetre) do ch:=concat (ch,' ');  { Rajoute N epaces avant
et apres la chaine S}  ch:= concat(ch,S,ch);
  b:= 1;

  Repeat
   Begin
    b:=b+1;
    Ecris(x1,Y,Copy(ch,b,LonFenetre),fg,bg);
    delay(Vitesse);

   end;
  Until (b>(LonFenetre+LonStr+1));
  Vide_Buffer_Clavier;

 end;

Procedure Scroll_Inverse_No_Exit
(x1,x2,Y:Byte;S:String;fg,bg,vitesse:integer);
{ Procédure identique à Scroll mais sans possibilité d'Echap.}

 Var
    a,b,LonFenetre,LonStr: Byte;
    ch: String;

 Begin

  Ch:='';
  LonFenetre:=(x2-x1);
  LonStr:=Length(S);

  For b:=1 to (LonFenetre) do ch:=concat (ch,' ');  { Rajoute N epaces avant
et apres la chaine S}
  ch:= concat(ch,S,ch);
  b:= 1;

  Repeat
   Begin
    b:=b+1;
    Ecris(x1,Y,Copy(ch,(LonFenetre+LonStr)-b,LonFenetre),fg,bg);
    delay(Vitesse);

   end;
  Until (b>(LonFenetre+LonStr+1));
  Vide_Buffer_Clavier;

 end;

