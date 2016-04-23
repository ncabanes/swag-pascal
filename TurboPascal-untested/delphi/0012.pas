
{
Here's the source code for a resizable panel.  Give the panel an align
property of alClient, throw some controls on it, and watch them resize
at run time when you resize the form.  There is some code that prohibits
resizing during design time, but this can be taken out.  This may not be
perfect, because I threw it together in a few minutes, but it's worked
for me so far.
}

unit Elastic;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, ExtCtrls;

type
  TElasticPanel = class( TPanel )
  private
     FHorz, FVert: boolean;
     nOldWidth, nOldHeight: integer;
     bResized: boolean;
  protected
     procedure WMSize( var message: TWMSize ); message WM_SIZE;
  public
     nCount: integer;
     constructor Create( AOwner: TComponent ); override;
  published
     property ElasticHorizontal: boolean read FHorz write FHorz default 
TRUE;
     property ElasticVertical: boolean read FVert write FVert default 
TRUE;
  end;

procedure Register;

implementation

constructor TElasticPanel.Create( AOwner: TComponent );
begin
  inherited Create( AOwner );
  FHorz := TRUE;
  FVert := TRUE;
  nOldWidth := Width;
  nOldHeight := Height;
  bResized := FALSE;
end;

procedure TElasticPanel.WMSize( var message: TWMSize );
var
  bResize: boolean;
  xRatio: real;
  i: integer;
  ctl: TWinControl;
begin
  Inc( nCount );
  if Align = alNone then
     bResize := TRUE
  else
     bResize := bResized;
  if not ( csDesigning in ComponentState ) and bResize then
     begin
        if FHorz then
           begin
              xRatio := Width / nOldWidth;
              for i := 0 to ControlCount - 1 do
                 begin
                    ctl := TWinControl( Controls[i] );
                    ctl.Left := Round( ctl.Left * xRatio );
                    ctl.Width := Round( ctl.Width * xRatio );
                 end;
           end;
        if FVert then
           begin
              xRatio := Height / nOldHeight;
              for i := 0 to ControlCount - 1 do
                 begin
                    ctl := TWinControl( Controls[i] );
                    ctl.Top := Round( ctl.Top * xRatio );
                    ctl.Height := Round( ctl.Height * xRatio );
                 end;
           end;
     end
  else
     begin
        nOldWidth := Width;
        nOldHeight := Height;
     end;
  bResized := TRUE;
  nOldWidth := Width;
  nOldHeight := Height;
end;

procedure Register;
begin
  RegisterComponents('Additional', [TElasticPanel]);
end;

end.

