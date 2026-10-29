import QtQuick
Rectangle {
 id: lab
 width:1280;height:940;color:night?"#142032":"#eaf0f6"
 property real deviceRatio:Screen.devicePixelRatio
 property bool night:false
 property int readabilityMode:0
 readonly property bool whiteInk:readabilityMode===1
 property bool chromatic:true
 property bool bendEnabled:true
 property int backgroundMode:0
 property bool moving:false
 property real shift:0
 property real mouseX:width*.5
 property real mouseY:height*.5
 property int geometryRevision:0
 property string shaderError:""
 property string externalImage:""
 onWidthChanged:geometryRevision++
 onHeightChanged:geometryRevision++
 Timer {interval:16;running:lab.moving;repeat:true;onTriggered:{lab.shift+=.003;lab.geometryRevision++}}
 Item {
  id:background;anchors.fill:parent
  Rectangle {anchors.fill:parent;gradient:Gradient{orientation:Gradient.Horizontal;GradientStop{position:0;color:lab.night?"#134a61":"#7ed8cf"} GradientStop{position:.48;color:lab.night?"#615777":"#d5c7e4"} GradientStop{position:1;color:lab.night?"#764646":"#f6ac86"}}}
  Item {anchors.fill:parent;visible:lab.backgroundMode===0
   Rectangle {x:-160+Math.sin(lab.shift)*110;y:390;width:1000;height:700;radius:350;rotation:-24;color:lab.night?"#235877":"#467ca7"}
   Rectangle {x:560+Math.cos(lab.shift)*70;y:450;width:1000;height:650;radius:320;rotation:28;color:lab.night?"#79596e":"#f4d28c"}
   Rectangle {x:840;y:170;width:150;height:150;radius:75;color:lab.night?"#e2b080":"#fff1cc"}
   Repeater {model:16;Rectangle{x:280+index*24;y:350+index*8;width:6;height:540;rotation:18;color:lab.night?"#7785a1":"#d8e5e4";opacity:.55}}
  }
  Canvas {anchors.fill:parent;visible:lab.backgroundMode===1
   onVisibleChanged:requestPaint()
   onWidthChanged:requestPaint()
   onHeightChanged:requestPaint()
   onPaint:{var c=getContext('2d');c.clearRect(0,0,width,height);for(var x=0;x<width;x+=32)for(var y=0;y<height;y+=32){c.fillStyle=((x/32+y/32)%2===0)?'#213b5b':'#f7e9cb';c.fillRect(x,y,32,32)}}
  }
  Column {x:10;y:230;spacing:38;visible:lab.backgroundMode===2
   Repeater {model:6;Text{text:index%2?"REFRACTION  /  0123456789  /  玻璃材质":"TRANSPARENT   背景文字保持清晰   RGB";font.pixelSize:50;font.bold:true;color:lab.night?"#d8e8ef":"#214b69"}}
  }
  Image {anchors.fill:parent;visible:lab.backgroundMode===3;source:lab.externalImage;fillMode:Image.PreserveAspectCrop}
  Rectangle {anchors.fill:parent;color:"#07101f";opacity:lab.whiteInk?.68:0;Behavior on opacity{NumberAnimation{duration:180}}}
 }
 ShaderEffectSource {id:backgroundTexture;sourceItem:background;live:true;hideSource:false;visible:false;textureSize:Qt.size(lab.width,lab.height)}
 Rectangle {width:parent.width;height:160;color:lab.whiteInk?"#ed142032":"#eef3f7fa"}
 Text {x:32;y:23;text:"GLASS / 材质实验室";font.pixelSize:28;font.bold:true;color:lab.whiteInk?"white":"#182f43"}
 Text {x:32;y:66;text:"拖动分段胶囊后松手吸附 · 三档材质 × 两套可读性方案";font.pixelSize:14;color:lab.whiteInk?"#aabfce":"#52697a"}
 Row {x:32;y:105;spacing:10
  Repeater {model:["换背景","色散","折射","深浅色","背景移动"]
   Rectangle {width:116;height:34;radius:17;color:lab.whiteInk?"#37475a":"#dce6ef"
    Text {anchors.centerIn:parent;font.pixelSize:13;color:lab.whiteInk?"white":"#223e56";text:modelData+(index===1?(lab.chromatic?" 开":" 关"):index===2?(lab.bendEnabled?" 开":" 关"):"")}
    MouseArea {anchors.fill:parent;cursorShape:Qt.PointingHandCursor;onClicked:{if(index===0)lab.backgroundMode=(lab.backgroundMode+1)%(lab.externalImage?4:3);if(index===1)lab.chromatic=!lab.chromatic;if(index===2)lab.bendEnabled=!lab.bendEnabled;if(index===3)lab.night=!lab.night;if(index===4)lab.moving=!lab.moving}}
   }
  }
 }
 Row {x:680;y:105;spacing:8
  Repeater {model:["A  浅玻璃 · 深色变色字","B  暗背景 · 白色字"]
   Rectangle {width:268;height:34;radius:17
    color:lab.readabilityMode===index?(lab.whiteInk?"#426e63":"#c6e8dd"):(lab.whiteInk?"#37475a":"#dce6ef")
    border.color:lab.readabilityMode===index?"#168865":"transparent"
    Text {anchors.centerIn:parent;text:modelData;font.pixelSize:13;color:lab.whiteInk?"white":"#143e31";font.bold:lab.readabilityMode===index}
    MouseArea {anchors.fill:parent;cursorShape:Qt.PointingHandCursor;onClicked:lab.readabilityMode=index}
   }
  }
 }
 Row {x:24;y:184;spacing:16
  Repeater {model:3
   Pane {width:(lab.width-80)/3;height:708;scene:lab;texture:backgroundTexture}
  }
 }
 Text {x:32;y:910;text:lab.shaderError?"Shader error: "+lab.shaderError:"点击按钮、拖动滑块或切换开关；网格用于检查位移，文字背景用于检查透明度。";font.pixelSize:12;color:lab.whiteInk?"#c4d5e2":"#284b64"}
 MouseArea {anchors.fill:parent;acceptedButtons:Qt.NoButton;hoverEnabled:true;propagateComposedEvents:true;onPositionChanged:function(m){lab.mouseX=m.x;lab.mouseY=m.y}}
}

