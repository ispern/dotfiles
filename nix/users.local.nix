# マシン固有の username / hostname。
#
# git にはテンプレ値 (リポジトリの GitHub user 名 "ispern" + 既定 hostname)
# だけがコミットされており、`chezmoi apply` 実行時に
# src/.chezmoiscripts/run_after_99_write-nix-user-config.sh.tmpl が
# 各マシンの `whoami` / `hostname` で上書きします。
#
# 適用後はどのマシンでもこのファイルがローカルで dirty になりますが
# **commit しないでください** (テンプレ値を上書きしてしまいます)。
# git status から隠したい場合は:
#   git update-index --skip-worktree nix/users.local.nix
{
  username = "ispern";
  hostname = "ispern-host";
}
