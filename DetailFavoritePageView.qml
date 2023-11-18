//DetailFavoritePageView

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    Layout.fillWidth: true
    width: parent.width
    color: "#00000000"

    Text {
        x: 10
        //文本与底部对齐
        verticalAlignment: Text.AlignBottom
        text: qsTr("我喜欢的")
        font.family: window.mFONT_FAMILY
        font.pointSize: 25
    }
}
