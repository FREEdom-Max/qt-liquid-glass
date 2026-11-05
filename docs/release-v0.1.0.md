# Qt Liquid Glass v0.1.0

首次组件参考版本：提供 GlassScene、Prism/Lens、共享模糊工具，以及按钮、开关、水平滑块、进度条。最小示例直接使用公开组件，并展示主题与效果回退。

新增统一字体、强调色与可见焦点，修复父级尺寸和缩放原点变化时的取样依赖。移除公开材质的未分发原生表面接口。

## 运行

```sh
python -m pip install -r requirements.txt
python examples/minimal.py
python examples/minimal.py --test
```

## 验证

隔离环境 Python 3.11.9、PyQt6 6.11.0、Qt 6.11.0、Windows build 26300、Direct3D11、DPR 1.5：公开组件16项GPU检查通过。覆盖交互、键盘、禁用、主题、背景不可用与效果回退、父级平移/缩放/尺寸变化和矩形裁剪的像素验证。详细记录见 docs/verification.json。

全部 GLSL 使用 qsb 6.11.0 重建，构建记录见 docs/shader-build.json。演示 docs/demo.gif 约24秒，展示实际公开控件。

## 限制与授权

只验证上述 Windows 组合。其他平台、多屏混合DPI、HDR、复杂裁剪、真实设备丢失恢复未验证；旋转、负缩放与非统一变换不支持。Windows桌面捕获仅提供架构说明。没有实际呈现FPS、功耗或显存承诺。

自有源码和生成素材MIT授权；外部PyQt6/Qt等遵循各自授权，详见 docs/sources.md。
