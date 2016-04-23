{
I have just made a HP DESKJET Unit. Maybe there are some interested out there.
Please write me a message if you are going to use it...
Here it is :

{-----------------------CUT CUT CUT CUT CUT CUT---------------------------}

{                           HP-DESKJET v1.0
                    THE ULTIMATE HP DESKJET UNIT
          (C)COPYRIGHT 1996 DIMENSION X ■ DONE BY BUCKSHAG

 This unit is made by : John Vd Burg a.k.a. BuCKSHaG from DiMeNSioN X
 The unit has been tested on a HP DESKJET 500 and 520. But i Think it
 will work on all of the HP DESKJETS. Feel free to use it in your
 programs, but please give me some credits :)
 To the makers of SWAG : "Feel free to put it in the SWAG files".

 Grtx BuCKSHaG/DiMeNSioN X}

Unit DESKJET;
INTERFACE
Uses Crt,Printer;
Var Command:string;

Procedure HP_RESET;                             {Resets The Printer}
Procedure HP_SELFTEST;                          {Perform A Selftest}
Procedure HP_EJECT;                             {Eject A Page}
Procedure HP_TRAYFEED;                          {Prepare Page For Printing}
Procedure HP_ENVFEED;                           {Envelope Feed}
Procedure HP_LEFTTORIGHT;                       {Prints From Left To Right}
Procedure HP_BIDIRECTIONAL;                     {Prints From Both Sides}
Procedure HP_RIGHTTOLEFT;                       {Prints From Right To Left}
Procedure HP_SingleFIXED;                       {Underline Method (Single)}
Procedure HP_SingleFLOAT;                       {Underline Method (Single)}
Procedure HP_DoubleFIXED;                       {Underline Method (Double)}
Procedure HP_DoubleFLOAT;                       {Underline Method (Double)}
Procedure HP_UNDERLINEOFF;                      {Turns Underline Usage OFF}
Procedure HP_EOLoff;                            {Wrap Text At Eoln OFF}
Procedure HP_EOLon;                             {Wrap Text At Eoln ON}
Procedure HP_DisplayON;                         {Turns Display ON}
Procedure HP_DisplayOFF;                        {Turns Display OFF}
Procedure HP_LineByLineON;                      {Line By Line Printing ON}
Procedure HP_LineByLineOFF;                     {Line By Line Printing OFF}
Procedure HP_DEFAULTSIZE;                       {Default Paper Size}
Procedure HP_USLETTERSIZE;                      {US-Letter Paper Size}
Procedure HP_USLEGALSIZE;                       {US-Legal Paper Size}
Procedure HP_A4SIZE;                            {A4 Paper Size}
Procedure HP_ENVELOPESIZE;                      {Envelope Paper Size}
Procedure HP_LANDSCAPE;                         {Landscape Printing ON}
Procedure HP_PORTRAIT;                          {Portrait Printing ON}
Procedure HP_LINESPERINCH(x:integer);           {[X] Number Of Lines Per Inch}
Procedure HP_LINES(x:integer);                  {[X] Number Of Lines Per Page}
Procedure HP_CHARPERINCH(x:integer);            {[X] Number Of Chars Per Inch}
Procedure HP_UPRIGHT;                           {Straight Letters}
Procedure HP_ITALIC;                            {Cursive Letters}
Procedure HP_NORMAL;                            {Normal Letters}
Procedure HP_BOLD;                              {Bold Printing On}
Procedure HP_EXTRABOLD;                         {Extra Bold Printing ON}
Procedure HP_HIGHQUALITY;                       {High Quality Printing ON}
Procedure HP_LOWQUALITY;                        {Low Quality Printing ON}
Procedure HP_75dpi;                             {75 Dots Per INCH Print Res.}
Procedure HP_100dpi;                            {100 Dots Per INCH Print Res.}
Procedure HP_150dpi;                            {150 Dots Per INCH Print Res.}
Procedure HP_300dpi;                            {300 Dots Per INCH Print Res.}
Procedure HP_COURIER;                           {Font}
Procedure HP_CGTIMES;                           {Font}
Procedure HP_LETTERGOTHIC;                      {Font}
Procedure HP_LINEPRINTER;                       {Font}
Procedure HP_PICA;                              {Font}
Procedure HP_PRESTIGE;                          {Font}
Procedure HP_ELITE;                             {Font}
Procedure HP_SCRIPT;                            {Font}
Procedure HP_HELVETICA;                         {Font}
Procedure HP_TIMESROMAN;                        {Font}
Procedure HP_PRESENTATIONS;                     {Font}
Procedure HP_CGCENTURY;                         {Font}
Procedure HP_BRUSH;                             {Font}
Procedure HP_DOMCASUAL;                         {Font}
Procedure HP_UNIVERSCONDESED;                   {Font}
Procedure HP_GARAMOND;                          {Font}
Procedure HP_UNIVERS;                           {Font}
Procedure HP_CGTRIUMVIRATE;                     {Font}

IMPLEMENTATION

Procedure HP_RESET;                             {Resets The Printer}
 Begin
  Command:=#27+'E';
  Writeln(lst,command);
 End;

Procedure HP_SELFTEST;                          {Perform A Selftest}
 Begin
  Command:=#27+'z';
  Writeln(lst,command);
 End;

Procedure HP_EJECT;                             {Eject A Page}
 Begin
  Writeln(lst,#12);
 End;

Procedure HP_TRAYFEED;                          {Prepare Page For Printing}
 Begin
  Command:=#27+'&11H';
  Writeln(lst,command);
 End;

Procedure HP_ENVFEED;                           {Envelope Feed}
 Begin
  Command:=#27+'&13H';
  Writeln(lst,command);
 End;

Procedure HP_LEFTTORIGHT;                       {Prints From Left To Right}
 Begin
  Command:=#27+'&k0W';
  Writeln(lst,command);
 End;

Procedure HP_BIDIRECTIONAL;                     {Prints From Both Sides}
 Begin
  Command:=#27+'&k1W';
  Writeln(lst,command);
 End;

Procedure HP_RIGHTTOLEFT;                       {Prints From Right To Left}
 Begin
  Command:=#27+'&k2W';
  Writeln(lst,command);
 End;

Procedure HP_SingleFIXED;                       {Underline Method (Single)}
 Begin
  Command:=#27+'&d1D';
  Writeln(lst,command);
 End;

Procedure HP_SingleFLOAT;                       {Underline Method (Single)}
 Begin
  Command:=#27+'&d3D';
  Writeln(lst,command);
 End;

Procedure HP_DoubleFIXED;                       {Underline Method (Double)}
 Begin
  Command:=#27+'&d2D';
  Writeln(lst,command);
 End;

Procedure HP_DoubleFLOAT;                       {Underline Method (Double)}
 Begin
  Command:=#27+'&d4D';
  Writeln(lst,command);
 End;

Procedure HP_UNDERLINEOFF;                      {Turns Underline Usage OFF}
 Begin
  Command:=#27+'&d@';
  Writeln(lst,command);
 End;

Procedure HP_EOLoff;                            {Wrap Text At Eoln OFF}
 Begin
  Command:=#27+'&s1C';
  Writeln(lst,command);
 End;

Procedure HP_EOLon;                             {Wrap Text At Eoln ON}
 Begin
  Command:=#27+'&s0C';
  Writeln(lst,command);
 End;

Procedure HP_DisplayON;                         {Turns Display ON}
 Begin
  Command:=#27+'Y';
  Writeln(lst,command);
 End;

Procedure HP_DisplayOFF;                        {Turns Display OFF}
 Begin
  Command:=#27+'Z';
  Writeln(lst,command);
 End;

Procedure HP_LineByLineON;                      {Line By Line Printing ON}
 Begin
  Command:=#27+'&k0E';
  Writeln(lst,command);
 End;

Procedure HP_LineByLineOFF;                     {Line By Line Printing OFF}
 Begin
  Command:=#27+'&k1E';
  Writeln(lst,command);
 End;

Procedure HP_DEFAULTSIZE;                       {Default Paper Size}
 Begin
  Command:=#27+'&10A';
  Writeln(lst,command);
 End;

Procedure HP_USLETTERSIZE;                      {US-Letter Paper Size}
 Begin
  Command:=#27+'&12A';
  Writeln(lst,command);
 End;

Procedure HP_USLEGALSIZE;                       {US-Legal Paper Size}
 Begin
  Command:=#27+'&13A';
  Writeln(lst,command);
 End;

Procedure HP_A4SIZE;                            {A4 Paper Size}
 Begin
  Command:=#27+'&126A';
  Writeln(lst,command);
 End;

Procedure HP_ENVELOPESIZE;                      {Envelope Paper Size}
 Begin
  Command:=#27+'&181A';
  Writeln(lst,command);
 End;

Procedure HP_LANDSCAPE;                         {Landscape Printing ON}
 Begin
  Command:=#27+'&l1O';
  Writeln(lst,command);
 End;

Procedure HP_PORTRAIT;                          {Portrait Printing ON}
 Begin
  Command:=#27+'&l0O';
  Writeln(lst,command);
 End;

Procedure HP_LINESPERINCH(x:integer);           {[X] Number Of Lines Per Inch}
Var y:string;
 Begin
  Str(x,y);
  Command:=#27+'&1'+y+'D';
  Writeln(lst,command);
 End;

Procedure HP_LINES(x:integer);                  {[X] Number Of Lines Per Page}
Var y:String;
 Begin
  Str(x,y);
  Command:=#27+'&1l'+y+'P';
  Writeln(lst,command);
 End;

Procedure HP_CHARPERINCH(x:integer);            {[X] Number Of Chars Per Inch}
Var y:String;
 Begin
  Str(x,y);
  Command:=#27+'&(s'+y+'H';
  Writeln(lst,command);
 End;

Procedure HP_UPRIGHT;                           {Straight Letters}
 Begin
  Command:=#27+'(s0S';
  Writeln(lst,command);
 End;

Procedure HP_ITALIC;                            {Cursive Letters}
 Begin
  Command:=#27+'(s1S';
  Writeln(lst,command);
 End;

Procedure HP_NORMAL;                            {Normal Letters}
 Begin
  Command:=#27+'(s0B';
  Writeln(lst,command);
 End;

Procedure HP_BOLD;                              {Bold Printing On}
 Begin
  Command:=#27+'(s3B';
  Writeln(lst,command);
 End;

Procedure HP_EXTRABOLD;                         {Extra Bold Printing ON}
 Begin
  Command:=#27+'(s7B';
  Writeln(lst,command);
 End;

Procedure HP_HIGHQUALITY;                       {High Quality Printing ON}
 Begin
  Command:=#27+'(s2Q';
  Writeln(lst,command);
 End;

Procedure HP_LOWQUALITY;                        {Low Quality Printing ON}
 Begin
  Command:=#27+'(s1Q';
  Writeln(lst,command);
 End;

Procedure HP_75dpi;                             {75 Dots Per INCH Print Res.}
 Begin
  Command:=#27+'*t75R';
  Writeln(lst,command);
 End;

Procedure HP_100dpi;                            {100 Dots Per INCH Print Res.}
 Begin
  Command:=#27+'*t100R';
  Writeln(lst,command);
 End;

Procedure HP_150dpi;                            {150 Dots Per INCH Print Res.}
 Begin
  Command:=#27+'*t150R';
  Writeln(lst,command);
 End;

Procedure HP_300dpi;                            {300 Dots Per INCH Print Res.}
 Begin
  Command:=#27+'*t300R';
  Writeln(lst,command);
 End;

Procedure HP_COURIER;                           {Font}
 Begin
  Command:=#27+'(s3T';
  Writeln(lst,command);
 End;

Procedure HP_CGTIMES;                           {Font}
 Begin
  Command:=#27+'(s4101T';
  Writeln(lst,command);
 End;

Procedure HP_LETTERGOTHIC;                      {Font}
 Begin
  Command:=#27+'(s6T';
  Writeln(lst,command);
 End;

Procedure HP_LINEPRINTER;                       {Font}
 Begin
  Command:=#27+'(S0T';
  Writeln(lst,command);
 End;

Procedure HP_PICA;                              {Font}
 Begin
  Command:=#27+'(s1T';
  Writeln(lst,command);
 End;

Procedure HP_PRESTIGE;                          {Font}
 Begin
  Command:=#27+'(s8T';
  Writeln(lst,command);
 End;

Procedure HP_ELITE;                             {Font}
 Begin
  Command:=#27+'(s2T';
  Writeln(lst,command);
 End;

Procedure HP_SCRIPT;                            {Font}
 Begin
  Command:=#27+'(s7T';
  Writeln(lst,command);
 End;

Procedure HP_HELVETICA;                         {Font}
 Begin
  Command:=#27+'(s4T';
  Writeln(lst,command);
 End;

Procedure HP_TIMESROMAN;                        {Font}
 Begin
  Command:=#27+'(s5T';
  Writeln(lst,command);
 End;

Procedure HP_PRESENTATIONS;                     {Font}
 Begin
  Command:=#27+'(s11T';
  Writeln(lst,command);
 End;

Procedure HP_CGCENTURY;                         {Font}
 Begin
  Command:=#27+'(s23T';
  Writeln(lst,command);
 End;

Procedure HP_BRUSH;                             {Font}
 Begin
  Command:=#27+'(s32T';
  Writeln(lst,command);
 End;

Procedure HP_DOMCASUAL;                         {Font}
 Begin
  Command:=#27+'(s61T';
  Writeln(lst,command);
 End;

Procedure HP_UNIVERSCONDESED;                   {Font}
 Begin
  Command:=#27+'(s85T';
  Writeln(lst,command);
 End;

Procedure HP_GARAMOND;                          {Font}
 Begin
  Command:=#27+'(s101T';
  Writeln(lst,command);
 End;

Procedure HP_UNIVERS;                           {Font}
 Begin
  Command:=#27+'(s52T';
  Writeln(lst,command);
 End;

Procedure HP_CGTRIUMVIRATE;                     {Font}
 Begin
  Command:=#27+'(s4T';
  Writeln(lst,command);
 End;

end.
