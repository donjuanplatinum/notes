# RFC
## 2369
The Use of URLs as Meta-Syntax for Core Mail List Commands and their Transport through Message Header Fields

该文档规定了一组邮件列表命令规范头字段，这些字段是添加到电子邮件分发列表发送的电子邮件消息中的结构化字段。每个字段通常包含一个 URL（通常是 mailto URL，如 RFC 2368 中所定义），用于定位相关信息或直接执行命令

RFC 2369 中描述的三个核心头字段是list-help、list-subscribe和list-unsubscribe。还有其他三个头字段list-post、list-owner和list-archive，虽然应用不如核心字段广泛，但对很多邮件列表也很有用。通过包含这些头字段，列表服务器可以让邮件客户端为用户提供自动化工具来执行列表功能，例如以菜单项、按钮或其他用户界面元素的形式，简化用户体验，为通常复杂且多样的邮件列表管理器命令提供一个通用接口。

## 2368
The mailto URL scheme

该文档定义了用于指定电子邮件地址的统一资源定位符（URL）的格式，它是取代 RFC 1738《统一资源定位符》和 RFC 1808《相对统一资源定位符》的一系列文档之一。RFC 2368 扩展了 RFC 1738 中 “mailto” URL 的语法，通过允许 URL 表达额外的邮件头字段和邮件主体字段，从而可以创建更多符合 RFC 822 标准的消息。

“mailto” URL 的基本形式为：mailto:<收件人地址>[?< 邮件头字段 1>&< 邮件头字段 2>...]。其中，<收件人地址> 是符合 RFC 822 标准的邮箱地址，< 邮件头字段 > 用于设置邮件的头部信息，如主题、抄送等，特殊的头部字段名为 “body” 时，表示其关联的值是邮件的正文内容。

RFC 2368 所定义的 “mailto” URL 方案，使得用户可以通过点击包含 “mailto” URL 的链接，直接打开默认的邮件客户端并自动填充收件人、主题、正文等信息，方便了电子邮件的发送。不过，RFC 2368 后来被 RFC 6068《The ' mail to ' URI scheme》所取代。
