000100250707**free
000101250531//ctl-opt main(main) option(*nodebugio:*srcstmt:*nounref) dftactgrp(*no) ;
000102250531ctl-opt nomain;
000103250531
000104250531dcl-ds PgmDs psds qualified ;//（Program Status Data Structure）
000105250531  PgmName *proc ; //*procプログラム自身の名前が入る
000106250531end-ds ;
000107250531
000108250531
000109250531dcl-f SELECTD workstn indds(Dspf) sfile(SFL01:Z1RRN) usropn; // sfile サブファイル定義
000110250601dcl-f CUSTOMER keyed usropn usage(*update:*delete) ;
000111250601//dcl-f UPDATED workstn usropn ;
000112250531
000113250531dcl-c MaxSfl 9999 ;
000114250531
000115250531dcl-ds Dspf qualified ;
000116250531  Exit ind pos(3) ;     //ind pos(3) インジケータ03
000117250531  Refresh ind pos(5) ;
000118250531  SflDspCtl ind pos(30) ;
000119250531  SflDsp ind pos(31) ;
000120250531end-ds ;
000121250601
000122250601dcl-ds CUSTOMERds likerec(CUSTOMERR:*all);
000123250601dcl-ds UPDATE1ds likerec(UPDATE1:*all);
000124250531
000125250531dcl-s PrvPosition like(Z1POSITION) ;  //5A 品番 検索欄
000126250531dcl-s SearchName varchar(20);
000127250531dcl-s i int(10);
000128250601dcl-s dFlg int(10);
000129250531
000130250531//サブプロシージャプロトタイプ定義用copy句
000131250531/COPY QCRUD,PRCOPY
000132250531
000133250531//--------------------------------------------------------
000134250531dcl-proc SelectCustomer export;
000135250531  //dcl-ds CTL01ds likerec(CTL01:*all);
000136250531  dcl-pi SelectCustomer;
000137250531  end-pi;
000138250531
000139250531  open SELECTD;
000140250531  open CUSTOMER;
000141250601  //open UPDATED;
000143250531
000144250531  Z1SCREEN = %trimr(PgmDs.PgmName) + '-1' ;
000145250531  setll *loval CUSTOMER ;  //「ITMMSTR ファイルのキー順で、最初のレコードにポジションする」
000146250531  LoadSubfile() ;
000147250531
000148250531  dow (1 = 1) ;
000149250531    write REC01 ;
000150250531    exfmt CTL01 ;
000151250531
000152250531    if (Dspf.Exit) ;
000153250531      Dspf.Exit = *OFF;
000154250531      leave ;
000155250531    elseif (Dspf.Refresh) ;
000156250531      Z1POSITION = ' ' ;       //ディスプレイ検索欄初期化
000157250531      PrvPosition = ' ' ;      //検索欄変数初期化
000158250531      setll *loval CUSTOMERR ;   //レコードポジション初期化
000159250531      LoadSubfile() ;
000160250531      iter ;                   //次ループへ
000162250531    elseif (Z1POSITION <> PrvPosition or SearchName <> %trim(NAMEINP)) ;
000163250531    //検索欄に新しい入力があった場合
000164250531      PrvPosition = Z1POSITION ;
000165250531      SearchName = %trim(NAMEINP) ;
000166250531      setll Z1POSITION CUSTOMERR ;  //物理ファイルのレコードポジションをZ1POSITIONに
000167250531      LoadSubfile() ;
000168250531      iter ;
000169250531    endif ;
000170250531
000171250531    if (Dspf.SflDsp) ;
000172250531      ReadSubfile() ;
000173250531    endif ;
000174250531  enddo ;
000175250531
000176250531  close SELECTD;
000177250531  close CUSTOMER;
000178250601  //close UPDATED;
000179250531
000180250531end-proc;
000181250531
000182250531//--------------------------------------------------------
000183250531dcl-proc LoadSubfile ;
000184250531  Dspf.SflDspCtl = *off ;
000185250531  Dspf.SflDsp = *off ;
000186250531  write CTL01 ;
000187250531  Dspf.SflDspCtl = *on ;
000188250531
000189250531  Z1OPT = ' ' ;              //オプション欄
000190250531  Z1RRN = 0;
000191250531  for i = 1 to MaxSfl ;  //現在の行番号内部変数
000192250531    read CUSTOMERR ;
000193250531    if (%eof) ;
000194250531      leave ;
000195250531    endif ;
000196250531
000197250531    //===== ★ フィルタ：SearchName が空 or 部分一致 ↓ =====
000198250531    if SearchName = *blanks
000199250531      or %SCAN(%trim(SearchName):%trim(NAME)) > 0;
000200250531        //SearchName
000201250531        // NAME
000202250531        Z1RRN += 1;
000203250531        write SFL01;    // write 新しいサブファイル行を作成 SFL フィールドに書き込み
000204250531    endif;
000205250531
000206250531    //write SFL01 ;
000207250531  endfor ;
000208250531
000209250531  if (Z1RRN > 0) ;
000210250531    Dspf.SflDsp = *on ;
000211250531  endif ;
000212250531end-proc ;
000213250531
000214250531//--------------------------------------------------------
000215250531dcl-proc ReadSubfile ;
000216250531  dow (1 = 1) ;
000217250531    readc SFL01 ;  //変更行のみを読み込み
000218250531    if (%eof) ;
000219250531      leave ;
000220250531    endif ;
000221250531
000222250601    // オプションの値に応じた処理
000223250531    if Z1OPT = 'U';
000224250601      UPDATE1ds.USCREEN1 = %trimr(PgmDs.PgmName) + '-UPDATE' ;
000225250601      UPDATE1ds.U_CUSTID = CUST_ID;
000226250601      UPDATE1ds.U_NAME = NAME;
000227250601      UPDATE1ds.U_EMAIL = EMAIL;
000228250601      UPDATE1ds.U_PHONE = PHONE;
000229250601      //UPDATE1ds.MSG = 'test文字列';
000230250601      dow 1 = 1;
000231250601        exfmt UPDATE1 UPDATE1ds;
000232250601        if Dspf.Exit;          // F3=Cancel
000233250601          Dspf.Exit = *off;
000234250601          leave;          // 戻る
000235250601        elseif *in04;       // F5=Update
000236250601          *in04 = *off;
000237250601          //chain UPDATE1ds.U_CUSTID CUSTOMERR CUSTOMERds;
000238250601          //if %found(CUSTOMER);
000239250601            //CUSTOMERds.CUST_ID  = %trim(UPDATE1ds.U_CUSTID);
000240250601            //CUSTOMERds.NAME  = %trim(UPDATE1ds.U_NAME);
000241250601            //CUSTOMERds.EMAIL = %trim(UPDATE1ds.U_EMAIL);
000242250601            //CUSTOMERds.PHONE = %trim(UPDATE1ds.U_PHONE);
000243250601            //update CUSTOMERR CUSTOMERds;
000244250601            //UPDATE1ds.MSG = '*Updated*';
000246250601          //ENDIF;
000247250601        endif;
000248250601        chain UPDATE1ds.U_CUSTID CUSTOMERR CUSTOMERds;
000249250601        if %found(CUSTOMER);
000250250601          CUSTOMERds.CUST_ID  = %trim(UPDATE1ds.U_CUSTID);
000251250601          CUSTOMERds.NAME  = %trim(UPDATE1ds.U_NAME);
000252250601          CUSTOMERds.EMAIL = %trim(UPDATE1ds.U_EMAIL);
000253250601          CUSTOMERds.PHONE = %trim(UPDATE1ds.U_PHONE);
000254250601          update CUSTOMERR CUSTOMERds;
000255250601          UPDATE1ds.MSG = 'Updated : ' + CUSTOMERds.CUST_ID + CUSTOMERds.NAME;
000258250601        ENDIF;
000259250601      enddo;
000260250601    // オプションの値に応じた処理Delete
000261250601    elseif Z1OPT = 'D';
000262250601      exfmt DELETER;
000263250601      if Dspf.Exit;          // F3=Cancel
000264250601          Dspf.Exit = *off;
000265250601      else;
000266250601        chain CUST_ID CUSTOMERR CUSTOMERds;
000267250601        if %found(CUSTOMER);
000268250601          delete CUSTOMERR;
000269250601        ENDIF;
000270250601        dFlg = 1;
000274250601      endif;
000275250601
000276250531    ENDIF;
000277250531
000278250531    Z1OPT = ' ' ;
000279250531    update SFL01 ; //既存サブファイル行を更新
000280250531  enddo ;
000281250705  if dFlg = 1;  //デリートがあった場合再読み込みする
000282250601    dFlg = 0;
000283250601    setll *loval CUSTOMER ;  //「ITMMSTR ファイルのキー順で、最初のレコードにポジションする」
000284250601    LoadSubfile() ;
000285250601  endif;
000286250531end-proc ;
