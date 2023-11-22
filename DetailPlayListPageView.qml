/*
author: zouyujie
date: 2023.11.18
function: 专辑/歌单的界面，是个模板界面，赋值即可
*/
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "requestNetwork.js" as MyJs //命名首字母必须大写，否则编译失败

ColumnLayout {

    //通过ID判断是否切换了歌单
    property string targetId: ""
    property string targetType: ""
    property string name: ""  //专辑名字

    property alias playListListView: playListListView
    property alias playingPlayListId: playListListView.isPlayingPlayListId

    //鼠标点了不同的banner会改变
    onTargetIdChanged: {
        playListListView.currentPage = 0
        playListListView.scrollBar.position = 0
        playListListView.currentPlayListId = targetId
        //已实现异步请求
        var url = (targetType==="10" ? "/album":"/playlist/detail")+"?id="+targetId
        MyJs.postRequest(url, loadPlayList)
    }

    Rectangle {
        Layout.fillWidth: true
        width: parent.width
        height: 50
        color: "#00000000"
        //color: "lightyellow"

        Text {
            x: 10
            //文本与底部对齐
            verticalAlignment: Text.AlignBottom
            text: qsTr(targetType==="10" ? "专辑-"+name:"歌单-"+name)
            font.family: window.mFONT_FAMILY
            font.pointSize: 25
        }
    }

    RowLayout {
        height: 170
        width: parent.width
        MusicRoundImage {
            id: playListCover
            width: 150; height: 150
            Layout.leftMargin: 10
        }

        Item {
            height: parent.height
            Layout.fillWidth: true

            Text {
                id: playListDesc
                width: parent.width*0.95
                anchors.centerIn: parent
                wrapMode: Text.WrapAnywhere
                font.family: window.mFONT_FAMILY
                font.pointSize: 14
                maximumLineCount: 4
                elide: Qt.ElideRight
                lineHeight: 1.5
                text: "这个家伙很懒，什么都没留下......"
            }
        }
    }  //end RowLayout

    MusicListView {
        id: playListListView
        onSwitchPage: function(offset) {
            MyJs.postRequest("/playlist/track/all?id="+targetId+"&limit=60&offset="+offset, getOnePageSongs)
        }
        modelName: "DetailPlayListPageView"
    }

    function loadPlayList(data) {
        //是专辑的情况
        if (targetType==="10") {
            var result = JSON.parse(data)
            var album = result.album
            var songs = result.songs
            //上半部分赋值
            name = album.name
            playListCover.imgSrc = album.blurPicUrl
            playListDesc.text = album.description
            //为音乐列表赋值,下半部分
            playListListView.songCount = songs.length
            playListListView.musicList = songs.map(item=>{
                                                       return {
                                                           id: item.id,
                                                           name: item.name,
                                                           artist: item.ar[0].name,
                                                           album: item.al.name
                                                       }
                                                   })
        } else if (targetType==="1000") {  //是歌单的情况
            var playlist = JSON.parse(data).playlist
            //上半部分赋值
            name = playlist.name
            playListCover.imgSrc = playlist.coverImgUrl
            playListDesc.text = playlist.description
            //为音乐列表赋值,下半部分,再次请求数据两次
            MyJs.postRequest("/playlist/track/all?id="+targetId+"&limit=600", getAllSongs) //响应慢
            MyJs.postRequest("/playlist/track/all?id="+targetId+"&limit=60&offset=0", getOnePageSongs) //响应更快一点
        }
    }  //end function loadPlayList()

    function getAllSongs(data) {
        var songsAll = JSON.parse(data).songs
        playListListView.songCount = songsAll.length
    }

    function getOnePageSongs(data) {
        var songsOnePage = JSON.parse(data).songs
        playListListView.musicList = songsOnePage.map(item=>{
                                                   return {
                                                       id: item.id,
                                                       name: item.name,
                                                       artist: item.ar[0].name,
                                                       album: item.al.name
                                                   }
                                               })
    }
}
