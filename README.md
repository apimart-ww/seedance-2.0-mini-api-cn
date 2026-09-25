# Seedance 2.0 Mini API 中文文档：模型 ID、每秒价格与调用示例

> **每秒 $0.0106（480P）**，按量计费，最低 1 美元起充。同一个 OpenAI 兼容接口，`https://api.apimart.ai/v1`。

<p align="center"><img src="assets/01-preview-thumb.jpg" width="820" alt="Seedance 2.0 Mini sample frame"></p>
**[查看 Seedance 2.0 Mini 模型页](https://go.apimart.ai/k-1b2b36)** · **[实时价格](https://go.apimart.ai/k-c1d777)** · **[获取 API Key](https://go.apimart.ai/k-3cdd9d)**

它是目前全平台每秒单价最低的视频模型之一，适合先跑通管线再做批量。

## 为什么通过 APIMart 调用 Seedance 2.0 Mini

- **一把 key 通吃全目录。** 同一套 base URL 与鉴权头可访问 Seedance 2.0 Mini 以及目录里 300 多个图像、视频、语言模型，换模型只改 `model` 字段。
- **1 美元起充、按量付费。** 没有订阅和预付套餐，也没有免费额度要先烧完——表里的单价就是实际单价。
- **账单在响应里。** 每次调用返回 `cost` / `credits_cost`，花多少当场可见，不用月底对账。
- **异步任务设计。** 提交拿到 `task_id`，轮询 `GET /v1/tasks/{id}`，批处理和重试就是普通队列逻辑。

## 模型 ID 与接口

| 字段 | 取值 |
| --- | --- |
| `model` | `seedance-2.0-mini` |
| endpoint | `POST https://api.apimart.ai/v1/videos/generations` |
| task | GET /v1/tasks/{id} |


## 真实调用样例（下表每条都是实际跑出来的结果）

| 输出档位 | file | 花费 | prompt |
| --- | --- | --- | --- |
| <img src="assets/01-preview-thumb.jpg" width="260"> | [01-preview.mp4](assets/01-preview.mp4) | $0.0528 | `海边悬崖上的现代别墅，黄昏，泳池倒映天空，缓慢推镜` |

## 实测价格

<!-- pricing:model:start -->
| 输出档位 | 单价 |
| --- | --- |
| `480P` | $0.0106 |
| `480P-input` | $0.0064 |
| `720P` | $0.028 |
<!-- pricing:model:end -->

## 请求参数

| 字段 | 取值 |
| --- | --- |
| `model` | `seedance-2.0-mini` |
| `resolution` | `480p / 720p` |
| `duration` | `5 / 10 秒` |
| `n` | `1` |

## 60 秒上手

```bash
export APIMART_API_KEY="<token>"
curl --request POST \
  --url https://api.apimart.ai/v1/videos/generations \
  --header "Authorization: Bearer $APIMART_API_KEY" \
  --header 'Content-Type: application/json' \
  --data '{"model":"seedance-2.0-mini", "prompt":"a cozy reading nook by a rainy window, warm lamp light", "n":1}'
```

```python
import os, time, requests

BASE = "https://api.apimart.ai/v1"
HEADERS = {"Authorization": f"Bearer {os.environ['APIMART_API_KEY']}", "Content-Type": "application/json"}

r = requests.post(f"{BASE}/videos/generations", headers=HEADERS, timeout=60, json={
    "model": "seedance-2.0-mini",
    "prompt": "a cozy reading nook by a rainy window, warm lamp light",
    "n": 1,
})
r.raise_for_status()
task_id = (r.json().get("data") or {}).get("id")
while True:
    t = requests.get(f"{BASE}/tasks/{task_id}", headers=HEADERS, timeout=60).json().get("data", {})
    if t.get("status") in ("completed", "failed"):
        print(t.get("status"), t.get("cost"))
        break
    time.sleep(5)
```

## 批量成本换算

| 用量 | 花费 |
| --- | --- |
| 60 秒 | $0.6336 |
| 600 | $6.336 |

按上表单价线性计算，未考虑阶梯折扣。价格快照见上方日期，预算前请复核实时价格。（snapshot 2026-09-21）

## 首次调用排错

| 现象 | 原因 | 处理 |
| --- | --- | --- |
| `401` / invalid api key | 密钥缺失、被截断，或粘贴时带了换行 | 从控制台重新复制；请求头格式为 `Authorization: Bearer $APIMART_API_KEY` |
| 余额不足 / credit 错误 | 账号没有余额 | 在控制台充值，最低 1 美元；没有免费额度可兜底 |
| `429` | 同一个 key 并发过高 | 退避后重试，重试时沿用同一个 `Idempotency-Key` |
| `400` / model 不存在 | 模型 ID 或参数档位写错 | 照抄上方表格里的 `model` 值，注意不同档位的字段名不同 |
| 任务 `failed` | 提示词被过滤，或参考图 URL 失效 | 换新的 `Idempotency-Key` 重新提交，并重新托管参考图 |

## 常见问题

**计费按什么单位？**

图像按张、视频按秒、语言模型按百万 token 计费；费用在任务响应里直接返回，可逐条核对。

**能开发票或查看明细吗？**

控制台的账单页可以按时间查看每次调用与扣费明细。

**支持哪些调用方式？**

任何能发 HTTP 请求的语言都可以。接口与 OpenAI 兼容，Python 可直接改用 openai SDK 并替换 base_url。

**结果链接会过期吗？**

会。任务完成后请立刻把文件下载到自己存储，不要长期依赖返回的临时地址。

## 披露

本仓库是第三方中转服务 APIMart 的接入说明，与模型原厂无隶属关系。价格与参数以仓库内标注的快照为准，实际计费以平台账单为准。

## 仓库结构

```
README.md            本文件
data/model.json      模型 ID、价格快照、参数
examples/curl.sh     curl 示例
examples/python.py   Python（提交 + 轮询）
LICENSE, .gitignore
```

## License

MIT
