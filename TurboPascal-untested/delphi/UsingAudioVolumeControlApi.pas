(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0424.PAS
  Description: Using Audio Volume Control API
  Author: SWAG SUPPORT TEAM
  Date: 01-02-98  07:34
*)

//
unit WaveUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls,
  Forms, Dialogs, MMSystem, StdCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.Button1Click(Sender: TObject);
var
 NumDevs     : Integer;
 waveCaps    : TWaveOutCaps;
 Volume      : DWORD;
 Left, Right : Word;
 Version     : Word;
begin
// We should have at least one device
  NumDevs := waveOutGetNumDevs;
  Edit1.Text := Format('Number of devices is %d', [NumDevs]);
// for the 1st device (hard-coded)
// Get Device Caps
  waveOutGetDevCaps(0, @waveCaps, SizeOf(waveCaps));
// Show device caps
  Memo1.Lines.Add('IατΓαφΦσ: '+waveCaps.szPName);
  Version := waveCaps.vDriverVersion;
  Memo1.Lines.Add(Format('Aσd±Φ  ΣdαΘΓσdα: %d.%d', [Hi(Version), Lo(Version)]));
  Case waveCaps.wChannels of
    1 : Memo1.Lines.Add('Iεφε');
    2 : Memo1.Lines.Add('╤≥σdσε');
  End;
 // Standard formats

 If waveCaps.dwFormats AND WAVE_FORMAT_1M08 <> 0 Then
  Memo1.Lines.Add('11.025 kHz, mono, 8-bit');
 If waveCaps.dwFormats AND WAVE_FORMAT_1M16 <> 0 Then
  Memo1.Lines.Add('11.025 kHz, mono, 16-bit');
{
WAVE_FORMAT_1S08	11.025 kHz, stereo, 8-bit
WAVE_FORMAT_1S16	11.025 kHz, stereo, 16-bit
WAVE_FORMAT_2M08	22.05 kHz, mono, 8-bit
WAVE_FORMAT_2M16	22.05 kHz, mono, 16-bit
WAVE_FORMAT_2S08	22.05 kHz, stereo, 8-bit
WAVE_FORMAT_2S16	22.05 kHz, stereo, 16-bit
WAVE_FORMAT_4M08	44.1 kHz, mono, 8-bit
WAVE_FORMAT_4M16	44.1 kHz, mono, 16-bit
WAVE_FORMAT_4S08	44.1 kHz, stereo, 8-bit
WAVE_FORMAT_4S16	44.1 kHz, stereo, 16-bit
}

// If Volume Control Supported
  If waveCaps.dwSupport AND WAVECAPS_VOLUME <> 0 Then
   Begin
    waveOutGetVolume(0, @Volume);
    Left  := LoWord(Volume);
    Right := HiWord(Volume);
// Show values of WAVE Device on volume control panel
    Edit2.Text := Format('Left : %d, Right : %d', [Left, Right]);
   waveOutSetVolume(0, $40008000);
   End;
end;

end.

