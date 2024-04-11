#!/bin/bash

# Command line options go here
#SBATCH --partition=g2
#SBATCH --time=02:00:00
#SBATCH --nodes=1
#SBATCH --job-name=moetre
#SBATCH --output=moetre.out
#SBATCH --gpus-per-node=4

# インストールしたcondaを有効化。
source ~/miniconda3/etc/profile.d/conda.sh
which conda && echo "====" && conda --version
conda activate .venv

bash ${HOME}/git/sample_gcp_single/script/pretrain_moe.sh
