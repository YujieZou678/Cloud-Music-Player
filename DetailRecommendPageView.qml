//DetailRecommendPageView.qml

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

//为了有滑轮，隐藏超出的视图
ScrollView {

    //如果网络请求没有数据
    signal noData(var modelName)
    //如果网络请求有数据
    signal yesData(var modelName)

    clip: true
    ColumnLayout {
        spacing: 0

        Rectangle {
            Layout.fillWidth: true
            width: parent.width
            height: 50
            color: "#00000000"

            Text {
                x: 10
                //文本与底部对齐
                verticalAlignment: Text.AlignBottom
                text: qsTr("推荐内容")
                font.family: window.mFONT_FAMILY
                font.pointSize: 25
            }
        }

        //banner
        MusicBannerView {
            id: bannerView
            Layout.preferredWidth: window.width - 200
            Layout.preferredHeight: (window.width - 200)*0.3
            Layout.fillHeight: true
            Layout.fillWidth: true
        }

        Rectangle {
            Layout.fillWidth: true
            width: parent.width
            height: 50
            color: "#00000000"

            Text {
                x: 10
                //文本与底部对齐
                verticalAlignment: Text.AlignBottom
                text: qsTr("热门歌单")
                font.family: window.mFONT_FAMILY
                font.pointSize: 25
            }
        }

        //热门歌单网格布局
        MusicGridHotView {
            id: gridHotView
            Layout.preferredWidth: window.width - 200
            Layout.preferredHeight: (window.width - 200)/5*4 + 120
            Layout.fillHeight: true
            Layout.fillWidth: true
        }

        Rectangle {
            Layout.fillWidth: true
            width: parent.width
            height: 50
            color: "#00000000"

            Text {
                x: 10
                //文本与底部对齐
                verticalAlignment: Text.AlignBottom
                text: qsTr("新歌推荐")
                font.family: window.mFONT_FAMILY
                font.pointSize: 25
            }
        }

        //新歌推荐网格布局
        MusicGridLatestView {
            id: latestView
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.preferredWidth: window.width - 200
            Layout.preferredHeight: (window.width - 200)*0.1*10
        }
    }

    Component.onCompleted: {
        //实现异步请求,并进行相应处理
        postRequest("/banner", getBannerList, "bannerList")
        postRequest("/top/playlist/highquality?limit=20", getHotList, "hotList")
        postRequest("/top/song", getLatestList, "latestList")
    }

    onNoData: function(modelName) {
        //判断是哪个模块发出的请求
        if (modelName === "bannerList") {
            //手动给Json数组赋值
            var json = []
            var oneJsonData = {
                "imageUrl":"qrc:/images/errorLoading.png"
            }
            for (var i=0; i<5; i++) {
                json.push(oneJsonData)
            }
            bannerView.bannerList = json

            //反复请求
            bannerRepeatRequest.start()
        }
        else if (modelName === "hotList") {
            //手动给Json数组赋值
            var json = []
            var oneJsonData = {
                "coverImgUrl":"qrc:/images/errorLoading.png",
                "name":"歌单"
            }
            for (var i=0; i<20; i++) {
                json.push(oneJsonData)
            }
            gridHotView.hotList = json

            //反复请求
            hotListRepeatRequest.start()
        }
        else if (modelName === "latestList") {
            //手动给Json数组赋值
            var json = []
            var json1 = []
            var threeJsonData = {
                "name":"作者"
            }
            json1.push(threeJsonData)
            var oneJsonData = {
                "picUrl":"qrc:/images/errorLoading.png",
                "name": "专辑",
                "artists": json1
            }
            var twoJsonData = {
                "album": oneJsonData
            }
            for (var i=0; i<30; i++) {
                json.push(twoJsonData)
            }
            latestView.latestList = json

            //反复请求
            latestRepeatRequest.start()
        }
    }
    onYesData: function(modelName){
        //判断是哪个模块发出的请求
        if (modelName === "bannerList") {
            //停止反复请求
            bannerRepeatRequest.stop()
        }
        else if (modelName === "hotList") {
            //停止反复请求
            hotListRepeatRequest.stop()
        }
        else if (modelName === "latestList") {
            //停止反复请求
            latestRepeatRequest.stop()
        }
    }

    //网络请求失败的间断性反复请求
    Timer {
        id: bannerRepeatRequest
        interval: 1000
        repeat: true
        running: false
        onTriggered: { postRequest("/banner", getBannerList, "bannerList") }
    }
    Timer {
        id: hotListRepeatRequest
        interval: 1000
        repeat: true
        running: false
        onTriggered: { postRequest("/top/playlist/highquality?limit=20", getHotList, "hotList") }
    }
    Timer {
        id: latestRepeatRequest
        interval: 1000
        repeat: true
        running: false
        onTriggered: { postRequest("/top/song", getLatestList, "latestList") }
    }

    function getBannerList(data) {
        //在JS中string转JSON，得到Json数组
        var banners = JSON.parse(data).banners
        //赋值
        bannerView.bannerList = banners
    }

    function getHotList(data) {
        //在JS中string转JSON，得到Json数组
        var playLists = JSON.parse(data).playlists
        //赋值
        gridHotView.hotList = playLists
    }

    function getLatestList(data) {
        //在JS中string转JSON，得到Json数组
        var latestLists = JSON.parse(data).data
        //赋值
        latestView.latestList = latestLists.slice(0,30)
    }

    //网络请求模板函数
    function postRequest(url="", handleData, moduleName) {
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
                noData(moduleName)
                return;
            }
            yesData(moduleName)
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
