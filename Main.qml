import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtMultimedia

ApplicationWindow {
    id: window

    property int mWINDOW_WIDTH: 1200
    property int mWINDOW_HEIGHT: 800
    property string mFONT_FAMILY: "微软雅黑"

    property alias mediaPlayer: mediaPlayer
    property alias layoutBottomView: layoutBottomView
    property alias pageHomeView: pageHomeView

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
        onPositionChanged: {
            layoutBottomView.timeText = getTime(mediaPlayer.position/1000)+"/"+getTime(mediaPlayer.duration/1000)
        }
    }
    AudioOutput {
        id: audioOutPut
    }
}
