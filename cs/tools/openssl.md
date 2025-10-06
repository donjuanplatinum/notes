# OpenSSL
加密工具
- SSl证书管理
- 加密/解密
- 生成密钥对
- SSL测试
- 计算Hash
- 签名验证
## 子命令
| command | 含义                             |
|---------|----------------------------------|
| genrsa  | 生成rsa私钥                      |
| req     | 生成CSR和自签名证书              |
| x509    | 处理X.509证书                    |
| rsa     | 处理RSA密钥(转换格式 提取公钥等) |
| enc     | 对称加密/解密(AES,DES等)         |
| dgst    | 计算文件Hash(MD5,SHA等)          |
| rand    | 生成随机数                       |
| passwd  | 加密密码                                 |
	

### enc子命令
| arg   | 含义 |
|-------|------|
| -salt | 加盐 |
| -d    | 解密 |
| -e    | 加密 |
### dgst子命令
| arg   | 含义       |
|-------|------------|
| -sign | 带私钥签名 |
|       |            |
## 支持的算法
### dgst
```
blake2b512        blake2s256        md4               md5               
mdc2              rmd160            sha1              sha224            
sha256            sha3-224          sha3-256          sha3-384          
sha3-512          sha384            sha512            sha512-224        
sha512-256        shake128          shake256          sm3        
```
### enc
```
aes-128-cbc       aes-128-ecb       aes-192-cbc       aes-192-ecb       
aes-256-cbc       aes-256-ecb       aria-128-cbc      aria-128-cfb      
aria-128-cfb1     aria-128-cfb8     aria-128-ctr      aria-128-ecb      
aria-128-ofb      aria-192-cbc      aria-192-cfb      aria-192-cfb1     
aria-192-cfb8     aria-192-ctr      aria-192-ecb      aria-192-ofb      
aria-256-cbc      aria-256-cfb      aria-256-cfb1     aria-256-cfb8     
aria-256-ctr      aria-256-ecb      aria-256-ofb      base64            
bf                bf-cbc            bf-cfb            bf-ecb            
bf-ofb            camellia-128-cbc  camellia-128-ecb  camellia-192-cbc  
camellia-192-ecb  camellia-256-cbc  camellia-256-ecb  cast              
cast-cbc          cast5-cbc         cast5-cfb         cast5-ecb         
cast5-ofb         des               des-cbc           des-cfb           
des-ecb           des-ede           des-ede-cbc       des-ede-cfb       
des-ede-ofb       des-ede3          des-ede3-cbc      des-ede3-cfb      
des-ede3-ofb      des-ofb           des3              desx              
idea              idea-cbc          idea-cfb          idea-ecb          
idea-ofb          rc2               rc2-40-cbc        rc2-64-cbc        
rc2-cbc           rc2-cfb           rc2-ecb           rc2-ofb           
rc4               rc4-40            rc5               rc5-cbc           
rc5-cfb           rc5-ecb           rc5-ofb           seed              
seed-cbc          seed-cfb          seed-ecb          seed-ofb          
sm4-cbc           sm4-cfb           sm4-ctr           sm4-ecb           
sm4-ofb           

```
## 密钥
```
openssl genrsa -out private.key 2048 # 生成私钥

openssl rsa -in private.key -pubout public.key # 从私钥提取公钥
```

## 证书
X.509
```shell
openssl req -x509 -newkey rsa:2048 -nodes -keyout server.key -out server.crt -days 365
```

CSR签名请求
```shell
openssl genrsa -des3 -out server.key 2048 # 1.生成私钥
openssl req -new -key server.key -out server.csr # 2. 基于私钥生成csr
openssl x509 -req -days 365 -in server.csr -signkey server.key -out server.crt # 3. 基于私钥和csr生成证书
```
