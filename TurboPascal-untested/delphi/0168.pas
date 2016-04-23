
Here is the poor man's version:

 procedure keybd_Event; far; external 'USER' index 289;

 procedure PostVKey(bVirtKey: byte; Up: Boolean);
 var
  AXReg,BXReg : Word;
  AXHigh, AXLow, BXHigh, BXLow : Byte;

function MakeWord(L,H: Byte): Word;
begin
  MakeWord := (H shl 8) + L;
end;
begin
  AXLow := bVirtKey;
  if up then AXHigh := $80 else AXHigh := $0;
  AXreg := MakeWord(AXLow,AXHigh);
  BXLow := VkKeyScan(bVirtKey);
  BXHigh := 0;
  BXReg := MakeWord(BXLow,BXHigh);
  asm
    mov bx,BXreg;
    mov ax,AXReg;
  end;
  Keybd_Event;
end;

then to simulate Shift+Ins you need:-

PostVKey(VK_Shift,false);
PostVKey(VK_Insert,false);
PostVKey(VK_Insert,True);
PostVKey(VK_Shift,True);

Here is the Rolls-Royce version:
Note:  This is commercial and copyrighted code.  The source code may not be sold for profit
(unless Steve is doing the selling).

{This unit is to be included in the app that you are running.}
unit SKeys;
interface
type
  { Return values for SendKeys function }
  TSendKeyError = (sk_None, sk_FailSetHook, sk_InvalidToken, sk_UnknownError);
function SendKeys(S: String): TSendKeyError;
implementation
function SendKeys; external 'SendKey' index 2;
end.
(********************************************)
{Here is the DLL that is used.}
library SendKey;
uses
 SysUtils, WinTypes, WinProcs, Messages, Classes, KeyDefs;
type
  { Error codes }
  TSendKeyError = (sk_None, sk_FailSetHook, sk_InvalidToken, sk_UnknownError);
  { exceptions }
  ESendKeyError = class(Exception);
  ESetHookError = class(ESendKeyError);
  EInvalidToken = class(ESendKeyError);
  { a TList descendant that know how to dispose of its contents }
  TMessageList = class(TList)
  public
    destructor Destroy; override;
  end;
destructor TMessageList.Destroy;
var
  i: longint;
begin
  { deallocate all the message records before discarding the list }
  for i := 0 to Count - 1 do
    Dispose(PEventMsg(Items[i]));
  inherited Destroy;
end;
var
  { variables global to the DLL }
  MsgCount: word;
  MessageBuffer: TEventMsg;
  HookHandle: hHook;
  Playing: Boolean;
  MessageList: TMessageList;
  AltPressed, ControlPressed, ShiftPressed: Boolean;
  NextSpecialKey: TKeyString;

function MakeWord(L, H: Byte): Word;
{ macro creates a word from low and high bytes }
inline(
  $5A/            { pop dx }
  $58/            { pop ax }
  $8A/$E2);       { mov ah, dl }

procedure StopPlayback;
{ Unhook the hook, and clean up }
begin
  { if Hook is currently active, then unplug it }
  if Playing then
    UnhookWindowsHookEx(HookHandle);
  MessageList.Free;
  Playing := False;
end;

function Play(Code: integer; wParam: word; lParam: Longint): Longint; export;

{ This is the JournalPlayback callback function.  It is called by Windows }
{ when Windows polls for hardware events.  The code parameter indicates what }
{ to do. }
begin
  case Code of
    hc_Skip: begin
    { hc_Skip means to pull the next message out of our list. If we }
    { are at the end of the list, it's okay to unhook the JournalPlayback }
    { hook from here. }
      { increment message counter }
      inc(MsgCount);
      { check to see if all messages have been played }
      if MsgCount >= MessageList.Count then
        StopPlayback
      else
      { copy next message from list into buffer }
      MessageBuffer := TEventMsg(MessageList.Items[MsgCount]^);
      Result := 0;
    end;
    hc_GetNext: begin
    { hc_GetNext means to fill the wParam and lParam with the proper }
    { values so that the message can be played back.  DO NOT unhook }
    { hook from within here.  Return value indicates how much time until }
    { Windows should playback message.  We'll return 0 so that it's }
    { processed right away. }
      { move message in buffer to message queue }
      PEventMsg(lParam)^ := MessageBuffer;
      Result := 0  { process immediately }
    end
    else
      { if Code isn't hc_Skip or hc_GetNext, then call next hook in chain }
      Result := CallNextHookEx(HookHandle, Code, wParam, lParam);
  end;
end;
procedure StartPlayback;
{ Initializes globals and sets the hook }
begin
  { grab first message from list and place in buffer in case we }
  { get a hc_GetNext before and hc_Skip }
  MessageBuffer := TEventMsg(MessageList.Items[0]^);
  { initialize message count and play indicator }
  MsgCount := 0;
  { initialize Alt, Control, and Shift key flags }
  AltPressed := False;
  ControlPressed := False;
  ShiftPressed := False;
  { set the hook! }
  HookHandle := SetWindowsHookEx(wh_JournalPlayback, Play, hInstance, 0);
  if HookHandle = 0 then
    raise ESetHookError.Create('Couldn''t set hook')
  else
    Playing := True;
end;
procedure MakeMessage(vKey: byte; M: word);
{ procedure builds a TEventMsg record that emulates a keystroke and }
{ adds it to message list }
var
  E: PEventMsg;
begin
  New(E);                                 { allocate a message record }
  with E^ do begin
    Message := M;                         { set message field }
    { high byte of ParamL is the vk code, low byte is the scan code }
    ParamL := MakeWord(vKey, MapVirtualKey(vKey, 0));
    ParamH := 1;                          { repeat count is 1 }
    Time := GetTickCount;                 { set time }
  end;
  MessageList.Add(E);
end;
procedure KeyDown(vKey: byte);
{ Generates KeyDownMessage }
begin
  { don't generate a "sys" key if the control key is pressed (Windows quirk) }
  if (AltPressed and (not ControlPressed) and (vKey in [Ord('A')..Ord('Z')])) or
     (vKey = vk_Menu) then
    MakeMessage(vKey, wm_SysKeyDown)
  else
    MakeMessage(vKey, wm_KeyDown);
end;
procedure KeyUp(vKey: byte);
{ Generates KeyUp message }
begin
  { don't generate a "sys" key if the control key is pressed (Windows quirk) }
  if AltPressed and (not ControlPressed) and (vKey in [Ord('A')..Ord('Z')]) then
    MakeMessage(vKey, wm_SysKeyUp)
  else
    MakeMessage(vKey, wm_KeyUp);
end;
procedure SimKeyPresses(VKeyCode: Word);
{ This function simulates keypresses for the given key, taking into }
{ account the current state of Alt, Control, and Shift keys }
begin
  { press Alt key if flag has been set }
  if AltPressed then
    KeyDown(vk_Menu);
  { press Control key if flag has been set }
  if ControlPressed then
    KeyDown(vk_Control);
  { if shift is pressed, or shifted key and control is not pressed... }
  if (((Hi(VKeyCode) and 1) <> 0) and (not ControlPressed)) or ShiftPressed then
    KeyDown(vk_Shift);    { ...press shift }
  KeyDown(Lo(VKeyCode));  { press key down }
  KeyUp(Lo(VKeyCode));    { release key }
  { if shift is pressed, or shifted key and control is not pressed... }
  if (((Hi(VKeyCode) and 1) <> 0) and (not ControlPressed)) or ShiftPressed then
    KeyUp(vk_Shift);      { ...release shift }
  { if shift flag is set, reset flag }
  if ShiftPressed then begin
    ShiftPressed := False;
  end;
  { Release Control key if flag has been set, reset flag }
  if ControlPressed then begin
    KeyUp(vk_Control);
    ControlPressed := False;
  end;
  { Release Alt key if flag has been set, reset flag }
  if AltPressed then begin
    KeyUp(vk_Menu);
    AltPressed := False;
  end;
end;
procedure ProcessKey(S: String);
{ This function parses each character in the string to create the message list }
var
  KeyCode: word;
  Key: byte;
  index: integer;
  Token: TKeyString;
begin
  index := 1;
  repeat
    case S[index] of
      KeyGroupOpen : begin
      { It's the beginning of a special token! }
        Token := '';
        inc(index);
        while S[index] <> KeyGroupClose do begin
          { add to Token until the end token symbol is encountered }
          Token := Token + S[index];
          inc(index);
          { check to make sure the token's not too long }
          if (Length(Token) = 7) and (S[index] <> KeyGroupClose) then
            raise EInvalidToken.Create('No closing brace');
        end;
        { look for token in array, Key parameter will }
        { contain vk code if successful }
        if not FindKeyInArray(Token, Key) then
          raise EInvalidToken.Create('Invalid token');
        { simulate keypress sequence }
        SimKeyPresses(MakeWord(Key, 0));
      end;
      AltKey : begin
        { set Alt flag }
        AltPressed := True;
      end;
      ControlKey : begin
        { set Control flag }
        ControlPressed := True;
      end;
      ShiftKey : begin
        { set Shift flag }
        ShiftPressed := True;
      end;
      else begin
      { A normal character was pressed }
        { convert character into a word where the high byte contains }
        { the shift state and the low byte contains the vk code }
        KeyCode := vkKeyScan(MakeWord(Byte(S[index]), 0));
        { simulate keypress sequence }
        SimKeyPresses(KeyCode);
      end;
    end;
    inc(index);
  until index > Length(S);
end;
function SendKeys(S: String): TSendKeyError; export;
{ This is the one entry point.  Based on the string passed in the S  }
{ parameter, this function creates a list of keyup/keydown messages, }
{ sets a JournalPlayback hook, and replays the keystroke messages.   }
var
  i: byte;
begin
  try
    Result := sk_None;                   { assume success }
    MessageList := TMessageList.Create;  { create list of messages }
    ProcessKey(S);                       { create messages from string }
    StartPlayback;                       { set hook and play back messages }
  except
    { if an exception occurs, return an error code, and clean up }
    on E:ESendKeyError do begin
      MessageList.Free;
      if E is ESetHookError then
        Result := sk_FailSetHook
      else if E is EInvalidToken then
        Result := sk_InvalidToken;
    end
    else
      { Catch-all exception handler ensures than an exception }
      { doesn't walk up into application stack }
      Result := sk_UnknownError;
  end;
end;
exports
  SendKeys index 2;
begin
end.

(********************************************)
unit Keydefs;
interface
uses WinTypes;
const
  MaxKeys = 24;
  ControlKey = '^';
  AltKey = '@';
  ShiftKey = '~';
  KeyGroupOpen = '{';
  KeyGroupClose = '}';
type
  TKeyString = String[7];
  TKeyDef = record
    Key: TKeyString;
    vkCode: Byte;
  end;
const
  KeyDefArray : array[1..MaxKeys] of TKeyDef = (
    (Key: 'F1';     vkCode: vk_F1),
    (Key: 'F2';     vkCode: vk_F2),
    (Key: 'F3';     vkCode: vk_F3),
    (Key: 'F4';     vkCode: vk_F4),
    (Key: 'F5';     vkCode: vk_F5),
    (Key: 'F6';     vkCode: vk_F6),
    (Key: 'F7';     vkCode: vk_F7),
    (Key: 'F8';     vkCode: vk_F8),
    (Key: 'F9';     vkCode: vk_F9),
    (Key: 'F10';    vkCode: vk_F10),
    (Key: 'F11';    vkCode: vk_F11),
    (Key: 'F12';    vkCode: vk_F12),
    (Key: 'INSERT'; vkCode: vk_Insert),
    (Key: 'DELETE'; vkCode: vk_Delete),
    (Key: 'HOME';   vkCode: vk_Home),
    (Key: 'END';    vkCode: vk_End),
    (Key: 'PGUP';   vkCode: vk_Prior),
    (Key: 'PGDN';   vkCode: vk_Next),

    (Key: 'TAB';    vkCode: vk_Tab),
    (Key: 'ENTER';  vkCode: vk_Return),
    (Key: 'BKSP';   vkCode: vk_Back),
    (Key: 'PRTSC';  vkCode: vk_SnapShot),
    (Key: 'SHIFT';  vkCode: vk_Shift),
    (Key: 'ESCAPE'; vkCode: vk_Escape));

function FindKeyInArray(Key: TKeyString; var Code: Byte): Boolean;
implementation
uses SysUtils;
function FindKeyInArray(Key: TKeyString; var Code: Byte): Boolean;
{ function searches array for token passed in Key, and returns the }
{ virtual key code in Code. }
var
  i: word;
begin
  Result := False;
  for i := Low(KeyDefArray) to High(KeyDefArray) do
    if UpperCase(Key) = KeyDefArray[i].Key then begin
      Code := KeyDefArray[i].vkCode;
      Result := True;
      Break;
    end;
end;
end.
