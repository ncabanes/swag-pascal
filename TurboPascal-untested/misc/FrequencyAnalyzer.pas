(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0104.PAS
  Description: Frequency Analyzer
  Author: STEVE ROGERS
  Date: 08-24-94  13:45
*)

{
JL>  #2: Another thing, I've got this cool Lotto program where I would like to
  >  a date file where the user can enter the weeks winning lotto numbers, then
  >  after a collection of weeks is made (say 10), the computer will read all t
  >  numbers in the file and compile a list of the most frequently ocurring num
  >  and print them out to the screen. I'm having trouble reading from and writ
  >  to the file. (I'll tackle the list compiling once that is straightened out
  >  help?

  Oh Boy, Lotto programs, the concept is pregnant with possibilities!
  Ever wonder why someone with a lotto program would sell it and not
  just win all the lottos? :)

  Ok, you want a frequency analyzer. Here's a start that will let you
  enter numbers and give a frequency table of all the numbers to date
  (hey, this is kinda fun, maybe I'll go into the lottery seminar
  bidness. Look out, Becky Paul!):
}

{$i-}
uses
  crt;

const
  MAX = 49;

type
  tFreqArray= array[0..MAX] of word;

var
  freqArray : tFreqArray;

{----------------------}
procedure InitFreqArray;
{ Read data file into array. If not found, zero all accumulators. }

var
  FreqF : file of tFreqArray;

begin
  assign(FreqF,'lotto.dat');
  reset(FreqF);
  if (ioresult=0) then begin
    read(Freqf,freqArray);
    close(freqF);
  end else fillchar(FreqArray,sizeof(FreqArray),0);
end;

{----------------------}
procedure SaveFreqArray;
var
  FreqF : file of tFreqArray;

begin
  assign(FreqF,'lotto.dat');
  rewrite(FreqF);
  write(Freqf,freqArray);
  close(freqF);
end;

{----------------------}
procedure PrintFrequencyTable;

type
  tPickRec=record
    Number : byte;
    Freq : word;
  end;
  tPickArray=array[0..MAX] of tPickRec;

var
  PickArray : tPickArray;

{-----------}
procedure SortPickArray;

{-----------}
procedure Swap(One,TheOther : byte);
var
  tmp : tPickRec;

begin
  tmp:= PickArray[One];
  PickArray[One]:= PickArray[TheOther];
  PickArray[TheOther]:= tmp;
end;

{----------}
var
  i,j,min : byte;

begin
  for i:= 0 to pred(MAX) do begin
    min:= i;
    for j:= succ(i) to MAX do
      if (PickArray[j].freq > PickArray[min].freq) then  min:= j;
    if (min>i) then Swap(i,min);
  end;
end; {SortPickArray}

{--------}
var
  i : byte;

begin
  for i:= 0 to MAX do with PickArray[i] do begin
    Number:= i;
    Freq:= FreqArray[i];
  end;

  SortPickArray;
  clrscr;
  writeln;
  writeln('Frequency Table:');
  for i:= 0 to 9 do
    writeln(PickArray[i].Number   :7,': ',PickArray[i].Freq   :5,' ',
            PickArray[i+10].Number:7,': ',PickArray[i+10].Freq:5,' ',
            PickArray[i+20].Number:7,': ',PickArray[i+20].Freq:5,' ',
            PickArray[i+30].Number:7,': ',PickArray[i+30].Freq:5,' ',
            PickArray[i+40].Number:7,': ',PickArray[i+40].Freq:5,' ');

end; {PrintFrequencyTable}

{----------------------}
procedure GetLottoNumbers;
var
  OneNumber : byte;
  Test : integer;
  s : string;

begin
  PrintFrequencyTable;
  repeat
    writeln;
    write('Enter lotto number (<=',MAX,', Enter to quit): ');
    readln(s);
    if (s<>'') then begin
      val(s,OneNumber,test);
      if (test=0) then begin
        inc(FreqArray[OneNumber]);
        PrintFrequencyTable;
      end;
    end;
  until (s='');

end; {GetLottoNumbers}
begin
  InitFreqArray;
  GetLottoNumbers;
  SaveFreqArray;
end.

