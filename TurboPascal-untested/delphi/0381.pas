
Try a rewritten label component that uses a bitmap instead of the straight
canvas:

unit Freelbl;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs;

type
  TFreeLabel = class(TGraphicControl)
  private
    { Private declarations }
    procedure WMERASEBKGND(var msg:TWMERASEBKGND); message WM_ERASEBKGND;
    procedure CMFONTCHANGED(var msg:TMsg); message CM_FONTCHANGED;
    procedure CMTEXTCHANGED(var msg:TMsg); message CM_TEXTCHANGED;
  protected
    { Protected declarations }
  public
    { Public declarations }
    constructor Create(Aowner:TComponent); override;
    procedure Paint; override;
  published
    { Published declarations }
    property Caption;
    property Align;
    property Color;
    property Font;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Samples', [TFreeLabel]);
end;

constructor TFreeLabel.Create(Aowner:TComponent);
begin
 inherited Create(Aowner);
 ControlStyle := [csOpaque];
end;

procedure TFreeLabel.Paint;
var t:TBitmap;
    r:TRect;
    Text:array[0..255] of Char;
begin
 T:=TBitmap.Create;
 t.width:=width;
 t.height:=height;

 with t.canvas do
  begin
   brush.color:=self.color;
   r:=Rect(0,0,width,height);

   fillrect(r);

   font:=self.font;

   StrPCopy(Text, Caption);
   DrawText(t.canvas.Handle, Text, StrLen(Text), R, DT_CENTER or
      DT_VCENTER or DT_WORDBREAK);
  end;
 canvas.draw(0,0,t);
 t.free;
end;

procedure TFreeLabel.CMFONTCHANGED(var msg:TMsg);
begin
 invalidate;
end;

procedure TFreeLabel.CMTEXTCHANGED(var msg:TMsg);
begin
 invalidate;
end;

procedure TFreeLabel.WMERASEBKGND(var msg:TWMERASEBKGND);
begin
 { Since we blot out the background in the paint method, there is no need
   to be redundant. }
 msg.result:=1;
end;

end.
