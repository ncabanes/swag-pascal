
{Here it is : The very fast Knuth Morris Pratt algo. It is only
implemented to search for a substring in a string but you can easily
transform it to search into a whole text. Sorry but it's not well
commented. I'm sure you'll understand ;-> }

program kmp;
 
uses crt;
 
const longmaxchaine=50;
      longmaxchaineplus1=51;
 
type  chaine=string[longmaxchaine];
      lmcplus1=1..longmaxchaineplus1;
      tablongueur=array[1..longmaxchaine] of integer;
 
PROCEDURE compilation(tmodele:chaine;
                      var longueur:tablongueur);
var im,k,lm,toto:integer;
    fini:boolean;
BEGIN
  lm:=length(tmodele);
  im:=1;
  k:=0;
  longueur[1]:=0;
  while im<lm do
    begin
      fini:=false;
      repeat
        if k<=0 then fini:=true
        else
          if tmodele[im]=tmodele[k] then fini:=true
        else
          k:=longueur[k];
       until fini;
       im:=im+1;
       k:=k+1;
       if tmodele[im]=tmodele[k] then
         longueur[im]:=longueur[k]
       else
         longueur[im]:=k;
    end;
    write('Precompilation:');
    for toto:=1 to length(tmodele) do
      write(longueur[toto]);
    writeln;
end;


 
PROCEDURE recherche(tsujet:chaine;
                    taille:lmcplus1;
                    tmodele:chaine;
                    var trouve:boolean);

var fini:boolean;
    im,is,lm,ls:integer;
    longueur:tablongueur;
BEGIN
  compilation(tmodele,longueur);
  lm:=length(tmodele);
  ls:=length(tsujet);
  is:=1;
  im:=1;
  While (im<=lm) and (is<=ls) do
    begin
      fini:=false;
      repeat
        if im<=0 then fini:=true
        else
          if tmodele[im]=tsujet[is] then fini:=true
        else im:=longueur[im];
      until fini;
      im:=im+1;
      is:=is+1;
    end;
    if im>lm then trouve:=true else trouve:=false;
    if trouve then writeln('Trouve en ',is-im+1);
end;
 
{----------------------------- MAIN
----------------------------------------}
 
var tsujet,tmodele:chaine;
    trouve:boolean;
BEGIN
  clrscr;
  tsujet:='klfglkhooladfgdfhoolahrthhooli';
  tmodele:='hoo';
  writeln('sujet:"',tsujet,'"');
  writeln('modele:"',tmodele,'"');

  recherche(tsujet,length(tsujet),tmodele,trouve);
 
  if not trouve then writeln('Pas trouve');
  readkey;
end.


{You can email me (Ludovic Russo).Here is my address:
lrusso@ice.unice.fr}

