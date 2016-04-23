
From: dblock@vdn.com (David Block)

Vincent Lim <kaneda@singnet.com.sg> wrote:

How do I send Printer Control Codes to the printer without having them
translated into unprintable characters?
Not sure if it is Windows API or Delphi is the culprit.
When I write the printer control codes, they are just printed as
unprintable characters rather than being interpreted by the printer.
You need to use the Passthrough printer Escape function to send data directly to the printer. If you're using WriteLn, then it won't work. Here's some code to get you started: 


--------------------------------------------------------------------------------

unit Passthru;

interface

uses printers, WinProcs, WinTypes, SysUtils;

Procedure       PrintTest;

implementation

Type
        TPassThroughData = Record
                nLen : Integer;
                Data : Array[0..255] of byte;
        end;

Procedure DirectPrint(s : String);
var
        PTBlock : TPassThroughData;
Begin
        PTBlock.nLen := Length(s);
        StrPCopy(@PTBlock.Data,s);
        Escape(printer.handle, PASSTHROUGH,0,@PTBlock,nil);
End;



Procedure PrintTest;
Begin
        Printer.BeginDoc;
        DirectPrint(CHR(27)+'&l1O'+'Hello, World!');
        Printer.EndDoc;
End;


end.
