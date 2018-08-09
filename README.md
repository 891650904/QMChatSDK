# 客服SDK集成文档（iOS）
## 1、SDK工作流程
![Alt text](https://fs-kefu-sdk.7moor.com/flow_chart.jpg)

## 2、准备工作
### 2.1 文件说明
|文件	|说明	|
|-----|----|
|IMSDK-OC|使用Objective-C编写UI界面的demo, 快速集成可使用此demo|
|QMChatSDK|在线客服核心库、可以通过pod<font color=red>动态引用(视频版暂时不支持)</font>|
|Qiniu|在线客服文件存储的第三方库, 使用SDK需要依赖此库(内含:AFNetworking、HappyDNS)、可以通过pod<font color=red>动态引用</font>|
|FMDB|在线客服数据持久化的第三方库, 使用SDK需要依赖此库、可以通过pod<font color=red>动态引用</font>|
|Release|只支持真机(armv7、arm64等)的动态库|
|真机+模拟器|同时支持真机和模拟器(i386、x86_64)的动态库, 应用发布使用此版本需要添加脚本|

### 2.2 开发环境

Xcode版本 -> 9.3(9E145),  9.4.1(9F2000)

QMChatSDK版本 -> 2.5.1

Qiniu版本 -> 7.1.8

AFNetworking版本 -> 3.1.0

FMDB版本 -> 2.7.2

HappyDNS版本 -> 0.3.10

<font color=red> iOS版本最低支持8.0, 最高支持11.4 (视频版最低支持9.0)</font>

## 3、快速集成 
<font color=red>注: 集成和发布过程有问题，请看文档最后的常见问题</font>
### 3.1 导入SDK
把IMSDK-OC中的Framework(FMDB.framework、QMChatSDK.framework、Qiniu.framework)拷贝到工程路径下, 右键工程目录, 选择Add Files to "工程名"

### 3.2 集成Demo

QMChatRoom: 聊天界面及部分工具类

Resources: 表情资源文件

Assets: 其他图片资源

Vendors: 第三方库

PrefixHeader: 头文件

<font color=red>注: 可选择性导入工程</font>

### 3.3 配置xcode(重要)
* General配置（动态库需要添加依赖）

Embedded Binaries,展开 Embedded Binaries 后
点击展开后下面的 + 来添加framework

![Alt text](https://fs-kefu-sdk.7moor.com/setDynamicLibrary1.png)

* Build Settings配置 (支持swift、不支持bitcode)

<font color=red> Build Options -> Always Embed Swift Standard Libraries 选择Yes</font>

<font color=red> Build Options -> Enable Bitcode 选择No</font>

* Info.plist配置 (允许http、获取权限)

![Alt text](https://fs-kefu-sdk.7moor.com/setNewInfo.png)

### 3.4 注册SDK

* 初始化SDK

AppKey: 在后台SDK下载界面的下方, 是接入在线客服的唯一凭证 
userName: 可以区分不同用户的用户名称, 可以显示在后台客服界面  
userId: 可以区分不同用户接入在线客服, 不同用户用户ID一定不同

<font color=red>注: userId 只能使用字母、数字及下划线、否则会初始化失败, AppKey、userName、userId都是必填项</font>

	[QMConnect registerSDKWithAppKey:@"注册App的AppKey" userName:@"用户名" userId:@"1234"];

###### 注：进行任何操作必须是注册AppKey成功的状态

* AppKey获取方法

![Alt text](https://fs-kefu-sdk.7moor.com/liucheng.png)

* 监听注册状态

监听SDK初始化的状态需要注册广播:  

CUSTOM_LOGIN_SUCCEED: 注册成功的时候广播的名字, SDK其他的接口操作都基于注册成功的状态才能进行, 如获取部门、或技能组的接口  
CUSTOM_LOGIN_ERROR_USER: 注册失败时候广播的名字, 具体失败的原因提示:  
1、accessId is Empty: appKey不可以为空值  

2、userName is Empty: userName不可以为空值  

3、userId is not match: userId不可以为空值 

4、Create Socket Error: 建立连接失败

5、Connect Socket Error: 连接服务器失败

6、5: 服务器状态异常

7、400: appKey错误或不存在

8、服务端返回其他类型错误

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccess:) name:CUSTOM_LOGIN_SUCCEED object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginFaile:) name:CUSTOM_LOGIN_ERROR_USER object:nil];

## 4、API接口

### 4.1 自建服务器设置网络地址
是不是自建服务器的用户不需要设置此项，此接口应在注册之前使用

	[QMConnect setServerAddress:@"IP地址" tcpPort:@"端口" httpPost:@"TCP地址"];

### 4.2 获取渠道全局配置
获取全局配置,主要用于区分下一步操作<font color=red>日程管理</font>和<font color=red>技能组</font>(如果不配置日程管理的可跳过此步骤，直接获取技能组信息)

    [QMConnect sdkGetWebchatGlobleConfig:^(NSDictionary * _Nonnull scheduleDic) {
        //获取渠道全局配置字典
    } failBlock:^{
        //获取信息失败
    }];
    
    注册成功自动获取后台配置信息并写入本地plist文件

###  4.3 获取配置信息(开启日程管理时用到) 
	[QMConnect sdkGetWebchatScheduleConfig:^(NSDictionary * _Nonnull scheduleDic) {
		//获取配置信息成功
    } failBlock:^{
       //获取配置信息失败 
    }];


### 4.4 获取部门信息（技能组）

后台可配置多个部门/技能组(如: 售前、售后等), SDK注册成功后, 调用此接口获取后台配置好的部门信息, 用户将选择对应的部门进行问题咨询,     

    [QMConnect sdkGetPeers:^(NSArray * _Nonnull peerArray) {
    	// 获取部门信息的数组
  	 } failureBlock:^{
        // 获取信息失败
    }];
    
技能组包含部门ID和部门Name两个属性, 只有一个部门可以不提示选择框, 直接进入聊天界面

### 4.5 开始会话

进入聊天界面, 首先调用开始会话接口, 成功后才能获取坐席状态, 及消息的收发, 参数为刚刚选择的部门ID, 回调是否开启评价选择项 

	[QMConnect sdkBeginNewChatSession:self.peerId successBlock:^(BOOL remark) 	{
       // 开始会话成功, 评价开关
	} failBlock:^{
        // 开始会话失败
	}];
	
	
开始会话带专属坐席（不能配置机器人）

    [QMConnect sdkBeginNewChatSession:self.peerId params:@{@"agent": @"8000"} successBlock:^(BOOL remark) {
		// 开始会话成功, 评价开关    
	 } failBlock:^{
      // 开始会话失败
    }];
	
开始会话(日程管理专用) 

	[QMConnect sdkBeginNewChatSessionSchedule: self.scheduleId processId: self.processId currentNodeId: self.currentNodeId params: @{@"":@""} successBlock:^(BOOL remark) {
		// 开始会话成功, 评价开关
     } failBlock:^{
		// 开始会话失败
     }];
	
会话状态(以广播的形式推送给移动端)
  
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(robotAction) name:ROBOT_SERVICE object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(customOnline) name:CUSTOMSRV_ONLINE object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(customOffline) name:CUSTOMSRV_OFFLINE object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(customClaim) name:CUSTOMSRV_CLAIM object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(customFinish) name:CUSTOMSRV_FINISH object:nil];
	
其他推送

排队数

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(customQueue:) name:CUSTOMSRV_QUEUENUM object:nil];
    
坐席信息

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(customAgentMessage:) name:CUSTOMSRV_AGENT object:nil];
    
满意度

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(customInvestigate) name:CUSTOMSRV_INVESTIGATE object:nil];
    
专属坐席未在线

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(customVIP) name:CUSTOMSRV_VIP object:nil];

### 4.6 坐席信息

|Object|说明|备注|
|---------------	|------------	|:----:|
|exten				|坐席工号		|例：7000、8000|
|name				|坐席名称		|后台未配置显示工号| 
|icon_url			|坐席头像		|后台未配置没有值| 
|type				|类型			|robot（机器人）claim（人工）| 

### 4.7 消息结构

|Object|说明|备注|
|---------------	|------------	|:----:|
|_id				|消息ID			|记录每条消息的ID|
|device			|设备类型		|如：iphone5s、iphone6|
|message			|消息内容		||
|messageType		|消息类型		|如：text、image、voice、file、iframe(小网页)、richText(富文本)、Card(商品展示)、cardInfo(商品详情)|
|platform			|平台类型		|如：iOS、Android|
|sessionId		|查询消息的ID	|不同用户的sessionId不同、根据sesssionId查询数据库消息|
|accessid        |查询消息的accessid|AppKey下的全部数据,可查看该用户的同一个AppKey下的全部数据库消息|
|createTime		|消息时间		|创建消息的时间|
|fromType			|消息来源		|自己发送的为0、接收的消息为1|
|status			|消息发送状态	|发送成功为：0、发送失败为：1、正在发送中：2|
|recordSeconds	|录音时间		|语音消息录音时长|
|localFilePath	|本地文件路径	|文件上传或者下载后本地存储路径, 沙盒相对路径, 如：|
|remoteFilePath	|远程文件路径	|存储文件的网络路径，可以通过该路径下载各类文件|
|fileName			|文件名			||
|fileSize			|文件大小		||
|mp3FileSize     |mp3消息类型文件大小 ||
|downloadState	|下载状态		|已下载：0, 未下载：1, 下载中：2|
|width				|iframe类型webView宽度||
|height			|iframe类型webView高度||
|agentExten		|坐席工号		||
|agentName		|坐席名称		||
|agentIcon		|坐席头像		||
|isRobot			|机器人消息		||
|robotType       |机器人类型    ||
|robotId         |机器人id     ||
|isUseful			|机器人帮助状态	||
|questionId		|机器人问题ID	||
|richTextUrl     |富文本地址    ||
|richTextPicUrl  |图片地址     ||
|richTextTitle   |标题         ||
|richTextDescription |描述     ||
|cardImage       |商品信息左侧图片   ||
|cardHeader      |商品信息标题      ||
|cardSubhead     |商品信息副标题     ||
|cardPrice       |商品信息价格      ||
|cardUrl         |商品信息地址      ||

### 4.8 获取未读消息数
	
	此接口Appkey、userName、userId必须与注册用的保持一致
	
	[QMConnect sdkGetUnReadMessage:@"AppKey"    userName:@"userName" userId: @"userId" successBlock:^(NSInteger) {
        // 获取未读消息数成功
    } failureBlock:^{
        // 获取未读消息数失败
    }];

<font color=red>获取未读消息数的AppKey、userName、userId必须和注册的保持一致</font>
	
### 4.9 发送消息

发送文本消息  

	[QMConnect sendMsgText:@"文本消息" successBlock:^{
		// 文本消息发送成功
	} failBlock:^{
		// 文本消息发送失败
	}];
	
发送语音消息  

    [QMConnect sendMsgAudio:@"录音文件名" duration:@"录音时长" successBlock:^{
        // 语音消息发送成功
    } failBlock:^{
        // 语音消息发送失败
    }];

发送图片消息

    [QMConnect sendMsgPic:image对象 successBlock:^{
       // 图片发送成功
    } failBlock:^{
       // 图片发送失败
    }];

发送文件消息

    [QMConnect sendMsgFile:@"文件名字" filePath:@"文件路径" fileSize:@"文件大小" progressHander:^(float progress) {
    	// 文件上传进度回调
	} successBlock:^{
        // 文件上传成功
    } failBlock:^{
       // 文件上传失败
    }];
    
发送卡片消息
 
    [QMConnect sendMsgCardInfo:dic successBlock:^{
        商品信息发送成功
    } failBlock:^{
        商品信息发送失败
    }];
    
消息重发

	[QMConnect resendMessage:消息实例 successBlock:^{
		// 重新发送成功
	} failBlock:^{
		// 重新发送失败
	}];

### 4.10 数据库操作

获取同一个accessId下数据库的全部信息,参数number为每次从数据库取回的消息条数, dataArray为消息数组

  [QMConnect getAccessidAllDataFormDatabase:number];

获取单次会话的数据库信息(客服主动关闭后在进入消息清空), 参数number为每次从数据库取回的消息条数, dataArray为消息数组

	dataArray = [QMConnect getDataFromDatabase:number]
	
获取单条消息, 参数为消息ID, 返回值虽然为数组类型, 但只包含一条消息, 一般用于发送失败的消息重发

	dataArray = [QMConnect getOneDataFromDatabase:@"消息ID"]
	
删除单条消息, 参数为消息ID, 只能删除本地数据库中的消息

	[QMConnect removeDataFromDataBase:@"消息ID"];
	
修改语音状态接口,参数为消息ID

    [QMConnect changeAudioMessageStatus:@"消息ID"];

撤回消息接口,该接口只用于客服撤回消息
	
	 [QMConnect changeDrawMessageStatus:@"消息ID"];

查询MP3类型文件的消息的大小

    [QMConnect queryMp3FileMessageSize:@"消息ID"];
    
修改MP3类型文件的消息的大小

    [QMConnect changeMp3FileMessageSize:@"消息ID" fileSize:@"文件大小"];

插入商品信息卡片消息, 进入客服界面会出现该商品的消息

    [QMConnect insertCardInfoData:消息字典];
    
删除商品信息卡片消息

	 [QMConnect deleteCardTypeMessage];

修改商品信息卡片消息时间

    [QMConnect changeCardTypeMessageTime:消息时间];

### 4.11 是否启用机器人
在线客服包含机器人客服和人工客服, 如配置有机器人客服, 如没配置直接进入人工

	[QMConnect allowRobot];

### 4.12 转人工服务

    [QMConnect sdkConvertManual:^{
       // 转人工客服成功
    } failBlock:^{
       // 转人工客服失败
    }];

如未配置机器人客服不需要调用此接口, 转人工客服失败, 则直接跳转至留言界面或退出

### 4.13 授权其他坐席

专属坐席未在线的情况下，是否接受其他坐席的服务

    [QMConnect sdkAcceptOtherAgentWithPeer:self.peerId successBlock:^{
    	// 授权成功
    	// 需要再次调用beginSession接口
    } failBlock:^{
    	// 授权失败
    }];

### 4.14 获取评价信息

	[QMConnect sdkGetInvestigate:^(NSArray * _Nonnull investigateArray) {
    	// 获取评价信息成功
	} failureBlock:^{
        // 获取评价信息失败
	}];

### 4.15 提交评价

	[QMConnect sdkSubmitInvestigate:@"评价名称" value:@"评价编号" successBlock:^{
		// 评价成功
	} failBlock:^{
		// 评价失败
	}];

### 4.16 机器人帮助评价

    [QMConnect sdkSubmitRobotFeedback:isUseful questionId:@"机器人问题id" messageId:@"消息ID" robotType:@"机器人消息类型" robotId:@"机器人ID" successBlock:^{
		//机器人帮助评价成功 
    } failBlock:^{
       //机器人帮助评价失败
    }];

### 4.17 提交留言

	[QMConnect sdkSubmitLeaveMessage:@"部门ID" phone: @"联系电话" Email:@"联系邮箱" message:@"留言内容" successBlock:^{
		// 留言成功
	} failBlock:^{
		// 留言失败
	}];

### 4.18 关闭服务

	[QMConnect logout];

### 4.19 下载文件

	[QMConnect downloadFileWithMessage:文件消息实例 localFilePath:@"存储文件的路径" progressHander:^(float progress) {
		// 文件下载进度
	} successBlock:^{
		// 文件下载成功
	} failBlock:^(NSString * _Nonnull error) {
		// 文件下载失败
	}];
	
### 4.20 留言功能	
	
留言功能

	[QMConnect allowedLeaveMessage]

留言提示信息

	[QMConnect leaveMessageAlert]

留言内容信息

	[QMConnect leaveMessagePlaceholder]

自动关闭会话功能

	[QMConnect allowedBreakSession]

自动关闭会话提示语

	[QMConnect breakSessionAlert]

自动关闭会话时间

	[QMConnect breakSessionDuration]

自动关闭提醒时间

	[QMConnect breakSessionAlertDuration]
	
	
### 4.21 定时提醒和关闭会话(1.9.0以后不建议使用此接口)
	QMConnect sdkChatTimerBreaking:^(NSDictionary * _Nonnull) {
        //获取定时提示信息成功
    } failBlock:^{
        //获取定时提示消息失败
    }];

###  4.22 更新deviceToken

每次启动应用都需要重新设置

	 [QMConnect setServerToken:deviceToken];
  

## 常见问题

<h3><a href="#jumpto1">集成问题</a></h3>
<h3><a href="#jumpto2">编译问题</a></h3>
<h3><a href="#jumpto3">发布问题</a></h3>  
<h3><a href="#jumpto4">逻辑问题</a></h3>
<h3><a href="#jumpto5">使用问题</a></h3>
<h3><a href="#jumpto6">推送问题</a></h3>
<h3><a href="#jumpto7">H5页面问题</a></h3>

<h3><div id="jumpto1">集成问题</div></h3>

1. 不显示表情  

解决方案: 

* 查看demo导入工程的时候是否将表情图片同时导入
* 查看对应表情的expressionImage.plist文件是否已经导入, 该文件在第三方库ExpressionView文件夹下
* 查看显示表情的Cell中是否支持表情的富文本, demo中使用的是EmojiLabel第三方库

2. 第三方库冲突

* demo中的第三方库冲突可以二选一，将其中一个重复的删除
* SDK中使用了FMDB, Qiniu, AFNetworking等第三方库, 容易出现冲突的是AFNetworking出现冲突时可以将其中冲突的类名改写一下

3. 使用iphone真机注册失败

* 在蜂窝移动网络中，打开对应的网络管理

4. pod search 不到最新的库

* 更新本地的缓存 pod repo update  
* 检查pod版本

5. SDK界面部分显示成英文 

* SDK支持国际化,导入代码的同时，需要在工程中建立创建多语言文件，Demo中的多语言文件名称为:
<font color=red>Localizable.strings</font>

6. 已接入人工,导航栏仍显示 <font color=red>等待接入</font> (2.7.0版本之前显示的是等待连接)

* 因为客服系统设置访客回复消息后才算接入会话, 修改方式看下图

![Alt text](https://fs-kefu-sdk.7moor.com/dengdai.png)


<h3><div id="jumpto2">编译问题</div></h3>

1. Library not loaded  

集成SDK后工程run的时候crash, 提示Library not loaded, 主要原因是库文件没有加载成功, 错误如下
![Alt text](http://7xqpis.com1.z0.glb.clouddn.com/imageNotFound.png)

解决方案: 

* <font color=red>检查SDK版本和Xcode版本，2.5.0以上的SDK只支持 >= Xcode9.3的版本</font> 
* Build Settings->Build Options->Always Embed Swift Standard Libraries = Yes
* General->Embedded Binaries 点击’+‘号，将QMChatSDK.framework、FMDB.framework和Qiniu.framework三个库添加进入
* 缓存导致，删除相应的库文件重新导入
* 如果是pod引入出现此问题,在Podfile文件中添加 use_frameworks! (如果pod的第三方库较多, 请先查明use_frameworks!用法)

<font color=red>注: 建议多使用clean或重新导入包, 2.5.0(包含2.5.0)以上版本只支持Xcode9.3以上的版本(包含Xcode9.3)</font>

2. 模拟器报错

![Alt text](https://fs-kefu-sdk.7moor.com/symbol.tiff)

* 检查使用的库是否是文件夹中真机+模拟器的库
* 检查是否导入libicucore.tbd库

<h3><div id="jumpto3">发布问题</div></h3>

1. x86_64,i386  

集成了SDK的应用发布到AppStore时报错，如下

![Alt text](http://7xqpis.com1.z0.glb.clouddn.com/submitAppStore1.png)

解决方案:

* QMChatSDK库文件有两种, 一种支持真机和模拟器, 一种只支持真机, 如果测试需要用到模拟器, 测试时可以用前一种, 如果不用模拟器全程只用真机, 建议用只支持真机的库, 在真机文件夹下, <font color=red>发布应用时不能使用同时支持真机和模拟器的库文件, 否则会报错</font>

* 使用脚本打包前去掉不需要的架构(推荐)

	具体参照demo Build Phases
	
* 如果使用带视频的SDK包上传App Store报错, QMVSDK.framework这个包不能放在General -> Embedded Binaries 下,其他几个保留,在Linked Frameworks and Libraries 下几个包都需要保留

<h3><div id="jumpto4">逻辑问题</div></h3>

1. 跳转至聊天界面

* 现象一 跳转至聊天界面后，网络断开重新连接，又跳转一次聊天界面  

	解决方案： 跳转界面根据注册SDK成功后，接收到相应的通知进行跳转，网络波动会导致后台重新连接，再次发出连接成功的通知，所以在跳转界面进行判断，在聊天界面的时候，接收连接成功的通知直接return不会跳转
	
* 现象二 应用将要进入后台的时候调用注销接口, 返回前台后收不到消息

   解决方案： 需要重新注册和之前注册的AppKey、userName、userId需要保持一致
	
<h3><div id="jumpto5">使用问题</div></h3>

* 客服发送消息用户无法收到

	解决方案：登录后台系统需要使用google浏览器

* 客服不在线、用户的会话接入到了该客服

	解决方案：客服登陆前、确保所有的待处理会话都已经结束
	
<h3><div id="jumpto6">推送问题</div></h3>

1、 上传证书不离线推送

* 检查客服系统中是否配置过 p12 文件，此证书是否与此app的 Bundle Identifier 关联的推送证书

* 检查证书的线上、测试环境是否跟客服系统中配置的相同
 
* 检查 appName 是否和客服系统中填写的“App名称”一致

* 检查 provision profile 是否包含了推送证书

* 检查代码调试是否可以获取到 devicetoken

* 检查工程中的 Capablities 中是否开启了 Push Notifications


2、上传URL接收不到离线推送

* 消息以json数据发送给客服系统中配置的URL，检查是否收到json数据

3、SDK以离线 app在线时接收到离线推送提示处理

* 详见AppDelegate

<h3><div id="jumpto7">H5页面问题</div></h3>

1. H5链接页面不显示

		NSString *filePath = @"kf.7moor.com";
    	NSString *encodedString = [filePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
   		NSURL *weburl = [NSURL URLWithString:encodedString];
    	[webView loadRequest:[NSURLRequest requestWithURL:weburl]];


2. H5页面点击图片或文件不跳转

		- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion{
  		  if (self.presentedViewController != nil) {
   			     [super dismissViewControllerAnimated:flag completion:completion];
   			}
		}

3. tabBar遮挡发送按钮

*  查看webView的frame的高度

## 代码改动页面

#### 2.7.0代码改动页面
* QMChatRoomViewController
* QMChatRoomCardCell
* QMChatRoomRichTextCell
* QMChatRoomBaseCell(改动背景颜色和更换了背景图片)

## 更新日志

#### 版本更新2.7.0: 2018-07-01
* 新增未读消息数功能
* 新增商品信息消息展示和发送功能
* 新增获取同一个AppKey下的全部消息功能

#### 版本更新2.6.1: 2018-6-20
* 支持Xcode9.4.1， iOS 11.4

#### 版本更新2.6.0: 2018-05-31
* 支持上传证书离线消息推送
* 支持主动会话

#### 版本更新2.5.3: 2018-05-18
* 支持国际化
* mp3文件以语音形式直接播放

#### 版本更新2.5.1: 2018-04-10
* 修复已知问题

#### 版本更新2.5.0: 2018-04-4
* 新增消息撤回功能
* 客服正在输入提示
* 支持Xcode9.3

#### 版本更新2.4.0: 2018-03-16
* 新增日程管理功能
* 新增富文本消息类型

#### 版本更新2.3.0: 2018-02-08

* 新增专属坐席功能
* 分离机器人消息显示

#### 版本更新2.2.0: 2017-11-17

* 适配iPhone X
* 增加机器人回复有无帮助选项
* 包名更新为QMChatSDK
* 更新Qiniu第三方库至7.1.8版本
* 支持 Cocoapods
* 修复发送视频文件失败的问题

#### 版本更新2.1.0: 2017-09-22
* 支持xcode9，iOS11

#### 版本更新2.0.0: 2017-09-11
* 在线客服全新界面

#### 版本更新1.9.0: 2017-08-02
* 更新SDK依赖库，FMDB、Qiniu
* 增加获取后台配置信息接口
* 优化Demo

#### 版本更新1.8.0: 2017-06-08
* 支持IPv6
* 优化发送表情功能
* 更新第三方库

#### 版本更新1.7.0: 2017-03-30
* 支持xcode8.3 iOS10.3

#### 版本更新1.6.0: 2017-01-11
* 新增推送在线客服工号
* 新增定时提醒和关闭会话

#### 版本更新1.5.0: 2016-11-23
* 新增iframe消息类型

#### 版本更新1.4.0: 2016-11-11
* 支持xcode8.1 iOS10.1

#### 版本更新1.3.0: 2016-08-20
* 新增文件消息类型，支持文件消息发送，文件下载
* 新增图片消息发送接口(参数为本地图片相对路径)
* 消息结构新增字段(localFilePath、remoteFilePath、fileName、fileSize、downloadState)
* 优化聊天界面  
注: 已集成SDK的客户更新需要对文件管理的消息类型做相应处理，否则直接更新SDK会导致崩溃

#### 版本更新1.2.2: 2016-06-20
* 更新七牛SDK，支持IPv6
* 对特殊字符进行处理
* 使用IMSDK依赖Qiniu，FMDB第三方库  


#### 版本更新1.2.1: 2016-04-25
* SDK支持iOS9.3
* 修复SDK表情库与后台不匹配
* SDK支持真机和模拟器合并包  


#### 版本更新1.2.0: 2016-03-25
* SDK新增删除一条数据库信息接口(只能删除本地数据库消息) 
* SDK新增满意度评价推送(通知方式新增一条本地消息，消息内容为获取的本地评价信息) 
* SDK新增多技能组获取接口(开始会话前可以选择相应的技能组进行咨询) 
* SDK新增获取满意度调查信息接口(异步请求满意度调查选项,移除之前的获取本地满意度调查接口,用户可根据获取到的数据自行缓存)
* SDK新增设置服务器地址接口(自建客户可设置此接口,连接本地服务器)

#### 版本更新1.1.1: 2016-02-03
* 新增SDK注销接口(使用demo需在AppDelegate中添加全局变量)  

#### 版本更新1.1.0: 2015-12-22
* 修复已知的BUG
* SDK新增接收图片消息











