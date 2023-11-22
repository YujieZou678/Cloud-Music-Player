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
    //用于列表播放后，自动播放下一首
    property var mainMusicList: []
    property int mainMusicListIndex: 0
    property string mainModelName: ""

    property alias layoutBottomView: layoutBottomView
    property alias pageHomeView: pageHomeView

    width: mWINDOW_WIDTH
    height: mWINDOW_HEIGHT
    visible: true
    title: qsTr("Cloud Music Player")
    //添加主窗口快捷键
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
                if (mainMusicList.length < 1) return
                mainMusicListIndex = (mainMusicListIndex+mainMusicList.length+1)%mainMusicList.length
                var nextSong = mainMusicList[mainMusicListIndex]
                var targetId = nextSong.id
                var nameText = nextSong.name+"-"+nextSong.artist
                MyJs.playMusic(targetId, nameText, dataHandle)
                //切换列表高亮块
                if (mainModelName === "DetailSearchPageView") {
                    var loader = pageHomeView.repeater.itemAt(1)
                    loader.item.musicListView.listView.currentIndex = mainMusicListIndex
                } else if (mainModelName === "DetailPlayListPageView") {
                    var loader = pageHomeView.repeater.itemAt(5)
                    loader.item.playListListView.listView.currentIndex = mainMusicListIndex
                }
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

    function dataHandle(_data) {
        var data = JSON.parse(_data).data
        //赋值,播放音乐
        mediaPlayer.source = data[0].url
        layoutBottomView.playStateSource = "qrc:/images/pause.png"
        mediaPlayer.play()
    }
}
