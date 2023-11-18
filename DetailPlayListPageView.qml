//DetailPlayListPageView

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ColumnLayout {

    //通过ID判断是否切换了歌单
    property string targetId: ""
    property string targetType: ""
    property string name: ""

    property alias playListListView: playListListView

    //鼠标点了不同的banner会改变
    onTargetIdChanged: {
        playListListView.currentPage = 0
        playListListView.scrollBar.position = 0
        //已实现异步请求
        var url = (targetType==="10" ? "/album":"/playlist/detail")+"?id="+targetId
        postRequest(url, loadPlayList)
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
            postRequest("/playlist/track/all?id="+targetId+"&limit=60&offset="+offset, getOnePageSongs)
        }
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
            postRequest("/playlist/track/all?id="+targetId+"&limit=600", getAllSongs) //响应慢
            postRequest("/playlist/track/all?id="+targetId+"&limit=60&offset=0", getOnePageSongs) //响应更快一点
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

    //网络请求模板函数
    function postRequest(url="", handleData) {
        //得到一个空闲的manager
        var manager = getFreeManager()

        function onReply(data) {
            //得到数据立马断开连接,重置状态
            switch(manager) {
            case 0:
                onReplySignal1.disconnect(onReply)
                reSetStatus(manager)
                break;
            case 1:
                onReplySignal2.disconnect(onReply)
                reSetStatus(manager)
                break;
            case 2:
                onReplySignal3.disconnect(onReply)
                reSetStatus(manager)
                break;
            }
            //如果传递的数据为空，则判断网络请求失败
            if (data==="") {
                console.log("Error: no data!")
                return;
            }
            //处理数据
            handleData(data)
        }
        switch(manager) {
        case 0:
            onReplySignal1.connect(onReply)
            break;
        case 1:
            onReplySignal2.connect(onReply)
            break;
        case 2:
            onReplySignal3.connect(onReply)
            break;
        }

        //请求数据
        getData(url, manager)
    }

}
