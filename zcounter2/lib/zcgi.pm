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
#   zcgi.pm
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
#   2001.04.25  0.0.2   Cookie 追加
#   2001.04.26  0.0.3   暗号処理（ダミー）追加
#   2001.04.28  0.0.4   リダイレクト処理追加
#   2001.05.01  0.0.5   URL文字をアンカーに変更する処理追加
#   2001.05.28  0.0.6   暗号処理（簡易版）追加
#   2001.06.15  0.0.7   クッキー有効期限を指定可能にする。
# =================================================================


###################################################################
#
#	Use Library
#
###################################################################
require "jcode.pl";


###################################################################
#
#	Define Globals 固定値
#
###################################################################

# 日本語文字コードタイプ定義。下記以外のタイプ(IATA Alias名など）
# は使用しないようにしているので注意されたい。
$EUC       = 'EUC-JP';
$JIS       = 'iso-2022-jp';
$SJIS      = 'Shift_JIS';
$SAVERCODE = 'SAVER-ENCODE';


###################################################################
#
#	CGI パラメータ取得
#
###################################################################
sub GetParam
{
	my ($query, @params, $param);
	my $p = {};

	# HTTP Method
	my $method = uc $ENV{'REQUEST_METHOD'};

	# パラメータ取得
	if ($method eq 'POST') {
		read(STDIN, $query, $ENV{'CONTENT_LENGTH'});
	} else {
		$query = $ENV{'QUERY_STRING'};
	}
	@params = split(/&/, $query);

	# パラメータをキーと値に分解
	foreach $param (@params) {
		my ($name, $value) = split(/=/, $param);

		# URL エンコードをデコード
		$value = &URLDecode($value);

		# 日本語コード変換・特殊文字対策
		$value = &ConvStr($value, $SAVERCODE);

		# 改行コードは\nに統一
		$value =~ s/\r\n/\n/g;
		$value =~ s/\n\r/\n/g;
		$value =~ s/\r/\n/g;

		# 最後の改行は削除
		chomp $value;

		# パラメータハッシュにセット
		$p->{$name} = $value;
	}

	return $p;
}

###################################################################
#
#	サーバファイルエンコード取得
#
###################################################################
sub GetSaverEncode
{
	$Static_enc;
	my @judge;

	# '漢字'をサンプルに１６進変換して調べてみる
	# '漢字'は、EUCでは、b4,c1,bb,fa である。。
	if ($Static_enc eq '') {

		@judge = unpack('C*', '漢字');

		if ($judge[0] == 0xb4) {
			$Static_enc = $EUC;
		} else {
			$Static_enc = $SJIS;
		}
	}
	return $Static_enc;
}

###################################################################
#
#	日本語コード変換・特殊文字対策
#
###################################################################
sub ConvStr
{
	my ($str, $enc) = @_;

	# 引数 $enc がサーバのファイルエンコードを
	# 自動判定するように期待するモードのときは
	# サーバーのファイルエンコード取得
	$enc = &GetSaverEncode() if ($enc eq $SAVERCODE);

	# EUCに変換
	if ($enc eq $EUC) {
		$str = &ConvStr2EUC($str);
	}
	# SJISに変換
	elsif ($enc eq $SJIS) {
		$str = &ConvStr2SJIS($str);
	}
	else {
		&FatalError("サーバの日本語コード不明");
	}
	return $str;
}

###################################################################
#
#	EUC への日本語コード変換・特殊文字対策
#
###################################################################
sub ConvStr2EUC
{
	# EUC 変換
	$str = &jcode::euc(@_);

	# 半角カナを全角カナに変換
	jcode::h2z_euc(*str);

	# ---------------------------------------------------
	# 機種依存文字を強制変換する。
	# MS拡張文字の内、使われがちな文字から順次対応したい。
	# ---------------------------------------------------

	# 丸数字
	&jcode::tr(*str, "\xad\xa1", "\xff");	$str =~ s/\xff/(1)/g;
	&jcode::tr(*str, "\xad\xa2", "\xff");	$str =~ s/\xff/(2)/g;
	&jcode::tr(*str, "\xad\xa3", "\xff");	$str =~ s/\xff/(3)/g;
	&jcode::tr(*str, "\xad\xa4", "\xff");	$str =~ s/\xff/(4)/g;
	&jcode::tr(*str, "\xad\xa5", "\xff");	$str =~ s/\xff/(5)/g;
	&jcode::tr(*str, "\xad\xa6", "\xff");	$str =~ s/\xff/(6)/g;
	&jcode::tr(*str, "\xad\xa7", "\xff");	$str =~ s/\xff/(7)/g;
	&jcode::tr(*str, "\xad\xa8", "\xff");	$str =~ s/\xff/(8)/g;
	&jcode::tr(*str, "\xad\xa9", "\xff");	$str =~ s/\xff/(9)/g;
	&jcode::tr(*str, "\xad\xaa", "\xff");	$str =~ s/\xff/(10)/g;
	&jcode::tr(*str, "\xad\xab", "\xff");	$str =~ s/\xff/(11)/g;
	&jcode::tr(*str, "\xad\xac", "\xff");	$str =~ s/\xff/(12)/g;
	&jcode::tr(*str, "\xad\xad", "\xff");	$str =~ s/\xff/(13)/g;
	&jcode::tr(*str, "\xad\xae", "\xff");	$str =~ s/\xff/(14)/g;
	&jcode::tr(*str, "\xad\xaf", "\xff");	$str =~ s/\xff/(15)/g;
	&jcode::tr(*str, "\xad\xb0", "\xff");	$str =~ s/\xff/(16)/g;
	&jcode::tr(*str, "\xad\xb1", "\xff");	$str =~ s/\xff/(17)/g;
	&jcode::tr(*str, "\xad\xb2", "\xff");	$str =~ s/\xff/(18)/g;
	&jcode::tr(*str, "\xad\xb3", "\xff");	$str =~ s/\xff/(19)/g;
	&jcode::tr(*str, "\xad\xb4", "\xff");	$str =~ s/\xff/(20)/g;

	return $str;
}

###################################################################
#
#	SJIS への日本語コード変換・特殊文字対策
#
###################################################################
sub ConvStr2SJIS
{
	# SJIS 変換
	$str = &jcode::sjis(@_);

	# 半角カナを全角カナに変換
	jcode::h2z_sjis(*str);

	return $str;
}

###################################################################
#
#	クッキー取得
#
###################################################################
sub GetCookie
{
	my ($cookie_name) = @_;
	my $my_cookie = {};
	my %cookies;

	# HTTP Cookie 全部取得
	my @carry = split(/\;/, $ENV{'HTTP_COOKIE'});

	foreach my $c (@carry) {
		my ($name, $value) = split(/\=/, $c);
		$name =~ s/ //g;
		$cookies{$name} = $value;
	}

	# 引数で指定された名前（Key）を持つ Cookie Value
	# を取得する。
	my @zarry = split(/\,/, $cookies{"$cookie_name"});

	foreach my $c (@zarry) {

		# Cookie Value を':'で分離し、APPで使用するKey
		# と Value を取り出す。
		my ($name, $value) = split(/\:/, $c);

		# URLエンコードをデコード。
		$name  = &URLDecode($name);
		$value = &URLDecode($value);

		$my_cookie->{$name} = $value;
	}

	return $my_cookie;
}

###################################################################
#
#	クッキー発行
#
###################################################################
sub SetCookie
{
	my ($cookie_name, $my_cookie, $cookie_expire) = @_;
	my $cook;

	my @Month = ('Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'); 
	my @Week  = ('Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'); 

	# このAPPで使用するクッキー
	while (($name, $value) = each(%{$my_cookie})) {

		# URLエンコードする。
		$name  = &URLEncode($name);
		$value = &URLEncode($value);

		# クッキー値文字列生成
		$cook .= ($cook eq '') ? "$name\:$value" : "\,$name\:$value";
	}

	# クッキーの有効期限設定
	$cookie_expire ||= 30;
	my ($sec, $min, $hour, $day, $mon, $year,
		$wday, $yday, $is_dst) = gmtime(time + $cookie_expire*24*60*60);

	# 取得した有効期限日時をRFCの形式に変換する
	$year += 1900;
	$sec  = sprintf("%02d", $sec);
	$min  = sprintf("%02d", $min);
	$hour = sprintf("%02d", $hour);
	$day  = sprintf("%02d", $day);
	$mon  = $Month[$mon];
	$wday = $Week[$wday];

	# クッキー有効期限文字列生成
	my $expire = "$wday, $day\-$mon\-$year $hour:$min:$sec GMT";

	# Cookie 発行String生成
	my $set_cookie = "Set-Cookie: $cookie_name=$cook; expires=$expire\n";

	return $set_cookie;
}

###################################################################
#
#	リダイレクトHTTP Location ヘッダを生成
#
###################################################################
sub SetRedirectHeader
{
	my ($nextURL) = @_;
	my $location;

	# HTTP Location ヘッダを生成
	$location = "Status: 302 Moved\nLocation: $nextURL" ;

	return $location;
}

###################################################################
#
#	独自方式による暗号化（簡易版。考え中）
#
###################################################################
sub EnCrypt
{
	my ($pass, $key) = @_;
	my $ango;
	my $k;
	foreach my $d (unpack("C*", $key)) { $k += $d; }
	$k %= 16;
	foreach my $d (unpack("C*", $pass)) {
		$d += $k;
		$ango .= ($ango eq '') ? "$d" : "_$d";
	}
	return $ango;
}

###################################################################
#
#	独自方式による暗号文の平文化（簡易版。考え中）
#
###################################################################
sub DeCrypt
{
	my ($ango, $key) = @_;
	my $pass;
	my $k;
	foreach my $d (unpack("C*", $key)) { $k += $d; }
	$k %= 16;
	my @ptmp;
	foreach my $d (split(/_/, $ango)) {
		$d -= $k;
		push(@ptmp, $d);
	}
	$pass = pack("C*", (@ptmp));
	return $pass;
}

###################################################################
#
#	CDATA 変換
#
###################################################################
sub Cdata
{
	my($str) = @_;
	$str =~ s/&/&amp;/g;
	$str =~ s/\"/&quot;/g;
	$str =~ s/>/&gt;/g;
	$str =~ s/</&lt;/g;
	return $str;
}

###################################################################
#
#	URL エンコード
#
###################################################################
sub URLEncode
{
	my($str) = @_;
	$str =~ s/([^\w\-\*\. ])/sprintf("%%%02X", unpack('C', $1))/ge;
	$str =~ s/ /\+/g;
	return $str;
}

###################################################################
#
#	URL エンコードをデコード
#
###################################################################
sub URLDecode
{
	my ($str) = @_;
	$str =~ s/\+/ /g;
	$str =~ s/%([0-9a-fA-F][0-9a-fA-F])/pack("C", hex($1))/eg;
	return $str;
}

###################################################################
#
#	URL を表す文字列を自動的にHTMLアンカータグに変換する
#
###################################################################
sub SetHtmlAnker
{
	my ($str) = @_;
	$str =~ s/(https?:\/\/[\w\.\/\?\-=&#~\%\+]+)/<a href=\"$1\" target=\"_ztarget\">$1<\/a>/g;
	return $str;
}

###################################################################
#
#	致命的エラー
#
###################################################################
sub FatalError
{
	my ($emes, $lock) = @_;
	unlink("$lock") if ($lock ne '');
	die @_;
}

###################################################################
1
