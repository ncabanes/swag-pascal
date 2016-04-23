
{Automatic sizing with taskbar in Win95 and NT-Shell update  }
{Modified by Tim Baker timbaker@mail.infinet.com to use the  }
{TWMGETMINMAXINFO Windows message                            }
{Original procedure for sizing for Win95/NtShell TaskBar from}
{Peter M. Jagielski 73737,1761@compuserve.com.               }

{This is freeware and freely distributable, just include the }
{above five lines just before the procedure in your progam.  }

{After adding this to your program, run it, maximize your     }
{window, and move the task bar around the screen.  Your       }
{program will automatically change its position and size.     }

{Just after your normal procedure definitions in your class(tform) type      }
{and before your private variable declarataions, Add the following two lines }
{Without the comment brackets of course                                      }
{  private                                                                   }
{    procedure mymax(var msg: TWMGETMINMAXINFO);  message wm_getminmaxinfo;  }

procedure Tform1.mymax(var msg : TWMGETMINMAXINFO);
Const
   MyMinimumWidth = 600;
   MyMinimumHeight = 440;
var
  Width1,Height1,Top1,Left1:Integer;
  TaskBarHandle: HWnd;    { Handle to the Win95 Taskbar }
  TaskBarCoord:  TRect;   { Coordinates of the Win95 Taskbar }
  CxScreen,               { Width of screen in pixels }
  CyScreen,               { Height of screen in pixels }
  CxFullScreen,           { Width of client area in pixels }
  CyFullScreen,           { Heigth of client area in pixels }
  CyCaption:     Integer; { Height of a window's title bar in pixels }
begin
   {Remove the next two lines if you do not require a minimum width or height}
   msg.minmaxinfo^.ptMinTrackSize.x := MyMinimumWidth;
   msg.minmaxinfo^.ptMinTrackSize.y := MyMinimumHeight;

   if FindWindow('Shell_TrayWnd',Nil)=0 then
      begin
         {Neither Windows 95 nor the NT Shell Update are running}
         msg.minmaxinfo^.ptMaxTrackSize.x := GetSystemMetrics(SM_CXSCREEN);
         msg.minmaxinfo^.ptMaxTrackSize.y := GetSystemMetrics(SM_CYSCREEN);
      end
   else
      begin
         { Get coordinates of Win95 Taskbar }
         GetWindowRect(TaskBarHandle,TaskBarCoord);
         { Get various screen dimensions and set form's width/height }
         CxScreen      := GetSystemMetrics(SM_CXSCREEN);
         CyScreen      := GetSystemMetrics(SM_CYSCREEN);
         CxFullScreen  := GetSystemMetrics(SM_CXFULLSCREEN);
         CyFullScreen  := GetSystemMetrics(SM_CYFULLSCREEN);
         CyCaption     := GetSystemMetrics(SM_CYCAPTION);
         Width1  := CxScreen - (CxScreen - CxFullScreen) + 1;
         Height1 := CyScreen - (CyScreen - CyFullScreen) + CyCaption + 1;
         Top1    := 0;
         Left1   := 0;
         if (TaskBarCoord.Top = -2) and (TaskBarCoord.Left = -2) then
            { Taskbar on either top or left }
            if TaskBarCoord.Right > TaskBarCoord.Bottom then
               { Taskbar on top }
               Top1  := TaskBarCoord.Bottom
            else
               { Taskbar on left }
               Left1 := TaskBarCoord.Right;
         {Set the minimum positions and sizes}
         msg.MinMaxInfo^.ptMaxPosition.x  := left1;
         msg.MinMaxInfo^.ptMaxPosition.y  := top1;
         msg.minmaxinfo^.ptMaxTrackSize.x := Width1;
         msg.minmaxinfo^.ptMaxTrackSize.y := Height1;
      end;
end;
