 功能（基础功能之外的,自己加的）：
 
 //何年何月何日
 1.数据和图片的缓冲界面。
 2.实现最大同时三个网络异步请求(数量可调，加代码的问题)。
 
 //2023.11.17
 1.网络请求失败，拿不到数据就手动给模块赋值或不给模块赋值，并且报错处理，并且定时反复请求（仅在推荐窗口）。
 
 //2023.11.18
 1.使用git管理，并拥有远程仓库。
 2.列表双击播放音乐。
 3.图片缓冲加了进度%。
 
 问题: qml的Image图片处理，自动网络请求，网络路径不同，有的会缓存有的不会，有的会自动重新加载有的不会？
 2023.11.19 答：上述问题是因为PathView可视的delegate/item会重新加载，不可视就不加载，导致了切换图片会重新给路径赋值即重新加载。
 
 //2023.11.19
 1.图片加载失败，赋予一个默认路径，不自动重复请求。
 
 想法：一般因为网络加载失败了，然后网络又好了，可以手动刷新，自动反复请求的话对后台消耗太大（非必要内容不加该功能）。
 
 //2023.11.20
 1.新增了requestNetwork.js文件，放入网络请求模板函数，实现模块化编程。之前失败应该是因为qml导入js文件命名没有注意首字母必须大写。
 2.bug,由列表和新歌视图里的index引起的问题。
 3.搜索添加默认搜索。
 4.主窗口空格快捷键，播放与暂停。
 5.播放滑块缓冲动画。
 6.切换播放逻辑处理。
 
 //2023.11.21
 1.js文件放入播放函数，模块化编程。
 2.实现列表自动顺序播放。
 
 问题：有个bug，拖动，有延迟，应该是内部position赋值之后继续计时，但是没有实时传出数据。内部问题。猜测：MediaPlayer播放作为子线程和主线程不同步，主线程阻塞？不晓得咋解决！也有可能是网络传输的问题。
 
 //2023.11.22
 1.解决小bug,同一个列表的循环播放。
 2.当前正在播放的列表界面，不销毁，不覆盖。专辑/歌单界面，切换歌单，原正播放的歌单，应该是独立的。
 
 //2023.11.23
 1.搜索界面光标的问题。
 2.上一首和下一首，按钮+快捷键(ctrl+alt+左和ctrl+alt+右)
 3.进度条栏，新增图片信息。
 4.js文件新增Json数组格式化处理函数，用于列表数据，模块化编程。
 5.播放模式的切换。顺序播放，循环播放，随机播放。逻辑：两个列表数组，播放历史列表，当前歌单列表。
 
 //2023.11.25
 1.关于上一首和下一首的逻辑问题：
     首先，有两个列表，分别是播放历史列表(相当于当前的播放列表)和歌单列表，两列表分别独立。
     播放历史列表，包括历史和当前播放的歌，当前播放的歌在末尾；歌单列表就是为了赋值一首歌增加到历史列表末尾进行播放。
     切歌分为三部分，得到index值，播放，高光块显示。第三部分最大会遍历60次。
     特殊情况：index位于播放历史列表中间，而不是末尾，点击一首新歌，此时播放路径会分叉。
     注意：上述为总体逻辑，中间会有其他细节处理。整体难点就是不知道逻辑该是怎么样的。
   期间遇到的问题(就是对JS不熟)：
     slice()：不会改变数组本身，只能赋值，如arr = arr.slice()
     push() splice()：两者会改变数组，直接执行，如arr.push() arr.splice()，它们本身返回的值反而不一样。
     push()不会触发onChange信号。如arr[]，arr.push()，不会触发信号，只能等值替代。
     concat()合并。
     
 //2023.11.26
 1.完善解决播放模式的切换，上一首和下一首的问题。
      
 
 当前需要完成的功能：

 感觉可以跟着视频走了。
 当前页面刷新的功能还没有。
 
