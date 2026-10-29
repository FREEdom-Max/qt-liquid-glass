# Qt Liquid Glass

Qt Quick / PyQt6 液态玻璃材质与控件参考资源。

## 运行独立材质实验室

```sh
python -m pip install -r requirements.txt
python examples/glass_lab.py
```

可比较折射、色散、轻模糊、深浅色与交互反馈；背景由 QML 生成，不需要账号、业务数据或外部图片。可用 `--image PATH` 加入自己的背景。

`qml/` 保存从应用提取的当前 Prism/Lens 材质及按钮、开关、滑块、进度条。实验室是独立的材质比较示例，使用自己的展示组件；并非当前组件的完整集成测试。

## 复用与桌面背景

参见 [架构与组件说明](docs/architecture.md)。桌面管线的关键是 WGC GPU 纹理 → 共享磨砂 → 局部透镜 → 清晰前景。此首版收录该方案的源码分析文档；不分发依赖应用窗口生命周期的 Windows 捕获实现。

GLSL 源码和 qsb 同时保留。修改 shader 后使用对应 Qt Shader Tools 的 qsb 重新编译，例如 `qsb --glsl "100 es,120,150" --hlsl 50 --msl 12 -o qml/lens.frag.qsb qml/lens.frag`。

这是参考实现，尚未完成跨平台与跨 Qt 版本验证。不承诺实际帧率。依赖按各自许可证使用；本仓库尚未指定额外开源许可证。

## 预览

![独立材质实验室](docs/preview.png)

## 本机验证

Python 3.11.9 / PyQt6 6.11.0 / Qt 6.11.0，Windows D3D11，DPR 1.5。独立实验室的折射、色散、按压反馈、滑块、开关、分段拖动与键盘检查通过；QML 和 shader 错误为空。可用以下命令重跑（输出目录默认 data/glass_lab，不纳入版本控制）：

```sh
python examples/glass_lab.py --capture
```
