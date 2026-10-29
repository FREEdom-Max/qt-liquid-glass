# 液态玻璃实现与复用指南

代码审阅日期：2026-10-28。本说明来自当前源码，不代表本次完成了运行、性能或跨机器兼容验证。

## 1. 当前实际架构

主入口是 `jmviewer/quick_ui.py` 的 QuickMainWindow 与 `jmviewer/qml/Main.qml`。材质统一由 Prism → Lens → lens.frag 实现。

```text
桌面：WGC 会话捕获（排除本应用窗口）
  → Qt 自己的 D3D11 设备上裁剪/合成桌面纹理
  → DesktopTexture / QSGTextureProvider
  → FrostedBackdrop 共享 GPU 模糊
  → 多个 Prism / Lens 局部折射、色散、高光
  → 文字、图标、图片等清晰前景

图片：背景图片 → backdrop 纹理 → 同一套 Prism / Lens
```

桌面模糊负责降低背景干扰；液态玻璃负责局部透镜感。二者顺序是先磨砂再折射，不应把前景一起模糊。共享背景模糊可避免每个按钮重复执行整幅背景模糊，但每个透镜仍有采样开销。

`gpu_desktop.py` 要求 D3D11 和 basic render loop；更新定时器为 16 ms，这不是实测 60 FPS。`native_glass/capture.py` 使用 WGC，按相交显示器捕获并合成纹理，像素不经过 Python CPU 图像读回。导入 Qt 纹理使用原生符号，存在 Qt ABI 版本耦合。

捕获使用会话级窗口排除以避免递归采到自己；该功能不可用时会报错，不回退到全局截图排除。这是保留正常截图/录屏能力的设计，具体录屏软件表现仍需实测。

## 2. 三条路径必须区分

| 路径 | 当前定位 |
| --- | --- |
| QML Prism/Lens + GPU 桌面纹理 | 当前主线 |
| `glass.py` 的 Acrylic、QPainter 高光和 CardWidget 改写 | QWidget 旧样式方案，不代表当前桌面管线 |
| `native_glass` 的原生表面合成及 Prism 注册接口 | 有实验接口；Main.qml 明确 `nativeRefraction:false`，但其中 capture 模块仍被主线使用 |

`native_backdrop.py` 当前启用窗口透明与系统圆角并移除背景效果，注释明确当前 layered QWidget 路径与 Accent Acrylic 不兼容。不能仅依据界面“原生磨砂”提示，声称当前降级分支真正执行了 Acrylic 模糊。

## 3. 材质与组件语言

Lens 用圆角矩形 SDF 计算轮廓和边缘法线，以边缘坡度偏移采样坐标，叠加中心放大、RGB 分离、五点轻模糊、明暗染色、随指针变化的边缘高光。它是视觉近似，不是物理光线追踪。

Prism 对外参数：`corner`、`refraction`、`chroma`、`blur`、`veil`、`over`、`pushed`、`zoom`。默认值依次为 22、19、1.8、0.35、随主题变化、0、0、1.025。`blur` 是局部采样偏移，不能等同于桌面模糊强度。

| 组件 | 样式与交互 |
| --- | --- |
| GlassButton | 高 42、胶囊轮廓；按下材质扩大，折射 19→34、放大 1.025→1.18，减少蒙层与模糊；点击布局固定 |
| GlassSwitch | 66×38 轨道、30×30 玻璃滑块；橙色选中提示，240 ms 位移 |
| GlassSlider | 5 px 轨道、橙色进度；40×30 滑块按下变为 44×28 |
| GlassComboBox | 高 42、圆角 15；弹层圆角 16、选项高 40；包含应用弹窗与阅读器联动 |
| GlassProgress | 高 12、圆角 6；橙色进度、100 ms 宽度过渡 |
| GlassAvatar | 默认 64×64，圆形玻璃外框与清晰头像分层；按下扩大材质 |
| CapsuleSelector | 胶囊选择器支持拖动；普通切换 300 ms，吸附使用弹簧动画 |

主题采用浅色深字与深色白字；主文字 `#183443` / `#f4fafb`，次文字 `#4b6575` / `#b4c9d2`，强调色 `#e58a40`。深色 Prism 额外覆盖灰色蒙层，改善亮桌面上的白字可读性。按钮和头像提供可见焦点框。

## 4. 复用边界

建议拆成两个层级：

1. **通用 QML 材质与控件**：Prism.qml、Lens.qml、lens.frag 和编译后的 lens.frag.qsb，以及 Glass 系列组件、CapsuleSelector、FrostedBackdrop。先以图片背景演示，摆脱业务与 Windows 捕获依赖。
2. **可选 Windows 桌面适配器**：gpu_desktop.py、desktop_texture.py、desktop_capture.py 及 native_glass/capture.py 的必要依赖。需要独立主窗口适配与生命周期管理，不能只复制两个 Python 文件。

最小使用形式：

```qml
GlassButton {
    theme: glassScene
    text: "示例按钮"
    onClicked: console.log("clicked")
}
```

`glassScene` 必须满足现有契约：width/height、whiteInk、ink、effectsEnabled、desktopGlass、desktopTextureReady、nativeRefraction、backdropTexture、geometryRevision、chromatic、mouseX/mouseY、shaderError。背景源必须与 scene 坐标对应。Lens 依赖 mapToItem 与 geometryRevision，滚动、缩放和裁剪需要验证。

ComboBox 的 appBridge/syncMaterialPopup 联动、头像的业务来源、应用窗口和捕获生命周期应改成宿主回调。主题参数建议统一到 GlassTheme，避免将完整 appState 暴露给通用组件。公开模块应保存 shader 源码及可重复构建步骤，不能仅分发 qsb。

## 5. GitHub 发布建议

值得独立发布为 **PyQt6 / Qt Quick liquid glass showcase**，先定位为可运行参考实现，再逐步演进为组件库。价值在于桌面输入、共享磨砂与局部透镜的组合，以及统一交互风格。

建议仓库结构：

```text
qml/Glass/          材质、组件、主题
shaders/           源码与构建说明
platform/windows/  可选捕获适配器
examples/          图片背景与桌面背景两个最小示例
docs/              架构、参数、限制、兼容性
```

发布前需要完成：业务解耦；最小示例；明确 Python/Qt/Windows 实测版本；检查素材和依赖授权并选择许可证；补充浅深色、按钮交互、桌面动态背景演示。PyQt6 及其他依赖的再分发条件应单独核对，不能直接假定全部可用 MIT 发布。

验证矩阵至少覆盖：多显示器与混合 DPI、窗口移动/缩放、最小化恢复、捕获失败、shader 失败、截图录屏、弹层裁剪、亮背景白字、键盘焦点，以及关闭窗口后资源释放。性能报告分开记录捕获/提交耗时、真实呈现帧率、GPU 占用和显存；不要把定时器频率或更新回调计数写成显示器 FPS。

当前结论：适合发布技术展示和参考资源；尚未据此确认达到跨机器通用组件库的发布质量。此仓库提供材质参考资源，Windows 桌面捕获部分保留为架构说明。
