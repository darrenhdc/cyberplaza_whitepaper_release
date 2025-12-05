# translate_sc.sh — 自动化 LaTeX 翻译（本地/托管模型）

此脚本实现了一个“一条命令完成批量翻译”的工作流，用于将
`cyberplaza_whitepaper/mainmatter/*.tex` 翻译生成到 `mainmatter_sc/*.tex`。

支持的后端（通过环境变量 `API_TYPE` 指定）：

- `github` — 使用 GitHub 的模型（即 Copilot 后端）。可使用 `GITHUB_TOKEN` 或 `gh auth` 自动获取 token。
- `openai` — 使用 OpenAI Chat API（需设置 `OPENAI_API_KEY`）。
- `doubao` — 国内/自托管的 Doubao 风格接口（需设置 `DOUBAO_URL` 和 `DOUBAO_KEY`）。
- `test` — 测试模式（不调用任何网络接口），用于本地演练或调试。

使用方法（常见示例）

1) 翻译全部（默认使用 `github` 后端）：

```bash
cd /Users/handongcui/Documents/cyberplaza_docs
./scripts/translate_sc.sh
```

2) 使用 Doubao（示例）

```bash
export API_TYPE=doubao
export DOUBAO_URL=https://your-doubao-endpoint/v1/chat/completions
export DOUBAO_KEY=your-api-key
./scripts/translate_sc.sh
```

3) 翻译单文件（仅测试，不访问网络）

```bash
API_TYPE=test ./scripts/translate_sc.sh chapter-1.tex
```

关于 Doubao 的说明

不同的 Doubao/国产模型托管服务的请求/响应格式可能不完全一致。脚本默认向 `DOUBAO_URL` 发起 POST 请求，发送 JSON 载荷（包含 `model` 与 `input` 字段），并尝试用 `jq` 从常见字段中提取翻译结果，例如 `choices[0].message.content`、`response`、`output[0].content`、`data[0].content` 等。

如果你的服务返回字段或接口路径不同，请在环境变量 `DOUBAO_URL` 指向正确的 API 地址，或者根据你的服务调整 `scripts/translate_sc.sh` 中的 `translate_with_doubao()` 函数以匹配实际响应结构。

依赖

- jq
- curl
- （可选） gh CLI — 若选择 `github` 后端并希望脚本自动获取 token

示例：使用 OpenAI

```bash
export API_TYPE=openai
export OPENAI_API_KEY=sk-...
./scripts/translate_sc.sh
```

翻译完成后请编译并验证：

```bash
./scripts/compile_sc.sh
```
