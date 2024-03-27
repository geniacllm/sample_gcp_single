import sentencepiece as spm

# モデルのロード
sp = spm.SentencePieceProcessor()
sp.Load("/persistentshare/storage/team_kumagai/tokenizer/swallow/tokenizer.model")

# モデルのテスト
text = "Geminiの作成したニュースです。盲導犬の介助でピアノ演奏会デビュー！視覚障がいを持つ少女の夢が叶う。福岡県在住の視覚障がいを持つ10歳の少女、佐藤美咲さんが、盲導犬の介助を受けながらピアノ演奏会デビューを果たしました。美咲さんは幼い頃からピアノに夢中でしたが、視覚障碍のため楽譜を読むことが困難でした。しかし、盲導犬の「ライト」と共に練習を重ね、ついに念願の舞台に立つことができました。"
print(text)
print(sp.EncodeAsPieces(text)
