/*
author: zouyujie
date: 2024.4.9
function: MV视图。
*/
import QtQuick
import QtQuick.Layouts
import QtMultimedia
import QtQuick.Controls

Item {

    property string mvSource: "file:///root/tmp/Three.Little.Pigs.1933.avi"
    property int itemIndex: 0

    id: self
    anchors.fill: parent

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {  //上
            Layout.fillWidth: true
            Layout.preferredHeight: window.height*0.68
            color: "black"

            RowLayout {
                anchors.fill: parent
                spacing: 0

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }
                Item {  //播放窗口
                    Layout.preferredWidth: parent.height/3*4
                    Layout.preferredHeight: parent.height

                    MediaPlayer {
                        id: mvMediaPlayer
                        audioOutput: audioOutPut
                        videoOutput: videoOutPut
                        source: mvSource
                        Component.onCompleted: {
                            mvMediaPlayer.play()
                        }
                    }

                    AudioOutput {
                        id: audioOutPut
                    }
                    VideoOutput {
                        id: videoOutPut
                        anchors.fill: parent
                        //fillMode: Image.PreserveAspectCrop  //缩放填充
                    }
                }
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }
            }
        }

        Item {  //下
            Layout.fillWidth: true
            Layout.fillHeight: true

//            ColumnLayout {
//                anchors.fill: parent
//                spacing: 0

//                Item {  //第一排信息
//                    Layout.fillWidth: true
//                    Layout.preferredHeight: 30
//                    RowLayout {
//                        anchors.fill: parent
//                        spacing: 0

//                        Item {
//                            Layout.fillHeight: true
//                            Layout.preferredWidth: 60
//                        }
//                        Text {
//                            text: "送你一朵小红花（《送你一朵小红花》电影主题曲）"
//                            color: "#eeffffff"
//                            font {
//                                pointSize: 12
//                                family: mFONT_FAMILY
//                                bold: true
//                            }
//                        }
//                        Item {
//                            Layout.fillHeight: true
//                            Layout.fillWidth: true
//                        }
//                    }
//                }
//                Item {
//                    Layout.fillWidth: true
//                    Layout.preferredHeight: 5
//                }
//                Item {  //第二排信息
//                    Layout.fillWidth: true
//                    Layout.preferredHeight: 30
//                    RowLayout {
//                        anchors.fill: parent
//                        spacing: 0

//                        Item {
//                            Layout.fillHeight: true
//                            Layout.preferredWidth: 60
//                        }
//                        Text {
//                            text: "演唱："
//                            color: "#eeffffff"
//                            font {
//                                pointSize: 12
//                                family: mFONT_FAMILY
//                            }
//                            opacity: 0.5
//                        }
//                        Text {
//                            text: "赵英俊"
//                            color: "#eeffffff"
//                            font {
//                                pointSize: 12
//                                family: mFONT_FAMILY
//                            }
//                        }
//                        Item {
//                            Layout.preferredWidth: 8
//                        }
//                        Text {
//                            text: "1521.42万次播放"
//                            color: "#eeffffff"
//                            font {
//                                pointSize: 12
//                                family: mFONT_FAMILY
//                            }
//                            opacity: 0.5
//                        }
//                        Item {
//                            Layout.preferredWidth: 8
//                        }
//                        Text {
//                            text: "发布时间："
//                            color: "#eeffffff"
//                            font {
//                                pointSize: 12
//                                family: mFONT_FAMILY
//                            }
//                            opacity: 0.5
//                        }
//                        Text {
//                            text: "2020-12-15"
//                            color: "#eeffffff"
//                            font {
//                                pointSize: 12
//                                family: mFONT_FAMILY
//                            }
//                            opacity: 0.5
//                        }
//                        Item {
//                            Layout.fillHeight: true
//                            Layout.fillWidth: true
//                        }
//                    }
//                }
//                Item {
//                    Layout.fillHeight: true
//                    Layout.fillWidth: true
//                }
//            }

            ListView {
                id: listView
                anchors.fill: parent
                model: 10
                clip: true
                header: Item {
                    height: self.height-window.height*0.68
                    width: 200
                    Text {
                        text: "推荐MV"
                        font {
                            pointSize: 18
                            family: mFONT_FAMILY
                            bold: true
                        }
                        anchors.centerIn: parent
                        color: "#eeffffff"
                    }
                }

                delegate: Image {
                    height: self.height-window.height*0.68
                    width: self.width/4
                    source: "qrc:/images/12.png"
                }
                orientation: ListView.Horizontal
                onContentXChanged: {
                    if (contentX < -20-200) contentX = -200
                    if (contentX > self.width/7*10+100) contentX = self.width/7*10+60
                }
                MouseArea {
                    anchors.fill: parent
                    onWheel: function (wheel) {
                        if (wheel.angleDelta.y < 0) {
                            listView.contentX += 200
                        }
                        else {
                            listView.contentX -= 200
                        }
                    }
                }
                Behavior on contentX {
                    NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
                }

//                ScrollBar.horizontal: ScrollBar {
//                    id: scrollBar
//                    anchors.bottom: parent.bottom
//                }
            }
        }
    }
}


