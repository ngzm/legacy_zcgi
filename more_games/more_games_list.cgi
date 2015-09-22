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

###################################################################
#
#	Start Running Script
#
###################################################################
use CGI;
use strict;
require "jcode.pl";

# グローバル変数
use vars qw(
	%LINK_ARRAY
);


# 厳選リンクサイトURL配列
%LINK_ARRAY = (
###	"ゲーム楼"				=>	"http://www.gamerou.net/",
###	"ケセラセラ"			=>	"http://queserasera.main.jp/ranklink/ranklink.cgi?id=zumin",
###	"FREE ! ミニゲーム集"	=>	"http://www.32game.com/",
###	"無料ゲーム情報局"		=>	"http://www.rinku.zaq.ne.jp/bkayf600/salagame.html",
###	"無料ゲームコム"		=>	"http://members.jcom.home.ne.jp/masimaro/",
	"無料ゲームA1-GAME"		=>	"http://a1-game.com/",
	"E-GAME 無料ゲーム"		=>	"http://www.everygame.net/",
	"ゲームボックス"		=>	"http://www.game-box.jp/ranking/ranklink.cgi?id=zumin",
	"GAME GAME GAME"		=>	"http://hpcgi1.nifty.com/netvoyager/game/rl1_86/ranklink.cgi?id=zumin",
	"100%ねっとげストア"	=>	"http://game.spstore.com/cgi-bin/rk/ranklink.cgi?id=zumin",
	"ゲームの缶詰"			=>	"http://www.game-can.com/ranking/ranklink.cgi?id=zumin",
	"おもしろゲーム"		=>	"http://muryou777.com/",
	"フリゲマン"			=>	"http://www.fgman.com/",
	"無料ゲーム人気サイト"	=>	"http://game.link-search.com/ranklink.cgi?id=zumin",
	"無料ゲーム総合サイト"	=>	"http://chibicon.net",
	"GAME OR DIE "			=>	"http://gomu.org/game/",
	"フリーテレビゲーム"	=>	"http://goldnov.com/",
	"0円！楽ゲーム"			=>	"http://www.raku-game.com/",
	"ゲームコーナー"		=>	"http://kudou3.com/game/index.html",
	"無料ゲームナビゲータ"	=>	"http://www.69sp.com/",
);

# 厳選リンクをランダムに抽出
my @link_keys = keys(%LINK_ARRAY);
my $len = @link_keys;
## print "len = $len\n";

srand;
my $no = int (rand $len);
## print "no = $no\n";

# CGIインスタンス生成
my $query = new CGI;

# 表示リスト数をパラメータより取得
my $maxline = $query->param('maxline');
if ($maxline < 1) {
	$maxline = 2;
}

# ヘッダ出力
print <<"EOH"; 
Content-type: text/javascript; charset=Shift_JIS
Pragma: no-cache
Cache-Control: no-cache

EOH

# リスト（Javascript）の出力
for (my $i=0 ; $i < $maxline ; $i++) {

	if ($i > 0) {
#		print "document.write(\"<hr>\");\n";
		print "document.write(\"<br>\");\n";
	}

	my $j = ($no + $i) % $len;

## print "j = $j\n";

	my $str = $link_keys[$j];
	my $url = $LINK_ARRAY{$str};
	my $label = &jcode::sjis($str);
	print "document.write(\"<a href='$url' target='_blank'>$label</a>\");\n";
}

exit 0;
