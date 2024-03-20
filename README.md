# sample_gcp_single
gcpプレ環境においてシングルGPUでの学習を実行するサンプルプログラム

## 前提
* Geniacプレ環境においてGCPにアクセスできること。
* 学習データが共有ディスクに保管されていること

### 参考：2FA登録後のprivate repositoryへのアクセスについて
* Github Personal access tokenを発行する
** Github > Settings > Developper settings > tokens(classic) > New personal access token (classic)
** ghp_から始まるものが入手できればOK

## 初回環境構築（初回のみ）
ログインサーバーにおいて以下を実行してください。
鋭意、作成中
```
cd ~
git clone https://github.com/geniacllm/sample_gcp_single.git
sbatch init.sh
```
