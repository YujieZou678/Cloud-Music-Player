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
    var url = "/song/url?id="+targetId

    postRequest(url, dataHandle)

    //歌名与信息先显示，加载后才有声音
    if (artist === "") {
        layoutBottomView.nameText = name + "-" + "未知"
        pageDetailView.artistText = "未知"
    } else {
        layoutBottomView.nameText = name + "-" + artist
        pageDetailView.artistText = artist
    }
    layoutBottomView.timeText = getTime(window.mediaPlayer.position/1000)+"/"+getTime(window.mediaPlayer.duration/1000)
    layoutBottomView.slider.handleRec.imageLoading.visible = true
    layoutBottomView.musicCoverSrc = picUrl
    pageDetailView.nameText = name
    //得到歌词
    var url_ = "/lyric?id="+targetId
    postRequest(url_, getLyric)
}
function dataHandle(_data) {  //上面的槽函数
    var data = JSON.parse(_data).data
    //赋值
    mediaPlayer.source = data[0].url
    layoutBottomView.playStateSource = "qrc:/images/pause.png"
    mediaPlayer.play()
}
function getLyric(_data) {
    var data = JSON.parse(_data).lrc.lyric  //歌词
    if (data.length < 1) return
    var lyrics = data.replace(/\[.*\]/gi,"").split("\n")

    if (lyrics.length>0) pageDetailView.lyricsList = lyrics

    var times = []
    data.replace(/\[.*\]/gi, function(match, index){
        //match [00:00:00]
        if (match.length>2) {
            var time = match.substr(1, match.length-2)
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
    if (mainHistoryList.length < 1) {  //判断此时是否有列表
        console.log("此时没有列表播放")
        return
    }

    if (!ifAutoSwitch) {
        if (modePlay === "循环播放") { modePlay = "顺序播放" }  //如果手动切歌，循环播放相当于顺序播放
    }

    switch (modePlay) {
    case "顺序播放":
        /* 顺序播放 */
        //得到下一首歌的index
        if (isNextSong) {   //判断是上一首还是下一首
            if (mainPlayListIndex === mainHistoryList.length-1) {  //判断此时index是不是在历史列表末尾
                if (mainAllMusicList.length === 0) { console.log("此时没有列表播放"); return }
                mainAllMusicListIndex = (mainAllMusicListIndex+mainAllMusicList.length+1)%mainAllMusicList.length
                addHistoryItem(mainAllMusicList[mainAllMusicListIndex])  //历史列表增加,增加什么就播放什么
            }
            else { mainPlayListIndex = mainPlayListIndex + 1 }
        }
        else {
            if (mainPlayListIndex === 0) { console.log("此时没有播放记录"); return }
            mainPlayListIndex = mainPlayListIndex - 1
        }

        //播放
        var nextSong = mainHistoryList[mainPlayListIndex]
        var targetId = nextSong.id
        var picUrl = nextSong.picUrl
        playMusic(targetId, nextSong.name, nextSong.artist, picUrl)

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
                }
                break;
            }
        }
        break;
    case "随机播放":
        /* 随机播放 */
        //得到下一首歌的index
        if (isNextSong) {   //判断是上一首还是下一首
            if (mainPlayListIndex === mainHistoryList.length-1) {  //判断此时index是不是在历史列表末尾
                if (mainAllMusicList.length === 0) { console.log("此时没有列表播放"); return }
                var randomIndex = Math.floor(Math.random()*mainAllMusicList.length)  //歌单index为随机
                if (mainAllMusicListIndex === randomIndex) {  //随机可能重复
                    mainAllMusicListIndex = (mainAllMusicListIndex+mainAllMusicList.length+1)%mainAllMusicList.length
                } else { mainAllMusicListIndex = randomIndex }
                addHistoryItem(mainAllMusicList[mainAllMusicListIndex])  //历史列表增加,增加什么就播放什么
            }
            else { mainPlayListIndex = mainPlayListIndex + 1 }
        }
        else {
            if (mainPlayListIndex === 0) { console.log("此时没有播放记录"); return }
            mainPlayListIndex = mainPlayListIndex - 1
        }

        //播放
        var nextSong = mainHistoryList[mainPlayListIndex]
        var targetId = nextSong.id
        var nameText = nextSong.name+"-"+nextSong.artist
        var picUrl = nextSong.picUrl
        playMusic(targetId, nameText, picUrl)

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
                }
                break;
            }
        }
        break;
    case "循环播放":
        /* 循环播放 */
        var nextSong = mainHistoryList[mainPlayListIndex]  //播放同一首歌
        var targetId = nextSong.id
        var nameText = nextSong.name+"-"+nextSong.artist
        var picUrl = nextSong.picUrl
        playMusic(targetId, nameText, picUrl)
        break;
    }
}

//用Js对Json数组进行格式化,参数：Json数组，各个歌曲
function getFormatData(songs) {
    return songs.map(item=>{
                         return {
                             id: item.id,
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




