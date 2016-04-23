{ Frames unit - a set of comprehensive (for my purposes) functions for
        drawing pretty 3-D frames of all types. Pretty simple stuff - I'm sure
        you will be able to figure it out - but that's why I included it.
        As always, you are welcome to do whatever with this unit. I only ask that
        if you upload it somewhere modified, keep my name off it, so I don't have
        to answer for your bad code <grin>. If you have any suggestions or
        questions, by all means send them to me - I'd love to hear from a fellow
        programmer.
                Steve Willer
                Mark Data Management
                CIS: 70400,3667
                AOL: SteveWill
}

unit frames;

interface
uses WinTypes,WinProcs,WinDOS;
procedure DrawBorderFrame(PaintDC:HDC;PaintR:TRect;Back:boolean);
procedure DrawOutFrame(PaintDC:HDC;PaintR:TRect;Back:boolean;Width:integer);
procedure DrawInFrame(PaintDC:HDC;PaintR:TRect;Back:boolean;Width:integer);
procedure DrawDivLine(PaintDC:HDC;Y:integer;Width:integer);
procedure DrawDotLine(PaintDC:HDC;PaintR:TRect;Incr:integer);
function MakeBorBrush(HWindow:HWnd;BackColor1,BackColor2:TColorRef):HBrush;
procedure DrawExplodeFrame(PaintDC:HDC;ExplR:TRect;PenColor,BrushColor:TColorRef;DrawBrush:boolean;Width:integer;
                                Steps:integer;Pause:longint);

implementation
procedure DrawBorderFrame(PaintDC:HDC;PaintR:TRect;Back:boolean);
var ThePen,OldPen:HPen;
                FillBrush,OldBrush:HBrush;
begin
        if Back then
        begin
                FillBrush := CreateSolidBrush($00C0C0C0);
                OldBrush := SelectObject(PaintDC,FillBrush);
                InflateRect(PaintR,-1,-1);
                FillRect(PaintDC,PaintR,FillBrush);
                InflateRect(PaintR,1,1);
                SelectObject(PaintDC,OldBrush);
                DeleteObject(FillBrush);
        end;

        OldBrush := SelectObject(PaintDC,GetStockObject(Null_Brush));
        ThePen := CreatePen(ps_Solid,1,$00C0C0C0);
        OldPen := SelectObject(PaintDC,ThePen);
        PaintR.top:=PaintR.top+1;
        PaintR.left:=PaintR.left-1;
        Rectangle(PaintDC,PaintR.left,PaintR.top,PaintR.right,PaintR.bottom);
        PaintR.top:=PaintR.top-1;
        PaintR.left:=PaintR.left+1;
        SelectObject(PaintDC,OldPen);
        DeleteObject(ThePen);
        SelectObject(PaintDC,OldBrush);

        ThePen := CreatePen(ps_Solid,1,RGB(255,255,255));
        OldPen := SelectObject(PaintDC,ThePen);
        MoveTo(PaintDC,PaintR.right,PaintR.top);
        LineTo(PaintDC,PaintR.left,PaintR.top);
        LineTo(PaintDC,PaintR.left,PaintR.bottom);
        MoveTo(PaintDC,PaintR.left+2,PaintR.bottom-2);
        LineTo(PaintDC,PaintR.right-2,PaintR.bottom-2);
        LineTo(PaintDC,PaintR.right-2,PaintR.top+2);
        SelectObject(PaintDC,OldPen);
        DeleteObject(ThePen);

        ThePen := CreatePen(ps_Solid,1,RGB(127,127,127));
        OldPen := SelectObject(PaintDC,ThePen);
        MoveTo(PaintDC,PaintR.right-2,PaintR.top+2);
        LineTo(PaintDC,PaintR.left+2,PaintR.top+2);
        LineTo(PaintDC,PaintR.left+2,PaintR.bottom-3);
        MoveTo(PaintDC,PaintR.left,PaintR.bottom);
        LineTo(PaintDC,PaintR.right,PaintR.bottom);
        LineTo(PaintDC,PaintR.right,PaintR.top);
        SelectObject(PaintDC,OldPen);
        DeleteObject(ThePen);
end;

procedure DrawOutFrame (PaintDC:HDC; PaintR:TRect; Back:boolean; Width:integer);
var
        ThePen, OldPen:HPen;
        FillBrush, OldBrush:HBrush;
        count:integer;
        CalcR:TRect;
begin
if Back then
        begin
        FillBrush := CreateSolidBrush ($00C0C0C0);
        OldBrush := SelectObject(PaintDC,FillBrush);
        InflateRect (PaintR, -1*(Width)+1, -1*(Width)+1);
        FillRect (PaintDC,PaintR,FillBrush);
        InflateRect (PaintR,Width-1,Width-1);
        SelectObject (PaintDC,OldBrush);
        DeleteObject (FillBrush);
        end;

CalcR := PaintR;

for count:=0 to (Width-1) do
        begin
        PaintR := CalcR;
        InflateRect (PaintR, -1*(count), -1*(count));

        ThePen := CreatePen(ps_Solid,1,RGB(255,255,255));
        OldPen := SelectObject(PaintDC,ThePen);
        MoveTo (PaintDC,PaintR.right,PaintR.top);
        LineTo (PaintDC,PaintR.left,PaintR.top);
        LineTo (PaintDC,PaintR.left,PaintR.bottom+1);
        SelectObject (PaintDC,OldPen);
        DeleteObject (ThePen);

        ThePen := CreatePen (ps_Solid,1,RGB(127,127,127));
        OldPen := SelectObject (PaintDC,ThePen);
        MoveTo (PaintDC,PaintR.right,PaintR.top+1);
        LineTo (PaintDC,PaintR.right,PaintR.bottom);
        LineTo (PaintDC,PaintR.left,PaintR.bottom);
        SelectObject (PaintDC,OldPen);
        DeleteObject (ThePen);
        end;
end;

procedure DrawInFrame(PaintDC:HDC;PaintR:TRect;Back:boolean;Width:integer);
var ThePen,OldPen:HPen;
                FillBrush,OldBrush:HBrush;
                count:integer;
                CalcR:TRect;
begin
        if Back then
        begin
                FillBrush := CreateSolidBrush($00C0C0C0);
                OldBrush := SelectObject(PaintDC,FillBrush);
                InflateRect(PaintR,-1*(Width)+1,-1*(Width)+1);
                FillRect(PaintDC,PaintR,FillBrush);
                InflateRect(PaintR,Width-1,Width-1);
                SelectObject(PaintDC,OldBrush);
                DeleteObject(FillBrush);
        end;

        CalcR:=PaintR;

        for count:=0 to (Width-1) do
        begin
                PaintR:=CalcR;
                InflateRect(PaintR,-1*(count),-1*(count));

                ThePen := CreatePen(ps_Solid,1,RGB(127,127,127));
                OldPen := SelectObject(PaintDC,ThePen);
                MoveTo(PaintDC,PaintR.right,PaintR.top);
                LineTo(PaintDC,PaintR.left,PaintR.top);
                LineTo(PaintDC,PaintR.left,PaintR.bottom);
                SelectObject(PaintDC,OldPen);
                DeleteObject(ThePen);

                ThePen := CreatePen(ps_Solid,1,RGB(255,255,255));
                OldPen := SelectObject(PaintDC,ThePen);
                MoveTo(PaintDC,PaintR.right,PaintR.top+1);
                LineTo(PaintDC,PaintR.right,PaintR.bottom);
                LineTo(PaintDC,PaintR.left-1,PaintR.bottom);
                SelectObject(PaintDC,OldPen);
                DeleteObject(ThePen);
        end;
end;

procedure DrawDivLine(PaintDC:HDC;Y:integer;Width:integer);
var ThePen,OldPen:HPen;
                FillBrush,OldBrush:HBrush;
                count:integer;
begin
                ThePen := CreatePen(ps_Solid,Width,RGB(127,127,127));
                OldPen := SelectObject(PaintDC,ThePen);
                MoveTo(PaintDC,GetSystemMetrics(sm_CXScreen),Y);
                LineTo(PaintDC,0,Y);
                SelectObject(PaintDC,OldPen);
                DeleteObject(ThePen);
                Y:=Y+Width;
                ThePen := CreatePen(ps_Solid,Width,RGB(255,255,255));
                OldPen := SelectObject(PaintDC,ThePen);
                MoveTo(PaintDC,GetSystemMetrics(sm_CXScreen),Y);
                LineTo(PaintDC,0,Y);
                SelectObject(PaintDC,OldPen);
                DeleteObject(ThePen);
end;

procedure DrawDotLine(PaintDC:HDC;PaintR:TRect;Incr:integer);
var ROP2:integer;
                count:integer;
begin
        ROP2 := GetROP2(PaintDC);
        SetROP2(PaintDC,r2_Not);
        count := PaintR.left;
        while count < PaintR.right-1 do
                begin
                        SetPixel(PaintDC,count,PaintR.top,$00000000);
                        SetPixel(PaintDC,count,PaintR.bottom-1,$00000000);
                        count := count + Incr;
                end;
        count := PaintR.top+2;
        while count < PaintR.bottom-1 do
                begin
                        SetPixel(PaintDC,PaintR.left,count,$00000000);
                        SetPixel(PaintDC,PaintR.right-1,count,$00000000);
                        count := count + Incr;
                end;
        SetROP2(PaintDC,ROP2);
end;


function MakeBorBrush(HWindow:HWnd;BackColor1,BackColor2:TColorRef):HBrush;
var DC,MemDC:HDC;
                Bits:HBitmap;
                FillR:TRect;
                TheBrush,OldBrush:HBrush;
begin
        DC:=CreateDC('display',nil,nil,nil);
        MemDC:=CreateCompatibleDC(DC);
        Bits:=CreateCompatibleBitmap(DC,8,8);
        SelectObject(MemDC,Bits);
        if Bits<>0 then
        begin
                TheBrush:=CreateSolidBrush(GetNearestColor(DC,BackColor2));
                OldBrush:=SelectObject(MemDC,TheBrush);
                PatBlt(MemDC,0,0,8,8,Blackness);
                with FillR do begin
                        left:=0;right:=8;top:=0;bottom:=8;
                end;
                FillRect(MemDC,FillR,TheBrush);
                SelectObject(MemDC,OldBrush);
                DeleteObject(TheBrush);
                SetPixel(MemDC,0,0,BackColor1);
                SetPixel(MemDC,0,2,BackColor1);
                SetPixel(MemDC,0,4,BackColor1);
                SetPixel(MemDC,0,6,BackColor1);
                SetPixel(MemDC,2,0,BackColor1);
                SetPixel(MemDC,2,2,BackColor1);
                SetPixel(MemDC,2,4,BackColor1);
                SetPixel(MemDC,2,6,BackColor1);
                SetPixel(MemDC,4,0,BackColor1);
                SetPixel(MemDC,4,2,BackColor1);
                SetPixel(MemDC,4,4,BackColor1);
                SetPixel(MemDC,4,6,BackColor1);
                SetPixel(MemDC,6,0,BackColor1);
                SetPixel(MemDC,6,2,BackColor1);
                SetPixel(MemDC,6,4,BackColor1);
                SetPixel(MemDC,6,6,BackColor1);
                MakeBorBrush:=CreatePatternBrush(Bits);
        end else MakeBorBrush:=0;
        DeleteDC(MemDC);
        DeleteDC(DC);
        DeleteObject(Bits);
end;

procedure DrawExplodeFrame(PaintDC:HDC;ExplR:TRect;PenColor,BrushColor:TColorRef;DrawBrush:boolean;Width:integer;
                        Steps:integer;Pause:longint);
var        count:integer;
                dX,dY:double;
                ThePen,OldPen:HPen;
                TheBrush,OldBrush:HBrush;
                OrigR:TRect;
                TimeCount:longint;
begin
        ThePen := CreatePen(ps_Dot,Width,PenColor);
        OldPen := SelectObject(PaintDC,ThePen);
        if DrawBrush then
                TheBrush:=CreateSolidBrush(BrushColor) else
                TheBrush := GetStockObject(Null_Brush);
        OldBrush:= SelectObject(PaintDC,TheBrush);
        dY:=(ExplR.bottom-ExplR.top)/Steps;
        dX:=(ExplR.right-ExplR.left)/Steps;
        with ExplR do
        begin
                left:=left+((right-left) div 2);
                top:=top+((bottom-top) div 2);
                right:=left;bottom:=top;
        end;
        OrigR:=ExplR;
        for count:=1 to steps do
        begin
                with ExplR do
                begin
                        TimeCount := GetTickCount;
                        left:=OrigR.left-integer(Round(dX*count));
                        right:=OrigR.right+integer(Round(dX*count));
                        bottom:=OrigR.bottom-integer(Round(dY*count));
                        top:=OrigR.top+integer(Round(dY*count));
                        Rectangle(PaintDC,left,top,right,bottom);
                        while (GetTickCount - TimeCount) < Pause do begin end;
                end;
        end;
        SelectObject(PaintDC,OldBrush);
        DeleteObject(TheBrush);
        SelectObject(PaintDC,OldPen);
        DeleteObject(ThePen);
end;

begin
end.
