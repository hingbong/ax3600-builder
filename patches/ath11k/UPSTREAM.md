# 本地 ath11k 补丁来源

`patches/ath11k/` 由工作流 “Prepare tree” 之后的 `Apply local ath11k patches`
步骤复制到 `openwrt/package/kernel/mac80211/patches/ath11k/`，与上游补丁一起在
mac80211 包编译时按文件名顺序以 `-p1` 应用。

| 文件 | 来源 | PR 内编号 | 作用 |
| --- | --- | --- | --- |
| `960-wifi-ath11k-make-external-IRQ-control-idempotent.patch` | openwrt/openwrt#24254 | 950 | 外部 IRQ 生命周期跟随 NAPI 状态，避免重复 disable 抬高 IRQ disable depth |
| `961-wifi-ath11k-use-private-page-frag-caches-for-rxdma.patch` | openwrt/openwrt#24254 | 951 | 每个 RXDMA ring 私有 `page_frag_cache`，RXDMA 与 CE 不再共用 per-CPU 页片段缓存 |

## 引入记录

- PR: https://github.com/openwrt/openwrt/pull/24254 （state: open, merged: false）
- 引入时 PR head: `2ab272d5bdab22626bc67a08906e2ed9fabd44b7`
- 引入日期: 2026-11-18
- 基线: openwrt main `27663a017a`，backports 7.2（`PKG_SOURCE_VERSION:=7.2`）
- 编号调整: PR 里是两个新文件 950/951，与上游已有的 950/951 同号不同名；
  改名为 960/961，确保排在 956 之后、最后应用。
- 与上游 954 的关系: 954 已在 `ath11k_core_reconfigure_on_crash()` 里先
  `ath11k_hif_irq_disable()` + `ath11k_hif_ce_irq_disable()` 再拆数据路径，
  所以 951 的 core.c hunk 已不需要（照抄会 fuzz 到错误的函数里），已删除；
  961 只保留 dp.h / dp_rx.c 的页片段缓存改动。

## 交叉验证

- PR 评论里 `mahir-m01`（2026-11-11，main `3b197b2007` / backports 7.2）给出的刷新方案与本目录一致：
  编号用 960/961，hunk 1 重刷为 `<linux/gfp.h>` 在前、`<net/sock.h>` 在 `<linux/skbuff.h>` 之后。
- `Gibbo97` 的独立结论补充了第二点：上游 `e56c9d429ba0`（即 OpenWrt 954）已把 shutdown 集中到
  `ath11k_core_reconfigure_on_crash()` 锁内，所以 allocator 补丁里额外的
  `ath11k_hif_irq_disable()` 应当删除——与本地删除 core.c hunk 的做法一致。
- 关于 960（IRQ 幂等）：`Gibbo97` 认为在 954 之后“恢复失败再次恢复”仍可能造成 IRQ depth 失衡，
  上游 2026-11 有新提案专门处理这个 retry 场景（https://lists.openwall.net/linux-kernel/2026/11/01/444）。
  如果该提案进入 main，960 可能变得多余；巡检时顺带看一眼即可。

## 每日巡检要判定的四种情况

1. **已不需要**：PR `state=closed` 且 `merged=true`，或 openwrt main 的
   `package/kernel/mac80211/patches/ath11k/` 里出现同内容文件 →
   删掉本地 `96*.patch`。
2. **需要同步**：PR `head.sha` 与上面记录不同 → 重新抓 `.patch` 并 rebase
   （注意重新确认 core.c hunk 和编号）。
3. **不兼容**：上游 ath11k 补丁（尤其 954/956 及更高编号）或
   `mac80211/Makefile` 的 `PKG_SOURCE_VERSION` 换版，改到
   `ahb.c`/`pcic.c` 的 ext IRQ enable/disable、`dp_rx.c` 的 RXDMA refill、
   `dp.h` 的 `struct dp_rxdma_ring` → 本地补丁会打不上，构建在 mac80211 包处失败。
4. **正常**：以上都不成立，记录一行“本地补丁 960/961 正常”即可。

## 回滚

删除 `patches/ath11k/96*.patch` 即可；工作流的复制步骤对空目录无副作用，
不需要改动任何其他文件。
