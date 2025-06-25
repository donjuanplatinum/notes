# PGP
Pretty Good Privacy ( PGP ) 是一款加密程序，为数据通信提供加密 隐私和身份验证。

## 设计
PGP 加密采用散列算法、数据压缩、对称密钥加密以及公钥加密的一系列组合；每一步都使用几种受支持的算法之一。每个公钥都与一个用户名或电子邮件地址绑定。该系统的第一个版本通常被称为信任网 (Web of Trust)，与X.509系统形成对比。X.509系统采用基于证书颁发机构的分层方法，后来被添加到 PGP 实现中。PGP 加密的当前版本包含通过自动密钥管理服务器的选项。

### 加密解密与签名过程
`加密解密过程简单来说就是 我用你给我的锁(你的pubkey)锁门 你用你的钥匙(你的privkey)开门`
`签名与验证过程就是 我盖了个章(我的privkey) 你对照我公布的章的样子(我的pubkey)验证章是不是我盖的`

签名的过程中 先计算文件的摘要 例如哈希值 然后用你的privkey加密哈希值 加密后的哈希值就是签名

### 对称与非对称
当文件很大时gpg会混用对称与非对称: gpg先使用对称密钥加密文件 然后用非对称密钥加密对称密钥 
当使用-c时 仅使用对称加密
### 签名密钥
对密钥进行签名代表 `我验证过这个公钥确实属于该用户 其他人可以信任它`
### 信任等级
定义你对其他用户公钥的信任程度 分为两类
- 对密钥的信任 你对密钥持有者的信任程度
- 对签名的信任 你对其他人对该密钥的信任程度
等级 1 未知 2 不信任 3 边际信任 4 完全信任 5 最终信任(仅自己)
gpg会验证 一个密钥 1. 是否被足够多你信任的用户签名 2. 这些签名者的信任级别
### 指纹
公钥指纹是公钥的缩写。通过指纹，人们可以验证对应的公钥是否正确。像 C3A6 5E46 7B54 77DF 3C4C 9790 4D22 B3CA 5B32 FF66 这样的指纹可以印在名片上。 一般为40位16进制


## 词汇
sec 私钥
sub 子公钥
ssb 子私钥
fingerprint 指纹
## 功能
公钥部分 验证 加密[E]
私钥部分 认证[C] 签名[S] 解谜
## 使用
1. 生成密钥
```shell
gpg --gen-key
```

2. 生成吊销证书
```shell
gpg --gen-revoke [ID]
```

3. 列出密钥
```shell
gpg --list-keys
```

4. 删除密钥
```shell
gpg --delete-key [ID]
```

5. 输出密钥
公钥
```shell
gpg --armor --output pubkey --export [ID]
```

私钥
```shell
gpg --armor --output privkey --export-secret-keys

6. 公钥服务器
上传
```shell
gpg --send-keys [ID] --keyserver hkp://subkeys.pgp.net
```

查询
```shell
gpg --keyserver hkp://subkeys.pgp.net --search-keys [user ID]
```


7. 指纹
生成公钥指纹
```shell
gpg --fingerprint [ID]
```


8. 导入密钥
```shell
gpg --import [keyfile]
```

9. 加密解密签名
加密
```shell
gpg --recipient [userid] --output outputfile.en --encrypt inputfile
```

解密
```shell
gpg --decrypt inputfile --output outputfile
```

签名
```shell
gpg --sign file # 二进制
gpg --clearsign file # ascii
gpg --detach-sign file # 分开存放签名文件 二进制
gpg --armor --detach-sign  file # 分开存放签名文件 ascii
```

验证签名
```shell
gpg --verify asc file
```
10. 子密钥
实际中 一般主密钥只参与签名[S]与认证[C] 加密[E]由子密钥(sub)执行


## 选项
-s --sign 签名
--clear-sign 明文签名
-b --detach-sign 分离签名
-e --encrypt 加密
-c --symmetric 仅对称加密
-d --decrypt 解密
--verify 验证签名
-k --list-secret-keys 列出密钥
 -K, --list-secret-keys             列出私钥
     --generate-key                 生成一个新的密钥对
     --quick-generate-key           快速生成一个新的密钥对
     --quick-add-uid                快速添加一个新的用户标识
     --quick-revoke-uid             快速吊销一个用户标识
     --quick-set-expire             快速设置一个过期日期
     --full-generate-key            完整功能的密钥对生成
     --generate-revocation          生成一份吊销证书
     --delete-keys                  从公钥钥匙环里删除密钥
     --delete-secret-keys           从私钥钥匙环里删除密钥
     --quick-sign-key               快速签名一个密钥
     --quick-lsign-key              快速本地签名一个密钥
     --quick-revoke-sig             快速吊销一个密钥签名
     --sign-key                     签名一个密钥
     --lsign-key                    本地签名一个密钥
     --edit-key                     签名或编辑一个密钥
     --change-passphrase            更改密码
     --export                       导出密钥
     --send-keys                    将密钥导出到一个公钥服务器上
     --receive-keys                 从公钥服务器上导入密钥
     --search-keys                  在公钥服务器上搜索密钥
     --refresh-keys                 从公钥服务器更新所有密钥
     --import                       导入/合并密钥
     --card-status                  打印卡片状态
     --edit-card                    更改卡片上的数据
     --change-pin                   更改卡片的 PIN
     --update-trustdb               更新信任数据库
     --print-md                     打印消息摘要
     --server                       以服务器模式运行
     --tofu-policy VALUE            设置一个密钥的 TOFU 政策


