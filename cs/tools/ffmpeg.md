# FFMPEG
所有音频 视频 图片的瑞士军刀

## 基本使用
基本的转换
```shell
ffmpeg -i input.avi output.mp4
```

裁剪片段
```shell
# 从30秒截取到1分钟
ffmpeg -ss 00:00:30 -to 00:01:00 -i input -c copy clip.mp4
```

提取某一帧
```shell
# 提取第十秒
ffmpeg -ss 00:00:10 -i input -vframes 1 output.png
```

分辨率调整
```shell
# 调整input为1920*1080
ffmpeg -i input -vf "scale=1920:1080" output
```

变速
```shell
# 二倍速
ffmpeg -i input -filter:v "setpts=0.5*PTS" 
```

视频压缩
```shell
# crf为0-51的质量等级 越小越好
ffmpeg -i input -vcodec libx264 -crf 23 output
```

音频压缩
```shell
ffmpeg -i input -b:a 192k output
```

查看媒体的信息
```shell
ffmpeg -i input
```

元数据修改
```shell
ffmpeg -i music.flac -metadata artist="artist" output
```
## 选项
| 选项   | 意义 |
|--------|------|
| -vcode | 指定编码器     |
## 媒体
### 编码器
编码器决定了视频的编码和解码方式

编码器的目的就是压缩视频体积 同时尽量保持画质

常见的视频编码器
| 编码器       | 标准      | 特点                    |
|--------------|-----------|-------------------------|
| libx264      | H264      | 主流 高效 兼容性好      |
| libx265      | H265/HEVC | 压缩更高 CPU占用更大    |
| libvpx-vp9   | VP9       | 开源 WEB友好            |
| libaom-av1   | AV1       | 新一代超高压缩率 速度慢 |
| png/rawvideo | 不压缩    | 大                        |

音频编码器
| 编码器 | 标准 | 特点 |
|--------|------|------|
|        |      |      |
