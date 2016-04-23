{
  DELPHI 1.0

  Two new freeware components based on TSpeedButton and TBitBtn.  The most
  improvement is the ability to put an Icon replacing the only BMP picture.

  On somes ICON,  the result  is not  very good  but in the most case, the
  result is great.


  TAVCSpeedButton:

      - PopupMenu Feature
      - Icon

  TBitBtn:

      - Icon


   Sample:
   ------

   var
      btTry: TAVCSpeedButton;

   ...

      btTry.LoadIcon (LoadIcon(hInstance, 'MAINICON'));


               ╔════════════════════════════════════════╗
               ║                                        ║░
               ║          AVONTURE CHRISTOPHE           ║░
               ║              AVC SOFTWARE              ║░
               ║     BOULEVARD EDMOND MACHTENS 157/53   ║░
               ║           B-1080 BRUXELLES             ║░
               ║              BELGIQUE                  ║░
               ║                                        ║░
               ╚════════════════════════════════════════╝░
               ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░


}
unit Icobtn;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Buttons, Extctrls, Menus;

type

  TAVCSpeedButton = class(TSpeedButton)
  private
    procedure WM_RBUTTONDOWN (var Message: TMessage); message WM_RBUTTONDOWN;
  public
    constructor Create(Owner: TComponent); override;
    destructor  Destroy; override;
    procedure   LoadIcon(Ico: hIcon);
  published
    PopupMenu : TPopupMenu;
  end;

  TAVCBitBtn = class(TBitBtn)
  protected
  public
    constructor Create(Owner: TComponent); override;
    destructor  Destroy; override;
    procedure   LoadIcon(Ico: hIcon);
  published
  end;

procedure Register;

implementation

Uses ShellAPI;

constructor TAVCBitBtn.Create;
begin
  inherited Create(Owner);
  Parent := (Owner as TWinControl);
end;

destructor TAVCBitBtn.Destroy;
begin
  inherited Destroy;
end;

procedure TAVCBitBtn.LoadIcon;
var
   pic : TPicture;
   iico : TIcon;
begin

   iico        := TIcon.Create;
   iico.Handle := ico;
   Pic         := TPicture.Create;
   Pic.Icon    := iico;
   Glyph       := TBitmap.Create;
   Height      := iico.Height+8;

   WITH Glyph DO
      BEGIN
         Width  := iico.Width+30;
         Height := iico.Height;
         Canvas.Draw (0, 0, Pic.Icon);
      END;

   iico.free;

end;

{ ******************************************************** }

constructor TAVCSpeedButton.Create;
begin
  inherited Create(Owner);
  Parent := (Owner as TWinControl);
end;

destructor TAVCSpeedButton.Destroy;
begin
  inherited Destroy;
end;

procedure TAVCSpeedButton.LoadIcon;
var
   pic : TPicture;
   iico : TIcon;
begin

   iico        := TIcon.Create;
   iico.Handle := ico;
   Pic         := TPicture.Create;
   Pic.Icon    := iico;
   Glyph       := TBitmap.Create;
   Height      := iico.Height+4;
   Width       := iico.width+4;

   WITH Glyph DO
      BEGIN
         Width  := iico.Width;
         Height := iico.Height;
         Canvas.Draw (0, 0, Pic.Icon);
      END;

   iico.free;

end;

procedure TAVCSpeedButton.WM_RBUTTONDOWN;
var
   Where: TPoint;
begin

   IF NOT (PopupMenu = NIL) THEN
      BEGIN
         GetCursorPos (Where);
         WITH PopupMenu DO
            BEGIN
               PopupComponent := TComponent(Self);
               Popup (Where.X, Where.Y);
            END;
      END;

end;

procedure Register;
begin
   RegisterComponents ('Samples', [TAVCBitBtn]);
   RegisterComponents ('Samples', [TAVCSpeedButton]);
end;

end.
