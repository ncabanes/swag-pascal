{
>> Well, I'm actually working on a program that uses
>> pkunzip, arj etc too, and I solved it by using another
>> page when unzipping... just change [40h:4Ah] to let's
>> say, 1, and no output should come on your screen....
}

Mem[$40:$4A]:=1;
Exec(Filename,Params); {Or whatever}
Mem[$40:$4A]:=0;

