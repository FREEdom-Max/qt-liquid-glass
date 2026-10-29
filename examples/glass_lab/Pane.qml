import QtQuick
Item {
 id: pane
 objectName: "tier"+index
 required property var scene
 required property var texture
 required property int index
 property int tier: index
 property real amount: [10,19,28][tier]
 property real chroma: [.65,1.8,3.6][tier]
 property real roughness: [.15,.35,1.7][tier]
 property real veil: [.015,.025,.09][tier]
 property color ink: scene.whiteInk ? "#f8fbff" : "#142737"
 property int taps: 0
 property real sliderValue: .52
 property bool switched: true
 property int selected: 0
 component Glass: Lens {
  scene: pane.scene; backgroundTexture: pane.texture
  refraction: pane.scene.bendEnabled ? pane.amount : 0
  chroma: pane.scene.bendEnabled ? pane.chroma : 0
  blur: pane.roughness; veil: scene.whiteInk ? pane.veil : .38 + pane.veil*.3
 }
 component Label: Text {color:pane.ink; font.family:"Microsoft YaHei UI"; font.pixelSize:14; font.weight:Font.DemiBold}
 Label {x:22;y:687;font.pixelSize:11;text:"折射 "+pane.amount+" px · 色散 "+pane.chroma+" px · 覆盖 "+Math.round(pane.veil*100)+"%"}
 Rectangle {anchors.fill:parent; color:scene.whiteInk?"#44101d2c":"#78dbe5ec"; radius:24; border.color:scene.whiteInk?"#18ffffff":"#44ffffff"}
 Label {x:22;y:20;font.pixelSize:22;font.bold:true;text:["01  清透","02  棱镜","03  柔雾"][tier]}
 Label {x:22;y:53;font.pixelSize:12;text:["低覆盖 · 细微色散","更强边缘折射 · 可见色散","柔化细节 · 较高覆盖"][tier]}
 Label {x:22;y:98;text:"按钮"}
 Item {
  x:22;y:126;width:pane.width-44;height:54
  property real compression:buttonMouse.pressed?1:0
  Behavior on compression {NumberAnimation{duration:buttonMouse.pressed?85:170;easing.type:Easing.OutCubic}}
  Glass {
   objectName:"buttonSurface"+pane.index
   x:(parent.width-width)/2;y:(54-height)/2+parent.compression
   width:parent.width*(1-.015*parent.compression);height:54*(1-.05*parent.compression);corner:24
   over:buttonMouse.containsMouse?1:0;pushed:buttonMouse.pressed?1:0
   Label {anchors.centerIn:parent;font.pixelSize:16;text:pane.taps ? "已点击 " + pane.taps + " 次" : "＋  添加到收藏"}
  }
  MouseArea {id:buttonMouse;anchors.fill:parent;hoverEnabled:true;cursorShape:Qt.PointingHandCursor;onClicked:pane.taps++}
 }
 Label {x:22;y:208;text:"滑块"}
 Item {
  id:slider;x:22;y:239;width:pane.width-44;height:36;focus:true
  Rectangle {anchors.verticalCenter:parent.verticalCenter;width:parent.width;height:5;radius:3;color:scene.whiteInk?"#55ffffff":"#44304e65"}
  Rectangle {anchors.verticalCenter:parent.verticalCenter;width:parent.width*pane.sliderValue;height:5;radius:3;color:"#409ded"}
  Glass {
   objectName:"sliderHandle"+pane.index
   property real stretch:slideMouse.pressed?1:0
   Behavior on stretch {NumberAnimation{duration:slideMouse.pressed?100:180;easing.type:Easing.OutCubic}}
   x:(parent.width-width)*pane.sliderValue;y:(36-height)/2
   width:52+4*stretch;height:36-2*stretch;corner:height/2;over:slideMouse.containsMouse?1:0;pushed:slideMouse.pressed?1:0
   Rectangle {anchors.centerIn:parent;width:15;height:2;radius:1;color:pane.ink;opacity:.6}
  }
  MouseArea {id:slideMouse;anchors.fill:parent;hoverEnabled:true;onPressed:function(m){slider.forceActiveFocus();pane.sliderValue=Math.max(0,Math.min(1,m.x/width))} onPositionChanged:function(m){if(pressed)pane.sliderValue=Math.max(0,Math.min(1,m.x/width))}}
  Keys.onLeftPressed:pane.sliderValue=Math.max(0,pane.sliderValue-.02)
  Keys.onRightPressed:pane.sliderValue=Math.min(1,pane.sliderValue+.02)
 }
 Label {x:pane.width-70;y:208;text:Math.round(pane.sliderValue*100)+"%"}
 Label {x:22;y:305;text:"进度条"}
 Glass {x:22;y:338;width:pane.width-44;height:19;corner:9
  Rectangle {x:2;y:2;width:(parent.width-4)*pane.sliderValue;height:parent.height-4;radius:7;color:"#75409ded"}
 }
 Label {x:22;y:393;text:"开关"}
 Glass {x:pane.width-94;y:383;width:72;height:40;corner:20
  Rectangle {anchors.fill:parent;radius:20;color:pane.switched?"#50409ded":"transparent"
   Behavior on color {ColorAnimation{duration:240;easing.type:Easing.InOutCubic}}
  }
  Glass {objectName:"switchThumb"+pane.index;x:pane.switched?34:4;y:4;width:34;height:32;corner:16;veil:scene.whiteInk?.045:.53
   Behavior on x {NumberAnimation{duration:240;easing.type:Easing.InOutCubic}}
  }
  MouseArea {anchors.fill:parent;onClicked:pane.switched=!pane.switched;cursorShape:Qt.PointingHandCursor}
 }
 Label {x:22;y:459;text:"分段选择"}
 Item {
  id:segments;objectName:"segments"+pane.index
  x:22;y:490;width:pane.width-44;height:48;focus:true
  property real position: 0
  property bool committing: false
  property bool dragging: false
  property bool pressPreview: false
  property int pressTarget: 0
  property real pressX: 0
  property real startPosition: 0
  property real grabOffset: 0
  property bool grabbedThumb: false
  readonly property real cell: (width-8)/3
  readonly property int previewIndex: Math.max(0,Math.min(2,Math.round(position)))
  function stopMotion() {clickMove.stop();snapMove.stop()}
  function moveTo(target, spring) {
   stopMotion();
   if(spring){snapMove.from=position;snapMove.to=target;snapMove.start()}
   else {clickMove.from=position;clickMove.to=target;clickMove.start()}
  }
  function choose(target,spring) {
   committing=true;pane.selected=target;committing=false;
   moveTo(target,spring);
  }
  function settle(commit) {
   var target=commit?previewIndex:pane.selected;
   pressPreview=false;dragging=false;choose(target,true);
  }
  Connections {target:pane;function onSelectedChanged(){if(!segments.dragging&&!segments.committing)segments.moveTo(pane.selected,false)}}
  NumberAnimation {id:clickMove;target:segments;property:"position";duration:300;easing.type:Easing.OutCubic}
  SpringAnimation {id:snapMove;target:segments;property:"position";spring:5;damping:.78;mass:.65}
  Glass {anchors.fill:parent;corner:24}
  Glass {
   id:capsule;objectName:"capsule"+pane.index
   property real lift:segments.dragging||segments.pressPreview?1:0
   x:4+segments.position*segments.cell-(width-segments.cell)/2
   y:(segments.height-height)/2
   width:segments.cell*(1+.12*lift);height:40+16*lift;corner:height/2
   // Lifted capsule stays clear: separation comes from lensing, not a veil.
   veil:(scene.whiteInk?.1:.55)*(1-Math.max(0,Math.min(1,lift)))
   blur:pane.roughness*(1-Math.max(0,Math.min(1,lift)))
   refraction:scene.bendEnabled?pane.amount+(34-pane.amount)*Math.max(0,Math.min(1,lift)):0
   pushed:segmentMouse.pressed?1:0
   zoom:1.025+.155*lift
   Behavior on lift {NumberAnimation{duration:segments.dragging||segments.pressPreview?140:230;easing.type:segments.dragging||segments.pressPreview?Easing.OutCubic:Easing.OutBack}}
  }
  Item {
   id:segmentContent;width:segments.width;height:48
   Row {x:4;width:parent.width-8;height:48
    Repeater {model:["全部","收藏","最近"]
     Item {width:segments.cell;height:48
      Row {
       anchors.centerIn:parent;spacing:5
       Rectangle {width:10;height:10;anchors.verticalCenter:parent.verticalCenter;radius:index===0?2:index===1?5:0;color:pane.ink;rotation:index===2?45:0}
       Label {text:modelData;font.weight:Font.DemiBold}
      }
     }
    }
   }
  }
  ShaderEffectSource {
   id:contentTexture;sourceItem:segmentContent;hideSource:true;live:true;visible:false
   textureSize:Qt.size(segmentContent.width*scene.deviceRatio,48*scene.deviceRatio)
  }
  ShaderEffect {
   objectName:"contentLens"+pane.index
   x:-16;y:-16;width:segments.width+32;height:segments.height+32
   property var source:contentTexture
   property size contentSize:Qt.size(segments.width,segments.height)
   property vector4d lensRect:Qt.vector4d(capsule.x,capsule.y,capsule.width,capsule.height)
   property color selectedColor:scene.whiteInk?"#a2f9da":"#087c55"
   property real padding:16
   property real zoom:capsule.zoom
   fragmentShader:"content_lens.frag.qsb"
   onStatusChanged:if(status===ShaderEffect.Error)scene.shaderError=log
  }
  MouseArea {
   id:segmentMouse;anchors.fill:parent;cursorShape:Qt.PointingHandCursor;preventStealing:true
   onPressed:function(m){
    segments.forceActiveFocus();segments.stopMotion();segments.pressPreview=false;segments.dragging=false;segments.pressX=m.x;
    segments.startPosition=segments.position;
    segments.grabbedThumb=m.x>=capsule.x && m.x<=capsule.x+capsule.width;
    segments.grabOffset=segments.grabbedThumb?m.x-capsule.x:segments.cell/2;
    segments.pressTarget=Math.max(0,Math.min(2,Math.floor((m.x-4)/segments.cell)));
    segments.pressPreview=true;
    segments.moveTo(segments.pressTarget,false);
   }
   onPositionChanged:function(m){
    if(!pressed || (!segments.dragging && Math.abs(m.x-segments.pressX)<=4))return;
    segments.stopMotion();segments.pressPreview=false;segments.dragging=true;
    segments.position=Math.max(0,Math.min(2,(m.x-4-segments.grabOffset)/segments.cell));
   }
   onReleased:function(m){
    
    if(segments.pressPreview){segments.pressPreview=false;segments.committing=true;pane.selected=segments.pressTarget;segments.committing=false;return;}
    if(segments.dragging)segments.settle(true);
    else segments.choose(Math.max(0,Math.min(2,Math.floor((m.x-4)/segments.cell))),false);
   }
   onCanceled:segments.settle(false)
  }
  Keys.onLeftPressed:{pane.selected=Math.max(0,pane.selected-1)}
  Keys.onRightPressed:{pane.selected=Math.min(2,pane.selected+1)}
  Keys.onEscapePressed:segments.settle(false)
 }
 Glass {x:22;y:571;width:pane.width-44;height:108;corner:26
  Label {x:18;y:20;font.bold:true;font.pixelSize:17;text:"观察背景的边缘弯曲"}
  Label {x:18;y:52;width:parent.width-36;wrapMode:Text.Wrap;text:"中心尽量通透，折射与彩色分离集中在边缘；文字作为清晰前景。";font.pixelSize:13}
 }
}
