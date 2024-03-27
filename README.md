# sample_gcp_single
gcpプレ環境においてシングルGPUでの学習を実行するサンプルプログラム

## 前提
- Geniacプレ環境においてGCPにアクセスできること。
- 学習データが共有ディスクに保管されていること
  - /persistentshare/storage/team_kumagai/

### 参考：2FA登録後のprivate repositoryへのアクセスについて
- Github Personal access tokenを発行する
  - Github > Settings > Developper settings > tokens(classic) > New personal access token (classic)
  - repoに全部チェックをつける。cloneだけなので他は不要。
  - ghp_から始まるものが入手できればOK

## 全体の流れ
- init.shを参考に仮想環境を構築する。（bash init.shでは途中でうまくいかない）
- srunで計算環境にアクセスする
- 仮想環境を呼び出す
- トークナイザーをトレーニングする（データが不明だったので、一旦swallowを利用する）
- 学習用データセットをトークナイザでbinとidxにする。
- 学習スタート
