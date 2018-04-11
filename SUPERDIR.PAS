Program SuperDir;
{$I-} {$C-}
Const
  Blc = 160;
  Max = 265;
  Funcao  :  Array[1..10] of String[8]
          = ('Mostr','Impri','Renom','Apaga','Recup'
            ,'Copia','Rw/Ro','Apg-*','Cop-*','Drive');
  Pirata  = 'AETRAAROIOP';
  TmDir   = 29;
  ClJan   = 31;
  TmJan   = 48;
  NLJ     = 14;
Type
  NmArq = String[12];
  NmArqD= String[20];
  DefFcb= String[36];
  Buffer= String[128];
  LinJan= String[TmJan];
  LinDir= String[TmDir];
Var
  Buf : Array [1..Blc] of Buffer;
  Dir : Array [1..Max] of NmArq;
  Mar : Array [1..Max] of Boolean;
  Tam : Array [1..Max] of Integer;
  Usu : Array [1..Max] of Byte;
  Ro  : Array [1..Max] Of Boolean;
  JanL: Array [1..NLJ] of LinJan;
  Arq1,Arq2   :File;
  Nm1,Nm2,Nm3 :NmArqD;
  Fcb         :DefFcb;
  Fim         :Boolean;
  Opc,Let,Drd :Char;
  Ent,Dma     :Buffer;
  Nus         :LinDir;
  Usd,Aux     :Integer;
  Pag,Lin,Lint:Byte;
  Cola,Col    :Byte;
  Drv,AAt,At  :Integer;
  X           :Integer;
  Pos1,Pos2   :Integer;
  Ctm,Kbm     :Integer;
  Ct,Kb,Xtot  :Integer;
  Xtrl,Xstr   :Integer;
  Xgrp,Xblc   :Integer;
  Xent,Xres   :Integer;

Procedure Bip;
Begin
  Write(^G);
End;

Procedure Mos(L,C:Byte;Msg:Buffer);
Begin
  GotoXY(C,L);
  Write(Msg);
End;

Procedure Espere;
Begin
  Mos(1,2,'ESPERE');
  Mos(1,1,'');
End;

Procedure Limpa;
Begin
  Mos(1,2,'----------------');
  Mos(1,1,'');
End;

Function Rep(N:Byte;C:Char):Buffer;
Var Aux:Buffer; X:Byte;
Begin
  FillChar(Aux,N+1,C); Aux[0]:=Chr(N); Rep:=Aux;
End;

FunCtion CNm(Nom:NmArqD):NmArqD;
Begin
  Nom:=Chr(Drv+65)+':'+Copy(Nom,1,12);
  x:=Pos(' ',Nom); If x>0 Then Delete(Nom,x,Pos('.',Nom)-x);
  CNm:=Nom;
End;

FunCtion NmC(Nom:NmArqD):NmArqD;
Begin
  If Pos('.',Nom)=0 Then Nom:=Nom+'.';
  X:=Pos('.',Nom); Insert(Rep(9-x,' '),Nom,x);
  x:=Length(Nom);  Nom:=Nom+Rep(12-x,' ');
  For x:=1 to 12 do Nom[x]:=Upcase(Nom[x]);
  NmC:=Nom;
End;

Procedure Mos_Jan(Msg:Buffer);
Var x:Byte;
Begin
  Mos(6+Lint,ClJan+1,Msg); JanL[Lint]:=Msg; Lint:=Lint+1;
  If Lint=NLJ Then
  Begin
    For x:=1 to NLJ-1 do
    Begin
      Mos(x+6,ClJan+1,Rep(Length(JanL[x]),' '));
      Mos(x+6,ClJan+1,JanL[x+1]);
    End;
    For x:=1 to NLJ-1 do JanL[x]:=JanL[X+1]; Lint:=Lint-1;
  End;
End;

Procedure Jan(Msg:Buffer);
Var Resto:buffer;
Begin
  Resto:='';
  While Length(Msg)>TmJan do
  Begin
    Mos_Jan(Copy(Msg,1,TmJan));
    Msg:=Copy(Msg,TmJan+1,Length(msg)-TmJan);
  End;
  Mos_Jan(Msg);
End;

Procedure Jan2(Msg:Buffer);
Begin
  Mos_Jan(''); Mos_Jan(Msg); Mos_Jan('');
End;

FunCtion Pede(Msg:Buffer;Tam:Byte):NmArqD;
Var Aux:NmArqD;
Begin
  Mos(6+Lint,ClJan+1,Msg);
  BufLen:=Tam; Read(Aux);
  Jan(Msg+Aux); If Aux='' Then Aux:='*';
  Pede:=Aux;
End;

Procedure Quadro(L1,L2,C,T:Byte);
Begin
  Mos(L1,C,'+'+Rep(T,'-')+'+');
  For x:=L1+1 to L2-1 do
  Begin
    Mos(x,C,'!'); Mos(x,C+T+1,'!');
  End;
  Mos(L2,C,'+'+Rep(T,'-')+'+');
End;

Procedure Mos_Fun;
Begin
  Mos(21,Cola*8-7,Rep(7,' '));
  Mos(23,Cola*8-7,Rep(7,' '));
  Mos(22,Cola*8-7,' ');
  Mos(22,Cola*8-1,' ');
  Quadro(21,23,Col*8-7,5);
  Cola:=Col;
End;

Procedure Mos_Dir(M:Byte);
Var Monte:Boolean;
    Aux2 :Integer;
    Aux3 :LinDir;
    Aux4 :LinDir;
Begin
  Mos(lin,02,' ');
  If M>0 Then Monte:=True Else Monte:=False;
  If M>1 Then Begin Pag:=1; At:=1; End;
  If At<Pag Then Begin Pag:=At; Monte:=True; End;
  If At>(Pag+10) Then Begin Pag:=At-10; Monte:=True; End;
  If Monte
  Then For x:=0 to 10 do
  Begin
    Mos(x+9,4,''); Aux2:=Pag+x;
    Str(Usu[Aux2]:2,Aux3); If Usu[Aux2]>31 Then Aux3:='AP';
    Aux3:=Aux3+':'+Dir[Aux2];
    If Mar[Aux2] Then Aux3:=Aux3+' *'    Else Aux3:=Aux3+'  ';
    If Ro [Aux2] Then Aux3:=Aux3+' R/O'  Else Aux3:=Aux3+' R/W';
    Str(Tam[Aux2]:4,Aux4); Aux3:=Aux3+Aux4+'k';
    If Pag+x>Ct Then Write(Rep(27,' ')) Else Write(Aux3);
  End;
  Lin:=At-Pag+9; Mos(lin,02,'*');
End;

FunCtion  Ex(Arq:NmArqD;Us:Byte):Boolean;
Var       Arq9 : File;
Begin
  Espere;
  Bdos(32,Us); Assign(Arq9,Arq); Reset(Arq9);
  If IOresult=0 Then Ex:=True Else Ex:=False;
  Close(Arq9);
  Limpa;
End;

Procedure Sort_Dir;
Var  Ok  :Byte;
     Aux2,Mx:Integer;
     Aux1:Boolean;
Begin
  Mx:=Ct-1;
  Repeat
  Begin
    Ok:=1;
    GotoXY(10,1); Write('Ord ',Mx+1:3);
    For x:=1 to Mx do
    If Chr(Usu[x])+Dir[x]>Chr(Usu[x+1])+Dir[x+1] Then
    Begin
      Nm1 :=Dir[x]; Dir[x]:=Dir[x+1]; Dir[x+1]:=Nm1;
      Aux2:=Usu[x]; Usu[x]:=Usu[x+1]; Usu[x+1]:=Aux2;
      Aux1:=Ro [x]; Ro [x]:=Ro [x+1]; Ro [x+1]:=Aux1;
      Aux1:=Mar[x]; Mar[x]:=Mar[x+1]; Mar[x+1]:=Aux1;
      Aux2:=Tam[x]; Tam[x]:=Tam[x+1]; Tam[x+1]:=Aux2;
      Ok:=0; Mx:=x;
    End;
  End until Ok=1;
  Aux2:=0;
  For x:=1 to Ct do
  Begin
    If (Dir[x]<>Dir[x+1]) or (Usu[x]<>Usu[X+1]) Then
    Begin
        Aux2:=Aux2+1;
        If Aux2<>x Then
        Begin
             Dir[Aux2]:=Dir[x];
             Usu[Aux2]:=Usu[x];
             Ro [Aux2]:=Ro [x];
             Mar[Aux2]:=Mar[x];
             Tam[Aux2]:=Tam[x];
         End;
     End;
  End;
  Ct:=Aux2;
End;

Procedure Mos_Kb;
Var Ctn:Integer;
Begin
  Kb:=0; Ctn:=0;
  For X:=1 to Ct do if usu[x]<32 Then Begin Kb:=Kb+Tam[X]; Ctn:=Ctn+1; End;
  Mos(3,34,'Drive '+Chr(Drv+65)+':');
  Mos(4,32,''); If Kb>0 Then Write(Ctn:3) Else Write(0:3); Write(' Arq(s)');
  Mos(3,45,''); Write(Kb:5,' Kb Usado(s)');
  Mos(4,45,''); Write(Xtot-Kb:5,' Kb Livre(s)');
  Mos(3,63,'  '); Write(Ctm:3,' Marcado(s)');
  Mos(4,63,''); Write(Kbm:5,' Kb');
End;

Procedure Vazio;
Begin
  Ct:=1;
  Dir[1]:='---Nenhum--- ';
  Ro[1] :=False;
  Usu[1]:=255;
  Mar[1]:=False;
  Tam[1]:=0;
End;

Procedure Le_Dir(M:Byte);
Var  Ok,Base:Byte;
     x,DPH  :Integer;

Begin
  Espere;
  Bdos(13); Bdos(14,Drv);
  DPH :=BdosHl(31);
  Xstr:=Mem[DPH   ]+Mem[DPH+01]*256;
  Xgrp:=Mem[DPH+03]+1;
  Xblc:=Mem[DPH+05]+Mem[DPH+06]*256;
  Xent:=Mem[DPH+07]+Mem[DPH+08]*256+1;
  Xres:=Mem[DPH+13]+Mem[DPH+14]*256;
  Xtot:=(((Xblc+1) * Xgrp) div 8)-(Xent div 32);
  Xtrl:=(((Xblc+1) * Xgrp) div Xstr)+Xres;
  For x:=1 to Max do Dir[x]:='';
  Fcb:='????????????'+Rep(24,#0);
  FillChar(Dma,129,0); Dma[0]:=#128;
  Bdos(26,Addr(Dma)+1);
  Ok:=Bdos(17,Addr(Fcb)+1);
  Ct:=0;
  While Ok<>255 do
  Begin
    Base:=Ok*32; Ct:=Ct+1;
    GotoXY(10,1); Write('Dir ',Ct:3);
    Usu[Ct]:=Ord(Dma[Base+1]);
    If Ord(Dma[Base+10])>127
    Then Begin
      Dma[Base+10]:=Chr(Ord(Dma[Base+10]) and 127);
      Ro[Ct]:=True
    End
    Else Ro[Ct]:=False;
    Dma[Base+11]:=Chr(Ord(Dma[Base+11]) and 127);
    Dir[Ct]:=Copy(Dma,Base+2,8)+'.'+Copy(Dma,10+Base,3);
    Mar[Ct]:=False;
    If ((Dma[Base+13]=#0) and (Dma[Base+16]<#128)) or (Usu[ct]>31)
       Then Tam[Ct]:=trunc((Ord(Dma[Base+16])/xgrp)+0.99)*(xgrp div 8)
       Else Tam[Ct]:=-1;
    If Dma[Base+12]=#$E5 then Ct:=Ct-1;
    Ok:=Bdos(18,Addr(Fcb)+1);
  End;
  If Ct=0 Then Vazio;
  Sort_Dir;
  For x:=1 to Ct do
  Begin
    GotoXY(10,1); Write('Tam ',X:3);
    If Tam[x]<0 Then
    Begin
      Nm1:=CNm(Dir[x]);
      Bdos(32,Usu[x]); Assign(Arq1,Nm1); Reset(Arq1);
      Tam[x]:=trunc((FileSize(Arq1)/xgrp)+0.99)*(xgrp div 8);
      Close(Arq1);
    End;
  End;
  If At>Ct Then At:=Ct;
  Limpa; Mos_Dir(M); Ctm:=0; Kbm:=0; Mos_Kb;
End;

Procedure N_Ex;
Begin
  If Usu[At]<32
  Then Begin Bip; Jan2('** Arquivo Nao Existe'); Le_Dir(2); end
  Else Begin Bip; Jan2('** Arquivo Apagado   '); end;
  Fim:=True;
End;

Procedure Leia_Setor(trl,str:byte);
Begin
      Bios(08,drv);
      Bios(09,trl);
      Bios(10,str);
      Bios(11,Addr(Dma)+1);
      Bios(12);
      Dma[0]:=#128;
End;

Procedure Grave_Setor(trl,str:byte);
Begin
      Bios(08,drv);
      Bios(09,trl);
      Bios(10,str);
      Bios(11,Addr(Dma)+1);
      Dma[0]:=#128;
      Bios(13);
End;

Function  Logico(Fis:Byte):Byte;
Var XLT,DPH:Integer;
Begin
        DPH:=BiosHl(8,Drv);
        XLT:=Mem[DPH]+Mem[DPH+1]*256;
        If XLT=0 then Logico:=Fis else Logico:=Mem[XLT+Fis];
End;

Procedure Inicio;
Var  Nom :String[80];
     Check:Integer;
Begin
  ClrScr;
  Nom:=     '(C) 1987 Jose Barreto Jr';
  Check:=0;
  For X:=1 to Length(Nom) do Check:=Check+Ord(Nom[X])*X;
  If Check<>25478 Then
  Begin
    For X:=1 to 6 do Write(Copy(Pirata,14-x*2-1,1));
    Halt;
  End;
  Quadro(01,06,01,TmDir);
  Quadro(01,06,ClJan,TmJan);
  Mos(03,05,'SuperDiretorio - Ver 3.5');
  Mos(04,05,Nom);
  Quadro(06,20,01,TmDir);
  Mos(07,03,'Usr:NomeArqv.Ext * Prot Tam');
  Mos(08,03,'--- -------- --- - --- ----');
  Quadro(06,20,ClJan,TmJan);
  For x:=1 to 10  do Mos(22,X*8-6,Funcao[X]);
  For x:=1 to NLJ do JanL[x]:='';
  Lint:=1; Lin:=8; Cola:=1; Col:=1;
End;

Procedure Mark;
Var Marca:Char;
Begin
  If Usu[At]>31 Then N_Ex
  Else Begin
    Mar[At]:=Not Mar[At];
    If Mar[At]
    Then begin Ctm:=Ctm+1; Kbm:=Kbm+Tam[At] End
    Else begin Ctm:=Ctm-1; Kbm:=Kbm-Tam[At] End;
    Mos_Kb; Mos_Dir(1);
  End;
End;

Procedure List;
Var Vid:Buffer;
    Conj:Set of Char;
Begin
  Nm1:=CNm(Dir[At]);
  If not Ex(Nm1,Usu[At]) Then N_Ex
  Else Begin
    Jan2('** Listando '+Nm1);
    Bdos(32,Usu[At]); Assign(Arq1,Nm1); Reset(Arq1);
    Let:=' '; Vid:=''; Conj:=[#10,#13,' '..#126];
    While not(eof(Arq1)) and (Let=' ') do
    Begin
      BlockRead(Arq1,Ent,1);
      For X:=0 to 127 do
      Begin
        If not(Ent[x] in Conj) Then Ent[x]:='.';
        If (Ent[x]<>#10)and(Ent[x]<>#13)  then Vid:=Vid+Ent[x];
        If (Length(Vid)>47)or(Ent[x]=#10) then Begin Jan(Vid); Vid:=''; End;
      End;
      If KeyPressed Then Read(Kbd,Let);
      If Let=^S
      Then Begin Read(Kbd,Let); Let:=' '; End;
    End;
    Jan(Vid);
    If Let<>' '
      Then Begin Bip; Jan2('** Interrompido'); End
      Else Jan2('** Final do Arquivo');
    Close(Arq1);
  End;
End;

Procedure Print;
Var Conj:Set of Char;
Begin
  If Bios(14)=0
  Then Begin Bip; Jan2('** Impressora nao esta'' pronta'); End
  Else Begin
    Nm1:=CNm(Dir[At]);
    If not Ex(Nm1,Usu[At]) Then N_Ex
    Else Begin
      Jan2('** Listando '+Nm1);
      Conj:=[#10,#13,' '..#126];
      Bdos(32,Usu[At]); Assign(Arq1,Nm1); Reset(Arq1);
      While not(eof(Arq1)) and (not KeyPressed) do
      Begin
        BlockRead(Arq1,Ent,1);
        For X:=0 to 127 do
        Begin
          If not (Ent[x] in Conj) Then Ent[x]:='.';
          Write(Lst,Ent[x]);
        End;
      End;
      WriteLn(Lst);
      Close(Arq1);
    End;
  End;
End;

Procedure Grv_Dest;
Label gsai;
Begin
  Close(Arq1); Limpa;
  If (Nm1[1]=Nm2[1]) and (Usd=Usu[at]) Then
  Begin
    Let:=Pede('Coloque Disco -DESTINO- e tecle ENTER:',1);
    If Let<>'*' Then
    Begin
      Jan('** Copia Interrompida');
      Fim:=true;
      goto gsai;
    End;
    Espere;
    Bdos(13);
  End;
  Nm3:=NmC(Copy(Nm2,3,Length(Nm2)-2));
  Fcb:=#0+Copy(Nm3,1,8)+Copy(Nm3,10,3)+Rep(24,#0);
  Bdos(32,Usd); Bdos(14,Ord(Nm2[1])-65); Bdos(30,Addr(Fcb)+1);
  Assign(Arq2,Nm2);
  If Ex(Nm2,Usd) Then Reset(Arq2) Else Rewrite(Arq2);
  If IOresult>0
  Then Begin
    Bip; Jan2('** Diretorio Cheio');
    Close(Arq2); Le_Dir(2); Fim:=True; goto gsai;
  End;
  Espere;
  Seek(Arq2,Pos2);
  For Aux:=1 to ((Pos1-1) mod Blc)+1 do
  Begin
    GotoXY(10,1); Write(' >',(Pos2+Aux+7) div 8:5,'k');
    BlockWrite(Arq2,Buf[Aux],1);
    If IOresult>0 Then
    Begin
      Bip; Jan2('** Disco Cheio');
      Close(Arq2); Erase(Arq2);
      Le_Dir(2); Fim:=True; goto gsai;
    End;
  End;
  Pos2:=FilePos(Arq2); Close(Arq2); Limpa;
  gsai:;
  If (Nm1[1]=Nm2[1]) and (Usd=Usu[at]) Then
  Begin
    Let:=Pede('Coloque Disco --FONTE-- e tecle ENTER:',1);
    If Let<>'*' Then
    Begin
      Bip; Jan2('** Copia Interrompida');
      Le_Dir(2); Fim:=true;
    End;
    Espere; Bdos(13);
  End;
End;

Procedure Ped_Dest;
Begin
  Drd:=Pede('Drive destino    (a-p):',1);
  If Drd='*' Then Nm2:=Chr(Drv+65);
  Drd:=Upcase(Drd);
  If not (Drd in ['A'..'P'])
  Then Begin
    Jan2('** Drive Invalido'); Fim:=True;
  End;
  If not Fim then
  Begin
    Nus:=Pede('Usuario destino (0-31):',2);
    Jan(''); Val(Nus,Usd,Aux);
    If (Aux>0) or (Usd<0) or (Usd>31)
    Then Begin
      Jan2('** Usuario Invalido'); Fim:=True;
    End;
  End;
End;

Procedure Copia;
label sai;
Begin
  Fim:=False; Mos_Dir(0);
  Nm1:=CNm(Dir[At]);
  If not Ex(Nm1,Usu[At]) Then N_Ex
  Else Begin
    Nm2:=Drd+Copy(Nm1,2,Length(Nm1)-1);
    Jan('** Copiando '+Dir[At]+' para '+Drd+Nus+':');
    Pos1:=0; Pos2:=0;
    Espere;
    Bdos(13); Bdos(32,Usu[At]); Assign(Arq1,Nm1); Reset(Arq1);
    While Pos1<FileSize(Arq1) do
    Begin
      GotoXY(10,1); Write(' <',(Pos1+8) div 8:5,'k');
      BlockRead(Arq1,Buf[(Pos1 mod Blc)+1],1);
      Pos1:=Pos1+1;
      If (Pos1 mod Blc)=0
      Then Begin
        Grv_Dest;
        If Fim Then goto sai;
        If Not Ex(Nm1,Usu[At]) Then
        Begin
          Bip; Jan2('** Arquivo Fonte nao Encontrado');
          Le_Dir(2); Fim:=True; goto Sai;
        End;
        Reset(Arq1); Seek(Arq1,Pos1); Espere;
      End;
    End;
    Close(Arq1); Limpa;
    If (Pos1 mod Blc)>0 Then Grv_Dest;
    If Fim Then goto Sai;
    If Mar[At] Then Mark;
  End;
  sai:;
End;

Procedure Protege;
Begin
  Nm1:=Cnm(Dir[At]);
  If not Ex(Nm1,Usu[At]) then N_Ex
  else Begin
    Fcb:=#0+Copy(Dir[At],1,8)+Copy(Dir[At],10,3)+Rep(24,#0);
    Ro[At]:=Not Ro[At];
    If Ro[At] then Fcb[10]:=Chr(Ord(Fcb[10])+128);
    Bdos(30,Addr(Fcb)+1);
    Mos_Dir(1);
  End;
End;

Procedure Ren;
Begin
  Nm1:=CNm(Dir[At]);
  If not Ex(Nm1,Usu[At]) Then N_Ex
  Else Begin
    If Ro[At] Then
    Begin
      Bip; Jan2('** Arquivo Protegido');
    End
    Else Begin
      Nm2:=Pede('Novo Nome :',12);
      If Nm2='*'
      Then Begin
        Bip; Jan2('** Nao Renomeado')
      End
      Else Begin
        If Ex(Nm2,Usu[At])
        Then Begin
          Bip; Jan2('** Arquivo Ja'' Existe');
        End
        Else begin
          Jan2('** Renomeando '+Nm1+' para '+Nm2);
          Espere;
          Bdos(32,Usu[At]); Assign(Arq1,Nm1); Rename(Arq1,Nm2);
          Dir[At]:=NmC(Nm2);
          Sort_Dir; Mos_Dir(1); Limpa;
        End;
      End;
    End;
  End;
End;

Procedure Era;
Begin
  Fim:=False;
  Nm1:=CNm(Dir[At]);
  If not Ex(Nm1,Usu[At]) Then N_Ex
  Else Begin
    If Ro[At] Then
    Begin
      Bip; Jan('** Arquivo Protegido');
    End
    Else Begin
      Mos_Dir(0);
      Let:=Pede('Apaga '+Nm1+' (s/n)?',1);
      Let:=Upcase(Let);
      If Let='S'
      Then Begin
        Jan('** Apagando '+Nm1);
        Espere;
        Bdos(32,Usu[At]); Assign(Arq1,Nm1); Erase(Arq1);
        Fim:=True;
        If Mar[At] Then Mark; Usu[At]:=$E5;
        Sort_Dir; If Ct=0  Then Vazio;
        If At>Ct Then Begin At:=Ct; Fim:=False; End;
        Limpa;
        Mos_Dir(1); Mos_Kb;
      End
      Else Begin
        Bip; Jan('** Nao apagado');
      End;
    End;
  End;
End;

Procedure Recup;
Var Achou,Grava:Boolean;
    Tra,Sta,Cts:Byte;
    Off,Ctu,Usx:Byte;
    Conj       :Set of Byte;
Begin
  If Usu[At]<32 then Jan2('** Arquivo nao esta'' apagado')
  else begin
    Nus:=Pede('Usuario destino (0-31):',2);
    Jan(''); Val(Nus,Usd,Aux);
    If (Aux>0) or (Usd<0) or (Usd>31) then Jan2('** Usuario Invalido')
    else Begin
      Nm1:=Cnm(Dir[At]);
      If Ex(Nm1,Usd) then Jan2('** Nome Ja'' existe neste usuario')
      else Begin
        Nm1:=Copy(Dir[At],1,8)+Copy(Dir[At],10,3);
        Achou:=False; Conj:=[];
        Tra:=Xres; Sta:=0; Cts:=0;
        While Cts<(xent div 4) do
        Begin
          Leia_Setor(Tra,Logico(Sta)); Grava:=False;
          For Off:=0 to 3 do
          Begin
            For Ctu:=1 to 11 do
              Dma[Off*32+Ctu]:=Chr(Ord(Dma[Off*32+Ctu]) and 127);
            Usx:=Ord(Dma[Off*32+1]);
            If (Usx>31) and (not(Usx in Conj)) and (Copy(Dma,Off*32+2,11)=Nm1)
            then Begin
              Dma[Off*32+1]:=Chr(Usd);
              Achou:=True; Grava:=True;
              Conj:=Conj+[Usx];
            End;
          End;
          If Grava then Grave_Setor(Tra,Logico(Sta));
          Cts:=Cts+1;
          Sta:=Sta+1; If Sta>Xstr then Begin Sta:=0; Tra:=Tra+1; End;
        End;
        If Achou Then Jan2('** Arquivo Recuperado - Verifique')
                 else Jan2('** Arquivo Nao Encontrado');
        Le_Dir(2);
      End;
    End;
  End;
End;

Procedure Drive;
Begin
  Let:=Pede('Novo Drive (a-p):',1);
  If Let='*' Then Let:=Chr(Drv+65);
  Let:=Upcase(let);
  If not (Let in ['A'..'P']) Then Jan2('** Drive Invalido')
  Else Begin
    Jan2('** Mudando para o drive '+Let+':');
    Drv:=Ord(let)-65; Le_Dir(2);
  End;
End;

Procedure Help;
Begin
  Jan(''); Jan('');
  Jan('  Comandos  8 e 2 movem arquivo');
  Jan('            9 e 3 movem arq/pag');
  Jan('              5   marca arquivo');
  Jan('            4 e 6 movem funcao');
  Jan('            ENTER chama funcao');
  Jan('              ^C  volta ao CP/M');
  Jan('');
  Jan('  Use o teclado numerico reduzido');
  Jan(''); Jan(''); Opc:=' ';
End;

Procedure Aciona;
Begin
  Case Col of
    1:List;
    2:Print;
    3:Ren;
    4:Begin Jan(''); Era; Jan(''); End;
    5:Recup;
    6:Begin
        Fim:=False;
        Ped_Dest;
        If not Fim Then Copia;
        If not Fim Then Jan2('** Copia Completa');
        If (not Fim) and (Nm1[1]=Nm2[1]) and (Usu[At]<>Usd) Then Le_Dir(1);
      End;
    7:Protege;
    8:Begin
        If Ctm=0 then Jan2('** Nao ha'' arquivos marcados')
        Else Begin
          Jan2('** Apagando os Marcados'); AAt:=At; At:=1;
          While At<=Ct do
          Begin
            If Mar[At] Then Begin Era; If Fim Then At:=At-1; End;
            At:=At+1;
          End;
          At:=AAt; If At>Ct then At:=Ct; Mos_Dir(0); Jan('');
        End;
      End;
    9:Begin
        If Ctm=0 then Jan2('** Nao ha'' arquivos marcados')
        Else Begin
          Jan2('** Copiando os marcados');
          AAt:=At; Fim:=False; Ped_Dest;
          For At:=1 to Ct do If (Mar[At]) and (not Fim) Then Copia;
          If not Fim Then Jan2('** Copia Completa');
          If (not Fim) and (Nm1[1]=Nm2[1]) and (Usu[At]<>Usd) Then Le_Dir(1);
          At:=AAt; If At>Ct then At:=Ct; Mos_Dir(0);
        End;
      End;
   10:Drive;
  End;
End;

Begin
  Drv:=Mem[4] and 15;
  Inicio;
  Mos_Fun;
  Le_Dir(2);
  Help;
  Repeat Begin
    Limpa;
    Mos(lin,2,'');
    Read(Kbd,Opc);
    Case Opc of
      '8':Begin
            If At>1 Then At:=At-1; Mos_Dir(0);
          End;
      '2':Begin
            If At<Ct Then At:=At+1; Mos_Dir(0);
          End;
      '9':Begin
            At:=At-11; If At<1 Then At:=1; Mos_Dir(0);
          End;
      '3':Begin
            At:=At+11; If At>Ct Then At:=Ct; Mos_Dir(0);
          End;
      '4':Begin
            If Col>1 Then Col:=Col-1 Else Col:=10; Mos_Fun;
          End;
      '6':Begin
            If Col<10 Then Col:=Col+1 Else Col:=1; Mos_Fun;
          End;
      '5':Mark;
      #13:Aciona;
       ^C:;
      Else Begin Bip; Help; End;
    End;
  End until Opc=^C;
  Mos(23,1,'');
End.
