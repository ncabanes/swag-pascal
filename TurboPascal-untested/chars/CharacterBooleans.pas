(*
  Category: SWAG Title: CHARACTER HANDLING
  Original name: 0010.PAS
  Description: Character Booleans
  Author: SWAG SUPPORT TEAM
  Date: 11-26-94  05:05
*)

unit IS;

Interface

function IsLower (c:char):boolean;
 {Returns true of c is a lower case letter}

Inline(                  {Assembly by Inline 01/12/88 23:45}
  $59/                   {     pop  cx        ;recover argument}
  $B0/$00/               {     mov  al,0      ;establish false return}
  $80/$F9/$61/           {     cmp  cl,'a'}
  $72/$07/               {     jb   done}
  $80/$F9/$7A/           {     cmp  cl,'z'}
  $77/$02/               {     ja   done}
  $B0/$01                {     mov  al,1      ;true}
 );                      {done:}

function IsUpper (c:char):boolean;
  {returns true if c is an upper case letter}

Inline(                  {Assembly by Inline 01/12/88 23:45}
  $59/                   {     pop  cx        ;recover argument}
  $B0/$00/               {     mov  al,0      ;establish false return}
  $80/$F9/$41/           {     cmp  cl,'A'}
  $72/$07/               {     jb   done}
  $80/$F9/$5A/           {     cmp  cl,'Z'}
  $77/$02/               {     ja   done}
  $B0/$01                {     mov  al,1      ;true}
 );                      {done:}

function IsDigit (c:char):boolean;
  {returns true if c is a digit, i.e., 0-9}

Inline(                  {Assembly by Inline 01/12/88 23:45}
  $59/                   {     pop  cx        ;recover argument}
  $B0/$00/               {     mov  al,0      ;establish false return}
  $80/$F9/$30/           {     cmp  cl,'0'}
  $72/$07/               {     jb   done}
  $80/$F9/$39/           {     cmp  cl,'9'}
  $77/$02/               {     ja   done}
  $B0/$01                {     mov  al,1      ;true}
 );                      {done:}

Function IsAlpha(c:char):boolean;
 {returns true if c is an upper or lower case letter}
Inline(                  {Assembly by Inline 01/12/88 23:45}
  $59/                   {          pop  cx}
  $B0/$00/               {          mov  al,0}
  $80/$F9/$41/           {          cmp  cl,'A'}
  $72/$11/               {          jb   done}
  $80/$F9/$5A/           {          cmp  cl,'Z'}
  $76/$0A/               {          jbe  OK}
  $80/$F9/$61/           {          cmp  cl, 'a'}
  $72/$07/               {          jb   done}
  $80/$F9/$7A/           {          cmp  cl,'z'}
  $77/$02/               {          ja   done}
  $B0/$01                {  OK:     mov  al,1}
 );                      {  done:}
Function IsAlNum(c:char):boolean;
 {returns true if c is a letter or a digit}
Inline(                  {Assembly by Inline 01/12/88 23:45}
  $59/                   {          pop  cx}
  $B0/$00/               {          mov  al,0}
  $80/$F9/$30/           {          cmp  cl,'0'}
  $72/$1B/               {          jb   done}
  $80/$F9/$39/           {          cmp  cl, '9'}
  $76/$14/               {          jbe  OK}
  $80/$F9/$41/           {          cmp  cl,'A'}
  $72/$11/               {          jb   done}
  $80/$F9/$5A/           {          cmp  cl,'Z'}
  $76/$0A/               {          jbe  OK}
  $80/$F9/$61/           {          cmp  cl, 'a'}
  $72/$07/               {          jb   done}
  $80/$F9/$7A/           {          cmp  cl,'z'}
  $77/$02/               {          ja   done}
  $B0/$01                {  OK:     mov  al,1}
 );                      {  done:}


Implementation
end.

