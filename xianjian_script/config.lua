
--debug参数 正式版的 debug 是1  测试版的debug 为2 
--1 是日志也会输出
DEBUG = 1

 
--游戏整体帧率
GAME_RUN_FPS = 30
-- 是否跳过登录sdk
DEBUG_SKIP_LOGIN_SDK = false

-- 是否跳过logo
DEBUG_SKIP_LOGO = false
   
-- 是否跳过视频
DEBUG_SKIP_VIDEO = true

-- 是否跳过CG视频(暂定三测会关闭CG视频功能，所以提供该开关)
DEBUG_SKIP_CG_VIDEO = true

-- 强制播放情怀动画和CG视频(默认仅播放一次，打开该开关后每次都播放(前提是DEBUG_SKIP_LOGO=false))
DEBUG_FORCE_MOMERY_CG = false

-- 是否显示SceneTest界面及自动登录
-- 设置为true，在SceneTest.autoLoginConfig中填写账号、密码，可以实现自动登录
DEBUG_ENTER_SCENE_TEST = false;

-- 加载完毕不进入主城，直接进入window_test界面
DEBUG_ENTER_WINDOW_TEST = false;

-- 是否跳过序章
DEBUG_SKIP_PROLOGURE = false

-- 是否生成mini包白名单
DEBUG_CREATE_WHILTE_LIST = false

-- 是否跳过自动登录
DEBUG_SKIP_AUTO_LOGIN = true

-- 是否跳过主城公告
DEBUG_SKIP_HOME_GONGGAO = true

-- 是否跳过登录界面公告
DEBUG_SKIP_LOGIN_GONGGAO = false

-- 是否AppStore审核期间
DEBUG_APP_STORE_REVIEW = false

-- display FPS stats on screen
DEBUG_FPS = false

--是否显示日志view
DEBUG_LOGVIEW = false       

--是否显示GM命令
DEBUG_GMVIEW = false

--是否 服务器纯跑逻辑
DEBUG_SERVICES = false

-- 1 是显示网络交互的输出日志 但是 不在 命令行里显示  2 是 又在命令行输出 又打出日志 0是什么都不输出  
DEBUG_CONNLOGS = 2          

-- dump memory info every 10 seconds
--内存输出开关
DEBUG_MEM = false   

--内存输出一次的时间间隔           
DEBUG_MEM_INTERVAL = 0.3

--是否加载废弃的api        
-- load deprecated API 
LOAD_DEPRECATED_API = false
 
--是否加载扩展的api
-- load shortcodes API
LOAD_SHORTCODES_API = true

--是否使用散图
CONFIG_USEDISPERSED = false         

-- pc                   Mac or Windows 使用asset下资源
-- android              使用asset_android下大图
-- ios                  使用asset_ios下大图
CONFIG_ASSET_PLATFOMR = "pc"



--1 是dev  目前 暂定 10001 为 版署包
APP_PLAT = 1 -- 1:dev

--游戏内部代号
APP_NAME = "xianpro"

RELEASE_VER = "1.0.0" --版本号名称
-- 显示点击位置
SHOW_CLICK_POS = true;
-- 显示点击区域
SHOW_CLICK_RECT = false
--是否关闭新手引导
IS_CLOSE_TURORIAL = false;
--是否显示跳过引导
IS_CAN_SKIP_TURORIAL = false;

IS_USE_SPINE_JSON_CONFIG = false;

--是否显示战斗跳过
IS_SHOWBATTLESKIP = false;

--是否禁用敏感词检查
IS_CLOSE_BAN_WORDS = false

--是否显示点击特效
IS_SHOW_CLICK_EFFECT = true

-- 是否开启退出界面后重新require
IS_CLEAR_PACKAGE_AFTER_HIDE = false

 --是否开启调试更换伙伴
IS_BATTLE_DEBUGHERO = false   

--是否开启config_debug配置覆盖  默认是开启的 config_debug 忽略提交git的
--开发人员需要在script目录下 拷贝config.lua 重命名config_debug.lua,修改里面的参数就好
IS_COVER_FORM_CONFIG_DEBUG = true

--是否开启mobdebug（mac下）
IS_OPEN_MOBDEBUG = false

-- 是否显示战斗内角色属性信息 
IS_SHOW_BATTLE_IFNO = false

--是否打开可以点击界面事件
IS_OPEN_LOGDEBUG = true

-- 是否开启战斗校验
IS_CHECK_DUMMY = true

-- 是否开启战斗时使用sissionMaping表映射关系修改我方上阵伙伴属性、默认为false
IS_SISSION_MAPPING = false

-- 是否屏蔽日志
IS_IGNORE_LOG = false

-- 是否开启延长loading条时间
LOADING_TIME = false

-- 是否跳过战斗服校验
IS_SKIP_SERVICE = false

--是否跳过主城动画 和主城有未处理的错误码的面板
IS_TODO_MAIN_RUNCATION = false

--是否开启场景更换调试功能.主要是为了测试 场景是否有缝隙 点击屏幕左中的位置进行更换场景
DEBUG_TESTSCENE = false

-- 是否检查SPINE渲染尺寸
IS_CHECK_SPINE_ATTACHMENTSIZE = false

--是否开启网络延迟 0或者空表示不延时 , 其他的表示延迟的毫秒数 超过1000就表示延迟很高
IS_NETWORK_DELAY = 0

-- 是否关闭设备ID的缓存
IS_CLOSE_DEVICE_CACHE = false

-- 编辑器模式(仙盟探索地形编辑器)
IS_EDITER = false

-- 仙盟探索的GM是否打开
IS_EXPLORE_GM_RES = false

--直接设置奇侠处于 老手期
IS_PARTNER_SKILLFULL = false


--是否强制定位为刘海屏 设备
IS_NOTOCH_DEVICE = false

--登入groupId,为了实现不同的区组, 默认是pc,可选字段是 android ,ios
PLATFORM_LOGIN_GROUP= "pc"

-- 强制关闭文件，临时用
FORCE_CLOSE_QUEST = true
