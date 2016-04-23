{
As I follow this forum, many requests are made for PCX graphics
file routines. Those that are looking for Read_PCX info can
find it on the ZSoft BBS in a wonderful Pascal example: ShowPCX.

On the other hand, there is next to zilch out there on how to
Write_PCX files. I know.... I searched and searched and couldn't
find a thing! So with a little brute force  and a few ZSoft
C language snippets <groan>, I got this together:

PCX_W.Write_PCX (Name:Str80);
given to the public domain and commonweal.
pseudocode:
           set 640x480x16 VGAhi graphics mode only for now
           getimage 1 row at a time
           reorganize the BGI color planes into PCX format order
           encode the raw PCX line into a run length limited
             compressed PCX line
           blockwrite the compressed PCX line to your.PCX file
}

{$R-}    {Range checking, turn off when debugged}

unit PCX_W;

{ --------------------- Interface ----------------- }

interface

type
    Str80 = string [80];

procedure Write_PCX  (Name:Str80);


{ ===================== Implementation ============ }

implementation

uses
    Graph;


{-------------- Write_PCX --------------}

procedure Write_PCX (Name:Str80);

const
     RED1   = 0;
     GREEN1 = 1;
     BLUE1  = 2;

type
    ArrayPal   = array [0..15, RED1..BLUE1] of byte;

const
     MAX_WIDTH  = 4000;    { arbitrary - maximum width (in bytes) of
                             a PCX image }
     INTENSTART =   $5;
     BLUESTART  =  $55;
     GREENSTART =  $A5;
     REDSTART   =  $F5;

type
    Pcx_Header = record
    {comments from ZSoft ShowPCX pascal example}

        Manufacturer: byte;     { Always 10 for PCX file }

        Version: byte;          { 2 - old PCX - no palette (not used
                                      anymore),
                                  3 - no palette,
                                  4 - Microsoft Windows - no palette
                                      (only in old files, new Windows
                                      version uses 3),
                                  5 - with palette }

        Encoding: byte;         { 1 is PCX, it is possible that we may
                                  add additional encoding methods in the
                                  future }

        Bits_per_pixel: byte;   { Number of bits to represent a pixel
                                  (per plane) - 1, 2, 4, or 8 }

        Xmin: integer;          { Image window dimensions (inclusive) }
        Ymin: integer;          { Xmin, Ymin are usually zero (not always)}
        Xmax: integer;
        Ymax: integer;

        Hdpi: integer;          { Resolution of image (dots per inch) }
        Vdpi: integer;          { Set to scanner resolution - 300 is
                                  default }

        ColorMap: ArrayPal;
                                { RGB palette data (16 colors or less)
                                  256 color palette is appended to end
                                  of file }

        Reserved: byte;         { (used to contain video mode)
                                  now it is ignored - just set to zero }

        Nplanes: byte;          { Number of planes }

        Bytes_per_line_per_plane: integer;   { Number of bytes to
                                               allocate for a scanline
                                               plane. MUST be an an EVEN
                                               number! Do NOT calculate
                                               from Xmax-Xmin! }

        PaletteInfo: integer;   { 1 = black & white or color image,
                                  2 = grayscale image - ignored in PB4,
                                      PB4+ palette must also be set to
                                      shades of gray! }

        HscreenSize: integer;   { added for PC Paintbrush IV Plus
                                  ver 1.0,  }
        VscreenSize: integer;   { PC Paintbrush IV ver 1.02 (and later)}
                                { I know it is tempting to use these
                                  fields to determine what video mode
                                  should be used to display the image
                                  - but it is NOT recommended since the
                                  fields will probably just contain
                                  garbage. It is better to have the
                                  user install for the graphics mode he
                                  wants to use... }

        Filler: array [74..127] of byte;     { Just set to zeros }
    end;

    Array80    = array [1..80]        of byte;
    ArrayLnImg = array [1..326]       of byte; { 6 extra bytes at
     beginng of line that BGI uses for size info}
    Line_Array = array [0..MAX_WIDTH] of byte;
    ArrayLnPCX = array [1..4]         of Array80;

var
   PCXName   : File;
   Header    : Pcx_Header;                 { PCX file header }
   ImgLn     : ArrayLnImg;
   PCXLn     : ArrayLnPCX;
   RedLn,
   BlueLn,
   GreenLn,
   IntenLn   : Array80;
   Img       : pointer;


{-------------- BuildHeader- -----------}

procedure BuildHeader;

const
     PALETTEMAP: ArrayPal=
                 {  R    G    B                    }
                (($00, $00, $00),  {  black        }
                 ($00, $00, $AA),  {  blue         }
                 ($00, $AA, $00),  {  green        }
                 ($00, $AA, $AA),  {  cyan         }
                 ($AA, $00, $00),  {  red          }
                 ($AA, $00, $AA),  {  magenta      }
                 ($AA, $55, $00),  {  brown        }
                 ($AA, $AA, $AA),  {  lightgray    }
                 ($55, $55, $55),  {  darkgray     }
                 ($55, $55, $FF),  {  lightblue    }
                 ($55, $FF, $55),  {  lightgreen   }
                 ($55, $FF, $FF),  {  lightcyan    }
                 ($FF, $55, $55),  {  lightred     }
                 ($FF, $55, $FF),  {  lightmagenta }
                 ($FF, $FF, $55),  {  yellow       }
                 ($FF, $FF, $FF) );{  white        }

var
   i : word;

begin
     with Header do
          begin
               Manufacturer  := 10;
               Version  := 5;
               Encoding := 1;
               Bits_per_pixel := 1;
               Xmin := 0;
               Ymin := 0;
               Xmax := 639;
               Ymax := 479;
               Hdpi := 640;
               Vdpi := 480;
               ColorMap := PALETTEMAP;
               Reserved := 0;
               Nplanes  := 4; { Red, Green, Blue, Intensity }
               Bytes_per_line_per_plane := 80;
               PaletteInfo := 1;
               HscreenSize := 0;
               VscreenSize := 0;
               for i := 74 to 127 do
                   Filler [i] := 0;
          end;
end;


{-------------- GetBGIPlane ------------}

procedure GetBGIPlane (Start:word; var Plane:Array80);

var
   i : word;

begin
     for i:= 1 to Header.Bytes_per_line_per_plane do
         Plane [i] := ImgLn [Start +i -1]
end;

{-------------- BuildPCXPlane ----------}

procedure BuildPCXPlane (Start:word; Plane:Array80);

var
   i : word;

begin
     for i := 1 to Header.Bytes_per_line_per_plane do
         PCXLn [Start] [i] := Plane [i];
end;


{-------------- EncPCXLine -------------}

procedure EncPCXLine (PlaneLine : word); { Encode a PCX line }

var
   This,
   Last,
   RunCount : byte;
   i,
   j        : word;


  {-------------- EncPut -----------------}

  procedure EncPut (Byt, Cnt :byte);

  const
       COMPRESS_NUM = $C0;  { this is the upper two bits that
                              indicate a count }

  var
     Holder : byte;

  begin
  {$I-}
       if (Cnt = 1) and (COMPRESS_NUM <> (COMPRESS_NUM and Byt)) then
          blockwrite (PCXName, Byt,1)          { single occurance }
          {good place for file error handler!}
       else
           begin
                Holder := (COMPRESS_NUM or Cnt);
                blockwrite (PCXName, Holder, 1); { number of times the
                                                   following color
                                                   occurs }
                blockwrite (PCXName, Byt, 1);
           end;
  {$I+}
  end;


begin
     i := 1;         { used in PCXLn }
     RunCount := 1;
     Last := PCXLn [PlaneLine][i];
     for j := 1 to Header.Bytes_per_line_per_plane -1 do
         begin
              inc (i);
              This := PCXLn [PlaneLine][i];
              if This = Last then
                 begin
                      inc (RunCount);
                      if RunCount = 63 then   { reached PCX run length
                                                limited max yet? }
                         begin
                              EncPut (Last, RunCount);
                              RunCount := 0;
                         end;
                 end
              else
                  begin
                       if RunCount >= 1 then
                          Encput (Last, RunCount);
                       Last := This;
                       RunCount := 1;
                  end;
         end;
     if RunCount >= 1 then  { any left over ? }
        Encput (Last, RunCount);
end;

            { - - -W-R-I-T-E-_-P-C-X- - - - - - - - }

const
     XMAX = 639;
     YMAX = 479;

var
   i, j, Size : word;

begin
     BuildHeader;
     assign     (PCXName,Name);
{$I-}
     rewrite    (PCXName,1);
     blockwrite (PCXName,Header,sizeof (Header));
     {good place for file error handler!}
{$I+}
     setviewport (0,0,XMAX,YMAX, ClipOn);
     Size := imagesize (0,0,XMAX,0); { size of a single row }
     getmem (Img,Size);

     for i := 0 to YMAX do
         begin
              getimage (0,i,XMAX,i,Img^);  { Grab 1 line from the
                                             screen store in Img
                                             buffer  }
              move (Img^,ImgLn,Size {326});

              GetBGIPlane (INTENSTART, IntenLn);
              GetBGIPlane (BLUESTART,  BlueLn );
              GetBGIPlane (GREENSTART, GreenLn);
              GetBGIPlane (REDSTART,   RedLn  );
              BuildPCXPlane (1, RedLn  );
              BuildPCXPlane (2, GreenLn);
              BuildPCXPlane (3, BlueLn );
              BuildPCXPlane (4, IntenLn); { 320 bytes/line
                                            uncompressed }
              for j := 1 to Header.NPlanes do

                  EncPCXLine (j);
         end;
     freemem (Img,Size);           (* Release the memory        *)
{$I-}
     close (PCXName);              (* Save the Image            *)
{$I+}
end;

end {PCX.TPU} .


{ -----------------------Test Program -------------------------- }

program WritePCX;

uses
    Graph, PCX_W;

{-------------- DrawHorizBars ----------}

procedure DrawHorizBars;

var
   i, Color : word;

begin
     cleardevice;
     Color := 15;
     for i := 0 to 15 do
         begin
              setfillstyle (solidfill,Color);
              bar (0,i*30,639,i*30+30);       { 16*30 = 480 }
              dec (Color);
         end;
end;

{-------------- Main -------------------}

var
   NameW : Str80;
   Gd,
   Gm    : integer;

begin
     writeln;
     if (ParamCount = 0) then           { no DOS command line
                                          parameters }
        begin
             write ('Enter name of PCX picture file to write: ');
             readln (NameW);
             writeln;
        end
     else
         begin
              NameW := paramstr (1);  { get filename from DOS
                                        command line }
         end;

     if (Pos ('.', NameW) = 0) then   { make sure the filename
                                        has PCX extension }
        NameW := Concat (NameW, '.pcx');

     Gd:=VGA;
     Gm:=VGAhi; {640x480, 16 colors}
     initgraph (Gd,Gm,'..\bgi');  { path to your EGAVGA.BGI }

     DrawHorizBars;

     readln;
     Write_PCX (NameW); { PCX_W.TPU }
     closegraph;                    { Close graphics    }
     textmode (co80);               { back to text mode }
end.  { Write_PCX }

{
OK, everybody, I hope this gets you started. I had a lot of
fun setting it up. There are some obvious places that need
optimization... especially the disk intensive blockwrites. If
someone could please figure out holding about 4k or so in pointers
of the encoded PCX file before writing, I'd sure appreciate it!.
(please post for everyone, if you do.)

}