# 架构

## 当前仓库

```text
GlassScene.background → ShaderEffectSource（共享 GPU 纹理）
  → Prism / Lens（局部折射、色散与高光）
  → 默认 content 层（文字、图标等清晰前景）
```

GlassScene 提供主题和坐标参考；四种 Controls Basic 控件使用 Prism 绘制材质，保留标准输入逻辑。背景纹理不含清晰前景，避免递归采到自身。FrostedBackdrop 是可选共享 GPU 模糊工具，与 Lens 的少量局部采样模糊分开。

Lens 基于圆角矩形距离场求边缘法线和采样位移，再叠加 RGB 分离、中心放大、染色和高光。这是屏幕空间近似，不是物理光线追踪。

## 实验室与维护关系

examples/glass_lab 的 Lens/Shader 是独立实验分支，保留参数对比和分段胶囊实验；qml/ 是当前公开组件实现。两套代码不是自动同步的镜像。修改材质时应明确改动目标，并用 tools/build_shaders.py 为全部 GLSL 重建 qsb。公开控件用 minimal.py --test 验证；实验室用 glass_lab.py --capture 验证。以后确有维护需求再合并。

## 原应用历史研究（未分发）

原应用主入口为 QuickMainWindow / QuickBridge 与 Main.qml。其桌面背景管线为 WGC 会话级捕获排除自身窗口 → Qt D3D11 设备上裁剪合成 → QSGTextureProvider → 共享 GPU 磨砂 → Prism/Lens → 清晰前景。

共享磨砂降低背景干扰，局部透镜保留折射与高光。每个表面仍有采样成本。更新定时器16ms不等于显示器实际60FPS。

Windows 捕获依赖系统特性、Qt 原生纹理 ABI 及窗口生命周期；该适配器未随本项目发布，当前示例使用应用自有背景。会话级排除的目标是避免递归采集而不影响其他录屏软件；实际兼容性需要逐一测试。

旧 QWidget glass.py 的 Acrylic/QPainter 样式与原生合成实验属于其他实现路径；公开 Prism 已移除这些接口。原应用 ComboBox、Avatar、CapsuleSelector 仅作为历史设计来源，当前没有这些独立组件。
