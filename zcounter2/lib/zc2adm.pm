# =================================================================
#
#   □□□ 最初にご確認ください □□□
#
#   本スクリプトはフリーソフトです。著作権は放棄していません。
#   非営利目的で使用される場合に限り、自由に使用、カスタマイズ、
#   再配布可能です。
#
#   尚、このスクリプトを使用したいかなる損害に対して、著作者は
#   一切その責を負いません。
#
# =================================================================
#
#	=============== Zumin - カウンター２号 ==============
#	============  管理者ツール App Library  =============
#
#   zc2adm.pm
#
#   Copyright(c) 2001-  Zumin., All rights reserved.
#
#   Email : mailto:webmaster@zumin.cside9.com
#   URL   : http://zumin.cside9.com/zumin/
#
# =================================================================
#   更新履歴：
#   Date.       Ver.    Note.
#   2001.04.14  0.0.1   初版
#   2001.04.23  0.0.2   初期不具合ＦＩＸ
#   2001.04.25  0.0.3   管理者認証機能追加
#   2001.04.26  0.0.4   管理者認証機能不具合ＦＩＸ
#   2001.04.28  0.0.5   ライブラリ整理
#   2001.05.01  0.0.6   カウンターログファイル形式一部変更
#   2001.05.03  0.0.7   ブラウザ表示ブラッシュアップ
#   2001.05.08  0.0.8   アクセスログファイル形式変更
#   2001.05.08  1.0.1   Ver.1 リリース
#   2001.05.10  1.0.2   カウンター更新処理不具合対応
#   2001.05.10  1.0.3   管理機能表示形式若干修正
#   2001.05.26  1.0.4   デモ用、機能削減追加
#   2001.05.28  1.0.5   暗号処理（簡易版）追加
#   2001.06.15  1.0.6   クッキー有効期限を指定可能にする
#   2001.06.15  1.0.7   ログ項目にUSER-AGENT追加
#   2002.09.28  1.1.0   HTTPヘッダにキャッシュしない指示を追加
# =================================================================


###################################################################
#
#	Use Library
#
###################################################################
use		zcgi;


###################################################################
#
#	Define Globals 固定値
#
###################################################################

# カウンタファイルパス
$CountDataFilePath = "data/zcounter2.dat";

# ログファイルパス
$AccessLogFilePath = "data/zcounter2.log";

# ロックファイルパス
$LockFilePath = "data/zcounter2.lck";

# クッキー名称
$MyCookieName = 'ZC2ADM';

# ログ一覧一ページあたりの表示件数
$AdminPageCount = 50;

# シグナルハンドリング
# ロックファイルを確実に消す!
$SIG{'PIPE'} = "SigHandleExit";
$SIG{'INT'}  = "SigHandleExit";
$SIG{'HUP'}  = "SigHandleExit";
$SIG{'QUIT'} = "SigHandleExit";
$SIG{'TERM'} = "SigHandleExit";

# デモ用（普通は 0 固定）
$DemoUse = 0;

###################################################################
#
#	初期処理
#
###################################################################
sub zAdmInit
{
	# 管理者パスワードチェック
	if ($AdminPasswd eq '') {
		&PrintHeader();
		&PrintErr('管理者パスワードが定義されていません');
		&PrintFooter();
		exit;
	}
	if (length $AdminPasswd < 4) {
		&PrintHeader();
		&PrintErr('管理者パスワードは4バイト以上で定義してください');
		&PrintFooter();
		exit;
	}
	if (length $AdminPasswd > 16) {
		&PrintHeader();
		&PrintErr('管理者パスワードが16バイトを超えています');
		&PrintFooter();
		exit;
	}
	if ($AdminPasswd !~ /[\w\d]+/) {
		&PrintHeader();
		&PrintErr('管理者パスワードは半角英数字で定義してください');
		&PrintFooter();
		exit;
	}

	# 暗号化キー
	if ($CriptKey eq '') {
		&PrintHeader();
		&PrintErr('管理者パスワード暗号化キーが定義されていません');
		&PrintFooter();
		exit;
	}
	if (length $CriptKey < 4) {
		&PrintHeader();
		&PrintErr('管理者パスワード暗号化キーは4バイト以上で定義してください');
		&PrintFooter();
		exit;
	}
	if (length $CriptKey > 16) {
		&PrintHeader();
		&PrintErr('管理者パスワード暗号化キーが16バイトを超えています');
		&PrintFooter();
		exit;
	}
	if ($CriptKey !~ /[\w\d]+/) {
		&PrintHeader();
		&PrintErr('管理者パスワード暗号化キーは半角英数字で定義してください');
		&PrintFooter();
		exit;
	}
}

###################################################################
#
#	HTML ヘッダ書き出し
#
###################################################################
sub PrintHeader
{
	my ($cookie) = @_;

	# サーバー日本語文字コード取得
	my $saver_jcode = &GetSaverEncode();

	# HTTP ヘッダ
	print "Pragma: no-cache\n";
	print "Cache-Control: no-cache\n";
	print "Content-Type: text/html; charset=$saver_jcode\n";

	# Cookieの設定要求があれば Cookie 発行
	print "$cookie\n"  if ($cookie ne '');
	print "\n";

print <<"EOHD"
<html>
<head>
<title>Zcounter Admin Tool [ FOR $CurrentVer ]</title>
</head>

<body bgcolor="#FFFFFF">
<center>
<table width="95%" bgcolor="CCCCFF" border="0" cellpadding="3" cellspacing="3">
<tr>
<td align="center">[ <a href="$HomeURL">HOME</a> ]<br></td>
</tr>
</table>
<p>
<h2>COUNTER 管理</h2>
<p>
EOHD

}

###################################################################
#
#	HTML フッタ書き出し
#
###################################################################
sub PrintFooter
{
	# 著作者バナー用
	my $zuminURL = "http://zumin.cside9.com/zumin/";

print <<"EOFT"
<p>

<table width="95%" bgcolor="CCCCFF" border="0" cellpadding="3" cellspacing="3">
<tr>
<td align="center">
<address>$CurrentVer CGI Script &copy; 2001- <a href="$zuminURL" target="zumin">ZUMIN</a></address>
</td>
</tr>
</table>

</center>
</body>
</html>
EOFT
}

###################################################################
#
#	エラー時HTML表示処理
#
###################################################################
sub PrintErr
{
	my ($err) = @_;
	print "<font color=\"#FF0000\">$err</font>\n";
}

###################################################################
#
#	ログデータ一覧書き出し
#
###################################################################
sub PrintLogList
{
	my ($c) = @_;

	# ログデータ一覧取得
	my @logs = &GetLogList();
	if (@logs eq '') {
		return;
	}

	# ログデータ一覧チェック
	my $logcnt = @logs;
	if ($logcnt == 0) {
		&PrintErr('アクセスログにデータがありません');
		return;
	}

	# 表示ページの調整
	my $pagemax = int(($logcnt - 1) / $AdminPageCount) + 1;
	my $page = ($c->{page} < 1) ? 1 : $c->{page};
	my $start = ($page - 1) * $AdminPageCount + 1;
	if ($start > $logcnt) {
		$page  = $pagemax;
		$start = ($page - 1) * $AdminPageCount + 1;
	}
	my $end = $start + $AdminPageCount;

	# ログデータ書き出し
	# テーブルヘッダ
{
print <<"EOTH"
<table width="95%" border="0" cellpadding="5" cellspacing="2">
<tr bgcolor="#AADDAA">
	<th nowrap>No</th>
	<th nowrap>Count</th>
	<th nowrap>Date</th>
	<th nowrap>訪問者IP</th>
	<th nowrap>訪問者Host</th>
	<th nowrap>訪問者Agent</th>
</tr>
EOTH
}
	# ログデータ書き出し
	# 取得したデータ表示
	my $lineno = 0;
	foreach my $c (@logs) {

		$lineno++;
		next if ($lineno < $start);
		last if ($lineno >= $end);

		my $date     = &Cdata($c->{date});
		my $time     = &Cdata($c->{time});
		my $count    = &Cdata($c->{count});
		my $logcount = &Cdata($c->{logcount});
		my $ip       = &Cdata($c->{ip})			unless ($DemoUse);
		my $host     = &Cdata($c->{host})		unless ($DemoUse);
		my $agent    = &Cdata($c->{agent})		unless ($DemoUse);
		my $refferer = &Cdata($c->{refferer})	unless ($DemoUse);
{
print <<"EOD"
<tr bgcolor="#DDDDDD">
	<td nowrap align="right">$logcount<br></td>
	<td nowrap align="right">$count<br></td>
	<td nowrap align="left">$date&nbsp;&nbsp;$time<br></td>
	<td nowrap align="left">$ip<br></td>
	<td nowrap align="left">$host<br></td>
	<td align="left">$agent<br></td>
</tr>
EOD
}
	}
{
print <<"EOTE"

</table>

EOTE
}
	# ページ
	print "<table width=\"90%\" border=\"0\" cellpadding=\"1\" cellspacing=\"1\">\n";
	print "<tr>\n";
	print "\t<td align=\"right\" width=\"10%\"><strong>Page: </strong></td>\n";
	print "\t<td align=\"left\">\n";
	for (my $i = 1; $i <= $pagemax ; $i++) {
		if ($i == $page) {
			print "\t<strong>&nbsp;${i}&nbsp;</strong>\n";
		} else {
			print "\t<a href=\"zc2adm.cgi?page=$i\">&nbsp;${i}&nbsp;</a>\n";
		}
	}
	print "\t</td>\n";
	print "</tr>\n";
	print "</table>\n";

	# コマンドボタン表示
	print "<table border=\"0\" cellpadding=\"1\" cellspacing=\"0\">\n";
	print "<tr>\n";

	# ログのダウンロード
	print "<td align=\"left\">\n";
	print "<form action=\"zc2adm.cgi\" method=\"GET\">\n";
	print "<input type=\"hidden\" name=\"download\" value=\"download\">\n";
	print "<input type=\"submit\" value=\"ログダウンロード\">\n";
	print "</form>\n";
	print "</td>\n";

	# ログのクリア
	print "<td align=\"right\">\n";
	print "<form action=\"zc2adm.cgi\" method=\"GET\">\n";
	print "<input type=\"hidden\" name=\"clear\" value=\"clear\">\n";
	print "<input type=\"submit\" value=\"ログクリア\" "			.
			"onClick=\"return confirm(" 							.
			"'全てのアクセスログを削除しますが宜しいですか？')\">\n";
	print "</form>\n";
	print "</td>\n";

	print "</tr>\n";
	print "</table>\n";
}

###################################################################
#
#	パスワード入力フォーム書き出し
#
###################################################################
sub PrintPasswdForm
{
print <<"EOPS"
<p>
管理者の認証パスワードを入力してください。
<form action="zc2adm.cgi" method="POST">
	<input type="password" name="passwd" maxlength="16">
	<input type="submit" value="送信">
</form>
EOPS
}

###################################################################
#
#	ログデータ一覧取得
#
###################################################################
sub GetLogList
{
	my @logs;

	# ログデータ読み込み
	unless (-e "$AccessLogFilePath") {
		&PrintErr('ログファイルが見つかりません');
		return;
	}
	open(CFILE, "$AccessLogFilePath") ||
		&FatalError('ログファイルオープンエラー', $LockFilePath);

	# ログファイル読み込み
	while (my $line = <CFILE>) {
		chomp $line;

		# データを分解
		my $c = {};
		(	$c->{date},
			$c->{time},
			$c->{count},
			$c->{logcount},
			$c->{ip},
			$c->{host},
			$c->{agent},
			$c->{refferer},
		) = split(/\t/, $line);

		# データ格納
		unshift(@logs, $c);
	}

	# ログファイルクローズ
	close(CFILE);

	return @logs;
}

###################################################################
#
#	ログデータファイルクリア（ファイル削除）
#
###################################################################
sub ClearAllLog
{
	# アクセスログデータファイルを削除する
	if (-e "$AccessLogFilePath") {
		unlink($AccessLogFilePath);
	}

	# カウンターデータ読み込み
	my $c = {};
	if (-e "$CountDataFilePath") {
		open(CFILE, "$CountDataFilePath") ||
			&FatalError('ログファイルオープンエラー', $LockFilePath);
		my $line = <CFILE>;
		close(CFILE);
		(	$c->{date},
			$c->{time},
			$c->{count},
			$c->{logcount},
			$c->{ip},
		) = split(/\t/, $line);
	}

	# アクセスログカウントクリア
	$c->{logcount} = 0;

	# カウンターデータ保存
	open(CFILE, "> $CountDataFilePath") ||
			&FatalError('ログファイルオープンエラー', $LockFilePath);
	print CFILE
				"$c->{date}\t"     ,
				"$c->{time}\t"     ,
				"$c->{count}\t"    ,
				"$c->{logcount}\t" ,
				"$c->{ip}"         ;
	close(CFILE);
}

###################################################################
#
#	ログデータファイルダウンロード
#
###################################################################
sub DownloadLog
{
	# HTTP ヘッダ出力
	# Content-Disposition: HTTPヘッダを出力する。
	print "Content-Type: text/comma-separated-values; charset=Shift_JIS\n";
	print "Content-Disposition: inline; filename=\"zcounter.csv\"\n";
	print "\n";

	# ログデータ読み込み
	unless (-e "$AccessLogFilePath") {
		return;
	}
	open(CFILE, "$AccessLogFilePath") ||
			&FatalError('ログファイルオープンエラー', $LockFilePath);

	# ログファイル読み込み
	while (my $line = <CFILE>) {
		chomp $line;

		# CSV形式に変換
		$line =~ s/\t/\,/g;

		# Shift_JIS に変換する。
		$line = &ConvStr($line, $SJIS);

		# ログデータ出力
		print "$line\n";
	}

	# ログファイルクローズ
	close(CFILE);

	return 1;
}

###################################################################
#
#	カウンターファイルロック処理
#
###################################################################
sub LockCounterFile
{
	# リトライ回数上限のチェック
	my $retry_max = 8;
	my $retry = 0;

	# カウンターファイルロック解除待ち
	while (-e "$LockFilePath") {

		# リトライ回数上限のチェック
		$retry++;
		&ErrDisp() if ($retry > $retry_max);

		# Sleep
		sleep(1);
	}

	# カウンターファイルロック処理
	open(LOCK, "> $LockFilePath") || &ErrDisp();
	print LOCK "Locking\n";
	close(LOCK);
}

###################################################################
#
#	カウンターファイルアンロック処理
#
###################################################################
sub UnlockCounterFile
{
	if (-e "$LockFilePath") {
		unlink("$LockFilePath") || &ErrDisp();
	}
}

###################################################################
#
#	シグナルハンドリング処理
#
###################################################################
sub SigHandleExit
{
	# アンロック処理
	unlink("$LockFilePath") if (-e "$LockFilePath");
	exit;
}

###################################################################
#
#	デモ版ごめんなさいメッセージ出力
#
###################################################################
sub SorryButDemo
{
	my ($p) = @_;
	&PrintHeader($p->{cookie});
	print "<h2>デモ版なので動きません。ごめんなさい。</h2>\n";
	&PrintFooter();
}

###################################################################
1
