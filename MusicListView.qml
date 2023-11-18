//MusicListView

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Shapes

Frame {

    //需要赋值
    property var musicList: []
    property int songCount: 0

    property int currentPage: 0
    property int pageSize: 60
    property alias scrollBar: scrollBar

    //视觉逻辑
    property alias imageLoadingVisible: imageLoading.visible
    property alias listViewVisible: listView.visible
    property alias pageButtonVisible: pageButton.visible

    //信号，切换页数
    signal switchPage(int offset)

    //一开始会默认赋值一次
    onMusicListChanged: {
        imageLoading.visible = false
        listView.visible = true
        pageButton.visible = true

        listViewModel.clear()
        listViewModel.append(musicList)
    }

    //缓冲画面
    Image {
        id: imageLoading
        visible: true
        source: "qrc:/images/loading.png"
        width: 30; height: 30
        anchors.centerIn: parent
    }
    RotationAnimation {
        target: imageLoading
        from: 0
        to: 360
        duration: 2000
        running: true
        loops: Animation.Infinite
    }

    Layout.fillHeight: true
    Layout.fillWidth: true
    //超出部分隐藏
    clip: true
    padding: 0
    background: Rectangle {
        //底层不能是无色，否则上层没效果，默认为white
        //color: "lightyellow"
    }

    ListView {
        id: listView
        visible: false
        anchors.fill: parent
        anchors.bottomMargin: 58
        model: ListModel {
            id: listViewModel
        }
        delegate: listViewDelegate
        ScrollBar.vertical: ScrollBar {
            id: scrollBar
            anchors.right: parent.right
        }
        header: listViewHeader
        highlight: Rectangle {
            color: "#f0f0f0"
        }
        highlightMoveDuration: 0
        highlightResizeDuration: 0
    }

    //音乐数据列表
    Component {
        id: listViewDelegate
        Rectangle {
            id: listViewDelegateItem
            height: 45
            width: listView.width
            //将颜色置为无色，方便显示第二层hightlight的颜色
            color: "#00000000"

            //画边框
            Shape {
                id: shape
                anchors.fill: parent
                ShapePath {
                    strokeWidth: 0
                    strokeColor: "#50000000"
                    strokeStyle: ShapePath.SolidLine
                    startX: 0
                    startY: listViewDelegateItem.height
                    PathLine {
                        x:0; y:listViewDelegateItem.height
                    }
                    PathLine {
                        x:shape.width; y:listViewDelegateItem.height
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onEntered: {
                    color = "#f0f0f0"
                }
                onExited: {
                    color = "#00000000"
                }
                onClicked: {
                    listView.currentIndex = index
                }

                //内容
                RowLayout {
                    width: parent.width; height: parent.height
                    spacing: 15
                    x: 5
                    //序号
                    Text {
                        id: indexNumber
                        text: index+1 + pageSize*currentPage
                        horizontalAlignment: Text.AlignHCenter
                        Layout.preferredWidth: parent.width*0.05
                        font.family: window.mFONT_FAMILY
                        font.pointSize: 13
                        color: "black"
                        elide: Qt.ElideRight
                    }
                    //最后加载index
//                    Component.onCompleted: {
//                        indexNumber.text = index+1 + pageSize*currentPage
//                    }

                    Text {
                        text: name
                        //horizontalAlignment: Text.AlignHCenter
                        Layout.preferredWidth: parent.width*0.4
                        font.family: window.mFONT_FAMILY
                        font.pointSize: 13
                        color: "black"
                        elide: Qt.ElideRight
                    }
                    Text {
                        text: artist
                        horizontalAlignment: Text.AlignHCenter
                        Layout.preferredWidth: parent.width*0.15
                        font.family: window.mFONT_FAMILY
                        font.pointSize: 13
                        color: "black"
                        elide: Qt.ElideRight
                    }
                    Text {
                        text: album
                        horizontalAlignment: Text.AlignHCenter
                        Layout.preferredWidth: parent.width*0.15
                        font.family: window.mFONT_FAMILY
                        font.pointSize: 13
                        color: "black"
                        elide: Qt.ElideRight
                    }

                    Item {
                        Layout.preferredWidth: parent.width*0.15
                        RowLayout {
                            anchors.centerIn: parent
                            MusicIconButton {
                                iconSource: "qrc:/images/pause.png"
                                iconWidth: 16; iconHeight: 16
                                toolTip: "播放"
                                onClicked: {
                                    playMusic(index)
                                }
                            }
                            MusicIconButton {
                                iconSource: "qrc:/images/favorite.png"
                                iconWidth: 16; iconHeight: 16
                                toolTip: "喜欢"
                                onClicked: {
                                    //
                                }
                            }
                            MusicIconButton {
                                iconSource: "qrc:/images/clear.png"
                                iconWidth: 16; iconHeight: 16
                                toolTip: "删除"
                                onClicked: {
                                    //
                                }
                            }
                        }
                    }  //end Item

                }  //end RowLayout
            }  //end MouseArea
        }  //end Rectangle
    }

    //header
    Component {
        id: listViewHeader
        Rectangle {
            color: "#00AAAA"
            height: 45
            width: listView.width
            RowLayout {
                width: parent.width; height: parent.height
                spacing: 15
                x: 5
                Text {
                    text: "序号"
                    horizontalAlignment: Text.AlignHCenter
                    Layout.preferredWidth: parent.width*0.05
                    font.family: window.mFONT_FAMILY
                    font.pointSize: 13
                    color: "black"
                    elide: Qt.ElideRight
                }
                Text {
                    text: "歌名"
                    //horizontalAlignment: Text.AlignHCenter
                    Layout.preferredWidth: parent.width*0.4
                    font.family: window.mFONT_FAMILY
                    font.pointSize: 13
                    color: "black"
                    elide: Qt.ElideRight
                }
                Text {
                    text: "歌手"
                    horizontalAlignment: Text.AlignHCenter
                    Layout.preferredWidth: parent.width*0.15
                    font.family: window.mFONT_FAMILY
                    font.pointSize: 13
                    color: "black"
                    elide: Qt.ElideRight
                }
                Text {
                    text: "专辑"
                    horizontalAlignment: Text.AlignHCenter
                    Layout.preferredWidth: parent.width*0.15
                    font.family: window.mFONT_FAMILY
                    font.pointSize: 13
                    color: "black"
                    elide: Qt.ElideRight
                }
                Text {
                    text: "操作"
                    horizontalAlignment: Text.AlignHCenter
                    Layout.preferredWidth: parent.width*0.15
                    font.family: window.mFONT_FAMILY
                    font.pointSize: 13
                    color: "black"
                    elide: Qt.ElideRight
                }
            }
        }
    }  //end header

    //pageButton
    Item {
        id: pageButton
        //如果列表长度为0,则没有pageButton
        visible: false
        //visible: musicList.length===0 ? false:true
        height: 40; width: parent.width
        anchors {
            top: listView.bottom
            topMargin: 20
        }

        ButtonGroup {
            //定义一系列按钮的逻辑
            buttons: buttons.children
        }

        RowLayout {
            id: buttons
            //让以下组件居中
            anchors.centerIn: parent
            Repeater {
                id: repeater
                model: songCount/pageSize>9 ? 9: songCount/pageSize
                Button {
                    Text {
                        anchors.fill: parent
                        text: modelData+1
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font {
                            family: window.mFONT_FAMILY
                            pointSize: 14
                        }
                        color: checked ? "#497563":"black"
                    }
                    background: Rectangle {
                        implicitHeight: 30; implicitWidth: 30
                        color: checked ? "#e2f0f8":"#20e9f4ff"
                        radius: 3
                    }
                    checkable: true
                    checked: index === currentPage
                    onClicked: {
                        //换页
                        if (currentPage===index) return
                        imageLoading.visible = true
                        listView.visible = false
                        currentPage = index
                        //切换页数之后视图自动到顶部
                        scrollBar.position = 0
                        switchPage(index*pageSize)
                    }
                }
            }
        }
    }

    function playMusic(index = 0) {
        if (musicList.length<1) return
        var id = musicList[index].id
        console.log("id: "+id+" 正在播放音乐")
        var url = "/song/url?id="+id

        postRequest(url, dataHandle)
    }

    function dataHandle(_data) {
        var data = JSON.parse(_data).data
        //赋值
        mediaPlayer.source = data[0].url
        layoutBottomView.nameText = musicList[index].name+"-"+musicList[index].artist
        layoutBottomView.timeText = getTime(window.mediaPlayer.position/1000)+"/"+getTime(window.mediaPlayer.duration/1000)
        layoutBottomView.playStateSource = "qrc:/images/pause.png"
        mediaPlayer.play()
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
