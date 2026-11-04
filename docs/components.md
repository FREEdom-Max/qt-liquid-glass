# 组件与支持范围

## GlassScene

默认尺寸由宿主设置；whiteInk=false、effectsEnabled=true、chromatic=true。ink 自动随主题变化。background 属性接受背景 Item；默认内容进入清晰前景层，只有背景进入 ShaderEffectSource。没有自定义背景时使用默认纯色。

关闭效果时 Prism 使用普通填充；shader 错误写入 shaderError 并关闭效果。零尺寸容器暂停背景纹理更新，不应在零尺寸下依赖光学输出。

geometryRevision 可由宿主在复杂几何变化后递增。容器处理尺寸变化，Lens 订阅父级 x/y/scale。轴对齐平移与正向统一缩放是设计范围；旋转、负缩放、任意变换不支持。复杂嵌套裁剪、混合 DPI、父级变换仍须人工验证。

## 控件

所有控件必填 theme: scene，继承 Qt Quick Controls Basic 的对应控制属性和信号。

| 组件 | 常用属性与默认值 | 信号 |
| --- | --- | --- |
| GlassButton | text=""、enabled=true，高42 | clicked |
| GlassSwitch | checked=false、text=""，高44 | toggled |
| GlassSlider | from=0、to=1、value=0、stepSize=0，高38 | moved |
| GlassProgress | from=0、to=1、value=0，高12 | valueChanged |

字体可用控件 font.family / font.pixelSize 设置。强调色目前部分写在控件内；主题统一配置尚待迁移，GlassScene 的 accent/fontFamily/fontSize 预留值暂不自动驱动旧组件。

## 光学参数

Prism 默认 corner=22、refraction=19、chroma=1.8、blur=.35、zoom=1.025。refraction 为屏幕空间边缘偏移强度，chroma 为 RGB 采样分离，blur 为局部五点采样偏移，zoom 为中心放大。它们不是物理折射率或桌面高斯模糊半径。FrostedBackdrop 是独立共享模糊工具。

GlassScene 固定关闭 desktopGlass/nativeRefraction，默认路径不依赖 nativeGlass。Prism 保留的原生表面接口属于未提供适配器的历史实验接口。

## 验证记录（2026-11-04）

命令：python examples/minimal.py --test

通过：组件加载、按钮鼠标/空格激活、禁用按钮不触发、开关、滑块右键值增量、进度联动、浅深色切换、窗口调整尺寸后的非空渲染、关闭效果后点击。无 QML/shader 错误，进程正常退出。

待验证：干净虚拟环境安装、Tab 焦点顺序、禁用开关和滑块、父容器移动/缩放像素准确性、复杂裁剪、明暗背景可读性人工评审、多 DPI、其他平台。非空截图不证明采样位置准确。

## 来源与后续

当前材料提取自原应用的 QML/GLSL 与独立实验室。背景由 QML 生成，预览为本地实验室截图；未包含账号与外部图片。PyQt6/Qt 是外部依赖，各自授权独立适用。自有代码与参考来源的完整核对、项目 LICENSE、20–30秒动态演示及正式版本发布尚待完成；不将其记为已完成。
