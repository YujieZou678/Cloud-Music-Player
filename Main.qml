/*
author: zouyujie
date: 2023.11.18
function: qml主函数
*/
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtMultimedia
import "requestNetwork.js" as MyJs

ApplicationWindow {
    id: window

    property int mWINDOW_WIDTH: 1200
    property int mWINDOW_HEIGHT: 800
    property string mFONT_FAMILY: "微软雅黑"

    /* 实际上主函数不需要声明，会自动加载到全部应用里 */
    property alias mediaPlayer: mediaPlayer
    property alias layoutBottomView: layoutBottomView
    property alias pageHomeView: pageHomeView
    property alias pageDetailView: pageDetailView

    //用于列表播放后，切歌
    property var mainHistoryList: []   //播放历史列表
    property bool loadCacheCause: true  //是否是加载缓存导致
    onMainHistoryListChanged: {  //一开始自动会执行一次
        if (mainHistoryList.length === 0) {
            var dataCache = getHistoryCache()
            if (dataCache.length < 1) {
                console.log("播放历史缓存数据为空。")
                loadCacheCause = false
            } else {
                mainHistoryList = dataCache  //加载缓存
            }
        }
        else {
            if (loadCacheCause) { loadCacheCause = false; return }
            if (mainHistoryList.length > 20) { mainHistoryList.shift() }  //限制历史列表范围，考虑复杂度!
            saveHistoryCache(mainHistoryList)  //每播放一首歌就需要重新缓存
            var loader = pageHomeView.repeater.itemAt(3).item.historyListView  //每播放一首歌就需要改变历史视图
            loader.musicList = mainHistoryList.slice().reverse()  //副本颠倒
            loader.songCount = mainHistoryList.length
        }
    }
    property var mainAllMusicList: []  //当前歌单/专辑列表
    onMainAllMusicListChanged: {
        //清空随机历史列表和index
        mainRandomHistoryList = []
        mainRandomHistoryListIndex = -1
    }
    property int mainAllMusicListIndex: -1  //当前歌单/专辑列表的index
    property string mainModelName: ""  //播放模式
    property var mainRandomHistoryList: []  //随机模式下的历史列表
    property int mainRandomHistoryListIndex: -1  //随机模式下的历史列表的index

    width: mWINDOW_WIDTH
    height: mWINDOW_HEIGHT
    visible: true
    title: qsTr("Cloud Music Player")

    ColumnLayout {
        anchors.fill: parent
        //组件之间的边距
        spacing: 0
        LayoutTopView {
            id: layoutTopView
        }

        //中间内容
        PageHomeView {
            id: pageHomeView
        }
        //歌曲的细节视图。唱片旋转，歌词。
        PageDetailView {
            id: pageDetailView
            visible: false
        }

        //底部工具栏
        LayoutBottomView {
            id: layoutBottomView
        }
    }

    MediaPlayer {
        id: mediaPlayer
        property var times: []  //歌词的各个时间段
        audioOutput: audioOutPut
        //拖动，有延迟，应该是内部position赋值之后继续计时，但是没有实时传出数据
        onPositionChanged: {
            layoutBottomView.timeText = getTime(mediaPlayer.position/1000)+"/"+getTime(mediaPlayer.duration/1000)

            if (times.length>0) {
                var count = times.filter(time=>time<mediaPlayer.position).length  //对数据进行筛选
                pageDetailView.current = (count===0) ? 0: count-1
            }
        }

        onMediaStatusChanged: {
            switch(mediaPlayer.mediaStatus) {
            case MediaPlayer.LoadingMedia:
                //正在加载媒体,正在播放
                console.log("加载动画")
                break;
            case MediaPlayer.LoadedMedia:
                //媒体加载完成，播放完成
                console.log("上一首播放完毕")
                break;
            case MediaPlayer.BufferingMedia:
                //数据正在缓冲
                console.log("BufferingMedia......")
                break;
            case MediaPlayer.BufferedMedia:
                //数据缓冲完成
                layoutBottomView.slider.handleRec.imageLoading.visible = false
                pageDetailView.cover.isRotating = true
                console.log("结束加载动画，开始播放")
                break;
            case MediaPlayer.StalledMedia:
                //缓冲数据被打断
                console.log(5)
                break;
            case MediaPlayer.EndOfMedia:
                //当前歌曲结束
                console.log("自动播放下一首")
                MyJs.switchSong(true, layoutBottomView.modePlay, true)
                break;
            case MediaPlayer.InvalidMedia:
                console.log("The media cannot be played")
                break;
            }
        }
    }
    AudioOutput {
        id: audioOutPut
    }

    //添加主窗口快捷键，空格暂停
    Shortcut {
        context: Qt.WindowShortcut
        sequence: "space"
        onActivated: {
            switch(mediaPlayer.playbackState) {
            case MediaPlayer.PlayingState:
                mediaPlayer.pause()
                layoutBottomView.playStateSource = "qrc:/images/stop.png"
                pageDetailView.cover.isRotating = false
                console.log("歌曲已暂停")
                break;
            case MediaPlayer.PausedState:
                mediaPlayer.play()
                console.log("歌曲继续播放")
                layoutBottomView.playStateSource = "qrc:/images/pause.png"
                pageDetailView.cover.isRotating = true
                break;
            }
        }
    }
    //添加主窗口快捷键，上一首
    Shortcut {
        context: Qt.WindowShortcut
        sequence: "Ctrl+Alt+left"
        onActivated: {
            MyJs.switchSong(false, layoutBottomView.modePlay, false)
        }
    }
    //添加主窗口快捷键，下一首
    Shortcut {
        context: Qt.WindowShortcut
        sequence: "Ctrl+Alt+Right"
        onActivated: {
            MyJs.switchSong(true, layoutBottomView.modePlay, false)
        }
    }
}
