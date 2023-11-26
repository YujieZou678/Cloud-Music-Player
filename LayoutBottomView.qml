/*
author: zouyujie
date: 2023.11.18
function: 最下面那层部件，播放，切换歌曲，进度条......
*/
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtMultimedia
import "requestNetwork.js" as MyJs

Rectangle {

    property alias slider: slider
    property alias nameText: nameText.text
    property alias timeText: timeText.text
    property alias modePlay: playMode.toolTip  //播放模式
    property alias playStateSource: playIconButton.iconSource  //播放/暂停按钮
    property alias musicCoverSrc: musicCover.imgSrc  //图片信息

    property var playModeSwitch: [  //播放模式提示语的数组
        { name: "顺序播放", source: "qrc:/images/repeat.png"},
        { name: "随机播放", source: "qrc:/images/random.png"},
        { name: "循环播放", source: "qrc:/images/single-repeat.png"}
    ]
    property int indexPlayMode: 0

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
            onClicked: {
                MyJs.switchSong(false, modePlay, false)
            }
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
            onClicked: {
                MyJs.switchSong(true, modePlay, false)
            }
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
                property alias handleRec: handleRec
                handle: Rectangle {
                    id: handleRec
                    x: slider.leftPadding + (slider.availableWidth - width)*slider.visualPosition
                    y: slider.topPadding + (slider.availableHeight - height)/2
                    width: 15; height: 15
                    radius: 10
                    color: "#f0f0f0"
                    border.color: "#73a7ab"
                    border.width: 0.5

                    property alias imageLoading: imageLoading
                    //缓冲画面
                    Image {
                        id: imageLoading
                        source: "qrc:/images/loading.png"
                        width: 12; height: 12
                        visible: false
                        anchors.centerIn: parent
                    }
                    RotationAnimation {
                        target: imageLoading
                        from: 0
                        to: 360
                        duration: 500
                        running: true
                        loops: Animation.Infinite
                    }
                }
            }
        }
        MusicRoundImage {
            id: musicCover
            width: 50; height: 50
            imgSrc: "qrc:/images/errorLoading.png"
        }
        MusicIconButton {
            Layout.preferredWidth: 50
            iconSource: "qrc:/images/favorite.png"
            iconWidth: 32; iconHeight: 32
            toolTip: "我喜欢"
        }
        MusicIconButton {
            id: playMode
            Layout.preferredWidth: 50
            iconSource: playModeSwitch[indexPlayMode].source
            iconWidth: 32; iconHeight: 32
            toolTip: playModeSwitch[indexPlayMode].name
            onClicked: {
                indexPlayMode = (indexPlayMode+3+1)%3
            }
        }
        Item {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.preferredWidth: parent.width/10
        }
    }  //end RowLayout
}  //end Rectangle
