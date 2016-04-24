(*
  Category: SWAG Title: SOUNDBLASTER/ADLIB/SPEAKER ROUTINES
  Original name: 0106.PAS
  Description: Another Complete CDROM sound unit
  Author: YUVAL MELAMED
  Date: 05-30-97  18:17
*)

(*
  compiler...Turbo-Pascal 7.0.
  source.....Enhanced CD-ROM Audio control unit.
  requires...CD-ROM w/ MSCDEX.EXE v2.10+ loaded, 386+.
  coded by...Yuval Melamed (Email: variance@inter.net.il)
  credits....Ralf Brown's Interrupt List 48.
  modified...03-Mar-1997, 17:58.
*)

{$A-,D-,G+,I-,L-,S-,R-,T-}
unit CDAudio;

interface

type
  (* User interface basic type - time representor: *)
  TMSF = record {<T>rack, <M>inutes, <S>econds, <F>rames}
    (* Order was reversed (FSMT) to match the Red book format: *)
    Frm,        {frame, 1/75 of a second}
    Sec, Min,   {seconds, minutes}
    Trk : Byte; {track, or 0 to represent disc time, or 0/1 as audio/data}
  end;
  (* the TrkArr is actually used only as a pointer in DiscRec record.
     the MSF part - location of track on disc.
     the T (Trk field) is 1 for data track track, 0 for audio.        *)
  TrkArr = array[01..99] of TMSF;
  (* Use this type to represent a whole disc, and compare between discs: *)
  DiscRec = record
    Length : TMSF;   {disc's length in [MSF], number of tracks in Trk field}
    Track : ^TrkArr; {TMSF(s), track length [MSF]/data-flags [T]}
  end;

var
  (* System variables, initialized when unit starts: *)
  NumCDDrv : Byte;                  {number of CD-ROM drives}
  DrvList : array[1..8] of Char;    {drive letters list}
  FstCDDrv : Char absolute DrvList; {first CD-ROM drive letter}
  MSCDEXVer : Real;                 {MSCDEX.EXE version, 0 for none}
  (* The following const actually points to the first byte of the real-
     typed MSCDEXVer - if none (0.00), than the boolean is considered to
     be false. Else (even if major or minor are zero), it returns true.  *)
  MSCDEXLoaded : Boolean absolute MSCDEXVer;

const
  (* Current-drive parameter (change drive only by ChangeCDROMDrv): *)
  CurCDDrv : 0..9 = 0; {current cd-rom drive to work with (user variable)}
  (* Returned values for comparison of two TMSF's: *)
  SameTime = 0; {means that the TMSF's are equal}
  SuccTime = 1; {means that the first TMSF is bigger than the first}
  PredTime = 2; {means that the first is smaller}

(* Drive status/capabilities functions: *)
function DoorOpen : Boolean;   {is door open?}
function Locked : Boolean;     {is door locked?}
function NoDisc : Boolean;     {is drive empty?}
function DrvBusy : Boolean;    {is drive busy? (mostly playing)}
function InPause : Boolean;    {is audio in pause?}
function AudVolume : Byte;     {what's the audio channels' volume?}
function Writable : Boolean;   {does the drive writable?}
function SuppAudVid : Boolean; {does it support audio/video tracks?}
function SuppAudChn : Boolean; {does it support audio channels? (volume)}

(* Disc/audio current information: *)
procedure GetDiscInfo(var Info : DiscRec);          {not neccessary!, user's}
procedure GetDiscLen(var DLen {: TMSF});            {get disc length/tracks}
procedure GetTrkLoc(var TLoc {: TMSF}; Trk : Byte); {get track's location}
procedure GetTrkLen(var TLen : TMSF; Trk : Byte);   {get length of track}
procedure CurDiscPos(var DPos {: TMSF});            {get disc position}
procedure CurTrkPos(var TPos {: TMSF});             {get track position}
procedure GetDiscRem(var DRem : TMSF);              {get disc remaining time}
procedure GetTrkRem(var TRem : TMSF);               {get track remain. time}

(* CD-ROM drive commands: *)
procedure EjectDoor;               {eject tray out, if not locked}
procedure InsertDoor;              {insert tray inside}
procedure LockDoor;                {lock tray (no eject till reboot/unlock)}
procedure UnlockDoor;              {unlock the tray}
procedure SetVolume(Vol : Byte);   {set all audio channel's volume}

(* Play/pause/resume procedures: *)
procedure PlayFrom(From : TMSF);           {play from specified till end}
procedure PlayRange(From, Till : TMSF);    {play specified range}
procedure PlayAmount(From, Amount : TMSF); {play from spec., amount spec.}
procedure PlayTrack(TrkNum : Byte);        {play spec. track, till disc end}
procedure PlaySingle(TrkNum : Byte);       {play spec. track, till track end}
procedure PlayPrevTrk;                     {play pervious track to current}
procedure PlayNextTrk;                     {play next track to current}
procedure PlayReverse(Skip : TMSF);        {play from current - specified}
procedure PlayForward(Skip : TMSF);        {play from current + specified}
procedure PauseAudio;                      {pause current audio if playing}
procedure ResumeAudio;                     {resume audio, only if paused}

(* Utility functions, for both user, and other procedures: *)
procedure SetTMSF(var Dest {: TMSF}; T, M, S, F : Byte); {generate TMSF}
procedure AddTMSF(var Dest {: TMSF}; Src : TMSF);        {2 TMSF's sum}
procedure SubTMSF(var Dest {: TMSF}; Src : TMSF);        {2 TMSF's diff.}
function CompTMSF(FstTime, SndTime : TMSF) : Byte;       {2 TMSF's relation}
procedure DiscTime(var Dest : TMSF);                     {track to disc time}
procedure TrkTime(var Dest : TMSF);                      {disc to track time}
procedure ChangeCDROMDrv(Drv : Byte);                    {change cur. drive}
function SameDisc(var Dest, Src {: DiscRec}) : Boolean;  {compare 2 DiscRec}

implementation

(* --- Internal variables, procedures and functions (hidden to user): --- *)

var
  (* Device request header (at maximum used size):
     (although the size is different every call, this variable wasn't
     programmed to be local, in order to gain speed when using calls,
     and overall, it also saves memory.
     ofs / size  / description
     ---   ----    -----------
     00h   byte    length of block (unused for CD-ROM).
     01h   byte    subunit within device driver (set automaticly).
     02h   byte    command code (request specifier).
     03h   word    status (filled by device driver).
     05h   8byte   unused/reserved by DOS.
     ---case command codes: 03h, 0Ch (IOCTL input/output)---
     0Dh   byte    media descriptor (unused for CD-ROM).
     0Eh   dword   transfer address (of IOCTL block).
     12h   word    (call) number of bytes to read/write (unused).
                   (ret.) actuall number read/written.
     ---case command code: 84h (CD-ROM play)---
     0Dh   byte    addressing mode (see above).
     0Eh   dword   starting sector number.
     12h   dword   number of sectors to play.
     ---case command codes: 85h, 88h (CD-ROM pause/resume)---
     no further fields.                                               *)
  Request : array[$00..$15] of Byte; {multi-porpose block (see above)}
  (* Transfer buffer (holds information of IOCTL input/output):
     first byte is always function, rest is data. see at the procedures
     and functions for more details.                                    *)
  TBuff : array[$00..$0A] of Byte;   {multi-porpose buffer}
  (* This drive letter, is the actuall number of default CD-ROM drive,
     in word format, to make interrupt calls faster.                   *)
  CurDrive : Word;                   {drive's letter (0=A, 1=B, ...)}
  (* Play start-address and number of sectors to play. these are -
     temporary variables to PFrom^ & PCount^ (see const below), because
     the 'Request' fields may not be ready to use directly before the
     actuall play request.                                              *)
  PFromT, PCountT : TMSF;            {play from, play count}

const
  (* Play start-address and number of sectors to play.
     declared as pointers, to be addressed at Request's offsets -
     0Eh and 10h when using command code 84h (see above).
     this method saves some code, and makes code easily readable: *)
  PFrom : ^Longint = @Request[$0E];  {play from}
  PCount : ^Longint = @Request[$12]; {play count}

(* Red book format: frame/second/minute/unused, and
   TMSF format : frame/second/minute/track - convertor to:
   HSG format: minute * 4500 + seconds * 75 + frame - 150.
   the "- 150" was dropped in the procedure, because all the unit
   automaticly handles the 150 frames difference (2sec). *)
function HSG(RedBook : TMSF) : Longint; assembler;
asm
      mov     cl,byte ptr RedBook   {get frames field}
      xor     ch,ch                 {clear high byte - CX=CL}
      mov     ah,byte ptr RedBook+1 {get seconds field}
      mov     dl,byte ptr RedBook+2 {get minutes field}
      xor     dh,dh                 {clear high byte - DX=DL}
      mov     al,75                 {multiply seconds by 75}
      mul     ah                    {place result in AX}
      add     cx,ax                 {add seconds*75 to frames}
      mov     ax,4500               {multiply minutes by 4500}
      mul     dx                    {place result at DX:AX}
      add     ax,cx                 {add seconds*75+frames to result}
      adc     dx,0                  {make sure result stays dword}
end;

(* IOCTL input call procedure. It is used only within the code of other
   procedures, to minimize the generated code. Speed lost due to the -
   'call' command is absolutely superflouos for that case.              *)
procedure InputRequest; assembler;
asm
      mov     ax,1510h                          {mscdex service}
      mov     bx,seg Request                    {request segment}
      mov     es,bx                             {segreg assignment}
      mov     bx,offset Request                 {request offset}
      mov     byte ptr es:[bx+2],03h            {command code}
      mov     cx,CurDrive                       {drive letter}
      mov     word ptr es:[bx+0Eh],offset TBuff {transfer offset}
      mov     word ptr es:[bx+10h],seg TBuff    {transfer segment}
      int     2Fh                               {send device driver request}
end;

(* IOCTL output command procedure, to use inside unit's procedures. *)
procedure OutputRequest; assembler;
asm
      mov     ax,1510h                          {mscdex service}
      mov     bx,seg Request                    {request segment}
      mov     es,bx                             {segreg assignment}
      mov     bx,offset Request                 {request offset}
      mov     byte ptr es:[bx+2],0Ch            {command code}
      mov     cx,CurDrive                       {drive letter}
      mov     word ptr es:[bx+0Eh],offset TBuff {transfer offset}
      mov     word ptr es:[bx+10h],seg TBuff    {transfer segment}
      int     2Fh                               {send device driver request}
end;

(* Control-Block command for the MSCDEX driver. This procedure is also
   used within other procedures, to minimize the total unit's code.    *)
procedure PlayRequest; assembler;
asm
      mov     ax,1510h               {mscdex service}
      mov     bx,seg Request         {request segment}
      mov     es,bx                  {segreg assignment}
      mov     bx,offset Request      {request offset}
      mov     byte ptr es:[bx+2],84h {command code}
      mov     byte ptr es:[di+0Dh],0 {HSG addressing mode}
      mov     cx,CurDrive            {drive letter}
      int     2Fh                    {send device request}
end;

(* Device status (door state/drive capabilities/etc...). *)
function DeviceStatus : Word; assembler;
asm
      mov     byte ptr TBuff,06h                {function}
      call    InputRequest                      {make IOCTL input call}
      mov     ax,word ptr TBuff+1               {result - low status word}
end;

(* Q-Sub audio channels information (current track-time, and disc-time). *)
procedure ReqQSubAudChnInfo; assembler;
asm
      mov     byte ptr TBuff,0Ch                {function}
      call    InputRequest                      {make IOCTL input call}
      mov     bh,byte ptr TBuff+2               {get track}
      mov     cl,bh                             {save (temp)}
      and     bh,0Fh                            {get units digit}
      shr     cl,4                              {get decimals digit}
      mov     al,10                             {multiply decimals by 10}
      mul     cl                                {get result}
      add     bh,al                             {add units to decimals*10}
end;

(* ----- Interface-declared procedures and functions: ----- *)

(* True - door is open, false - door is closed. *)
function DoorOpen : Boolean; assembler;
asm
      call    DeviceStatus {get current device status}
      and     al,1 shl 0   {check bit 0 of status}
end;

(* True - door is locked, false - door is unlocked. *)
function Locked : Boolean; assembler;
asm
      call    DeviceStatus {get current device status}
      not     al           {reverse bits values - opposite of unlocked}
      and     al,1 shl 1   {check bit 1 of status}
end;

(* True - drive is empty, false - disc present. *)
function NoDisc : Boolean; assembler;
asm
      call    DeviceStatus {get current device status}
      mov     al,ah        {transfer high byte of status to function result}
      and     al,1 shl 3   {check bit 11 of status (bit 3 of high byte)}
end;

(* True - drive is busy (mostly playing), false - drive's busy-led is off. *)
function DrvBusy : Boolean; assembler;
asm
      call    DeviceStatus          {only to update status word of Request}
      mov     al,byte ptr Request+4 {status word's high byte}
      and     al,1 shl 1            {check bit 9 of status (1 of high byte)}
end;

(* True - audio is paused, false - unpaused (unneccessarily playing!). *)
function InPause : Boolean; assembler;
asm
      mov     byte ptr TBuff,0Fh  {function}
      call    InputRequest        {make IOCTL input request}
      mov     al,byte ptr TBuff+1 {result - low status word}
end;

(* Drive's volume (left audio channel's volume, presuming rest are same). *)
function AudVolume : Byte; assembler;
asm
      mov     byte ptr TBuff,04h  {function}
      call    InputRequest        {make IOCTL input request}
      mov     al,byte ptr TBuff+2 {result - left chn's volume}
end;

(* True - drive can write discs, false - read only (CDROM). *)
function Writable : Boolean; assembler;
asm
      call    DeviceStatus {get current device status}
      and     al,1 shl 3   {check bit 3 of status}
end;

(* True - drive can play audio/video tracks, false - can't. *)
function SuppAudVid : Boolean; assembler;
asm
      call    DeviceStatus {get current device status}
      and     al,1 shl 4   {check bit 4 of status}
end;

(* True - drive supports audio channels control, false - doesn't. *)
function SuppAudChn : Boolean; assembler;
asm
      call    DeviceStatus {get current device status}
      mov     al,ah        {transfer high byte of status to function result}
      and     al,1 shl 0   {check bit 8 of status (0 of low byte)}
end;

(* Disposes old tracks data field, if any, get disc tracks count & length,
   allocate new tracks field, and fill with tracks' parameters.            *)
procedure GetDiscInfo(var Info : DiscRec);
var
  Trk : Byte;                                   {track index}
begin
	if Info.Track <> nil then                     {if DiscRec defined -}
  	FreeMem(Info.Track, Info.Length.Trk shl 2); {- then free occupied memory}
	GetDiscLen(Info.Length);                      {get disc length}
  GetMem(Info.Track, Info.Length.Trk shl 2);    {allocate memory}
  for Trk := 1 to Info.Length.Trk do            {cycle through all tracks}
    GetTrkLen(Info.Track^[Trk], Trk);           {get track's length}
end;

(* Disc length in global TMSF variable (actually: leadout-2sec),
   number of tracks, in TMSF's Trk field.                        *)
procedure GetDiscLen(var DLen {: TMSF} ); assembler;
asm
      mov     byte ptr TBuff,0Ah                {function}
      call    InputRequest                      {make IOCTL input call}
      mov     bh,byte ptr TBuff+2               {get last track (=count)}
      mov     ax,word ptr TBuff+3               {get farames & seconds}
      mov     bl,byte ptr TBuff+5               {get minutes}
      sub     ah,2                              {subtract 2sec to get length}
      jns     @Return                           {adjust if < 0}
      add     ah,60                             {make Sec field to 59, or 58}
      dec     bl                                {decrease Min}
@Return:
      les     di,DLen                           {address of global variable}
      mov     es:[di],ax                        {copy: Frm, Sec}
      mov     es:[di+2],bx                      {copy: Min, Trk}
end;

(* Get track's starting address on disc into global TMSF,
   and sets Trk field to 1 if data track, or to 0 if audio track. *)
procedure GetTrkLoc(var TLoc {: TMSF}; Trk : Byte); assembler;
asm
      mov     byte ptr TBuff,0Bh                {function}
      mov     al,Trk                            {get track}
      mov     byte ptr TBuff+1,al               {requested track}
      call    InputRequest                      {make IOCTL input call}
      mov     ax,word ptr TBuff+2               {get farames & seconds}
      mov     bl,byte ptr TBuff+4               {get minutes}
      mov     bh,byte ptr TBuff+6               {get control info}
      and     bh,1 shl 6                        {check bit 6 - data track?}
      shr     bh,6                              {make 0 or 1, acco. to bit}
      sub     ah,2                              {subtract 2sec to adj. loc.}
      jns     @Return                           {adjust if < 0}
      add     ah,60                             {make Sec field to 59, or 58}
      dec     bl                                {decrease Min}
@Return:
      les     di,TLoc                           {address of global variable}
      mov     es:[di],ax                        {copy: Frm, Sec}
      mov     es:[di+2],bx                      {copy: Min, Trk}
end;

(* Track's length in a global TMSF variable.
   Trk field, is set then to 1 if data track, 0 if audio. *)
procedure GetTrkLen(var TLen : TMSF; Trk : Byte);
var
  TLoc : TMSF;               {track location}
begin
  GetTrkLoc(TLen, Trk);      {start address of track}
  GetDiscLen(TLoc);          {get disc length}
  if Trk < TLoc.Trk then     {if track is last, location=disc length}
    GetTrkLoc(TLoc, Trk+1);  {get successor's location}
  SubTMSF(TLen, TLoc);       {place diff. (length) in result}
end;

(* Get current disc time, and current track (at Trk field).
   note: device returns track number at hexa-view, means that track -
   10 for example, won't be 0Ah (10d), but 10h. that is why this proc. -
   has a code to make it the correct track number.
   [ track := (track shr 4) * 10 + (track and 0Fh) ].                    *)
procedure CurDiscPos(var DPos {: TMSF} ); assembler;
asm
      call    ReqQSubAudChnInfo                 {get current positions}
      mov     bl,byte ptr TBuff+8               {get minutes}
      mov     ah,byte ptr TBuff+9               {get seconds}
      mov     al,byte ptr TBuff+0Ah             {get frames}
      sub     ah,2                              {subtract 2sec to adj. pos.}
      jns     @Return                           {adjust if < 0}
      add     ah,60                             {make Sec field to 59, or 58}
      dec     bl                                {decrease Min}
@Return:
      les     di,DPos                           {address of global variable}
      mov     es:[di],ax                        {copy: Frm, Sec}
      mov     es:[di+2],bx                      {copy: Min, Trk}
end;

(* Get current track time, and current track (at Trk field).
   (same manner as CurDiscTime).                             *)
procedure CurTrkPos(var TPos {: TMSF} ); assembler;
asm
      call    ReqQSubAudChnInfo                 {get current positions}
      mov     bl,byte ptr TBuff+4               {get minutes}
      mov     ah,byte ptr TBuff+5               {get seconds}
      mov     al,byte ptr TBuff+6               {get frames}
      les     di,TPos                           {address of global variable}
      mov     es:[di],ax                        {copy: Frm, Sec}
      mov     es:[di+2],bx                      {copy: Min, Trk}
end;

(* Get current disc remaining time, and current track (at Trk field). *)
procedure GetDiscRem(var DRem : TMSF);
var
  DLen : TMSF;          {disc length}
begin
  GetDiscLen(DLen);     {get disc length}
  CurDiscPos(DRem);     {get current disc position}
  SubTMSF(DRem, DLen);  {find difference (= remaining disc time)}
end;

(* Get current track remaining time, and current track (at Trk field). *)
procedure GetTrkRem(var TRem : TMSF);
var
  TLen : TMSF;               {track length}
begin
  GetTrkLen(TLen, TRem.Trk); {get current track's length}
  CurTrkPos(TRem);           {get current track position}
  SubTMSF(TRem, TLen);       {find difference (= remaining track time)}
end;

(* If door is unlocked, pause audio if playing, and eject tray out. *)
procedure EjectDoor; assembler;
asm
      call    PauseAudio         {pause audio}
      mov     byte ptr TBuff,00h {function}
      call    OutputRequest      {make IOCTL output call}
end;

(* Insert tray inside drive. *)
procedure InsertDoor; assembler;
asm
      mov     byte ptr TBuff,05h {function}
      call    OutputRequest      {make IOCTL output call}
end;

(* Locks the door inside the drive (no eject, even with external button).
	 Door remains locked until cold boot/unlock function call/device reset. *)
procedure LockDoor; assembler;
asm
      mov     word ptr TBuff,0101h {function}
      call    OutputRequest        {make IOCTL output call}
end;

(* This call unlocks locked door. *)
procedure UnlockDoor; assembler;
asm
      mov     word ptr TBuff,0001h {function}
      call    OutputRequest        {make IOCTL output call}
end;

procedure SetVolume(Vol : Byte); assembler;
asm
      mov     byte ptr TBuff,03h  {function}
      xor     al,al               {start at channel 0}
      mov     ah,Vol              {volume - user input}
      mov     word ptr TBuff+1,ax {left}
      inc     al                  {next channel}
      mov     word ptr TBuff+3,ax {right}
      inc     al                  {next channel}
      mov     word ptr TBuff+5,ax {left prime}
      inc     al                  {next channel}
      mov     word ptr TBuff+7,ax {right prime}
      call    OutputRequest       {make IOCTL output call}
end;

(* Plays regardless of current audio status (playing or not), from
   specified location until end of disc.
   user can input the start address by disc time, or by track time
   as he wishes, representing disc time by a zero Trk field.       *)
procedure PlayFrom(From : TMSF);
begin
  PauseAudio;                           {interrupt playing}
  GetDiscLen(PCountT);                  {disc length}
  if From.Trk <> 0 then DiscTime(From); {make disc timing}
  PFrom^ := HSG(From);                  {start address}
  PCount^ := HSG(PCountT) - PFrom^;     {count of sectors}
  PlayRequest;                          {make play request}
end;

(* Play specified range, interrupts current playing if needed.
   same manner of input as previous procedure (see above).     *)
procedure PlayRange(From, Till : TMSF);
begin
  PauseAudio;                           {interrupt playing}
  if From.Trk <> 0 then DiscTime(From); {make disc timing}
  if Till.Trk <> 0 then DiscTime(Till); {make disc timing}
	PFrom^ := HSG(From);                  {start address}
  PCount^ := HSG(Till) - PFrom^;        {count of sectors}
  PlayRequest;                          {make play request}
end;

(* Plays specified amount of sectors from specified start address.
   only start address can be either travk time or disc time, but amount
   must be [MSF] value (Trk field ignored).                             *)
procedure PlayAmount(From, Amount : TMSF);
begin
  PauseAudio;                           {interrupt playing}
  if From.Trk <> 0 then DiscTime(From); {make disc timing}
  PFrom^ := HSG(From);                  {start address}
  PCount^ := HSG(Amount);               {count of sectors}
  PlayRequest;                          {make play request}
end;

(* Interrupt current playing and play specified track, until end of disc.
   request will be ignored if track is data track, and if audio was -
   playing, it won't be stopped.                                          *)
procedure PlayTrack(TrkNum : Byte);
begin
  GetTrkLoc(PFromT, TrkNum);               {get track location}
  if PFromT.Trk = 0 then PlayFrom(PFromT); {play if audio track}
end;

(* Same as above procedure, but plays until end of track. *)
procedure PlaySingle(TrkNum : Byte);
begin
  GetTrkLoc(PFromT, TrkNum);                          {get track location}
  GetTrkLen(PCountT, TrkNum);                         {get track length}
  if PFromT.Trk = 0 then PlayAmount(PFromT, PCountT); {play if audio track}
end;

(* Plays the predecessor track to current, or last track if current
   track is the first track.                                        *)
procedure PlayPrevTrk;
begin
  CurTrkPos(PFromT);                       {get current track}
  if PFromT.Trk = 1 then                   {check current}
  begin                                    {if first track -}
    GetDiscLen(PCount^);                   {get disc length}
    PFromT.Trk := PCountT.Trk;             {play last}
  end
  else                                     {if not -}
    Dec(PFromT.Trk);                       {previous track}
  GetTrkLoc(PFromT, PFromT.Trk);           {get new track loc.}
  if PFromT.Trk = 0 then PlayFrom(PFromT); {play if audio track}
end;

(* Plays the successor track to current, or first track if current
   track is the last track.                                        *)
procedure PlayNextTrk;
begin
  GetDiscLen(PCountT);                     {get disc length}
  CurTrkPos(PFromT);                       {get current track}
  if PFromT.Trk = PCountT.Trk then         {check current}
    PFromT.Trk := 1                        {first if was last}
  else                                     {if not -}
    Inc(PFromT.Trk);                       {next track}
  GetTrkLoc(PFromT, PFromT.Trk);           {get new track loc.}
  if PFromT.Trk = 0 then PlayFrom(PFromT); {play if audio track}
end;

(* Use [MSF] input to force playing from current location minus the
   amount given, till end of disc.                                  *)
procedure PlayReverse(Skip : TMSF);
begin
  CurDiscPos(PFromT);    {get current position}
  SubTMSF(PFromT, Skip); {subtract requested amount}
  PFromT.Trk := 0;       {make disc time}
  PlayFrom(PFromT);      {play from new location}
end;

(* Use [MSF] input to force playing from current location plus the
   amount given, till end of disc.                                 *)
procedure PlayForward(Skip : TMSF);
begin
	CurDiscPos(PFromT);    {get current position}
  AddTMSF(PFromT, Skip); {add requested amount}
  PFromT.Trk := 0;       {make disc time}
  PlayFrom(PFromT);      {play from new location}
end;

(* Pauses current audio if playing, if not playing - ignored.
   This is actually the STOP command, as it has the same effect. *)
procedure PauseAudio; assembler;
asm
      mov     ax,1510h               {mscdex service}
      mov     bx,seg Request         {request segment}
      mov     es,bx                  {segreg assignment}
      mov     bx,offset Request      {request offset}
      mov     byte ptr es:[bx+2],85h {command code}
      mov     cx,CurDrive            {drive letter}
      int     2Fh                    {send device driver request}
end;

(* Resumes paused audio only (faster than PlayAudio). *)
procedure ResumeAudio; assembler;
asm
      mov     ax,1510h                          {mscdex service}
      mov     bx,seg Request                    {request segment}
      mov     es,bx                             {segreg assignment}
      mov     bx,offset Request                 {request offset}
      mov     byte ptr es:[bx+2],88h            {command code}
      mov     cx,CurDrive                       {drive letter}
      int     2Fh                               {send device driver request}
end;

(* This procedure makes easier when trying to assign a full time
   into TMSF variable. that way, your code will consume one text line,
   instead of four record-field assignment clauses.                    *)
procedure SetTMSF(var Dest {: TMSF}; T, M, S, F : Byte); assembler;
asm
      mov     al,F         {get frames}
      mov     ah,S         {get seconds}
      mov     bl,M         {get minutes}
      mov     bh,T         {get track}
      les     di,Dest      {get global variable's address}
      mov     es:[di],ax   {copy: Frm, Sec}
      mov     es:[di+2],bx {copy: Min, Trk}
end;

(* Adds source TMSF value to destination, ignoring Trk field. *)
procedure AddTMSF(var Dest {: TMSF}; Src : TMSF); assembler;
asm
      les     di,Dest            {get global address}
      mov     al,byte ptr Src    {get source frames}
      add     al,es:[di]         {add destination frames to source's}
      cmp     al,75              {compare with maximum frames value}
      jb      @Frames            {jump if below}
      sub     al,75              {subtract 75 frames}
      inc     byte ptr es:[di+1] {add 1 second to "pay" the 75 frames}
@Frames:
      mov     es:[di],al         {copy: Frm}
      mov     al,byte ptr Src+1  {get source seconds}
      add     al,es:[di+1]       {add destination seconds to source's}
      cmp     al,60              {compare with maximum seconds value}
      jb      @Seconds           {jump if below}
      sub     al,60              {subtract 60 seconds}
      inc     byte ptr es:[di+2] {add 1 minute to "pay" the 60 seconds}
@Seconds:
      mov     es:[di+1],al       {copy: Sec}
      mov     al,byte ptr Src+2  {get source's minutes}
      add     es:[di+2],al       {copy: Min (sum of destination+source)}
end;

(* Subtracts source TMSF value from destination, ignoring Trk field.
   returned value is difference, no sign is assigned.                *)
procedure SubTMSF(var Dest {: TMSF}; Src : TMSF); assembler;
asm
      les     di,Dest           {get global destination address}
      mov     al,es:[di]        {get destination's frames}
      mov     bx,es:[di+1]      {get destination's seconds & minutes}
      mov     cl,byte ptr Src   {get source's frames}
      mov     dx,word ptr Src+1 {get source's seconds & minutes}
      cmp     bx,dx             {compare dest's minutes to src's}
      ja      @SubMin           {below/above/equal: jump if above}
      jb      @XchgTMSF         {below/equal: jump if below}
      cmp     al,cl             {equal: compare dest's frames to src's}
      ja      @SubMin           {below/above/equal: jump if above}
      jb      @XchgTMSF         {below/equal: jump if below}
      xor     al,al             {equal: make frames zero}
      xor     bx,bx             {equal: make seconds & minutes zero}
      jmp     @Return           {return result}
@XchgTMSF:
      xchg    al,cl             {exchange frames}
      xchg    bx,dx             {exchange seconds & minutes}
@SubMin:
      sub     bh,dh             {subtract src's minutes from dest's, ≥ 0}
      cmp     bl,dl             {compare dest's seconds to src's}
      jae     @SubSec           {below/above/equal: jump if above or equal}
      add     bl,60             {below: add 1 minute by 60 seconds}
      dec     bh                {below: subtract 1 minute (minutes were > 0)}
@SubSec:
      sub     bl,dl             {subtract src's seconds from dest's, ≥ 0}
      cmp     al,cl             {compare dest's minutes to src's}
      jae     @SubFrm           {below/above/equal: jump if above or equal}
      add     al,75             {below: add 1 second by 75 frames}
      dec     bl                {below: subtract 1 sec., and check its sign}
      jns     @SubFrm           {positive/negative/zero: jump if not neg.}
      mov     bl,59             {negative (-1): make 59 seconds}
      dec     bh                {negative (-1): subtract 1 minute (were > 0)}
@SubFrm:
      sub     al,cl             {subtract src's frames from dest's, ≥ 0}
@Return:
      mov     es:[di],al        {copy: Frm}
      mov     es:[di+1],bx      {copy: Sec, Min (never touch the Trk field)}
end;

(* Compares two TMSF records, and return their relation: If both represent
   the same time, it returns 0, which has a const named 'SameTime',
   1 means that the first TMSF is successor, and the const is 'SuccTime',
   2 means that the second record is bigger, therefore the fisrt is -
   predecessor to the second, and the const is: 'PredTime'.
   The procedure handles all combination of disc-time and track-time.      *)
function CompTMSF(FstTime, SndTime : TMSF) : Byte;
begin
  if FstTime.Trk <> 0 then DiscTime(FstTime); {deal with absolute time}
  if SndTime.Trk <> 0 then DiscTime(SndTime); {make sure both are abs.}
  if Longint(FstTime) > Longint(SndTime) then {check if first is bigger}
    CompTMSF := SuccTime;                     {if so, return const value}
  if Longint(FstTime) < Longint(SndTime) then {check if first is smaller}
    CompTMSF := PredTime;                     {if so, report by const}
  if Longint(FstTime) = Longint(SndTime) then {same? (least chances)}
    CompTMSF := SameTime;                     {report by const value 0}
end;

(* Converts given track time (including the track number in Trk field),
   to postion in global disc timing.                                    *)
procedure DiscTime(var Dest : TMSF);
var
  TLoc : TMSF;               {track location}
begin
  GetTrkLoc(TLoc, Dest.Trk); {get given track location}
  AddTMSF(Dest, TLoc);       {add track location to time into track}
  Dest.Trk := 0;             {indicate 'disc-time'}
end;

(* Converts given disc time (ignoring Trk field), into track time, placing
   the track number which falls in that given position, and the time into
   the track, when being at this position on disc.                         *)
procedure TrkTime(var Dest : TMSF);
var
  Upper, Lower, Middle : Byte;                           {for binary search}
  Disc, Trk : TMSF;                                      {disc & track times}
begin
  Dest.Trk := 0;                                         {clear highest byte}
  GetDiscLen(Disc);                                      {get disc length}
  GetTrkLoc(Trk, Disc.Trk);                              {get last trk' loc.}
  if Longint(Dest) >= (Longint(Trk) and $FFFFFF) then    {lower than given?}
    Dest.Trk := Disc.Trk;                                {if so - last track}
  if (Disc.Trk > 1) and (Dest.Trk = 0) then              {is there track 2?}
  begin
    GetTrkLoc(Trk, 2);                                   {get track location}
    if Longint(Dest) < (Longint(Trk) and $FFFFFF) then   {higher than given?}
    begin
      Dest.Trk := 1;                                     {if so - 1st track}
      GetTrkLoc(Trk, 1);                                 {get its location}
    end;
  end;
  if Dest.Trk = 0 then                                   {if still not found}
  begin
    Lower := 2;                                          {lower search bound}
    Upper := Disc.Trk - 1;                               {upper search bound}
    while Dest.Trk <> Middle do                          {binary search loop}
    begin
      Middle := (Lower + Upper) shr 1;                   {check the middle}
      GetTrkLoc(Trk, Middle + 1);                        {get next location}
      if Longint(Dest) > (Longint(Trk) and $FFFFFF) then {lower than given?}
      begin
        Lower := Middle + 1;                             {check the highers}
        Continue;                                        {jump to 'while'}
      end;
      GetTrkLoc(Trk, Middle);                            {get middle loc.}
      if Longint(Dest) < (Longint(Trk) and $FFFFFF) then {higher than given?}
        Upper := Middle - 1                              {check the lowers}
      else                                               {else -}
        Dest.Trk := Middle;                              {given falls here}
    end;
  end;
  SubTMSF(Dest, Trk);                                    {time into track}
end;

(* This procedures changes the default drive we're working with. it can
   handle a maximum of 10 CD-ROM drives, from 0 (first, unit default), to
   9 (10th drive, last).
   All procedures, also drive capabilities, refer to the new drive.       *)
procedure ChangeCDROMDrv(Drv : Byte);
begin
  CurCDDrv := Drv;                     {interface drive index}
  CurDrive := Byte(DrvList[Drv]) - 65; {unit's drive letter (char-ascii(A)}
end;

(* Compare two DiscRec's, and return true if equal, false for unidentical.
   the compare service, can provide a tool to examine two different discs,
   and decide whether one disc is actually the same as another disc.
   the compare consist of the disc length, and the track array, rather
   than just the pointer address values (compares Track^, not Track).
   True that there's an UPC/EAN code check, but it is unsupported for most
   drives, so this procedure is more reliable.                             *)
function SameDisc(var Dest, Src {: DiscRec}) : Boolean; assembler;
asm
      cld                {move forward}
      les     di,Dest    {load destination}
      push    ds         {save data segment}
      lds     si,Src     {load source}
      dw 0A766h          {=386's CMPSD; compare TMSF's}
      jne     @Return    {if not equal - return false}
      mov     cl,[si-1]  {get track count (same for both if reached here)}
      xor     ch,ch      {make word}
      les     di,es:[di] {load destination's tracks}
      lds     si,[si]    {load source's tracks}
      db 0F3h,66h,0A7h   {=REPE CMPSD; compare all tracks until not equal}
@Return:
      db 0Fh,94h,0C0h    {=SETE AL; set SameDisc to False or True}
      pop     ds         {restore data segment}
end;

(* Main, issued automaticly at unit's startup: *)
begin
  asm
        mov     ax,1500h              {CD-ROM information function}
        xor     bx,bx                 {bx must be zero}
        int     2Fh                   {execute interrupt}
        mov     NumCDDrv,bl           {number of cd-rom drives on system}
        mov     ax,1100h              {mscdex installation check}
        mov     dx,sp                 {save stack}
        push    0DADAh                {subfunction of installation check}
        int     2Fh                   {execute interrupt}
        mov     sp,dx                 {restore interrupt}
        cmp     al,0FFh               {must be equal, to indicate installed}
        jne     @AfterVer             {jump to end if uninstalled}
        mov     ax,150Ch              {version check function}
        int     2Fh                   {execute interrupt}
        mov     CurDrive,bx           {store version in plain memory}
        mov     ax,150Dh              {get drive letters func.}
        mov     bx,seg DrvList        {segment of drive letter list}
        mov     es,bx                 {assign to extra segment}
        mov     bx,offset DrvList     {offset of array to hold letters}
        int     2Fh                   {execute interrupt}
  @AfterVer:
  end;
  (* Places resident's MSCDEX.EXE version.
     if none - then MSCDEXVer = 0.00.
     the earliest version for this unit, must be 2.10+ : *)
  MSCDEXVer := Hi(CurDrive) + Lo(CurDrive) / 100; {format: n.nn}
  CurDrive := Byte(FstCDDrv);                     {produce word-type digit}
  for CurCDDrv := 1 to NumCDDrv do                {convert array to letters}
    Inc(Byte(DrvList[CurCDDrv]), Byte('A'));      {add 65 to the ascii value}
end.
