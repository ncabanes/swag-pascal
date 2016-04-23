
Routine that allows Windows programs to continue to process while in a
processing loop.


There are two basic ways of handling loop processing in Windows
that would otherwise take away control (tie up processing of your
code and not allow other processes to run) of other running
Window's applications.  The first and probably the most flexible
approach is to write a processing loop and 'YIELD' to other
Windows application's request.  The second approach would be to
override TApplication's MessageLoop method and within the
MessageLoop call your process.


'YIELD'
If your procedure that takes a while to execute contains some
sort of outer loop, make a call to a procedure that allows other
apps to run.  Your time consuming code might look something like:

     ...
     While MoreToDo do
     begin
       YieldToOthers;
       DoSomeProcessing;
     end;

A few notes concerning this procedure:

  *  The call to HALT may need to be modified to do any cleanup
     required
     (i.e.: close open files, etc.).


  *  You'll need to be sensitive to re-entrant issues.

The procedure "YieldToOthers" would look like:

  Procedure YieldToOthers;
  var
    Msg : TMsg;
  begin
    While PeekMessage(Msg,0,0,0,PM_REMOVE) do begin
      if Msg.Message = WM_QUIT then begin
        Application^.Done;
        halt; {!!}
      end;
      TranslateMessage(Msg);
      DispatchMessage(Msg);
    end;
  end;

'MessageLoop'
This is a replacement for the TApplication MessageLoop method.

It provides for an 'idle loop' where your program can
continuously process its own work, and yet still yield control to
windows when windows needs to do something.

  TMyApp = object(TApplication)
    procedure MessageLoop; virtual;  { add this method to your }
  end;      {*  descendant of TApplication  *}

  {*  just paste this in to your program  *}
  procedure TMyApp.MessageLoop;
  var
    Message: TMsg;
  begin

    while true do begin
      if PeekMessage(Message, 0, 0, 0, pm_Remove) then begin

        if Message.Message = wm_Quit then Exit;
        TranslateMessage(Message);
        DispatchMessage(Message);
      end
      else begin

        {**  do your stuff here  **}

      end;
    end;

    Status := Message.WParam;

  end;


