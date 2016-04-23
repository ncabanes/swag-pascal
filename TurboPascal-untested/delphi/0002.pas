
Q:  How do I terminate all running tasks?

A:  Below is some code that will help if you want to terminate ALL tasks,
    no questions asked.

A word of caution, before you run this for the first time, make sure
that you save it and anything else that may have some pending data.


procedure TForm1.ButtonKillAllClick(Sender: TObject);
var
  pTask   : PTaskEntry;
  Task    : Bool;
  ThisTask: THANDLE;
begin
  GetMem (pTask, SizeOf (TTaskEntry));
  pTask^.dwSize := SizeOf (TTaskEntry);


  Task := TaskFirst (pTask);
  while Task do
  begin
    if pTask^.hInst = hInstance then
      ThisTask := pTask^.hTask
    else
      TerminateApp (pTask^.hTask, NO_UAE_BOX);
    Task := TaskNext (pTask);
  end;
  TerminateApp (ThisTask, NO_UAE_BOX);
end;

