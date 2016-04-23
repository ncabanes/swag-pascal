{I am having trouble finding exact percents in BPC Pascal 7.0. While this
routine will compile under TPC 4.0+, I am still having troubles getting it
to come out to a rounded number. I have posted this message in other
conferences than Pascal simply because it's a math problem as well as a
programming problem. Thanks Moderators! }

  function calc_p2(num1,num2:integer):string15;
  var
    x:real;
    z:integer;
    cp:string[5];
  begin
    if num1=0 then calc_p2:='0' else calc_p2:='100';
    cp:='  0';
    if (num1=0) or (num2=0) then
      begin
        calc_p2:='    0';
        exit;
      end;
    x:=num1/num2*100;
    str(x:1:1,cp);
    if cp='100.00' then cp:='100';
    if cp='100.0' then cp:='100';
    if cp='0.0' then cp:='0';
    if cp='0.00' then cp:='0';
    while length(cp)<5 do insert(' ',cp,1);
    calc_p2:=cp;
  end;

begin
  writeln('50 into 100 = ',calc_p2(50,100));
  writeln('25 into 100 = ',calc_p2(50,100));
end.

The problem that I am having is, is that it isn't always accurate. I have
a program that has 13 different categories, each with an amount in each
category. Those are then calculated with the percents to show total number
against the full number of all categories. Unfortunatly, adding up the
percents comes up with 99.90% or 100.1% and even 100.3%.

IS there a way to get this to be ACCURATE? It's driving me nutts. Maybe I
am just approaching it in the wrong direction, but any help would be
appreciated.
