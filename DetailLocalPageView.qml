/*
author: zouyujie
date: 2024.1.22
function: 播放本地音乐。
*/
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt.labs.platform
import Qt.labs.folderlistmodel

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
            btnText: "搜索本地音乐"
            btnHeight: 50
            btnWidth: 200
            onClicked: {
                //加载界面
                localListView.imageLoadingVisible = true
                localListView.listViewVisible = false
                localListView.pageButtonVisible = false

                localListView.currentPage = 0;
                localListView.scrollBar.position = 0;

                //开始处理本地音乐
                var musicList = []
                var folderList = ["/root", "/opt", "/usr"] //需要遍历的文件夹
                getSongsFF_AtSub1Thread(folderList)  //子线程执行查找

                function onReply(data) {
                    var songsList = data

                    for (var i in songsList) {
                        //处理每一首歌，songsList为它们的地址
                        var songNameAbsoArr = songsList[i].split("/")
                        var songNameArr = songNameAbsoArr[songNameAbsoArr.length-1].split(".")
                        songNameArr.pop()  //去掉后缀
                        var songName = songNameArr.join(".")  //考虑歌名部分为A.B.C的情况
                        var songArr = songName.split("-")  //分离 歌手-歌名

                        var artist = songArr.length>1 ? songArr[0]:"未知"
                        var song = songArr.length>1 ? songArr[1]: songArr[0]

                        musicList.push({
                                           id: "file://"+songsList[i],
                                           name: song,
                                           artist: artist,
                                           album: "本地音乐",
                                           picUrl: "qrc:/images/errorLoading.png"
                                       })
                    }
                    //赋值
                    localListView.songCount = musicList.length
                    console.log("本地音乐 搜索歌曲数目："+localListView.songCount)
                    localListView.musicList = musicList

                    onGetSongsFFEnd_Signal.disconnect(onReply)  //断开连接
                }

                onGetSongsFFEnd_Signal.connect(onReply)
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

//    FileDialog {
//        id: fileDialog
//        fileMode: FileDialog.OpenFiles
//        nameFilters: ["MP3 Music Files(*.mp3)", "FLAC Music Files(*.flac)"]
//        //folder: StandardPaths.standardLocations(StandardPaths.MusicLocation)[0]  //该属性目前没用
//        //folder: "file:///root/tmp"
//        //currentFile: "file:///root/tmp/海阔天空.mp3"
//        acceptLabel: "确定"
//        rejectLabel: "取消"

//        onAccepted: {

//        }
//    }
}




