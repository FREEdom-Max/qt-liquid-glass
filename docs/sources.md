# 来源与第三方依赖

本仓库自有 QML、GLSL、Python、文档及生成背景的演示素材以 MIT 授权，见 LICENSE。MIT 不覆盖外部运行时、字体或工具。

## 项目来源核对

- 初始 Prism、Lens、基础控件来自作者 FREEdom-Max 的 JMViewer QML 实现，原应用相关提交为 327eb9f；独立实验室来自同一工作区 tools/glass_lab 和 tools/glass_lab.py。
- 对本次分发的源文件检查了版权头、第三方链接与引用标记；未发现需要保留的第三方代码版权声明。此记录是源码和本地历史核对，不是对互联网所有代码的查重保证。
- Shader 使用圆角距离场、有限差分法线、纹理偏移及 RGB 分离等常用方法。没有分发 Apple 系统材质实现、图标、商标素材或其源码。Liquid Glass 仅描述视觉风格，不表示官方实现或认可。
- qsb 是本仓库 GLSL 的构建输出；构建工具与哈希见 shader-build.json。
- docs/minimal.png、demo.gif 为真实公开组件最小示例的渲染捕获；docs/preview.png 为旧材质实验室。背景均由 QML 几何生成，未使用外部摄影素材。
- 字体仅按系统字体名称请求，未嵌入或再分发字体文件。

## 外部依赖

| 依赖 | 用途 | 官方授权说明 |
| --- | --- | --- |
| PyQt6 | Python 示例与测试运行时 | [Riverbank：GPL v3 / 商业授权](https://en.riverbankcomputing.com/software/pyqt) |
| Qt / Qt Quick / Controls / Effects | GPU 渲染与基础控件 | [Qt 授权及第三方组件](https://doc.qt.io/qt-6/licensing.html) |
| Qt Shader Tools qsb | 开发时构建，运行时不需要 | [qsb 手册](https://doc.qt.io/qt-6/qtshadertools-qsb.html) |
| Pillow | 可选开发工具，仅录制 GIF | [Pillow License](https://pillow.readthedocs.io/en/stable/about.html#license) |

这些依赖通过官方包另行安装，不作为本仓库自有代码重新授权。选择或分发 PyQt6 运行时须遵守其 GPL 或商业授权；项目 MIT 不改变这一要求。示例源代码可按 MIT 使用，包含外部运行时的应用分发需另外满足相应授权。

qsb 来源为官方 PySide6 发行包，开发者工具目录不上传。发布源仓库不包含 Qt/PyQt/PySide 的二进制运行时。
