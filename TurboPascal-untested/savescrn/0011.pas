 Program FancyWiper;
 uses crt;

 Type
   {I define the following type for all my virtual screens. Using this
    record allows me to write to any screen variable very easily}
   ScreenType = array [1..25,1..80] of record
        ch   : Char;
        Attr : Byte;
      end;

 Var
   {define a variable which points to the screen location. If you had a mono
    card then the address would be $B000:0000.}
   Screen : ScreenType absolute $B800:0000;

   {Declare a variable to save your old DOS screen}
   OldScreen : ScreenType;
   {Declare a virtual screen}
   VirtScr : ScreenType;

   {This procedure is used to write text to a virtual screen. Now
    there are no problems writing to line 25! ;-) }
   Procedure MyWrite(var Scr : ScreenType; x,y : integer; st : String);
   var
     t, xpos : integer;
   begin
     xpos := 0;

     {exit proc if y not in screen limits}
     if not (y in [1..25]) then
       exit;

     while (xpos+1 <= length(st)) and (xpos+x <=80) do
       begin
         with Scr[y, xpos+x] do
           begin
             ch := St[xpos+1];
             attr := TextAttr;
           end;
         inc(xpos);
       end;
   end;

   {A kludgy ClrScr for a virtual screen }
   Procedure MyClrScr(var Scr : ScreenType);
   begin
     fillchar(Scr, Sizeof(scr), 0);
   end;

   {Simple demonstration of a fancy effect. There's a lot more where this came
   from!!}
   Procedure Wipe(Scr : ScreenType; Left : Boolean; DelayTime : Word);
   var
     xstep,x,y : integer;
   begin
     if Left then
       begin
         xstep := -1;
         x := 80;
       end
     else
       begin
         xstep := 1;
         x := 1;
       end;

     while x in [1..80] do
       begin
         for y := 1 to 25 do
           Screen[y,x] := Scr[y,x];
         Delay(DelayTime);
         inc(x,xstep);
       end;
   end;


 Begin
   {Save the dos screen first}
   OldScreen := Screen;

   {Now go and do whatever you want with the screen}
   TextColor(Green);
   MyClrScr(VirtScr);
   MyWrite(VirtScr,10,10,'Hello there! Hows everything!  That should make this line long enough');
   MyWrite(VirtScr,10,13,'Whats your name : ');
   Wipe(VirtScr,True,30);
   GotoXy(28,13);
   TextColor(White);
   Readln;

   {Now to restore the old screen}
   Wipe(OldScreen,False,20);
 End.
