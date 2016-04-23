{
Here is an example that prints columns that are right, left, and center
justified.  There are headers, footers, and, generally, a bunch o' things
here.  This app encapsulates functionality to print text, lines, boxes
and shaded boxes. Text can be left or right justified and centered.
Columns can be  created and text can be left or right justified within the
columns or  text can be centered.  Lines of any thickness can be drawn.
Boxes can be drawn with any thickness.  The boxes can be shaded if desired.
Headers and footers can be created and the header/footer areas can be shaded
if desired.  Page numbering can contain custom text and can be placed
anywhere desired.
}


{******* prnMain.pas *******}

unit Prnmain;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, ExtCtrls, Printers;

const
  HeaderLines = 5;                        { Number of allowable header lines }
  FooterLines = 5;                        { Number of allowable footer lines }
  Columns = 20;                           { Number of allowable columns }
        
type
  THeaderRecord = Record
     Text: String[240];                   { Header text }
     YPosition: Single;                   { Inches from the top }
     Alignment: Integer;                  { 0:Left 1:Center 2:Right }

     FontName: String[80];                { Font name }
     FontSize: Integer;                   { Font size }
     FontStyle: TFontStyles;              { Font style }
     End;

  TFooterRecord = Record
     Text: String[240];                   { Footer text }
     YPosition: Single;                   { Inches from the top }
     Alignment: Integer;                  { 0:Left 1:Center 2:Right }
     FontName: String[80];                { Font name }
     FontSize: Integer;                   { Font size }
     FontStyle: TFontStyles;              { Font style }

     End;

  THeaderCoordinates = Record
     XTop: Single;
     YTop: Single;
     XBottom: Single;
     YBottom: Single;
     Boxed: Boolean;
     Shading: Word;
     LineWidth: Word;
     End;   

  TFooterCoordinates = Record
     XTop: Single;
     YTop: Single;
     XBottom: Single;
     YBottom: Single;
     Boxed: Boolean;
     Shading: Word;
     LineWidth: Word;
     End;   

  TPageNumberRecord = Record
     YPosition: Single;
     Text: String[240];
     Alignment: Word; 
     FontName: String[80];
     FontSize: Word;
     FontStyle: TFontStyles;

     End;

  TColumnInformationRecord = Record
     XPosition: Single;
     Length: Single;
     End;

  TPrintObject = class
     private
        TopMargin: Integer;               { Top margin in pixels }
        BottomMargin: Integer;            { Bottom margin in pixels }
        LeftMargin: Integer;              { Left margin in pixels }
        RightMargin: Integer;             { Right margin in pixels }
        PixelsPerInchVertical: Integer;   { Number of pixels per inch along Y axis }
        PixelsPerInchHorizontal: Integer; { Number of pixels per inch along X axis }
        TotalPageWidthPixels: Integer;    { Full width of page in pixels - includes gutters }

        TotalPageHeightPixels: Integer;   { Full height of page in pixels - includes gutters }
        TotalPageHeightInches: Single;    { Height of page in inches }
        TotalPageWidthInches: Single;     { Width of page in inches }
        GutterLeft: Integer;              { Unprintable area on left }
        GutterRight: Integer;             { Unprintable area on right }
        GutterTop: Integer;               { Unprintable area on top }
        GutterBottom: Integer;            { Unprintable area on bottom }
        DetailTop: Single;                { Inches from the top where the detail section starts }
        DetailBottom: Single;             { Inches from the top where the detail section ends }

        LastYPosition: Single;            { The Y position where the last write occurred }
        AutoPaging: Boolean;              { Are new pages automatically generated? }
        CurrentTab: Single;               { The value of the current tab }
        CurrentFontName: String[30];
        CurrentFontSize: Integer;
        CurrentFontStyle: TFontStyles;
        TextMetrics: TTextMetric;
        Header: Array[1..HeaderLines] of THeaderRecord;
        Footer: Array[1..FooterLines] of TFooterRecord;
        ColumnInformation: Array[1..Columns] of TColumnInformationRecord;
        PageNumber: TPageNumberRecord;

        HeaderCoordinates: THeaderCoordinates;
        FooterCoordinates: TFooterCoordinates;
        function CalculateLineHeight: Integer;
        function InchesToPixelsHorizontal( Inches: Single ): Integer;
        function InchesToPixelsVertical( Inches: Single ): Integer;
        function PixelsToInchesHorizontal( Pixels: Integer ): Single;
        function PixelsToInchesVertical( Pixels: Integer ): Single;
        function LinesToPixels( Line:Integer ): Integer;
        procedure CalculateMeasurements;
        procedure _DrawBox( XTop:Word; YTop:Word; XBottom:Word; YBottom:Word; LineWidth:Word; Shading:Word );
     public
        procedure Start;

        procedure Quit;
        procedure Abort;
        procedure SetMargins( Top:Single; Bottom:Single; Left:Single; Right:Single );
        procedure SetFontInformation( Name:String; Size:Word; Style: TFontStyles );
        procedure WriteLine( X:Single; Y:Single; Text:String );
        procedure WriteLineRight( Y:Single; Text:String );
        procedure WriteLineCenter( Y:Single; Text:String );
        procedure WriteLineColumnRight( ColumnNumber:Word; Y:Single; Text:String );
        procedure WriteLineColumnCenter( ColumnNumber:Word; Y:Single; Text:String );
        procedure DrawLine( TopX:Single; TopY:Single; BottomX:Single; BottomY:Single; LineWidth:Word );
        procedure SetLineWidth( Width:Word );

        function  GetLineWidth: Word;
        procedure SetTab( Inches:Single );
        procedure NewPage;
        function  GetLinesPerPage: Integer;
        procedure GetPixelsPerInch( var X:Word; var Y:Word );
        procedure GetPixelsPerPage( var X:Word; var Y:Word );
        procedure GetGutter( var Top:Word; var Bottom:Word; var Left:Word; var Right:Word );
        function  GetTextWidth( Text:String ): Integer;
        function  GetLineHeightPixels: Word;
        function  GetLineHeightInches: Single;
        function  GetPageNumber:Integer;
        function  GetColumnsPerLine: Integer;
        procedure SetOrientation( Orient: TPrinterOrientation );

        procedure SetHeaderInformation( Line:Integer; YPosition: Single; Text:String; Alignment:Word; 
                     FontName:String; FontSize: Word; FontStyle: TFontStyles );
        procedure SetFooterInformation( Line:Integer; YPosition: Single; Text:String; Alignment:Word; 
                     FontName:String; FontSize: Word; FontStyle: TFontStyles );
        procedure WriteHeader;
        procedure WriteFooter;
        procedure SaveCurrentFont;
        procedure RestoreCurrentFont;
        procedure SetDetailTopBottom( Top: Single; Bottom: Single );
        procedure SetAutoPaging( Value: Boolean );
        procedure SetPageNumberInformation( YPosition:Single; Text:String; Alignment:Word; FontName:String; 
                     FontSize:Word; FontStyle:TFontStyles );

        procedure WritePageNumber;
        procedure WriteLineColumn( ColumnNumber:Word; Y:Single; Text:String );
        procedure DrawBox( XTop:Single; YTop:Single; XBottom:Single; YBottom:Single; LineWidth:Word );
        procedure DrawBoxShaded( XTop:Single; YTop:Single; XBottom:Single; YBottom:Single; LineWidth:Word; Shading:Word );
        procedure SetHeaderDimensions( XTop:Single; YTop:Single; XBottom:Single; YBottom:Single;
                  Boxed: Boolean; LineWidth:Word; Shading:Word );
        procedure SetFooterDimensions( XTop:Single; YTop:Single; XBottom:Single; YBottom:Single;
                  Boxed: Boolean; LineWidth:Word; Shading:Word );
        procedure CreateColumn( Number:Word; XPosition:Single; Length:Single );
        procedure SetYPosition( YPosition:Single );
        function  GetYPosition: Single;
        procedure NextLine;
        function  GetLinesLeft: Word;
        function  GetLinesInDetailArea: Word;

        procedure SetTopOfPage;
        procedure NewLines( Number:Word );
        function GetFontName: String;
        function GetFontSize: Word;
   End;

implementation

procedure TPrintObject.Start;

   { This function MUST be called first before any other printing function }

   var
      Top,Bottom,Left,Right: Single;
      I: Integer;

   Begin
   Printer.BeginDoc;

   AutoPaging := True;

   CalculateMeasurements;

   PageNumber.Text := '';

   Top := PixelsToInchesVertical( GutterTop );
   Bottom := PixelsToInchesVertical( GutterBottom );
   Left := PixelsToInchesHorizontal( GutterLeft );
   Right := PixelsToInchesHorizontal( GutterRight );
   SetMargins( Top,Bottom,Left,Right );

   For I := 1 To HeaderLines Do

      Header[I].Text := '';
   HeaderCoordinates.Boxed := False;
   HeaderCoordinates.Shading := 0;
   For I := 1 To FooterLines Do
      Footer[I].Text := '';
   FooterCoordinates.Boxed := False;
   FooterCoordinates.Shading := 0;

   CurrentTab := 0.0;

   LastYPosition := 0.0;
   End;              

procedure TPrintObject.Quit;

   { 'Quit' must always be called when printing is completed }

   Begin
   WriteHeader;
   WriteFooter;
   WritePageNumber;

   Printer.EndDoc
   End;

procedure TPrintObject.SetMargins( Top:Single; Bottom:Single; Left:Single; Right:Single );

   { Set the top, bottom, left and right margins in inches }


   var
      Value: Single;
      Buffer: String;

   Begin
   { If the sum of the left and right margins exceeds the width of the page,
     set the left margin to the value of 'GutterLeft' and set the right
     margin to the value of 'GutterRight' }
   If ( Left + Right >= TotalPageWidthInches ) Then
      Begin
      Left := GutterLeft;
      Right := GutterRight;
      End;
   If ( Left <= 0 ) Then
      Left := GutterLeft;
   If ( Right <= 0 ) Then
      Right := GutterRight;

   { If the sum of the top and bottom margins exceeds the height of the 
     page, set the top margin to the value of 'GutterTop' and set the 
     bottom margin to the value of 'GutterBottom' }

   If ( Top + Bottom >= TotalPageHeightInches ) Then
      Begin
      Top := GutterTop;
      Bottom := GutterBottom;
      End;
   If ( Top <= 0 ) Then
      Top := GutterTop;
   If ( Bottom <= 0 ) Then
      Bottom := GutterBottom;

   { Convert everything to pixels }
   TopMargin := InchesToPixelsVertical( Top );
   If ( TopMargin < GutterTop ) Then
      TopMargin := GutterTop;

   BottomMargin := InchesToPixelsVertical( Bottom );
   If ( BottomMargin < GutterBottom ) Then
      BottomMargin := GutterBottom;

   LeftMargin := InchesToPixelsHorizontal( Left );
   If ( LeftMargin < GutterLeft ) Then
      LeftMargin := GutterLeft;

   RightMargin := InchesToPixelsHorizontal( Right );

   If ( RightMargin < GutterRight ) Then
      RightMargin := GutterRight;
   End;

procedure TPrintObject.WriteLine( X:Single; Y:Single; Text:String );

   { Write some text.  The parameters represent inches from the left ('X')
     and top ('Y') margins. }

   var
      XPixels: Integer;
      YPixels: Integer;

   Begin
   { How many pixels are there in the inches represented by 'X'? }
   If ( X >= 0.0 ) Then
      XPixels := InchesToPixelsHorizontal( X )
   Else
      XPixels := LeftMargin;
   If ( XPixels < GutterLeft ) Then
      XPixels := GutterLeft;

   { If there is a tab set, increase 'XPixels' by the amount of the tab }
   If ( CurrentTab > 0.0 ) Then

      Inc( XPixels,InchesToPixelsHorizontal(CurrentTab) );

   { How many pixels are there in the inches represented by 'Y'? }
   If ( Y > -0.01 ) Then
      { Printing will occur at an absolute location from the top of the 
        page. }
      Begin
      YPixels := InchesToPixelsVertical( Y );
      If ( YPixels < GutterTop ) Then
         YPixels := GutterTop;
      If ( YPixels > TotalPageHeightPixels ) Then
         YPixels := TotalPageHeightPixels - GutterBottom;

      LastYPosition := Y;
      End;
   If ( Y = -1.0 ) Then
      { Write the text at the next line }
      Begin
      If ( AutoPaging = True ) Then
         Begin
         { If the next line we're going to write to exceeds beyond the 

           bottom of the detail section, issue a new page }
         If ( LastYPosition + GetLineHeightInches > DetailBottom ) Then
            NewPage;
         End;
      YPixels := InchesToPixelsVertical( LastYPosition + GetLineHeightInches );
      LastYPosition := LastYPosition + GetLineHeightInches;
      End;
   If ( Y = -2.0 ) Then
      { Write the text on the current line }
      YPixels := InchesToPixelsVertical( LastYPosition );      

   Printer.Canvas.TextOut( XPixels-GutterLeft,YPixels-GutterTop,Text );
   End;

procedure TPrintObject.WriteLineColumn( ColumnNumber:Word; Y:Single; Text:String );

   { Write text, left aligned against the column represented by
     'ColumnInformation[ColumnNumber]' }

   Begin
   WriteLine( ColumnInformation[ColumnNumber].XPosition,Y,Text );

   End;

procedure TPrintObject.WriteLineColumnRight( ColumnNumber:Word; Y:Single; Text:String );

   { Write text, right aligned against the column represented by
     'ColumnInformation[ColumnNumber]' }

   var
      PixelLength: Word;
      StartPixel: Word;

   Begin
   { How many pixels does the text in 'Text' require? }
   PixelLength := Printer.Canvas.TextWidth( Text );

   { Calculate where printing should start }
   StartPixel := InchesToPixelsHorizontal( ColumnInformation[ColumnNumber].XPosition + 
      ColumnInformation[ColumnNumber].Length ) - PixelLength;

   SetTab( 0.0 );
   WriteLine( PixelsToInchesHorizontal(StartPixel),Y,Text );
   SetTab( CurrentTab );
   End;

procedure TPrintObject.WriteLineRight( Y:Single; Text:String );

   { Print a line of text right justified 'Y' inches from the top }

   var
      PixelLength: Word;
      StartPixel: Word;


   Begin
   { How many pixels does the text in 'Text' require? }
   PixelLength := Printer.Canvas.TextWidth( Text );

   { Calculate where printing should start }
   StartPixel := (TotalPageWidthPixels-GutterLeft-GutterRight) - PixelLength;

   SetTab( 0.0 );       
   WriteLine( PixelsToInchesHorizontal(StartPixel),Y,Text );
   SetTab( CurrentTab );       
   End;

procedure TPrintObject.WriteLineCenter( Y:Single; Text:String );

   { Print a line of text centered at Y inches from the top }

   var
      PixelLength: Integer;
      StartPixel: Integer;

   Begin
   { How many pixels does the text in 'Text' require? }
   PixelLength := Printer.Canvas.TextWidth( Text );

   { Calculate where printing should start }
   StartPixel := ((GutterLeft+(TotalPageWidthPixels-GutterRight)) Div 2) - (PixelLength Div 2);   

   SetTab( 0.0 );
   WriteLine( PixelsToInchesHorizontal(StartPixel),Y,Text );

   SetTab( CurrentTab );
   End;

procedure TPrintObject.WriteLineColumnCenter( ColumnNumber:Word; Y:Single; Text:String );

   { Print a line of text centered within the column number represented by
     'ColumnNumber', at Y inches from the top }

   var
      PixelLength: Integer;
      StartPixel: Integer;
      Pixels: Integer;

   Begin
   { How many pixels does the text in 'Text' require? }
   PixelLength := Printer.Canvas.TextWidth( Text );

   { Calculate where printing should start }
   Pixels := InchesToPixelsHorizontal( ColumnInformation[ColumnNumber].Length );
   StartPixel := (InchesToPixelsHorizontal( ColumnInformation[ColumnNumber].Length ) Div 2) +
      InchesToPixelsHorizontal(ColumnInformation[ColumnNumber].XPosition) - (PixelLength Div 2);

   SetTab( 0.0 );
   WriteLine( PixelsToInchesHorizontal(StartPixel),Y,Text );
   SetTab( CurrentTab );
   End;


procedure TPrintObject.DrawLine( TopX:Single; TopY:Single; BottomX:Single; BottomY:Single; LineWidth:Word );

   { Draw a line beginning at a particular X,Y coordinate and ending at a
     particular X,Y coordinate. }

   var
      TopXPixels, BottomXPixels, TopYPixels, BottomYPixels: Integer;

   Begin
   TopXPixels := InchesToPixelsHorizontal( TopX );
   BottomXPixels := InchesToPixelsHorizontal( BottomX );
   TopYPixels := InchesToPixelsVertical( TopY );
   BottomYPixels := InchesToPixelsVertical( BottomY );

   Dec( TopXPixels,GutterLeft );
   Dec( BottomXPixels,GutterLeft );
   Dec( TopYPixels,GutterTop );
   Dec( BottomYPixels,GutterTop );


   Printer.Canvas.Pen.Width := LineWidth;

   Printer.Canvas.MoveTo( TopXPixels,TopYPixels );
   Printer.Canvas.LineTo( BottomXPixels,BottomYPixels );
   End;

procedure TPrintObject.SetFontInformation( Name:String; Size:Word; Style: TFontStyles );

   { Change the current font information }

   Begin
   Printer.Canvas.Font.Name := Name;
   Printer.Canvas.Font.Size := Size;
   Printer.Canvas.Font.Style := Style;

   CalculateMeasurements;
   End;

function TPrintObject.GetFontName: String;

   { Return the current font name }

   Begin
   Result := Printer.Canvas.Font.Name;
   End;

function TPrintObject.GetFontSize: Word;

   { Return the current font size }

   Begin
   Result := Printer.Canvas.Font.Size;
   End;


procedure TPrintObject.SetOrientation( Orient: TPrinterOrientation );

   Begin
   Printer.Orientation := Orient;
                                       
   CalculateMeasurements;
   End;

function TPrintObject.CalculateLineHeight: Integer;

   { Calculate the height of a line plus the normal amount of space between
     each line }

   Begin
   Result := TextMetrics.tmHeight + TextMetrics.tmExternalLeading;
   End;

procedure TPrintObject.NewPage;

   { Issue a new page }

   Begin
   WriteHeader;
   WriteFooter;
   WritePageNumber;
   LastYPosition := DetailTop - GetLineHeightInches;

   Printer.NewPage;

   End;

function TPrintObject.GetPageNumber;

   { Return the current page number }

   Begin
   Result := Printer.PageNumber;
   End;

function TPrintObject.GetTextWidth( Text:String ): Integer;

   { Return the width of the text contained in 'Text' in pixels }

   Begin
   Result := Printer.Canvas.TextWidth( Text );
   End;

function TPrintObject.GetLineHeightPixels: Word;

   Begin
   Result := CalculateLineHeight;
   End;

function TPrintObject.GetLineHeightInches: Single;

   Begin
   Result := PixelsToInchesVertical( GetLineHeightPixels );
   End;

procedure TPrintObject._DrawBox( XTop:Word; YTop:Word; XBottom:Word; YBottom:Word; LineWidth:Word; Shading:Word );

   { The low level routine which actually draws the box and shades it as

     desired. The paramaters are in pixels and not inches. }

   Begin
   Printer.Canvas.Pen.Width := LineWidth;
   Printer.Canvas.Brush.Color := RGB( Shading,Shading,Shading );

   Printer.Canvas.Rectangle( XTop,YTop,XBottom,YBottom );
   End;

procedure TPrintObject.DrawBox( XTop:Single; YTop:Single; XBottom:Single; YBottom:Single; LineWidth:Word );

   { Draw a box at the X,Y coordinates passed in the parameters }

   var
      BLinePixels,BColPixels,ELinePixels,EColPixels: Integer;

   Begin
   BLinePixels := InchesToPixelsVertical( YTop ) - GutterTop;
   ELinePixels := InchesToPixelsVertical( YBottom ) - GutterTop;

   BColPixels := InchesToPixelsHorizontal( XTop ) - GutterLeft;
   EColPixels := InchesToPixelsHorizontal( XBottom ) - GutterLeft;

   _DrawBox( BColPixels,BLinePixels,EColPixels,ELinePixels,LineWidth,255 );
   End;

procedure TPrintObject.DrawBoxShaded( XTop:Single; YTop:Single; XBottom:Single; YBottom:Single; LineWidth:Word; Shading:Word );

   { Draw a box at the X,Y coordinates passed in the parameters }


   var
      BLinePixels,BColPixels,ELinePixels,EColPixels: Integer;

   Begin
   BLinePixels := InchesToPixelsVertical( YTop ) - GutterTop;
   ELinePixels := InchesToPixelsVertical( YBottom ) - GutterTop;

   BColPixels := InchesToPixelsHorizontal( XTop ) - GutterLeft;
   EColPixels := InchesToPixelsHorizontal( XBottom ) - GutterLeft;

   _DrawBox( BColPixels,BLinePixels,EColPixels,ELinePixels,LineWidth,Shading );
   End;

function TPrintObject.GetLinesPerPage: Integer;

   { Return the number of lines on the entire page }

   Begin
   Result := (TotalPageHeightPixels - GutterTop - GutterBottom) Div CalculateLineHeight;
   End;

function TPrintObject.GetLinesInDetailArea: Word;

   { Return the number of lines in the detail area }

   Begin
   Result := InchesToPixelsVertical( DetailBottom - DetailTop ) Div CalculateLineHeight;
   End;


procedure TPrintObject.GetPixelsPerInch( var X:Word; var Y:Word );

   Begin
   X := PixelsPerInchHorizontal;
   Y := PixelsPerInchVertical;
   End;

procedure TPrintObject.GetPixelsPerPage( var X:Word; var Y:Word );

   Begin
   X := TotalPageWidthPixels - GutterLeft - GutterRight;
   Y := TotalPageHeightPixels - GutterTop - GutterBottom;
   End;

procedure TPrintObject.GetGutter( var Top:Word; var Bottom:Word; var Left:Word; var Right:Word );

   Begin
   Top := GutterTop;
   Bottom := GutterBottom;
   Left := GutterLeft;
   Right := GutterRight;
   End;

procedure TPrintObject.Abort;

   Begin
   Printer.Abort;
   End;

function TPrintObject.GetColumnsPerLine: Integer;

   { How many columns are there in a Line? }


   var
      Pixels: Integer;

   Begin
   Pixels := TotalPageWidthPixels - GutterLeft - GutterRight;

   Result := Pixels Div Printer.Canvas.TextWidth( 'B' );      
   End;  

function TPrintObject.InchesToPixelsHorizontal( Inches: Single ): Integer;

   { Convert the horizontal inches represented in 'Inches' to pixels }

   var
      Value: Single;
      Buffer: String;
      I: Integer;
                  
   Begin
   Value := Inches * PixelsPerInchHorizontal;
   Buffer := FloatToStr( Value );

   { If there is a decimal point in 'Buffer', remove it. }
   I := 1;
   While( (Buffer[I] <> '.') And (I <= Length(Buffer)) ) Do
      Inc( I );
   Buffer[0] := Chr( I-1 );


   Result := StrToInt( Buffer );
   End;

function TPrintObject.InchesToPixelsVertical( Inches: Single ): Integer;

   { Convert the vertical inches represented in 'Inches' to pixels }

   var
      Value: Single;
      Buffer: String;
      I: Integer;

   Begin
   Value := Inches * PixelsPerInchVertical;
   Buffer := FloatToStr( Value );

      { If there is a decimal point in 'Buffer', remove it. }
   I := 1;
   While( (Buffer[I] <> '.') And (I <= Length(Buffer)) ) Do
      Inc( I );
   Buffer[0] := Chr( I-1 );

   Result := StrToInt( Buffer );
   End;

function TPrintObject.PixelsToInchesHorizontal( Pixels: Integer ): Single;


   Begin
   Result := Pixels / PixelsPerInchHorizontal;
   End;

function TPrintObject.PixelsToInchesVertical( Pixels: Integer ): Single;

   Begin
   Result := Pixels / PixelsPerInchVertical;
   End;

function TPrintObject.LinesToPixels( Line:Integer ): Integer;

   { Calculate the number of vertical pixels in 'Line' }

   Begin
   If ( Line <= 0 ) Then
      Line := 1;

   Result := (Line-1) * CalculateLineHeight;
   End;

procedure TPrintObject.SetLineWidth( Width:Word );

   Begin
   Printer.Canvas.Pen.Width := Width;
   End;

function TPrintObject.GetLineWidth: Word;

   Begin
   Result := Printer.Canvas.Pen.Width;
   End;

procedure TPrintObject.CalculateMeasurements;


   { Calculate some necessary measurements.  Thanks to Robert Fabiszak
     CompuServe: 70304,2047 for the Escape() Windows API calls. }

   var
      pt: TPoint;

   Begin
   { Call the Windows API function GetTextMetrics() to get the specifics
     of the particular font. }
   GetTextMetrics( Printer.Canvas.Handle,TextMetrics );

   { Calculate the number of pixels per inch vertical and horizontal.
     'GetDeviceCaps' is a Windows API call. }
   PixelsPerInchVertical := GetDeviceCaps( Printer.Handle,LOGPIXELSY );
   PixelsPerInchHorizontal := GetDeviceCaps( Printer.Handle,LOGPIXELSX );

   { Get the gutter on the left and top.  'Escape' is a Windows API 

     call. }
   Escape( Printer.Canvas.Handle,GETPRINTINGOFFSET,0,Nil,@pt );
   GutterLeft := pt.X;
   GutterTop := pt.Y;

   Escape( Printer.Canvas.Handle,GETPHYSPAGESIZE,0,Nil,@pt );
   TotalPageWidthPixels := pt.X;
   TotalPageHeightPixels := pt.Y;
   TotalPageWidthInches := pt.X / PixelsPerInchHorizontal;
   TotalPageHeightInches := pt.Y / PixelsPerInchVertical;

   GutterRight := TotalPageWidthPixels - GutterLeft - Printer.PageWidth;
   GutterBottom := TotalPageHeightPixels - GutterTop - Printer.PageHeight;

   If ( TopMargin < GutterTop ) Then
      TopMargin := GutterTop;
   If ( BottomMargin < GutterBottom ) Then
      BottomMargin := GutterBottom;
   If ( LeftMargin < GutterLeft ) Then
      LeftMargin := GutterLeft;

   If ( RightMargin < GutterRight ) Then
      RightMargin := GutterRight;   
   End;

procedure TPrintObject.SetHeaderInformation( Line:Integer; YPosition: Single; Text:String; Alignment:Word; 
   FontName:String; FontSize: Word; FontStyle: TFontStyles );

   Begin
   If ( Line > HeaderLines ) Then
      Exit;

   Header[Line].Text := Text;
   Header[Line].YPosition := YPosition;
   Header[Line].Alignment := Alignment;
   Header[Line].FontName := FontName;
   Header[Line].FontSize := FontSize;
   Header[Line].FontStyle := FontStyle;
   End;

procedure TPrintObject.SetFooterInformation( Line:Integer; YPosition: Single; Text:String; Alignment:Word; 

   FontName:String; FontSize: Word; FontStyle: TFontStyles );

   Begin
   If ( Line > FooterLines ) Then
      Exit;

   Footer[Line].Text := Text;
   Footer[Line].YPosition := YPosition;
   Footer[Line].Alignment := Alignment;
   Footer[Line].FontName := FontName;
   Footer[Line].FontSize := FontSize;
   Footer[Line].FontStyle := FontStyle;   
   End;

procedure TPrintObject.WriteHeader;

   { If any headers are defined, write them }

   var
      I: Integer;

   Begin
   SaveCurrentFont;
   For I := 1 To HeaderLines Do
      Begin
      If ( Length(Header[I].Text) > 0 ) Then

         Begin
         With Header[I] Do
            Begin
            SetFontInformation( FontName,FontSize,FontStyle );
            If ( Alignment = 0 ) Then
               WriteLine( LeftMargin, YPosition, Text );
            If ( Alignment = 1 ) Then
               WriteLineCenter( YPosition, Text );
            If ( Alignment = 2 ) Then
               WriteLineRight( YPosition, Text );
            End;
         End;

      RestoreCurrentFont;
      End;

   { Does the user desire a box around the header? }
   If ( HeaderCoordinates.Boxed = True ) Then
      Begin
      If ( HeaderCoordinates.Shading > 0 ) Then

         DrawBoxShaded( HeaderCoordinates.XTop,HeaderCoordinates.YTop,HeaderCoordinates.XBottom,
            HeaderCoordinates.YBottom,HeaderCoordinates.LineWidth,HeaderCoordinates.Shading)
      Else
         DrawBox( HeaderCoordinates.XTop,HeaderCoordinates.YTop,HeaderCoordinates.XBottom,
            HeaderCoordinates.YBottom,HeaderCoordinates.LineWidth );
      End;
   End;

procedure TPrintObject.WriteFooter;

   { If any footers are defined, write them }

   var
      I: Integer;
      Temp: Boolean;

   Begin
   SaveCurrentFont;

   { Set 'AutoPaging' off.  Otherwise the footer will not get written
     correctly. }
   Temp := AutoPaging;
   AutoPaging := False;
      
   For I := 1 To FooterLines Do

      Begin
      If ( Length(Footer[I].Text) > 0 ) Then
         Begin
         With Footer[I] Do
            Begin
            SetFontInformation( FontName,FontSize,FontStyle );
            If ( Alignment = 0 ) Then
               WriteLine( LeftMargin, YPosition, Text );
            If ( Alignment = 1 ) Then
               WriteLineCenter( YPosition, Text );
            If ( Alignment = 2 ) Then
               WriteLineRight( YPosition, Text );
            End;
         End;

      RestoreCurrentFont;
      End;

   { Does the user desire a box around the footer? }

   If ( FooterCoordinates.Boxed = True ) Then
      Begin
      If ( FooterCoordinates.Shading > 0 ) Then
         DrawBoxShaded( FooterCoordinates.XTop,FooterCoordinates.YTop,FooterCoordinates.XBottom,
            FooterCoordinates.YBottom,FooterCoordinates.LineWidth,FooterCoordinates.Shading )
      Else
         DrawBox( FooterCoordinates.XTop,FooterCoordinates.YTop,FooterCoordinates.XBottom,
            FooterCoordinates.YBottom,FooterCoordinates.LineWidth );
      End;

   AutoPaging := Temp;
   End;

procedure TPrintObject.SaveCurrentFont;

   Begin
   CurrentFontName := Printer.Canvas.Font.Name;
   CurrentFontSize := Printer.Canvas.Font.Size;
   CurrentFontStyle := Printer.Canvas.Font.Style;
   End;                                       


procedure TPrintObject.RestoreCurrentFont;

   Begin
   SetFontInformation( CurrentFontName,CurrentFontSize,CurrentFontStyle );
   End;

procedure TPrintObject.SetDetailTopBottom( Top: Single; Bottom: Single );

   Begin
   DetailTop := Top;
   DetailBottom := Bottom;

   LastYPosition := Top - GetLineHeightInches;
   End;

procedure TPrintObject.SetAutoPaging( Value: Boolean );

   Begin
   AutoPaging := Value;
   End;

procedure TPrintObject.SetPageNumberInformation( YPosition:Single; Text:String; Alignment:Word; FontName:String; 
   FontSize:Word; FontStyle:TFontStyles );

   Begin
   PageNumber.Text := Text;

   PageNumber.YPosition := YPosition;
   PageNumber.Alignment := Alignment;
   PageNumber.FontName := FontName;
   PageNumber.FontSize := FontSize;
   PageNumber.FontStyle := FontStyle;
   End;

procedure TPrintObject.WritePageNumber;

   var
      Buffer: String;
      Temp: Boolean;

   Begin
   Buffer := Format( PageNumber.Text,[Printer.PageNumber] );

   SaveCurrentFont;
   SetFontInformation( PageNumber.FontName,PageNumber.FontSize,PageNumber.FontStyle );

   Temp := AutoPaging;
   AutoPaging := False;
                                   

   If ( PageNumber.Alignment = 0 ) Then
      WriteLine( LeftMargin, PageNumber.YPosition, Buffer );
   If ( PageNumber.Alignment = 1 ) Then
      WriteLineCenter( PageNumber.YPosition, Buffer );
   If ( PageNumber.Alignment = 2 ) Then
      WriteLineRight( PageNumber.YPosition, Buffer );

   AutoPaging := Temp;

   RestoreCurrentFont;
   End;

procedure TPrintObject.SetTab( Inches:Single );

   Begin
   CurrentTab := Inches;
   End;

procedure TPrintObject.SetHeaderDimensions( XTop:Single; YTop:Single; XBottom:Single; YBottom:Single;
   Boxed: Boolean; LineWidth:Word; Shading:Word );

   Begin
   HeaderCoordinates.XTop := XTop;

   HeaderCoordinates.XBottom := XBottom;
   HeaderCoordinates.YTop := YTop;
   HeaderCoordinates.YBottom := YBottom;
   HeaderCoordinates.Boxed := Boxed;
   HeaderCoordinates.LineWidth := LineWidth;
   HeaderCoordinates.Shading := Shading;
   End;

procedure TPrintObject.SetFooterDimensions( XTop:Single; YTop:Single; XBottom:Single; YBottom:Single;
   Boxed: Boolean; LineWidth:Word; Shading:Word );

   Begin
   FooterCoordinates.XTop := XTop;
   FooterCoordinates.XBottom := XBottom;
   FooterCoordinates.YTop := YTop;
   FooterCoordinates.YBottom := YBottom;
   FooterCoordinates.Boxed := Boxed;
   FooterCoordinates.LineWidth := LineWidth;
   FooterCoordinates.Shading := Shading;
   End;

procedure TPrintObject.CreateColumn( Number:Word; XPosition:Single; Length:Single );


   Begin
   ColumnInformation[Number].XPosition := XPosition;
   ColumnInformation[Number].Length := Length;
   End;

procedure TPrintObject.SetYPosition( YPosition:Single );

   Begin
   LastYPosition := YPosition;
   End;
    
function TPrintObject.GetYPosition: Single;

   Begin
   Result := LastYPosition;
   End;

procedure TPrintObject.NextLine;

   Begin
   LastYPosition := LastYPosition + GetLineHeightInches;
   End;   

function TPrintObject.GetLinesLeft: Word;

   { Return the number of lines left in the detail area }

   var
      Lines: Single;
      Buffer: String[20];
      I: Word;

   Begin
   Lines := (DetailBottom - LastYPosition) / GetLineHeightInches;

   Buffer := FloatToStr( Lines );

   { Buffer contains the number of lines left as a floating point number.
     Find the decimal and truncate the string at that point.  So, if there
     are 2.99 lines left, 2 will be returned.  Better to be conservative. }
   For I := 1 To Length(Buffer) Do
      Begin
      If ( Buffer[I] = '.' ) Then
         Begin
         Buffer[0] := Chr(I-1);
         Break;
         End;
      End;

   Result := StrToInt( Buffer );
   End;

procedure TPrintObject.SetTopOfPage;

   Begin
   LastYPosition := DetailTop;
   End;

procedure TPrintObject.NewLines( Number:Word );


   { Generate the number of line feeds represented in 'Number' }

   var
      I: Word;

   Begin
   For I := 1 To Number Do
      NextLine;
   End;

end.

{******* demo.pas *******}

unit Demo;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, ExtCtrls, StdCtrls, Mask, DBCtrls, Menus, PrnMain;

const
  LeftMargin = 0.5;
  RightMargin = 0.5;
  TopMargin = 0.5;
  BottomMargin = 0.5;

type
  TPrintForm = class(TForm)
   Button1: TButton;
   Button2: TButton;
   PixelsPerInch: TPanel;
   PixelsPerPage: TPanel;
   Gutters: TPanel;
   LineHeight: TPanel;
   FontInformation: TPanel;

   LinesInDetailArea: TPanel;
   procedure Button1Click(Sender: TObject);
   procedure FormCreate(Sender: TObject);
   procedure Button2Click(Sender: TObject);
  private
   { Private declarations }
  public
   { Public declarations }
  end;

var
  PrintForm: TPrintForm;
  Prn: TPrintObject;

implementation

{$R *.DFM}

procedure TPrintForm.Button1Click(Sender: TObject);

  var
     Buffer: String;
     Code: String[10];
     ECHOCode: String[10];
     HeaderLine: Boolean;
     I: Word;
 
  Begin
  { Define the dimensions of the header area.  I want the header area
    lightly shaded.  If I wanted no shading, the last parameter would be
    255. }
  with prn do 
  begin
    SetHeaderDimensions( 0.25,0.25,8.25,1.25,True,0,225 );

    { Define two header lines }
    SetHeaderInformation( 1,0.5,'This is header line number 1',1,'Arial',14,[fsBold] );

    SetHeaderInformation( 2,1.0,DateToStr(Date),1,'Arial',11,[] );

    { Define the dimensions of the footer area.  I want the footer area
      lightly shaded.  If I wanted no shading, the last parameter would be
      255. }
    SetFooterDimensions( 0.25,9.40,8.25,10.20,True,0,225 );

    { Define two footer lines }
    SetFooterInformation( 1,9.5,'This is footer line number 1',1,'Arial',14,[fsBold] );
    SetFooterInformation( 2,9.85,'This is footer line number 2',1,'Arial',12,[fsBold] );

    { I would like page numbering, right justified on the very bottom of the
      page. }
    SetPageNumberInformation( 10.25,'Page: %d',2,'Arial',9,[fsBold] );


    { Set the current position to the top of the detail area }
    SetTopOfPage;

    { Write three lines, the first left justified, the second centered and
      the third right justified.  The first line gets printed two inches
      from the top.  The next two lines get printed at the next line from
      the previous line. The '-1' for the first parameter indicates that
      printing should be on the next line.  If '-2' is passed as a 
      parameter, printing would occur on the current line. }
    WriteLine( -1.0,2.0,'This is a line left justified' );
    WriteLineCenter( -1.0,'This is a line centered' );
    WriteLineRight( -1.0,'This is a line right justified' );


    { Create five columns.  The first parameter is the column number, the
      second parameter is the location in inches from the left and the third
      parameter is the length in inches. }
    CreateColumn( 1,0.25,1.5 );
    CreateColumn( 2,1.80,1.5 );
    CreateColumn( 3,3.35,1.5 );
    CreateColumn( 4,4.90,1.5 );
    CreateColumn( 5,6.50,1.5 );

    { Start writing column text (left justified) at three inches from the
      top }
    SetYPosition( 3.0 );
    For I := 1 To 10 Do
       Begin
       { The first parameter of 'WriteLineColumn' is the column number and
         the second parameter indicates that printing should occur on the
         current line (in this case, three inches from the top).  If the 

         second parameter was -1, printing would occur on the next line. }
       WriteLineColumn( 1,-2,Format('Column 1, Line %d',[I]) );
       WriteLineColumn( 2,-2,Format('Column 2, Line %d',[I]) );
       WriteLineColumn( 3,-2,Format('Column 3, Line %d',[I]) );
       WriteLineColumn( 4,-2,Format('Column 4, Line %d',[I]) );
       WriteLineColumn( 5,-2,Format('Column 5, Line %d',[I]) );
       { Generate a line feed }
       NextLine;
       End;

    { Start writing column text (right justified) at six inches from the 
      top }
    SetYPosition( 5.0 );

    For I := 1 To 10 Do
       Begin
       WriteLineColumnRight( 1,-2,Format('Column 1, Line %d',[I]) );
       WriteLineColumnRight( 2,-2,Format('Column 2, Line %d',[I]) );
       WriteLineColumnRight( 3,-2,Format('Column 3, Line %d',[I]) );
       WriteLineColumnRight( 4,-2,Format('Column 4, Line %d',[I]) );
       WriteLineColumnRight( 5,-2,Format('Column 5, Line %d',[I]) );
       NextLine;
       End;
                                                             
    { Start writing column text (centered) at seven inches from the 
      top }
    SetYPosition( 7.0 );
    For I := 1 To 10 Do
       Begin
       WriteLineColumnCenter( 1,-2,Format('Column 1, Line %d',[I]) );

       WriteLineColumnCenter( 2,-2,Format('Column 2, Line %d',[I]) );
       WriteLineColumnCenter( 3,-2,Format('Column 3, Line %d',[I]) );
       WriteLineColumnCenter( 4,-2,Format('Column 4, Line %d',[I]) );
       WriteLineColumnCenter( 5,-2,Format('Column 5, Line %d',[I]) );
       NextLine;
       End;

    { Start a new page }
    NewPage;

    { Change the font information }
    SetFontInformation( 'Courier',20,[fsBold,fsUnderline] );

    For I := 1 To 10 Do
       WriteLine( LeftMargin,-1,Format('This is line %d',[I]) );

    { Set a tab of .5 inches }
    SetTab( 0.5 );

    { Change the font information }
    SetFontInformation( 'Arial',10,[fsItalic] );

    NextLine;
    For I := 1 To 10 Do
       { Since a tab of .5 is set, this text will actually get printed at
         1.0 inches from the left }
       WriteLine( LeftMargin,-1,Format('This is line %d',[I]) );

    { Draw some lines of varying thickness }
    DrawLine( 2.5,5.0,6.0,8.5,5 );
    DrawLine( 6.2,5.2,3.0,8.7,20 );
                                                            
    { We're all done.  Always call 'Quit' }
    Quit;
    Free;
    Exit;
  end;
End;

procedure TPrintForm.FormCreate(Sender: TObject);
var
  X,Y: Word;

  Top,Bottom,Left,Right: Word;

Begin
    { Create a TPrintObject }
    Prn := TPrintObject.Create;
	with prn do 
    begin

    { Must always call 'Start' first thing }
    Start;

    { Set left, right, top and bottom margins - in inches }
    SetMargins( LeftMargin,RightMargin,TopMargin,BottomMargin );

    { Define what the 'detail' section dimensions will be.  The detail section
      is the space between the header and the footer areas. }
    SetDetailTopBottom( 1.4,9.4 );

    { Set default information }
    SetFontInformation( 'Arial',11,[] ); 

    GetPixelsPerInch( X,Y );
    PixelsPerInch.Caption := Format( 'Pixels Per Inch      X: %d  Y: %d',[X,Y] );


    GetPixelsPerPage( X,Y );
    PixelsPerPage.Caption := Format( 'Pixels Per Page      X: %d  Y: %d',[X,Y] );

    GetGutter( Top,Bottom,Left,Right );
    Gutters.Caption := Format( 'Gutters     Top: %d   Bottom: %d   Left: %d   Right: %d',[Top,Bottom,Left,Right] );

    LineHeight.Caption := Format( 'Height of Each Line:   %d',[GetLineHeightPixels] );

    FontInformation.Caption := Format( 'Font Name: %s     Font Size: %d',[GetFontName,GetFontSize] );

    LinesInDetailArea.Caption := Format( 'Lines in Detail Area: %d',[GetLinesInDetailArea] );

	end; {with}
End;

procedure TPrintForm.Button2Click(Sender: TObject);

  Begin
  Close;
  Halt;
  End;

end.


{******* project.dpr *******}

program Project;

uses
  Forms,
  Prnmain in 'PRNMAIN.PAS',
  Demo in 'DEMO.PAS' {PrintForm};

{$R *.RES}

begin
  Application.CreateForm(TPrintForm, PrintForm);
  Application.Run;
end.
 

{******* demo.dfm *******}

object PrintForm: TPrintForm
  Left = 104
  Top = 90
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Print Demonstration'
  ClientHeight = 317

  ClientWidth = 427
  Color = clSilver
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'System'
  Font.Style = []
  PixelsPerInch = 96
  Position = poScreenCenter
  OnCreate = FormCreate
  TextHeight = 16
  object Button1: TButton
    Left = 276
    Top = 270
    Width = 61
    Height = 33
    Caption = '&Print'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 342
    Top = 270
    Width = 61
    Height = 33
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 1
    OnClick = Button2Click
  end
  object PixelsPerInch: TPanel
    Left = 6
    Top = 12
    Width = 415
    Height = 25
    TabOrder = 2
  end
  object PixelsPerPage: TPanel
    Left = 6
    Top = 42
    Width = 415

    Height = 25
    TabOrder = 3
  end
  object Gutters: TPanel
    Left = 6
    Top = 72
    Width = 415
    Height = 25
    TabOrder = 4
  end
  object LineHeight: TPanel
    Left = 6
    Top = 102
    Width = 415
    Height = 25
    TabOrder = 5
  end
  object FontInformation: TPanel
    Left = 6
    Top = 132
    Width = 415
    Height = 25
    TabOrder = 6
  end
  object LinesInDetailArea: TPanel
    Left = 6
    Top = 162
    Width = 415
    Height = 25
    TabOrder = 7
  end
end
