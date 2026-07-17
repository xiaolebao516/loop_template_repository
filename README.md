# Agent Loop Engineering Template

本仓库用于逐步构建一套可部署到其他项目的 Agent Loop Engineering 模板。当前 V0 只提供 Lite 与 Standard 两种工作流，用于在明确边界内持续执行、验证、记录状态并交付结果。

## 仓库结构

`template/` 中的内容用于未来部署到目标项目：

- `AGENTS.md`：项目地图、黄金规则入口和工作流路由器。
- `.agent/LOOP.md`：当前 Loop 的目标、范围、成功标准和稳定执行契约。
- `.agent/STATE.md`：当前 Loop 的实时执行状态。
- `.agent/LOG.md`：已结束任务的精简历史。
- `.agents/skills/workflow-lite/SKILL.md`：低风险、局部任务的轻量工作流。
- `.agents/skills/workflow-standard/SKILL.md`：需要规划、状态维护和真实验收的标准工作流。

目标项目中的 Agent 从 `AGENTS.md` 进入，根据任务选择且只加载一套 Workflow Skill。`LOOP.md` 是目标、范围和成功标准的唯一事实来源；Standard Workflow 在关键阶段维护 `STATE.md`，任务结束后将精简结果追加到 `LOG.md`。Lite Workflow 仅在产生长期价值信息时追加日志。

## V0 边界

当前不包含：

- Strict Workflow
- 多 Agent、Subagent 或 Worktree 编排
- Hook 或可执行状态机
- CLI 或自动模型切换
- 自动部署 Skill

## 后续方向

先将 V0 部署到真实项目试运行，观察工作流选择、状态维护和验收记录是否有效，再根据证据细化规则并封装部署能力。
