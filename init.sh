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
cd ~/ucllm_nedo_dev/train/
# Megatron-DeepSpeedのレポジトリをクローン。
git clone https://github.com/hotsuyuki/Megatron-DeepSpeed
# mainブランチではエラーが起きる場合があるため、指定のタグにチェックアウト。
cd ~/ucllm_nedo_dev/train/Megatron-DeepSpeed/ && git fetch origin && git checkout refs/tags/ucllm_nedo_dev_v20240205.1.0
# apexのレポジトリをクローン。
git clone https://github.com/NVIDIA/apex
cd ~/ucllm_nedo_dev/train/apex/ && git fetch origin && git checkout refs/tags/23.08

# 環境整備用のconda環境
mkdir -p ~/miniconda3/ && cd ~/miniconda3/
wget https://repo.anaconda.com/miniconda/Miniconda3-py310_23.10.0-1-Linux-x86_64.sh && bash Miniconda3-py310_23.10.0-1-Linux-x86_64.sh -b -u -p ~/miniconda3/

source ~/miniconda3/etc/profile.d/conda.sh
which conda && echo "====" && conda --version

# Step 0-2. Python仮想環境の作成
cd ~/ucllm_nedo_dev/train/

# Python仮想環境を作成。
conda create --name .venv python=3.9 -y

# Python仮想環境を有効化した時に自動で環境変数 `$LD_LIBRARY_PATH` を編集するように設定。
mkdir -p ~/miniconda3/envs/.venv/etc/conda/activate.d
echo 'export ORIGINAL_LD_LIBRARY_PATH=$LD_LIBRARY_PATH' > ~/miniconda3/envs/.venv/etc/conda/activate.d/edit_environment_variable.sh
echo 'export LD_LIBRARY_PATH="$HOME/miniconda3/envs/.venv/lib:$LD_LIBRARY_PATH"' >> ~/miniconda3/envs/.venv/etc/conda/activate.d/edit_environment_variable.sh
chmod +x ~/miniconda3/envs/.venv/etc/conda/activate.d/edit_environment_variable.sh

# Python仮想環境を無効化した時に自動で環境変数 `$LD_LIBRARY_PATH` を元に戻すように設定。
mkdir -p ~/miniconda3/envs/.venv/etc/conda/deactivate.d
echo 'export LD_LIBRARY_PATH=$ORIGINAL_LD_LIBRARY_PATH' > ~/miniconda3/envs/.venv/etc/conda/deactivate.d/rollback_environment_variable.sh
echo 'unset ORIGINAL_LD_LIBRARY_PATH' >> ~/miniconda3/envs/.venv/etc/conda/deactivate.d/rollback_environment_variable.sh
chmod +x ~/miniconda3/envs/.venv/etc/conda/deactivate.d/rollback_environment_variable.sh
