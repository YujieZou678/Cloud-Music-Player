/*
author: zouyujie
date: 2023.11.18
function: 推荐内容窗口的新歌推荐视图
*/
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtMultimedia
import "requestNetwork.js" as MyJs //命名首字母必须大写，否则编译失败

Item {

    property var latestList: []

    Grid {
        id: gridLayOut
        anchors.fill: parent
        columns: 3

        Repeater {
            id: gridRepeater
            model: latestList
            Frame {
                padding: 5
                width: parent.width/3
                height: parent.width*0.1
                background: Rectangle {
                    id: background
                    color: "#00000000"
                }
                clip: true

                MusicRoundImage {
                    id: img
                    width: parent.height
                    height: parent.height
                    imgSrc: modelData.picUrl
                }

                //歌名
                Text {
                    id: songName
                    width: parent.width - img.width
                    height: 30
                    anchors {
                        left: img.right
                        leftMargin: 5
                        verticalCenter: parent.verticalCenter
                    }
                    text: modelData.name
                    font {
                        family: window.mFONT_FAMILY
                        pointSize: 11
                    }
                    elide: Qt.ElideRight
                }
                //作者
                Text {
                    width: parent.width - img.width
                    height: 30
                    anchors {
                        left: img.right
                        leftMargin: 5
                        top: songName.bottom
                    }
                    text: modelData.artist
                    font {
                        family: window.mFONT_FAMILY
                    }
                    elide: Qt.ElideRight
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered: {
                        background.color = "#50000000"
                    }
                    onExited: {
                        background.color = "#00000000"
                    }
                    onClicked: {
                        //播放单曲
                        if (mediaPlayer.playbackState === MediaPlayer.PlayingState) {
                            mediaPlayer.pause()
                            mediaPlayer.source = ""
                        }
                        var item = latestList[index]
                        var targetId = item.id
                        var nameText = item.name+"-"+item.artist
                        var picUrl = modelData.picUrl
                        MyJs.playMusic(targetId,nameText,picUrl)
                        MyJs.addHistoryItem(item)
                    }
                }

            }  //end Frame
        }
    }
}
