/*
author: zouyujie
date: 2024.2.18
function: 背景。
*/
import QtQuick
import Qt5Compat.GraphicalEffects

Item {

    //逻辑：两张图片切换，实现无缝衔接。
    property alias backgroundImageSrc1: backgroundImage1.source
    property alias backgroundImageSrc2: backgroundImage2.source

    property bool selectImage: true  //判断选哪个image,true为1,false为2

    Image {
        id: backgroundImage1
        source: "qrc:/images/player"
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        cache: true
        visible: false  //不是真正的对象
        onStatusChanged: {
            switch (status) {
            case Image.Ready:
                realBackgroundImage1.visible = true
                realBackgroundImage2.visible = false
                break;
            case Image.Loading:
                realBackgroundImage2.visible = true
                realBackgroundImage1.visible = false
                break;
            case Image.Error:
                console.log("背景图片加载错误......")
                break;
            }
        }
    }

    Image {
        id: backgroundImage2
        source: "qrc:/images/player"
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        cache: true
        visible: false  //不是真正的对象
        onStatusChanged: {
            switch (status) {
            case Image.Ready:
                realBackgroundImage2.visible = true
                realBackgroundImage1.visible = false
                break;
            case Image.Loading:
                realBackgroundImage1.visible = true
                realBackgroundImage2.visible = false
                break;
            case Image.Error:
                console.log("背景图片加载错误......")
                break;
            }
        }
    }

    ColorOverlay {  //颜色滤镜
        id: backgroundImageOverlay1
        anchors.fill: backgroundImage1
        source: backgroundImage1
        color: "#35000000"
        visible: false
    }

    FastBlur {  //模糊，真正的对象
        id: realBackgroundImage1
        anchors.fill: backgroundImageOverlay1
        source: backgroundImageOverlay1
        radius: 80
        visible: false
    }

    ColorOverlay {
        id: backgroundImageOverlay2
        anchors.fill: backgroundImage2
        source: backgroundImage2
        color: "#35000000"
        visible: false
    }

    FastBlur {
        id: realBackgroundImage2
        anchors.fill: backgroundImageOverlay2
        source: backgroundImageOverlay2
        radius: 80
        visible: false
    }
}
