#!/usr/bin/perl --
# =================================================================
#	=============== Zumin - 画像アップロードCGI ==============
#
#   delete.cgi
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

# 削除ファイル名取得
my $fname = $query->param('del_file');
if ($fname eq '') {
	$mes = "削除ファイルの指定がありません";
	goto ON_ERROR;
}
unless (-e "$fname") {
	$mes = "削除対象のファイルがありません";
	goto ON_ERROR;
}

# 削除処理
unlink($fname);

# 正常レスポンス
$mes = "ファイル：$fname を削除しました";
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
<h1 style="color : #3366CC">&#9825; 削除完了 &#9829;</h1>
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

