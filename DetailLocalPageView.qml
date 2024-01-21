/*
author: zouyujie
date: 2023.11.18
function:
*/
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ColumnLayout {

    Rectangle {
        Layout.fillWidth: true
        width: parent.width
        height: 60
        color: "#00000000"

        Text {
            x: 10
            //文本与底部对齐
            verticalAlignment: Text.AlignBottom
            text: qsTr("本地音乐")
            font.family: window.mFONT_FAMILY
            font.pointSize: 25
        }
    }

    RowLayout {
        height: 80

        Item {
            width: 10
        }

        MusicTextButton {
            btnText: "添加本地音乐"
            btnHeight: 50
            btnWidth: 200
            onClicked: {

            }
        }
        MusicTextButton {
            btnText: "刷新记录"
            btnHeight: 50
            btnWidth: 200
            onClicked: {

            }
        }
        MusicTextButton {
            btnText: "清空记录"
            btnHeight: 50
            btnWidth: 200
            onClicked: {

            }
        }
    }

    MusicListView {
        id: localListView
    }
}




