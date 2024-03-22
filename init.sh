#!/bin/bash

# Command line options go here
#SBATCH --partition=g2
#SBATCH --time=00:01:00
#SBATCH --nodes=1
#SBATCH --job-name=init
#SBATCH --output=init.out
#SBATCH --gpus-per-node=1

# Step 0-0. ベースライン実行のための環境確認
nvidia-smi

# Step 0-1. ベースライン実行のためのコード類のダウンロード
# ベースライン ucllm_nedo_dev
cd ~/
git clone https://github.com/matsuolab/ucllm_nedo_prod.git ~/ucllm_nedo_dev

# 作業ディレクトリに移動
cd ~/ucllm_nedo_dev/train/

# Megatron-DeepSpeedのレポジトリをクローン。
git clone https://github.com/hotsuyuki/Megatron-DeepSpeed
cd ~/ucllm_nedo_dev/train/Megatron-DeepSpeed/ && git fetch origin && git checkout refs/tags/ucllm_nedo_dev_v20240205.1.0

# apexのレポジトリをクローン。
git clone https://github.com/NVIDIA/apex
cd ~/ucllm_nedo_dev/train/apex/ && git fetch origin && git checkout refs/tags/23.08

# llm-jp-sftのレポジトリをクローン。
git clone https://github.com/hotsuyuki/llm-jp-sft
cd ~/ucllm_nedo_dev/train/llm-jp-sft/ && git fetch origin && git checkout refs/tags/ucllm_nedo_dev_v20240208.1.0

# Step 0-2. Python仮想環境の作成
mkdir -p ~/miniconda3/ && cd ~/miniconda3/
wget https://repo.anaconda.com/miniconda/Miniconda3-py310_23.10.0-1-Linux-x86_64.sh && bash Miniconda3-py310_23.10.0-1-Linux-x86_64.sh -b -u -p ~/miniconda3/

source ~/miniconda3/etc/profile.d/conda.sh
which conda && echo "====" && conda --version

# Python仮想環境を作成。(Python 3.9)
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

cd ~/ucllm_nedo_dev/train/
# Python仮想環境を有効化して、各種パッケージをインストール。
conda activate .venv
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
# nvccが対応しているCUDAのバージョンとPyTorchが依存しているCUDAのバージョンが一致していることを確認。
which nvcc && echo "====" && nvcc --version && echo "====" && python -c "import torch; print(torch.__version__)"

# pipのバージョンが23.1以上であることを確認。
which pip && echo "====" && pip --version

# pipのバージョンが23.1以上の場合のインストール方法で、apexをインストール。
# ※しばらく時間がかかるので注意。
cd ~/ucllm_nedo_dev/train/apex/ && pip install -v --disable-pip-version-check --no-cache-dir --no-build-isolation --config-settings "--build-option=--cpp_ext" --config-settings "--build-option=--cuda_ext" ./

# apexがインストールされていることを確認。
pip list | grep "apex"

# apex_C.cpython-39-x86_64-linux-gnu.soが作成されていることを確認。
find ~/ucllm_nedo_dev/train/apex/build/lib.linux-x86_64-cpython-39/ -name apex_C.cpython-39-x86_64-linux-gnu.so

# Step 0-6. Flash Attention 2のインストール
# Flash Attention 2のインストールに必要なninjaを念のため再インストール。
pip uninstall ninja -y && pip install ninja==1.11.1

# Flash Attention 2をインストール。
pip install flash-attn==2.5.0 --no-build-isolation

# Flash Attention 2.5がインストールされていることを確認。
pip list | grep "flash-attn"
