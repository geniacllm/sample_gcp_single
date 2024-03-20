#!/bin/bash

# Command line options go here
#SBATCH --partition=g2
#SBATCH --time=00:01:00
#SBATCH --nodes=1
#SBATCH --job-name=init
#SBATCH --output=init.out
#SBATCH --gpus-per-node=1

# Command(s) goes here
nvidia-smi

# ベースライン実行のためのコード類のダウンロード
cd ~/
git clone https://github.com/matsuolab/ucllm_nedo_prod.git ~/ucllm_nedo_dev
git clone https://github.com/hotsuyuki/Megatron-DeepSpeed
mv ~/Megatron-DeepSpeed ~/ucllm_nedo_dev/train/
# mainブランチではエラーが起きる場合があるため、指定のタグにチェックアウト。
cd ~/ucllm_nedo_dev/train/Megatron-DeepSpeed/ && git fetch origin && git checkout refs/tags/ucllm_nedo_dev_v20240205.1.0

# 環境整備用のconda環境
mkdir -p ~/miniconda3/ && cd ~/miniconda3/
wget https://repo.anaconda.com/miniconda/Miniconda3-py310_23.10.0-1-Linux-x86_64.sh && bash Miniconda3-py310_23.10.0-1-Linux-x86_64.sh -b -u -p ~/miniconda3/

source ~/miniconda3/etc/profile.d/conda.sh
which conda && echo "====" && conda --version
