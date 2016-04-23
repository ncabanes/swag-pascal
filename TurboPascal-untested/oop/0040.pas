Unit Misc;

{
                                MISC.PAS
                     A Turbo Vision Object Library

                             By  Devin Cook
                               MSD - 1990

I haven't been exactly overwhelmed by the amount of Turbo Vision objects shared
by TP users, so I thought I would thow my hat into the ring and spread a few
objects I have developed around.

I am not an expert in Turbo Vision ( who can be in 3 weeks? ), or in OOP, so I
have probably broken quite a few rules, but you might get some ideas from the
work I have done.

This unit has some of the my more mainstream objects included.  I have a few
other, less general objects which I may spread around later.

These objects have not been used enough to verify they are 100% bug free, so
if you find any problems, or have any comments, please send me some Email
( D.Cook on Genie ).

                                OBJECTS:

TDateView      -    A date text box, much like TClockView in TVDemos.

TPushButton    -    A descendend of TButton, with "feel" for keyboard users.

TNum_Box       -    A number only input box with an adjustable number of digits
                    before and after the decimal point, along with selectable
                    negative number acceptance.

TLinked_Dialog -    A descendent of TDialog which allows you to set "Links"
                    between items ( i.e. item selection through cursor keys ).

Also, FormatDate, a function used by TDateView is provided.


                            ╔═════════════╗
                            ║  TDateView  ║
                            ╚═════════════╝


TDateView is almost identicle to TClockView ( in TVDemos - Gadget.Pas ).

INITIALIZATION:

TDateView is initialized by sending TDateView a TRect giving it's location.

USAGE:

Once TDateView is initialized, an occasional call to TDateView.Update keeps
the displayed date current.

Example:

  Var TR    : TRect ;
      DateV : TDateView ;
  Begin
      TR.Assign( 60 , 0 , 78 , 1 );
      DateV.Init( TR );
      DateV.Update ;
  End;



                           ╔═══════════════╗
                           ║  TPushButton  ║
                           ╚═══════════════╝


TPushButton is identicle to TButton in every way except that when it is
"pressed", it actually draws itself pressed.

This gives visual feedback to those using non-mouse systems.

The delay values in TPushButton.Press may need to be altered to adjust the
"feel".

                             ╔════════════╗
                             ║  TNum_Box  ║
                             ╚════════════╝


TNum_Box is a numerical entry box with definable precision.

INITIALIZATION:

TNum_Box is initialized by sending TNum_Box.Init:
        Location                            : TPoint
        Max Digits before the decimal point : Integer
        Max Digits after the decimal point  : Integer
        Negative Numbers allowed flag       : Boolean
        Default Value                       : Extended

If the digits after the decimal point = 0, no decimal point is displayed
( or excepted ).

If negative numbers are allowed, one extra space is reserved for a negative
sign.  No digits can be entered in this spot.

Only Backspace is used to edit the numberical field.

USAGE:

The value of the input box can be read directly from TNum_Box.Curr_Val.

This value may not be up to date if editing is still taking place, or no
data has been entered.  To ensure a correct reading, a call to
TNum_Box.Update_Value is recommended.

After initilization, the box is displayed with blanks for the number of digits.
If you wish to display the default value instead, use TNum_Box.Update_Value.

Example:

  Var TP        : TPoint ;
      Int_Box1  : TNum_Box ;
      Int_Box2  : TNum_Box ;
      Flt_Box1  : TNum_Box ;
  Begin
      Tp.X := 10 ;
      Tp.Y := 5 ;

      (* Define a box at 10,5 with 3 digits, no decimals, no negatives and a
         default of 0 *)

      Int_Box1.Init( TP , 3 , 0 , False , 0 )

      TP.X := 15 ;

      (* Define a box at 10,15 with 5 digits, no decimals, negatives and a
         default of 1.  Then, update the box displaying the default *)

      Int_Box2.Init( TP , 5 , 0 , True , 1 )
      Int_Box2.Update_Value ;

      TP.X := 25 ;

      (* Define a box at 10,25 with 5 digits, 2 decimal places , negatives and
         a default of 0.  Leave the box a blank. *)

      flt_Box1.Init( TP , 5 , 2 , True , 0 )

  End;

                          ╔══════════════════╗
                          ║  TLinked_Dialog  ║
                          ╚══════════════════╝


TLinked_Dialog is descendant of TDialog with improved cursor movement between
fields.

Developing for a non-mouse system ( even a mouse system ) where your dialogs
have over about 10 fields gets a bit ugly.  The tab key becomes impracticle
and setting hotkeys for each field may not be practicle.

The program EXAMPLE.PAS is not an exageration, it is a SIMPLIFIED version of
a dialog I am developing at work.  Try getting to a field #54 via tabs!

TLinked_Dialog solves the problem by having the Dialog jump between links
you define. Cursor keys are used to select the link direction, though 2 spare
links are defined for object future use or for object use.

     Example of a linking:               11
                                         21 22
                                         31

  Object 21 would want links defined for 11 ( DLink_Up ), 22 ( DLink_Right ),
  and 31 ( DLink_Down ).

  Once the links are defined, HandleEvent switches the focus according to the
  cursor keys.


INITIALIZATION:

TDialog is initialized exactly the same as TDialog.  ( Refer to the Turbo Vision
manual for details. )

TLinked_Dialog.Init calls TDialog.Init and the initialized a collection of
links to track item linking.

USAGE:

Once TLinked_Dialog is initialized, you insert items into the TLinked_Dialog
just as you would a normal dialog.

After the items are inserted, you set up links.

*****  NOTE:  Do not set up links for an item before it is inserted! *****

Links are created by calling TLinked_Dialog.Set_Link with
        Item to set link for    : PView
        Direction of link       : Integer
                                              Use the constants:
                                      DLink_Up, Dlink_Down, DLink_Right,
                                      DLink_Left, DLink_Spare1, Dlink_Spare2
        Pointer to linked item  : Pointer

All links are 1 way.  If you wish Button55 <--> Button56, you must define
two links, Button55 right to Button56 and Button56 left to Button55.  This is
because multiple items may be linked to the same item, which would make finding
the reverse link impossible.

You can select another object via a link by calling TLinked_Dialog.Select_Link
with the link direction.  The currently selected object's link will be traced
to the next object ( If possible ).

Example:

  Var TR    : TRect ;
      TP    : TPoint ;
      TLD   : TLinked_Dialog ;
      Butt1 : TPushButton ;
      Box1  : TNum_Box ;
      Box2  : TNum_Box ;
      Box3  : TNum_Box ;
      Box4  : TNum_Box ;

  Begin
      TR.Assign( 10 , 1 , 70 , 10 );
      TLD.Init( TR ,'Test Linked Dialog');


      (* Set up a button and insert it *)

      TR.Assign( 5 , 3 , 15 , 5 );
      Butt1.Init(TR,'~P~ush',cmOk,bfDefault));
      TLD.Insert( Butt1 );

      (* Set up box1 and insert it *)
      TP.Y := 8 ;
      TP.X := 3 ;

      Box1.Init( TP , 3 , 2 , FALSE , 1 );
      TLD.Insert( Box1 );

      (* Set up box2 and insert it *)
      TP.X := TP.X + 10 ;

      Box2.Init( TP , 3 , 2 , FALSE , 1 );
      TLD.Insert( Box2 );

      TP.Y := 9 ;
      TP.X := 3 ;

      (* Set up box3 and insert it *)

      Box3.Init( TP , 3 , 2 , FALSE , 1 );
      TLD.Insert( Box3 );

      TP.X := TP.X + 10 ;

      (* Set up box and insert it *)

      Box4.Init( TP , 3 , 2 , FALSE , 1 );
      TLD.Insert( Box4 );

      (*   Boxes at  [1] [2]  *)
      (*             [3] [4]  *)

      (* Link Box1 -> Box2 *)
      TDL.Set_Link( @BOX1 , DLink_Right , @BOX2 );

      (* Link Box1 <- Box2 *)
      TDL.Set_Link( @BOX2 , DLink_Left  , @BOX1 );

      (* Link Box3 -> Box4 *)
      TDL.Set_Link( @BOX3 , DLink_Right , @BOX4 );

      (* Link Box3 <- Box4 *)
      TDL.Set_Link( @BOX4 , DLink_Left  , @BOX3 );

      (* Link Box1 -> Box3 *)
      TDL.Set_Link( @BOX1 , DLink_Down  , @BOX3 );

      (* Link Box1 <- Box3 *)
      TDL.Set_Link( @BOX3 , DLink_Up    , @BOX1 );

      (* Link Box2 -> Box4 *)
      TDL.Set_Link( @BOX2 , DLink_Down  , @BOX4 );

      (* Link Box2 <- Box4 *)
      TDL.Set_Link( @BOX4 , DLink_Up    , @BOX2 );

End;


}

{ Note:  Tab Size = 4 }

(* Set conditions to allow for "Extended" type *)
{$N+,E+}

(**************************************************************************)
(*                                                                        *)
(*               Library of objects for Turbo Vision  V1.00               *)
(*                                                                        *)
(*               By:   Devin Cook                                         *)
(*                     copyright (c) 1990 MSD                             *)
(*                     Public Domain Object library                       *)
(*                                                                        *)
(*   Object:  TDateView                                                   *)
(*                Same as TClockView, except displays the date            *)
(*                                                                        *)
(*   Object:  TPushButton                                                 *)
(*                Same as TButton, except button "Show" press by keyboard *)
(*                                                                        *)
(*   Object:  TNum_Box                                                    *)
(*                An editable number only entry box - configurable        *)
(*                                                                        *)
(*   Object:  TLinked_Dialog                                              *)
(*                A normal dialog which handles cursor links to other     *)
(*                items                                                   *)
(*                                                                        *)
(*   Func:    FormatDate                                                  *)
(*                Formats a date into a string                            *)
(*                                                                        *)
(**************************************************************************)

{$F+,O+,S-,D+}

Interface

Uses Crt, Dos, Objects, Views, Dialogs, Drivers;

(*   Constents for Linked_Dialog   *)

Const        DLink_Left                =        1 ;
                DLink_Right                =        2 ;
                DLink_Up                =        3 ;
                DLink_Down                =        4 ;
                DLink_Spare1        =        5 ;
                DLink_Spare2        =        6 ;

Type

(**************************************************************************)
(*                                                                        *)
(*                        Object: TDateView                               *)
(*                                                                        *)
(*  Desc: TDateView is a static text object of the date, in a formated    *)
(*        string, usually placed on the status or menu lines.             *)
(*                                                                        *)
(*        Format:  Sun  Dec 16, 1990                                      *)
(*                                                                        *)
(*        This format can be altered by changing Function FormatDate.     *)
(*                                                                        *)
(*  Init: Initialization is done by supply a TRect to the INIT method.    *)
(*                                                                        *)
(*  Note: The UPDATE method checks to see if the Day-of-Week value still  *)
(*        matches the system Day-of-Week, and updates it's view if they   *)
(*        don't match.  An occasional call to TDateView.UPDATE will keep  *)
(*        your date indicator up to date.                                 *)
(*                                                                        *)
(**************************************************************************)

        PDateView = ^TDateView;
        TDateView = Object(TView)
                                        DateStr: string[19];
                                        Last_DOW: Word;
                                        Constructor Init(var Bounds: TRect);
                                        Procedure Draw; virtual;
                                        Procedure Update; virtual;
                                End;

(**************************************************************************)
(*                                                                        *)
(*                        Object: TPushButton                             *)
(*                                                                        *)
(*  Desc: TPushButton is a TButton except that it indicates being         *)
(*        pressed from the keyboard.                                      *)
(*                                                                        *)
(*  Note: You may wish to adjust with the delay values in the             *)
(*        TPushButton.Press method to suit your taste.                    *)
(*                                                                        *)
(*        See TButton for method descriptions.                            *)
(*                                                                        *)
(**************************************************************************)

  PPushButton        =        ^TPushButton;
  TPushButton        =        Object(Tbutton)
                                                Procedure Press ;        Virtual ;
                                        End;

(**************************************************************************)
(*                                                                        *)
(*                        Object: TNum_Box                                *)
(*                                                                        *)
(*  Desc: TInt_Box is a number only input box with an adjustable number   *)
(*        of digits before and after the decimal point.                   *)
(*                                                                        *)
(*        It can be flagged not to accept negative numbers if desired.    *)
(*                                                                        *)
(*  Init: Initialization is done by providing your desired configuration  *)
(*        to TNum_Box.Init.                                               *)
(*                                                                        *)
(*        TNum_Box.Init(                                                  *)
(*            Loc       -     TPoint with location for num                *)
(*            MaxWh     -     Integer with #digits before the decimal     *)
(*                            point                                       *)
(*            MaxDs     -     Integer with #digits after the decimal      *)
(*                            point                                       *)
(*            NegOk     -     Boolean.  True if neg values allowed        *)
(*            Deflt     -     Extended floating point with default value  *)
(*                     )                                                  *)
(*                                                                        *)
(*  Box width =   MaxWh +                                                 *)
(*                MaxDs + 1 ( if MaxDs > 0 ) +                            *)
(*                1 if Negok                                              *)
(*                                                                        *)
(*  To read the value back, simply access the Curr_Val variable for the   *)
(*  TNum_Box.  It is an extended floating point varaible, so you should   *)
(*  convert it to the desired precision.                                  *)
(*                                                                        *)
(*  Note:  A call to TNum_Box.Update_Val "Locks" the edited number into   *)
(*         the curr_val field, loading the default value if no number has *)
(*         been entered.                                                  *)
(*                                                                        *)
(**************************************************************************)

        PNum_Box    =        ^TNum_Box;
        TNum_Box    =        Object        ( TView )
                                                Max_Whole        :        Integer ;
                                                Max_Decs        :        Integer ;
                                                Max_Len                :        Integer ;
                                                Neg_Ok      :   Boolean ;
                                                Default_val        :        Extended ;
                                                Num_Str                :        String[24] ;
                                                Curr_Val        :        Extended ;
                                                Dec_Pos                :        Integer ;
                                                First_Char        :        Boolean ;

                                                Constructor Init( Loc        :        TPoint ;
                                                                                  MaxWh :        Integer ;
                                                                                  MaxDs :        Integer ;
                                                                                  NegOk :         Boolean ;
                                                                                  Dflt        :        Extended );
                                                Procedure Draw;        Virtual;
                                                Procedure HandleEvent( Var Event:TEvent ); Virtual;
                                                Procedure SetState( AState:Word; Enable:Boolean);
                                                        Virtual;
                                                Procedure Add_Digit( Charcode : Char );        Virtual;
                                                Procedure Do_Edit( Keycode : Word ); Virtual;
                                                Procedure Update_Value;
                                        End;

(*  Record used by TLinked_Dialog  *)

                DLink_Record        =        Record
                                                                Item                :        Pointer ;
                                                                Left_Link        :        Pointer ;
                                                                Right_Link        :        Pointer ;
                                                                Up_Link                :        Pointer ;
                                                                Down_Link        :        Pointer ;
                                                                Spare1_Link        :        Pointer ;
                                                                Spare2_Link        :        Pointer ;
                                                        End;

(*  Object for TLinked_Dialog's collection  *)

                PLink_Item                =        ^TLink_Item ;
                TLink_Item                =        Object
                                                                Item                :        Pointer ;
                                                                Pointers        :        Array[1..6] of Pointer ;
                                                                Constructor Init( Link_Rec : DLink_Record );
                                                                Procedure Add_Link( Link_Direc : Integer ;
                                                                                                        Link : Pointer );
                                                        End;

(*  TLinked_Dialog's collection of links  *)

                PLinked_List        =        ^TLinked_List ;
                TLinked_List        =        Object( TCollection )
                                                                Function Search( key : Pointer ) : Integer ;
                                                        End;

(**************************************************************************)
(*                                                                        *)
(*                        Object: TLinked_Dialog                          *)
(*                                                                        *)
(*  Desc: TLinked_Dialog is a variation of a standard dialog which        *)
(*        allows for improved cursor movement between items.              *)
(*                                                                        *)
(*        You can define which objects to "Link" to on the right, left,   *)
(*        above and below.  These objects are focused by use of the       *)
(*        cursor keys.                                                    *)
(*                                                                        *)
(*        Two spare links are defined for item use ( such as switching    *)
(*        to a certain box once a button is pressed. )                    *)
(*                                                                        *)
(*  Init: Initialization is identical to TDialog's init.  Refer to the    *)
(*        Turbo Vision manual for details.                                *)
(*                                                                        *)
(*  Inserting an item is identical to a normal TDialog.Insert. When an    *)
(*  item is inserted into a TLinked_Dialog, a record is created for       *)
(*  tracking links.                                                       *)
(*                                                                        *)
(*                             Defining a Link                            *)
(*                                                                        *)
(*  Once you have inserted all items into your dialog, links are created  *)
(*  to other items using TLinked_Dialog.Setlink.                          *)
(*                                                                        *)
(*  TLinked_Dialog.Setlink(                                               *)
(*       P          -    PView or descendant.                             *)
(*                       This is a pointer to the item you wish to add    *)
(*                       the link to.                                     *)
(*       Link_Direc -    Integer with link direction.                     *)
(*                       This should be one of the following constants:   *)
(*                             DLink_Up     :   Up                        *)
(*                             DLink_Down   :   Down                      *)
(*                             DLink_Right  :   Right                     *)
(*                             DLink_Left   :   Left                      *)
(*                             DLink_Spare1 :   Spare 1                   *)
(*                             DLink_Spare2 :   Spare 2                   *)
(*       Link       -    A pointer to the item you want to link to        *)
(*       )                                                                *)
(*                                                                        *)
(*                           Accesing a link                              *)
(*                                                                        *)
(*  Items within a dialog can switch to a linked item by calling:         *)
(*                                                                        *)
(*  TLinked_Dialog.Select_link(                                           *)
(*       Direc      -    Integer with link direction.                     *)
(*       )                                                                *)
(*                                                                        *)
(**************************************************************************)

                PLinked_Dialog        =   ^TLinked_Dialog ;
                TLinked_Dialog        =        Object( TDialog )
                                                                Link_List        :        TLinked_List ;
                                                                Constructor Init(var Bounds: TRect;
                                                                                                 ATitle: TTitleStr);
                                                                Procedure Insert(P: PView); Virtual;
                                                                Procedure Set_Link( P: PView ;
                                                                                                        Link_Direc : Integer ;
                                                                                                        Link : Pointer );
                                                                Procedure HandleEvent( Var Event : TEvent );
                                                                        Virtual;
                                                                Procedure Select_Link( Direc : Integer );
                                                        End;


(**************************************************************************)
(*                                                                        *)
(*                      Function: FormatDate                              *)
(*                                                                        *)
(*  Desc:  The format date function used by TDateView, made public for    *)
(*         other possible uses.                                           *)
(*                                                                        *)
(**************************************************************************)

Function FormatDate( Year , Month , Day , DOW : Word ): String;

Implementation

(**************************************************************************)
(*                                                                        *)
(*                        Object: TDateView                               *)
(*                                                                        *)
(**************************************************************************)

Constructor TDateView.Init(var Bounds: TRect);
Begin
        TView.Init(Bounds);
        DateStr := '';
        LAST_DOW := 8 ;     (*  Force an update!  *)
End;


(* Draw the TDateView object *)

Procedure TDateView.Draw;
Var
        B: TDrawBuffer;
        C: Byte;
Begin
        C := GetColor(2);
        MoveChar(B, ' ', C, Size.X);
        MoveStr(B, DateStr, C);
        WriteLine(0, 0, Size.X, 1, B);
End;

(* Verify the TDateView object is up to date *)
(* Redisplaying it if it needs updating      *)

Procedure TDateView.Update;
Var Year, Month, Day, DOW : word;
Begin
        GetDate( Year , Month , Day , Dow );
        If (DOW <> LAST_DOW) then
        Begin
                DateStr := FormatDate( Year , Month , Day , DOW );
                DrawView;
                LAST_DOW := DOW ;
        End;
End;

(**************************************************************************)
(*                                                                        *)
(*                        Object: TPushButton                             *)
(*                                                                        *)
(**************************************************************************)

Procedure TPushButton.Press;
Begin
        DrawState(TRUE);        (*  Draw Button "Pressed"  *)
        Delay(150);
        DrawState(FALSE);        (*  Draw Button "Released" *)
        Delay(50);
        TButton.Press;
End;

(**************************************************************************)
(*                                                                        *)
(*                        Object: TNum_Box                                *)
(*                                                                        *)
(**************************************************************************)

Constructor TNum_Box.Init( Loc : TPoint ; MaxWh, MaxDs : Integer ;
                                                   NegOk : Boolean ;  Dflt : Extended );
Var        R                :        TRect ;
        X                :        Integer ;
        Wrk_Str :        String ;

Begin

        Wrk_Str := '' ;
        If ( NegOk ) then
                Wrk_Str := ' ' ;
        For X := 1 to MaxWh do
                Wrk_Str := Wrk_Str + ' ' ;

        If ( MaxDs > 0 ) then
        Begin
                Wrk_Str := Wrk_Str + '.';
                For X := 1 to MaxDs do
                        Wrk_Str := Wrk_Str + ' ' ;
        End;
        R.Assign( Loc.X , Loc.Y , Loc.X + Length( Wrk_Str ) , Loc.Y + 1 );
        TView.Init( R ) ;

        Num_Str := Wrk_Str ;

        Neg_Ok := NegOk ;
        Max_Whole := MaxWh ;
        Max_Decs := MaxDs ;

        Max_Len := Length( Num_Str );

        Options := Options OR ofSelectable ;

        Default_Val := Dflt ;
        Curr_Val := Dflt ;
        Dec_Pos := Pos( '.' , Num_Str );

        If ( Dec_Pos < 1 ) then
                Dec_Pos := Max_Len + 1 ;


        Cursor.X := Dec_Pos - 2;

        First_Char := True ;
        ShowCursor;
End;

(*  Draw the TNum_Box on the view.  *)
(*  Color depends on the state of   *)
(*  the object.                     *)

Procedure TNum_Box.Draw;
Var        Buff : TDrawBuffer ;
        Colr : Word;
Begin
        Colr := GetColor(19);
        If GetState(sfFocused) then
                If First_Char then
                        Colr := GetColor(20)
                else
                        Colr := GetColor(22);

        MoveChar( Buff,' ',Colr, Size.X);
        MoveStr( Buff,Num_Str,0);
        Writeline(0,0,Size.X,1,Buff);

End;

(*  Updated SetState to watch for changes in the  *)
(*  selected and focused flags.                   *)

Procedure TNum_Box.SetState(AState: Word; Enable: Boolean);
Begin
        TView.SetState(AState, Enable);
        If ( AState = sfFocused ) then
                Draw ;
        If ( AState = sfFocused ) And ( Enable ) then
                First_Char := TRUE ;
End;

(*  HandleEvent, routing keystrokes  *)

Procedure TNum_Box.HandleEvent( Var Event : TEvent );
Var        NextCmd: TEvent;
        test:PEvent;
Begin
        TView.HandleEvent( Event );
        If Event.What = evKeydown then
        Begin
                Case ( Event.Charcode ) of
                        #00                :   Begin
                                                End;
                        #08                :        Begin
                                                        Do_Edit( Event.keyCode );
                                                        ClearEvent( Event );
                                                End;
                        #13                :        Begin
                                                        ClearEvent( Event );
                                                        Update_Value ;
                                                End;
                        '0'..'9':        Begin
                                                        Add_Digit( Event.Charcode );
                                                        ClearEvent( Event );
                                                End;
                        '.','-':        Begin
                                                        Add_Digit( Event.Charcode );
                                                        ClearEvent( Event );
                                                End;
                        End;
        End;
End;

(*  Perform normal charector addition to the number string  *)

Procedure TNum_Box.Add_Digit( Charcode : Char );
Var        X                        :        Integer ;
        First_Dig        :        Integer ;
Begin

        If ( First_Char ) then
        Begin
                For X := 1 to Length( Num_Str ) do
                        If (Num_Str[X]<>'.') then
                                Num_Str[X]:=' ';

                First_Char := False ;
                Cursor.X := Dec_Pos - 2;
                ShowCursor;
        End;

        If Neg_Ok then
                First_Dig := 2
        else
                First_Dig := 1;

        If ( Cursor.X < Dec_Pos ) then
        Case ( Charcode ) of
                '0'..'9'        :        If Not( Num_Str[ First_Dig ] IN ['0'..'9']) then
                                                Begin
                                                        For X := 1 to Cursor.X do
                                                                Num_Str[X] := Num_Str[X+1] ;
                                                        Num_Str[ Cursor.X + 1 ] := Charcode ;
                                                End;
                '-'                        :        Begin
                                                        If (Neg_Ok) then
                                                        Begin
                                                                if (Num_Str[ Cursor.X + 1 ] = ' ') then
                                                                        Num_Str[ Cursor.X + 1 ] := '-'
                                                        End;
                                                End;
                '.'                        :        Begin
                                                        If (Max_Decs>0) and ( Cursor.X < Dec_Pos ) then
                                                        Begin
                                                                Cursor.X := Dec_Pos ;
                                                                ShowCursor;
                                                        End;
                                                End;
        End
        else
        Case ( Charcode ) of
                '0'..'9'        :        Begin
                                                        If ( Cursor.X < ( Max_Len - 1 )) then
                                                        Begin
                                                                Num_Str[Cursor.X+1] := Charcode ;
                                                                Inc( Cursor.X );
                                                                ShowCursor;
                                                        End
                                                        else
                                                                if Num_Str[Cursor.X+1] = ' ' then
                                                                        Num_Str[Cursor.X+1] := Charcode ;
                                                End;
        End;

        Draw;
End;

(*  Perform any editing on the number string  *)
(*  ( Only the <Backspace> key is currently   *)
(*  supported ).                              *)

Procedure TNum_Box.Do_Edit( Keycode : Word );
Var        X                        :        Integer ;
Begin
        First_Char := False ;
        If ( Dec_Pos = 0 ) or ( Cursor.X < Dec_Pos ) then
        Begin
                If (Keycode = kbBack) then
                Begin
                        For X := Cursor.X+1 downto 2 do
                                Num_Str[X] := Num_Str[X-1] ;
                        Num_Str[ 1 ] := ' ' ;
                End;
        End
        else
        Begin
                If (Keycode = kbBack) then
                Begin
                        If Num_Str[Cursor.X+1] = ' ' then
                        Begin
                                Dec( Cursor.X );
                                Num_Str[Cursor.X+1] := ' ';
                        End
                        else
                                Num_Str[Cursor.X+1] := ' ';

                        If Num_Str[ Cursor.X ] = '.' then
                                Cursor.X := Cursor.X - 2 ;
                        ShowCursor;
                End;
        End;

        Draw;
End;

(* "Lock" the number string value in the box.     *)
(* Use the default value if no number is present. *)

Procedure TNum_Box.Update_Value;
Var Code        :        Integer ;
        Work_str:        String[24];
Begin
        Work_Str := Num_Str ;
        While (( Length( Work_Str )>0 ) and ( Work_Str[Length( Work_Str )] IN ['.',' '])) do
                Work_Str := Copy( Work_Str , 1 , length( Work_Str ) -1 );

        Code := 0 ;

        If ( Work_Str = '' ) then
                Curr_Val := Default_Val
        else
                Val( Work_Str, Curr_Val , Code );
        Str( Curr_Val:Max_Len:Max_Decs , Num_Str );

        Cursor.X := Max_Len - 1 ;
        First_Char := True ;
        Draw;
End;

(**************************************************************************)
(*                                                                        *)
(*                        Object: TLink_Item                              *)
(*                                                                        *)
(*                 Used by TLinked_Dialog to track links                  *)
(*                                                                        *)
(**************************************************************************)

Constructor TLink_Item.Init( Link_Rec : DLink_Record );
Begin
        Item := Link_Rec.Item ;
        With Link_Rec do
        Begin
                Pointers[DLink_Left]        := Left_Link;
                Pointers[DLink_Right]        := Right_Link;
                Pointers[DLink_Up]                := Up_Link;
                Pointers[DLink_Down]         := Down_Link;
                Pointers[DLink_Spare1]        := Spare1_Link;
                Pointers[DLink_Spare2]        := Spare2_Link;
        End;
End;

Procedure TLink_Item.Add_Link( Link_Direc : Integer ; Link : Pointer );
Begin
        Pointers[ Link_Direc ] := Link ;
End;

(**************************************************************************)
(*                                                                        *)
(*                        Object: TLink_List                              *)
(*                                                                        *)
(*                 Used by TLinked_Dialog to track links                  *)
(*                                                                        *)
(**************************************************************************)

Function TLinked_List.Search( Key : Pointer ) : Integer ;
Var        X : Integer ;
        Found : Boolean ;
        Linked_Item : PLink_Item ;
Begin
        Search := -1 ;
        Found := False ;
        X := 0 ;
        While ( X < Count ) AND ( NOT FOUND ) do
        Begin
                Linked_Item := at( X );
                Found := Linked_Item^.Item = Key ;
                X := X + 1 ;
        End;

        If ( Found ) then
                Search := X - 1 ;
End;

(**************************************************************************)
(*                                                                        *)
(*                        Object: TLinked_Dialog                          *)
(*                                                                        *)
(**************************************************************************)

Constructor TLinked_Dialog.Init(var Bounds: TRect; ATitle: TTitleStr);
Begin
        TDialog.Init( Bounds , ATitle );
        Link_List.Init(10, 5);
End;

Procedure TLinked_Dialog.Insert(P: PView);
Var        Linked_Item : PLink_Item ;
        Blank_Rec : DLink_Record ;
Begin
        With Blank_Rec do
        Begin
                Item := P ;
                Left_Link         := Nil ;
                Right_Link        := Nil ;
                Up_Link                := Nil ;
                Down_Link        := Nil ;
                Spare1_Link        := Nil ;
                Spare2_Link := Nil ;
        End;
        Linked_Item := New( PLink_Item , Init( Blank_Rec ) );
        TDialog.Insert( P );
        Link_List.Insert( Linked_Item );
End;

Procedure TLinked_Dialog.Set_Link(P:PView;Link_Direc:Integer;Link:Pointer);
Var        Linked_Item : PLink_Item ;
        X : Integer ;
Begin
        X := Link_List.Search( P );
        If ( X < 0 ) then
                Exit ;
        Linked_Item := Link_List.at( X );
        Linked_Item^.Pointers[ Link_Direc ] := Link ;
End;

Procedure TLinked_Dialog.Select_Link( Direc : Integer );
Var        X                : Integer ;
        LL_Item        : PLink_Item ;
        Item        : PView ;
Begin
        X := Link_List.Search( Current );
        LL_Item := Link_List.at(X);
        Item := LL_Item^.Pointers[ Direc ];
        If ( Item <> Nil ) then
                Item^.Select ;
End;

Procedure TLinked_Dialog.HandleEvent( Var Event : TEvent );
Var        X                : Integer ;
        LL_Item        : PLink_Item ;
        Item        : PView ;
Begin
        TDialog.HandleEvent( Event );

        If ( Event.What = evKeydown ) then
                Case Event.keycode of
                        kbUp        :        Begin
                                                        Select_Link( DLink_Up );
                                                        ClearEvent( Event );
                                                End;
                        kbDown        :        Begin
                                                        Select_Link( DLink_Down );
                                                        ClearEvent( Event );
                                                End;
                        kbRight        :        Begin
                                                        Select_Link( DLink_Right );
                                                        ClearEvent( Event );
                                                End;
                        kbLeft        :        Begin
                                                        Select_Link( DLink_Left );
                                                        ClearEvent( Event );
                                                End;
                End;
End;

(**************************************************************************)
(*                                                                        *)
(*                      Function: FormatDate                              *)
(*                                                                        *)
(**************************************************************************)

Function FormatDate( Year , Month , Day , DOW : Word ): String;
Const
        DAYS : Array[0..6] of String = ( 'Sun','Mon','Tue','Wed','Thu','Fri','Sat');
        MONTHS : Array[1..12] of String = ( 'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec');
Var Work1,Work2 : String[4] ;
Begin
        Str( Day,Work1 );
        If ( Day < 10 ) then
        Work1 := '0' + Work1 ;
        Str( Year,Work2 );
        FormatDate := DAYS[DOW]+'  '+MONTHS[Month]+' '+Work1+', '+Work2;
End;

Begin
end.

{-----------------------    DEMO CODE --------------------- }

Program Example;

Uses Crt,App, Objects, Views, Dialogs, Drivers, Misc;

Type
        PMyApp                =        ^TMyApp ;
        TMyApp                =        Object( TApplication )
                                                Constructor Init;
                                        End;

Var
        MyApp        :        TMyApp ;
        Dialog  :   PLinked_Dialog;

        Screen_Array        :        Array[1..70] of TNum_Box;

Procedure Build_Links;
Var        P        :        TPoint ;
        X,Y :        Integer ;
        N        :        Integer ;
Begin

        For N := 1 to 50 do
        Begin
                P.Y := ( N - 1 ) DIV 10         + 8 ;
                P.X := ( N - 1 ) MOD 10 * 4 + 20 ;

                Screen_Array[N].Init( P , 3 , 0 , FALSE , N );
                Screen_Array[N].Update_Value;
        End;

        For N := 1 to 8 do
        Begin
                P.Y := ( N - 1 ) Div 3 * 2 + 8  ;
                P.X := ( N - 1 ) Mod 3 * 4 + 60 ;
                If ( N > 6 ) then
                        P.X := P.X + 4 ;
                Screen_Array[N+50].Init( P , 3 , 0 , FALSE , N+50 );
                Screen_Array[N+50].Update_Value;
        End;

        P.Y := 6 ;

(* Initialize 5 floating point boxes *)

        For N := 1 to 5 do
        Begin
                P.X := ( N * 12 ) ;
                Screen_Array[N+58].Init( P , 4 , 2 , True , N+58 );
        End;

(* Insert all boxes before setting links! *)

        For N := 1 to 63 do
                Dialog^.Insert( @Screen_Array[N] );

        For N := 1 to 50 do
        Begin
                if ( N MOD 10 ) <> 1 then
                        Dialog^.Set_Link(@Screen_array[N],DLink_Left ,@Screen_array[N-1]);
                if ( N MOD 10 ) <> 0 then
                        Dialog^.Set_Link(@Screen_array[N],DLink_Right,@Screen_array[N+1]);
                if ( N > 10 ) then
                        Dialog^.Set_Link(@Screen_array[N],DLink_Up   ,@Screen_array[N-10])
                else
                        Dialog^.Set_Link(@Screen_array[N],DLink_Up   ,@Screen_array[59]);

                if ( N <41 ) then
                        Dialog^.Set_Link(@Screen_array[N],DLink_Down ,@Screen_array[N+10]);

                if ( N=10 ) or ( N=20 ) then
                        Dialog^.Set_Link(@Screen_array[N],DLink_Right,@Screen_array[51]);

                if ( N=30 ) or ( N=40 ) then
                        Dialog^.Set_Link(@Screen_array[N],DLink_Right,@Screen_array[54]);
        End;

        Dialog^.Set_Link(@Screen_array[50],DLink_Right,@Screen_array[57]);

        Dialog^.Set_Link(@Screen_array[51],DLink_Left ,@Screen_array[10]);
        Dialog^.Set_Link(@Screen_array[51],DLink_Right,@Screen_array[52]);
        Dialog^.Set_Link(@Screen_array[51],DLink_Down ,@Screen_array[54]);

        Dialog^.Set_Link(@Screen_array[52],DLink_Left ,@Screen_array[51]);
        Dialog^.Set_Link(@Screen_array[52],DLink_Right,@Screen_array[53]);
        Dialog^.Set_Link(@Screen_array[52],DLink_Down ,@Screen_array[55]);

        Dialog^.Set_Link(@Screen_array[53],DLink_Left ,@Screen_array[52]);
        Dialog^.Set_Link(@Screen_array[53],DLink_Down ,@Screen_array[56]);

        Dialog^.Set_Link(@Screen_array[54],DLink_Left ,@Screen_array[30]);
        Dialog^.Set_Link(@Screen_array[54],DLink_Right,@Screen_array[55]);
        Dialog^.Set_Link(@Screen_array[54],DLink_Down ,@Screen_array[57]);
        Dialog^.Set_Link(@Screen_array[54],DLink_Up   ,@Screen_array[51]);

        Dialog^.Set_Link(@Screen_array[55],DLink_Left ,@Screen_array[54]);
        Dialog^.Set_Link(@Screen_array[55],DLink_Right,@Screen_array[56]);
        Dialog^.Set_Link(@Screen_array[55],DLink_Down ,@Screen_array[57]);
        Dialog^.Set_Link(@Screen_array[55],DLink_Up   ,@Screen_array[52]);

        Dialog^.Set_Link(@Screen_array[56],DLink_Left ,@Screen_array[55]);
        Dialog^.Set_Link(@Screen_array[56],DLink_Down ,@Screen_array[58]);
        Dialog^.Set_Link(@Screen_array[56],DLink_Up   ,@Screen_array[53]);

        Dialog^.Set_Link(@Screen_array[57],DLink_Left ,@Screen_array[50]);
        Dialog^.Set_Link(@Screen_array[57],DLink_Right,@Screen_array[58]);
        Dialog^.Set_Link(@Screen_array[57],DLink_Up   ,@Screen_array[55]);

        Dialog^.Set_Link(@Screen_array[58],DLink_Left ,@Screen_array[57]);
        Dialog^.Set_Link(@Screen_array[58],DLink_Up   ,@Screen_array[56]);

        For N := 59 to 63 do
        Begin
                if ( N > 59 ) then
                        Dialog^.Set_Link(@Screen_array[N],DLink_Left ,@Screen_array[N-1]);
                if ( N < 63 ) then
                        Dialog^.Set_Link(@Screen_array[N],DLink_Right,@Screen_array[N+1]);
                Dialog^.Set_Link(@Screen_array[N],DLink_Down,@Screen_array[1]);
        End;
End;

Procedure Do_Dialog;
Var        R                :        TRect ;
        TP                :        TPoint ;
        N                :        Integer ;
        Button        :        PButton ;
Begin

        R.Assign( 0 , 10 , 80 , 24 );
        Dialog := New( PLinked_Dialog , Init( R , 'Linked Dialog Example' ));
        Dialog^.SetState(sfShadow,False );

        Build_Links;

        R.Assign( 5 , 8 , 15 , 10 );
        Button := New(PPushButton,Init(R,'~P~ush',cmOk,bfDefault));
        Dialog^.Insert( Button );

        R.Assign( 5 , 11 , 15 , 13 );
        Button := New(PPushButton,Init(R,'~E~xit',cmQuit,bfDefault));
        Dialog^.Insert( Button );

        Dialog^.Set_Link(Button,DLink_Right,@Screen_array[1]);

        MyApp.Insert( Dialog );

End;


Constructor TMyApp.Init;
Begin
        TApplication.Init ;
        Do_Dialog;
End;

Begin
        ClrScr;
        MyApp.Init ;
        MyApp.Run ;
        MyApp.Done ;
End.