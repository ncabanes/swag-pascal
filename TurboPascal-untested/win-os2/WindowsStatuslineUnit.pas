(*
  Category: SWAG Title: WINDOWS & OS2 STUFF
  Original name: 0018.PAS
  Description: Windows Statusline Unit
  Author: THOMAS CARLISLE
  Date: 02-05-94  12:59
*)

(**************************************************************************
 *                                                                        *
 * STATUS.PAS - A Statusline unit, by Thomas S. Carlisle                  *
 *              Free for public use, all I ask is that my name remain     *
 *              with this code.                                           *  
 *                                                                        *
 * This unit provides easy implementation of a status line. The           *
 * statusline will be at the bottom of the screen, and will take on the   *
 * colors defined in the system as button face, and button shadow.        *
 *                                                                        *
 * The statusline can have multiple partitions to display different       *
 * information. For example, you could have a partition that displays     *
 * a clock (see STATUSEX.PAS), another one that displays the current      *
 * file open in a word processing application, or virtually anything you  *
 * can think up.                                                          *
 *                                                                        *
 * The main object is TStatusLine. TStatusline is an abstract object with *
 * limited default functionality. TStatusline is a statusline with no     *
 * partitions. It knows how to draw itself, and most importantly it knows *
 * how to insert partitions. However, TStatusline does not Insert any     *
 * partitions. The user must create a descendant object of TStatusLine    *
 * that overrides the Setup method to insert some partitions.             *
 *                                                                        *
 * A typical Setup method may look something like this:                   *
 *  PROCEDURE TMyStatusline.Setup;                                        *
 *  BEGIN                                                                 *
 *       InsertItem(100,DrawProc);                                        *
 *  END;                                                                  *
 *                                                                        *
 * That would insert a partition that is 100 pixels wide. The second      *
 * parameter is important. It is a procedure. Each partition must be      *
 * passed a procedure so it knows who to call to fill in the partition    *
 * with the appropriate text. The procedure passed in the InsertItem      *
 * statement MUST be a procedure that was previously declared like this:  *
 *                                                                        *
 * PROCEDURE DrawProc(PaintHDC : HDC; VAR PaintInfo : TPaintStruct);FAR;  *
 * BEGIN                                                                  *
 *     { your custom draw code goes here... }                             *
 * END;                                                                   *
 *                                                                        *
 * Note proceduremust be declared as FAR. It also MUST have the exact     *
 * parameter list as shown. In the body, you can do what you want. A      *
 * simple example would be to simply write out a line of text:            *
 *                                                                        *
 * PROCEDURE DrawProc(PaintHDC : HDC; VAR PaintInfo : TPaintStruct);FAR;  *
 * BEGIN                                                                  *
 *     TextOut(PaintHdc,3,1,'Test',4);                                    *
 * END;                                                                   *
 *                                                                        *
 * Usually you will not have a simple procedure like that. For a better,  *
 * more functional example see the procedure Clock in STATUSEX.PAS        *
 *                                                                        *
 *************************************************************************)

UNIT Status;

INTERFACE

USES
    WObjects,WinTypes,WinProcs,WinCrt;

TYPE
    TPaintProc = PROCEDURE(PaintHdc : HDC; VAR PaintInfo : TPaintStruct);

    PPartitionCollection = ^TPartitionCollection;

    TPartitionCollection = OBJECT(TCollection)
    END;

    PPartition = ^TPartition;

    TPartition = OBJECT(TWindow)
        PRIVATE
         LeftPosition,
         RightPosition  : WORD;
         PaintProc      : TPaintProc;
         CONSTRUCTOR Init(AParent : PWindowsObject; ATitle : PCHAR;
               LPos,RPos : WORD; Proc : TPaintProc);
         PROCEDURE Paint(PaintHDC : HDC; VAR PaintInfo : TPaintStruct);
              VIRTUAL;
    END;
    
    PStatusLine = ^TStatusLine;

    TStatusLine = OBJECT(TWindow)
        CONSTRUCTOR Init(AParent : PWindowsObject; ATitle : PCHAR);
        PROCEDURE Paint(PaintHDC : HDC; VAR PaintInfo : TPaintStruct);
              VIRTUAL;
        DESTRUCTOR Done;VIRTUAL;
        PROCEDURE InsertItem(StrLength : WORD; Proc : TPaintProc);
        PROCEDURE Setup;VIRTUAL;
        FUNCTION GetPartition(Index : BYTE):PPartition;VIRTUAL;
        PRIVATE
         Partitions     : PPartitionCollection;        
    END;

IMPLEMENTATION

(************************** TPartition Methods ***************************)

{ TPartition is an object descendant of TWindow. All TPartition objects
  are child windows with TStatusLine as the parent.

  When a TPartition is inserted in the statusline, it is automaticlly
  inserted right next to the previous TPartition on the statusline.

  The Init constructor method is called whenevr a new TPartition is
  inserted in the statusline. The parameters of Init include the
  TPartition's parent window, its title (Nil), the TPartitions left position
  on the statusline, it's right position on the statusline, and most
  importantly -- the last parameter -- is a procedure parameter. This
  procedure parameter is a user defined procedure that will be used by
  the TPartition.Paint method.

  Each TPartition knows how to draw itself, with the Paint method. The Paint
  method draws an empty partition (i.e - only the frame, not filled with
  text. The paint method calls the user defined procedure, which is
  responsible for filling the partition frame with the appropriate text.

  See STATUSEX.PAS for an example of the user defined procedure           }
    

CONSTRUCTOR TPartition.Init(AParent : PWindowsObject; ATitle : PCHAR;
       LPos,RPos : WORD; Proc : TPaintProc);

VAR
   R   : TRect;
BEGIN
     TWindow.Init(AParent,ATitle);
     LeftPosition:=LPos;
     RightPosition:=RPos;
     PaintProc:=Proc;
     WITH Attr DO BEGIN
          Style:=Style OR ws_Child;
          X:=LPos;
          Y:=0;
          W:=RPos-LPos;
          H:=17;
     END;
END;

PROCEDURE TPartition.Paint(PaintHDC : HDC; VAR PaintInfo : TPaintStruct);
VAR
   R : TRect;
   TheBrush,
   OldBrush     : HBrush;
   Pen,
   OldPen       : HPen;
BEGIN
     GetClientRect(HWindow,R);
     TheBrush:=CreateSolidBrush(GetSysColor(color_BtnFace));
     FillRect(PaintHdc,R,TheBrush);
     DeleteObject(TheBrush);

     SetBkColor(PaintHdc,GetSysColor(color_BtnFace));
     PaintProc(PaintHdc,PaintInfo);

     Pen:=CreatePen(ps_Solid,1,RGB(255,255,255));
     OldPen:=SelectObject(PaintHDC,Pen);
     MoveTo(PaintHDC,R.Left,R.Top);
     LineTo(PaintHDC,R.Right,R.Top);
     MoveTo(PaintHdc,R.Left,R.Top);
     LineTo(PaintHdc,R.Left,R.Bottom);
     MoveTo(PaintHdc,R.Left+2,R.Top+15);
     LineTo(PaintHdc,R.Right-3,R.Top+15);
     LineTo(PaintHdc,R.Right-3,R.Top+2);

     DeleteObject(SelectObject(PaintHdc,OldPen));
     Pen:=CreatePen(ps_Solid,1,GetSysColor(color_btnShadow));
     OldPen:=SelectObject(PaintHDC,Pen);
     MoveTo(PaintHdc,R.Left+2,R.Top+2);
     LineTo(PaintHdc,R.Right-3,R.Top+2);
     MoveTo(PaintHdc,R.Right-1,R.Top);
     LineTo(PaintHdc,R.Right-1,R.Bottom);
     MoveTo(PaintHdc,R.Left+2,R.Top+2);
     LineTo(PaintHdc,R.Left+2,R.Top+15);

     DeleteObject(SelectObject(PaintHDC,OldPen));     
END;

(*************************** TStatusLine Methods *************************)

{ TStatusLine is an object descendant of TWindow. TStatusLine has a field
  called Partitions, which is a collection of TPartitions.

  The InsertItem method is the method responsible for inserting new
  TPartitions in the Partition collection.

  The Paint method draws the statusline, and iterates through the Partition
  collection call each ones Paint method. This results in the entire
  statusline being redrawn. }


CONSTRUCTOR TStatusLine.Init(AParent : PWindowsObject; ATitle : PCHAR);
BEGIN
     TWindow.Init(AParent,ATitle);
     WITH Attr DO BEGIN
          Style := Style OR ws_Child OR ws_Border;
     END;
     Partitions:=New(PPartitionCollection,Init(1,1));
     Setup;
END;

PROCEDURE TStatusLine.InsertItem(StrLength : WORD; Proc : TPaintProc);
BEGIN
     IF Partitions^.Count=0 THEN BEGIN
        Partitions^.Insert(New(PPartition,Init(@Self,Nil,0,StrLength,
        Proc)));
     END
     ELSE BEGIN
       Partitions^.Insert(New(PPartition,Init(@Self,NIL,PPartition(
          Partitions^.At(Partitions^.Count-1))^.RightPosition,PPartition(
          Partitions^.At(Partitions^.Count-1))^.RightPosition+StrLength,
          Proc)));
     END;
END;

FUNCTION TStatusLine.GetPartition(Index : BYTE):PPartition;
BEGIN
     GetPartition:=NIL;
     IF Partitions^.Count<>0 THEN BEGIN
        GetPartition:=Partitions^.At(Index);
     END;
END;

PROCEDURE TStatusLine.Setup;
BEGIN
END;

PROCEDURE TStatusLine.Paint(PaintHDC : HDC; VAR PaintInfo : TPaintStruct);
VAR
   R         : TRect;
   TheBrush  : HBrush;
   Pen,
   OldPen    : HPen;

   PROCEDURE CallPaint(P : PPartition);FAR;
   BEGIN
        P^.Paint(PaintHDC,PaintInfo);        
   END;

BEGIN
     GetClientRect(Parent^.HWindow,R);
     MoveWindow(HWindow,0,R.Bottom-18,R.Right-R.Left,R.Bottom,TRUE);

     GetClientRect(HWindow,R);
     IF Partitions^.Count<>0 THEN BEGIN
        R.Left:=PPartition(
              Partitions^.At(Partitions^.Count-1))^.RightPosition;
     END;
     TheBrush:=CreateSolidBrush(GetSysColor(color_BtnFace));
     FillRect(PaintHdc,R,TheBrush);
     DeleteObject(TheBrush);

     Pen:=CreatePen(ps_Solid,1,RGB(255,255,255));
     OldPen:=SelectObject(PaintHDC,Pen);
     MoveTo(PaintHDC,R.Left,R.Top);
     LineTo(PaintHDC,R.Right,R.Top);
     MoveTo(PaintHdc,R.Left,R.Top);
     LineTo(PaintHdc,R.Left,R.Bottom);
     MoveTo(PaintHdc,R.Left+2,R.Top+15);
     LineTo(PaintHdc,R.Right-3,R.Top+15);
     LineTo(PaintHdc,R.Right-3,R.Top+2);

     DeleteObject(SelectObject(PaintHdc,OldPen));
     Pen:=CreatePen(ps_Solid,1,GetSysColor(color_btnShadow));
     OldPen:=SelectObject(PaintHDC,Pen);
     MoveTo(PaintHdc,R.Left+2,R.Top+2);
     LineTo(PaintHdc,R.Right-3,R.Top+2);
     MoveTo(PaintHdc,R.Right-1,R.Top);
     LineTo(PaintHdc,R.Right-1,R.Bottom);
     MoveTo(PaintHdc,R.Left+2,R.Top+2);
     LineTo(PaintHdc,R.Left+2,R.Top+15);

     DeleteObject(SelectObject(PaintHdc,OldPen));

     Partitions^.ForEach(@CallPaint);
END;


DESTRUCTOR TStatusLine.Done;
BEGIN
     Dispose(Partitions,Done);
     TWindow.Done;
END;

END.

{------------------------   DEMO -------------------------}

 (*************************************************************************
 *                                                                        *
 * STATUSEX.PAS - example program using the STATUS unit.                  *
 *                By Thomas S. Carlisle                                   *
 *                                                                        *
 *                                                                        *
 * This program sets up an example application demonstrating the use of   *
 * the STATUS unit. A main window is created that has a statusline with   *
 * a single partition that will display the current time.                 *
 *                                                                        *
 * I picked a clock example because it demonstrates how the main window   *
 * can communicate with the statusline to tell it a certain partition     *
 * needs to be redrawn.                                                   *
 *                                                                        *
 *************************************************************************)

PROGRAM StatusEx;
USES
    WObjects,WinTypes,WinProcs,Status,WinDOS,Strings;

CONST
     wm_UpdateTime   = $0400;  { User defined message }
      
TYPE
    TimeRec = RECORD           
            Hour,
            Min     : WORD;
    END;

    PMyStatusLine = ^TMyStatusLine;

    TMyStatusLine = OBJECT(TStatusLine)    
        PROCEDURE Setup;VIRTUAL;
        PROCEDURE UpdateTime(VAR Msg : TMessage);
             VIRTUAL wm_First + wm_UpdateTime;
    END;

    PMyWindow = ^TMyWindow;

    TMyWindow = OBJECT(TWindow)
         StatusLine    : PMyStatusLine;
         CONSTRUCTOR Init(AParent : PWindowsObject; ATitle : PCHAR);
         PROCEDURE SetupWindow;VIRTUAL;
         DESTRUCTOR Done;VIRTUAL;
         PROCEDURE Timer(VAR Msg : TMessage);VIRTUAL wm_Timer;
    END;

    TMyApp = OBJECT(TApplication)
           PROCEDURE InitMainWindow;VIRTUAL;
    END;


(********************************* Globals **************************)

VAR
   OldTime      : TimeRec;    { OldTime will be used to keep track of
                                whether or not the time has changed and
                                needs to be redrawn                       }

PROCEDURE Clock(PaintHdc : HDC; VAR PaintInfo : TPaintStruct);FAR;

{ This procedure MUST be declared as FAR because it is passed as a
  parameter to the statusline, so the statusline will know what procedure
  to call when the statusline needs to be drawn. The statusline draws the
  actual box, but this procedure must fill in the text.

  Note the parameter list. It is mandatory, but also convenient. You will
  need to use the PaintHDC as the device context for your text output. The
  PaintInfo is there just in case you need it. All procedures designed to be
  passed to the statusline to be used to fill in the statusline partitions
  MUST have these two parameters!

  This procedure simply fills the box with the current time.              }

VAR
   TimeStr      : ARRAY[0..5] OF CHAR;
   Hour,
   Minute,
   Sec,
   HSec         : WORD;
   TempStr,
   Temp1        : ARRAY[0..2] OF CHAR;
BEGIN
     StrCopy(TimeStr,' ');
     GetTime(Hour,Minute,Sec,HSec);
     OldTime.Hour:=Hour;          { Fill in OldTime record for future use }
     OldTime.Min:=Minute;
     Str(Hour,TempStr);           { Build the string that holds the time }
     StrCat(TimeStr,TempStr);
     StrCopy(TempStr,':');
     StrCat(TimeStr,TempStr);
     Str(Minute,TempStr);
     IF StrLen(TempStr)=1 THEN BEGIN
         StrCopy(Temp1,'0');
         StrCat(Temp1,TempStr);
         StrCopy(TempStr,Temp1);
     END; 
     StrCat(TimeStr,TempStr);
     TextOut(PaintHdc,3,1,TimeStr,StrLen(TimeStr));   { Output the time }
END;

(************************ TMyStatusLine Methods ************************)

PROCEDURE TMyStatusLine.UpdateTime(VAR Msg : TMessage);

{ This procedure is a response method for TMyStatusLine. It responds to
  the wm_UpdateTime user defined message. The procedure first checks
  the current time against the time in OldTime. If they are different,
  then the clock status window is invalidated, to force it to be redrawn
  with the new time.

  The reason this program is setup to keep track of the OldTime, and have
  this procedure check it, is to avoid flicker that occurs if the time
  is updated when it isn't necessary.                                    }

VAR
   Hour,Min,Sec,HSec : WORD;
BEGIN
     GetTime(Hour,Min,Sec,HSec);
     IF (OldTime.Hour<>Hour) OR (OldTime.Min<>Min) THEN
          InvalidateRect(GetPartition(0)^.HWindow,NIL,TRUE);
END;

PROCEDURE TMyStatusLine.Setup;

{ Overrides the inherited Setup method. This setup method inserts one
  statusline partition in the status line. }

BEGIN
     InsertItem(75,Clock);  { This inserts a new item in the statsuline.
                              The first parameter is the length (in pixels)
                              of the desired statusline partition. The
                              second parameter is the procedure this new
                              partition will call whenever it needs to be
                              redrawn. As stated earlier, the statusline
                              takes care of drawing the statusline and it's
                              partitions, but the procedure passed here is
                              responsible for filling the partition with
                              text }

                            { If you need more than one partition,
                              simply add more InsertItem statements. Each
                              one can be passed a length and procedure
                              parameter. Very powerful.                  }

END;

(************************* TMyWindow Methods ***************************)

CONSTRUCTOR TMyWindow.Init(AParent : PWindowsObject; ATitle : PCHAR);

{ TMyWindow is a descendant of TWindow. The only difference is it has a
  StatusLine.                                                              }

BEGIN
     TWindow.Init(AParent,ATitle);
     Statusline:=New(PMyStatusLine,Init(@Self,Nil));
END;

PROCEDURE TMyWindow.SetupWindow;

{ SetupWindow is needed in this application to start the timer that will
  be used to spark messages every second to make sure the statusline clock
  is kept up to date.                                                      }

BEGIN
     TWindow.SetupWindow;
     IF SetTimer(HWindow,1,1000,NIL) = 0 THEN
        MessageBox(HWindow,'ERROR','Timer not available',mb_OK);
END;

PROCEDURE TMyWindow.Timer(VAR Msg : TMessage);

{ Responds to wm_Timer messages. First checks to make sure the incomming
  message is ours (ID=1). If it is, it sends a wm_UpdateTime message
  to the statusline. That is the message the statusline responds to by
  updating the time, if it has changed.                                   }
   
BEGIN
     IF Msg.wParam=1 THEN BEGIN
        SendMessage(StatusLine^.HWindow,wm_UpdateTime,0,0);     
     END;     
END;

DESTRUCTOR TMyWindow.Done;
{ Cleans up by killing the timer we started, and disposing the statusline }
BEGIN
     KillTimer(HWindow,1);
     Dispose(StatusLine,Done);
     TWindow.Done;
END;

(****************************** TMyApp Methods ************************)

PROCEDURE TMyApp.InitMainWindow;
{ Gets our main window (TMyWindow) in action }
BEGIN
     MainWindow:=New(PMyWindow,Init(NIL,'Test'));
END;

VAR
   MyApp   : TMyApp;
BEGIN
     MyApp.Init('Test');
     MyApp.Run;
     MyApp.Done;
END.
