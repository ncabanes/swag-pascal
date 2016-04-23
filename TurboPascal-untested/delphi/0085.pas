{
I have finally created a custom component, TWrapGrid that allows you to
use a TStringGrid, but also wrap the text in a cell.
This is the beta version, so I encourage you to experiment with it,
try it out, and send me comments on what you think of it.
When you use it, remember to se the RowHeights (or DefaultRowHeight)
large enough so that when it wraps, it shows up in the cell.

To install, copy the following text and paste it into a Unit.  Save it
under the name 'Wrapgrid.PAS'. Then follow the directions I put in the
header of the component.

Also, I am looking for a Web page where I can put this on for people to
download.

I'm also looking for feedback on this component, so please try it and tell me
what you think.

Here is the code!
-------------------------------------------
{  This is a custom component for Delphi.
   It is wraps text in a TStringGrid, thus the name TWrapGrid.
   It was created by Luis J. de la Rosa.
   E-mail: delarosa@ix.netcom.com
   Everyone is free to use it, distribute it, and enhance it.

   To use:  Go to the 'Options' - 'Install Components' menu selection in Delphi.
            Select 'Add'.
            Browse for this file, which will be named 'Wrapgrid.PAS'.
            Select 'OK'.
            You have now added this to the Samples part of your component
               palette.
            After that, you can use it just like a TStringGrid.

   Please send any questions or comments to delarosa@ix.netcom.com
   Enjoy!

   A few additional programming notes:
   I have overridden the Create and DrawCell methods.  Everything else should
   behave just like a TStringGrid.
   The Create sets the DefaultDrawing to False, so you don't need to.

   Also, I am using the pure block emulation style of programming, making my
   code easier to read.
}
   
unit Wrapgrid;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Grids;

type
  TWrapGrid = class(TStringGrid)
  private
    { Private declarations }
  protected
    { Protected declarations }
    { This DrawCell procedure wraps text in the grid cell }
    procedure DrawCell(ACol, ARow : Longint; ARect : TRect;
      AState : TGridDrawState); override;
  public
    { Public declarations }
    { The Create procedure is overriden to use the DrawCell procedure by
         default }
    constructor Create(AOwner : TComponent); override;
  published
    { Published declarations }
  end;

procedure Register;

implementation


constructor TWrapGrid.Create(AOwner : TComponent);
begin
   { Create a TStringGrid }
   inherited Create(AOwner);

   { Make the drawing use our DrawCell procedure by default }
   DefaultDrawing := FALSE;
end;



{ This DrawCell procedure wraps text in the grid cell }
procedure TWrapGrid.DrawCell(ACol, ARow : Longint; ARect : TRect;
   AState : TGridDrawState);
var
   Sentence,                  { What is left in the cell to output }
   CurWord : String;          { The word we are currently outputting }
   SpacePos,                  { The position of the first space }
   CurX,                      { The x position of the 'cursor' }
   CurY : Integer;            { The y position of the 'cursor' }
   EndOfSentence : Boolean;   { Whether or not we are done outputting the cell }
begin
   { Initialize the font to be the control's font }
   Canvas.Font := Font;

   with Canvas do begin
      { If this is a fixed cell, then use the fixed color }
      if gdFixed in AState then begin
         Pen.Color   := FixedColor;
         Brush.Color := FixedColor;
      end
      { else, use the normal color }
      else begin
         Pen.Color   := Color;
         Brush.Color := Color;
      end;

      { Prepaint cell in cell color }
      Rectangle(ARect.Left, ARect.Top, ARect.Right, ARect.Bottom);
   end;

   { Start the drawing in the upper left corner of the cell }
   CurX := ARect.Left;
   CurY := ARect.Top;

   { Here we get the contents of the cell }
   Sentence := Cells[ACol, ARow];

   { for each word in the cell }
   EndOfSentence := FALSE;
   while (not EndOfSentence) do begin
      { to get the next word, we search for a space }
      SpacePos := Pos(' ', Sentence);
      if SpacePos > 0 then begin
         { get the current word plus the space }
         CurWord := Copy(Sentence, 0, SpacePos);

         { get the rest of the sentence }
         Sentence := Copy(Sentence, SpacePos + 1, Length(Sentence) - SpacePos);
      end
      else begin
         { this is the last word in the sentence }
         EndOfSentence := TRUE;
         CurWord := Sentence;
      end;

      with Canvas do begin
         { if the text goes outside the boundary of the cell }
         if (TextWidth(CurWord) + CurX) > ARect.Right then begin
            { wrap to the next line }
            CurY := CurY + TextHeight(CurWord);
            CurX := ARect.Left;
         end;

         { write out the word }
         TextOut(CurX, CurY, CurWord);
         { increment the x position of the cursor }
         CurX := CurX + TextWidth(CurWord);
      end;
   end;
end;

procedure Register;
begin
   { You can change Samples to whichever part of the Component Palette you want
     to install this component to }
   RegisterComponents('Samples', [TWrapGrid]);
end;

end.
