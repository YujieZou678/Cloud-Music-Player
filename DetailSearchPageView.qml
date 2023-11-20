/*
author: zouyujie
date: 2023.11.18
function: 搜索窗口
*/
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQml
import "requestNetwork.js" as MyJs //命名首字母必须大写，否则编译失败


ColumnLayout {
    Layout.fillHeight: true
    Layout.fillWidth: true

    Rectangle {
        Layout.fillWidth: true
        width: parent.width
        height: 60
        color: "#00000000"

        Text {
            x: 10
            //文本与底部对齐
            verticalAlignment: Text.AlignBottom
            text: qsTr("搜索音乐")
            font.family: window.mFONT_FAMILY
            font.pointSize: 25
        }
    }

    RowLayout {
        Layout.fillWidth: true

        TextField {
            id: searchInput
            font {
                family: window.mFONT_FAMILY
                pointSize: 14
            }
            selectByMouse: true
            selectionColor: "#999999"
            placeholderText: "请输入搜索关键词"
            placeholderTextColor: "#999999"
            background: Rectangle {
                color: "#00000000"
//                border.width: 1
//                border.color: "black"
                opacity: 0.5
                implicitHeight: 40
                implicitWidth: 400
            }
            focus: true
            Keys.onEnterPressed: { doAndSearch() }
            Keys.onReturnPressed: { doAndSearch() }
        }

        MusicIconButton {
            iconSource: "qrc:/images/search.png"
            toolTip: "搜索"
            onClicked: { doAndSearch() }
        }
    }

    MusicListView {
        id: musicListView
        //当切换页数，需要用function接收信号的参数
        onSwitchPage: function(offset) {
            doSearch(offset)
        }
    }

    function doAndSearch() {
        musicListView.imageLoadingVisible = true
        musicListView.listViewVisible = false
        musicListView.pageButtonVisible = false

        musicListView.currentPage = 0;
        musicListView.scrollBar.position = 0;
        doSearch();
    }

    function dataHandle(data) {
        var result = JSON.parse(data).result
        var songList = result.songs
        //赋值
        musicListView.songCount = result.songCount
        console.log("\""+searchInput.text+"\" 搜索歌曲数目：" + result.songCount)
        //用JS对数据进行格式化，相当于自定义
        musicListView.musicList = songList.map(item=>{
                                                   return {
                                                       id: item.id,
                                                       name: item.name,
                                                       artist: item.artists[0].name,
                                                       album: item.album.name
                                                   }
                                               })
    }

    //执行搜索
    function doSearch(offset = 0) {
        var keyWords = searchInput.text
        if (keyWords.length < 1) {
            musicListView.imageLoadingVisible = false
            musicListView.listViewVisible = false
            musicListView.pageButtonVisible = false
            console.log("输入不能为空！")
            return
        }

        MyJs.postRequest("/search?keywords="+keyWords+"&offset="+offset+"&limit="+musicListView.pageSize, dataHandle)
    }
}


