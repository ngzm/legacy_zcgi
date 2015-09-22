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
#   また、本スクリプトは、とほほさん著作 gifcat.pl を使用、再配
#   布しています。こちらの使用上の注意もご確認ください。
#   http://wakusei.cplaza.ne.jp
#
# =================================================================
#
#	=============== Zumin - カウンター２号 ===============
#	===============       App Library      ===============
#
#   zcounter2.pm
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
#   2001.04.15  0.0.2   初期不具合FIX
#   2001.04.18  0.0.3   初期不具合FIX
#   2001.04.20  0.0.4   初期不具合FIX   初回リリース版
#   2001.04.24  0.0.5   カウンターログファイル形式一部変更
#   2001.04.26  0.0.6   管理機能追加に伴う修正
#   2001.04.28  0.0.7   ライブラリ整理
#   2001.05.01  0.0.8   カウンターログファイル形式一部変更
#   2001.05.08  0.0.9   アクセスログファイル形式変更
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
require "gifcat.pl";


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

# 数字イメージファイルパス
@ImageDataFilePath = (
		'counter_img/zero.gif',
		'counter_img/one.gif',
		'counter_img/two.gif',
		'counter_img/three.gif',
		'counter_img/four.gif',
		'counter_img/five.gif',
		'counter_img/six.gif',
		'counter_img/seven.gif',
		'counter_img/eight.gif',
		'counter_img/nine.gif',
);

# エラーイメージファイル
$ErrorImageFilePath = 'data/error.gif';

# クライアントIpAddress
$ClientIp = $ENV{'REMOTE_ADDR'};

# クライアントAgent
$ClientAgent = $ENV{'HTTP_USER_AGENT'};

# クライアントReferer
$ClientReferer = $ENV{'HTTP_REFERER'};

# 今日の日付
($Sec, $Min, $Hour, $Day, $Mon, $Year) = localtime(time());
$Date = sprintf("%04d-%02d-%02d", 1900 + $Year, $Mon + 1, $Day);
$Time = sprintf("%02d:%02d:%02d", $Hour, $Min, $Sec);

# シグナルハンドリング
# ロックファイルを確実に消す!
$SIG{'PIPE'} = "SigHandleExit";
$SIG{'INT'}  = "SigHandleExit";
$SIG{'HUP'}  = "SigHandleExit";
$SIG{'QUIT'} = "SigHandleExit";
$SIG{'TERM'} = "SigHandleExit";


###################################################################
#
#	初期処理
#
###################################################################
sub zCounterInit
{
	# -------------------------------------
	#	ユーザー定義変数のチェック
	# -------------------------------------

	# カウンターの表示桁数
	if ($CounterSize < 1 || $CounterSize > 16) {
		$CounterSize = 6;
	}
	# アクセスログ件数上限
	if ($AccessLogMax < 1 || $AccessLogMax > 2048) {
		$AccessLogMax = 2048;
	}
}

###################################################################
#
#	カウンターデータ取得
#
###################################################################
sub LoadCounterData
{
	# カウンターデータ初期値セット
	my $c = {};
	(	$c->{date},
		$c->{time},
		$c->{count},
		$c->{logcount},
		$c->{ip},
	) =	(
		$Date,
		$Time,
		0,
		0,
		'0.0.0.0',
	);

	# カウンターデータ読み込み
	if (-e "$CountDataFilePath") {
		open(CFILE, "$CountDataFilePath") || &ErrDisp();
		my $line = <CFILE>;
		close(CFILE);
		(	$c->{date},
			$c->{time},
			$c->{count},
			$c->{logcount},
			$c->{ip},
		) = split(/\t/, $line);
	}

	return $c;
}

###################################################################
#
#	カウンターデータ更新
#
###################################################################
sub UpdateCounterData
{
	my ($c) = @_;
	my $n = {};
	my $time1 = $Time;			$time1 =~ s/://g;
	my $time2 = $c->{time};		$time2 =~ s/://g;
	my $date1 = $Date;			$date1 =~ s/-//g;
	my $date2 = $c->{date};		$date2 =~ s/-//g;

	my $m = substr($time1, 2, 2) - substr($time2, 2, 2);
	my $h = ( substr($time1, 0, 2) - substr($time2, 0, 2) ) * 60;
	my $d = ( $date1 - $date2 ) * 24 * 60;
	my $span = $m + $h + $d;

	# 同一IPアドレスのチェックしない、
	# 同一IPアドレスではない、
	# 同一IPアドレスでも前回アクセスから一定時間経過している、、
	if (!$CheckHomonymIp ||
		$ClientIp ne $c->{ip} ||
		($NoCountSpan > 0 && $NoCountSpan < $span)) {

		# ときは、カウンターを進める。
		$n->{count} = $c->{count} + 1;

	} else {

		# そうじゃないときは、カウンタそのまま。
		$n->{count} = $c->{count};
	}

	# ログにセーブされた件数
	$n->{logcount} = $c->{logcount} + 1;

	# ログ件数が指定された件数を超えるときは、、
	if ($n->{logcount} >= $AccessLogMax) {

		# ログファイルを一旦クリアする。
		unlink("$AccessLogFilePath");

		# ログ件数フィールドクリア
		$n->{logcount} = 0;
	}

	# アクセス日
	$n->{date} = $Date;

	# アクセス時
	$n->{time} = $Time;

	# クライアントIPアドレス更新
	$n->{ip} = $ClientIp;

	return $n;
}

###################################################################
#
#	カウンターデータ保存
#
###################################################################
sub SaveCounterData
{
	my ($c) = @_;
	open(CFILE, "> $CountDataFilePath") || &ErrDisp();
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
#	ログーデータ追加
#
###################################################################
sub AddAccessLogData
{
	my ($c) = @_;

	# クライアントホスト名取得
	$c->{host} = gethostbyaddr(pack("C4", split(/\./, $c->{ip})), 2);

	# クライアントUSER-AGENT
	$c->{agent} = $ClientAgent;

	# クライアントReferer
	$c->{referer} = $ClientReferer;

	# ログファイルにアクセスログ追加
	open(CFILE, ">> $AccessLogFilePath") || &ErrDisp();
	print CFILE
				"$c->{date}\t"     ,
				"$c->{time}\t"     ,
				"$c->{count}\t"    ,
				"$c->{logcount}\t" ,
				"$c->{ip}\t"       ,
				"$c->{host}\t"     ,
				"$c->{agent}\t"    ,
				"$c->{referer}\n"   ;
	close(CFILE);
}

###################################################################
#
#	カウンターイメージ出力
#
###################################################################
sub CounterDisp
{
	my ($count) = @_;
	my $format = sprintf("%%0%dd", $CounterSize);
	my $count_txt = sprintf("$format", $count);
	my @img_files;

	# 各数字イメージファイルパス取得
	for (my $i = 0; $i < length($count_txt) ; $i++) {
		my $no = substr($count_txt, $i, 1) + 0;
		push(@img_files, "$ImageDataFilePath[$no]");
	}

	# イメージ連結処理
	if (&gifcat::gifcat(@img_files) != 1) {
		&ErrDisp();
	}

	# HTTPヘッダ出力
	print "Content-type: image/gif\n";
	print "\n";

	# データ出力
	binmode(STDOUT);
	print $gifcat::GifImage;
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
#	エラーイメージ表示処理
#
###################################################################
sub ErrDisp
{
	# アンロック処理
	unlink("$LockFilePath") if (-e "$LockFilePath");

	# エラーイメージファイル読み込み
	my ($dev, $ino, $mode, $nlink, $uid, $gid, $rdev,
		$size, $atime, $mtime, $ctime, $blksize, $blocks)
							 = stat($ErrorImageFilePath);

	open(EFILE, "$ErrorImageFilePath") || die;
	binmode(EFILE);
	my $eimg;
	read(EFILE, $eimg, $size);
	close(EFILE);

	# HTTPヘッダ出力
	print "Content-type: image/gif\n";
	print "\n";

	# エラーイメージ出力
	binmode(STDOUT);
	print $eimg;

	exit;
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
