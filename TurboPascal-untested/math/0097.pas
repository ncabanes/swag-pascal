{
Hi Gayle. Got a couple of routines here for you. These are calculation
routines to find an accurate percentage between two given numbers. While
they are quite simple, perhaps they will help anyone who is just starting
out.

  { the following procedure will calculate the percentage between two
    given numbers, and report the percentage in a string. }

  type string10=string[10];

  function calc_p1(num1,num2:integer):string10;
  var
    z:real;
    out1:string[10];
  begin
    out1:='  0';
    if num1=0 then exit;
    if num2=0 then exit;
    z:=num1/num2;
    str(z:2:2,out1);
    if out1='1.00' then
      begin
        out1:='100';
        calc_p1:=out1;
        exit;
      end;
    delete(out1,1,2);
    if out1[1]='0' then delete(out1,1,1);
    while length(out1)<2 do insert(' ',out1,1);
    if out1='0' then out1:='100';
    if out1='' then out1:='0';
    calc_p1:=out1;
  end;

  { this procedure does the same thing, but breaks the percentage down
    to a tenth of a percentage (ie. 10.5% 99.98%, etc.) }

  function calc_p2(num1,num2:integer):string10;
  var
    z:real;
    out1:string[10];
  begin
    out1:='  -0- ';
    if num1=0 then exit;
    if num2=0 then exit;
    z:=num1 / num2;
    str(z:2:3,out1);
    delete(out1,1,2);
    if copy(out1,1,2)='00' then
      begin
        delete(out1,1,2);
        insert('.',out1,1);
      end else
    if copy(out1,1,1)='0' then
      begin
        delete(out1,1,1);
        insert('.',out1,2);
      end else insert('.',out1,3);
    if out1='.0' then out1:='100.00';
    calc_p2:=out1;
  end;

begin
  writeln('calc_p1: 50 into 100 is ',calc_p1(50,100),'%');
  writeln('calc_p2: 67 into 161 is ',calc_p2(67,161),'%');
end.
