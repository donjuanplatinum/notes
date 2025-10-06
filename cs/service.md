# 服务
## Dovecot
高性能邮件代理(MDA)

配置证书
`/etc/dovecot/conf.d/10-ssl.conf`
```
ssl_cert = </etc/letsencrypt..
ssl_key = </etc/letsencrypt..
```

创建用户并给予权限
```shell
useradd -m /var/mail --shell /usr/sbin/nologin vmail
chown vmail:vmail /var/mail
chmod 700 /var/mail
```

更改`/etc/dovecot/conf.d/10-mail.conf中的`mail_location
```
mail_location = sdbox:/var/mail/%n/
```

修改auth-system`/etc/dovecot/conf.d/auth-system.conf.ext`的userdb
```
userdb {
  driver = passwd
  override_fields = uid=vmail gid=vmail home=/var/mail/%n/
}
```

### 选择性: mariadb

登录数据库
```shell
mysql -u root -p
```

创建对象
```sql
CREATE DATABASE IF NOT EXISTS dovecotDB;

USE dovecotDB;

CREATE TABLE IF NOT EXISTS users (
    username VARCHAR(255) NOT NULL PRIMARY KEY,
    password VARCHAR(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE USER IF NOT EXISTS 'dovecot'@'localhost' IDENTIFIED BY 'your_secure_password';

GRANT SELECT ON dovecotDB.* TO 'dovecot'@'localhost';

FLUSH PRIVILEGES;

SHOW GRANTS FOR 'dovecot'@'localhost';
```

注释掉不使用的`/etc/dovecot/conf.d/10-auth.conf`中的身份验证 并打开sql
```
#!include auth-system.conf.ext
!include auth-sql.conf.ext
```

修改`/etc/dovecot/conf.d/auth-sql.conf.ext`中的userdb
```
userdb {
  driver = sql
  args = /etc/dovecot/dovecot-sql.conf.ext
  override_fields = uid=vmail gid=vmail home=/var/mail/%n/
}
```

创建`/etc/dovecot/dovecot-sql.conf.ext`
```
driver = mysql**
connect = host=mariadb_srv.example.com dbname=dovecotDB user=dovecot password=_<dovecotPW>_ ssl_ca=/etc/pki/tls/certs/ca.crt
default_pass_scheme = SHA512-CRYPT
user_query = SELECT username FROM users WHERE username='%u';
password_query = SELECT username AS user, password FROM users WHERE username='%u';
iterate_query = SELECT username FROM users;
```
### 选择性: pgsql
```
CREATE TABLE mail_domain (
    id SERIAL PRIMARY KEY,
    domain_name VARCHAR(255) NOT NULL UNIQUE,
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW()
);
```
### LMTP
与postfix通讯

开启lmtp协议

`/etc/dovecot/dovecot.conf`中
```
protocols = imap pop3 lmtp
```

默认情况下 会在`/var/run/dovecot/lmtp`创建socket

可在`/etc/dovecot/conf.d/10-master.conf`中修改

若要监听端口 在service lmtp命名空间内加入inet_listener
```
service lmtp {
  ...
  inet_listener lmtp {
    port = 24
  }
  ...
}
```
## Postfix
高性能邮件服务器(MTA)

- main.cf: 包含 Postfix 的全局配置。
- master.cf: 指定 Postfix 与各种进程进行交互以完成邮件发送。
- access ：指定访问规则，例如允许连接到 Postfix 的主机。
- transport ：将电子邮件地址映射到中继主机。
- aliases ：包含一个邮件协议所需的可配置列表，其描述用户 ID 别名。请注意，您可以在 /etc/ 目录中找到此文件。

修改main.cf
```
inet_interfaces = all
myhostname = smtp.example.com
mydomain = example.com
myorigin = $mydomain # 使用这个设置时，Postfix 使用域名而不是主机名作为本地发送的邮件的源。
smtpd_tls_cert_file = /etc/pki/tls/certs/postfix.pem
smtpd_tls_key_file = /etc/pki/tls/private/postfix.key
smtpd_tls_auth_only = yes
```

### 可选的 多个域转发
在/etc/postfix/virtual加入转发
```
<info@example.com> <user1@example.net>
```
其中info@example.com 会转发到user1@example.net

创建hash文件
```
postmap /etc/postfix/virtual
```

在main.cf加入virtual_alias_maps参数
```
virtual_alias_maps = hash:/etc/postfix/virtual
```
### 联动dovecot
首先在dovecot中配置了LMTP套接字或监听服务

main.cf
```
virtual_transport = lmtp:unix:/var/run/dovecot/lmtp # 虚拟邮箱
mailbox_transport = lmtp:unix:/var/run/dovecot/lmtp # 非虚拟邮箱
```
## Gnu mailman
GNU的邮件列表管理器
```shell

```


## postgres
连接数据库
```
psql -U root
```
