#!/bin/bash

# ディレクトリパスを変数として保存します。
ucllm_nedo_dev_train_dir="${HOME}/ucllm_nedo_dev/train"
megatron_deepspeed_dir="${ucllm_nedo_dev_train_dir}/Megatron-DeepSpeed"
input_tokenizer_file="/persistentshare/storage/team_kumagai/tokenizer/swallow/tokenizer.model"

data_path="/persistentshare/storage/team_kumagai/datasets/model_data/wiki40bja/"

if [ ! -f "${data_path}.bin" ] || [ ! -f "${data_path}.idx" ]; then
    echo "Either ${data_path}.bin or ${data_path}.idx doesn't exist yet, so download arxiv.jsonl and preprocess the data."
    python ${megatron_deepspeed_dir}/tools/preprocess_data.py \
        --tokenizer-type SentencePieceTokenizer \
        --tokenizer-model ${input_tokenizer_file} \
        --input ${data_path}/output.jsonl \
        --output-prefix ${megatron_deepspeed_dir}/dataset/wikipedia \
        --dataset-impl mmap \
        --workers $(grep -c ^processor /proc/cpuinfo) \
        --append-eod
else
    echo "Both ${data_path}.bin and ${data_path}.idx already exist."
fi
echo ""