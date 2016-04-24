(*
  Category: SWAG Title: OOP/TURBO VISION ROUTINES
  Original name: 0036.PAS
  Description: ScreenSaver Object
  Author: M. FIEL
  Date: 02-15-94  08:40
*)

UNIT ScrSaver;

{
  ScreenSaver Object based on the ScreenSaver by
  Stefan Boether in the TurboVision Forum of CompuServe

  (C) M.Fiel 1993 Vienna - Austria
  CompuServe ID : 100041,2007

  Initialize it with a string (wich is printed on the screen) and the time
  in seconds when it should start.

  To see how it works start the menupoint 'ScreenSave' in the
  demo.exe

  to see how to initialisze the saver watch the demo source.

  to increase or decrease the speed of the printed string use the
  '+' and '-' key (the gray ones);

  Use freely if you find it useful.

}


INTERFACE

USES  Dos, Objects, Drivers, Views, App ;

TYPE

  PScreenSaver = ^TScreenSaver;
  TScreenSaver = object( TView )

    Activ       : Boolean;
    Seconds     : Integer;

    constructor Init(FName:String;StartSeconds:Integer);
    procedure   GetEvent(var Event : TEvent); virtual;
    function    itsTimeToAct : Boolean;

    PRIVATE

    LastPos     : Integer;
    Factory     : PString;
    DelayTime   : Integer;
    IdleTime    : LongInt;

    procedure   Action; virtual;
    procedure   SetIdleTime; virtual;

  END;

IMPLEMENTATION

  USES
    Crt;

  constructor TScreenSaver.Init(FName:String;StartSeconds:Integer);
    var
      R : TRect;
    begin

      R.Assign(ScreenWidth-1,0,ScreenWidth,1);
      inherited Init(R);

      LastPos:=(ScreenWidth DIV 2);
      Factory:=NewStr(FName);
      DelayTime:=100;
      Seconds :=StartSeconds;
      SetIdleTime;

    end;

  procedure TScreenSaver.GetEvent(var Event:TEvent);
    begin

      if (Event.What=evNothing) then begin

        if not Activ then begin

          if itsTimeToAct then begin
            Activ := True;
            DoneVideo;
          end;

        end else Action;

      end else if Activ then begin

        if ((Event.What=evKeyDown) and ((Event.KeyCode=kbGrayPlus) or
                                        (Event.KeyCode=kbGrayMinus)) ) then begin
          case Event.KeyCode of
            kbGrayPlus:if DelayTime>0 then dec(DelayTime);
            kbGrayMinus:if DelayTime<4000 then inc(DelayTime);
          end;

          ClearEvent(Event);

        end else begin
          Activ := False;
          InitVideo;
          Application^.ReDraw;
          SetIdleTime;
        end;
      end else
        SetIdleTime;
    end;

  procedure TScreenSaver.SetIdleTime;
    var
      h,m,s,mm: word;
    begin
      GetTime(h,m,s,mm);
      IdleTime:=(h*3600)+(m*60)+s;
    end;

  function TScreenSaver.itsTimeToAct : Boolean;
    var
      h,m,s,mm: word;
    begin
      GetTime(h,m,s,mm);
      itsTimeToAct:=( ((h*3600)+(m*60)+s) > (IdleTime+Seconds) )
    end;

  procedure TScreenSaver.Action;
    var
      Reg:Registers;
      PrStr : String;
    begin
      Dec(LastPos);

      if LastPos>0 then begin

       if LastPos<=ScreenWidth then begin
         if LastPos=ScreenWidth then LastPos:=ScreenWidth-length(Factory^);
         Reg.DL:=LastPos;
         PrStr:=Factory^+' ';
       end else begin
         PrStr:=(Copy(Factory^,1,ScreenWidth+length(Factory^)-LastPos));
         Reg.DL:=ScreenWidth-length(PrStr);
       end;

     end else begin

       if length(Factory^)+LastPos=0 then begin
         PrStr:=' ';
         Reg.DL:=0;
         LastPos:=ScreenWidth+length(Factory^);
       end else begin
         Reg.DL := $00;
         PrStr:=Copy(Factory^,Abs(LastPos)+1,80)+' ';
       end;

     end;

     with Reg do begin
       AH := $02;
       BH := $00;
       DH := (ScreenHeight DIV 2) + (ScreenHeight DIV 4);
     end;
     Intr($10,Reg); (* Set Cursor Position *)

     PrintStr(PrStr);

     with Reg do begin
       AH:=$02;
       BH:=$00;
       DH:=(ScreenHeight+1);
       DL:=$00;
     end;
     Intr($10,Reg); (* Set Cursor Position outside -> Cursor not visible *)

     Delay(DelayTime);

   end;

END.
