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

//播放音乐模板函数，参数说明：1.歌曲id 2.歌曲名字 3.作者 4.图片信息地址
function playMusic(targetId, name, artist, picUrl) {
    console.log("id: "+targetId+" 正在播放音乐")
    //本地音乐
    var check = targetId.split(":")
    if (check[0] === "file") {
        //本地音乐
        mediaPlayer.source = targetId
        layoutBottomView.playStateSource = "qrc:/images/pause.png"
        mediaPlayer.play()
    }
    else {
        //网络音乐
        var url = "/song/url?id="+targetId
        postRequest(url, dataHandle)

        //得到歌词
        var url_ = "/lyric?id="+targetId
        postRequest(url_, getLyric)

        layoutBottomView.slider.handleRec.imageLoading.visible = true  //缓冲加载界面可视,本地不需要，否则有bug
    }

    //歌名与信息先显示，加载后才有声音
    if (artist === "") {
        layoutBottomView.nameText = name + "-" + "未知"
        pageDetailView.artistText = "未知"
    } else {
        layoutBottomView.nameText = name + "-" + artist
        pageDetailView.artistText = artist
    }
    layoutBottomView.timeText = getTime(window.mediaPlayer.position/1000)+"/"+getTime(window.mediaPlayer.duration/1000)
    layoutBottomView.musicCoverSrc = picUrl
    pageDetailView.nameText = name
}
function dataHandle(_data) {  //上面的槽函数
    var data = JSON.parse(_data).data
    //赋值
    mediaPlayer.source = data[0].url
    layoutBottomView.playStateSource = "qrc:/images/pause.png"
    mediaPlayer.play()
}
function getLyric(_data) {  //处理歌词
    var data = JSON.parse(_data).lrc.lyric  //歌词
    if (data.length < 1) return
    var lyrics = data.replace(/\[.*\]/gi,"").split("\n")  //得到每一行的歌词

    if (lyrics.length>0) pageDetailView.lyricsList = lyrics

    var times = []
    data.replace(/\[.*\]/gi, function(match, index){  //match为替换的data
        //match [00:00]
        if (match.length>2) {
            var time = match.substr(1, match.length-2)  //substr分割字符串
            var arr = time.split(":")
            var timeValue = arr.length>0 ? parseInt(arr[0])*60*1000 : 0
            arr = arr.length>1 ? arr[1].split("."):[0,0]
            timeValue += arr.length>0 ? parseInt(arr[0]*1000) : 0
            timeValue += arr.length>1 ? parseInt(arr[1]) : 0

            times.push(timeValue)
        }
    })
    mediaPlayer.times = times
}

//列表切换歌曲模板函数,参数：1.需要判断是切换上一首还是下一首 2.播放模式 3.是否为自动切歌
function switchSong(isNextSong, modePlay, ifAutoSwitch) {
    if (mainAllMusicList < 1) {  //判断此时是否有列表
        console.log("此时没有列表播放")
        return
    }

    if (!ifAutoSwitch) {
        if (modePlay === "循环播放") { modePlay = "顺序播放" }  //如果手动切歌，循环播放相当于顺序播放
    }

    switch (modePlay) {
    case "顺序播放":
        /* 顺序播放 */
        if (isNextSong) {  //下一首
            mainAllMusicListIndex = (mainAllMusicListIndex + 1 + mainAllMusicList.length)%mainAllMusicList.length
        }
        else {  //上一首
            mainAllMusicListIndex = (mainAllMusicListIndex - 1 + mainAllMusicList.length)%mainAllMusicList.length
        }

        //播放
        var nextSong = mainAllMusicList[mainAllMusicListIndex]
        var targetId = nextSong.id
        var picUrl = nextSong.picUrl
        playMusic(targetId, nextSong.name, nextSong.artist, picUrl)
        changeHistoryList(nextSong)  //添加历史

        //切换列表高亮块
        if (mainModelName === "DetailSearchPageView") {  //判断属于哪个视图的歌单
            var loader = pageHomeView.repeater.itemAt(1)
            loader.item.musicListView.listView.currentIndex = mainAllMusicListIndex
        } else if (mainModelName === "DetailPlayListPageView") {
            //还要判断是显示哪个列表视图
            var loader = []
            if (pageHomeView.ifPlaying === 0) { loader = pageHomeView.repeater.itemAt(5) }
            else if (pageHomeView.ifPlaying === 1) { loader = pageHomeView.repeater.itemAt(6) }
            loader.item.playListListView.listView.currentIndex = mainAllMusicListIndex
        } else if (mainModelName === "DetailLocalPageView") {
            var loader = pageHomeView.repeater.itemAt(2)
            loader.item.localListView.listView.currentIndex = mainAllMusicListIndex
        }
        break;
    case "随机播放":
        /* 随机播放 */
        if (isNextSong) {   //下一首
            var randomIndex = Math.floor(Math.random()*mainAllMusicList.length)  //歌单index为随机
            if (mainAllMusicListIndex === randomIndex) {  //随机可能重复
                mainAllMusicListIndex = (mainAllMusicListIndex+mainAllMusicList.length+1)%mainAllMusicList.length
            } else { mainAllMusicListIndex = randomIndex }
        }
        else {  //上一首
            //
        }

        //播放
        var nextSong = mainAllMusicList[mainAllMusicListIndex]
        var targetId = nextSong.id
        var picUrl = nextSong.picUrl
        playMusic(targetId, nextSong.name, nextSong.artist, picUrl)
        addHistoryItem(nextSong)  //添加历史

        //切换列表高亮块,需要判断这首歌是否属于当前歌单
        for (var i = 0; i<mainAllMusicList.length; i++) {  //在完整的歌单列表顺序查找,最大遍历60次
            if (targetId===mainAllMusicList[i].id) {
                if (mainModelName === "DetailSearchPageView") {  //判断属于哪个视图的歌单
                    var loader = pageHomeView.repeater.itemAt(1)
                    loader.item.musicListView.listView.currentIndex = i
                } else if (mainModelName === "DetailPlayListPageView") {
                    //还要判断是显示哪个列表视图
                    var loader = []
                    if (pageHomeView.ifPlaying === 0) { loader = pageHomeView.repeater.itemAt(5) }
                    else if (pageHomeView.ifPlaying === 1) { loader = pageHomeView.repeater.itemAt(6) }
                    loader.item.playListListView.listView.currentIndex = i
                } else if (mainModelName === "DetailLocalPageView") {
                    var loader = pageHomeView.repeater.itemAt(2)
                    loader.item.localListView.listView.currentIndex = i
                }

                break;
            }
        }
        break;
    case "循环播放":
        /* 循环播放 */
        var nextSong = mainAllMusicList[mainAllMusicListIndex]
        var targetId = nextSong.id
        var picUrl = nextSong.picUrl
        playMusic(targetId, nextSong.name, nextSong.artist, picUrl)
        break;
    }
}

//用Js对Json数组进行格式化,参数：Json数组，各个歌曲
function getFormatData(songs) {
    return songs.map(item=>{
                         return {
                             id: item.id+"",
                             name: item.name,
                             artist: item.ar[0].name,
                             album: item.al.name,
                             picUrl: item.al.picUrl
                         }
                     })
}

//为播放历史列表添加值，只有这样才能触发onChange
function addHistoryItem(newItem) {
    var temp = mainHistoryList
    temp.push(newItem)
    mainHistoryList = temp
}

//每播放一首歌对历史列表进行检索，然后处理
function changeHistoryList(item) {
    var index = -1  //item位于历史列表的索引

    for (var i in mainHistoryList) {
        if (item.id === mainHistoryList[i].id) {
            index = i
            break
        }
    }

    if (index !== -1) {
        //播放的歌曲存在于历史列表
        var temp = mainHistoryList[index]
        mainHistoryList.splice(index, 1)  //删除
        addHistoryItem(temp)  //重新添加到末尾
    }
    else {
        //播放的歌曲不存在于历史列表
        addHistoryItem(item)
    }
}




