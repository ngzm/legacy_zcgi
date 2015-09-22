#!/usr/bin/perl --
# =================================================================
#	=============== Zumin - 画像アップロードCGI ==============
#
#   disp.cgi
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

# クエリーのパスワード取得
my $passwd = $query->param($COOKIE_NAME);
if ($passwd ne '') {
	# ---------------------------------------------
	# クエリーでパスワードが入力されたときは
	# POSTで起動したときであり、その後の再表示で
	# 再送のダイアログが出るためうざい。。
	# そこで、一旦、クッキーをセットし、もう一度
	# 自分自身にリダイレクトする。
	# ---------------------------------------------
	# パスワードクッキー文字列生成
	my $cookie = $query->cookie(
		-name		=> "$COOKIE_NAME",
		-value		=> "$passwd",
		-expires	=> "$COOKIE_EXPIRE",
		-path		=> '/upload'
	);
	print_Redirect($cookie);
	exit(0);
}

# クッキーに保存されたパスワード取得
$passwd = $query->cookie(-name => "$COOKIE_NAME");

## DEBUG
## print stderr "### PASSWD=$passwd\n";
## DEBUG

if ($passwd eq '') {
	# パスワードがないときパスワード入力フォームへ
	print_Auth();
	exit(0);

} elsif ($passwd ne $PASSWORD) {
	# 認証失敗した場合
	# エラー表示後パスワード入力フォームへ
	$mes = "パスワードが違います！";
	&print_Auth($mes);
	exit(0);
}
# パスワードクッキー文字列生成
my $cookie = $query->cookie(
	-name		=> "$COOKIE_NAME",
	-value		=> "$passwd",
	-expires	=> "$COOKIE_EXPIRE",
	-path		=> '/upload'
);

# ディレクトリ検索しエントリしているファイル名を全て取得
my @files;
opendir(DIR, $TARGET_DIR) or die "opendir $TARGET_DIR 失敗: $!";
while (my $entry = readdir(DIR)) {
	if (-d "$TARGET_DIR/$entry") {
		next;
	}
	push(@files, "$TARGET_DIR/$entry");
}
closedir(DIR);

# ファイルリスト表示レスポンス出力
print_List($cookie, @files);
exit(0);

###################################################################
#
# ファイルリスト表示レスポンス出力
#
###################################################################
sub print_List
{
	my ($cookie, @files) = @_;
	my $cnt = @files;

	# ヘッダ部出力
	print "Content-type: text/html; charset=$SAVER_ENCODE\n";
	print "Pragma: no-cache\n";
	print "Cache-Control: no-cache\n";
	print "Set-Cookie: $cookie\n";
	print "\n";

	# HTML出力
print <<"EO_HEAD"; 
<HTML> 
<HEAD> 
<TITLE>パパのアップロードCGI</TITLE> 
</HEAD>
<BODY>
<H1 style="color : #3366CC">パパのアップロードCGI</H1>
<DIV style="padding : 10px; background-color : #CCDDFF">
■ ここからファイルをアップロードできます。
<p>
<form action="./${UPLOAD_CGI}" method="POST" enctype="multipart/form-data">
<input type="file" name="upfile" size="80">
<br>
<input type="submit" value="アップロードする">
</form>
</DIV>
<p>

<DIV style="padding : 10px; background-color : #CCDDFF">
■ 現在保存されているファイル：$cnt 個
<p>
<TABLE BORDER=1>
EO_HEAD

# ディレクトリエントリの表示
my $i = 0;
foreach my $file (@files) {
	$i++;
	my $tmp = sprintf("%03d", $i);

	print "<tr>\n";
	print "<td>No：$tmp</td>\n";
	print "<td><a href=\"$file\">$file</a></td>\n";

	if ($file =~ /(\.gif|\.jpg|\.png)$/i) {
		print "<td><img src=\"$file\" alt=\"img$i\"></td>\n";
	} else {
		print "<td style=\"background-color : #004488; color : #FFFFFF\">プレビューなし</td>\n";
	}
	print "<td>\n";
	print "<form action=\"./${DELETE_CGI}\" method=\"GET\">\n";
	print "<input type=\"hidden\" name=\"del_file\" value=\"${file}\">\n";
	print "<input type=\"submit\" value=\"消す\" onClick=\"return confirm(" .
					"'ファイル $file を削除します。よろしいですか？')\">\n";
	print "</form>\n";
	print "</td>\n";
	print "</tr>\n";
}

# テイル部出力
print <<"EO_TAIL"; 
</TABLE>
</DIV>
</BODY> 
</HTML> 
EO_TAIL
}

###################################################################
#
# 認証画面出力
#
###################################################################
sub print_Auth
{
	my ($mes) = @_;

	# ヘッダ部出力
	print "Content-type: text/html; charset=$SAVER_ENCODE\n";
	print "Pragma: no-cache\n";
	print "Cache-Control: no-cache\n";
	print "\n";

	# HTML出力
print <<"EO_AUTH"; 
<HTML> 
<HEAD> 
<TITLE>パパのアップロードCGI</TITLE> 
</HEAD>
<BODY>
<H1 style="color : #3366CC">パパのアップロードCGI<BR> -- パスワード入力 --</H1>
<DIV style="padding : 10px; background-color : #CCDDFF">
$mes
<P>
<form action="./${DISP_CGI}" method="POST">
<input type="password" name="$COOKIE_NAME" maxlength="16">
<input type="submit" value="送信">
</form>

</DIV>
</BODY> 
</HTML> 
EO_AUTH
}

###################################################################
#
# リダイレクト 
#
###################################################################
sub print_Redirect
{
	my ($cookie) = @_;

	print "Content-type: text/html; charset=$SAVER_ENCODE\n";
	print "Set-Cookie: $cookie\n";
	print "Location: $DISP_CGI\n";
	print "\n";
}
