import QtQuick
import QtQuick.Controls

Button {
    property string iconSource: ""

    property string toolTip: "提示"

    property bool isCheckable: false
    property bool isChecked: false

    property int iconWidth: 32
    property int iconHeight: 32

    id: self

    icon.source: iconSource
    icon.width: iconWidth
    icon.height: iconHeight

    //提示是否可见
    ToolTip.visible: hovered
    //提示内容
    ToolTip.text: toolTip

    background: Rectangle {
        color: self.down || (isCheckable && self.isChecked) ? "#497563" : "#20e9f4ff"
        radius: 3
    }
    icon.color: self.down ? "#ffffff" : "#e2f0f8"

    //是否可检测
    checkable: isCheckable
    //如果可检测，则在点击或有焦点空格后转换true或false
    checked: isChecked
}
