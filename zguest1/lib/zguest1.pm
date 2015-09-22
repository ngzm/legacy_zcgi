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
#	===============     Zumin - ゲストブック     ===============
#	============== ゲストブック本体 専用 App-Lib ===============
#
#   zguest1.pm
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
#   2001.04.27  0.0.2   初期不具合修正
#   2001.04.28  0.0.3   アイコン表示機能整備
#   2001.04.28  0.0.4   投稿ログ削除機能追加
#   2001.05.01  0.0.5   URL文字をアンカーに変更する処理追加
#   2001.05.09  0.0.6   APPライブラリを整理しzg1core.pmを追加
#   2001.05.12  0.0.7   投稿ログ表示ブラッシュアップ
#   2001.05.17  0.0.8   投稿ログ保存形式を一般的な形に変更
#   2001.05.19  1.0.1   リリース第１版
#   2001.05.23  1.0.2   ログ登録処理若干効率化
#   2001.05.24  1.0.3   返信ログ登録処理若干効率化
#   2001.05.26  1.0.4   デモ用、機能削減追加
#   2001.05.28  1.0.5   暗号処理（簡易版）追加
#   2001.06.15  1.0.6   クッキー有効期限を指定可能にする
#   2001.06.15  1.0.7   訪問者のプロファイルをクッキーに記憶（60日）
#   2002.05.25  1.0.8   名前、E-MAIL、HP-NAME、URL入力テキストサイズ拡大
#   2002.09.28  1.1.0   HTTPヘッダにキャッシュしない指示を追加
#   2002.10.05  1.2.0   ログダウンロードのCSVファイルのカンマや改行などを
#                       含むデータのときにフォーマットが壊れていた不具合
#                       に対応
#   2002.10.14  1.3.0   管理者ツールに投稿ログ検索機能追加
#   2003.01.25  1.3.1   アイコン表示数制限数を10から30に増加
# =================================================================

###################################################################
#
#	Define Globals 固定値
#
###################################################################

# このCGI名称
$MyCGI  = "zguest1.cgi";
$MyCGIp = "zguest1p.cgi";

# 管理者用の管理CGIへのURL
$AdminCgiUrl = 'zg1adm.cgi';

# クッキー名称
$MyCookieName = 'ZGUEST1';


# ゲストブックトップへのリンクを表示するかどうかのフラグ
# サブメニューの時に表示する。
$DispLinktoTop = 0;

# へび型一覧表示フラグ
$Snake = 1;


###################################################################
#
#	HTML データ書き出し
#
###################################################################
sub PrintHeader
{
	# サーバー日本語文字コード取得
	my $saver_jcode = &GetSaverEncode();

	# HTTP データ出力
	print "Pragma: no-cache\n";
	print "Cache-Control: no-cache\n";
	print "Content-type: text/html; charset=$saver_jcode\n";
	print "\n";

	# HTML Header
	print "<html>\n";
	print "<head><title>$UserTitle</title></head>\n";

	# HTML Body
	print "<body bgcolor=\"$UserBgColor\" text=\"$UserFgColor\"";
	print " background=\"$UserBgImg\"" if ($UserBgImg);
	print ">\n";

	print "<center>\n";

	print "<table width=\"94%\" border=\"0\" ",
			"cellpadding=\"4\" cellspacing=\"0\" bgcolor=\"$UserLogBgColor\">\n";
	print "<tr><td align=\"center\">\n";
	print "[ <a href=\"$MyCGI\">戻る</a> ]\n" if ($DispLinktoTop);
	print "[ <a href=\"$HomeURL\">ホーム</a> ]\n";
	print "[ <a href=\"$AdminCgiUrl\">管理ページ</a> ]\n";
	print "</td></tr></table>\n";
	print "<br><br>\n";
	print "<p>\n";

	if ($UserTitleImg){
		print "<img src=\"$UserTitleImg\">\n";
	} else {
		print "<h1><font color=\"$UserTitleColor\">$UserTitle</font></h1>\n";
	}
}

###################################################################
#
#	HTML フッタ書き出し
#
###################################################################
sub PrintFooter
{
	print "</center>\n";

	# Copyright
	my $zuminURL  = 'http://zumin.cside9.com/zumin/';
	print "<hr size=\"2\" align=\"center\" noshade>\n";
	print "<div align=\"right\">\n";
	print "<address>CGI Script $CurrentVer &copy;2001- <a href=\"$zuminURL\" target=\"zumin\">Zumin</a></address>\n";
	print "</div>\n";

	# HTML END
	print "</body>\n";
	print "</html>\n";
}

###################################################################
#
#	エラー時HTML表示処理
#
###################################################################
sub PrintError
{
	print "<div><strong><font color=\"#FF0000\">\n";
	foreach (@ErrorMessage) { print "$_<br>\n"; }
	print "</font></strong></div>\n";
	print "<p>\n";
}

###################################################################
#
#	入力フォーム出力
#
###################################################################
sub PrintForm
{
	my ($p) = @_;
	my $subject = &Cdata($p->{subject});
	my $name    = &Cdata($p->{name});
	my $email   = &Cdata($p->{email});
	my $hpname  = &Cdata($p->{hpname});
	my $url     = ($p->{url} ne '') ? &Cdata($p->{url}) : 'http://';
	my $body    = &Cdata($p->{body});
	my $sex     = ($p->{sex} == 1)  ? 1 : 0;
	my $icon    = ($p->{icon} > 0)  ? $p->{icon}  : 1;
	my $fgcol   = ($p->{fgcol} > 0) ? $p->{fgcol} : 1;

	# 入力フォーム出力
	print "<table border=\"0\" cellpadding=\"3\" cellspacing=\"3\">\n";
	print "<form method=\"POST\" action=\"$MyCGIp\">\n";
	if ($p->{command} eq 'res') {
		print "\t<input type=\"hidden\" name=\"command\" value=\"res\">\n";
		print "\t<input type=\"hidden\" name=\"serial\" value=\"$p->{serial}\">\n";
		print "\t<input type=\"hidden\" name=\"resnumber\" value=\"$p->{resnumber}\">\n";
	}

	# 名前
	print "<tr>\n";
	print "<th align=\"right\" nowrap>お名前</th>\n";

	print "\t<td>\n";
	print "\t\t<input type=\"text\" name=\"name\" size=\"30\" " .
									"value=\"$name\" maxlength=\"80\">\n";
	# 性別
	print "\t\t&nbsp;&nbsp\n";
	print "\t\t<input type=\"radio\" name=\"sex\" value=\"0\"";
	unless ($sex == 1) { print " checked"; }
	print "><strong>男性</strong>\n";
	print "\t\t<input type=\"radio\" name=\"sex\" value=\"1\"";
	if ($sex == 1) { print " checked"; }
	print "><strong>女性</strong>\n";

	print "\t</td>\n";
	print "</tr>\n";

	# E-Mail
	print "<tr>\n";
	print "\t<th align=\"right\" nowrap>E-MAIL</th>\n";
	print "\t<td><input type=\"text\" name=\"email\" size=\"58\" " .
								"value=\"$email\" maxlength=\"100\"></td>\n";
	print "</tr>\n";

	# HP-NAME
	print "<tr>\n";
	print "\t<th align=\"right\" nowrap>HP-NAME</th>\n";
	print "\t<td><input type=\"text\" name=\"hpname\" size=\"58\" " .
								"value=\"$hpname\" maxlength=\"100\"></td>\n";
	print "</tr>\n";

	# URL
	print "<tr>\n";
	print "\t<th align=\"right\" nowrap>URL</th>\n";
	print "\t<td><input type=\"text\" name=\"url\" size=\"58\" " .
								"value=\"$url\" maxlength=\"100\"></td>\n";
	print "</tr>\n";

	# アイコン
	my $icon_cnt = @UserLogIcon;
	if ($icon_cnt > 0) {
		print "<tr>\n";
		print "\t<th align=\"right\" nowrap>好きなアイコン</th>\n";
		print "\t<td>\n";
		for my $i (1 .. $icon_cnt) {
			my $src = $UserLogIcon[$i - 1];
			print "\t\t<input type=\"radio\" name=\"icon\" value=\"$i\"";
			print " checked" if ($icon == $i);
			print "><img src=\"$src\">\n";
			print "\t\t<br>\n" if (($i % 5) == 0 && $i < $icon_cnt);
		}
		print "\t</td>\n";
		print "</tr>\n";
	}

	# 文字色
	if (@UserLogColor > 0) {
		print "<tr>\n";
		print "\t<th align=\"right\" nowrap>文字の色</th>\n";
		print "\t<td nowrap>\n";
		for my $i (1 .. @UserLogColor) {
			my $col = $UserLogColor[$i - 1];
			print "\t\t<input type=\"radio\" name=\"fgcol\" value=\"$i\"";
			print " checked" if ($fgcol == $i);
			print "><font color=\"$col\">● </font>\n";
		}
		print "\t</td>\n";
		print "</tr>\n";
	}

	# タイトル
	print "<tr>\n";
	print "\t<th align=\"right\" nowrap>タイトル</th>\n";
	if ($p->{command} eq 'res') {
		print "\t<td>\n";
		print "\t<input type=\"hidden\" name=\"subject\" value=\"$subject\">\n";
		print "\t<strong>$subject</strong>\n";
		print "\t</td>\n";
	} else {
		print "\t<td><input type=\"text\" name=\"subject\" size=\"50\" " .
									"value=\"$subject\" maxlength=\"50\"></td>\n";
	}
	print "</tr>\n";

	# メッセージ本文
	print "<tr>\n";
	print "\t<td colspan=\"2\">\n";
	print "\t<textarea cols=\"70\" rows=\"8\" name=\"body\">$body</textarea>\n";
	print "\t</td>\n";
	print "</tr>\n";

	# 削除キーボタン
	print "<tr>\n";
	print "\t<td colspan=\"2\" align=\"right\">\n";
	print "\t<strong>削除キー</strong>";
	print "<input type=\"text\" name=\"delkey\" size=\"8\" value=\"\" maxlength=\"8\">\n";
	print "\t</td>\n";
	print "</tr>\n";

	# 送信ボタン
	print "<tr>\n";
	print "\t<td colspan=\"2\" align=\"center\">\n";
	print "\t<input type=\"submit\" value=\"送信\">\n";
	print "\t<input type=\"reset\"  value=\"リセット\">\n";
	print "\t</td>\n";
	print "</tr>\n";

	print "</form>\n";
	print "</table>\n";
	print "<br>\n";
	print "<br>\n";
	print "<p>\n";
}

###################################################################
#
#	書き込まれたメッセージログの読み込みと出力
#
###################################################################
sub PrintLog
{
	my ($p) = @_;

	# メッセージログデータの読み込み
	my %logdata = &GetLogData();
	my $total   = $MessageDispCount1;

	# 最大ページ数
	my $pagemax = int(($total - 1) / $LogDisplayCount) + 1;

	# 表示ページ
	my $page = ($p->{page} < 1) ? 1 : $p->{page};

	# 表示するログ件数範囲、ページ数の調整
	my $disp_low = ($page - 1) * $LogDisplayCount + 1;
	if ($disp_low > $total) {
		$page = $pagemax;
		$disp_low = ($page - 1) * $LogDisplayCount + 1;
	}
	my $disp_high = $disp_low + $LogDisplayCount;

	# -------------------------------
	#	書き込みされたログの表示
	# -------------------------------
	print "<table border=\"0\" width=\"100%\" cellpadding=\"8\" cellspacing=\"8\">\n";
	my $cur_align = 0;
	my $lineno = 0;
	for my $k (sort LogKeyCmpare keys %logdata) {

		my $d = $logdata{$k};

		# 削除フラグチェック
		if ($d->{deleted}) { next; }

		# ログ番号カウントアップ
		$lineno++;

		# 表示ログ番号チェック
		if ($lineno < $disp_low)   { next; }
		if ($lineno >= $disp_high) { last; }

		# -------------------------------
		#	投稿ログ一件分出力
		# -------------------------------
		if ($Snake) {
			my $align_no = $cur_align % 4;
			if ($align_no == 0)     { print "<tr><td align=\"left\">\n"; }
			elsif ($align_no == 1 ) { print "<tr><td align=\"center\">\n"; }
			elsif ($align_no == 3 ) { print "<tr><td align=\"center\">\n"; }
			else                    { print "<tr><td align=\"right\">\n"; }
			$cur_align++;
		} else {
			print "<tr><td align=\"center\">\n";
		}

		# 書込みログ表示
		&PrintLogData($d);

		print "</td></tr>\n";
	}
	print "</table>\n";
	print "<p>\n";

	# -------------------------------
	#	処理ボタン類の表示
	# -------------------------------
	&PrintPageButton($page, $pagemax);
	print "<p>\n";
}

###################################################################
#
#	書き込まれたメッセージログ一件分出力
#
###################################################################
sub PrintLogData
{
	my ($d, $no_command) = @_;
	my $serial    = &Cdata($d->{serial});
	my $resnumber = &Cdata($d->{resnumber});
	my $date      = &Cdata($d->{date});
	my $time      = &Cdata($d->{time});
	my $subject   = &Cdata($d->{subject});
	my $name      = &Cdata($d->{name});
	my $email     = &Cdata($d->{email});
	my $hpname    = &Cdata($d->{hpname});
	my $url       = &Cdata($d->{url});
	my $body      = $d->{body};
	my $sex       = ($d->{sex} == 1) ? 1 : 0;
	my $fgcol     = ($d->{fgcol} > 0 && $d->{fgcol} <= @UserLogColor)
							? $UserLogColor[$d->{fgcol} - 1] : '#000000';
	my $icon      = ($d->{icon}  > 0 && $d->{icon}  <= @UserLogIcon)
							? $d->{icon} : 1;

	# 本文の改行コード、Cdata変換
	$body =~ s/<br>/\n/g;
	$body =  &Cdata($body);
	$body =~ s/\n/<br>/g;

	# 本文のURLをアンカーに変換
	$body = &SetHtmlAnker($body);

	# 書き込まれたメッセージログ一件分出力
	my $width = '90%';	if ($Snake) { $width = '85%'; }
	my $bgcol = $UserLogBgColor; if ($resnumber) { $bgcol = $UserLogResBgColor; }
	print "<table border=\"0\" width=\"$width\" ",
						"cellpadding=\"5\" cellspacing=\"0\"  bgcolor=\"$bgcol\">\n";

	# ----------------------
	#	１行目
	# ----------------------
	print "<tr><td>\n";

	# シリアル番号
	if ($resnumber == 0) {
		print "\t<small>No. $serial</small>\n";
		print "\t&nbsp;\n";
	} else {
		print "\t<small>返信→ No. $serial</small>\n";
		print "\t&nbsp;\n";
	}

	# タイトル
	print "\t<strong><font color=\"$fgcol\">$subject</font></strong>\n";
	print "\t&nbsp;\n";

	# 名前
	my $namecolor = ($sex) ? '#FF0000' : '#0000FF';
	print "\t<strong><font color=\"$namecolor\">$name</font></strong>\n";
	print "\t<small><font color=\"$fgcol\">さんより</font></small>\n";
	print "\t&nbsp;\n";

	# 投稿時刻
	print "\t<small><font color=\"$fgcol\">$date&nbsp;$time</font></small>\n";
	print "\t&nbsp;\n";

	# メールアドレス
	if ($email ne '') {
		print "\t<a href=\"mailto:$email\">",
				"<img src=\"$UserLogMailIcon\" align=\"middle\" width=\"20\" height=\"15\">",
				"</a>\n";
	}
	# HPアドレス
	if ($url ne '') {
		print "\t<a href=\"$url\" target=\"_guest\">" ,
				"<img src=\"$UserLogHomeIcon\" align=\"middle\" width=\"20\" height=\"15\">" ,
				"</a>\n";
		if ($hpname ne '') {
			print "\t&nbsp;";
			print "<small><a href=\"$url\" target=\"_guest\">$hpname</a></small>\n";
		}
	}
	print "</td></tr>\n";

	# ----------------------
	#	２行目
	# ----------------------
	print "<tr><td>\n";
	print "\t<table border=\"0\" cellpadding=\"4\" cellspacing=\"0\">\n";
	print "\t<tr>\n";

	# 選択されたアイコン
	# アイコン画像ファイルHTML
	my $iconfile  = $UserLogIcon[$icon - 1];
	if ($iconfile) {
		my $iconfile = $UserLogIcon[$icon - 1];
		print "\t\t<td width=\"58\" nowrap valign=\"top\" align=\"left\">\n";
		print "\t\t<img src=\"$iconfile\">\n";
		print "\t\t</td>\n";
	} else {
		print "\t\t<td width=\"54\"><br></td>\n";
	}

	# メッセージ本体
	print "\t\t<td><font color=\"$fgcol\">$body</font></td>\n";

	print "\t</tr>\n";
	print "\t</table>\n";
	print "</td></tr>\n";

	unless ($no_command) {
		# ----------------------
		#	３行目
		# ----------------------
		print "<tr><td align=\"right\">\n";
		&PrintDataCommandButton($serial, $resnumber);
		print "</td></tr>\n";
	}

	print "</table>\n";
}

###################################################################
#
#	投稿ログ一覧リストに表示するページング出力
#
###################################################################
sub PrintPageButton
{
	my ($cur_page, $pagemax) = @_;

	print "<table width=\"98%\" border=\"0\" cellpadding=\"1\" cellspacing=\"1\">\n";
	print "<tr>\n";
	print "<td width=\"5%\" align=\"right\"><strong>Page: </strong></td>\n";
	print "<td align=\"left\">";
	for (my $i = 1; $i <= $pagemax ; $i++) {
		if ($i == $cur_page) {
			print "<strong>&nbsp;${i}&nbsp;</strong>";
		} else {
			print "<a href=\"$MyCGI?page=$i\">&nbsp;${i}&nbsp;</a>";
		}
	}
	print "</td>\n";
	print "</tr>\n";
	print "</table>\n";
}

###################################################################
#
#	投稿ログ一覧の各投稿データ毎コマンドボタン出力
#
###################################################################
sub PrintDataCommandButton
{
	my ($serial, $resnumber) = @_;

	print "<table border=\"0\" cellpadding=\"1\" cellspacing=\"1\">\n";
	print "<tr>\n";

	if ($resnumber == 0) {
		print "<td>\n";
		print "<form method=\"GET\" action=\"$MyCGI\">\n";
		print "\t<input type=\"hidden\" name=\"command\" value=\"res\">\n";
		print "\t<input type=\"hidden\" name=\"serial\" value=\"$serial\">\n";
		print "\t<input type=\"hidden\" name=\"resnumber\" value=\"$resnumber\">\n";
		print "\t<input type=\"submit\" value=\"返信\">\n";
		print "</form>\n";
		print "</td>\n";
	}
	print "<td>\n";
	print "<form method=\"GET\" action=\"$MyCGI\">\n";
	print "\t<input type=\"hidden\" name=\"command\" value=\"delete\">\n";
	print "\t<input type=\"hidden\" name=\"serial\" value=\"$serial\">\n";
	print "\t<input type=\"hidden\" name=\"resnumber\" value=\"$resnumber\">\n";
	print "<input type=\"submit\" value=\"削除\">\n";
	print "</form>\n";
	print "</td>\n";

	print "</tr>\n";
	print "</table>\n";
}

###################################################################
#
#	削除キー入力フォーム出力
#
###################################################################
sub PrintDeleteKeyForm
{
	my ($p) = @_;
	my $serial    = &Cdata($p->{serial});
	my $resnumber = &Cdata($p->{resnumber});

	print "<h3>削除してよければ削除キーを入力してください。</h3>\n";

	print "<table border=\"0\" cellpadding=\"1\" cellspacing=\"1\">\n";
	print "<tr>\n";

	print "<td>\n";
	print "<form method=\"POST\" action=\"$MyCGIp\">\n";
	print "\t<input type=\"hidden\" name=\"command\" value=\"delete\">\n";
	print "\t<input type=\"hidden\" name=\"serial\" value=\"$serial\">\n";
	print "\t<input type=\"hidden\" name=\"resnumber\" value=\"$resnumber\">\n";
	print "<input type=\"text\" name=\"delkey\" size=\"8\" value=\"\" maxlength=\"8\">\n";
	print "<input type=\"submit\" value=\"削除実行\">\n";
	print "</form>\n";
	print "</td>\n";

	print "</tr>\n";
	print "</table>\n";
}

###################################################################
1
