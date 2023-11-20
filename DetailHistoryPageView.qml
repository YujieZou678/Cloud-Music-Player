/*
author: zouyujie
date: 2023.11.18
function:
*/
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    Layout.fillWidth: true
    width: parent.width
    //height: 60
    color: "#00000000"

    Text {
        x: 10
        //文本与底部对齐
        verticalAlignment: Text.AlignBottom
        text: qsTr("播放历史")
        font.family: window.mFONT_FAMILY
        font.pointSize: 25
    }
}
