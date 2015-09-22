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
# =================================================================
#
#	============== Zumin - 素材やさん向け =============
#	=============== 壁紙サンプル表示CGI ===============
#
#   zbgshow1.cgi
#
#   Copyright(c) 2001-  Zumin., All rights reserved.
#
#   Email : mailto:webmaster@zumin.cside9.com
#   URL   : http://zumin.cside9.com/zumin/
#
# =================================================================
#   更新履歴：
#   Date.       Ver.    Note.
#   2001.05.13  0.0.1   初版
#   2001.05.27  1.0.1   初期不具合FIX
#   2001.05.28  1.0.2   初期不具合FIX
#   2001.05.30  1.0.3   初回リリース版
# =================================================================
# zbgshow1 Version
$MajiorVer  = "zbgshow1_V1";
$MiniorVer  = "03";
$CurrentVer = "${MajiorVer}${MiniorVer}";


###################################################################
#
#   カスタマイズ可能変数（お好みで書き換え可）
#
###################################################################

$Title = '壁紙サンプル表示';
$Body  = '表示はこんな感じです。<br>いかがですか？';


###################################################################
#
#	Define Globals 固定値
#
###################################################################

# ------------------------------------
# 以下は変更しないでください。
# ------------------------------------
$Url      = '';
$TitleCol = '000000';
$BodyCol  = '000000';


###################################################################
#
#	Start Running Script
#
###################################################################

# サーバー日本語文字コード取得
my $saver_jcode = &GetSaverEncode();

# パラメータ取得
my $p = &GetParam();

# パラメータ解析
# 壁紙画像へのURL
if ($p->{url} ne '') { $Url = $p->{url}; }
else {

{
print <<"EOE"
Content-type: text/html; charset=$saver_jcode

<html>
<head>
<title>$Title</title>
</head>
<body bgcolor="#FFFFFF">
<center>
<h2><font color="#FF0000">
画像ファイルへの URL が指示されていません。
</font></h2>
</center>
</body>
</html>
EOE
}

	exit;
}

# サンプル文字色
if ($p->{title_col} ne '') { $TitleCol = "#$p->{title_col}"; }
if ($p->{body_col} ne '')  { $BodyCol  = "#$p->{body_col}"; }

{
print <<"EOF"
Content-type: text/html; charset=$saver_jcode

<html>
<head>
<title>$Title</title>
</head>
<body bgcolor="#FFFFFF" background="$Url">
<center>

<font color="$TitleCol">
<h1>$Title</h1>
</font>
<p>

<hr NOSHADE size="2" width="90%">
<font color="$BodyCol">
$Body
</font>
<hr NOSHADE size="2" width="90%">

<p>
<BR>
<BR>
<font color="#000000">●●● #000000 ●●●</font><BR>
<font color="#FFFFFF">●●● #FFFFFF ●●●</font><BR>
<font color="#FFFF00">●●● #FFFF00 ●●●</font><BR>
<font color="#00FF00">●●● #00FF00 ●●●</font><BR>
<font color="#00FFFF">●●● #00FFFF ●●●</font><BR>
<font color="#0000FF">●●● #0000FF ●●●</font><BR>
<font color="#FF00FF">●●● #FF00FF ●●●</font><BR>
<font color="#FF0000">●●● #FF0000 ●●●</font><BR>
<P>

</center>
</body>
</html>
EOF
}

exit;


###################################################################
#
#	CGI パラメータ取得
#
###################################################################
sub GetParam
{
	my ($query, @params, $param);
	my $p = {};

	# パラメータ取得
	$query = $ENV{'QUERY_STRING'};
	@params = split(/&/, $query);

	# パラメータをキーと値に分解
	foreach $param (@params) {
		my ($name, $value) = split(/=/, $param);

		# URL エンコードをデコード
		$value =~ s/\+/ /g;
		$value =~ s/%([0-9a-fA-F][0-9a-fA-F])/pack("C", hex($1))/eg;

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
		if ($judge[0] == 0xb4) { $Static_enc = 'EUC-JP';}
		else { $Static_enc = 'Shift_JIS'; }
	}
	return $Static_enc;
}
