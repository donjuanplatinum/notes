# 协议

## MCP
Model Context Protocol 模型上下文协议

让模型与外部工具 数据源 文件系统等交互的**统一**协议

### MCP架构
MCP 分为 **Server** 和 **Client**
```
           +------------------------------+
           |          Client              |
           | (如 ChatGPT / 本地应用 )       |
           +---------------+--------------+
                           |
                           | MCP JSON Messages
                           v
           +---------------+--------------+
           |              Server           |
           |  提供工具、资源、Prompt 模板     |
           +---------------+--------------+
                           |
                +----------+-----------+
                |     Tools / Resources |
                +-----------------------+

```

下面是一个流程的例子

首先我的Emacs的MCP Client先连接MCP Server 获取它的**工具** **资源**和**prompt模板列表**

假设我使用emacs的MCP Client 向它发出指令
```
请你创建一个macro来批量注释文件
```

Emacs将我的prompt包装为MCP的`user_message`
```json
{
  "type": "message",
  "role": "user",
  "content": "请你使用 Emacs 创建一个宏"
}
```

然后模型会通过我发送的`user_message`和从MCP Server得到的工具 资源和prompt模板来推断需要调用的工具

然后Client将模型推断的执行操作消息`call_tool`发送给MCP Server

Server执行操作
#### Server
Server在MCP中是提供能力的一方 告诉MCP Client可以执行的操作的集合

同时执行操作

#### Client
Client在MCP中向Server和模型发送请求

Cursor就是一个Client 它负责连接多个Server
