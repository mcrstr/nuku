unit nukusupl;
interface

type timeV = record
           min,sec,fr:byte;
             end;
     timearray = array [1..33] of timev;
     VPAge = array [0..65535] of byte;
     Vsh = array [0..63999] of byte;
     vsho =^vsh;

  t_palette = array[0..255,0..2] of byte;
 VirTcolor = array[0..199,0..960] of byte;

var
cdletter:char;
VirVidBuff:^Vpage;
timervar:word;
VPalette:^t_palette;
VirCol:^virtcolor;

function dista (x1,y1,x2,y2:longint) :longint;
Function At1(b:byte) :boolean;
Function At2(b:byte) :boolean;
Function BSA(b:byte) :byte;
Procedure Seta1(var b:byte);
Procedure Seta2(var b:byte);
procedure Bsinc(var b:byte);
procedure Bsdec(var b:byte);
function byte2chr(b:byte) : char;
Procedure ReadPcx(Name:string; Var where);
Procedure ReadPcxP(Name:string; Var where);
Procedure MoveN(A,B:Pointer; Cb:Word);
Procedure MoveI(A,B:Pointer; Cb:Word);
Procedure Perturb(Var s:word);
Procedure ZBitmap(X,Y,xl,yl,xt,yt:Word; sour:pointer);
Procedure ZBitmapM(Sourc:Pointer; X,Y,xl,yl,xt,yt:Word; dest:pointer);
function Givemeallmili(min,sec,fr:longint) : longint;
procedure File_Error;
Function Exist(FileName: string): boolean;
procedure chekcd;
function port(numb:word) :byte;
Procedure SetRGB(col,r,g,b:byte);
Function InvertWord(wo:word):word;
Procedure MoveWPal(Source,dest:pointer; amount:word);
Procedure SEtClock(Rate:word);
Procedure UpDatePal;
Procedure MovesI(A,B:Pointer; Cb:Word);

implementation

uses nuku_screen;

Procedure PortOut(Portz:word; Val:byte);
Begin
end;
Procedure SetRGB(col,r,g,b:byte);
Begin

set_color_palette(col,r,g,b);
Vpalette^[col,0]:=r;
Vpalette^[col,1]:=g;
Vpalette^[col,2]:=b;


end;

Procedure UpDatePal;
var i:byte;
Begin
For i:=0 to 255 do Begin
SetRGB(i, Vpalette^[i,0], Vpalette^[i,1], Vpalette^[i,2])
end;

end;

function port(numb:word) :byte;
Begin
port:=0;
end;

function Givemeallmili(min,sec,fr:longint) : longint;
Begin
Givemeallmili:=longint(((min*60)+sec)*30+fr);
end;

Procedure SEtClock(Rate:word);
Begin
PortOut($43,$3C);
PortOut($40,lo(rate));
PortOut($40,hi(rate));
end;

Procedure ZBitmap(X,Y,xl,yl,xt,yt:Word; sour:pointer);
var Yz:Word;
    i,j:word;
begin
For i:=0 to yl-1 do for j:=0 to xl-1 do
VirVidBuff^[320*(y+i)+x+j]:=Vsho(sour)^[xt*round(yt/yl*i)+round(Xt/xl*j)];

{YZ:=100;
asm
Push eDi
push esi
xor eax,eax
xor ebx,ebx
xor ecx,ecx
xor edx,edx
mov esi,virvidbuff
mov edi,sour
mov ax,320
mul yl
add ax,xl
add ax,X
add si,ax
mov ax,320
mul Y
add esi,eax
Mov cx,yl
@rep1:
Xor Dx,Dx
mov Ax,yt
mul yz
div Yl
xor dx,dx
mov bx,cx
dec bx
mul bx
div Yz
mov bx,ax
mov ax,xt
mul Bx
push di
add di,ax
push cx
mov cx,xl

@rep2:
Xor Dx,Dx
mov Ax,xt
mul yz
div Xl
xor dx,dx
mul cx
div Yz
push edi
add di,ax
mov al,[edi]
mov [esi],al
@paso:
dec esi
pop edi
Loop @rep2
xor ecx,ecx
mov cx,xl
add esi,ecx
sub esi,320
pop cx
pop edi
Loop @rep1
pop esi
pop edi
end;}
end;

Procedure MoveWPal(Source,dest:pointer; amount:word);
var i:longint;
    s,d,pal:PByte;
Begin
s:=PByte(source); d:=PByte(dest); pal:=PByte(Vpalette);
for i:=0 to longint(amount)-1 do
  d^:=pal[longint(s[i])+2];
end;

Procedure ZBitmapM(Sourc:Pointer; X,Y,xl,yl,xt,yt:Word; dest:pointer);
var Yz:Word;
    i,j:word;
    bak:byte;
begin
YZ:=100;
For i:=0 to yl-1 do for j:=0 to xl-1 do begin
bak:=Vsho(sourc)^[xt*round(yt/yl*i)+round(Xt/xl*j)];
if bak>0 then Vsho(dest)^[320*(y+i)+x+j]:=bak;
end;
{asm
Push Ds
les si,dest
lds di,Sourc
mov ax,320
mul yl
add ax,xl
add ax,X
add si,ax
mov ax,320
mul Y
add si,ax
Mov cx,yl

@rep1:
Xor Dx,Dx
mov Ax,yt
mul yz
div Yl
xor dx,dx
mov bx,cx
dec bx
mul bx
div Yz
mov bx,ax
mov ax,xt
mul Bx
push di
add di,ax
push cx
mov cx,xl
@rep2:
Xor Dx,Dx
mov Ax,xt
mul yz
div Xl
xor dx,dx
mul cx
div Yz
push di
add di,ax
mov al,ds:[di]
cmp al,0
Je @Paso
mov es:[si],al
@paso:
dec si
pop di
Loop @rep2
add si,xl
sub si,320
pop cx
pop di
Loop @rep1
pop ds
end;}
end;


Procedure Perturb(Var s:word);
var r,c:longword;
Begin
r:=s xor $AA55;
c:=(r shr 15) and 1;
r:=(r shl 1) and $FFFF;
r:=(r+$118+c) and $FFFF;
s:=word(r);
end;




Procedure MoveN(A,B:Pointer; Cb:Word);
var i:longint; sa,db:PByte;
begin
sa:=PByte(A); db:=PByte(B);
for i:=0 to longint(cb)-1 do
  if sa[i]<>0 then db[i]:=sa[i];
end;

Procedure MovesI(A,B:Pointer; Cb:Word);
var i:longint; sa,db:PByte;
begin
sa:=PByte(A); db:=PByte(B);
for i:=0 to longint(cb)-1 do
  if (sa-i)^<>0 then db[i]:=(sa-i)^;
end;
Procedure MoveI(A,B:Pointer; Cb:Word);
var i:longint; sa,db:PByte;
begin
sa:=PByte(A)+cb; db:=PByte(B);
for i:=0 to longint(cb)-1 do
  if (sa-i)^<>0 then db[i]:=(sa-i)^;
end;

function dista (x1,y1,x2,y2:longint) :longint;

begin

     dista:=Round( Sqrt( Sqr(x2-x1) + Sqr(y2-y1) ) );
end;
procedure File_Error;
Begin
writeln('Error - Archivo no se encontro -');
halt(1);
end;

Procedure ReadPcxP(Name:string; var where);
Var       FilePcx:File;
           PalReg:array[0..2] of byte;
                i:byte;
            count: smallint;
              BPL: smallint;
             line:array[0..512] of byte;
 b1,data,indic,loop:Byte;
           Posv,k:Word;
              Pos:Longint;
              vs:Word;
               je:word;

{No hace mucha falta explicar que es un proc que setea la paleta en ASM}



Function SacaVal:byte;
var bqs:byte;
Begin
if vs=513 then Begin
               BLockRead(Filepcx,line[0],513);
               vs:=0;
               end;
Sacaval:=line[vs];
inc(vs);
end;
var algo:byte;
Begin
    writeln('reading PCX: ',Name);


{     for vs:=0 to 65535 do Mem[$a000:Random(64000)]:=0;
     for vs:=0 to 63999 do Mem[$a000:vs]:=0;}
     assign(FilePcx,name);
     {$I-}
     Reset(FilePcx,1);
     {$I+}
     algo:=ioresult;
     if ioresult<>0 then file_error;
     {Primero leemos la paleta, que al ser un PCX 256c esta anexada al final del archivo}
     seek (FilePcx, FileSize (FilePcx) - 768); {nos movemos al final del archivo -(3*256),lo que ocupa la paleta}
     For i:= 0 to 255 do Begin
{                        Leemos a un Reg. de la paleta}
                        BlockRead (FilePcx, Palreg, 3);
{seteamos los reg. pero hay ke recordar que la intensidad de RGB en la pal. del PCX
 es de 0..255 y que la real es de 0..63, o sea , dividimos por 4 sin resto. Es mas rapido hacer shr 2 que div 4}
                        SetRGB(i,palreg[0] shr 2,palreg[1] shr 2,palreg[2]shr 2)
                        end;

{ponemos la pos. en el archivo a 128 , los 128 de arriba son el Header.. cosa que
 NO nos interesa, ya sabemos ke es 320x200x256}
     seek (FilePcx, 128);
     Pos:=128;
     PosV:=0;
     vs:=0;
     BLockRead(Filepcx,line[0],513);
     Repeat
     {leemo un byte del archivo}
     data:=Sacaval;
     {nos fijamos si hay compresion}
     if data and $C0 = $C0 Then Begin
                                   {si hay..}
                                   loop:=data and $3F; {cuantos se repite?}
                                   b1:=SacaVal; {CUAL se repite?}
                                   inc (pos,1);
                                   For k:=1 to loop do Begin {Bueh ponemos la cadena de bytes}
                                   Vpage(where)[PosV]:=b1;
                                   inc (PosV); {incrementa el punto donde tamos en video}
                                   end;
                                   end

                                   else Begin
                                   {no.. no hay compresion :(}
                                   Vpage(where)[posv]:=data;
                                   inc(posV); {incrementa el punto donde tamos en video}
                                   end;
     until PosV>63999; {ya terminamos? (320*200=64000}
     Close(FilePcx); {cerramo el archivo..}

     writeln('end PCX load..');
end;

Procedure ReadPcx(Name:string; var where);
Var       FilePcx:File;
           PalReg:array[0..2] of byte;
                i:byte;
            count: smallint;
              BPL: smallint;
             line:array[0..512] of byte;
 b1,data,indic,loop:Byte;
           Posv,k:Word;
              Pos:Longint;
              vs:Word;

{No hace mucha falta explicar que es un proc que setea la paleta en ASM}

Function SacaVal:byte;
var bqs:byte;
Begin
if vs=513 then Begin
               BLockRead(Filepcx,line[0],513);
               vs:=0;
               end;
Sacaval:=line[vs];
inc(vs);
end;
var algo:byte;
Begin
    writeln('reading PCX: ',Name);
 
     Assign(FilePcx,name);
     {$i-}
     Reset(FilePcx,1);
     {$i+}
  algo:=ioresult;
     algo:=ioresult;
     if ioresult<>0 then file_error;
     {Primero leemos la paleta, que al ser un PCX 256c esta anexada al final del archivo}
{ponemos la pos. en el archivo a 128 , los 128 de arriba son el Header.. cosa que
 NO nos interesa, ya sabemos ke es 320x200x256}
     seek (FilePcx, 128);
     Pos:=128;
     PosV:=0;
     vs:=0;
     BLockRead(Filepcx,line[0],513);
     Repeat
     {leemo un byte del archivo}
     data:=Sacaval;
     {nos fijamos si hay compresion}
     if data and $C0 = $C0 Then Begin
                                   {si hay..}
                                   loop:=data and $3F; {cuantos se repite?}
                                   b1:=SacaVal; {CUAL se repite?}
                                   inc (pos,1);
                                   For k:=1 to loop do Begin {Bueh ponemos la cadena de bytes}
                                   Vpage(Where)[posv]:=b1;
                                   inc (PosV); {incrementa el punto donde tamos en video}
                                   end;
                                   end

                                   else Begin
                                   {no.. no hay compresion :(}
                                   Vpage(Where)[posv]:=data;
                                   inc(posV); {incrementa el punto donde tamos en video}
                                   end;
     until PosV>63999; {ya terminamos? (320*200=64000}
     Close(FilePcx); {cerramo el archivo..}
end;
Function At1(b:byte) :boolean;
begin
at1:=(b and 128) = 128
end;
Function At2(b:byte) :boolean;
begin
at2:=(b and 64) = 64
end;

Function BSA(b:byte) :byte;
Begin
bsa:=b and 63;
end;

Procedure Seta1(var b:byte);
Begin
if At1(b) then b:=b and 127
          else b:=b or 128;
end;
Procedure Seta2(var b:byte);
Begin
if At2(b) then b:=b and 191
          else b:=b or 64;
end;

procedure Bsinc(var b:byte);
var s2:byte;
begin
s2:=b or 63;
b:=b and 63;
inc(b);
b:=b and s2;
end;
procedure Bsdec(var b:byte);
var state,s2:byte;
begin
s2:=b or 63;
b:=b and 63;
dec(b);
b:=b and s2;
end;
function byte2chr(b:byte) : char;
Begin
byte2chr:=chr(b+48);
end;

Function Exist(FileName: string): boolean;
Var
	Fil: File;

begin
	Assign(Fil,FileName);
	{$I- }
	Reset(Fil);
	Close(Fil);
	{$I+ }

	Exist := (IOResult = 0);
end;

procedure chekcd;
var t:boolean;
    intents:byte;
Begin

intents:=0;
Repeat
{t:=exist(cdletter+':\source.dir');}
t:=true;
if not t then Begin
                   Readpcxp('nuk.pcx',VirVidBuff^[0]);
                   repeat until port($60)>=128;
                   repeat until port($60)<128;
                   inc(intents);
                   end;
if intents>4 then Begin
                  Writeln('No se pudo encontrar el cd de NuKu');
                  halt(1);
                  end;
until t;
end;
Function InvertWord(wo:word):word;
Begin
InvertWord:=(wo shr 8) or (lo(wo) shl 8);
end;
end.

