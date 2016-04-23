
{
Q:  How do I make it so that only the form I select comes to 
the top?  (i.e. without the main form)

A:   Try this in any secondary window that you DON'T want 
dragging the program along:

  ...
  private {This goes in the for's type declaration.}
    { Private declarations }
    procedure CreateParams(VAR Params: TCreateParams); override;
  ...

procedure TForm2.CreateParams(VAR Params: TCreateParams);
begin
  Inherited CreateParams(Params);
  Params.WndParent := GetDesktopWindow;
end;

       By setting the form's parent window handle to the 
desktop, you remove the link that would normally force the 
whole application to come to the top when this form comes to
the top.
