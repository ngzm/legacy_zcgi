#!/usr/bin/perl --
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
# =================================================================
#
#	人口無能エンジン『ハムっこ！』を利用したおしゃべりCGI
#
# =================================================================
#   更新履歴：
#   Date.       Ver.    Note.
#	2002/09/14	0.01	アルファ版リリース
#	2002/09/18	0.10	ベータ１版リリース
#	2002/09/23	1.00	V1.00版リリース
#   2002.09.28  1.01    HTTPヘッダにキャッシュしない指示を追加
#   2003.02.11  1.03    改行コードによる起動不具合の修正（!/usr/bin/perl -- ）
# =================================================================

###################################################################
#
#	Use Library
#
###################################################################
require "hamkko.pl";		# 「ハムっこ」人口無能エンジン
use		zcgi;
use 	strict;

# シグナルハンドリング
# ロックファイルを確実に消す!
$SIG{'PIPE'} = "SigHandleExit";
$SIG{'INT'}  = "SigHandleExit";
$SIG{'HUP'}  = "SigHandleExit";
$SIG{'QUIT'} = "SigHandleExit";
$SIG{'TERM'} = "SigHandleExit";

# アクセスログファイル
my $LogFilePath  = "log/hamkko.log";

# ロックファイル
my $LockFilePath = "log/hamkko.lck";

##@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
##@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
##
## ここから、、各自の環境に合わせて設定してください。
##

# ---------------------------------------------------------
# あなたのホームを表すURLを指定してね
# ---------------------------------------------------------
my $HOME		= '/';

# ---------------------------------------------------------
# 『ハムっこ』の名前を「$HAMNAME」に付けてね。
# ---------------------------------------------------------
my $HAMNAME		= 'ハムっこ';

# ---------------------------------------------------------
# 見出しに表示する文字を指定してね
# ---------------------------------------------------------
my $MIDASHI		= 'ハムっこ～★とおはなししよ～';

# ---------------------------------------------------------
# ごきげんレベルを表す文字を指定してね！
# ---------------------------------------------------------
my $HAMLEVEL1	= '天使ハム～「ちょ～ハッピ～」';			# レベル80以上の時（機嫌最高）
my $HAMLEVEL2	= 'コックハム～「プチしあわせ～」';			# レベル60～79の時（機嫌良い）
my $HAMLEVEL3	= 'キキハム～「機嫌ふつう」';				# レベル40～59の時（機嫌普通）
my $HAMLEVEL4	= 'おにハム～「ちょいおこってま～す」';		# レベル20～39の時（機嫌悪い）
my $HAMLEVEL5	= 'おこりハム～「機嫌悪～」';				# レベル19以下の時（機嫌最悪）

# ---------------------------------------------------------
# ごきげんレベルに従ったアイコンファイル名を指定してね！
# ---------------------------------------------------------
my $HAMICON1	= 'tensi_ham.gif';							# レベル80以上の時（機嫌最高）
my $HAMICON2	= 'cook_ham.gif';							# レベル60～79の時（機嫌良い）
my $HAMICON3	= 'kiki_ham.gif';							# レベル40～59の時（機嫌普通）
my $HAMICON4	= 'oni_ham.gif';							# レベル20～39の時（機嫌悪い）
my $HAMICON5	= 'okori_ham.gif';							# レベル19以下の時（機嫌最悪）


##
##	各自の環境設定はここで終わり。
##	以降のソースコードは触ってもよし、触らなくてもよし、、
##
##@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
##@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

# 吹き出し部分を構成する画像
my $MESIMG0 = 'img/kome.gif';
my $MESIMG1 = 'img/edge1.gif';
my $MESIMG2 = 'img/edge2.gif';
my $MESIMG3 = 'img/edge3.gif';
my $MESIMG4 = 'img/edge4.gif';
my $R_METER = 'img/rmeter.gif';
my $B_METER = 'img/bmeter.gif';

# サーバー日本語文字コード取得
my $SAVER_ENC = &GetSaverEncode();

# HTML文字変換！
$HAMNAME = &Cdata($HAMNAME);
$MIDASHI = &Cdata($MIDASHI);

###################################################################
#	Start Running Script
###################################################################

# パラメータ取得
my $p = &GetParam();

# 処理切り替え
if ($p->{usname} eq '' && $p->{usin} eq '') {

	# HTML ヘッダ出力
	&print_header(0);

	# ユーザ名称入力フォーム表示
	&print_getname();

	# HTMLフッター出力
	&print_footer();

} elsif ($p->{usname} ne '' and $p->{usin} eq '') {

	# アクセスログにアクセス状況追加
	&add_accesslog($p);

	# HTML ヘッダ出力
	&print_header(1);

	# ユーザ名称入力直後画面
	my $dsp;
	$dsp->{usname} = $p->{usname};
	$dsp->{mode}   = $hamkko::MUNOU;
	$dsp->{level}  = 50;
	$dsp->{out}    = "ようこそ～ $p->{usname} さん！\n何か話しかけてみてね～";
	&print_responce($dsp);

	# HTMLフッター出力
	&print_footer();

} else {

	# HTML ヘッダ出力
	&print_header(1);

	# 人口無能とおしゃべりモード
	my ($resp, $dsp);
	eval {
		# ハムっこで対話
		my $arg;
		$arg->{myname} = $HAMNAME;
		$arg->{usname} = $p->{usname};
		$arg->{in}     = $p->{usin};
		$arg->{mode}   = $p->{mode};
		$arg->{level}  = $p->{level};
		$arg->{out}    = $p->{out};
		$resp = &hamkko::ham_main($arg);
	};
	if ($@) {
		$resp->{out} = "人口無能エンジン「ハムっこ！」内部エラー： $@\n";
	}
	$dsp->{usname} = $p->{usname};
	$dsp->{mode}   = $resp->{mode};
	$dsp->{level}  = $resp->{level};
	$dsp->{out}    = $resp->{out};
	&print_responce($dsp);

	# HTMLフッター出力
	&print_footer();
}

# 正常終了
exit;


###################################################################
#	HTMLヘッダ出力
###################################################################
sub print_header
{
	my ($m) = @_;
	my $onload;

	# キーフォーカスを入れるJavaScriptタグ
	if ($m) {
		$onload = 'document.kform.usin.focus()';
	} else {
		$onload = 'document.kform.usname.focus()';
	}

	# HTTP ヘッダ出力
	{
print << "HEADER"
Pragma: no-cache
Cache-Control: no-cache
Content-type: text/html; charset=$SAVER_ENC

<html>
<head>
<title>$HAMNAME</title>
<style type="text/css">
<!--
	body {
		color : #FFFFFF ;
		background-color : #115588 ;
		margin-left  : 5% ;
		margin-right : 5% ;
	}
	h1 {
		color : #FFFFFF ;
		background-color : #80A0DD ;
		text-align : center ;
		padding : 4px ;
	}
	h2 {
		color : #FFCC99 ;
		text-decoration : underline ;
	}
	table {
		color : #000000 ;
	}
	form {
		color : #000000 ;
		background-color : #D8D8D8 ;
		text-align : center ;
		padding : 16px ;
	}
	div.res {
		color : #000000 ;
		background-color : #D8D8D8 ;
		text-align : center ;
		padding : 18px ;
	}
	div.caution {
		color : #FFFFFF ;
		background-color : #80A0DD ;
		padding-top     : 1ex ;
		padding-bottom  : 1em ;
		padding-left    : 2em ;
		padding-right   : 2em ;
		font-weight : bold ;
	}
	address {
		color : #FFFFFF ;
		text-align : right ;
	}
	a.address {
		color : #FF77FF ;
	}

--->
</style>
</head>
<body onLoad="$onload">

<address>
	[ <a class="address" href="$HOME">HOME</a> ]
</address>

<h1>$MIDASHI</h1>
HEADER
	}
}

###################################################################
#	HTMLフッター出力
###################################################################
sub print_footer
{
	# HTTP フッタ出力
	{
print <<"FOOTER"
<div class="caution">
	<h2>■ あそびかた ■</h2>
	<ul>
	<li>「$HAMNAME」と楽しく！？会話してあそびます。
	<li>「$HAMNAME」は、皆さんの言葉に反応して何か返事をしてくれます。
	<li>会話の内容によって、「$HAMNAME」の機嫌が良くなったり、悪くなったりします。
	<li>例えば、「すごい」「すてき」「かわいい」などの言葉でほめると機嫌がよくなります。
	<li>逆に、「ばか」「アホ」「コラ！」「ダメ」などの言葉を浴びせると機嫌が悪くなります。
	<li>現在の機嫌は、「ごきげんメータ」に表示されます。
	<li>機嫌によって、次の状態に変化します。
		<ul>
		<li>$HAMLEVEL1
		<li>$HAMLEVEL2
		<li>$HAMLEVEL3
		<li>$HAMLEVEL4
		<li>$HAMLEVEL5
		</ul>
	<li>その他にも、突然機嫌が変わってしまうことがありますので、気をつけて下さい。
	</ul>
	<h2>■ ちゅうい ■</h2>
	<ul>
	<li>たまに、会話が飛びます！
	<li>たまに、暴言も吐きます、、かんべんして～
	</ul>
</div>
<p>
<address>
	$hamkko::CurrentVer CGI Script &copy; 2002-
	<a class="address" href="http://zumin.cside9.com/zumin/" target="zumin">ZUMIN</a>
</address>
</body>
</html>
FOOTER
	}
}

###################################################################
#	名称入力フォーム出力
###################################################################
sub print_getname
{
	# 名称入力フォーム出力
	{
print <<"HTML1"

<form name="kform" method="POST" action="zham.cgi">
	あなたの「おなまえ」を入力してね
	<p>
	<input type="text" name="usname" size=30>
	<input type="submit" value="そうしん">
	<input type="reset" value="とりけし">
</form>

<p>
HTML1
	}
}

###################################################################
#	返答結果出力＆ユーザ入力フォーム出力
###################################################################
sub print_responce
{
	my ($dsp) = @_;
	my ($out, $uname, $mode, $level);
	my ($rlev, $blev, $col, $icon, $ex);

	$mode  = $dsp->{mode};
	$level = $dsp->{level};

	# レベルによる変換
	if ($level < 20) {
		$col  = "#FF0000";
		$icon = "img/$HAMICON5";
		$ex   = "$HAMLEVEL5";
	}
	elsif ($level < 40) {
		$col  = "#AA0044";
		$icon = "img/$HAMICON4";
		$ex   = "$HAMLEVEL4";
	}
	elsif ($level < 60) {
		$col  = "#880088";
		$icon = "img/$HAMICON3";
		$ex   = "$HAMLEVEL3";
	}
	elsif ($level < 80) {
		$col  = "#4400AA";
		$icon = "img/$HAMICON2";
		$ex   = "$HAMLEVEL2";
	}
	else {
		$col  = "#0000FF";
		$icon = "img/$HAMICON1";
		$ex   = "$HAMLEVEL1";
	}
	$blev = $dsp->{level};
	$blev = 99 if ($blev > 99);
	$blev = 1  if ($blev < 1);
	$rlev = 100 - $blev;

	# HTML文字変換！
	$out   = &Cdata($dsp->{out});
	$ex    = &Cdata($ex);
	$uname = &Cdata($dsp->{usname});

	# さらに本文の改行を<br>に、URLをアンカーに変換
	$out   =~ s/\n/<br>/g;
	$out   = &SetHtmlAnker($out);

	# 出力
	{
print <<"HTML2"

<div class="res">
	<table border=0 cellpadding="0" cellspacing="0">
	<tr valign="bottom">
		<td rowspan="3" valign="middle" height="200"><img src="$icon" height="200"></td>
		<td rowspan="3" align="right" valign="middle" width="40"><img src="$MESIMG0"></td>
		<td><img src="$MESIMG1"></td>
		<td bgcolor="#FFFFFF"><br></td>
		<td><img src="$MESIMG2"></td>
	</tr>
	<tr>
		<td bgcolor="#FFFFFF"><br></td>
		<td bgcolor="#FFFFFF" align="left" valign="middle" width="280" height="170">
			<font color="$col">$out</font>
		</td>
		<td bgcolor="#FFFFFF"><br></td>
	</tr>
	<tr valign="top">
		<td><img src="$MESIMG4"></td>
		<td bgcolor="#FFFFFF"><br></td>
		<td><img src="$MESIMG3"></td>
	</tr>
	</table>
	<p>
	<table border=0 cellpadding="0" cellspacing="4">
	<tr>
		<td align="center">★★ごきげんメーター ★★</td>
	</tr>
	<tr>
		<td width="400">
			<img src="$B_METER" width="$blev%" height="16"><img src="$R_METER" width="$rlev%" height="16">
		</td>
	</tr>
	<tr>
	<td align="center">（$ex）</td>
	</tr>
	</table>
</div>

<form name="kform" method="POST" action="zham.cgi">
	<input type="hidden" name="usname" value="$uname">
	<input type="hidden" name="mode"   value="$mode">
	<input type="hidden" name="level"  value="$level">
	<input type="hidden" name="out"    value="$out">
	ここからはなしかけてね！
	<br>
	<input type="text" name="usin" size=60>
	<input type="submit" value="そうしん">
	<input type="reset"  value="とりけし">
</form>

<p>
HTML2
	}
}

###################################################################
#
#	アクセスログデータ追加
#
###################################################################
sub add_accesslog
{
	my ($p) = @_;

	# 入力された名前
	my $name = $p->{usname};

	# クライアントホストIP取得
	my $ip = $ENV{'REMOTE_ADDR'};

	# クライアントホスト名取得
	my $host = gethostbyaddr(pack("C4", split(/\./, $ip)), 2);

	# クライアントUSER-AGENT
	my $agent = $ENV{'HTTP_USER_AGENT'};

	# 現在日付
	# 現在時刻
	my ($Sec, $Min, $Hour, $Day, $Mon, $Year) = localtime(time());
	my $date = sprintf("%04d-%02d-%02d", 1900 + $Year, $Mon + 1, $Day);
	my $time = sprintf("%02d:%02d:%02d", $Hour, $Min, $Sec);

	# ログファイルロック！
	&lock_log();

	# ログファイルにアクセスログ追加
	open(LOG, ">> $LogFilePath") || die "Fatal!!! Cannot open $LogFilePath";
	print LOG
				"$date\t"     ,
				"$time\t"     ,
				"$ip\t"       ,
				"$host\t"     ,
				"$agent\t"    ,
				"non-refer\t" ,
				"$name\n"     ;
	close(LOG);

	# ログファイルアンロック！
	&unlock_log();
}

###################################################################
#
#	ロック処理
#
###################################################################
sub lock_log
{
	# リトライ回数上限のチェック
	my $retry_max = 8;
	my $retry     = 0;

	# カウンターファイルロック解除待ち
	while (-e "$LockFilePath") {
		$retry++;

		# リトライ回数上限のチェック
		if ($retry > $retry_max) {
			die "Fatal!!! Buzy Cannot Lock $LockFilePath";
		}
		sleep(1);
	}
	# カウンターファイルロック処理
	open(LOCK, "> $LockFilePath") || die "Fatal!!! $LockFilePath Open Error $LockFilePath";
	print LOCK "Locking\n";
	close(LOCK);
}

###################################################################
#
#	アンロック処理
#
###################################################################
sub unlock_log
{
	if (-e "$LockFilePath") {
		unlink("$LockFilePath") || die "Fatal!!! Can not delete LockFile $LockFilePath";
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
