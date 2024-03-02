/*
author: zouyujie
date: 2023.11.18
function: 歌曲细节。包括：唱片旋转，歌词滚动。
*/
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQml

Item {
    property string nameText: "云坠入雾里"
    property string artistText: "云坠入雾里"

    property alias cover: cover
    property alias lyricsList: lyricView.lyrics
    property alias current: lyricView.current

    Layout.fillHeight: true
    Layout.fillWidth: true

    RowLayout {
        anchors.fill: parent

        Frame {
            //Layout.preferredWidth: parent.width*0.45
            Layout.fillWidth: true
            Layout.fillHeight: true

            background: Rectangle {
                color: "#00000000"
            }

            Text {
                id: name
                text: nameText
                anchors {
                    bottom: artist.top
                    bottomMargin: 20
                    horizontalCenter: parent.horizontalCenter
                }
                font {
                    family: mFONT_FAMILY
                    pointSize: 16
                }
                color: "#eeffffff"
            }
            Text {
                id: artist
                text: artistText
                anchors {
                    bottom: cover.top
                    bottomMargin: 50
                    topMargin: 20
                    horizontalCenter: parent.horizontalCenter
                }
                font {
                    family: mFONT_FAMILY
                    pointSize: 14
                }
                color: "#aaffffff"
            }
            MusicBorderImage {
                id: cover
                anchors.centerIn: parent
                width: parent.width*0.6
                height: width
                borderRadius: width
                imgSrc: layoutBottomView.musicCoverSrc
                imageLoading.width: 35
                imageLoading.height: 35
            }

            Text {
                id: lyrics
                visible: layoutTopView.isSmallWindow
                text: lyricView.lyrics[lyricView.current] ? lyricView.lyrics[lyricView.current]:"暂无歌词"
                anchors {
                    top: cover.bottom
                    topMargin: 50
                    horizontalCenter: parent.horizontalCenter
                }
                font {
                    family: mFONT_FAMILY
                    pointSize: 14
                }
                color: "#aaffffff"
            }
        }

        Frame {
            visible: !layoutTopView.isSmallWindow
            Layout.preferredWidth: parent.width*0.55
            Layout.fillHeight: true
            background: Rectangle {
                color: "#0000AAAA"
            }

            MusicLyricView {
                id: lyricView
                anchors.fill: parent
            }
        }
    }
}
