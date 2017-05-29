(*
  Category: SWAG Title: MENU MANAGEMENT ROUTINES
  Original name: 0001.PAS
  Description: MENUDEMO.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:51
*)

Program Menu; Uses Crt;

Const
  MenuChoice : Array[1..3] of String[9] = ('Choice #1', 'Choice #2',
                                            'Choice #3');
  MenuPosX = 35;  MenuPosY = 10;
  NumberChoices = 3;

Type
  keys = (ReturnKey,Up,Down,Escape);

Var
  Key : keys;
  fk : Boolean;
  ch : Char;
  x, y, CurrentChoice : Integer;

Procedure SetChoiceColor(back,Fore : Integer);
begin
  TextBackGround(back);
  TextColor(Fore);
end;

Procedure GetKey;
begin
  fk := False;
  ch := ReadKey;
  if ch = #0 then
    begin
      fk := True;
      ch := ReadKey;
    end;
  if fk then
    begin
      Case ord(ch) of
        72 : key := Up;
        80 : key := Down;
      end; end;
      if not fk then
        begin
          Case ord(ch) of
            13 : key := ReturnKey;
            27 : key := Escape;
          end;
        end;
    end;

begin
  SetChoiceColor(7,0);                  {.. reverse vid black on white }
  For x := 1 to NumberChoices do
    begin                               {.. Write menu options }
      GotoXY(MenuPosX,MenuPosY+x-1);
      if x > 1 then SetChoiceColor(0,7);  {..turn reverse off after }
        Write(MenuChoice[x]);               {  first option written   }
    end;
  GotoXY(MenuPosX,MenuPosY);            {..position curosr on 1st option }
  CurrentChoice := 1;

  Repeat
    GetKey;                               {..wait For a key to be pressed }
    SetChoiceColor(0,7);                  {..reverse vid white on black }
    Write(MenuChoice[CurrentChoice]);     {..un-highlight current option }

    Case key of
      Up   : if CurrentChoice > 1 then dec(CurrentChoice)
               else CurrentChoice := NumberChoices;
      Down : if CurrentChoice < 3 then inc(CurrentChoice)
               else CurrentChoice := 1;
      end;

    SetChoiceColor(7,0);                        {..reverse vid black/white }
    GotoXY(MenuPosX,MenuPosY+CurrentChoice-1);
    Write(MenuChoice[CurrentChoice]);           {..highlight new option }
    GotoXY(MenuPosX,MenuPosY+CurrentChoice-1);
    Until (Key = ReturnKey) or (Key = Escape);

    SetChoiceColor(0,7);

    GotoXY(1,15);
    Case CurrentChoice of
      1 : Writeln('You chose 1');
      2 : Writeln('You chose 2');
      3 : Writeln('You chose 3');
    end;

end.
