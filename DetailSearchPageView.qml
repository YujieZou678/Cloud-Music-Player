//DetailSearchPageView

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQml


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

        postRequest("/search?keywords="+keyWords+"&offset="+offset+"&limit="+musicListView.pageSize, dataHandle)
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


