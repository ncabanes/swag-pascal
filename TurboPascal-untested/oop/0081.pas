{
 Since I received the request I post the following Turbo Vision snippet. The
 object in the code below is a very basic growbar. It is meant to be inserted
 into a dialog box and to show the progress of a certain action. The object
 is very simple so I didn't comment the source. I did include an example on
 how to put the progress bar into a dialog box. If you have questions about
 this code, feel free to ask. This is the text version of this object, the
 graphical version will follow later (it is a bit more complicated and I want
 to comment on it).

 Here we go :

 {==========================================================================}
 {= Unit name      : GrowView                                              =}
 {= Version        : 1.0                                                   =}
 {= Public Objects : TGrowView                                             =}
 {===--------------------------------------------------------------------===}
 {= Programmer     : David van Driessche                                   =}
 {= Language       : Borland Pascal 7.0                                    =}
 {===--------------------------------------------------------------------===}
 {= This code is property of David van Driessche (FidoNet 2:291/1933.13)   =}
 {= Please use it as you like.                                             =}
 {==========================================================================}

 {$F+,O+,X+,I+,B-,V-}

 {$ifdef DebugVersion}
  {$R+,S+,Q+,D+,L+,Y+}
 {$else}
  {$R-,S-,Q-,D-,L-,Y-}
 {$endif}

 unit GrowView ;

 interface

 uses Objects, Views ;

 type
  PGrowView = ^TGrowView ;
  TGrowView = object( TView )
               constructor Init( var R : TRect ; ATotal : Longint ) ;
               procedure   Draw ; virtual ;
               function    GetPalette : PPalette ; virtual ;
               procedure   Update( NewValue : Longint ) ;
               private
               Total       : Longint ;
               Value       : Longint ;
               NumBlock    : Integer ;
               function    CalcBlock : Integer ;
              end ;

 {
  Feel free to dissagree with my choice of colors. This palette maps into the
  TDialog palette and produces a black 'background' bar with yellow blocks.
 }
 const
  CGrowView = #6#9 ;

 implementation

 uses Drivers ;

 constructor TGrowView.Init( var R : TRect ; ATotal : Longint ) ;
  begin
   inherited Init( R ) ;
   Total        := ATotal ;  { Remember the 100% value }
   Value        := 0 ;       { Current value is 0 }
   NumBlock     := 0 ;       { No colored blocks so far }
  end ;

 { Calculate the number of colored blocks for the current 'Value' }
 function TGrowView.CalcBlock : Integer ;
  begin
   CalcBlock := Round( Size.X / Total * Value ) ;
  end ;

 procedure TGrowView.Draw ;
  var
   R      : TRect ;
   B      : TDrawBuffer ;
  begin
   MoveChar( B, '▒', GetColor( 1 ), Size.X ) ;
   MoveChar( B, #0 , GetColor( 2 ), NumBlock ) ;
   WriteLine( 0, 0, Size.X, Size.Y, B ) ;
  end ;

 function TGrowView.GetPalette: PPalette ;
  const
   P : string[ Length(CGrowView) ] = CGrowView ;
  begin
   GetPalette := @P ;
  end ;

 {
  This object was originally written in my graphical Turbo Vision variant. In
  this graphical world, drawing is very expensive (in terms of execution time)
  compared to calculating. I therefor try to avoid to redraw the progress bar
  if it is not necessary. The optimisations in the graphical variant are
  more complicated then what I left in here.
 }
 procedure TGrowView.Update( NewValue : Longint ) ;
  var
   NewBlock : integer ;
  begin
   { An update request : did my situation change ? }
   if (Value <> NewValue) then
    begin
     { Yes it did, remember the new situation }
     Value    := NewValue ;
     { Calculate the new number of colored blocks }
     NewBlock := CalcBlock ;
     { If this number didn't change we don't need to redraw }
     if (NewBlock <> NumBlock) then
      begin
       { Pitty, we do need the redraw. }
       NumBlock := NewBlock ;
       Draw ;
      end ;
    end ;
  end ;

 end.

 ---------- End of unit -----------------------------------------------------

 As I said this is a very simple object (though nice). Here is an example on
 how to get it into a dialog box (a quite stupid example too).

 procedure TMsgApplication.About ;
  var
   R       : TRect ;
   Counter : Integer ;
   GV      : PGrowView ;
   D       : PDialog ;
  begin
   R.Assign( 0, 0, 40, 5 ) ;
   D := New( PDialog, Init( R, 'Test' )) ;
   R.Assign( 2, 2, 38, 3 ) ;
   GV := New( PGrowView, Init( R, 100 )) ;
   D^.Insert( GV ) ;
   DeskTop^.Insert( D ) ;
   for Counter := 1 to 100 do
    begin
     Delay( 100 ) ;
     GV^.Update( Counter ) ;
    end ;
   Dispose( D, Done ) ;
  end ;

