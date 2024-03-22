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

