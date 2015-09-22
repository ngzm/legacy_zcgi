#!/usr/bin/perl --
# =================================================================
#	=============== Zumin - CGI Library Mini ==============
#
#   zcgi_mini.pm
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
use strict;
require './jcode.pl';

# グローバル変数
use vars qw(
	$EUC
	$JIS
	$SJIS
	$SAVERCODE
	$Static_enc
	$SAVER_ENCODE
	$UPLOAD_CGI
	$DELETE_CGI
	$TARGET_DIR
	$DISP_CGI
	$UPLOAD_CGI
	$DELETE_CGI
	$TARGET_DIR
	$MAX_SIZE
	$COOKIE_NAME
	$COOKIE_EXPIRE
	$PASSWORD
);

# 日本語文字コードタイプ定義。下記以外のタイプ(IATA Alias名など）
# は使用しないようにしているので注意されたい。
$EUC        = 'EUC-JP';
$JIS        = 'iso-2022-jp';
$SJIS       = 'Shift_JIS';
$SAVERCODE  = 'SAVER-ENCODE';
$Static_enc = '';

# サーバの漢字コード
$SAVER_ENCODE = &GetSaverEncode();

# 各CGIのURL
$DISP_CGI   = 'disp.cgi';
$UPLOAD_CGI = 'upload.cgi';
$DELETE_CGI = 'delete.cgi';

# ファイル保存先ディレクトリ
$TARGET_DIR = "./data";

# アップロードサイズ上限（byte）
$MAX_SIZE = 5000000;

# パスクッキー
$COOKIE_NAME   = 'pass';
$COOKIE_EXPIRE = '+60d';

# パスワード
$PASSWORD = 'xiehet';

###################################################################
#
#	サーバファイルエンコード取得
#
###################################################################
sub GetSaverEncode
{
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
	my $str = &jcode::euc(@_);

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
	my $str = &jcode::sjis(@_);

	# 半角カナを全角カナに変換
	jcode::h2z_sjis(*str);

	return $str;
}

###################################################################
1
