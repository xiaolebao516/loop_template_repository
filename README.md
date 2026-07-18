# Agent Loop Engineering Template

本仓库维护一个可部署到目标项目的极简 Agent Loop Engineering 运行时。

## 运行时结构

安装后目标项目只固定包含：

```text
AGENTS.md
.agent/
├── LOOP.md
└── STATE.md
```

- `AGENTS.md`：项目入口、确定性 Build / Test / Verify 命令、运行规则和初始化职责。
- `.agent/LOOP.md`：复杂任务的 Goal、Boundaries 和 SOP；简单任务可以不填写。
- `.agent/STATE.md`：当前恢复状态、尚未工程化的 Learnings 和最小 History。

reference、work 和 Skills 只在真实任务需要并证明有价值时按需创建，不作为固定运行时预装。

## 一键安装

在不包含 `AGENTS.md`、`.agent/` 或 `.agents/` 的目标项目根目录运行：

```powershell
irm https://raw.githubusercontent.com/xiaolebao516/loop_template_repository/main/scripts/install-agent-loop.ps1 | iex
```

指定目标目录：

```powershell
& ([scriptblock]::Create((irm 'https://raw.githubusercontent.com/xiaolebao516/loop_template_repository/main/scripts/install-agent-loop.ps1'))) -Target 'D:\project'
```

安装器需要 Windows PowerShell 5.1 和 Git。它只安装三个运行时文件，发现已有 Agent 痕迹时立即停止，不覆盖、不合并、不 commit、不 push，失败时不留下半成品。`-DryRun` 和 `-VerifyOnly` 均为只读模式。

## 初始化

安装后只需告诉 Agent：

> 初始化 Agent Loop Engineering。

初始化 Agent 会审计项目结构、文档和既有构建测试入口，优先复用可靠脚本与 CI 命令；缺少统一入口时创建最薄的确定性包装脚本，实际运行 Build / Test / Verify，并将唯一正式命令写入项目 `AGENTS.md`。初始化不创建业务 LOOP 或 History，STATE 保持 inactive，默认不 commit、不 push。

## 仓库验证

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\check-template.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\check-template.ps1 -Json
powershell -ExecutionPolicy Bypass -File .\tests\check-template.ps1
powershell -ExecutionPolicy Bypass -File .\tests\install-template.ps1
```

模板 MVP 处于真实使用观察期，后续只根据实际项目证据收敛规则。
