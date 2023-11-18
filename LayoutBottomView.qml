import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtMultimedia

Rectangle {

    property alias slider: slider
    property alias nameText: nameText.text
    property alias timeText: timeText.text
    property alias playStateSource: playIconButton.iconSource

    Layout.fillWidth: true
    height: 60
    color: "#00AAAA"

    //Layout布局(有些组件属性可能就没用)
    RowLayout {
        anchors.fill: parent
        Item {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.preferredWidth: parent.width/10
        }
        MusicIconButton {
            Layout.preferredWidth: 50
            iconSource: "qrc:/images/previous.png"
            iconWidth: 32; iconHeight: 32
            toolTip: "上一曲"
        }
        MusicIconButton {
            id: playIconButton
            Layout.preferredWidth: 50
            iconSource: "qrc:/images/stop.png"
            iconWidth: 32; iconHeight: 32
            toolTip: "暂停/播放"
            onClicked: {
                switch (window.mediaPlayer.playbackState) {
                case MediaPlayer.PlayingState:
                    window.mediaPlayer.pause()
                    iconSource = "qrc:/images/stop.png"
                    break;
                case MediaPlayer.PausedState:
                    window.mediaPlayer.play()
                    iconSource = "qrc:/images/pause.png"
                    break;
                }
            }
        }
        MusicIconButton {
            Layout.preferredWidth: 50
            iconSource: "qrc:/images/next.png"
            iconWidth: 32; iconHeight: 32
            toolTip: "下一曲"
        }
        //不是具体组件，没有默认属性，宽高会伸缩
        Item {
            Layout.preferredWidth: parent.width/2
            //可伸缩属性
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.topMargin: 25

            Text {
                id: nameText
                text: qsTr("云坠入雾里")
                anchors.left: slider.left
                anchors.bottom: slider.top
                font.family: "微软雅黑"
                color: "#ffffff"
            }
            Text {
                id: timeText
                text: qsTr("00:00/05:30")
                anchors.right: slider.right
                anchors.bottom: slider.top
                font.family: "微软雅黑"
                color: "#ffffff"
            }

            //具体组件有默认属性，宽高不会伸缩
            Slider {
                id: slider
                width: parent.width
                //一定要给显式的高，默认宽高仅在默认滑块上有
                height: 20
                //MediaPlayer.position应该是0-duration，而slider.position是0-1
                value: mediaPlayer.duration > 0 ? mediaPlayer.position / mediaPlayer.duration : 0
                onMoved: {
                    mediaPlayer.position = mediaPlayer.duration * slider.position
                }

                background: Rectangle {
                    x: slider.leftPadding
                    y: slider.topPadding + (slider.availableHeight - height)/2
                    width: slider.availableWidth
                    height: 4
                    radius: 2
                    color: "#e9f4ff"
                    Rectangle {
                        width: slider.visualPosition*parent.width; height: parent.height
                        radius: 2
                        color: "#73a7ab"
                    }
                }
                handle: Rectangle {
                    x: slider.leftPadding + (slider.availableWidth - width)*slider.visualPosition
                    y: slider.topPadding + (slider.availableHeight - height)/2
                    width: 15; height: 15
                    radius: 5
                    color: "#f0f0f0"
                    border.color: "#73a7ab"
                    border.width: 0.5
                }
            }
        }
        MusicIconButton {
            Layout.preferredWidth: 50
            iconSource: "qrc:/images/favorite.png"
            iconWidth: 32; iconHeight: 32
            toolTip: "下一曲"
        }
        MusicIconButton {
            Layout.preferredWidth: 50
            iconSource: "qrc:/images/repeat.png"
            iconWidth: 32; iconHeight: 32
            toolTip: "重复播放"
        }
        Item {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.preferredWidth: parent.width/10
        }
    }  //end RowLayout
}  //end Rectangle
