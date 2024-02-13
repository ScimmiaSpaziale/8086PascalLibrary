 ########################################################################
 #                                                                      #
 # "C8086i Ceglia x8086 Translator Library" - version 1.0               #
 # Useful Pascal Library to Translated x86 Asm Code in Binary/Byte Code #
 #                                                                      #
 # Copyright (C) 2009 - 2010 by Giovanni Ceglia                         #
 #                                                                      #
 # This file is part of "EPP Ceglia Tools".                             #
 #                                                                      #
 # "EPP Ceglia Tools" is free software: you can redistribute it and/or  #
 # modify it under the terms of the GNU General Public License as       # 
 # published by the Free Software Foundation, either version 3 of the   #
 # License, or (at your option) any later version.                      #
 #                                                                      #
 # This program is distributed in the hope that it will be useful,      #
 # but WITHOUT ANY WARRANTY; without even the implied warranty of       # 
 # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the         #
 # GNU General Public License for more details.                         #
 #                                                                      #
 # You should have received a copy of the GNU General Public License    #
 # along with this program. If not, see <http://www.gnu.org/licenses/>. #
 #                                                                      #
 ########################################################################

 ########################################################################
 #                                                                      #
 # This software is available at http://www.giovanniceglia.com          #
 # Comments and suggestions: http://www.giovanniceglia.com              #
 #                                                                      #
 # All contact info to contact Ceglia Giovanni can be found on:         # 
 # http://www.ceglia.tel, you can also write:                           #
 # giovanni.ceglia@gmail.com or giovanniceglia@xungame.com              #
 #                                                                      #
 ########################################################################

 ########################################################################
 #                                                                      #
 # This source/library is Compatible with Delphi 6-7, Turbo Pascal 7    #
 # Free Pascal, Lazarus, Dev Pascal, Kylix 3                            #
 #                                                                      # 
 # An Example to converte Asm Code:                                     #
 #                                                                      # 
 # Code8086('Mov AX,BX',0);                                             # 
 #                                                                      # 
 #  Nmc array includes counter for OpCodes. MC[1..Nmc] byte codes.      #
 #                                                                      # 
 ########################################################################

Unit C8086;

Interface
{$M 65000,1,655000}

Type String20=String[20];

Var
  Mc:Array[1..20] Of Byte; { Array contenenti gli OPCode generati. }
  Nmc:Word;                { Contatore che indica quandi OpCodes sono stati generati e quindi da prelevare in MC }
  Mem:Byte;                { Memoria consumata. }

  ErrorStack:Array[1..100] Of String; { Contiene gli errori generati. }
  ErrorCount:Integer; { Contatore degli errori generati. }

  Function Code8086(Istruzione:String; CompileRiga:Word):Boolean; { Trasforma l'istruzione ASM in Codice Operativo }

Implementation

Var
 OneCode:Array[1..27] Of String20;
 One8086:Array[1..27] Of String20;
 IOne:Word;

 CodeSeg:Byte;
 ExtraSeg:Boolean;
 Reg1,Seg1,Mem1,Adr1               :Boolean;
 Reg2,Seg2,Mem2,Adr2,Val2,Negation :Boolean;

 R1_8,R2_8,R1_16,R2_16,M1_8,M2_8,M1_16,M2_16:Boolean;
 IBX,IBP,ISI,IDI,IDSP:Boolean;

 Mde:String[2];
 Reg:String[3];
 R_M:String[3];
 W,D,S,V,Z,X:String[1];
 Disp:Word;
 Ad1,Ad2:Word;
 Dat:Word;
 O1,O2:Boolean;

 Code:Array[1..256] Of String20;
 Nc:Word;
 Riga:Integer;
 Negative:Boolean;

 Simb:Array[1..30] Of Char;
 Nsimbol:Word;
 AllSimbol:Boolean;

Procedure SetSimbol;
Begin
 Simb[1]:='"';
 Simb[2]:='@';
 Simb[3]:='(';
 Simb[4]:=')';
 Simb[5]:='<';
 Simb[6]:='>';
 Simb[7]:='=';
 Simb[8]:='!';
 Simb[9]:='?';
 Simb[10]:=',';
 Simb[11]:='+';
 Simb[12]:='-';
 Simb[13]:='/';
 Simb[14]:='*';
 Simb[15]:=':';
 Simb[16]:=';';
 Simb[17]:='[';
 Simb[18]:=']';
 Simb[19]:='.';
 Simb[20]:=' ';
 Simb[21]:='^';
 Nsimbol:=21;
End;

Function Pot(N,Exp:Word):Word;
Var C:Word;
Begin
 If Exp=0 Then Pot:=1 Else
  Begin
   C:=N;
   While Exp>1 Do
    Begin
     C:=C*N;
     Exp:=Exp-1;
    End;
   Pot:=C;
  End;
End;

Function Potenza(A,B:LongInt):LongInt;
Var
 C:LongInt;
Begin
 If B=0 Then Potenza:=1 Else
  Begin
   C:=A;
   While B>1 Do
    Begin
     C:=C*A;
     B:=B-1;
    End;
   Potenza:=c;
  End;
End;

Function RStr(N:Byte):String;
Begin
  If (N<=9) Then RStr:=Chr(48+N) Else RStr:=Chr(N);
End;

Function RNum(N:Char):Word;
Begin
 If (N>=#48)And(N<#58) Then RNum:=Ord(N)-48 Else RNum:=Ord(N)-55;
End;

Function BinStr(Num:word):string;
Var
sapp,sapp2:string;
nv,nv2:word;
begin
sapp:='';
sapp2:='';
nv:=num;
while nv>=2 do
begin
nv2:=nv mod 2;
nv:=nv div 2;
sapp2:=rstr(nv2);
sapp:=sapp2+sapp;
end;
sapp2:=rstr(nv);
sapp:=sapp2+sapp;
binstr:=sapp;
end;

Function DecStr(Num:Word):String;
Var
 Sapp,Sapp2:string;
 Nv,Nv2:word;
Begin
 Sapp:='';
 Sapp2:='';
 Nv:=Num;
 While Nv>=10 Do
  Begin
   Nv2:=Nv Mod 10;
   Nv:=Nv Div 10;
   Sapp2:=Rstr(Nv2);
   Sapp:=Sapp2+Sapp;
  End;
 Sapp2:=Rstr(Nv);
 Sapp:=Sapp2+Sapp;
 DecStr:=Sapp;
End;

Function IntStr(num:Integer):string;
var
sapp,sapp2,Sign:string;
nv,nv2:word;
begin
if num<0 Then
 begin
  sign:='-';
  num:=-num;
 end else sign:='+';
sapp:='';
sapp2:='';
nv:=num;
while nv>=10 do
begin
nv2:=nv mod 10;
nv:=nv div 10;
sapp2:=rstr(nv2);
sapp:=sapp2+sapp;
end;
sapp2:=rstr(nv);
sapp:=sapp2+sapp;
Intstr:=sign+sapp;
end;

Function HexStr(num:word):string;
var
sapp,sapp2:string;
nv,nv2:word;
begin
sapp:='';
sapp2:='';
nv:=num;
while nv>=16 do
begin
nv2:=nv mod 16;
nv:=nv div 16;
sapp2:=rstr(nv2);
sapp:=sapp2+sapp;
end;
sapp2:=rstr(nv);
sapp:=sapp2+sapp;
hexstr:=sapp;
end;

Function StrBin(numer:string):word;
var
i,x,y,app:word;
begin
app:=0;
x:=Length(numer);
I:=0;
for y:=x Downto 1 do
begin
app:=app+(rnum(numer[y])*pot(2,i));
I:=I+1;
end;
strbin:=app;
end;

Function StrDec(numer:string):word;
var
i,x,y,app:word;
begin
app:=0;
x:=Length(numer);
I:=0;
for y:=x Downto 1 do
begin
app:=app+(rnum(numer[y])*pot(10,i));
I:=I+1;
end;
strdec:=app;
end;

Function StrHex(numer:string):word;
var
i,x,y,app:word;
begin
app:=0;
x:=Length(numer);
I:=0;
for y:=x Downto 1 do
begin
app:=app+(rnum(numer[y])*pot(16,i));
I:=I+1;
end;
strhex:=app;
end;

Procedure NumErrore(S,E:String);
Begin
 ErrorCount:=ErrorCount+1;
 ErrorStack[ErrorCount]:=S;
 ErrorCount:=ErrorCount+1;
 ErrorStack[ErrorCount]:=E;
End;

Procedure Errore(S:String);
Var I:Integer;
    E:String;
Begin
 ErrorCount:=ErrorCount+1;
 ErrorStack[ErrorCount]:='Errore alla riga:'+IntStr(Riga);
 ErrorCount:=ErrorCount+1;
 ErrorStack[ErrorCount]:=S;
 E:='';
 For I:=1 To Nc Do
  Begin
   If I<>1 Then E:=E+', ';
   E:=E+Code[I];
  End;
 ErrorCount:=ErrorCount+1;
 ErrorStack[ErrorCount]:=E;
End;

Function ExtraSegVal(S:String):Byte;
Begin
 If S='CS' Then ExtraSegVal:=46  Else
 If S='SS' Then ExtraSegVal:=54  Else
 If S='ES' Then ExtraSegVal:=38  Else
 If S='DS' Then ExtraSegVal:=144 Else
  ExtraSegVal:=144;
End;

Function ChNum(S:Char):Byte;
Begin
 If (S>='0')And(S<='9') Then ChNum:=Ord(S)-48 Else
 If (S>='A')And(S<='F') Then ChNum:=(Ord(S)-65)+10 Else
  ChNum:=0;
End;

Function IsBin(S:String):Boolean;
Var V:Boolean;
    I:Word;
    L:Word;
Begin
 V:=True;
 L:=LengTh(S);
 If (S[1]<>'&')Or(L<2) Then V:=False Else
  Begin
   For I:=2 To L Do
    Begin
     If Not((S[I]='0')Or(S[I]='1')) Then V:=False;
    End;
  End;
 IsBin:=V;
End;

Function IsDec(S:String):Boolean;
Var V:Boolean;
    I:Word;
    L:Word;
Begin
 V:=True;
 L:=LengTh(S);
 If (L<1) Then V:=False Else
  Begin
   For I:=1 To L Do
    Begin
     If Not((S[I]>='0')And(S[I]<='9')) Then V:=False;
    End;
  End;
 IsDec:=V;
End;

Function IsHex(S:String):Boolean;
Var V:Boolean;
    I:Word;
    L:Word;
Begin
 V:=True;
 L:=LengTh(S);
 If (S[1]<>'$')Or(L<2) Then V:=False Else
  Begin
   For I:=2 To L Do
    Begin
     If Not(((S[I]>='0')And(S[I]<='9'))
        Or((S[I]>='A')And(S[I]<='F'))) Then V:=False;
    End;
  End;
 IsHex:=V;
End;

Function IsChar(S:String):Boolean;
Begin
 If (S[1]='"')And(S[3]='"') Then IsChar:=True Else IsChar:=False;
End;

Function IsDoubleChar(S:String):Boolean;
Begin
 If (S[1]='"')And(S[4]='"') Then IsDoubleChar:=True
                            Else IsDoubleChar:=False;
End;

Function IsBoolean(S:String):Boolean;
Begin
 If (S='TRUE') Or (S='FALSE') Then IsBoolean:=True Else IsBoolean:=False;
End;

Function IsString(S:String):Boolean;
Begin
 If (S[1]='"')And(S[LengTh(S)]='"') Then IsString:=True
                                    Else IsString:=False;
End;


Function Bit8Bin(S:String):Byte;
Var
 I,X,Y,N,App:Word;
Begin
 App:=0;
 X:=LengTh(S);
 I:=0;
 N:=2;
 If (S[1]='-')Or(S[1]='+') Then N:=3;
 For Y:=X DownTo N Do
  Begin
   App:=App+(ChNum(S[Y])*Potenza(2,I));
   I:=I+1;
  End;
 If S[1]='-' Then App:=256-App;
 Bit8Bin:=App;
End;


Function Bit8Dec(S:String):Byte;
Var
 I,X,Y,N,App:Word;
Begin
 App:=0;
 X:=LengTh(S);
 I:=0;
 N:=1;
 If (S[1]='-')Or(S[1]='+') Then N:=2;
 For Y:=X DownTo N Do
  Begin
   App:=App+(ChNum(S[Y])*Potenza(10,I));
   I:=I+1;
  End;
 If S[1]='-' Then App:=256-App;
 Bit8Dec:=App;
End;

Function Bit8Hex(S:String):Byte;
Var
 I,X,Y,N,App:Word;
Begin
 App:=0;
 X:=LengTh(S);
 I:=0;
 N:=2;
 If (S[1]='-')Or(S[1]='+') Then N:=3;
 For Y:=X DownTo N Do
  Begin
   App:=App+(ChNum(S[Y])*Potenza(16,I));
   I:=I+1;
  End;
 If S[1]='-' Then App:=256-App;
 Bit8Hex:=App;
End;


Function Bit8Char(S:String):Byte;
Begin
 Bit8Char:=Ord(S[2]);
End;

Function Bit8Boolean(S:String):Byte;
Begin
 If S='TRUE' Then Bit8Boolean:=$FF Else Bit8Boolean:=$00;
End;


Function Bit16Char(S:String):Word;
Begin
 Bit16Char:=Ord(S[2])+(Ord(S[2])*256);
End;


Function BitString(S:String):String;
Begin
 BitString:=Copy(S,2,LengTh(S)-2);
End;


Function Bit16Bin(S:String):Word;
Var
 I,X,Y,N,App:Word;
Begin
 App:=0;
 X:=LengTh(S);
 I:=0;
 N:=2;
 If (S[1]='-')Or(S[1]='+') Then N:=3;
 For Y:=X DownTo N Do
  Begin
   App:=App+(ChNum(S[Y])*Potenza(2,I));
   I:=I+1;
  End;
 If S[1]='-' Then App:=65536-App;
 Bit16Bin:=App;
End;

Function Bit16Dec(S:String):Word;
Var
 I,X,Y,N:Word;
 App:Word;
Begin
 App:=0;
 X:=LengTh(S);
 I:=0;
 N:=1;
 If (S[1]='-')Or(S[1]='+') Then N:=2;
 For Y:=X DownTo N Do
  Begin
   App:=App+(ChNum(S[Y])*Potenza(10,I));
   I:=I+1;
  End;
 If S[1]='-' Then App:=65536-App;
 Bit16Dec:=App;
End;

Function Bit16Hex(S:String):Word;
Var
 I,X,Y,N:Word;
 App:Word;
Begin
 App:=0;
 X:=LengTh(S);
 I:=0;
 N:=2;
 If (S[1]='-')Or(S[1]='+') Then N:=3;
 For Y:=X DownTo N Do
  Begin
   App:=App+(ChNum(S[Y])*Potenza(16,I));
   I:=I+1;
  End;
 If S[1]='-' Then App:=65536-App;
 Bit16Hex:=App;
End;

Function IsNumero(S:String):Boolean;
Begin
 If IsBin(S) Then IsNumero:=True Else
 If IsDec(S) Then IsNumero:=True Else
 If IsHex(S) Then IsNumero:=True Else
 If IsChar(S) Then IsNumero:=True Else
 If IsDoubleChar(S) Then IsNumero:=True Else
 If IsBoolean(S) Then IsNumero:=True Else
 If IsString(S) Then IsNumero:=True Else
 IsNumero:=False;
End;

Function Valore8Bit(S:String):Byte;
Begin
   If IsBin(S) Then Valore8Bit:=Bit16Bin(S) Else
   If IsDec(S) Then Valore8Bit:=Bit16Dec(S) Else
   If IsHex(S) Then Valore8Bit:=Bit16Hex(S) Else
   If IsChar(S) Then Valore8Bit:=Bit8Char(S) Else
   If IsBoolean(S) Then Valore8Bit:=Bit8Boolean(S) Else
    Begin
      Valore8Bit:=0;
      NumErrore(S,'Valore troppo grande o sbagliata scrittura.');
    End;
End;

Function Valore16Bit(S:String):Word;
Begin
   If IsBin(S) Then Valore16Bit:=Bit16Bin(S) Else
   If IsDec(S) Then Valore16Bit:=Bit16Dec(S) Else
   If IsHex(S) Then Valore16Bit:=Bit16Hex(S) Else
   If IsChar(S) Then Valore16Bit:=Bit8Char(S) Else
   If IsDoubleChar(S) Then Valore16Bit:=Bit16Char(S) Else
   If IsBoolean(S) Then Valore16Bit:=Bit8Boolean(S) Else
    Begin
      Valore16Bit:=0;
      NumErrore(S,'Valore troppo grande o sbagliata scrittura.');
    End;
End;

Function IsSimbol(S:Char):Boolean;
 Var
  T:Boolean;
  I:Word;
Begin
 T:=False;
 I:=1;
 While (I<Nsimbol)And Not T Do
  Begin
   If Simb[I]=S Then T:=True;
   I:=I+1;
  End;
 If S=#32 Then T:=True;
 If S='"' Then
  Begin
   AllSimbol:=Not AllSimbol;
   T:=False;
  End;
 If Not AllSimbol Then T:=False;
 IsSimbol:=T;
End;









Function IsSegReg(S:String):Boolean;
Begin
 If S='ES' Then IsSegReg:=True Else
 If S='DS' Then IsSegReg:=True Else
 If S='CS' Then IsSegReg:=True Else
 If S='SS' Then IsSegReg:=True Else
  IsSegReg:=False;
End;

Function Is8BitReg(S:String):Boolean;
Begin
 If S='AL' Then Is8BitReg:=True Else
 If S='AH' Then Is8BitReg:=True Else
 If S='BL' Then Is8BitReg:=True Else
 If S='BH' Then Is8BitReg:=True Else
 If S='CL' Then Is8BitReg:=True Else
 If S='CH' Then Is8BitReg:=True Else
 If S='DL' Then Is8BitReg:=True Else
 If S='DH' Then Is8BitReg:=True Else
  Is8BitReg:=False;
End;

Function Is16BitReg(S:String):Boolean;
Begin
 If S='AX' Then Is16BitReg:=True Else
 If S='BX' Then Is16BitReg:=True Else
 If S='CX' Then Is16BitReg:=True Else
 If S='DX' Then Is16BitReg:=True Else
 If S='SP' Then Is16BitReg:=True Else
 If S='BP' Then Is16BitReg:=True Else
 If S='SI' Then Is16BitReg:=True Else
 If S='DI' Then Is16BitReg:=True Else
  Is16BitReg:=False;
End;

Function ValReg(S:String):String;
Begin
 If (S='AX')Or(S='AL') Then ValReg:='000' Else
 If (S='CX')Or(S='CL') Then ValReg:='001' Else
 If (S='DX')Or(S='DL') Then ValReg:='010' Else
 If (S='BX')Or(S='BL') Then ValReg:='011' Else
 If (S='SP')Or(S='AH') Then ValReg:='100' Else
 If (S='BP')Or(S='CH') Then ValReg:='101' Else
 If (S='SI')Or(S='DH') Then ValReg:='110' Else
 If (S='DI')Or(S='BH') Then ValReg:='111' Else
 If (S='ES') Then ValReg:='00' Else
 If (S='CS') Then ValReg:='01' Else
 If (S='SS') Then ValReg:='10' Else
 If (S='DS') Then ValReg:='11' Else
 ValReg:='';
End;


Procedure CalcolaRM(Var I:Byte);
Var J,X:Integer;
Begin
 J:=I;
 While (Code[J]<>']') And (J<=Nc) Do J:=J+1;
 If J>Nc Then Errore('Parentesi non chiusa');
 IBX:=False;
 IBP:=False;
 ISI:=False;
 IDI:=False;
 IDSP:=False;
 Disp:=0;
 X:=I;
 While X<J Do
  Begin
   If Code[X]='BX' Then
    Begin
     If IBX Or IBP Then Errore('Errato spiazzamento ');
     IBX:=True
    End Else
   If Code[X]='BP' Then
    Begin
     If IBX Or IBP Then Errore('Errato spiazzamento ');
     IBP:=True
    End Else
   If Code[X]='SI' Then
    Begin
     If ISI Or IDI Then Errore('Errato spiazzamento ');
     ISI:=True
    End Else
   If Code[X]='DI' Then
    Begin
     If ISI Or IDI Then Errore('Errato spiazzamento ');
     IDI:=True
    End Else
   If Code[X]='-' Then
    Begin
     X:=X+1;
     If Not IsNumero(Code[X]) Then Errore('Atteso spiazzamento.');
     Disp:=Valore16Bit(Code[X]);
     If Disp>255 Then Disp:=65536-Disp Else Disp:=256-Disp;
     IDSP:=True;
    End Else
   If IsNumero(Code[X]) Then
    Begin
     If IDSP Then Errore('Spiazzamento non supportato');
     Disp:=Valore16Bit(Code[X]);
     IDSP:=True;
    End Else
   If Code[X]='+' Then
    Begin
    End Else Errore('Puntatore errato nell''istruzione.');
   X:=X+1;
  End;

I:=J;

If IBX And ISI Then R_M:='000' Else
If IBX And IDI Then R_M:='001' Else
If IBP And ISI Then R_M:='010' Else
If IBP And IDI Then R_M:='011' Else
If ISI Then R_M:='100' Else
If IDI Then R_M:='101' Else
If IBP Then R_M:='110' Else
If IBX Then R_M:='111' Else
 Errore('Mancato registro puntatore.');

End;

Procedure ControllaSegmentoOp1(Var I:Byte);
 Begin
   If IsSegReg(Code[I]) Then
    Begin
     If Code[I+1]=':' Then
      Begin
       CodeSeg:=ExtraSegVal(Code[I]);
       ExtraSeg:=True;
       I:=I+2;
      End Else
      Begin
       Seg1:=True;
       I:=I+1;
      End;
    End;
 End;

Function ControlOp1(Var I:Byte):Boolean;
Begin
 If Nc>=I Then
  Begin
   ControllaSegmentoOp1(I);
   R1_8:=Is8BitReg(Code[I]);
   R1_16:=Is16BitReg(Code[I]);
   Reg1:=R1_8 Or R1_16;
   If Reg1 Then I:=I+1;
   M1_8:=(Code[I]='BYTE');
   M1_16:=(Code[I]='WORD');
   Mem1:=M1_8 Or M1_16;
   If Code[I]='PTR' Then I:=I+1;
   If Code[I]='BYTE' Then I:=I+1;
   If Code[I]='WORD' Then I:=I+1;
   If Code[I]='PTR' Then I:=I+1;
   ControllaSegmentoOp1(I);

   If Reg1 And Mem1 Then Errore('Primo operando non pu• avere un registro e un indirizzo.');
   If Reg1 And Seg1 Then Errore('Primo operando non pu• avere un registro e un indirizzo.');
   If Seg1 And Mem1 Then Errore('Primo operando non pu• avere un registro e un indirizzo.');

   If Not (Reg1 Or Seg1) Then
    Begin
     If I>Nc Then Errore('Primo operando breve. Attesa "[". ');
     If Code[I]<>'[' Then Errore('Mancato indirizzo nel primo operando.') Else
       If Not Mem1 Then
        Begin
         M1_16:=True;
         Mem1:=True;
        End;
     I:=I+1;
     If IsNumero(Code[I]) Then
      Begin
       Adr1:=True;
       Ad1:=Valore16Bit(Code[I]);
       I:=I+1;
      End Else CalcolaRM(I);
     If Code[I]<>']' Then Errore('Parentesi non chiusa.') Else I:=I+1;
    End Else
     If (I<Nc)And(Code[I]<>',') Then Errore('Parametri nel primo operando errati.');
   ControlOp1:=True;
  End Else ControlOp1:=False;
End;

Procedure ControllaSegmentoOp2(Var I:Byte);
 Begin
   If IsSegReg(Code[I]) Then
    Begin
     If Code[I+1]=':' Then
      Begin
       CodeSeg:=ExtraSegVal(Code[I]);
       ExtraSeg:=True;
       I:=I+2;
      End Else
      Begin
       Seg2:=True;
       I:=I+1;
      End;
    End;
 End;

Function ControlOp2(Var I:Byte):Boolean;
Var Valore:Boolean;
Begin
 Valore:=False;
 If Nc>=I Then
  Begin
   If (Code[I]='-') Or (Code[I]='+')  Then Valore:=True;
   While (Code[I]='-') Or (Code[I]='+') Do
    Begin
     If Code[I]='-' Then Negation:=Not Negation;
     I:=I+1;
    End;
   If IsNumero(Code[I]) Then
    Begin
     Val2:=True;
     Dat:=Valore16Bit(Code[I]);
     I:=I+1;
    End Else
     If Valore Then Errore('Era atteso valore numerico.');
   ControllaSegmentoOp2(I);
   R2_8:=Is8BitReg(Code[I]);
   R2_16:=Is16BitReg(Code[I]);
   Reg2:=R2_8 Or R2_16;
   If Reg2 Then I:=I+1;
   M2_8:=(Code[I]='BYTE');
   M2_16:=(Code[I]='WORD');
   Mem2:=M2_8 Or M2_16;
   If Code[I]='PTR' Then I:=I+1;
   If Code[I]='BYTE' Then I:=I+1;
   If Code[I]='WORD' Then I:=I+1;
   If Code[I]='PTR' Then I:=I+1;
   ControllaSegmentoOp2(I);

   If Reg2 And Mem2 Then Errore('Secondo operando con elementi eccessivi.');
   If Reg2 And Val2 Then Errore('Secondo operando con eccessivi elementi.');
   If Reg2 And Seg2 Then Errore('Secondo operando con elementi eccessivi.');
   If Seg2 And Val2 Then Errore('Secondo operando con elementi eccessivi.');
   If Seg2 And Mem2 Then Errore('Secondo operando con elementi eccessivi.');

   If Not (Reg2 Or Seg2 Or Val2) Then
    Begin
     If I>Nc Then Errore('Secondo operando breve. Attesa "[". ');
     If Code[I]<>'[' Then Errore('Mancato indirizzo nel secondo operando.') Else
       If Not Mem2 Then
        Begin
         M2_16:=True;
         Mem2:=True;
        End;
     I:=I+1;
     If IsNumero(Code[I]) Then
      Begin
       Adr2:=True;
       Ad2:=Valore16Bit(Code[I]);
       I:=I+1;
      End Else CalcolaRM(I);
     If Code[I]<>']' Then Errore('Parentesi non chiusa.') Else I:=I+1;
    End Else If (I<=Nc) Then Errore('Parametri nel secondo operando errati.');
   ControlOp2:=True;
  End Else ControlOp2:=False;
End;


Procedure ExaminParam;
Var I:Byte;
Begin
 Reg1:=False;
 Seg1:=False;
 Mem1:=False;
 Adr1:=False;

 Adr2:=False;
 Seg2:=False;
 Reg2:=False;
 Mem2:=False;
 Val2:=False;

 ExtraSeg:=False;
 Negation:=False;

 R1_8:=False;
 R2_8:=False;
 R1_16:=False;
 R2_16:=False;
 M1_8:=False;
 M2_8:=False;
 M1_16:=False;
 M2_16:=False;

 Dat:=0;

 D:='1';

 I:=2;
 O1:=ControlOp1(I);
 If Code[I]=',' Then
  Begin
   I:=I+1;
   O2:=ControlOp2(I);
  End;
 If (Seg1 And R2_8) Or (Seg2 And R1_8) Then
   Errore('Non si pu• effettuare una operazione simile');
 If (R1_8 And R2_16) Or (R2_8 And R1_16) Then
   Errore('Non si pu• effettuare una operazione simile');
 If (M1_8 And R2_16) Or (M2_8 And R1_16) Then
   Errore('Non si pu• effettuare una operazione simile');
 If R1_8 And (Dat>255) Then Errore('Non si pu• effettuare una operazione simile');
 If R1_8 Or M1_8 Or R2_8 Or M2_8 Then W:='0' Else W:='1';

 If Reg1 And Reg2 Then
  Begin
   Mde:='11';
   Reg:=ValReg(Code[2]);
   R_M:=ValReg(Code[4]);
  End Else
 If (Reg1 And Seg2)Or(Seg1 And Reg2) Then
  Begin
   Mde:='11';
   If Reg1 And Seg2 Then
    Begin
     D:='0';
     Reg:=ValReg(Code[4]);
     R_M:=ValReg(Code[2]);
    End Else
    Begin
     D:='1';
     Reg:=ValReg(Code[4]);
     R_M:=ValReg(Code[2]);
    End;
  End Else
  Begin
   If Disp=0 Then Mde:='00' Else
   If Disp<256 Then Mde:='01' Else Mde:='10';

   If Reg2 And Adr1 Then D:='0' Else D:='1';
   If Seg2 And Adr1 Then D:='0' Else D:='1';

   If Val2 Then
    Begin
     If Reg1 Then R_M:=ValReg(Code[2]) Else
     If Reg2 Then R_M:=ValReg(Code[Nc]);
    End;

   If Reg1 Then Reg:=ValReg(Code[2]) Else If Reg2 Then Reg:=ValReg(Code[Nc]);
   If Seg1 Then Reg:=ValReg(Code[2]) Else If Seg2 Then Reg:=ValReg(Code[Nc]);
  End

End;

Procedure ExamineAndControlOp1;
Begin
 ExaminParam;
 If Not O1 Then Errore('Questa istruzione richiede un operando.');
 Nmc:=0;
 If ExtraSeg Then
  Begin
   If CodeSeg<>144 Then
    Begin
     Nmc:=1;
     MC[Nmc]:=CodeSeg;
    End;
  End;
End;

Procedure ExamineAndControlOp2;
Begin
 ExaminParam;
 If Not O1 And O2 Then Errore('Questa istruzione richiede due operandi.');
 Nmc:=0;
 If ExtraSeg Then
  Begin
   If CodeSeg<>144 Then
    Begin
     Nmc:=1;
     MC[Nmc]:=CodeSeg;
    End;
  End;
End;

Procedure Date8(D:Word);
Begin
 Nmc:=Nmc+1;
 Mc[Nmc]:=D;
End;

Procedure Date16(D:Word);
Begin
 Nmc:=Nmc+1;
 Mc[Nmc]:=D Mod 256;
 Nmc:=Nmc+1;
 Mc[Nmc]:=D Div 256;
End;

Procedure Variable(D:Word);
Begin
 Mem:=Nmc;
 Nmc:=Nmc+1;
 Mc[Nmc]:=D Mod 256;
 Nmc:=Nmc+1;
 Mc[Nmc]:=D Div 256;
End;


Procedure I_Add;
Begin
 ExamineAndControlOp2;
{  Da REGISTRO a REGISTRO             }
 If Reg1 And Reg2 Then
  Begin
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&000000'+D+W);
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&'+Mde+Reg+R_M);
  End Else
{ Da MEMORIA a REGISTRO e viceversa }
 If (Mem1 And Reg2)Or(Mem2 And Reg1) Then
  Begin
   If Reg1 Then D:='1' Else D:='0';
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&000000'+D+W);
   If Adr1 Or Adr2 Then
    Begin
     Nmc:=Nmc+1;
     Mc[Nmc]:=Valore8Bit('&00'+Reg+'110');
     If Mem2 Then Ad1:=Ad2;
     Variable(Ad1);
    End Else
    Begin
     Nmc:=Nmc+1;
     Mc[Nmc]:=Valore8Bit('&'+Mde+Reg+R_M);
     If Mde='01' Then Date8(Disp) Else
     If Mde='10' Then Date16(Disp);
    End;
  End Else
{  IMMEDIATO ad ACCUMULATORE               }
 If ((Code[2]='AX')Or(Code[2]='AL')) And Val2 Then
  Begin
   Nmc:=Nmc+1;
   S:='0';
   Mc[Nmc]:=Valore8Bit('&0000010'+W);
   If W='0' Then Date8(Dat) Else Date16(Dat);
  End Else
{  IMMEDIATO A REGISTRO               }
 If Reg1 And Val2 Then
  Begin
   Nmc:=Nmc+1;
   S:='0';
   Mc[Nmc]:=Valore8Bit('&100000'+S+W);
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&11'+'000'+R_M);
   If W='0' Then Date8(Dat) Else Date16(Dat);
  End Else
{ IMMEDIATO a MEMORIA }
 If Mem1 And Val2 Then
  Begin
   Nmc:=Nmc+1;
   S:='0';
   Mc[Nmc]:=Valore8Bit('&100000'+S+W);
   If Adr1 Then
    Begin
     Nmc:=Nmc+1;
     Mc[Nmc]:=Valore8Bit('&'+'00'+'000'+'110');
     Variable(Ad1);
    End Else
    Begin
     Nmc:=Nmc+1;
     Mc[Nmc]:=Valore8Bit('&'+Mde+'000'+R_M);
     If Mde='01' Then Date8(Disp) Else
     If Mde='10' Then Date16(Disp);
    End;
   If W='0' Then Date8(Dat) Else Date16(Dat);
  End Else
   Errore('Operandi errati.');
End;

Procedure I_Sbb;
Begin
 ExamineAndControlOp2;
{  Da REGISTRO a REGISTRO             }
 If Reg1 And Reg2 Then
  Begin
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&000110'+D+W);
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&'+Mde+Reg+R_M);
  End Else
{ Da MEMORIA a REGISTRO e viceversa }
 If (Mem1 And Reg2)Or(Mem2 And Reg1) Then
  Begin
   If Reg1 Then D:='1' Else D:='0';
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&000110'+D+W);
   If Adr1 Or Adr2 Then
    Begin
     Nmc:=Nmc+1;
     Mc[Nmc]:=Valore8Bit('&00'+Reg+'110');
     If Mem2 Then Ad1:=Ad2;
     Variable(Ad1);
    End Else
    Begin
     Nmc:=Nmc+1;
     Mc[Nmc]:=Valore8Bit('&'+Mde+Reg+R_M);
     If Mde='01' Then Date8(Disp) Else
     If Mde='10' Then Date16(Disp);
    End;
  End Else
{  IMMEDIATO ad ACCUMULATORE               }
 If ((Code[2]='AX')Or(Code[2]='AL')) And Val2 Then
  Begin
   Nmc:=Nmc+1;
   S:='0';
   Mc[Nmc]:=Valore8Bit('&0001110'+W);
   If W='0' Then Date8(Dat) Else Date16(Dat);
  End Else
{  IMMEDIATO A REGISTRO               }
 If Reg1 And Val2 Then
  Begin
   Nmc:=Nmc+1;
   S:='0';
   Mc[Nmc]:=Valore8Bit('&100000'+S+W);
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&11'+'011'+R_M);
   If W='0' Then Date8(Dat) Else Date16(Dat);
  End Else
{ IMMEDIATO a MEMORIA }
 If Mem1 And Val2 Then
  Begin
   Nmc:=Nmc+1;
   S:='0';
   Mc[Nmc]:=Valore8Bit('&100000'+S+W);
   If Adr1 Then
    Begin
     Nmc:=Nmc+1;
     Mc[Nmc]:=Valore8Bit('&'+'00'+'011'+'110');
     Variable(Ad1);
    End Else
    Begin
     Nmc:=Nmc+1;
     Mc[Nmc]:=Valore8Bit('&'+Mde+'011'+R_M);
     If Mde='01' Then Date8(Disp) Else
     If Mde='10' Then Date16(Disp);
    End;
   If W='0' Then Date8(Dat) Else Date16(Dat);
  End Else
   Errore('Operandi errati.');
End;

Procedure I_Dec;
Begin
 ExamineAndControlOp1;
{ REGISTRO a 16 bit  }
 If R1_16 Then
  Begin
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&01001'+Reg);
  End Else
{ REGISTRO normale   }
 If Reg1 Then
  Begin
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&1111111'+W);
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&11'+'001'+Reg);
  End Else
{ MEMORIA }
 If Mem1 Then
  Begin
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&1111111'+W);
   If Adr1 Then
    Begin
     Nmc:=Nmc+1;
     Mc[Nmc]:=Valore8Bit('&'+'00'+'001'+'110');
     Variable(Ad1);
    End Else
    Begin
     Nmc:=Nmc+1;
     Mc[Nmc]:=Valore8Bit('&'+Mde+'001'+R_M);
     If Mde='01' Then Date8(Disp) Else
     If Mde='10' Then Date16(Disp);
    End;
  End Else
   Errore('Non sono ammessi parametri del genere con questa istruzione.');
End;

Procedure I_Inc;
Begin
 ExamineAndControlOp1;
{ REGISTRO a 16 bit  }
 If R1_16 Then
  Begin
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&01000'+Reg);
  End Else
{ REGISTRO normale   }
 If Reg1 Then
  Begin
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&1111111'+W);
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&11'+'000'+Reg);
  End Else
{ MEMORIA }
 If Mem1 Then
  Begin
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&1111111'+W);
   If Adr1 Then
    Begin
     Nmc:=Nmc+1;
     Mc[Nmc]:=Valore8Bit('&'+'00'+'000'+'110');
     Variable(Ad1);
    End Else
    Begin
     Nmc:=Nmc+1;
     Mc[Nmc]:=Valore8Bit('&'+Mde+'000'+R_M);
     If Mde='01' Then Date8(Disp) Else
     If Mde='10' Then Date16(Disp);
    End;
  End Else
   Errore('Non sono ammessi parametri del genere con questa istruzione.');
End;

Procedure I_Neg;
Begin
 ExamineAndControlOp1;
{ REGISTRO normale   }
 If Reg1 Then
  Begin
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&1111011'+W);
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&11'+'011'+Reg);
  End Else
{ MEMORIA }
 If Mem1 Then
  Begin
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&1111011'+W);
   If Adr1 Then
    Begin
     Nmc:=Nmc+1;
     Mc[Nmc]:=Valore8Bit('&'+'00'+'011'+'110');
     Variable(Ad1);
    End Else
    Begin
     Nmc:=Nmc+1;
     Mc[Nmc]:=Valore8Bit('&'+Mde+'011'+R_M);
     If Mde='01' Then Date8(Disp) Else
     If Mde='10' Then Date16(Disp);
    End;
  End Else
   Errore('Non sono ammessi parametri del genere con questa istruzione.');
End;

Procedure I_Not;
Begin
 ExamineAndControlOp1;
{ REGISTRO normale   }
 If Reg1 Then
  Begin
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&1111011'+W);
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&11'+'010'+Reg);
  End Else
{ MEMORIA }
 If Mem1 Then
  Begin
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&1111011'+W);
   If Adr1 Then
    Begin
     Nmc:=Nmc+1;
     Mc[Nmc]:=Valore8Bit('&'+'00'+'010'+'110');
     Variable(Ad1);
    End Else
    Begin
     Nmc:=Nmc+1;
     Mc[Nmc]:=Valore8Bit('&'+Mde+'010'+R_M);
     If Mde='01' Then Date8(Disp) Else
     If Mde='10' Then Date16(Disp);
    End;
  End Else
   Errore('Non sono ammessi parametri del genere con questa istruzione.');
End;

Procedure I_Mul;
Begin
 ExamineAndControlOp2;
{ REGISTRO normale   }
 If Reg1 Then
  Begin
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&1111011'+W);
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&11'+'100'+Reg);
  End Else
{ MEMORIA }
 If Mem1 Then
  Begin
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&1111011'+W);
   If Adr1 Then
    Begin
     Nmc:=Nmc+1;
     Mc[Nmc]:=Valore8Bit('&'+'00'+'100'+'110');
     Variable(Ad1);
    End Else
    Begin
     Nmc:=Nmc+1;
     Mc[Nmc]:=Valore8Bit('&'+Mde+'100'+R_M);
     If Mde='01' Then Date8(Disp) Else
     If Mde='10' Then Date16(Disp);
    End;
  End Else
   Errore('Non sono ammessi parametri del genere con questa istruzione.');
End;

Procedure I_IMul;
Begin
 ExamineAndControlOp2;
{ REGISTRO normale   }
 If Reg1 Then
  Begin
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&1111011'+W);
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&11'+'101'+Reg);
  End Else
{ MEMORIA }
 If Mem1 Then
  Begin
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&1111011'+W);
   If Adr1 Then
    Begin
     Nmc:=Nmc+1;
     Mc[Nmc]:=Valore8Bit('&'+'00'+'101'+'110');
     Variable(Ad1);
    End Else
    Begin
     Nmc:=Nmc+1;
     Mc[Nmc]:=Valore8Bit('&'+Mde+'101'+R_M);
     If Mde='01' Then Date8(Disp) Else
     If Mde='10' Then Date16(Disp);
    End;
  End Else
   Errore('Non sono ammessi parametri del genere con questa istruzione.');
End;


Procedure I_Div;
Begin
 ExamineAndControlOp2;
{ REGISTRO normale   }
 If Reg1 Then
  Begin
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&1111011'+W);
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&11'+'110'+Reg);
  End Else
{ MEMORIA }
 If Mem1 Then
  Begin
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&1111011'+W);
   If Adr1 Then
    Begin
     Nmc:=Nmc+1;
     Mc[Nmc]:=Valore8Bit('&'+'00'+'110'+'110');
     Variable(Ad1);
    End Else
    Begin
     Nmc:=Nmc+1;
     Mc[Nmc]:=Valore8Bit('&'+Mde+'110'+R_M);
     If Mde='01' Then Date8(Disp) Else
     If Mde='10' Then Date16(Disp);
    End;
  End Else
   Errore('Non sono ammessi parametri del genere con questa istruzione.');
End;

Procedure I_IDiv;
Begin
 ExamineAndControlOp2;
{ REGISTRO normale   }
 If Reg1 Then
  Begin
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&1111011'+W);
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&11'+'111'+Reg);
  End Else
{ MEMORIA }
 If Mem1 Then
  Begin
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&1111011'+W);
   If Adr1 Then
    Begin
     Nmc:=Nmc+1;
     Mc[Nmc]:=Valore8Bit('&'+'00'+'111'+'110');
     Variable(Ad1);
    End Else
    Begin
     Nmc:=Nmc+1;
     Mc[Nmc]:=Valore8Bit('&'+Mde+'111'+R_M);
     If Mde='01' Then Date8(Disp) Else
     If Mde='10' Then Date16(Disp);
    End;
  End Else
   Errore('Non sono ammessi parametri del genere con questa istruzione.');
End;


Procedure I_Cmp;
Begin
 ExamineAndControlOp2;
{  Da REGISTRO a REGISTRO             }
 If Reg1 And Reg2 Then
  Begin
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&001110'+D+W);
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&'+Mde+Reg+R_M);
  End Else
{ Da MEMORIA a REGISTRO e viceversa }
 If (Mem1 And Reg2)Or(Mem2 And Reg1) Then
  Begin
   If Reg1 Then D:='1' Else D:='0';
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&001110'+D+W);
   If Adr1 Or Adr2 Then
    Begin
     Nmc:=Nmc+1;
     Mc[Nmc]:=Valore8Bit('&00'+Reg+'110');
     If Mem2 Then Ad1:=Ad2;
     Variable(Ad1);
    End Else
    Begin
     Nmc:=Nmc+1;
     Mc[Nmc]:=Valore8Bit('&'+Mde+Reg+R_M);
     If Mde='01' Then Date8(Disp) Else
     If Mde='10' Then Date16(Disp);
    End;
  End Else
{  IMMEDIATO ad ACCUMULATORE               }
 If ((Code[2]='AX')Or(Code[2]='AL')) And Val2 Then
  Begin
   Nmc:=Nmc+1;
   S:='0';
   Mc[Nmc]:=Valore8Bit('&0111100'+W);
   If W='0' Then Date8(Dat) Else Date16(Dat);
  End Else
{  IMMEDIATO A REGISTRO               }
 If Reg1 And Val2 Then
  Begin
   Nmc:=Nmc+1;
   S:='0';
   Mc[Nmc]:=Valore8Bit('&100000'+S+W);
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&11'+'111'+R_M);
   If W='0' Then Date8(Dat) Else Date16(Dat);
  End Else
{ IMMEDIATO a MEMORIA }
 If Mem1 And Val2 Then
  Begin
   Nmc:=Nmc+1;
   S:='0';
   Mc[Nmc]:=Valore8Bit('&100000'+S+W);
   If Adr1 Then
    Begin
     Nmc:=Nmc+1;
     Mc[Nmc]:=Valore8Bit('&'+'00'+'111'+'110');
     Variable(Ad1);
    End Else
    Begin
     Nmc:=Nmc+1;
     Mc[Nmc]:=Valore8Bit('&'+Mde+'111'+R_M);
     If Mde='01' Then Date8(Disp) Else
     If Mde='10' Then Date16(Disp);
    End;
   If W='0' Then Date8(Dat) Else Date16(Dat);
  End Else
   Errore('Operandi errati.');
End;

Procedure I_Adc;
Begin
 ExamineAndControlOp2;
{  Da REGISTRO a REGISTRO             }
 If Reg1 And Reg2 Then
  Begin
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&000100'+D+W);
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&'+Mde+Reg+R_M);
  End Else
{ Da MEMORIA a REGISTRO e viceversa }
 If (Mem1 And Reg2)Or(Mem2 And Reg1) Then
  Begin
   If Reg1 Then D:='1' Else D:='0';
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&000100'+D+W);
   If Adr1 Or Adr2 Then
    Begin
     Nmc:=Nmc+1;
     Mc[Nmc]:=Valore8Bit('&00'+Reg+'110');
     If Mem2 Then Ad1:=Ad2;
     Variable(Ad1);
    End Else
    Begin
     Nmc:=Nmc+1;
     Mc[Nmc]:=Valore8Bit('&'+Mde+Reg+R_M);
     If Mde='01' Then Date8(Disp) Else
     If Mde='10' Then Date16(Disp);
    End;
  End Else
{  IMMEDIATO ad ACCUMULATORE               }
 If ((Code[2]='AX')Or(Code[2]='AL')) And Val2 Then
  Begin
   Nmc:=Nmc+1;
   S:='0';
   Mc[Nmc]:=Valore8Bit('&0001010'+W);
   If W='0' Then Date8(Dat) Else Date16(Dat);
  End Else
{  IMMEDIATO A REGISTRO               }
 If Reg1 And Val2 Then
  Begin
   Nmc:=Nmc+1;
   S:='0';
   Mc[Nmc]:=Valore8Bit('&100000'+S+W);
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&11'+'010'+R_M);
   If W='0' Then Date8(Dat) Else Date16(Dat);
  End Else
{ IMMEDIATO a MEMORIA }
 If Mem1 And Val2 Then
  Begin
   Nmc:=Nmc+1;
   S:='0';
   Mc[Nmc]:=Valore8Bit('&100000'+S+W);
   If Adr1 Then
    Begin
     Nmc:=Nmc+1;
     Mc[Nmc]:=Valore8Bit('&'+'00'+'010'+'110');
     Variable(Ad1);
    End Else
    Begin
     Nmc:=Nmc+1;
     Mc[Nmc]:=Valore8Bit('&'+Mde+'010'+R_M);
     If Mde='01' Then Date8(Disp) Else
     If Mde='10' Then Date16(Disp);
    End;
   If W='0' Then Date8(Dat) Else Date16(Dat);
  End Else
   Errore('Operandi errati.');
End;


Procedure I_Sub;
Begin
 ExamineAndControlOp2;
{  Da REGISTRO a REGISTRO             }
 If Reg1 And Reg2 Then
  Begin
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&001010'+D+W);
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&'+Mde+Reg+R_M);
  End Else
{ Da MEMORIA a REGISTRO e viceversa }
 If (Mem1 And Reg2)Or(Mem2 And Reg1) Then
  Begin
   If Reg1 Then D:='1' Else D:='0';
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&001010'+D+W);
   If Adr1 Or Adr2 Then
    Begin
     Nmc:=Nmc+1;
     Mc[Nmc]:=Valore8Bit('&00'+Reg+'110');
     If Mem2 Then Ad1:=Ad2;
     Variable(Ad1);
    End Else
    Begin
     Nmc:=Nmc+1;
     Mc[Nmc]:=Valore8Bit('&'+Mde+Reg+R_M);
     If Mde='01' Then Date8(Disp) Else
     If Mde='10' Then Date16(Disp);
    End;
  End Else
{  IMMEDIATO ad ACCUMULATORE               }
 If ((Code[2]='AX')Or(Code[2]='AL')) And Val2 Then
  Begin
   Nmc:=Nmc+1;
   S:='0';
   Mc[Nmc]:=Valore8Bit('&0010110'+W);
   If W='0' Then Date8(Dat) Else Date16(Dat);
  End Else
{  IMMEDIATO A REGISTRO               }
 If Reg1 And Val2 Then
  Begin
   Nmc:=Nmc+1;
   S:='0';
   Mc[Nmc]:=Valore8Bit('&100000'+S+W);
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&11'+'101'+R_M);
   If W='0' Then Date8(Dat) Else Date16(Dat);
  End Else
{ IMMEDIATO a MEMORIA }
 If Mem1 And Val2 Then
  Begin
   Nmc:=Nmc+1;
   S:='0';
   Mc[Nmc]:=Valore8Bit('&100000'+S+W);
   If Adr1 Then
    Begin
     Nmc:=Nmc+1;
     Mc[Nmc]:=Valore8Bit('&'+'00'+'101'+'110');
     Variable(Ad1);
    End Else
    Begin
     Nmc:=Nmc+1;
     Mc[Nmc]:=Valore8Bit('&'+Mde+'101'+R_M);
     If Mde='01' Then Date8(Disp) Else
     If Mde='10' Then Date16(Disp);
    End;
   If W='0' Then Date8(Dat) Else Date16(Dat);
  End Else
   Errore('Operandi errati.');
End;


Procedure I_Mov;
Begin
 ExamineAndControlOp2;
{  Da REGISTRO a REGISTRO             }
 If Reg1 And Reg2 Then
  Begin
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&100010'+D+W);
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&'+Mde+Reg+R_M);
  End Else
{  Da REGISTRO di SEGMENTO a REGISTRO o viceversa }
 If (Reg1 And Seg2)Or(Seg1 And Reg2) Then
  Begin
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&100011'+D+'0');
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&'+Mde+'0'+Reg+R_M);
  End Else
{  Da ACCUMULATORE a MEMORIA o viceversa }
 If (Adr1 And ((Code[Nc]='AX')Or(Code[Nc]='AL'))) Or
    (Adr2 And ((Code[2]='AX')Or(Code[2]='AL')))  Then
  Begin
   If Adr1 And Reg2 Then D:='1' Else D:='0';
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&101000'+D+W);
   If Mem2 Then Ad1:=Ad2;
   Variable(Ad1);
  End Else
{ Da MEMORIA a REGISTRO e viceversa }
 If (Mem1 And Reg2)Or(Mem2 And Reg1) Then
  Begin
   If Reg1 Then D:='1' Else D:='0';
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&100010'+D+W);
   If Adr1 Or Adr2 Then
    Begin
     Nmc:=Nmc+1;
     Mc[Nmc]:=Valore8Bit('&00'+Reg+'110');
     If Mem2 Then Ad1:=Ad2;
     Variable(Ad1);
    End Else
    Begin
     Nmc:=Nmc+1;
     Mc[Nmc]:=Valore8Bit('&'+Mde+Reg+R_M);
     If Mde='01' Then Date8(Disp) Else
     If Mde='10' Then Date16(Disp);
    End;
  End Else
{  Da REGISTRO di SEGMENTO a MEMORIA o viceversa }
 If (Mem1 And Seg2)Or(Mem2 And Seg1) Then
  Begin
   If Seg1 Then D:='1' Else D:='0';
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&100011'+D+'0');
   If Adr1 Or Adr2 Then
    Begin
     Nmc:=Nmc+1;
     Mc[Nmc]:=Valore8Bit('&00'+'0'+Reg+'110');
     If Mem2 Then Ad1:=Ad2;
     Variable(Ad1);
    End Else
    Begin
     Nmc:=Nmc+1;
     Mc[Nmc]:=Valore8Bit('&'+Mde+'0'+Reg+R_M);
     If Mde='01' Then Date8(Disp) Else
     If Mde='10' Then Date16(Disp);
    End;
  End Else
{ IMMEDIATO a REGISTRO }
 If Reg1 And Val2 Then
  Begin
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&1011'+W+Reg);
   If W='0' Then Date8(Dat) Else Date16(Dat);
  End Else
{ IMMEDIATO a MEMORIA }
 If Mem1 And Val2 Then
  Begin
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&1100011'+W);
   If Adr1 Then
    Begin
     Nmc:=Nmc+1;
     Mc[Nmc]:=Valore8Bit('&'+'00'+'000'+'110');
     Variable(Ad1);
    End Else
    Begin
     Nmc:=Nmc+1;
     Mc[Nmc]:=Valore8Bit('&'+Mde+'000'+R_M);
     If Mde='01' Then Date8(Disp) Else
     If Mde='10' Then Date16(Disp);
    End;
   If W='0' Then Date8(Dat) Else Date16(Dat);
  End Else
 Errore('Questi operandi non possono operare insieme.');
End;





Procedure I_Push;
Begin
 ExamineAndControlOp1;
{ REGISTRO   }
 If Reg1 Then
  Begin
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&01010'+Reg);
  End Else
{ REGISTRO di SEGMENTO }
 If Seg1 Then
  Begin
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&000'+Reg+'110');
  End Else
{ MEMORIA }
 If Mem1 Then
  Begin
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&11111111');
   If Adr1 Then
    Begin
     Nmc:=Nmc+1;
     Mc[Nmc]:=Valore8Bit('&'+'00'+'110'+'110');
     Variable(Ad1);
    End Else
    Begin
     Nmc:=Nmc+1;
     Mc[Nmc]:=Valore8Bit('&'+Mde+'110'+R_M);
     If Mde='01' Then Date8(Disp) Else
     If Mde='10' Then Date16(Disp);
    End;
  End Else
   Errore('Non sono ammessi parametri del genere con questa istruzione.');
End;

Procedure I_Pop;
Begin
 ExamineAndControlOp1;
{ REGISTRO   }
 If Reg1 Then
  Begin
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&01011'+Reg);
  End Else
{ REGISTRO di SEGMENTO }
 If Seg1 Then
  Begin
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&000'+Reg+'111');
  End Else
{ MEMORIA }
 If Mem1 Then
  Begin
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&10001111');
   If Adr1 Then
    Begin
     Nmc:=Nmc+1;
     Mc[Nmc]:=Valore8Bit('&'+'00'+'000'+'110');
     Variable(Ad1);
    End Else
    Begin
     Nmc:=Nmc+1;
     Mc[Nmc]:=Valore8Bit('&'+Mde+'000'+R_M);
     If Mde='01' Then Date8(Disp) Else
     If Mde='10' Then Date16(Disp);
    End;
  End Else
   Errore('Non sono ammessi parametri del genere con questa istruzione.');
End;

Procedure I_InB;
Begin
 Nmc:=0;
 If Code[2]='DX' Then
  Begin
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&11101100');
  End Else
 If IsNumero(Code[2]) Then
  Begin
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&11100100');
   Ad1:=Valore16Bit(Code[2]);
   Date16(Ad1);
  End Else Errore('Atteso registro DX oppure indirizzo porta di I/O.');
End;
Procedure I_InW;
Begin
 Nmc:=0;
 If Code[2]='DX' Then
  Begin
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&11101101');
  End Else
 If IsNumero(Code[2]) Then
  Begin
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&11100101');
   Ad1:=Valore16Bit(Code[2]);
   Date16(Ad1);
  End Else Errore('Atteso registro DX oppure indirizzo porta di I/O.');
End;
Procedure I_OutB;
Begin
 Nmc:=0;
 If Code[2]='DX' Then
  Begin
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&11101110');
  End Else
 If IsNumero(Code[2]) Then
  Begin
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&11100110');
   Ad1:=Valore16Bit(Code[2]);
   Date16(Ad1);
  End Else Errore('Atteso registro DX oppure indirizzo porta di I/O.');
End;
Procedure I_OutW;
Begin
 Nmc:=0;
 If Code[2]='DX' Then
  Begin
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&11101110');
  End Else
 If IsNumero(Code[2]) Then
  Begin
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&11100110');
   Ad1:=Valore16Bit(Code[2]);
   Date16(Ad1);
  End Else Errore('Atteso registro DX oppure indirizzo porta di I/O.');
End;

Procedure I_Xchg;
Begin
 ExamineAndControlOp2;
{  Da ACCUMULATORE a REGISTRO         }
 If ((Code[2]='AX')And Reg2)Or((Code[Nc]='AX')And Reg1) Then
  Begin
   Nmc:=Nmc+1;
   If Code[2]='AX' Then Reg:=R_M;
   Mc[Nmc]:=Valore8Bit('&10010'+Reg);
  End Else
{  Da REGISTRO a REGISTRO             }
 If Reg1 And Reg2 Then
  Begin
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&1000011'+W);
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&'+Mde+Reg+R_M);
  End Else
{ Da MEMORIA a REGISTRO e viceversa.   }
 If (Mem1 And Reg2)Or(Mem2 And Reg1) Then
  Begin
   If Reg1 Then D:='1' Else D:='0';
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&1000011'+W);
   If Adr1 Or Adr2 Then
    Begin
     Nmc:=Nmc+1;
     Mc[Nmc]:=Valore8Bit('&00'+Reg+'110');
     If Mem2 Then Ad1:=Ad2;
     Variable(Ad1);
    End Else
    Begin
     Nmc:=Nmc+1;
     Mc[Nmc]:=Valore8Bit('&'+Mde+Reg+R_M);
     If Mde='01' Then Date8(Disp) Else
     If Mde='10' Then Date16(Disp);
    End;
  End Else
   Errore('Parametro dell''istruzione errato.');
End;


Procedure I_Lea;
Begin
 ExamineAndControlOp2;
{ Indirizzo nel REGISTRO della memoria  }
 If Reg1 And Mem2 Then
  Begin
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&10001101');
   If Adr2 Then
    Begin
     Nmc:=Nmc+1;
     Mc[Nmc]:=Valore8Bit('&00'+Reg+'110');
     If Mem2 Then Ad1:=Ad2;
     Variable(Ad1);
    End Else
    Begin
     Nmc:=Nmc+1;
     Mc[Nmc]:=Valore8Bit('&'+Mde+Reg+R_M);
     If Mde='01' Then Date8(Disp) Else
     If Mde='10' Then Date16(Disp);
    End;
  End Else
   Errore('Parametro dell''istruzione errato.');
End;

Procedure I_Lds;
Begin
 ExamineAndControlOp2;
{ Indirizzo nel REGISTRO della memoria  }
 If Reg1 And Mem2 Then
  Begin
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&11000101');
   If Adr2 Then
    Begin
     Nmc:=Nmc+1;
     Mc[Nmc]:=Valore8Bit('&00'+Reg+'110');
     If Mem2 Then Ad1:=Ad2;
     Variable(Ad1);
    End Else
    Begin
     Nmc:=Nmc+1;
     Mc[Nmc]:=Valore8Bit('&'+Mde+Reg+R_M);
     If Mde='01' Then Date8(Disp) Else
     If Mde='10' Then Date16(Disp);
    End;
  End Else
   Errore('Parametro dell''istruzione errato.');
End;
Procedure I_Les;
Begin
 ExamineAndControlOp2;
{ Indirizzo nel REGISTRO della memoria  }
 If Reg1 And Mem2 Then
  Begin
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&11000100');
   If Adr2 Then
    Begin
     Nmc:=Nmc+1;
     Mc[Nmc]:=Valore8Bit('&00'+Reg+'110');
     If Mem2 Then Ad1:=Ad2;
     Variable(Ad1);
    End Else
    Begin
     Nmc:=Nmc+1;
     Mc[Nmc]:=Valore8Bit('&'+Mde+Reg+R_M);
     If Mde='01' Then Date8(Disp) Else
     If Mde='10' Then Date16(Disp);
    End;
  End Else
   Errore('Parametro dell''istruzione errato.');
End;


Procedure Rotate(Rot:String);
Begin
 ExamineAndControlOp2;
 If Code[Nc]='1' Then V:='0' Else
 If Code[Nc]='CL' Then V:='1' Else
   Errore('Atteso valore 1 oppure registro CL.');
{ REGISTRO normale   }
 If Reg1 Then
  Begin
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&110100'+V+W);
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&11'+Rot+Reg);
  End Else
{ MEMORIA }
 If Mem1 Then
  Begin
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&110100'+V+W);
   If Adr1 Then
    Begin
     Nmc:=Nmc+1;
     Mc[Nmc]:=Valore8Bit('&'+'00'+Rot+'110');
     Variable(Ad1);
    End Else
    Begin
     Nmc:=Nmc+1;
     Mc[Nmc]:=Valore8Bit('&'+Mde+Rot+R_M);
     If Mde='01' Then Date8(Disp) Else
     If Mde='10' Then Date16(Disp);
    End;
  End Else
   Errore('Non sono ammessi parametri del genere con questa istruzione.');
End;

Procedure Logic(RegMem,Ime,Iac,Cod2:String);
Begin
 ExamineAndControlOp2;
 If Code[1]='TEST' Then D:='0';
{  Da REGISTRO a REGISTRO             }
 If Reg1 And Reg2 Then
  Begin
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&'+RegMem+D+W);
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&'+Mde+Reg+R_M);
  End Else
{ Da MEMORIA a REGISTRO e viceversa }
 If (Mem1 And Reg2)Or(Mem2 And Reg1) Then
  Begin
   If Reg1 Then D:='1' Else D:='0';
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&'+RegMem+D+W);
   If Adr1 Or Adr2 Then
    Begin
     Nmc:=Nmc+1;
     Mc[Nmc]:=Valore8Bit('&00'+Reg+'110');
     If Mem2 Then Ad1:=Ad2;
     Variable(Ad1);
    End Else
    Begin
     Nmc:=Nmc+1;
     Mc[Nmc]:=Valore8Bit('&'+Mde+Reg+R_M);
     If Mde='01' Then Date8(Disp) Else
     If Mde='10' Then Date16(Disp);
    End;
  End Else
{  IMMEDIATO ad ACCUMULATORE               }
 If ((Code[2]='AX')Or(Code[2]='AL')) And Val2 Then
  Begin
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&'+Iac+W);
   If W='0' Then Date8(Dat) Else Date16(Dat);
  End Else
{  IMMEDIATO A REGISTRO               }
 If Reg1 And Val2 Then
  Begin
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&'+Ime+W);
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&11'+Cod2+R_M);
   If W='0' Then Date8(Dat) Else Date16(Dat);
  End Else
{ IMMEDIATO a MEMORIA }
 If Mem1 And Val2 Then
  Begin
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&'+Ime+W);
   If Adr1 Then
    Begin
     Nmc:=Nmc+1;
     Mc[Nmc]:=Valore8Bit('&'+'00'+Cod2+'110');
     Variable(Ad1);
    End Else
    Begin
     Nmc:=Nmc+1;
     Mc[Nmc]:=Valore8Bit('&'+Mde+Cod2+R_M);
     If Mde='01' Then Date8(Disp) Else
     If Mde='10' Then Date16(Disp);
    End;
   If W='0' Then Date8(Dat) Else Date16(Dat);
  End Else
   Errore('Operandi errati.');
End;



Procedure I_Rep;
 Var Cods:String;
Begin
 Nmc:=0;
 If Nc=1 Then Errore('Era atteso un parametro');
 If Nc>2 Then Errore('Troppi parametri nell''istruzione.');
 If Code[1]='REP' Then Z:='0' Else Z:='1';
 Nmc:=Nmc+1;
 Mc[Nmc]:=Valore8Bit('&1111001'+Z);
 If Code[2]='MOVSB' Then Cods:='10100100' Else
 If Code[2]='MOVSW' Then Cods:='10100101' Else
 If Code[2]='CMPSB' Then Cods:='10100110' Else
 If Code[2]='CMPSW' Then Cods:='10100111' Else
 If Code[2]='SCASB' Then Cods:='10101110' Else
 If Code[2]='SCASW' Then Cods:='10101111' Else
 If Code[2]='LODSB' Then Cods:='10101100' Else
 If Code[2]='LODSW' Then Cods:='10101101' Else
 If Code[2]='STOSB' Then Cods:='10101010' Else
 If Code[2]='STOSW' Then Cods:='10101011' Else
  Errore('Errata sintassi nell''istruzione');
 Nmc:=Nmc+1;
 Mc[Nmc]:=Valore8Bit('&'+Cods);
End;

Procedure I_Int;
Begin
 Nmc:=0;
 If Nc=1 Then Errore('Era atteso un valore.');
 If Nc>2 Then Errore('Troppi parametri nell''istruzione.');
 If Not IsNumero(Code[2]) Then Errore('Atteso un valore numerico.');
 Nmc:=Nmc+1;
 Mc[Nmc]:=Valore8Bit('&11001101');
 Dat:=Valore16Bit(Code[2]);
 If Dat>255 Then Errore('Le interruzioni vanno da 0 a 255.');
 Date8(Dat);
End;

Procedure Salto(Cods:String);
Begin
 Nmc:=0;
 If Nc=1 Then Errore('Era atteso un valore.');
 If Nc>2 Then Errore('Troppi parametri nell''istruzione.');
 If Not IsNumero(Code[2]) Then Errore('Atteso un valore numerico.');
 Nmc:=Nmc+1;
 Mc[Nmc]:=Valore8Bit('&'+Cods);
 Dat:=Valore16Bit(Code[2]);
 If Dat>255 Then Errore('Il salto Š troppo lungo.');
 Date8(Dat);
End;


Procedure I_Ret;
Begin
 Nmc:=0;
 If Nc>2 Then Errore('Troppi parametri nell''istruzione.');
 If Not IsNumero(Code[2]) And (Nc=2) Then
  Errore('Atteso un valore numerico.');
 Nmc:=Nmc+1;
 If Nc=2 Then
  Begin
   Mc[Nmc]:=Valore8Bit('&11000010');
   Dat:=Valore16Bit(Code[2]);
   Date16(Dat);
  End Else Mc[Nmc]:=Valore8Bit('&11000011');
End;


Procedure I_RetFar;
Begin
 Nmc:=0;
 If Nc>2 Then Errore('Troppi parametri nell''istruzione.');
 If Not IsNumero(Code[2]) And (Nc=2) Then
  Errore('Atteso un valore numerico.');
 Nmc:=Nmc+1;
 If Nc=2 Then
  Begin
   Mc[Nmc]:=Valore8Bit('&11001010');
   Dat:=Valore16Bit(Code[2]);
   Date16(Dat);
  End Else Mc[Nmc]:=Valore8Bit('&11001011');
End;


Procedure I_Jump;
Begin
 Nmc:=0;
{ SALTO immediato    }
 If IsNumero(Code[2]) Then
  Begin
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&11101001');
   Dat:=Valore16Bit(Code[2]);
   Date16(Dat);
  End Else
  Begin
  ExamineAndControlOp1;
{ REGISTRO normale   }
 If Reg1 Then
  Begin
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&11111111');
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&11'+'100'+Reg);
  End Else
{ MEMORIA }
 If Mem1 Then
  Begin
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&11111111');
   If Adr1 Then
    Begin
     Nmc:=Nmc+1;
     Mc[Nmc]:=Valore8Bit('&'+'00'+'100'+'110');
     Variable(Ad1);
    End Else
    Begin
     Nmc:=Nmc+1;
     Mc[Nmc]:=Valore8Bit('&'+Mde+'100'+R_M);
     If Mde='01' Then Date8(Disp) Else
     If Mde='10' Then Date16(Disp);
    End;
  End Else
   Errore('Non sono ammessi parametri del genere con questa istruzione.');
  End;
End;

Procedure I_Call;
Begin
 Nmc:=0;
{ SALTO immediato    }
 If IsNumero(Code[2]) Then
  Begin

   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&11101000');
   Dat:=Valore16Bit(Code[2]);
   Date16(Dat);
  End Else
  Begin
  ExamineAndControlOp1;
{ REGISTRO normale   }
 If Reg1 Then
  Begin
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&11111111');
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&11'+'010'+Reg);
  End Else
{ MEMORIA }
 If Mem1 Then
  Begin
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&11111111');
   If Adr1 Then
    Begin
     Nmc:=Nmc+1;
     Mc[Nmc]:=Valore8Bit('&'+'00'+'010'+'110');
     Variable(Ad1);
    End Else
    Begin
     Nmc:=Nmc+1;
     Mc[Nmc]:=Valore8Bit('&'+Mde+'010'+R_M);
     If Mde='01' Then Date8(Disp) Else
     If Mde='10' Then Date16(Disp);
    End;
  End Else
   Errore('Non sono ammessi parametri del genere con questa istruzione.');
  End;
End;

Procedure I_JumpFar;
Begin
 Nmc:=0;
{ SALTO immediato    }
 If IsNumero(Code[2]) Then
  Begin
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&11101010');
   Dat:=Valore16Bit(Code[2]);
   Date16(Dat);
   Dat:=Valore16Bit(Code[4]);
   Date16(Dat);
  End Else
  Begin
  ExamineAndControlOp1;
{ REGISTRO normale   }
 If Reg1 Then
  Begin
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&11111111');
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&11'+'101'+Reg);
  End Else
{ MEMORIA }
 If Mem1 Then
  Begin
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&11111111');
   If Adr1 Then
    Begin
     Nmc:=Nmc+1;
     Mc[Nmc]:=Valore8Bit('&'+'00'+'101'+'110');
     Variable(Ad1);
    End Else
    Begin
     Nmc:=Nmc+1;
     Mc[Nmc]:=Valore8Bit('&'+Mde+'101'+R_M);
     If Mde='01' Then Date8(Disp) Else
     If Mde='10' Then Date16(Disp);
    End;
  End Else
   Errore('Non sono ammessi parametri del genere con questa istruzione.');
  End;
End;



Procedure I_CallFar;
Begin
 Nmc:=0;
{ SALTO immediato    }
 If IsNumero(Code[2]) Then
  Begin
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&10011010');
   Dat:=Valore16Bit(Code[2]);
   Date16(Dat);
   Dat:=Valore16Bit(Code[4]);
   Date16(Dat);
  End Else
  Begin
  ExamineAndControlOp1;
{ REGISTRO normale   }
 If Reg1 Then
  Begin
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&11111111');
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&11'+'011'+Reg);
  End Else
{ MEMORIA }
 If Mem1 Then
  Begin
   Nmc:=Nmc+1;
   Mc[Nmc]:=Valore8Bit('&11111111');
   If Adr1 Then
    Begin
     Nmc:=Nmc+1;
     Mc[Nmc]:=Valore8Bit('&'+'00'+'011'+'110');
     Variable(Ad1);
    End Else
    Begin
     Nmc:=Nmc+1;
     Mc[Nmc]:=Valore8Bit('&'+Mde+'011'+R_M);
     If Mde='01' Then Date8(Disp) Else
     If Mde='10' Then Date16(Disp);
    End;
  End Else
   Errore('Non sono ammessi parametri del genere con questa istruzione.');
 End;
End;

Procedure I_DByte;
Var Val,I:Word;
Begin
 Nmc:=0;
 I:=2;
 While I<=Nc Do
  Begin
   If Not IsNumero(Code[I]) Then Errore('Era atteso un dato a 8 Bit.');
   Val:=Valore16Bit(Code[I]);
   If Val>255 Then Errore('Il valore immesso Š troppo grande.');
   I:=I+1;
   Nmc:=Nmc+1;
   Mc[Nmc]:=Val;
   If (Code[I]<>',')And(I<=NC) Then Errore('Era attesa fine della riga oppure virgola.');
   I:=I+1;
  End;
End;

Procedure I_DWord;
Var Val,I:Word;
Begin
 Nmc:=0;
 I:=2;
 While I<=Nc Do
  Begin
   If Not IsNumero(Code[I]) Then Errore('Era atteso un dato a 16 Bit.');
   Val:=Valore16Bit(Code[I]);
   I:=I+1;
   Date16(Val);
   If (Code[I]<>',')And(I<=NC) Then Errore('Era attesa fine della riga oppure virgola.');
   I:=I+1;
  End;
End;




Procedure I_Enter;
Var Val:Word;
Begin
 Nmc:=1;
 Mc[Nmc]:=$C8;
 If Nc<4 Then Errore('Pochi parametri nell''istruzione.');
 If Not IsNumero(Code[2]) Or Not IsNumero(Code[4]) Then
  Errore('Questa istruzione richiede un dato a 16Bit e uno a 8Bit.');
 If Code[3]<>',' Then Errore('Era richiesto separatore virgola.');
 Val:=Valore16Bit(Code[2]);
 Date16(Val);
 Val:=Valore16Bit(Code[4]);
 If Val>255 Then Errore('Valore troppo grande.');
 Nmc:=Nmc+1;
 Mc[Nmc]:=Val;
End;

Procedure I_Leave;
Begin
 Nmc:=1;
 Mc[Nmc]:=$C9;
End;

{CodString}

Function Esiste(Nomefile:String):Boolean;
 Var
  F:File;
Begin
 {$I-}
 Assign(F,NomeFile);
 Reset(F);
 Close(F);
 {$I+}
 Esiste:=(Ioresult=0)And(NomeFile<>'');
End;

Function Maiusc(Ch:Char):Char;
Begin
 If (Ord(Ch)>=97)And(Ord(Ch)<=122)Then Maiusc:=Chr(Ord(Ch)-32) Else Maiusc:=Ch;
End;

Function StrMaiusc(S:String):String;
Var
 I:Word;
Begin
 For I:=1 to LengTh(S) do
  Begin
   S[I]:=Maiusc(S[I]);
  End;
 StrMaiusc:=S;
End;

Function Parola(Var S:String):String;
Var A:String;
Begin
 If LengTh(S)>0 Then
  Begin
   If IsSimbol(S[1]) Then
    Begin
     A:=S[1];
     S:=Copy(S,2,LengTh(S)-1);
    End Else
    Begin
     A:='';
     Repeat
      A:=A+S[1];
      S:=Copy(S,2,LengTh(S)-1);
     Until (LengTh(S)=0) Or (IsSimbol(S[1]));
    End;
  End Else A:='';
 Parola:=A;
End;

Procedure BusyCode(TxtString:String);
Var
 I:Word;
 S:String;
Begin
 For I:=1 To 100 Do ErrorStack[I]:='';
 ErrorCount:=0;
 For I:=1 To 256 Do Code[I]:='';
 TxtString:=StrMaiusc(TxtString);
 S:=TxtString;
 Nc:=0;
 While S>'' Do
  Begin
   AllSimbol:=True;
   Nc:=Nc+1;
   Code[Nc]:=Parola(S);
   If (Code[Nc]='') Or (Code[Nc]=' ') Then Nc:=Nc-1;
  End;
End;

Function Code8086(Istruzione:String; CompileRiga:Word):Boolean;
Var I:Integer;
    T:Boolean;
    E:Boolean;
Begin
 Riga:=CompileRiga;
 BusyCode(Istruzione);
 T:=False;
 I:=1;
 E:=True;
 While Not T And (I<=IOne) Do
  Begin
   If Code[1]=OneCode[I] Then
    Begin
     Nmc:=1;
     Mc[1]:=Bit8Bin(One8086[I]);
     T:=True;
    End Else I:=I+1;
  End;
 If Not T Then
  Begin
   If Code[1]='AAM' Then
    Begin
     Nmc:=2;
     Mc[1]:=Bit8Bin('&11010100');
     Mc[2]:=Bit8Bin('&00001010');
    End Else
   If Code[1]='AAD' Then
    Begin
     Nmc:=2;
     Mc[1]:=Bit8Bin('&11010101');
     Mc[2]:=Bit8Bin('&00001010');
    End Else
   If Code[1]='MOV'      Then I_Mov    Else
   If Code[1]='PUSH'     Then I_Push   Else
   If Code[1]='POP'      Then I_Pop    Else
   If Code[1]='INBYTE'   Then I_InB    Else
   If Code[1]='INWORD'   Then I_InW    Else
   If Code[1]='OUTBYTE'  Then I_OutB   Else
   If Code[1]='OUTWORD'  Then I_OutW   Else
   If Code[1]='XCHG'     Then I_Xchg   Else
   If Code[1]='LEA'      Then I_Lea    Else
   If Code[1]='LDS'      Then I_Lds    Else
   If Code[1]='LES'      Then I_Les    Else
   If Code[1]='ADD'      Then I_Add    Else
   If Code[1]='SBB'      Then I_Sbb    Else
   If Code[1]='DEC'      Then I_Dec    Else
   If Code[1]='NEG'      Then I_Neg    Else
   If Code[1]='CMP'      Then I_Cmp    Else
   If Code[1]='ADC'      Then I_Adc    Else
   If Code[1]='INC'      Then I_Inc    Else
   If Code[1]='SUB'      Then I_Sub    Else
   If Code[1]='MUL'      Then I_Mul    Else
   If Code[1]='IMUL'     Then I_IMul   Else
   If Code[1]='DIV'      Then I_Div    Else
   If Code[1]='IDIV'     Then I_IDiv   Else
   If Code[1]='NOT'      Then I_Not    Else

   If Code[1]='SHL'  Then Rotate('100') Else
   If Code[1]='SAL'  Then Rotate('100') Else
   If Code[1]='SHR'  Then Rotate('101') Else
   If Code[1]='SAR'  Then Rotate('111') Else
   If Code[1]='ROL'  Then Rotate('000') Else
   If Code[1]='ROR'  Then Rotate('001') Else
   If Code[1]='RCL'  Then Rotate('010') Else
   If Code[1]='RCR'  Then Rotate('011') Else

   If Code[1]='AND'  Then Logic('001000','1000000','0010010','100') Else
   If Code[1]='OR'   Then Logic('000010','1000000','0000110','001') Else
   If Code[1]='XOR'  Then Logic('001100','1000000','0011010','110') Else
   If Code[1]='TEST' Then Logic('100001','1111011','1010100','000') Else

   If Code[1]='REP'  Then I_REP Else
   If Code[1]='REPZ' Then I_REP Else
   If Code[1]='INT'  Then I_Int Else

   If Code[1]='RET'  Then I_Ret Else
   If Code[1]='RETFAR' Then I_RetFar Else

   If (Code[1]='JE')Or(Code[1]='JZ')    Then Salto('01110100') Else
   If (Code[1]='JL')Or(Code[1]='JNGE')  Then Salto('01111100') Else
   If (Code[1]='JLE')Or(Code[1]='JNG')  Then Salto('01111110') Else
   If (Code[1]='JB')Or(Code[1]='JNAE')  Then Salto('01110010') Else
   If (Code[1]='JBE')Or(Code[1]='JNA')  Then Salto('01110110') Else
   If (Code[1]='JP')Or(Code[1]='JPE')   Then Salto('01111010') Else
   If (Code[1]='JO')                    Then Salto('01110000') Else
   If (Code[1]='JS')                    Then Salto('01111000') Else
   If (Code[1]='JNE')Or(Code[1]='JNZ')  Then Salto('01110101') Else
   If (Code[1]='JNL')Or(Code[1]='JGE')  Then Salto('01111101') Else
   If (Code[1]='JNLE')Or(Code[1]='JG')  Then Salto('01111111') Else
   If (Code[1]='JNB')Or(Code[1]='JAE')  Then Salto('01110011') Else
   If (Code[1]='JNBE')Or(Code[1]='JA')  Then Salto('01110111') Else
   If (Code[1]='JNP')Or(Code[1]='JPO')  Then Salto('01111011') Else
   If (Code[1]='JNO')                   Then Salto('01110001') Else
   If (Code[1]='JNS')                   Then Salto('01111001') Else
   If (Code[1]='LOOP')                  Then Salto('11100010') Else
   If (Code[1]='LOOPZ')Or(Code[1]='LOOPE')   Then Salto('11100001') Else
   If (Code[1]='LOOPNZ')Or(Code[1]='LOOPNE') Then Salto('11100000') Else
   If (Code[1]='JCXZ')                       Then Salto('11100011') Else
   If (Code[1]='JMP')                        Then Salto('11101011') Else

   If (Code[1]='JUMP')            Then I_Jump     Else
   If (Code[1]='JUMPFAR')         Then I_JumpFar  Else
   If (Code[1]='CALL')            Then I_Call     Else
   If (Code[1]='CALLFAR')         Then I_CallFar  Else

   If (Code[1]='DB')              Then I_DByte    Else
   If (Code[1]='DW')              Then I_DWord    Else

   If (Code[1]='ENTER')           Then I_Enter    Else
   If (Code[1]='LEAVE')           Then I_Leave    Else

  End Else E:=False;
 Code8086:=E;
End;

Begin
 SetSimbol;
 AllSimbol:=True;
 OneCode[1]:='XLAT';    One8086[1]:='&11010111';
 OneCode[2]:='LAHF';    One8086[2]:='&10011111';
 OneCode[3]:='SAHF';    One8086[3]:='&10011110';
 OneCode[4]:='PUSHF';   One8086[4]:='&10011100';
 OneCode[5]:='POPF';    One8086[5]:='&10011101';
 OneCode[6]:='AAA';     One8086[6]:='&00110111';
 OneCode[7]:='DAA';     One8086[7]:='&00100111';
 OneCode[8]:='AAS';     One8086[8]:='&00111111';
 OneCode[9]:='DAS';     One8086[9]:='&00101111';
 OneCode[10]:='CBW';    One8086[10]:='&10011000';
 OneCode[11]:='CWD';    One8086[11]:='&10011001';
 OneCode[12]:='RET';    One8086[12]:='&11000011';
 OneCode[13]:='RETFAR'; One8086[13]:='&11001011';
 OneCode[14]:='INT3';   One8086[14]:='&11001100';
 OneCode[15]:='INTO';   One8086[15]:='&11001110';
 OneCode[16]:='IRET';   One8086[16]:='&11001111';
 OneCode[17]:='CLC';    One8086[17]:='&11111000';
 OneCode[18]:='STC';    One8086[18]:='&11111001';
 OneCode[19]:='CMC';    One8086[19]:='&11110101';
 OneCode[20]:='NOP';    One8086[20]:='&10010000';
 OneCode[21]:='CLD';    One8086[21]:='&11111100';
 OneCode[22]:='STD';    One8086[22]:='&11111101';
 OneCode[23]:='CLI';    One8086[23]:='&11111010';
 OneCode[24]:='STI';    One8086[24]:='&11111011';
 OneCode[25]:='HLT';    One8086[25]:='&11110100';
 OneCode[26]:='WAIT';   One8086[26]:='&10011011';
 OneCode[27]:='LOCK';   One8086[27]:='&11110000';
 IOne:=27;
End.
