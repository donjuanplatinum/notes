# Claude-Code源代码解读

Claude-Code的核心流程为:

用户输入 -> `QueryEngine` -> `Agent-Loop`

其中

- `QueryEngine`: 管理会话的模块 定义于`QueryEngine.ts`
- `Agent-Loop`: Agent最重要的循环. 定义于`query.ts`

## QueryEngine.ts
负责:

1. 整个conversation的历史
2. 将用户的输入进行**分类** 比如普通消息 或者 `/model`等命令
3. 构造Context 这一步很重要 组装了**各种层级的上下文** **各种工具的列表** **各种插件的列表**
4. 进入Agent Loop
5. 统计运行时的状态 比如**权限**, **token花的钱**, **最大循环 防止无限循环**
6. 将模型传回的事件进行分类 比如模型要调用MCP 或者skill 或者cli等 将模型的消息转换为工具调用类型

流程为:
```
submitMessage()接收输入 -> 将系统命令/model等与自然语言消息分类

-> getSystemContext(),getUserContext()构造Context -> 封装tools commands Agents等

-> 构造query()参数 -> 调用query() -> 持续接收query的事件并消耗 进行工具调用等
```

### QueryEngineConfig
`QueryEngine` 所需要的整个 Agent Runtime 的接口.

```ts
export type QueryEngineConfig = {

  cwd: string
  tools: Tools
  commands: Command[]
  mcpClients: MCPServerConnection[]
  agents: AgentDefinition[]
  canUseTool: CanUseToolFn
  getAppState: () => AppState
  setAppState: (f: (prev: AppState) => AppState) => void
  initialMessages?: Message[]
  readFileCache: FileStateCache
  customSystemPrompt?: string
  appendSystemPrompt?: string
  userSpecifiedModel?: string
  fallbackModel?: string
  thinkingConfig?: ThinkingConfig
  maxTurns?: number
  maxBudgetUsd?: number
  taskBudget?: { total: number }
  jsonSchema?: Record<string, unknown>
  verbose?: boolean
  replayUserMessages?: boolean
  /** Handler for URL elicitations triggered by MCP tool -32042 errors. */
  handleElicitation?: ToolUseContext['handleElicitation']
  includePartialMessages?: boolean
  setSDKStatus?: (status: SDKStatus) => void
  abortController?: AbortController
  orphanedPermission?: OrphanedPermission
  /**
   * Snip-boundary handler: receives each yielded system message plus the
   * current mutableMessages store. Returns undefined if the message is not a
   * snip boundary; otherwise returns the replayed snip result. Injected by
   * ask() when HISTORY_SNIP is enabled so feature-gated strings stay inside
   * the gated module (keeps QueryEngine free of excluded strings and testable
   * despite feature() returning false under bun test). SDK-only: the REPL
   * keeps full history for UI scrollback and projects on demand via
   * projectSnippedView; QueryEngine truncates here to bound memory in long
   * headless sessions (no UI to preserve).
   */
  snipReplay?: (
    yieldedSystemMsg: Message,
    store: Message[],
  ) => { messages: Message[]; executed: boolean } | undefined
}
```
### for await (const message of query(...))
接收`query()`产生的事件流 然后维护状态
```ts
for await (const message of query({...})) {

    // 1. 保存/更新 conversation 状态
    if (message.type === 'assistant' ||
        message.type === 'user') {

        messages.push(message)
        mutableMessages.push(message)
    }


    // 2. 处理模型输出
    if (message.type === 'assistant') {

        // 把内部消息转换成 SDK 对外消息
        yield normalizeMessage(message)

        continue
    }


    // 3. 处理流式输出
    if (message.type === 'stream_event') {

        // 更新 token usage
        // 更新 stop_reason

        if (includePartialMessages) {
            yield message
        }

        continue
    }


    // 4. 处理工具/其他附件产生的事件
    if (message.type === 'attachment') {

        messages.push(message)
        mutableMessages.push(message)

        if (message.attachment.type === 'structured_output') {
            保存 structured output
        }

        if (message.attachment.type === 'max_turns_reached') {
            yield ERROR_MAX_TURNS
            return
        }

        continue
    }


    // 5. 处理系统事件
    if (message.type === 'system') {

        if (message.subtype === 'compact_boundary') {
            压缩/清理 conversation
            yield compact_boundary
        }

        if (message.subtype === 'api_error') {
            yield api_retry
        }

        continue
    }


    // 6. 处理工具调用摘要
    if (message.type === 'tool_use_summary') {

        yield tool_use_summary

        continue
    }


    // 7. 检查全局限制
    if (超过 maxBudgetUsd) {
        yield ERROR_MAX_BUDGET
        return
    }

    if (超过 structured_output retry limit) {
        yield ERROR_MAX_RETRIES
        return
    }
}
```
## query.ts
Agent-Loop的主要定义

```ts
async function* query(context) {

    messages = context.messages

    while (true) {

        // ① 把当前完整上下文发送给模型
        response = await callLLM({
            messages,
            tools,
            systemPrompt,
        })

        // ② 处理模型产生的内容
        for (const block of response) {

            if (block.type === "text") {
                yield assistant_message(block)
            }

            if (block.type === "tool_use") {

                // ③ 模型决定调用工具
                toolResult = await executeTool(
                    block.name,
                    block.input
                )

                // ④ 把工具结果加入 conversation
                messages.push(
                    assistant_tool_use(block)
                )

                messages.push(
                    tool_result(toolResult)
                )
            }
        }

        // ⑤ 如果模型没有要求继续调用工具
        if (!response.hasToolUse) {
            break
        }

        // 否则回到 while，再次调用 LLM
    }
}
```

## context.ts
在`QueryEngine`调用`query()`之前 将提示词封装.

封装后的提示词包含以下层级
```
┌──────────────────────────────────────┐
│ System Prompt                        │
│                                      │
│  ├─ Claude Code 核心系统指令         │
│  ├─ 工具使用规则                     │
│  ├─ Agent 行为规范                   │
│  ├─ Tool / MCP 相关说明              │
│  ├─ Skill / Command 相关说明         │
│  └─ User/System Context              │
│       ├─ git status                  │
│       ├─ CLAUDE.md                   │
│       ├─ 当前日期                     │
│       └─ cache breaker（特殊情况）   │
├──────────────────────────────────────┤
│ Conversation History                 │
│                                      │
│  ├─ user messages                    │
│  ├─ assistant messages               │
│  ├─ tool_use                         │
│  ├─ tool_result                      │
│  ├─ progress                         │
│  └─ compact boundary 后的历史         │
├──────────────────────────────────────┤
│ Current User Message                 │
│                                      │
│  └─ 用户这一次输入                    │
├──────────────────────────────────────┤
│ Tools                                │
│                                      │
│  ├─ Bash                             │
│  ├─ Read                             │
│  ├─ Edit                             │
│  ├─ Write                            │
│  ├─ Glob                             │
│  ├─ Grep                             │
│  └─ MCP tools                        │
├──────────────────────────────────────┤
│ Commands / Skills / Agents           │
│                                      │
│  ├─ slash commands (/model ...)      │
│  ├─ skills                           │
│  └─ sub-agents                       │
└──────────────────────────────────────┘
```

### system prompt
在`constants/prompts.ts`

```
function getSimpleIntroSection(outputStyleConfig: OutputStyleConfig | null): string {
  return `
You are an interactive agent that helps users ${
  outputStyleConfig !== null
    ? 'according to your "Output Style" below, which describes how you should respond to user queries.'
    : 'with software engineering tasks.'
} Use the instructions below and the tools available to you to assist the user.

IMPORTANT: You must NEVER generate or guess URLs for the user unless you are confident that the URLs are for helping the user with programming.`
}
```
## state/AppStateStore.ts
运行时状态

核心为下面的层级
```
AppStateStore
│
├── Model
│   ├── model
│   ├── thinking
│   └── effort
│
├── Tools
│   ├── MCP tools
│   ├── commands
│   └── tool permissions
│
├── Agents
│   ├── agent definitions
│   ├── tasks
│   ├── teammates
│   └── agent registry
│
├── Plugins
│   ├── enabled plugins
│   ├── plugin commands
│   └── plugin errors
│
├── Session
│   ├── hooks
│   ├── messages / initial message
│   ├── todos
│   └── notifications
│
├── Files
│   ├── file history
│   └── attribution
│
└── Runtime
    ├── permissions
    ├── remote state
    ├── speculation
    └── various feature state
```


```
AppStateStore
│
├── settings
│   ├── 用户配置
│   ├── 权限配置
│   ├── 模型配置
│   └── 其他 CLI / UI settings
│
├── model state
│   ├── mainLoopModel
│   ├── mainLoopModelForSession
│   ├── thinkingEnabled
│   ├── effortValue
│   ├── fastMode
│   └── advisorModel
│
├── tool / permission state
│   ├── toolPermissionContext
│   ├── denialTracking
│   ├── workerSandboxPermissions
│   ├── pendingWorkerRequest
│   ├── pendingSandboxRequest
│   ├── replBridgePermissionCallbacks
│   └── channelPermissionCallbacks
│
├── MCP state
│   ├── mcp.clients
│   ├── mcp.tools
│   ├── mcp.commands
│   ├── mcp.resources
│   └── pluginReconnectKey
│
├── Plugin state
│   ├── plugins.enabled
│   ├── plugins.disabled
│   ├── plugins.commands
│   ├── plugins.errors
│   ├── plugins.installationStatus
│   └── plugins.needsRefresh
│
├── Agent state
│   ├── agentDefinitions
│   ├── agentNameRegistry
│   ├── standaloneAgentContext
│   ├── teamContext
│   ├── tasks
│   ├── todos
│   ├── inbox
│   └── remoteAgentTaskSuggestions
│
├── Conversation / Session state
│   ├── initialMessage
│   ├── sessionHooks
│   ├── notifications
│   ├── elicitation
│   ├── promptSuggestion
│   ├── skillImprovement
│   └── authVersion
│
├── File / Git state
│   ├── fileHistory
│   └── attribution
│
├── UI state
│   ├── verbose
│   ├── expandedView
│   ├── isBriefOnly
│   ├── footerSelection
│   ├── activeOverlays
│   ├── spinnerTip
│   ├── statusLineText
│   ├── selectedIPAgentIndex
│   └── coordinatorTaskIndex
│
├── Remote / Bridge state
│   ├── remoteSessionUrl
│   ├── remoteConnectionStatus
│   ├── remoteBackgroundTaskCount
│   ├── replBridgeEnabled
│   ├── replBridgeConnected
│   ├── replBridgeSessionActive
│   ├── replBridgeSessionUrl
│   ├── replBridgeError
│   └── ...
│
├── Speculation state
│   ├── speculation
│   └── speculationSessionTimeSavedMs
│
├── Tmux / Browser / Computer-use state
│   ├── tungsten...
│   ├── bagel...
│   └── computerUseMcpState
│
└── Ultraplan state
    ├── ultraplanLaunching
    ├── ultraplanSessionUrl
    ├── ultraplanPendingChoice
    ├── ultraplanLaunchPending
    └── isUltraplanMode
```
## Tool.ts
工具抽象层 

- 统一工具的输入 输出 上下文与权限语义
