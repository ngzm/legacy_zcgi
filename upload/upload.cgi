#!/usr/bin/perl --
# =================================================================
#	=============== Zumin - 画像アップロードCGI ==============
#
#   upload.cgi
#
#   Copyright(c) 2005-  Zumin., All rights reserved.
#
#   Email : mailto:webmaster@zumin.cside9.com
#   URL   : http://zumin.cside9.com/zumin/
#
# =================================================================
#   更新履歴：
#   Date.       Ver.    Note.
#   2005.03.18  1.0.0   初版
# =================================================================
###################################################################
# 宣言
###################################################################
use CGI;
use strict;
use lib ".";
use upload_common;

###################################################################
# 処理開始
###################################################################

my $mes = '';

# CGIインスタンス生成
my $query = new CGI;

# パスワード認証
my $passwd = $query->cookie(-name => "$COOKIE_NAME");
if ($passwd ne $PASSWORD) {
	# 認証失敗した場合
	&print_Redirect();
	exit(0);
}

# ファイルサイズをチェック
my $size = $ENV{CONTENT_LENGTH};
if ($size > $MAX_SIZE) {
	$mes = "ファイルサイズが大きすぎます（${size}byte）";
	goto ON_ERROR;
}

# アップロードファイルのファイルハンドル取得
my $filehandle = $query->upload('upfile');
if ($filehandle eq '') {
	$mes = "アップロードファイルの指定がありません";
	goto ON_ERROR;
}

# アップロードファイル名を取得
my $fname = $query->param('upfile');

# 日本語コード変換・特殊文字対策
$fname = &ConvStr($fname, $SAVERCODE);

$fname =~ s/\\/\//g;								# パス区切り文字を/に変換
$fname = substr($fname, rindex($fname,"/")+1);		# ファイル名のみを取得
if ($fname =~ /[^\w-\.]/) {
	$mes = "ファイル名に英数字以外は使用できません（${fname}）";
	goto ON_ERROR;
}

# エラーがないときはアップロードファイルを保存
open(OUT, ">$TARGET_DIR/$fname");
binmode OUT;
print OUT <$filehandle>;
close(OUT);

# 正常レスポンス
$mes = "ファイル：$fname は正常にアップロード完了しました";
&print_OK($mes);
exit(0);

ON_ERROR:
# エラー発生時
# 異常レスポンス
&print_Error($mes);
exit(-1);

###################################################################
#
# 正常メッセージの表示 
#
###################################################################
sub print_OK
{
	my ($mes) = @_;

	print "Content-type: text/html; charset=$SAVER_ENCODE\n";
	print "Pragma: no-cache\n";
	print "Cache-Control: no-cache\n";
	print "\n";

print <<"OKHTML"; 
<HTML> 
<HEAD> 
<TITLE>パパのアップロードCGI</TITLE> 
</HEAD> 
<BODY>
<DIV style="padding : 10px; background-color : #CCDDFF">
<h1 style="color : #3366CC">&#9825; アップロード成功 &#9829;</h1>
$mes<BR>
</DIV>
<DIV>
<P>
<a href="$DISP_CGI">- 戻る -</a>
</DIV>
</BODY> 
</HTML> 
OKHTML
}

###################################################################
#
# エラーメッセージの表示 
#
###################################################################
sub print_Error
{
	my ($mes) = @_;

	print "Content-type: text/html; charset=$SAVER_ENCODE\n";
	print "Pragma: no-cache\n";
	print "Cache-Control: no-cache\n";
	print "\n";

# エラーメッセージの表示 
print <<"ERRORHTML"; 
<HTML> 
<HEAD> 
<TITLE>パパのアップロードCGI</TITLE> 
</HEAD> 
<BODY>
<DIV style="padding : 10px; background-color : #FFCCDD">
<h1 style="color : #FF0066">！！！エラーです！！！</h1>
$mes
</DIV>
<DIV>
<P>
<a href="$DISP_CGI">- 戻る -</a>
</DIV>
</BODY> 
</HTML> 
ERRORHTML
}

###################################################################
#
# 認証エラーリダイレクト 
#
###################################################################
sub print_Redirect
{
	print "Content-type: text/html; charset=$SAVER_ENCODE\n";
	print "Location: $DISP_CGI\n";
	print "\n";
}

