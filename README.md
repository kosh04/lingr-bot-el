## Chatbot on Lingr

Lingr 上の発言に反応するボットです。

Emacs Webサーバライブラリ [Elnode](https://github.com/nicferrier/elnode) を
Heroku で動作させることを想定していますが、サーバ自体はローカルでも動作します。

- [Bot Profile](http://lingr.com/bot/emacs24)


## コマンド

- `M-x emacs-version` : 稼働している Emacs のバージョンを表示します
- `M-x uptime` : 稼働時間を表示します
- `C-h f FUNCTION` : 関数 FUNCTION のドキュメントを表示します
- `C-h v VARIABLE` : 変数 VARIABLE のドキュメントを表示します
- `!emacs EXPR` : EXPR を評価します


## 動作環境

- GNU Emacs 24+
- Elnode (それ以外の必要ライブラリは Cask を参照)
- Cask (optional)


## LICENSE

MIT License 
