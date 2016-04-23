
Here's an easy way to do it:
create a timer and put this code in the OnTimer event:

var Trk, Min, Sec: Word;
begin
with MediaPlayer1 do
begin
Trk:= MCI_TMSF_TRACK(Position);
Min:=MCI_TMSF_MINUTE(Position);
Sec:=MCI_TMSF_SECOND(Position);
Label1.Caption:=Format('%.2d',[Trk]);
Label2.Caption:=Format('%.2d:%.2d',[Min,Sec]);
end;
end;


Add MMSystem to the uses clause in Unit1
This will show current track and time.
Hope it actually works?!?!
