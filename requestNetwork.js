//网络请求模板函数，参数说明：1.请求路径 2.槽函数（获得数据之后处理该数据的函数）
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

//播放音乐模板函数，参数说明：1.歌曲id 2.歌曲名字+作者 3.槽函数
function playMusic(targetId, nameText, dataHandle) {
    console.log("id: "+targetId+" 正在播放音乐")
    var url = "/song/url?id="+targetId

    postRequest(url, dataHandle)

    //歌名与信息先显示，加载后才有声音
    layoutBottomView.nameText = nameText
    layoutBottomView.timeText = getTime(window.mediaPlayer.position/1000)+"/"+getTime(window.mediaPlayer.duration/1000)
    layoutBottomView.slider.handleRec.imageLoading.visible = true
}




