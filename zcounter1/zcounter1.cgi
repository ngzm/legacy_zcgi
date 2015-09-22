#!/usr/bin/perl
###################################################################

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
#	=============== Zumin - カウンター１号 ===============
#
#   zcounter1.cgi
#
#   Copyright(c) 2001-  Zumin., All rights reserved.
#
#   Email : mailto:webmaster@zumin.cside9.com
#   URL   : http://zumin.cside9.com/zumin/
#
# =================================================================
#   更新履歴：
#   Date.       Ver.    Note.
#   2001.04.20  0.0.1   新規作成
#   2001.04.23  0.0.2   カウンターログファイル形式一部変更
#   2001.04.25  0.0.3   コメントなどちょこっと変更
#   2001.04.28  0.0.4   ライブラリ整理
#   2001.05.08  1.0.1   Ver.1 リリース
# =================================================================
$MajiorVer = "zcounter1_v1";
$MiniorVer = "01";
$FullVer   = "${MajiorVer}${MiniorVer}";


###################################################################
#
#	Use Library
#
###################################################################
require userdef;
require "gifcat.pl";


###################################################################
#
#	Define Globals 固定値
#
###################################################################

# カウンタファイルパス
$CountDataFilePath = "data/zcounter1.dat";

# ロックファイルパス
$LockFilePath = "data/zcounter1.lck";

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
#	Start Running Script
#
###################################################################

# 初期処理
&zCounterInit();

# 処理ロック
&LockCounterFile();

# カウンタデータ取得
my $cdata = &LoadCounterData();

# カウンタデータ更新
my $ndata = &UpdateCounterData($cdata);

# カウンターデータ書込み
&SaveCounterData($ndata);

# ロック解除
&UnlockCounterFile();

# カウンターイメージ出力
&CounterDisp($ndata->{count});

exit;


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
		$c->{ip},
	) =	(
		$Date,
		$Time,
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

	# 同一IPアドレスのチェックしない、
	# 同一IPアドレスではない、
	# 最終アクセスから日付が変わった、、
	if (!$CheckHomonymIp ||
		$ClientIp ne $c->{ip} ||
		$Date ne $c->{date}) {

		# ときは、カウンターを進める。
		$n->{count} = $c->{count} + 1;

	} else {

		# そうじゃないときは、カウンタそのまま。
		$n->{count} = $c->{count};
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
				"$c->{date}\t"  ,
				"$c->{time}\t"  ,
				"$c->{count}\t" ,
				"$c->{ip}"      ;
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
