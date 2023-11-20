/*
author: zouyujie
date: 2023.11.18
function: 推荐内容窗口的新歌推荐视图
*/
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
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
                    imgSrc: modelData.album.picUrl
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
                    text: modelData.album.name
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
                    text: modelData.album.artists[0].name
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
                        playMusic(index)
                    }
                }

            }  //end Frame
        }
    }

    function playMusic(index = 0) {
        if (latestList.length<1) return
        var id = latestList[index].id
        console.log("id: "+id+" 正在播放音乐")
        var url = "/song/url?id="+id

        MyJs.postRequest(url, dataHandle)
    }

    function dataHandle(_data) {
        var data = JSON.parse(_data).data
        //赋值
        mediaPlayer.source = data[0].url
        layoutBottomView.nameText = latestList[index].name+"-"+latestList[index].artists[0].name
        layoutBottomView.timeText = getTime(window.mediaPlayer.position/1000)+"/"+getTime(window.mediaPlayer.duration/1000)
        layoutBottomView.playStateSource = "qrc:/images/pause.png"
        mediaPlayer.play()
    }
}
