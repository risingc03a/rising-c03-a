001500250518**FREE
001501250518ctl-opt main(main);
001502250515
001503250515//サブプロシージャプロトタイプ定義用copy句
001504250531/COPY QCRUD,PRCOPY
001508250515
001511250601dcl-ds PgmDs psds qualified ;//（Program Status Data Structure）
001512250601  PgmName *proc ; //*procプログラム自身の名前が入る
001513250601end-ds ;
001514250517
001515250517//--------------------------------------------
001516250517//各画面制御
001517250517//--------------------------------------------
001518250515dcl-proc main;
001519250515  dcl-f MAIND workstn usropn;
001520250515  dcl-ds MAINRds likerec(MAINR:*all);
001523250518  dcl-ds INSERTR1ds likerec(INSERTR1:*all);
001526250515
001528250518  dcl-s fldFlg int(10);
001529250518  dcl-s fldName varchar(20);
001530250518  dcl-s fldValue varchar(1);
001531250602  dcl-s rc int(10);
001537250518
001538250518  dcl-ds insert1Ds qualified;
001539250518    CUST_ID varchar(5);
001540250518    NAME varchar(20);
001541250602    EMAIL varchar(30);
001542250518    PHONE varchar(15);
001543250518  end-ds;
001544250515
001549250518  *INLR = *OFF;
001550250518  clear *IN;
001551250515  open MAIND;
001552250601
001553250601  MAINRds.MSCREEN = %trimr(PgmDs.PgmName) + '-1' ;
001554250601  INSERTR1ds.ISCREEN = %trimr(PgmDs.PgmName) + 'INSERT' ;
001555250515
001556250515  dow *in03 = *off;
001557250518
001558250515    exfmt MAINR MAINRds;
001559250518    if *in03 = *on;
001560250518      leave;
001561250518    ENDIF;
001562250518
001563250518    if MAINRds.IN1 <> '';
001564250518      fldFlg = fldFlg + 1;
001565250518      fldValue = MAINRds.IN1;
001566250601      fldName = 'CUSTOMER';
001567250518    endif;
001568250604    //if MAINRds.IN2 <> '';
001569250604      //fldFlg = fldFlg + 1;
001570250604      //fldValue = MAINRds.IN2;
001571250604      //fldName = 'ADDRESS';
001572250604    //endif;
001573250604    //if MAINRds.IN3 <> '';
001574250604      //fldFlg = fldFlg + 1;
001575250604      //fldValue = MAINRds.IN3;
001576250604      //fldName = 'ORDER';
001577250604    //endif;
001578250518
001579250518    if fldFlg = 0;
001580250518      MAINRds.MSG = '処理内容を入力してください';
001581250518    elseif fldFlg = 1;
001582250518      exsr srDispatch;
001583250518    elseif fldFlg >= 2;
001584250518      MAINRds.MSG = '処理対象は一つのみ選択してください';
001585250518    ENDIF;
001586250517
001587250518    fldFlg = 0;
001588250518    clear fldValue;
001589250518    clear fldName;
001590250517
001591250515  enddo;
001592250515
001593250515  close MAIND;
001596250518  *in03 = *off;
001597250515  *inlr = *on;
001598250515  return;
001599250518
001600250518  //--------------------------------------------
001601250518  //処理内容制御
001602250518  //--------------------------------------------
001603250518  begsr srDispatch;
001604250518
001605250518    if fldValue = '1';
001606250601      SelectCustomer();
001607250518    elseif fldValue = '2';
001608250601      if fldName = 'CUSTOMER';
001609250518        exsr srInsert1;
001610250601      elseif fldName = 'ADDRESS';
001611250601        //exsr srInsert2;
001612250601      elseif fldName = 'ORDER';
001613250601        //exsr srInsert3;
001614250518      endif;
001615250518    else;
001616250518      MAINRds.MSG = '有効な値を入力してください';
001617250518    ENDIF;
001618250518
001619250518  endsr;
001620250517
001651250518  //--------------------------------------------
001652250518  //insert画面1
001653250518  //--------------------------------------------
001654250518  begsr srInsert1;
001655250518    dow *in03 = *off;
001656250518      exfmt INSERTR1 INSERTR1ds;
001657250518      if *in03 = *on;
001658250602        *in03 = *off;
001659250518        leave;
001660250518      ENDIF;
001661250518      if INSERTR1ds.CUST_ID<>''
001662250518        and INSERTR1ds.NAME<>''
001663250518        and INSERTR1ds.EMAIL<>''
001664250518        and INSERTR1ds.PHONE<>'';
001665250518        insert1Ds.CUST_ID = %trim(INSERTR1ds.CUST_ID);
001666250518        insert1Ds.NAME = %trim(INSERTR1ds.NAME);
001667250518        insert1Ds.EMAIL = %trim(INSERTR1ds.EMAIL);
001668250518        insert1Ds.PHONE = %trim(INSERTR1ds.PHONE);
001669250518
001670250602        rc = 0;
001671250602        rc = insertSql1(%addr(insert1Ds));
001672250602        if rc = 1;
001673250602          INSERTR1ds.MSG = '新規レコードを作成しました。';
001674250602          commit;
001675250602        else;
001676250602          INSERTR1ds.MSG = 'INSERTエラー';
001677250602        endif;
001678250518      else;
001679250518        INSERTR1ds.MSG = '全ての入力欄に入力してください';
001680250518
001681250518      ENDIF;
001682250518
001683250518    ENDDO;
001684250518    *in03 = *off;
001685250518  ENDSR;
001686250518
001711250515end-proc;
