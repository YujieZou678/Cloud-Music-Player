//MusicRoundImage.qml

import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

Item {
    property string imgSrc: ""
    property int borderRadius: 5

    Image{
        id:image
        anchors.centerIn: parent
        source:imgSrc
        smooth: true
        visible: false
        width: parent.width
        height: parent.height
        fillMode: Image.PreserveAspectCrop
        antialiasing: true
        onStatusChanged: {
            switch (image.status) {
            case Image.Ready:
                imageLoading.visible = false
                break;
            case Image.Loading:
                //加载缓冲的画面
                imageLoading.visible = true
                break;
            case Image.Error:
                console.log("加载超时......")
                break;
            }
        }
    }

    //缓冲画面
    Image {
        id: imageLoading
        source: "qrc:/images/loading.png"
        width: 20; height: 20
        visible: false
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

    Rectangle{
        id:mask
        color: "black"
        anchors.fill: parent
        radius: borderRadius
        visible: false
        smooth: true
        antialiasing: true
    }

    OpacityMask{
        anchors.fill:image
        source: image
        maskSource: mask
        visible: true
        antialiasing: true
    }
}

