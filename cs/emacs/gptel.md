# GPTel
在Emacs中使用GPT
## 模型配置
```emacs-lisp
(gptel-make-anthropic "Claude" :stream t :key gptel-api-key)
```

gptel支持的LLM
| LLM               |
|-------------------|
| ChatGPT           |
| Anthropic(Claude) |
| Gemini            |
| Ollama            |
| Open WebUI        |
| Llama.cpp         |
| Llamafile         |
| GPT4ALL           |
| DeepSeek                  |


## 命令
- gptel-send: 将选择区的文本发送给GPT 并在选择区的下面生成回答
- C-u M-x gptel-send: 额外设置的gpt-send
- gptel-rewrite: 重写该位置
