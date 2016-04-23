{Here's a neat ANSI effect that scrolls a string in... quite neat i think.}

  procedure Thingy;
    const
      len = 45;
      IL : string[len] = 'Cool String Thingy! by The MAN';
      chardelay = 10;
      enddelay = 1000;
    var
      loop: byte;
    begin
      TextColor(white);
      GotoXY(1,1);
      write(IL);
      Delay(chardelay);
      TextColor(Random(15)+1);
      GotoXY(1,1);
      write(IL[1]);
      Delay(chardelay);
      GotoXY(2,1);
      TextColor(Random(15)+1);
      write(IL[2]);
      Delay(chardelay);
      for loop:=3 to len do
        begin
          GotoXY(loop-2,1);
      TextColor(Random(15)+1);
      {TextColor(white);}
      write(IL[loop-2]);
      Delay(chardelay);
      GotoXY(loop-1,1);
      TextColor(Random(15)+1);
      write(IL[loop-1]);
      Delay(chardelay);
      GotoXY(loop,1);
      TextColor(Random(15)+1);
      write(IL[loop]);
      Delay(chardelay);
    end;
      Delay(enddelay);
    end;

BEGIN
Thingy;
END.

