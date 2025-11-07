# CodeGeex的rust编写
这是2023左右编写的 现在来做个笔录
## 模型的结构
我们关注Config结构体
```rust
pub struct Config {
	/// Transformer 层数
    pub num_layers: usize,
	/// 对齐后词汇表大小
    pub padded_vocab_size: usize,
	/// 隐藏层维度
    pub hidden_size: usize,
	/// 前馈网络的内部维度
    pub ffn_hidden_size: usize,
	/// 每个注意头的维度
    pub kv_channels: usize,
	/// 注意力头数
    pub num_attention_heads: usize,
	/// 序列长度
    pub seq_length: usize,
	/// LayerNorm的epsilon值(防止除以0)
    pub layernorm_epsilon: f64,
	/// 是否用RMSNorm代替LayerNorm
    pub rmsnorm: bool,
	/// 残差连接位置
    pub apply_residual_connection_post_layernorm: bool,
	/// 是否使用Post-LN
    pub post_layer_norm: bool,
	/// 全连接层是否偏置
    pub add_bias_linear: bool,
	/// Q/K/V是否有偏置
    pub add_qkv_bias: bool,
	///是否融合偏置+dropout
    pub bias_dropout_fusion: bool,
	/// 是否使用多查询注意力
    pub multi_query_attention: bool,
	/// 多查询注意力中共享kv的组数
    pub multi_query_group_num: usize,
	/// 是否额外缩放QK
    pub apply_query_key_layer_scaling: bool,
	/// softmax是否在fp32精度
    pub attention_softmax_in_fp32: bool,
	/// 残差连接是否保持FP32
    pub fp32_residual_connection: bool,
    #[serde(default = "default_one")]
	/// 旋转位置编码(RoPE)比例系数
    pub rope_ratio: usize,
}
```
