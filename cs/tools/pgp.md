# PGP
Pretty Good Privacy ( PGP ) 是一款加密程序，为数据通信提供加密 隐私和身份验证。

## 设计
PGP 加密采用散列算法、数据压缩、对称密钥加密以及公钥加密的一系列组合；每一步都使用几种受支持的算法之一。每个公钥都与一个用户名或电子邮件地址绑定。该系统的第一个版本通常被称为信任网 (Web of Trust)，与X.509系统形成对比。X.509系统采用基于证书颁发机构的分层方法，后来被添加到 PGP 实现中。PGP 加密的当前版本包含通过自动密钥管理服务器的选项。

### 指纹
公钥指纹是公钥的缩写。通过指纹，人们可以验证对应的公钥是否正确。像 C3A6 5E46 7B54 77DF 3C4C 9790 4D22 B3CA 5B32 FF66 这样的指纹可以印在名片上。 一般为40位16进制


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
