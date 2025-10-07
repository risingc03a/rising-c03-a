000100250515**FREE
000101250515ctl-opt nomain;
000102250515
000103250515//サブプロシージャプロトタイプ定義用copy句
000104250531/COPY QCRUD,PRCOPY
000112250515
000113250515//-------------------------------------
000114250515// ログインユーザチェック
000115250515//-------------------------------------
000116250515dcl-proc userCheckSql export;
000117250515  dcl-pi *n int(10);
000118250515    Id varchar(10) const;
000119250515    Pwd varchar(20) const;
000120250515  end-pi;
000121250515
000122250520  dcl-s sqlStmt varchar(256);
000123250515  dcl-s result int(10);
000124250515
000125250515  // 動的 SQL 文を構築・準備
000126250515  sqlStmt = 'select count(*)'
000127250515          + ' from usrac'
000128250515          + ' where ID = ?'
000129250520          + ' and PWD = ?';
000130250515  exec sql
000131250515    prepare S2 from :sqlStmt;
000132250515  exec sql
000133250515    declare C2 cursor for S2;
000134250515  exec sql
000135250520    open C2 using :Id ,: Pwd;
000136250515
000137250515  // カーソルからフェッチしながら表示
000138250515    exec sql
000139250515      fetch next from C2 into :result;
000140250515    //エラー時
000141250515    if sqlstate <> '00000';
000142250515      return 0;
000143250515    endif;
000144250515    // フェッチ成功
000145250515    //if sqlstate = '00000';
000146250515    //endif;
000147250515
000148250515  exec sql
000149250518    close C2;
000150250515
000151250515  return result;
000152250515end-proc;
000153250515
000213250518//-------------------------------------
000214250518// insert処理1
000215250518//-------------------------------------
000216250518dcl-proc insertSql1 export;
000217250518  dcl-pi *n int(10);
000218250518    insert1DsPointer pointer const;
000221250518  end-pi;
000222250518
000223250518  dcl-s sqlStmt      varchar(256);
000224250518  dcl-ds insertDs qualified based(insert1DsPointer);
000225250518    CUST_ID varchar(5);
000226250518    NAME varchar(20);
000227250602    EMAIL varchar(30);
000228250518    PHONE varchar(15);
000229250518  end-ds;
000230250518
000231250602  //dcl-s buf          char(52);
000232250518
000235250518  // ■ ① 動的 SQL 文を文字列で構築
000236250518  sqlStmt = 'insert into'
000237250518          + ' CUSTOMER values (?,?,?,?)';
000240250518
000241250518  // ■ ② PREPARE → DECLARE CURSOR FOR 準備
000242250518  exec sql
000243250518    prepare S3 from :sqlStmt;
000244250518
000245250518  exec sql execute S3 using :insertDs.CUST_ID,
000246250518              :insertDs.NAME,
000247250518              :insertDs.EMAIL,
000248250518              :insertDs.PHONE;
000256250602
000257250518  if sqlstate = '00000';
000258250602    *inlr = *on;
000259250602    return 1;
000260250518  endif;
000261250518
000262250518  *inlr = *on;
000263250602  return 0;
000264250518
000265250518END-PROC;
000266250518
000267250515
