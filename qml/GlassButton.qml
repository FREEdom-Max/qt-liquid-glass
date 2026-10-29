import QtQuick
import QtQuick.Controls.Basic as C
C.Button {
    id:control
    required property var theme
    implicitWidth:Math.max(104,contentItem.implicitWidth+32)
    implicitHeight:42
    font.family:"Microsoft YaHei UI"
    font.pixelSize:14
    font.weight:Font.Bold
    hoverEnabled:true
    padding:12

    // The hit target/layout stays fixed while the lens lifts beyond its bounds.
    property real pressFeedback:down&&enabled?1:0
    Behavior on pressFeedback {
        NumberAnimation {
            duration:control.down?110:200
            easing.type:Easing.OutCubic
        }
    }

    background:Item {
        Prism {
            id:glass
            objectName:"buttonGlass"
            theme:control.theme
            width:parent.width+Math.min(12,parent.width*.08)*control.pressFeedback
            height:parent.height+10*control.pressFeedback
            x:(parent.width-width)/2
            y:(parent.height-height)/2
            corner:height/2
            // Match the raised sidebar capsule: clear center, strong lens edge.
            veil:(control.theme.whiteInk?.06:.34)*(1-control.pressFeedback)
            blur:.35*(1-control.pressFeedback)
            refraction:19+15*control.pressFeedback
            zoom:1.025+.155*control.pressFeedback
            over:control.hovered?1:0
            pushed:control.down?1:0
            opacity:control.enabled?1:.45

            Rectangle {
                anchors.fill:parent
                radius:parent.corner
                color:"transparent"
                border.width:1
                border.color:Qt.rgba(1,1,1,.6*control.pressFeedback)
                visible:control.pressFeedback>.001
            }
        }
        Rectangle {
            anchors.fill:glass
            anchors.margins:-3
            radius:height/2
            color:"transparent"
            border.color:"#d8752e"
            border.width:2
            visible:control.visualFocus
        }
    }

    contentItem:Text {
        text:control.text
        font:control.font
        color:control.down?(control.theme.whiteInk?"#ffc18f":"#ad4817"):control.theme.ink
        scale:1+.045*control.pressFeedback
        horizontalAlignment:Text.AlignHCenter
        verticalAlignment:Text.AlignVCenter
        opacity:control.enabled?1:.4
        elide:Text.ElideRight
        Behavior on color {ColorAnimation{duration:110}}
    }
}
