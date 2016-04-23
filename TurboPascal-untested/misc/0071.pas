{
>I've been trying to create a simple pick list using Object Proffesional and
>can't seem to get it to do what I want. I'm using the expick.pas example as
>start for creating my pick list. Everything is pretty much the same except
>that I want my pick list to exit with other keys insted of the enter key.
>The manual doesn't go into detail about this.

Check out the docs for OpCmd.  The procedure that you're wanting is
"AddCommand".   In my example below, I've set up a multiple choice list
that "remaps" the <Enter> key to toggle (like the <SpaceBar>) and use
<F10> to accept the choices.  Here's my example:

{DON'T FORGET TO "USE" OpCmd}

uses
   OpCmd; {among others}

procedure GetPicks;
var
   PL                  :PickList;
   PickDone            :boolean;

begin
   if not PL.InitDeluxe(screenwidth shr 1-16,5,
                        screenwidth shr 1+15,screenheight-6,
                        AltMenuCS,     {color set}
                        WinOpts,       {window options}
                        33,            {width of pick list strings}
                        NumItems,      {number of items}
                        UserStrings,   {user-string proc}
                        PickVertical,  {pick direction-type}
                        MultipleChoice,{single or multiple}
                        pkStick)then   {stick at edges}
    begin
        {error message}
        exit;
    end;
    PickCommands.AddCommand(ccToggle,1,$1C0D,0); {Enter=Toggle}
    PickCommands.AddCommand(ccSelect,1,$4400,0); {F10=Accept}
    PickDone:=false;
    repeat
       PL.Process;
       case PL.GetLastCommand of
          ccSelect:  {F10}
             begin
             end;

           ccQuit:
              PickDone:=true;

           ccError:
              begin
                 PickDone:=true;
              end;
        end; {case}
     until PickDone;
     HideMouse;

     {NOTE THE FOLLOWING LINES:  They're needed to remap the <Enter>
      key to its original setting and gets rid of the <F10> key as
      the ccSelect.  If you want *ALL* of your pick lists throughout
      your program to behave this way, use the PickCommands.AddCommand
      at the beginning of your program.}

      PickCommands.AddCommand(ccSelect,1,$1C0D,0); {Enter=Toggle}
      PickCommands.AddCommand(ccNone,1,$4400,0); {F10=Accept}
      PL.Done;
   end;
end;

{
CHARLES SERFOSS

>I've been trying to create a simple pick list using Object Proffesional and
>can't seem to get it to do what I want. I'm using the expick.pas example as a
>start for creating my pick list. Everything is pretty much the same except
>that I want my pick list to exit with other keys insted of the enter key.
>The manual doesn't go into detail about this.

You'll have to use the "AddCommand" method.  Here's an example.  This is
based on "expick1.pas" from Page 4-186 of Book #1.
}

program PickListExample;
uses
        OpCrt, OpRoot, OpCCmd, OpFrame, OpWindow, OpPick;
const
        NumPizzaToppings = 5;
var
        PizzaTop : PickList;
        PickWindowOptions : Longint;

procedure PizzaTopping(Item : Word { etc... }) : Far;
begin
end;

begin { Main }
        if not PizzaTop.InitCustom(35, 5, 45, { etc ... }) then begin
                halt;
        end;
        PizzaTop.SetSearchMode(PicckCharSearch);
        PizzaTop.EnableExplosion(20);
        with PizzaTop.wFrame do begin
                AddShadow...
                AddHeader...
        end;
        { *************** Decide Which Keys In Addition To Defaults To Allow }
        { PickCommands is just mentioned at the end of page 4-207.  The      }
        { CommandProcessor Type allows you to use the functions in section   }
        { (E) OPCMD - Page 3-82.  See Page 3-95 for documentation on         }
        { the "AddCommand" method!                                           }
        { *******************************************************************}
        with PickCommands do
        begin
                AddCommand(ccUser1,1,$5200,0); { $5200 = scan code for INS }
                AddCommand(ccUser2,1,$5300,0); { $5300 = scan code for DEL }
        end;
        PizzaTop.Process;
        PizzaTop.Erase;
        case PizzaTop.GetLastCommand of
                ccUser1 : ; { If User hits INS, this is executed }
                ccUser2 : ; { If User hits DEL, this is executed }
                ccSelect : writeln('You chose : ',PizzaTop.GetLastChoiceString);
        end;
        PizzaTop.Done;
end. { Main }

{
DAVID HOWORTH

> I've been trying to create a simple pick list using Object Proffesional
> can't seem to get it to do what I want. I'm using the expick.pas exampl
> start for creating my pick list. Everything is pretty much the same exc
> that I want my pick list to exit with other keys insted of the enter ke
> The manual doesn't go into detail about this.

Nick--The manual does go into subtantial detail.  You just need to
know where to look.  As with much of OPro, the things you want to
do with a particular object may be implemented, not in the object
per se, but in one of its ancestors.  It always pays to look in the
manual at the ancestor's methods.

You need to read up on CommandWindow, from which PickList is
descended, and on CommandProcessor, in OpCmd.  Here's a relevant
piece of code from one of my programs.  The first AddCommand adds
an additional Quit; the others are for purposes specific to my
application, not for predefined commands such as ccQuit.
}
with DialPickList { a PickList descendent } do

   with PickCommands do begin
     { Simulate WordPerfect's exit command }
     AddCommand(ccQuit,1,$4100,0);       { F7 }

     { ccUser0 = Add a new phone entry }
     AddCommand(ccUser0,1,$1E00,0);      {Alt-A}
     AddCommand(ccUser0,1,$5200,0);      {Ins}

     { ccUser1 = Delete a phone entry }
     AddCommand(ccUser1,1,$2000,0);      {Alt-D}
     AddCommand(ccUser1,1,$5300,0);      {Del}

     { ccUser2 = Edit a phone entry }
     AddCommand(ccUser2,1,$1200,0);      {Alt-E}

     { ccUser3 = Reconfigure Comm Stuff }
     AddCommand(ccUser3,1,$2E00,0);      {Alt-C}

     { ccUser4 = View log (the printing and purging routines branch
       from the browsing routine }
     AddCommand(ccUser4,1,$2F00,0);      {Alt-V}

  end; { with PickCommands }

end; { with DialPickList }
