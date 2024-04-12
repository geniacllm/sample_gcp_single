# 最初だけログイン必須。Write権限のaccess tokenかどうかを確認すること。
from huggingface_hub import login
login()

# tokenizerを読み込む
from transformers import DebertaV2Tokenizer
tokenizer_deberta = DebertaV2Tokenizer(
    vocab_file  = "/persistentshare/storage/team_kumagai/tokenizer/swallow/tokenizer.model",
    max_len = 512,
)

# レポ指定してアップロード
repo_name = "Your HF repo"
tokenizer_deberta.push_to_hub(repo_name)
