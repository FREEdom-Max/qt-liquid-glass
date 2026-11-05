# 组件与支持范围

## GlassScene

```qml
GlassScene {
    id: scene
    width: 800; height: 640
    accent: "#407be0"
    fontFamily: "Arial"
    fontSize: 16
    background: Rectangle { width: 300; height: 300; color: "salmon" }
    GlassButton { theme: scene; text: "确定" }
}
```

默认内容进入清晰前景层，background 属性接收背景 Item 列表。只有背景进入 ShaderEffectSource，控件与文字不进入取样源。没有自定义背景时使用 backgroundColor；外部图片尚未加载时可将 backgroundReady 绑定到 Image.Ready，保留普通材质回退。

| 属性 | 默认值 / 含义 |
| --- | --- |
| whiteInk | false；深色表面与浅色文字 |
| effectsEnabled / chromatic | true / true |
| backgroundReady | true；宿主声明外部背景可用性 |
| backgroundColor | 随 whiteInk 切换的默认底色 |
| ink | 深浅主题的文字色；可覆盖 |
| accent | #e58a40；轨道、进度、选中提示与焦点框 |
| pressedInk | 由 accent 和主题派生的按钮按压文字色 |
| fontFamily / fontSize | Microsoft YaHei UI / 14；控件默认字体，允许逐控件覆盖 |
| surfaceVeil | 深色 .72 / 浅色 .68；默认保证明暗背景上的基本可读性 |
| materialReady | 只读；效果开启、背景可用且场景尺寸非零 |
| backdropTexture | 只读共享背景纹理 |
| shaderError | 错误日志；非空时自动关闭 effectsEnabled |
| mouseX / mouseY | 鼠标在场景坐标中的位置 |
| geometryRevision | 特殊宿主布局变化时可递增以主动刷新坐标 |

使用默认容器无需手工构造内部状态。零尺寸、背景不可用及关闭效果时 Prism 使用可操作的普通填充。修复 shader 后清空 shaderError 并重新启用 effectsEnabled；实际设备丢失恢复尚未验证。

## 四种控件

都必填 `theme: scene`，继承 Qt Quick Controls Basic 对应控件的属性和信号。disabled 控件降低不透明度。按钮、开关、滑块提供可见焦点框并参与 Tab 导航。

| 组件 | 常用属性与默认值 | 事件 |
| --- | --- | --- |
| GlassButton | text=""，高42，enabled=true | clicked |
| GlassSwitch | checked=false、text=""，高44 | toggled |
| GlassSlider | from=0、to=1、value=0、stepSize=0，高38 | moved |
| GlassProgress | from=0、to=1、value=0，高12 | valueChanged |

```qml
GlassButton { theme: scene; text: "确定"; onClicked: console.log("clicked") }
GlassSwitch { theme: scene; text: "开关"; onToggled: console.log(checked) }
GlassSlider { id: slider; theme: scene; from: 0; to: 100; value: 50 }
GlassProgress { theme: scene; value: slider.value / 100 }
```

滑块与进度条当前仅支持水平布局。字体等可用控件标准 font 属性覆盖。原应用 nativeGlass 注册接口已从公开 Prism 移除，不需要 Windows 捕获对象。

## 材质与模糊

Prism 必填 theme，默认 corner=22、refraction=19、chroma=1.8、blur=.35、zoom=1.025、veil=theme.surfaceVeil，over/pushed=0；无业务信号。surface 为场景中的映射矩形，只读。

```qml
Prism { theme: scene; width: 300; height: 150; corner: 24; refraction: 14 }
```

Lens 是底层 ShaderEffect，必填 scene、backgroundTexture。默认 corner=22、refraction=14、chroma=1.1、blur=.4、veil=.03、zoom=1.025。scene 契约包括 width、height、whiteInk、chromatic、geometryRevision、mouseX、mouseY、shaderError；一般使用 Prism 即可。

```qml
Lens { scene: scene; backgroundTexture: scene.backdropTexture; width: 100; height: 60 }
```

refraction 是边缘采样偏移，chroma 是 RGB 分离偏移，blur 是局部五点采样偏移；均为场景逻辑像素近似。zoom 为中心放大。它们不是物理折射率或桌面高斯模糊半径。

FrostedBackdrop 是可选共享模糊工具，必填 source（Item），strength=16（映射范围0–48）、active=true、deviceRatio=Screen.devicePixelRatio。texture 输出供 Lens 取样；无交互信号。source 应是可取样的纹理源或启用 layer 的 Item。

```qml
FrostedBackdrop { id: frost; source: scene.backdropTexture; width: scene.width; height: scene.height; strength: 12 }
Lens { scene: scene; backgroundTexture: frost.texture; width: 200; height: 100 }
```

## 坐标和层级限制

背景和材质必须位于同一 GlassScene 参考坐标中。验证覆盖父级平移、正向统一 scale、中心与左上缩放原点、父级尺寸变化和矩形父级裁剪。Lens 自动订阅这些几何属性。每个表面采样共同背景，不对嵌套玻璃进行多级光学合成。

不支持旋转、负缩放、非统一缩放、任意 transform 列表及跨场景背景。复杂嵌套裁剪、多屏混合 DPI 和设备丢失恢复未验证。默认 veil 下对明暗背景进行过目视检查；用户降低 veil 或覆盖 ink 后须重新检查可读性，未声明达到全面无障碍认证。

[验证记录](validation.md) · [来源和授权](sources.md)
