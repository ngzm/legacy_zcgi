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
#	人口無能エンジン『ハムっこ！』
#
# =================================================================
#   更新履歴：
#   Date.       Ver.    Note.
#	2002/09/14	0.01	アルファ版リリース
#	2002/09/18	0.10	ベータ１版リリース
#	2002/09/23	1.00	新規リリース
#   2002.09.28  1.01    HTTPヘッダにキャッシュしない指示を追加
#   2003.02.11  1.03    改行コードによる起動不具合の修正（!/usr/bin/perl -- ）
# =================================================================
require "jcode.pl";		# 日本語文字コード変換ライブラリ
use strict;
package hamkko;

# -------------------------------------------------------------
#   グローバル変数
# -------------------------------------------------------------
use vars qw(
	$MajiorVer
	$MiniorVer
	$CurrentVer
	$TOUR
	$URANAI
	$NAZONAZO
	$MUNOU
);
# ---------------------------
#『ハムっこ』Version
# ---------------------------
$MajiorVer		= "hamkko_v1";
$MiniorVer		= "01";
$CurrentVer		= "${MajiorVer}\.${MiniorVer}";

# ---------------------------
# 『ハムっこ』処理モード
# ---------------------------
$TOUR			= 1;
$URANAI			= 2;
$NAZONAZO		= 3;
$MUNOU			= 4;

# ---------------------------
# 日本語文字コード
# ---------------------------
my $EUC			= 'EUC-JP';
my $SJIS		= 'Shift_JIS';
my $JIS			= 'iso-2022-jp';
my $SARVERENC	= $EUC;

# ---------------------------
# その他
# ---------------------------
my $OK			= 1;
my $NG			= 0;

# ---------------------------
my $dbg			= 0;
# ---------------------------

###################################################################
#	『ハムっこ』外部インターフェイス
###################################################################
sub ham_main
{
	my (@_args) = @_;
	my ($parm, $res) = ('', '');

	# システム初期設定、現在パラメータ取得
	$parm = &hinit(@_args);

	# モードによる処理ハンドリングその１
	if ($parm->{mode} == $MUNOU) {
		# 人口無能
		$res = &ham_munou($parm);
	}

	# モードによる処理ハンドリングその２
	if ($parm->{mode} == $TOUR) {
		# ホームページの紹介
		;
	} elsif ($parm->{mode} == $URANAI) {
		# うらない
		;
	} elsif ($parm->{mode} == $NAZONAZO) {
		# なぞなぞ
		;
	}

	return ($res);
}

###################################################################
#	人口無能エンジン
###################################################################
sub ham_munou
{
	my ($parm) = @_;
	my ($res, $out, $point);

if ($dbg) {
	print "A: parm->{in} = $parm->{in}<br>\n";
	print "A: parm->{mode} = $parm->{mode}<br>\n";
	print "A: parm->{level} = $parm->{level}<br>\n";
	print "A: parm->{out} = $parm->{out}<br>\n";
}

	# 長音を表す文字を"～"に統一
	my $ascii     = '[\x00-\x7F]';
	my $euc_2byte = '[\x8E\xA1-\xFE][\xA1-\xFE]';
	my $euc_3byte = '\x8F[\xA1-\xFE][\xA1-\xFE]';
	$parm->{in}  =~ s/\G((?:$ascii|$euc_2byte|$euc_3byte)*?)(?:\-|ー|－|―|‐|～)+/$1～/g;

if ($dbg) {
	print "B: parm->{in} = $parm->{in}<br>\n";
}

	# 入力文字をひらがなとカタカナに統一
	my $in_hira = &jcode::trans($parm->{in}, 'ア-ンヴヵヶ', 'あ-んぶかが', 'euc');
	my $in_kata = &jcode::trans($parm->{in}, 'あ-ん', 'ア-ン', 'euc');

	# 現在のごきげんパラメータを0～9に正規化
	my $clevel = int ($parm->{level} / 10);

	# 語彙辞書ロード
	my @dic1 = &load_dic1();

	# 応答辞書ロード
	my @dic2 = &load_dic2($clevel);

	# 応答キーが一致するデータ検索
	my @match;
	foreach my $d2 (@dic2) {

		my $key = $d2->{key};

		# 語彙展開
		for (my $n = 0 ;  ($key =~ /&<\S+>/) && $n < 4 ; $n++) {
			foreach my $d1 (@dic1) {
				$key =~ s/(?:$d1->{key})/$d1->{rep}/;
			}
		}

		# 応答キー検索
		if ($parm->{in} =~ /^(?:$ascii|$euc_2byte|$euc_3byte)*?(?:$key)/i) {
			# 後方参照があった場合はこのタイミングで一致した内容を記憶しておく
			# 制限：5個まで！！
			$d2->{1} = $1 if ($1 ne '');
			$d2->{2} = $2 if ($2 ne '');
			$d2->{3} = $3 if ($3 ne '');
			$d2->{4} = $4 if ($4 ne '');
			$d2->{5} = $5 if ($5 ne '');
			push(@match, $d2);

if ($dbg) {
	print "1: key = $key<br>\n";
}

		} elsif ($in_hira =~ /^(?:$ascii|$euc_2byte|$euc_3byte)*?(?:$key)/i) {
			# 後方参照があった場合はこのタイミングで一致した内容を記憶しておく
			# 制限：5個まで！！
			$d2->{1} = $1 if ($1 ne '');
			$d2->{2} = $2 if ($2 ne '');
			$d2->{3} = $3 if ($3 ne '');
			$d2->{4} = $4 if ($4 ne '');
			$d2->{5} = $5 if ($5 ne '');
			push(@match, $d2);

if ($dbg) {
	print "2: key = $key<br>\n";
}

		} elsif ($in_kata =~ /^(?:$ascii|$euc_2byte|$euc_3byte)*?(?:$key)/i) {
			# 後方参照があった場合はこのタイミングで一致した内容を記憶しておく
			# 制限：5個まで！！
			$d2->{1} = $1 if ($1 ne '');
			$d2->{2} = $2 if ($2 ne '');
			$d2->{3} = $3 if ($3 ne '');
			$d2->{4} = $4 if ($4 ne '');
			$d2->{5} = $5 if ($5 ne '');
			push(@match, $d2);

if ($dbg) {
	print "3: key = $key<br>\n";
}

		}
	}
	# 返答キーが一致した場合
	if (@match > 0) {
		my $d2 = $match[int rand @match];
		my @r  = split(/\|/, $d2->{res});
		$out   = $r[int rand @r];
		# 後方参照があった場合の処理
		$out =~ s/<1>/$d2->{1}/g if ($d2->{1} ne '');
		$out =~ s/<2>/$d2->{2}/g if ($d2->{2} ne '');
		$out =~ s/<3>/$d2->{3}/g if ($d2->{3} ne '');
		$out =~ s/<4>/$d2->{4}/g if ($d2->{4} ne '');
		$out =~ s/<5>/$d2->{5}/g if ($d2->{5} ne '');
		if ($out =~ /<0>/) {
			my @f;
			push(@f, $d2->{1}) if ($d2->{1} ne '');
			push(@f, $d2->{2}) if ($d2->{2} ne '');
			push(@f, $d2->{3}) if ($d2->{3} ne '');
			push(@f, $d2->{4}) if ($d2->{4} ne '');
			push(@f, $d2->{5}) if ($d2->{5} ne '');
			$out =~ s/<0>/$f[int rand @f]/g;
		}
		# ご機嫌ポイント数
		$point = $d2->{point};
	}
	# 一致する返答キーが存在しない場合
	else {
		# ランダム辞書ロード
		my @dic4 = &load_dic4($clevel);
		my $d4 = $dic4[int rand @dic4];
		$out   = $d4->{res}; 

		# ご機嫌ポイント数
		$point = (int rand 8) + 1;
	}

	# 語彙変換
	for (my $n = 0 ; ($out =~ /&<\S+>/) && ($n < 4) ; $n++) {
		foreach my $d1 (@dic1) {
			if ($out =~ /(?:$d1->{key})/) {
				my @r = split(/\|/, $d1->{rep});
				my $rep = $r[int rand @r];
				$out =~ s/(?:$d1->{key})/$rep/;
			}
		}
	}

	# 固定値変換
	$out =~ s/%<myname>/$parm->{myname}/g;
	$out =~ s/%<usname>/$parm->{usname}/g;

	# 返却値セット
	$res->{out}   = $out;
	$res->{mode}  = $parm->{mode};
	$res->{level} = $parm->{level} + ($point - 5) * 10 + (int rand $point);
	$res->{level} = 0   if ($res->{level} < 0);
	$res->{level} = 99  if ($res->{level} > 99);
	return $res;
}

###################################################################
#	各種初期化処理、パラメータ解析＆取得
###################################################################
sub hinit
{
	my ($arg) = @_;
	if ($arg->{in}		eq ''	||
		$arg->{myname}	eq ''	||
		$arg->{usname}	eq ''	||
		$arg->{mode}	eq ''	||
		$arg->{level}	eq ''	||
		$arg->{out}		eq ''	){
		die "引数が不足しています。" ;
	}
	&conv_str(\$arg->{in},     $EUC);
	&conv_str(\$arg->{myname}, $EUC);
	&conv_str(\$arg->{usname}, $EUC);
	&conv_str(\$arg->{out},    $EUC);

	# パラメータ値取得
	my $p;
	$p->{in}     = $arg->{in};		# 入力された言葉
	$p->{myname} = $arg->{myname};	# 対話している人（人口無能）の名前
	$p->{usname} = $arg->{usname};	# 対話している人（相手）の名前
	$p->{mode}   = $arg->{mode};	# 処理モード
	$p->{level}  = $arg->{level};	# 現在の機嫌
	$p->{out}    = $arg->{out};		# 返答する言葉

	# 乱数ジェネレータ初期化
	# srand(time);
	srand();

	# サーバ日本語文字エンコード取得
	# '漢字'をサンプルに16進変換して調べてみる
	# '漢字'は、EUCでは、b4,c1,bb,fa である。。
	my @judge = unpack('C*', '漢字');
	if ($judge[0] == 0xb4)	{ $SARVERENC = $EUC;  }
	else					{ $SARVERENC = $SJIS; }

	return $p;
}

###################################################################
#	語彙辞書ファイル「dic1.dat」ロード
###################################################################
sub load_dic1
{
	# 語彙辞書ロード
	open (IN, "dic1.dat") or die "dic1.dat がありません！";
	my @line = <IN>;
	close(IN);

	# 構造化して変数に格納
	my @dic1;
	foreach my $l (@line) {
		&conv_str(\$l, $EUC) if ($SARVERENC ne $EUC);
		next if ($l =~ /^#/);
		$l =~ s/\r\n/\n/g;
		$l =~ s/\n\r/\n/g;
		$l =~ s/\r/\n/g;
		$l =~ s/\t+/\t/g;
		chomp $l;
		my $d1;
		($d1->{key}, $d1->{rep}) = split(/\t/, $l);
		next if ($d1->{key} eq '' || $d1->{rep} eq '');
		push(@dic1, $d1);
	}
	return @dic1;
}

###################################################################
#	応答辞書ファイル「dic2.dat」ロード
###################################################################
sub load_dic2
{
	my ($level) = @_;
	my $lev;

	# 応答辞書ロード
	open (IN, "dic2.dat") or die "dic2.dat がありません！";
	my @line = <IN>;
	close(IN);

	# 構造化して変数に格納
	my @dic2;
	foreach my $l (@line) {
		&conv_str(\$l, $EUC) if ($SARVERENC ne $EUC);
		next if ($l =~ /^#/);
		$l =~ s/\r\n/\n/g;
		$l =~ s/\n\r/\n/g;
		$l =~ s/\r/\n/g;
		$l =~ s/\t+/\t/g;
		chomp $l;
		my $d2;
		($lev, $d2->{key}, $d2->{res}, $d2->{point}) = split(/\t/, $l);
		next if ($lev eq '' || $d2->{key} eq '' || $d2->{res} eq '' || $d2->{point} eq '');
		my ($lmin, $lmax) = split(/-/, $lev);
		push(@dic2, $d2) if ($lmin <= $level && $lmax >= $level);
	}
	return @dic2;
}

###################################################################
#	拡張応答辞書ファイル「dic3.dat」ロード
#	※ 現在未使用
###################################################################
sub load_dic3
{
	my @dic3;
	return @dic3;
}

###################################################################
#	ランダム応答辞書ファイル「dic4.dat」ロード
###################################################################
sub load_dic4
{
	my ($level) = @_;
	my $lev;

	# ランダム応答辞書ロード
	open (IN, "dic4.dat") or die "dic4.dat がありません！";
	my @line = <IN>;
	close(IN);

	# 構造化して変数に格納
	my @dic4;
	foreach my $l (@line) {
		&conv_str(\$l, $EUC) if ($SARVERENC ne $EUC);
		next if ($l =~ /^#/);
		$l =~ s/\r\n/\n/g;
		$l =~ s/\n\r/\n/g;
		$l =~ s/\r/\n/g;
		$l =~ s/\t+/\t/g;
		chomp $l;
		my $d4;
		($lev, $d4->{res}) = split(/\t/, $l);
		next if ($lev eq '' || $d4->{res} eq '');
		my ($lmin, $lmax) = split(/-/, $lev);
		push(@dic4, $d4) if ($lmin <= $level && $lmax >= $level);
	}
	return @dic4;
}

###################################################################
#	日本語コード変換
###################################################################
sub conv_str
{
	my ($pstr, $enc) = @_;
	if		($enc eq $EUC)	{ &jcode::convert($pstr, 'euc');  }
	elsif	($enc eq $SJIS)	{ &jcode::convert($pstr, 'sjis'); }
	else					{ die "日本語コード不明"; }
}

###################################################################
1;
