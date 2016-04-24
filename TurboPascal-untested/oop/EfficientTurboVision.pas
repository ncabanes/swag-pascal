(*
  Category: SWAG Title: OOP/TURBO VISION ROUTINES
  Original name: 0026.PAS
  Description: Efficient Turbo Vision
  Author: BRIAN RICHARDSON
  Date: 11-02-93  16:45
*)

{
From: BRIAN RICHARDSON
Subj: Efficient Tv2
---------------------------------------------------------------------------
 On 10-08-93 FRANK DERKS wrote to ALL...

  Hello All,

  for those who have read my other message (Efficient TV, Thu 07). Maybe
  some of you can expand on the following idea. How do I create a
  'dynamic' pick list box: a box that is displayed only when I have

  Or maybe more simple : what I'm after is a sort of inputline-object
  which can be cycled through a number of predefined values. }

uses objects, app, dialogs, drivers;

type
   PRoomInputLine = ^TRoomInputLine;
   TRoomInputLine = object(TInputLine)
     StatusList : PStringCollection;
     Index      : integer;

     constructor Init(var Bounds: TRect; AMaxLen: integer;
                      AStatusList : PStringCollection);
     procedure HandleEvent(var Event : TEvent); virtual;
     procedure Up; virtual;
     procedure Down; virtual;
   end;

   PRoomDialog = ^TRoomDialog;
   TRoomDialog = object(TDialog)
      constructor Init(List : PStringCollection);
   end;

constructor TRoomInputLine.Init(var Bounds : TRect; AMaxLen: Integer;
                              AStatusList : PStringCollection);
begin
   inherited Init(Bounds, AMaxLen);
   StatusList := AStatusList;
   Index := 0;
   SetData(PString(StatusList^.At(Index))^);
end;

procedure TRoomInputLine.Up;
begin
   Index := (Index + 1) Mod StatusList^.Count;
   SetData(PString(StatusList^.At(Index))^);
end;


procedure TRoomInputLine.Down;
begin
   if Index = 0 then Index := (StatusList^.Count - 1) else
   Dec(Index);
   SetData(PString(StatusList^.At(Index))^);
end;

procedure TRoomInputLine.HandleEvent(var Event: TEvent);
begin
   if (Event.What = evKeyDown) then begin
      case Event.KeyCode of
         kbUp     : Up;
         kbDown   : Down;
      else
      inherited HandleEvent(Event);
      end; end else
   inherited HandleEvent(Event);
end;

constructor TRoomDialog.Init(List : PStringCollection);
var R: TRect;
begin
   R.Assign(20, 5, 60, 20);
   inherited Init(R, '');
   R.Assign(15, 7, 25, 8);
   Insert(New(PRoomInputLine, Init(R, 20, List)));
   R.Assign(15, 9, 25, 10);
   Insert(New(PRoomInputLine, Init(R, 20, List)));

end;

var
   RoomApp  : TApplication;
   List     : PStringCollection;
begin
   RoomApp.Init;
   List := New(PStringCollection, Init(3, 1));
   with List^ do begin
      Insert(NewStr('Vacant')); Insert(NewStr('Occupied'));
      Insert(NewStr('Cleaning'));
   end;
   Application^.ExecuteDialog(New(PRoomDialog, Init(List)), nil);
   Dispose(List, Done);
   RoomApp.Done;
end.


