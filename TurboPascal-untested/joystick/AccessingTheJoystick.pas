(*
  Category: SWAG Title: JOYSTICK ROUTINES
  Original name: 0011.PAS
  Description: Accessing The Joystick
  Author: SEAN PALMER
  Date: 05-25-94  08:17
*)

{by Sean Palmer}
{public domain}
{feel free to put this in SWAG or whatever}

unit joy;

{unit for accessing joystick 0}

interface

var
 installed:boolean; {true if joystick 0 present at unit startup}
var
 X,Y:word;          {stick position}
var
 A,B:boolean;       {buttons down?}
const
 Cal_L:word=$FFFF;   {rect containing calibration extent of 'center'}
 Cal_T:word=$FFFF;
 Cal_R:word=0;
 Cal_B:word=0;

procedure sample;   {take a sample of current joystick 0 state}
procedure swirlCalibrate;
procedure centerCalibrate;


implementation

procedure sample;assembler;asm
 xor si,si     {x count}
 xor di,di     {y count}
 mov dx,$201   {Game port}
 out dx,al     {Fire the joystick one-shots}
@@L:
 in  al,dx     {get joystick bits}
 mov ah,al     {save original value}
 shr al,1      {joy 0 x expired? 0 if so, else 1}
 adc si,0      {accumulate in x}
 jc @@TOOLONG  {if overflow, give up}
 shr al,1      {joy 0 y expired? 0 if so, else 1}
 adc di,0      {accumulate in y}
 jc @@TOOLONG  {if overflow, give up}
 test ah,3
 jnz @@L       {keep going til they're both 0 or we overflow}
 not ah        {flip button bits so 1=pressed}
 mov al,ah
 and al,$10    {mask off buttons and store them}
 mov A,al
 and ah,$20
 mov B,ah
 mov X,si      {store x & y coords}
 mov Y,di
 jmp @@X
@@TOOLONG:
 mov X,-1      {overflowed, return -1 as error}
 mov Y,-1
 mov A,0
 mov B,0
@@X:
end;

procedure swirlCalibrate;begin  {display message before starting this one!}
 repeat sample until not (A or B);{make sure button is up}
 repeat                           {collect max extents}
  sample;
  if x<Cal_L then Cal_L:=x;
  if x>Cal_R then Cal_R:=x;
  if y<Cal_T then Cal_T:=y;
  if y>Cal_B then Cal_B:=y;
  until a;                        {until user presses a button}
  Cal_L:=((Cal_L*3)+Cal_R)div 4;      {now adjust for center by}
  Cal_R:=((Cal_R*3)+Cal_L)div 4;      { weighted averaging}
  Cal_T:=((Cal_T*3)+Cal_B)div 4;
  Cal_B:=((Cal_B*3)+Cal_T)div 4;
 end;

procedure centerCalibrate;var x2,y2:word;begin {doesn't require user
interaction}
 sample;
 x2:=x shr 1;
 y2:=y shr 1;
 Cal_L:=x-x2;
 Cal_R:=x+x2;
 Cal_T:=y-y2;
 Cal_B:=y+y2;
 end;

begin
 sample;
 installed:=(x<>$FFFF);
end.

