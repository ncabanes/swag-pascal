{
-> I would like to know what the best way is to identify the drive
-> letter
-> and type of each drive installed on a system.
-> Is there a DOS function? The equiptment check only tells numbers of
-> fixed disks, floppys, etc. I would like to know the letters.

This procedure reads the values in from CMOS...  It only does the A: and
B: drives, though..
}

function typeof(b:byte):string;
begin
     case b of
          0:typeof:='None';
          1:typeof:='360 KB 5 1/4';
          2:typeof:='1.2 MB 5 1/4';
          3:typeof:='720 KB 3 1/2';
          4:typeof:='1.44 MB 3 1/2';
          end;
     end;
var
   a:byte;
begin
     port[$70]:=$10;
     a:=port[$71];
     writeln('A: ',typeof(a shr 4));
     writeln('B: ',typeof(a and 15));
     port[$70]:=$11;
     a:=port[$71];
     end.

