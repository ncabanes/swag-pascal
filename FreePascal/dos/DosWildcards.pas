(*
  Category: SWAG Title: DOS & ENVIRONMENT ROUTINES
  Original name: 0094.PAS
  Description: DOS Wildcards
  Author: RENE SCHWIETZKE
  Date: 09-04-95  11:03
*)

{
From: Rene Schwietzke <rs@informatik.tu-cottbus.de>
}

program wildcards;
{****************************************************************************
 *  RenΘ Schwietzke  Richard-Koenig-Str. 08  D-04916 Herzberg  GERMANY      *
 *                                                                          *
 *  Internet: rs@informatik.tu-cottbus.de                                   *
 ****************************************************************************
 *  This is my implementation of a simple wildcard recognizer.              *
 *  Try it !                                                                *
 *  Please check the correctness, report all bugs and say your opinion.     *
 *                                                                          *
 *  written in Borland Pascal 7.0 with using of exit, break and continue    *
 ****************************************************************************
}
uses crt; {only for this demo}
{ *                : >=0 letters
  for example:
   *A              : words with >=1 letters and A at the end
   A*A             : words with >=2 letters and A at the begin and end
   A*              : words with >=1 letters and A at the begin

  ?                : one letter

  Combine it !
  See the examples at the end.}

{********** this function returns true if input_word=wilds ****************}
Function Wild(input_word,wilds:String;upcase_wish:boolean):Boolean;

 {looking for next *, returns position and string until position}
 function search_next(var wilds:string):word;
 var position,position2:word;
 begin
  position:=pos('*',wilds); {looks for *}

  if position<>0 then wilds:=copy(wilds,1,position-1);
     {returns the string}

  search_next:=position;
 end;

 {compares a string with '?' and another,
  returns the position of helpwilds in input_word}
 function find_part(helpwilds,input_word:string):word;
 var q,q2,q3,between:word;
     diff:integer;
 begin
  q:=pos('?',helpwilds);

  if q=0 then
   begin
    {if no '?' in helpwilds}

    find_part:=pos(helpwilds,input_word);
    exit;
   end;

  {'?' in helpwilds}
  diff:=length(input_word)-length(helpwilds);
  if diff<0 then begin find_part:=0;exit;end;
  between:=0;

  {now move helpwilds over input_word}
  for q:=0 to diff do
   begin
    for q2:=1 to length(helpwilds) do
     begin
      if (input_word[q+q2]=helpwilds[q2]) or (helpwilds[q2]='?') then
       begin if q2=length(helpwilds) then begin find_part:=q+1;exit;end;end
        else break;
     end;
   end;
  find_part:=0;
 end;
{************************** MAIN ******************************************}
{                this is the mainpart of wild                              }
var cwild,cinput_word:word;{counter for positions}
    q,lengthhelpwilds:word;
    maxinput_word,maxwilds:word;{length of input_word and wilds}
    helpwilds:string;
begin
 wild:=false;

 {uncomment this for often use with 'wildcardless' wilds}
 {if wilds=input_word then begin wild:=true;exit;end;}

 {delete '**', because '**'='*'}
 repeat
  q:=pos('**',wilds);
  if q<>0 then
   wilds:=copy(wilds,1,q-1)+'*'+copy(wilds,q+2,255);
 until q=0;

 {for fast end, if wilds only '*'}
 if wilds='*' then begin wild:=true;exit;end;

 maxinput_word:=length(input_word);
 maxwilds     :=length(wilds);

 {upcase all letters}
 if upcase_wish then
  begin
   for q:=1 to maxinput_word do input_word[q]:=upcase(input_word[q]);
   for q:=1 to maxwilds do wilds[q]:=upcase(wilds[q]);
  end;

 {set initialization}
 cinput_word:=1;cwild:=1;
 wild:=true;

 repeat
  {equal letters}
  if input_word[cinput_word]=wilds[cwild] then
   begin
    {goto next letter}
    inc(cwild);
    inc(cinput_word);
    continue;
   end;

  {equal to '?'}
  if wilds[cwild]='?' then
   begin
    {goto next letter}
    inc(cwild);
    inc(cinput_word);
    continue;
   end;

  {handling of '*'}
  if wilds[cwild]='*' then
   begin
    helpwilds:=copy(wilds,cwild+1,maxwilds);{takes the rest of wilds}

    q:=search_next(helpwilds);{search the next '*'}

    lengthhelpwilds:=length(helpwilds);

    if q=0 then
     begin
      {no '*' in the rest}
      {compare the ends}
      if helpwilds='' then exit;{'*' is the last letter}

      {check the rest for equal length and no '?'}
      for q:=0 to lengthhelpwilds-1 do
       if (helpwilds[lengthhelpwilds-q]<>input_word[maxinput_word-q]) and
          (helpwilds[lengthhelpwilds-q]<>'?') then
         begin wild:=false;exit;end;
      exit;
     end;

    {handle all to the next '*'}
    inc(cwild,1+lengthhelpwilds);
    q:=find_part(helpwilds,copy(input_word,cinput_word,255));
    if q=0 then begin wild:=false;exit;end;
    cinput_word:=q+lengthhelpwilds;
    continue;
   end;

  wild:=false;exit;

 until (cinput_word>maxinput_word) or (cwild>maxwilds);
 {no completed evaluation}
 if cinput_word<=maxinput_word then wild:=false;
 if cwild<=maxwilds then wild:=false;
end;

begin
 clrscr;
 {examples with the right result 'T' or 'F'}
 writeln(wild('Gebauer','G?bauer',false),' T');
 writeln(wild('Heiter','*r*s',false),' F');
 writeln(wild('L÷ffler','*r*s',false),' F');
 writeln(wild('Trinks','*r*s',false),' T');
 writeln(wild('Schwietzke','*e*e*',false),' T');
 writeln(wild('Endemann','*e*e*',false),' F');
 writeln(wild('Schwietzke','Schwietzke',false),' T');
 writeln(wild('Schwietzke','*',false),' T');
 writeln(wild('Schwietzke','Schwi*',false),' T');
 writeln(wild('Schwietzke','*tzke',false),' T');

 writeln(wild('Schwietzke','S?hwie*e',false),' T');
 writeln(wild('Schwietzke','S*??*e',false),' T');

 writeln(wild('Schwietzke','S*e',false),' T');
 writeln(wild('Schwietzke','*e',false),' T');

 writeln(wild('Schwietzke','S*k*',false),' T');
 writeln(wild('Schwietzke','S??w??tzke',false),' T');
 writeln(wild('Schwietzke','Sch*?t*ke',false),' T');
 writeln(wild('Schwietzke','Sch*k',false),' F');
 writeln(wild('Schwietzke','Sch*i?t*k?',false),' T');

 writeln(wild('Physik in ▄bersichten','?*',false),' T');
 writeln(wild('Physik in ▄bersichten','P*??*en',false),' T');

 writeln(wild('Alle Physik in ▄bersichten Physik in Ablagen',
              '*n Physik*',false),' T');

 {Thank's for testing and using.}
 {RenΘ Schwietzke 01-16-1995}
end.

