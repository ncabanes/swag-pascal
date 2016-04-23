From: johan@lindgren.pp.se

>   lopezj@iluso.ci.uv.es (Agustin Lopez Bueno) writes:
>  I need translate the contents of a RTF component to HTML
>  with Delphi. Anybody knows how to do this?
This is a routine I use to convert the content of a RichEdit to SGML-code. It does not produce a complete HTML-file but you will have to figure out which RTF-codes you should convert to which HTML-tags.


--------------------------------------------------------------------------------

function rtf2sgml (text : string) : string;
{Funktion f÷r att konvertera en RTF-rad till SGML-text.}
var
temptext : string;
start : integer;
begin
text := stringreplaceall (text,'&','##amp;');
text := stringreplaceall (text,'##amp','&amp');
text := stringreplaceall (text,'\'+chr(39)+'e5','&aring;');
text := stringreplaceall (text,'\'+chr(39)+'c5','&Aring;');
text := stringreplaceall (text,'\'+chr(39)+'e4','&auml;');
text := stringreplaceall (text,'\'+chr(39)+'c4','&Auml;');
text := stringreplaceall (text,'\'+chr(39)+'f6','&ouml;');
text := stringreplaceall (text,'\'+chr(39)+'d6','&Ouml;');
text := stringreplaceall (text,'\'+chr(39)+'e9','&eacute;');
text := stringreplaceall (text,'\'+chr(39)+'c9','&Eacute;');
text := stringreplaceall (text,'\'+chr(39)+'e1','&aacute;');
text := stringreplaceall (text,'\'+chr(39)+'c1','&Aacute;');
text := stringreplaceall (text,'\'+chr(39)+'e0','&agrave;');
text := stringreplaceall (text,'\'+chr(39)+'c0','&Agrave;');
text := stringreplaceall (text,'\'+chr(39)+'f2','&ograve;');
text := stringreplaceall (text,'\'+chr(39)+'d2','&Ograve;');
text := stringreplaceall (text,'\'+chr(39)+'fc','&uuml;');
text := stringreplaceall (text,'\'+chr(39)+'dc','&Uuml;');
text := stringreplaceall (text,'\'+chr(39)+'a3','&#163;');
text := stringreplaceall (text,'\}','#]#');
text := stringreplaceall (text,'\{','#[#');
text := stringreplaceall (text,'{\rtf1\ansi\deff0\deftab720','');{Skall alltid tas bort}
text := stringreplaceall (text,'{\fonttbl',''); {Skall alltid tas bort}
text := stringreplaceall (text,'{\f0\fnil MS Sans Serif;}','');{Skall alltid tas bort}
text := stringreplaceall (text,'{\f1\fnil\fcharset2 Symbol;}','');{Skall alltid tas bort}
text := stringreplaceall (text,'{\f2\fswiss\fprq2 System;}}','');{Skall alltid tas bort}
text := stringreplaceall (text,'{\colortbl\red0\green0\blue0;}','');{Skall alltid tas bort}
{I version 2.01 av Delphi finns inte \cf0 med i RTF-rutan. Tog dΣrf÷r bort
det efter \fs16 och la istΣllet en egen tvΣtt av \cf0.}
//temptext := hamtastreng (text,'{\rtf1','\deflang');
//text := stringreplace (text,temptext,''); {HΣmta och radera allt frσn start till deflang}
text := stringreplaceall (text,'\cf0','');
temptext := hamtastreng (text,'\deflang','\pard');{Plocka frσn deflang till pard f÷r att fσ }
text := stringreplace (text,temptext,'');{oavsett vilken lang det Σr. Norska o svenska Σr olika}
{HΣr skall vi plocka bort fs och flera olika siffror beroende pσ vilka alternativ vi godkΣnner.}
//text := stringreplaceall (text,'\fs16','');{8 punkter}
//text := stringreplaceall (text,'\fs20','');{10 punkter}
{Nu stΣdar vi istΣllet bort alla tvσsiffriga fontsize.}
while pos ('\fs',text) >0 do
  begin
    application.processmessages;
    start := pos ('\fs',text);
    Delete(text,start,5);
  end;
text := stringreplaceall (text,'\pard\plain\f0 ','<P>');
text := stringreplaceall (text,'\par \plain\f0\b\ul ','</P><MELLIS>');
text := stringreplaceall (text,'\plain\f0\b\ul ','</P><MELLIS>');
text := stringreplaceall (text,'\plain\f0','</MELLIS>');
text := stringreplaceall (text,'\par }','</P>');
text := stringreplaceall (text,'\par ','</P><P>');
text := stringreplaceall (text,'#]#','}');
text := stringreplaceall (text,'#[#','{');
text := stringreplaceall (text,'\\','\');
result := text;
end;


//This is cut directly from the middle of a fairly long save routine that calls the above function.
//I know I could use streams instead of going through a separate file but I have not had the time to change this

            utfilnamn := mditted.exepath+stringreplace(stringreplace(extractfilename(pathname),'.TTT',''),'.ttt','') + 'ut.RTF';
             brodtext.lines.savetofile (utfilnamn);
             temptext := '';
             assignfile(tempF,utfilnamn);
             reset (tempF);
             try
                while not eof(tempF) do
                  begin
                     readln (tempF,temptext2);
                     temptext2 := stringreplaceall (temptext2,'\'+chr(39)+'b6','');
                     temptext2 := rtf2sgml (temptext2);
                     if temptext2 <>'' then temptext := temptext+temptext2;
                     application.processmessages;
                  end;
             finally
                    closefile (tempF);
             end;
             deletefile (utfilnamn);
             temptext := stringreplaceall (temptext,'</MELLIS> ','</MELLIS>');
             temptext := stringreplaceall (temptext,'</P> ','</P>');
             temptext := stringreplaceall (temptext,'</P>'+chr(0),'</P>');
             temptext := stringreplaceall (temptext,'</MELLIS></P>','</MELLIS>');
             temptext := stringreplaceall (temptext,'<P></P>','');
             temptext := stringreplaceall (temptext,'</P><P></MELLIS>','</MELLIS><P>');
             temptext := stringreplaceall (temptext,'</MELLIS>','<#MELLIS><P>');
             temptext := stringreplaceall (temptext,'<#MELLIS>','</MELLIS>');
             temptext := stringreplaceall (temptext,'<P><P>','<P>');
             temptext := stringreplaceall (temptext,'<P> ','<P>');
             temptext := stringreplaceall (temptext,'<P>-','<P>_');
             temptext := stringreplaceall (temptext,'<P>_','<CITAT>_');
             while pos('<CITAT>_',temptext)>0 do
               begin
                 application.processmessages;
                 temptext2 := hamtastreng (temptext,'<CITAT>_','</P>');
                 temptext := stringreplace (temptext,temptext2+'</P>',temptext2+'</CITAT>');
                 temptext := stringreplace (temptext,'<CITAT>_','<CITAT>-');
               end;
             writeln (F,'<BRODTEXT>'+temptext+'</BRODTEXT>');
