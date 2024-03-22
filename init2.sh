#!/bin/bash

# Command line options go here
#SBATCH --partition=g2
#SBATCH --time=00:01:00
#SBATCH --nodes=1
#SBATCH --job-name=example
#SBATCH --output=example.out
#SBATCH --gpus-per-node=1

# インストールしたcondaを有効化。
source ~/miniconda3/etc/profile.d/conda.sh
which conda && echo "====" && conda --version
conda activate .venv

# Step 0-2. Python仮想環境の作成（差分）
cd ~/ucllm_nedo_dev/train/
conda install nvidia/label/cuda-11.8.0::cuda-toolkit
conda install pytorch==2.2.0 torchvision==0.17.0 torchaudio==2.2.0 pytorch-cuda=11.8 -c pytorch -c nvidia
which python && echo "====" && python --version

# 環境変数 `$PATH` に `$HOME/miniconda3/envs/.venv/bin` が含まれていることを確認。
echo $PATH | grep miniconda3/envs/.venv/bin

# 環境変数 `$LD_LIBRARY_PATH` に `$HOME/miniconda3/envs/.venv/lib` が含まれていることを確認。
echo $LD_LIBRARY_PATH | grep miniconda3/envs/.venv/lib

# Step 0-3. パッケージ等のインストール
cd ~/ucllm_nedo_dev/train/
pip install -r ~/ucllm_nedo_dev/train/requirements.txt
pip install deepspeed-kernels

# deepspeedを指定のバージョンでインストール。このとき、deepspeed関連の拡張機能たち "ops" を事前にビルドしておくために `DS_BUILD_OPS=1` と設定。 
# https://www.deepspeed.ai/tutorials/advanced-install/#pre-install-deepspeed-ops
# ※しばらく時間がかかるので注意。
DS_BUILD_OPS=1 DS_BUILD_EVOFORMER_ATTN=0 DS_BUILD_SPARSE_ATTN=0 pip install deepspeed==0.12.4

# deepspeed関連の拡張機能たち "ops" が正しくインストールされていることを確認。
ds_report | grep ops

# Step 0-4. Megatron-DeepSpeedのインストール
# Megatron-DeepSpeedをインストール。
cd ~/ucllm_nedo_dev/train/Megatron-DeepSpeed/ && python setup.py install

# Step 0-5. apexのインストール

