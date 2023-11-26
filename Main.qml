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

    property alias mediaPlayer: mediaPlayer
    property alias layoutBottomView: layoutBottomView
    property alias pageHomeView: pageHomeView

    //用于列表播放后，切歌
    property var mainHistoryList: []   //播放历史列表
    onMainHistoryListChanged: {  //一开始自动会执行一次
        if (mainHistoryList.length > 0) {
            if(mainPlayListIndex === mainHistoryList.length - 2) {
                 mainPlayListIndex = mainHistoryList.length - 1
            }
            else {
                //分叉处理
                mainHistoryList.splice(mainPlayListIndex+1, (mainHistoryList.length-mainPlayListIndex-2))
                mainPlayListIndex = mainHistoryList.length - 1
            }
        }
    }
    property int mainPlayListIndex: -1  //当前播放列表的index,一般情况在历史列表末尾
    property var mainAllMusicList: []  //当前歌单/专辑列表
    property int mainAllMusicListIndex: -1  //当前歌单/专辑列表的index
    property string mainModelName: ""  //播放模式

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

        //底部工具栏
        LayoutBottomView {
            id: layoutBottomView
        }
    }

    MediaPlayer {
        id: mediaPlayer
        audioOutput: audioOutPut
        //拖动，有延迟，应该是内部position赋值之后继续计时，但是没有实时传出数据
        onPositionChanged: {
            layoutBottomView.timeText = getTime(mediaPlayer.position/1000)+"/"+getTime(mediaPlayer.duration/1000)
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
                console.log("歌曲已暂停")
                break;
            case MediaPlayer.PausedState:
                mediaPlayer.play()
                console.log("歌曲继续播放")
                layoutBottomView.playStateSource = "qrc:/images/pause.png"
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
