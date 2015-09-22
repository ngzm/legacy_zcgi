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
#	============= Zumin - ゲストブック１号 ==============
#	========= ゲストブック本体 ＆ 管理者ツール ==========
#	================= 共通 App Library  =================
#
#   zg1core.pm
#
#   Copyright(c) 2001-  Zumin., All rights reserved.
#
#   Email : mailto:webmaster@zumin.cside9.com
#   URL   : http://zumin.cside9.com/zumin/
#
# =================================================================
#   更新履歴：
#   Date.       Ver.    Note.
#   2001.04.23  0.0.1   新規作成
#   2001.04.27  0.0.2   初期不具合修正
#   2001.04.28  0.0.3   アイコン表示機能整備
#   2001.04.28  0.0.4   投稿ログ削除機能追加
#   2001.05.01  0.0.5   URL文字をアンカーに変更する処理追加
#   2001.05.09  0.0.6   APPライブラリを整理しzg1core.pmを追加
#   2001.05.11  0.0.7   返信処理拡張
#   2001.05.12  0.0.8   １件削除、全クリア処理サポート
#   2001.05.12  0.0.9   投稿ログ表示ブラッシュアップ
#   2001.05.17  0.0.8   投稿ログ保存形式を一般的な形に変更
#   2001.05.19  1.0.1   リリース第１版
#   2001.05.23  1.0.2   ログ登録処理若干効率化
#   2001.05.24  1.0.3   返信ログ登録処理若干効率化
#   2001.05.26  1.0.4   デモ用、機能削減追加
#   2001.05.28  1.0.5   暗号処理（簡易版）追加
#   2001.06.15  1.0.6   クッキー有効期限を指定可能にする
#   2001.06.15  1.0.7   訪問者のプロファイルをクッキーに記憶（60日）
#   2002.05.25  1.0.8   名前、E-MAIL、HP-NAME、URL入力テキストサイズ拡大
#   2002.09.28  1.1.0   HTTPヘッダにキャッシュしない指示を追加
#   2002.10.05  1.2.0   ログダウンロードのCSVファイルのカンマや改行などを
#                       含むデータのときにフォーマットが壊れていた不具合
#                       に対応
#   2002.10.14  1.3.0   管理者ツールに投稿ログ検索機能追加
#   2003.01.25  1.3.1   アイコン表示数制限数を10から30に増加
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

# 伝言版ログデータファイル
$LogDataFilePath = 'data/zguest1.dat';

# 伝言版カウンターデータファイル
$LogCounterFilePath = 'data/zguest1.cnt';

# ロックファイルパス
$LockFilePath = 'data/zguest1.lck';

# テンポラリファイルパス
$TmpFilePath = 'data/zguest1.tmp';

# アイコンファイルディレクトリ
$UserImgPath = 'img';

# シグナルハンドリング
# ロックファイルを確実に消す!
$SIG{'PIPE'} = "ZguestExit";
$SIG{'INT'}  = "ZguestExit";
$SIG{'HUP'}  = "ZguestExit";
$SIG{'QUIT'} = "ZguestExit";
$SIG{'TERM'} = "ZguestExit";

# エラーメッセージ
@ErrorMessage;

# 書込みメッセージ文字色
@UserLogColor;

# 書込みメッセージに表示するアイコン
@UserLogIcon;

# メッセージ表示対象ログ数
$MessageDispCount1 = 0;
$MessageDispCount2 = 0;

# 指定シリアル番号の投稿メッセージに対する最大レス番号
$TargetSerial_MaxResNumber = 0;


###################################################################
#
#	初期処理
#
###################################################################
sub zGuestInit
{
	# ゲストブックログ件数最大数
	if ($MaxLogCount < 1 || $MaxLogCount > 512) {
		$MaxLogCount = 256;
	}
	# ページの背景
	if ($UserBgColor eq '' && $UserBgImg !~ /^#[0-9a-fA-F]{6}$/) {
		$UserBgColor = '#FFFFFF';
	}
	# ページの背景画像
	if ($UserBgImg ne '') {
		$UserBgImg = $UserImgPath . '/' . $UserBgImg;
	}
	# ページ本文の文字色
	if ($UserFgColor !~ /^#[0-9a-fA-F]{6}$/) {
		$UserFgColor = '#FFFFFF';
	}
	# タイトル
	if ($UserTitle eq '' && $UserTitleImg eq '') {
		$UserTitle = 'GUEST BOOK';
	}
	# タイトル色
	if ($UserTitleColor !~ /^#[0-9a-fA-F]{6}$/) {
		$UserTitleColor = '#FFFFFF';
	}

	# 書込みメッセージ文字色
	if ($UserLogColor_1 =~ /^#[0-9a-fA-F]{6}$/) {
		push(@UserLogColor, $UserLogColor_1);
	}
	if ($UserLogColor_2 =~ /^#[0-9a-fA-F]{6}$/) {
		push(@UserLogColor, $UserLogColor_2);
	}
	if ($UserLogColor_3 =~ /^#[0-9a-fA-F]{6}$/) {
		push(@UserLogColor, $UserLogColor_3);
	}
	if ($UserLogColor_4 =~ /^#[0-9a-fA-F]{6}$/) {
		push(@UserLogColor, $UserLogColor_4);
	}
	if ($UserLogColor_5 =~ /^#[0-9a-fA-F]{6}$/) {
		push(@UserLogColor, $UserLogColor_5);
	}
	if ($UserLogColor_6 =~ /^#[0-9a-fA-F]{6}$/) {
		push(@UserLogColor, $UserLogColor_6);
	}
	if ($UserLogColor_7 =~ /^#[0-9a-fA-F]{6}$/) {
		push(@UserLogColor, $UserLogColor_7);
	}
	if ($UserLogColor_8 =~ /^#[0-9a-fA-F]{6}$/) {
		push(@UserLogColor, $UserLogColor_8);
	}
	if ($UserLogColor_9 =~ /^#[0-9a-fA-F]{6}$/) {
		push(@UserLogColor, $UserLogColor_9);
	}
	if ($UserLogColor_10 =~ /^#[0-9a-fA-F]{6}$/) {
		push(@UserLogColor, $UserLogColor_10);
	}
	# 書込みメッセージに表示するアイコン
	if ($UserLogIcon_1 ne '') {
		push(@UserLogIcon, "${UserImgPath}\/${UserLogIcon_1}");
	}
	if ($UserLogIcon_2 ne '') {
		push(@UserLogIcon, "${UserImgPath}\/${UserLogIcon_2}");
	}
	if ($UserLogIcon_3 ne '') {
		push(@UserLogIcon, "${UserImgPath}\/${UserLogIcon_3}");
	}
	if ($UserLogIcon_4 ne '') {
		push(@UserLogIcon, "${UserImgPath}\/${UserLogIcon_4}");
	}
	if ($UserLogIcon_5 ne '') {
		push(@UserLogIcon, "${UserImgPath}\/${UserLogIcon_5}");
	}
	if ($UserLogIcon_6 ne '') {
		push(@UserLogIcon, "${UserImgPath}\/${UserLogIcon_6}");
	}
	if ($UserLogIcon_7 ne '') {
		push(@UserLogIcon, "${UserImgPath}\/${UserLogIcon_7}");
	}
	if ($UserLogIcon_8 ne '') {
		push(@UserLogIcon, "${UserImgPath}\/${UserLogIcon_8}");
	}
	if ($UserLogIcon_9 ne '') {
		push(@UserLogIcon, "${UserImgPath}\/${UserLogIcon_9}");
	}
	if ($UserLogIcon_10 ne '') {
		push(@UserLogIcon, "${UserImgPath}\/${UserLogIcon_10}");
	}
	# 書込みメッセージに表示するアイコン
	# 10から30に増加（2003/01/25）
	if ($UserLogIcon_11 ne '') {
		push(@UserLogIcon, "${UserImgPath}\/${UserLogIcon_11}");
	}
	if ($UserLogIcon_12 ne '') {
		push(@UserLogIcon, "${UserImgPath}\/${UserLogIcon_12}");
	}
	if ($UserLogIcon_13 ne '') {
		push(@UserLogIcon, "${UserImgPath}\/${UserLogIcon_13}");
	}
	if ($UserLogIcon_14 ne '') {
		push(@UserLogIcon, "${UserImgPath}\/${UserLogIcon_14}");
	}
	if ($UserLogIcon_15 ne '') {
		push(@UserLogIcon, "${UserImgPath}\/${UserLogIcon_15}");
	}
	if ($UserLogIcon_16 ne '') {
		push(@UserLogIcon, "${UserImgPath}\/${UserLogIcon_16}");
	}
	if ($UserLogIcon_17 ne '') {
		push(@UserLogIcon, "${UserImgPath}\/${UserLogIcon_17}");
	}
	if ($UserLogIcon_18 ne '') {
		push(@UserLogIcon, "${UserImgPath}\/${UserLogIcon_18}");
	}
	if ($UserLogIcon_19 ne '') {
		push(@UserLogIcon, "${UserImgPath}\/${UserLogIcon_19}");
	}
	if ($UserLogIcon_20 ne '') {
		push(@UserLogIcon, "${UserImgPath}\/${UserLogIcon_20}");
	}
	if ($UserLogIcon_21 ne '') {
		push(@UserLogIcon, "${UserImgPath}\/${UserLogIcon_21}");
	}
	if ($UserLogIcon_22 ne '') {
		push(@UserLogIcon, "${UserImgPath}\/${UserLogIcon_22}");
	}
	if ($UserLogIcon_23 ne '') {
		push(@UserLogIcon, "${UserImgPath}\/${UserLogIcon_23}");
	}
	if ($UserLogIcon_24 ne '') {
		push(@UserLogIcon, "${UserImgPath}\/${UserLogIcon_24}");
	}
	if ($UserLogIcon_25 ne '') {
		push(@UserLogIcon, "${UserImgPath}\/${UserLogIcon_25}");
	}
	if ($UserLogIcon_26 ne '') {
		push(@UserLogIcon, "${UserImgPath}\/${UserLogIcon_26}");
	}
	if ($UserLogIcon_27 ne '') {
		push(@UserLogIcon, "${UserImgPath}\/${UserLogIcon_27}");
	}
	if ($UserLogIcon_28 ne '') {
		push(@UserLogIcon, "${UserImgPath}\/${UserLogIcon_28}");
	}
	if ($UserLogIcon_29 ne '') {
		push(@UserLogIcon, "${UserImgPath}\/${UserLogIcon_29}");
	}
	if ($UserLogIcon_30 ne '') {
		push(@UserLogIcon, "${UserImgPath}\/${UserLogIcon_30}");
	}

	# 投稿ログ表示背景色
	if ($UserLogBgColor !~ /^#[0-9a-fA-F]{6}$/) {
		$UserLogBgColor = '#FFFFFF';
	}
	# 返信ログ表示背景色
	if ($UserLogResBgColor !~ /^#[0-9a-fA-F]{6}$/) {
		$UserLogResBgColor = '#FFFFFF';
	}
	# 書き込まれたログ1ページあたりの表示件数
	if ($LogDisplayCount < 1 || $LogDisplayCount > 100) {
		$LogDisplayCount = 20;
	}
	# メッセージログのメール部分に表示するアイコン。
	$UserLogMailIcon = $UserImgPath . '/' . $UserLogMailIcon;

	# メッセージログのホーム部分に表示するアイコン。
	$UserLogHomeIcon = $UserImgPath . '/' . $UserLogHomeIcon;

	# 管理者パスワードチェック
	if ($AdminPasswd eq '') {
		push(@ErrorMessage, '管理者パスワードが定義されていません');
	}
	if (length $AdminPasswd < 4) {
		push(@ErrorMessage, '管理者パスワードは4バイト以上で定義してください');
	}
	if (length $AdminPasswd > 16) {
		push(@ErrorMessage, '管理者パスワードが16バイトを超えています');
	}
	if ($AdminPasswd !~ /[\w\d]+/) {
		push(@ErrorMessage, '管理者パスワードは半角英数字で定義してください');
	}
	# 暗号化キー
	if ($CriptKey eq '') {
		push(@ErrorMessage, '管理者パスワード暗号化キーが定義されていません');
	}
	if (length $CriptKey < 4) {
		push(@ErrorMessage, '管理者パスワード暗号化キーは4バイト以上で定義してください');
	}
	if (length $CriptKey > 16) {
		push(@ErrorMessage, '管理者パスワード暗号化キーが16バイトを超えています');
	}
	if ($CriptKey !~ /[\w\d]+/) {
		push(@ErrorMessage, '管理者パスワード暗号化キードは半角英数字で定義してください');
	}

	return (@ErrorMessage == 0);
}

###################################################################
#
#	メッセージカウンターデータの読込
#
###################################################################
sub GetLogCounter
{
	# メッセージカウンターデータが存在しないときはすぐぬけよう
	unless (-e "$LogCounterFilePath") { return; }
	open(CFILE, "$LogCounterFilePath") ||
		&FatalError("Fatal!!! $LogCounterFilePath Open Error", $LockFilePath);
	my $line = <CFILE>;
	close(CFILE);
	chomp $line;
	return $line;
}

###################################################################
#
#	メッセージカウンターデータの書込
#
###################################################################
sub SetLogCounter
{
	my ($line) = @_;
	open(CFILE, "> $LogCounterFilePath") ||
		&FatalError("Fatal!!! $LogCounterFilePath Open Error", $LockFilePath);
	print CFILE "$line";
	close(CFILE);
}

###################################################################
#
#	メッセージログファイルの読込
#
###################################################################
sub GetLogData
{
	my ($p) = @_;
	my %logdata;

	# メッセージログが存在しないときはすぐぬけよう
	unless (-e "$LogDataFilePath") { return; }

	# メッセージログオープン
	open(CFILE, "$LogDataFilePath") ||
		&FatalError("Fatal!!! $LogDataFilePath Open Error", $LockFilePath);

	$MessageDispCount1 = 0;
	$MessageDispCount2 = 0;
	my $cur_serial = -1;

	# メッセージログの読込
	while (my $line = <CFILE>) {

		# 改行コード削除
		chomp $line;

		# 読込行をキーと値に分割
		my $d = {};
		(
			$d->{serial},		# シリアル番号
			$d->{resnumber},	# レス通し番号
			$d->{delkey},		# 削除キー
			$d->{deleted},		# 削除フラグ
			$d->{date},			# 日付
			$d->{time},			# 時間
			$d->{ip},			# IP
			$d->{host},			# Hostname
			$d->{subject},		# 表題
			$d->{name},			# 投稿者名
			$d->{sex},			# 性別
			$d->{email},		# Email
			$d->{hpname},		# HP名
			$d->{url},			# HP-URL
			$d->{fgcol},		# メッセージ文字色番号
			$d->{icon},			# アイコン番号
			$d->{body},			# メッセージ
		) = split(/\t/, $line);

		# 2002.10.14 検索機能の実装
		if ($p->{command} eq 'search') {
			if ($p->{taisyo} eq 'name') {
				next if ($d->{name} !~ /$p->{search_key}/);
			}
			if ($p->{taisyo} eq 'body') {
				next if ($d->{body} !~ /$p->{search_key}/);
			}
		}

		# 格納するハッシュキーを作成
		my $key = "$d->{serial}:$d->{resnumber}";

		# ログデータを格納する。
		$logdata{$key} = $d;

		# メッセージ表示ログカウント
		if (!$d->{deleted}) {
			$MessageDispCount1++;
		}
		if ($d->{serial} ne $cur_serial) {
			$MessageDispCount2++;
		}
		$cur_serial = $d->{serial};
	}
	# メッセージログクローズ
	close(CFILE);

	return %logdata;
}

###################################################################
#
#	メッセージログファイルのヘッダ部分のみ読込
#
###################################################################
sub GetLogHead
{
	my ($target_serial) = @_;
	my @loghead;
	my $serial;
	my $resnumber;
	my $delkey;
	my $deleted;
	my @dummy;

	# メッセージログが存在しないときはすぐぬけよう
	unless (-e "$LogDataFilePath") { return; }

	# メッセージログオープン
	open(CFILE, "$LogDataFilePath") ||
		&FatalError("Fatal!!! $LogDataFilePath Open Error", $LockFilePath);

	$MessageDispCount1 = 0;
	$MessageDispCount2 = 0;
	$TargetSerial_MaxResNumber = 0 if ($target_serial ne '');

	# メッセージログの読込
	while (my $line = <CFILE>) {

		# 改行コード削除
		chomp $line;

		# 読込行をキーと値に分割
		(
			$serial,			# シリアル番号
			$resnumber,			# レス通し番号
			$delkey,			# 削除キー
			$deleted,			# 削除フラグ
			@dummy,				# 値（ダミー）
		) = split(/\t/, $line);

		# 引数で $target_serial が指定されていればこのシリアルに対する
		# レス番号の最大値を $TargetSerial_MaxResNumber にセットする。
		# この $TargetSerial_MaxResNumber は返信の時のレス番号設定で参照する。
		if ($target_serial ne '' && $target_serial eq $serial) {
			$TargetSerial_MaxResNumber = $resnumber
					if ($TargetSerial_MaxResNumber < $resnumber);
		}

		# 通常のハッシュキー（ログヘッダ）を作成
		my $key = "$serial:$resnumber";

		# ログヘッダデータを格納する。
		push(@loghead, $key);

		# メッセージ表示ログカウント
		unless ($deleted)   { $MessageDispCount1++; }
		unless ($resnumber) { $MessageDispCount2++; }
	}
	# メッセージログクローズ
	close(CFILE);

	return @loghead;
}

###################################################################
#
#	指定されたログデータ一件取得
#
###################################################################
sub GetLog
{
	my ($p) = @_;
	my $c = {};

	if ($p->{serial} eq '' || $p->{resnumber} eq '') {
		push(@ErrorMessage, '入力パラメータに異常があります');
		return;
	}

	# メッセージログが存在しないときはすぐぬけよう
	unless (-e "$LogDataFilePath") { return; }

	# メッセージログオープン
	open(CFILE, "$LogDataFilePath") ||
		&FatalError("Fatal!!! $LogDataFilePath Open Error", $LockFilePath);

	# メッセージログの読込
	while (my $line = <CFILE>) {

		# 改行コード削除
		chomp $line;

		# 読込行をキーと値に分割
		my $d = {};
		(
			$d->{serial},		# シリアル番号
			$d->{resnumber},	# レス通し番号
			$d->{delkey},		# 削除キー
			$d->{deleted},		# 削除フラグ
			$d->{date},			# 日付
			$d->{time},			# 時間
			$d->{ip},			# IP
			$d->{host},			# Hostname
			$d->{subject},		# 表題
			$d->{name},			# 投稿者名
			$d->{sex},			# 性別
			$d->{email},		# Email
			$d->{hpname},		# HP名
			$d->{url},			# HP-URL
			$d->{fgcol},		# メッセージ文字色番号
			$d->{icon},			# アイコン番号
			$d->{body},			# メッセージ
		) = split(/\t/, $line);

		# 目的のデータかどうか比較
		if ($d->{serial} == $p->{serial} && $d->{resnumber} == $p->{resnumber}) {
			$c = $d;
			last;
		}
	}
	# メッセージログクローズ
	close(CFILE);

	if ($c eq '') {
		push(@ErrorMessage, '指定されたログデータはありません');
		return;
	}
	return $c;
}

###################################################################
#
#	投稿データのチェック
#
###################################################################
sub CheckData
{
	my ($p) = @_;

	unless ($p->{name}) {
		push(@ErrorMessage, '名前は必ず入力してください。');
	}
	unless ($p->{subject}) {
		push(@ErrorMessage, 'タイトルは必ず入力してください。');
	}
	unless ($p->{body}) {
		push(@ErrorMessage, 'メッセージに何か書き込んでください。');
	}
	if (length($p->{body}) > 512) {
		push(@ErrorMessage, '512 バイト（全角 256 文字）を超える書き込みはできません。');
		push(@ErrorMessage, 'どうしてもとおっしゃるなら、すいませんが、2回に分けてお願いします。');
	}
	if ($p->{delkey} ne '') {
		if ($p->{delkey} !~ /^[\w\d]+$/) {
			push(@ErrorMessage, '削除キーは半角英数字で入力してください。');
		}
	}
	unless ($p->{email} =~ /^[\w\.\-]+@[\w\.\-]+$/) {
		$p->{email} = '';
	}
	unless ($p->{url} =~ /^https?:\/\/[\w\.\/\?\-=&#~\%\+]+$/) {
		$p->{url} = '';
	}

	return (@ErrorMessage == 0);
}

###################################################################
#
#	投稿データの新規保存
#
###################################################################
sub InsertData
{
	my ($p) = @_;

	# メッセージログヘッダ読込
	my @loghead = &GetLogHead($p->{serial});

	# ------------------------------------
	# メッセージログ情報セット
	# ------------------------------------
	# 返信の場合
	if ($p->{serial} ne '') {

		# レス通し番号設定
		if ($TargetSerial_MaxResNumber eq '') {
			push(@ErrorMessage, '返信する元データがありません');
			return;
		}
		$p->{resnumber} = $TargetSerial_MaxResNumber + 1;
	}
	# 新規投稿の場合
	else {
		# カウンターデータ取得
		my $cur_serial = &GetLogCounter();

		# シリアル番号設定
		$p->{serial} = $cur_serial + 1;

		# レス通し番号設定
		$p->{resnumber} = 0;

		# カウンターデータ更新
		&SetLogCounter($p->{serial});
	}

	# 削除フラグ設定
	$p->{deleted} = 0;

	# 日付設定
	my ($Sec, $Min, $Hour, $Day, $Mon, $Year) = localtime(time());
	my $Date = sprintf("%04d-%02d-%02d", 1900 + $Year, $Mon + 1, $Day);
	my $Time = sprintf("%02d:%02d:%02d", $Hour, $Min, $Sec);
	$p->{date} = $Date;
	$p->{time} = $Time;

	# クライアント IP Address 設定
	my $ip = $ENV{'REMOTE_ADDR'};
	$p->{ip} = $ip;

	# クライアント Host Name 設定
	my $host = gethostbyaddr(pack("C4", split(/\./, $ip)), 2);
	$p->{host} = $host;

	# メッセージ本文の改行は <br> に変更
	$p->{body} =~ s/\n/<br>/g;

	# ------------------------------------
	# メッセージログへ書込み
	# ------------------------------------
	my $total = (@loghead);

	# ログ蓄積数が指定数に満たない場合
	# （通常はこちらで運用すべき！）
	if ($total < $MaxLogCount) {

		# メッセージログオープン
		open(CFILE, ">> $LogDataFilePath") ||
					&FatalError("Fatal!!! $LogDataFilePath Open Error");

		# 投稿データをログへ保存
		print CFILE
				"$p->{serial}\t"	,	# シリアル番号
				"$p->{resnumber}\t"	,	# レス通し番号
				"$p->{delkey}\t"	,	# 削除キー
				"$p->{deleted}\t"	,	# 削除フラグ
				"$p->{date}\t"		,	# 日付
				"$p->{time}\t"		,	# 時間
				"$p->{ip}\t"		,	# IP
				"$p->{host}\t"		,	# Hostname
				"$p->{subject}\t"	,	# 表題
				"$p->{name}\t"		,	# 投稿者名
				"$p->{sex}\t"		,	# 性別
				"$p->{email}\t"		,	# Email
				"$p->{hpname}\t"	,	# HP名
				"$p->{url}\t"		,	# HP-URL
				"$p->{fgcol}\t"		,	# メッセージ文字色番号
				"$p->{icon}\t"		,	# アイコン番号
				"$p->{body}\n"		;	# メッセージ

		# メッセージログクローズ
		close(CFILE);
	}

	# ログ蓄積数が指定数に達した場合
	# （そのうち、こちらは警告メールだそう！）
	else {
		# メッセージログの読込
		my %logdata = &GetLogData();

		# ログ蓄積数
		my $counter = 0;

		# メッセージ更新用テンポラリーファイルオープン
		open(CFILE, "> $TmpFilePath") ||
			&FatalError("Fatal!!! $TmpFilePath Open Error", $LockFilePath);

		# 投稿データをログへ保存
		print CFILE
				"$p->{serial}\t"	,	# シリアル番号
				"$p->{resnumber}\t"	,	# レス通し番号
				"$p->{delkey}\t"	,	# 削除キー
				"$p->{deleted}\t"	,	# 削除フラグ
				"$p->{date}\t"		,	# 日付
				"$p->{time}\t"		,	# 時間
				"$p->{ip}\t"		,	# IP
				"$p->{host}\t"		,	# Hostname
				"$p->{subject}\t"	,	# 表題
				"$p->{name}\t"		,	# 投稿者名
				"$p->{sex}\t"		,	# 性別
				"$p->{email}\t"		,	# Email
				"$p->{hpname}\t"	,	# HP名
				"$p->{url}\t"		,	# HP-URL
				"$p->{fgcol}\t"		,	# メッセージ文字色番号
				"$p->{icon}\t"		,	# アイコン番号
				"$p->{body}\n"		;	# メッセージ

		# 蓄積数カウントし指定数を超えないようにする。
		$counter++;

		# 更新データを含む投稿データを更新用テンポラリーファイルに保存
		foreach my $key (sort LogKeyCmpare keys %logdata) {

			my $o = $logdata{$key};
			print CFILE
					"$o->{serial}\t"	,	# シリアル番号
					"$o->{resnumber}\t"	,	# レス通し番号
					"$o->{delkey}\t"	,	# 削除キー
					"$o->{deleted}\t"	,	# 削除フラグ
					"$o->{date}\t"		,	# 日付
					"$o->{time}\t"		,	# 時間
					"$o->{ip}\t"		,	# IP
					"$o->{host}\t"		,	# Hostname
					"$o->{subject}\t"	,	# 表題
					"$o->{name}\t"		,	# 投稿者名
					"$o->{sex}\t"		,	# 性別
					"$o->{email}\t"		,	# Email
					"$o->{hpname}\t"	,	# HP名
					"$o->{url}\t"		,	# HP-URL
					"$o->{fgcol}\t"		,	# メッセージ文字色番号
					"$o->{icon}\t"		,	# アイコン番号
					"$o->{body}\n"		;	# メッセージ

			# 蓄積数カウントし指定数を超えないようにする。
			$counter++;
			if ($counter >= $MaxLogCount) { last; }
		}

		# 更新用テンポラリーファイルクローズ
		close(CFILE);

		# 更新用テンポラリーファイルをメッセージログファイル
		# としてリネームする。
		unlink($LogDataFilePath);
		rename($TmpFilePath, $LogDataFilePath) ||
			&FatalError("Fatal!!! $LogDataFilePath Has been Lost!!", $LockFilePath);
	}
	return 1;
}

###################################################################
#
#	投稿データの更新
#
###################################################################
sub UpdateData
{
	my ($p) = @_;
	my $serial    = $p->{serial};
	my $resnumber = $p->{resnumber};
	my $find;

	# メッセージログの読込
	my %logdata = &GetLogData();

	# メッセージ更新用テンポラリーファイルオープン
	open(CFILE, "> $TmpFilePath") ||
				&FatalError("Fatal!!! $TmpFilePath Open Error", $LockFilePath);

	foreach my $key (sort LogKeyCmpare keys %logdata) {
		my $o = $logdata{$key};

		# 更新データかどうか検査
		if ($o->{serial} == $serial && $o->{resnumber} == $resnumber) {

			# メッセージ本文の改行は <br> に変更
			$p->{body} =~ s/\n/<br>/g;

			# 更新データの場合はパラメータの値で更新する
			$o->{delkey}  = $p->{delkey};
			$o->{subject} = $p->{subject};
			$o->{name}	  = $p->{name};
			$o->{sex}	  = $p->{sex};
			$o->{email}   = $p->{email};
			$o->{hpname}  =	$p->{hpname};
			$o->{url}	  =	$p->{url};
			$o->{fgcol}	  =	$p->{fgcol};
			$o->{icon}	  =	$p->{icon};
			$o->{body}    = $p->{body};
			$find = 1;
		}
		# 更新データを含む投稿データを更新用テンポラリーファイルに保存
		print CFILE
				"$o->{serial}\t"	,	# シリアル番号
				"$o->{resnumber}\t"	,	# レス通し番号
				"$o->{delkey}\t"	,	# 削除キー
				"$o->{deleted}\t"	,	# 削除フラグ
				"$o->{date}\t"		,	# 日付
				"$o->{time}\t"		,	# 時間
				"$o->{ip}\t"		,	# IP
				"$o->{host}\t"		,	# Hostname
				"$o->{subject}\t"	,	# 表題
				"$o->{name}\t"		,	# 投稿者名
				"$o->{sex}\t"		,	# 性別
				"$o->{email}\t"		,	# Email
				"$o->{hpname}\t"	,	# HP名
				"$o->{url}\t"		,	# HP-URL
				"$o->{fgcol}\t"		,	# メッセージ文字色番号
				"$o->{icon}\t"		,	# アイコン番号
				"$o->{body}\n"		;	# メッセージ
	}
	# 更新用テンポラリーファイルクローズ
	close(CFILE);

	# 更新対象データが無かった場合
	if ($find eq '') {
		# 更新用テンポラリーファイル削除
		unlink($TmpFilePath);
		push(@ErrorMessage, '指定されたログデータはありません');
		return;

	# ログ編集データで更新した場合
	} else {
		# 更新用テンポラリーファイルをメッセージログファイル
		# としてリネームする。
		unlink($LogDataFilePath);
		rename($TmpFilePath, $LogDataFilePath) ||
			&FatalError("Fatal!!! $LogDataFilePath Has been Lost!!", $LockFilePath);
	}

	return 1;
}

###################################################################
#
#	指定された投稿データ１件を削除する
#
###################################################################
sub DeleteData
{
	my ($p) = @_;
	my $serial    = $p->{serial};
	my $resnumber = $p->{resnumber};
	my $find;

	# メッセージログの読込
	my %logdata = &GetLogData();

	# メッセージログ更新用テンポラリーファイルオープン
	open(CFILE, "> $TmpFilePath") ||
		&FatalError("Fatal!!! $TmpFilePath Open Error", $LockFilePath);

	# 削除データを除いた投稿データを更新用テンポラリーファイルに保存
	foreach my $key (sort LogKeyCmpare keys %logdata) {
		my $o = $logdata{$key};

		# 削除データかどうか検査
		if ($o->{serial} == $serial && $o->{resnumber} == $resnumber) {

			# 削除データ発見フラグセット
			$find = 1;

			# 削除データなので保存処理スキップ
			next;
		}
		print CFILE
				"$o->{serial}\t"	,	# シリアル番号
				"$o->{resnumber}\t"	,	# レス通し番号
				"$o->{delkey}\t"	,	# 削除キー
				"$o->{deleted}\t"	,	# 削除フラグ
				"$o->{date}\t"		,	# 日付
				"$o->{time}\t"		,	# 時間
				"$o->{ip}\t"		,	# IP
				"$o->{host}\t"		,	# Hostname
				"$o->{subject}\t"	,	# 表題
				"$o->{name}\t"		,	# 投稿者名
				"$o->{sex}\t"		,	# 性別
				"$o->{email}\t"		,	# Email
				"$o->{hpname}\t"	,	# HP名
				"$o->{url}\t"		,	# HP-URL
				"$o->{fgcol}\t"		,	# メッセージ文字色番号
				"$o->{icon}\t"		,	# アイコン番号
				"$o->{body}\n"		;	# メッセージ
	}
	# 更新用テンポラリーファイルクローズ
	close(CFILE);

	# 削除対象データが無かった場合
	if ($find eq '') {
		# 更新用テンポラリーファイル削除
		unlink($TmpFilePath);
		push(@ErrorMessage, '指定されたログデータはありません');
		return;

	# 削除対象データを削除した場合
	} else {
		# 更新用テンポラリーファイルをメッセージログファイル
		# としてリネームする。
		unlink($LogDataFilePath);
		rename($TmpFilePath, $LogDataFilePath) ||
			&FatalError("Fatal!!! $LogDataFilePath Has been Lost!!", $LockFilePath);
	}

	return 1;
}

###################################################################
#
#	投稿データを全て削除する
#
###################################################################
sub AllClearData
{
	# メッセージログファイル削除
	unlink($LogDataFilePath);
}

###################################################################
#
#	投稿データ非表示化（削除フラグを立てるだけ）チェック
#
###################################################################
sub CheckUndispData
{
	my ($p) = @_;

	if ($p->{serial} eq '') {
		push(@ErrorMessage, 'メッセージログNoが設定されていません。');
	}
	if ($p->{resnumber} eq '') {
		push(@ErrorMessage, 'メッセージログNoが設定されていません。');
	}
	if ($p->{delkey} eq '') {
		push(@ErrorMessage, '削除キーが設定されていません。');
	}
	return (@ErrorMessage == 0);
}

###################################################################
#
#	投稿データを非表示化（削除フラグを立てるだけ）する
#
###################################################################
sub UndispData
{
	my ($p) = @_;
	my $serial    = $p->{serial};
	my $resnumber = $p->{resnumber};
	my $delkey    = $p->{delkey};
	my $find;

	# メッセージログの読込
	my %logdata = &GetLogData();

	# メッセージログ更新用テンポラリーファイルオープン
	open(CFILE, "> $TmpFilePath") ||
			&FatalError("Fatal!!! $TmpFilePath Open Error", $LockFilePath);

	# 非表示フラグを立てて投稿データを更新用テンポラリーファイルに保存
	foreach my $key (sort LogKeyCmpare keys %logdata) {
		my $o = $logdata{$key};

		# 非表示データかどうか検査
		if ($o->{serial} == $serial && $o->{resnumber} == $resnumber) {
			if ($o->{delkey} ne '' && $o->{delkey} eq $delkey) {
				# ログNoと削除キー一致
				# 非表示フラグをONにする。
				$o->{deleted} = 1;

				# 非表示データ発見フラグセット
				$find = 1;
			}
		}
		print CFILE
				"$o->{serial}\t"	,	# シリアル番号
				"$o->{resnumber}\t"	,	# レス通し番号
				"$o->{delkey}\t"	,	# 削除キー
				"$o->{deleted}\t"	,	# 削除フラグ
				"$o->{date}\t"		,	# 日付
				"$o->{time}\t"		,	# 時間
				"$o->{ip}\t"		,	# IP
				"$o->{host}\t"		,	# Hostname
				"$o->{subject}\t"	,	# 表題
				"$o->{name}\t"		,	# 投稿者名
				"$o->{sex}\t"		,	# 性別
				"$o->{email}\t"		,	# Email
				"$o->{hpname}\t"	,	# HP名
				"$o->{url}\t"		,	# HP-URL
				"$o->{fgcol}\t"		,	# メッセージ文字色番号
				"$o->{icon}\t"		,	# アイコン番号
				"$o->{body}\n"		;	# メッセージ
	}
	# 更新用テンポラリーファイルクローズ
	close(CFILE);

	# 非表示対象データが無かった場合
	if ($find eq '') {
		# 更新用テンポラリーファイル削除
		unlink($TmpFilePath);
		push(@ErrorMessage, 'Noと削除キーに一致するメッセージはありません。');
		return;
	}
	# 非表示対象データに削除マークをつけた場合
	else {
		# 更新用テンポラリーファイルをメッセージログファイル
		# としてリネームする。
		unlink($LogDataFilePath);
		rename($TmpFilePath, $LogDataFilePath) ||
			&FatalError("Fatal!!! $LogDataFilePath Has been Lost!!", $LockFilePath);
	}

	return 1;
}

###################################################################
#
#	ロック処理
#
###################################################################
sub LockBoardFile
{
	# リトライ回数上限のチェック
	my $retry_max = 8;
	my $retry = 0;

	# カウンターファイルロック解除待ち
	while (-e "$LockFilePath") {
		$retry++;

		# リトライ回数上限のチェック
		&FatalError('Fatal!!! Buzy Cannot Lock', $LockFilePath)
										if ($retry > $retry_max);
		sleep(1);
	}
	# カウンターファイルロック処理
	open(LOCK, "> $LockFilePath") ||
		&FatalError('Fatal!!! $LockFilePath Open Error', $LockFilePath);
	print LOCK "Locking\n";
	close(LOCK);
}

###################################################################
#
#	アンロック処理
#
###################################################################
sub UnlockBoardFile
{
	if (-e "$LockFilePath") {
		unlink("$LockFilePath") ||
			&FatalError('Fatal!!! Can not delete LockFile', $LockFilePath);
	}
}

###################################################################
#
#	ログハッシュテーブルのソート用比較関数
#
###################################################################
sub LogKeyCmpare
{
	my ($sa, $ra) = split(/:/, $a);
	my ($sb, $rb) = split(/:/, $b);
	$sb <=> $sa or $ra <=> $rb;
}

###################################################################
#
#	ログハッシュテーブルのソート用比較関数その２
#
###################################################################
sub LogKeyCmpare2
{
	my ($sa, $ra) = split(/:/, $a);
	my ($sb, $rb) = split(/:/, $b);
	$sb <=> $sa or $rb <=> $ra;	# この行だけLogKeyCmpareと違う！
}

###################################################################
#
#	GET METHOD へリダイレクト
#
###################################################################
sub RedirectGetMethod
{
	my ($url, $my_cookie) = @_;
	my $location = &SetRedirectHeader($url);
	print "$location\n";

	if ($my_cookie) {
		my $cookie = &SetCookie($MyCookieName, $my_cookie, 60);
		print "$cookie\n";
	}

	print "\n";
}

###################################################################
#
#	終了処理
#
###################################################################
sub ZguestExit
{
	# アンロック処理
	unlink("$LockFilePath") if (-e "$LockFilePath");
	exit;
}

###################################################################
1
