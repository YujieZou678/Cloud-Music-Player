/*
author: zouyujie
date: 2023.11.18
function: 中间内容，区别于top和bottom
*/
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQml

RowLayout {

    property int defaultIndex: 0

    property var qmlList: [
        {icon:"recommend-white",value:"推荐内容",qml:"DetailRecommendPageView",menu:true},
        {icon:"cloud-white",value:"搜索音乐",qml:"DetailSearchPageView",menu:true},
        {icon:"local-white",value:"本地音乐",qml:"DetailLocalPageView",menu:true},
        {icon:"history-white",value:"播放历史",qml:"DetailHistoryPageView",menu:true},
        {icon:"favorite-big-white",value:"我喜欢的",qml:"DetailFavoritePageView",menu:true},
        {icon:"",value:"",qml:"DetailPlayListPageView",menu:false}]

    spacing: 0

    Frame{

        Layout.preferredWidth: 200
        Layout.fillHeight: true
        padding: 0
        background: Rectangle {
            color: "#AA00AAAA"
        }

        ColumnLayout{
            anchors.fill: parent

            Item{
                Layout.fillWidth: true
                Layout.preferredHeight: 150
                //见MusicRoundImage.qml
                MusicRoundImage{
                        anchors.centerIn:parent
                        height: 100
                        width:100
                        borderRadius: 100
                        imgSrc: "qrc:/images/12.png"
                    }
                }

            ListView{
                id:menuView
                Layout.fillHeight: true
                Layout.fillWidth: true
                model: ListModel{
                    id:menuViewModel
                }
                delegate: menuViewDelegate
                highlight:Rectangle{
                    color: "#aa73a7ab"
                }
            }

            Component{
                id:menuViewDelegate
                Rectangle{
                    id:menuViewDelegateItem
                    height: 50
                    width: 200
                    color: "#AA00AAAA"
                    RowLayout{
                        anchors.fill: parent
                        anchors.centerIn: parent
                        spacing:15
                        Item{
                            width: 30
                        }

                        Image{
                            source: "qrc:/images/"+icon
                            Layout.preferredHeight: 20
                            Layout.preferredWidth: 20
                        }

                        Text{
                            text:value
                            Layout.fillWidth: true
                            height:50
                            font.family: window.mFONT_FAMILY
                            font.pointSize: 12
                            color: "#ffffff"
                        }
                    }  //end RowLayout

                    MouseArea {
                        anchors.fill: parent
                        //启动鼠标悬浮功能
                        hoverEnabled: true
                        onEntered: {
                            color="#aa73a7ab"
                        }
                        onExited: {
                            color="#AA00AAAA"
                        }

                        onClicked:{
                            //只要点击菜单，第5个.qml就不可见
                            repeater.itemAt(5).visible = false

                            //item.ListView.view = 该item对应的ListView
                            repeater.itemAt(menuViewDelegateItem.ListView.view.currentIndex).visible =false
                            //改变当前项索引
                            menuViewDelegateItem.ListView.view.currentIndex = index
                            var loader = repeater.itemAt(menuViewDelegateItem.ListView.view.currentIndex)
                            loader.visible=true
                            loader.source = qmlList[index].qml+".qml"
                        }
                    }
                }
            }  //end Component
            //默认显示第一个，即“推荐内容“
            Component.onCompleted: {
                menuViewModel.append(qmlList.filter(item=>item.menu))
                //第一个Loader
                var loader = repeater.itemAt(defaultIndex)
                loader.visible=true
                loader.source = qmlList[defaultIndex].qml+".qml"
                //索引
                menuView.currentIndex = defaultIndex

                //后台自动加载第五个qml组件
                repeater.itemAt(5).source = qmlList[5].qml+".qml"
            }
        }  //end ColumnLayout
    }  //end Frame

    Repeater{
        id:repeater
        model: qmlList.length
        //加载一个qml组件
        Loader{
            visible: false
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }

    function showPlayList(targetId="", targetType="10") {
        //item.ListView.view = 该item对应的ListView
        repeater.itemAt(menuView.currentIndex).visible =false
        var loader = repeater.itemAt(5)
        loader.visible=true
        //靠loader为其加载的qml组件里面的赋值
        loader.item.targetType = targetType
        loader.item.targetId = targetId
        loader.item.playListListView.imageLoadingVisible = true
        loader.item.playListListView.listViewVisible = false
        loader.item.playListListView.pageButtonVisible = false
    }
//    function hidePlayList() {
//        //item.ListView.view = 该item对应的ListView
//        repeater.itemAt(menuView.currentIndex).visible =true
//        var loader = repeater.itemAt(5)
//        loader.visible=false
//    }
}
