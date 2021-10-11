# aws-terraform
## aws credentialの準備
- https://qiita.com/Chanmoro/items/55bf0da3aaf37dc26f73
- 既存ユーザーからaccessKeyを作成・ダウンロードした場合の手順
```sh
## ダウンロードしたファイルの改行コードが\r\n(^M$)なので
## それをawkで^Mの改行が残らないよう改行コードを\nのみに変更する

# ファイルの拡張子を確認
file ~/Downloads/{accessKeysのファイル名} | grep --color=auto CRLF 
## 私がダウンロードした際の改行コードはCRFLだったため変換が必要

# 改行コードを\nに変換してファイル名・保存場所を変更
## nkf -Luコマンドで改行コードをCRLFから LFに変換する
## 改行コードがLFであっても実行コマンドは変わらずファイル名・保存場所を変更する
nkf -Lu ~/Downloads/{accessKeysのファイル名} > accessKeys.csv

# ~/.aws/credentialsへ指定したプロファイル名で登録
## https://github.com/aws/aws-cli/issues/1201#issuecomment-745439327
## 上記参考コマンドを一部修正したawkコマンドを使ったスクリプトファイルをファイルを実行する
awk -f aws-import-credentials-csv {任意のプロファイル名} < accessKeys.csv >> ~/.aws/credentials

# 任意のプロファイル名で認証情報が登録されているか確認
cat ~/.aws/credentials
```
# aws provider version
- https://registry.terraform.io/providers/hashicorp/aws/latest