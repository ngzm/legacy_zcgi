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
#   zbgshow2.cgi
#
#   Copyright(c) 2001-  Naoki Nagazumi., All rights reserved.
#
#   Email : mailto:webmaster@zumin.cside9.com
#   URL   : http://zumin.cside9.com/zumin/
#
# =================================================================
#   更新履歴：
#   Date.       Ver.    Note.
#   2001.05.18  0.0.1   初版
#   2001.05.27  1.0.1   初回リリース版
# =================================================================
# zbgshow Version
$MajiorVer  = "zbgshow2_V1";
$MiniorVer  = "01";
$CurrentVer = "${MajiorVer}${MiniorVer}";


###################################################################
#
#	Define Globals 固定値
#
###################################################################
$ImgUrl      = '';
$Refer       = '';


###################################################################
#
#	Start Running Script
#
###################################################################

# CGIパラメータ取得
my $p = &GetParam();
if ($p->{url} ne '') { $ImgUrl = $p->{url}; }
else {
	&PrintError('画像ファイルへの URL が指示されていません。');
	exit;
}
if ($p->{refer} ne '') { $Refer = $p->{refer}; }
unless (-e $Refer) {
	&PrintError('読み込み対象となるHTMLファイルが見つけられません。');
	exit;
}
unless ($Refer =~ /\.html?$/) {
	&PrintError('読み込み対象がHTMLファイルではありません。');
	exit;
}

# 呼び出し元HTMLファイルをロード
my $html;
open(IN, "$Refer") || &PrintError("$Refer がオープンできませんでした");
while(my $line = <IN>) { $html .= $line; }
close(IN);

# 改行コードを xff に置き換え。
$html =~ s/\r\n/\xff/g;
$html =~ s/\r/\xff/g;
$html =~ s/\n/\xff/g;

# BODY TAG の BACKGROOOUND のみ書き換える。
my ($pre, $body, $after) = $html =~ /(.*)(<body[^>]*>)(.*)/i;
if ($body =~ /background=[^>\s]*/i) {
	$body = $` . "background=\"$ImgUrl\"" . $';
} else {
	$body =~ s/>/ background=\"$ImgUrl\">/;
}
$html = "$pre$body$after";

# 改行コード[ \n ]を復活。
$html =~ s/\xff/\n/g;

# ブラウザに出力
print "Content-type: text/html\n";
print "\n";
print $html;

exit;


###################################################################
#
#	エラー表示
#
###################################################################
sub PrintError
{
	my ($emes) = @_;

	# サーバー日本語文字コード取得
	my $saver_jcode = &GetSaverEncode();

print <<"EOE"
Content-type: text/html; charset=$saver_jcode

<html>
<head>
<title>$Title</title>
</head>
<body bgcolor="#FFFFFF">
<center>
<h2><font color=\"#FF0000\">$emes</font></h2>
</center>
</body>
</html>
EOE
}

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

	# PATH_TRANSLATED 取得
	my $path = $ENV{'PATH_TRANSLATED'};
	if ($path) { $p->{refer} = $path; }
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
			$Static_enc = 'EUC-JP';
		} else {
			$Static_enc = 'Shift_JIS';
		}
	}
	return $Static_enc;
}
