## Hydra

### 简介

`Hydra` Framework 主要提供流利说 iOS 团队内部和前端团队相交互的一些基础组件和工具实现。

### 项目名称来源

`Hydra`: 九頭蛇（英语：Hydra），是漫威漫画旗下的一个虚构的恐怖组织，在二戰時由納粹德国將軍約翰·施密特（紅骷髏）創立，口號為“九頭蛇萬歲”（Hail HYDRA）。详情可参考 [Wiki](https://zh.wikipedia.org/wiki/九头蛇_(漫威漫画))

### 当前版本

版本 `2.1`，加入了对 Swift 5.1 的支持。

版本 `2.0`，加入了对 Swift 5 的支持。

版本 `1.0`，主要包括的功能有如下：

1. JavaScript Bridge 协议的实现
2. 带有定义 JavaScript Bridge 协议实现的 WebViewController

关于 JS Bridge 协议和接口的定义可参考如下文档: [https://git.llsapp.com/docs/jsbridge-api-doc](https://git.llsapp.com/docs/jsbridge-api-doc)

### 集成

在集成 `Hydra` 项目时, 您应该在项目中 include 如下 Frameworks:

1. UIKit
2. Foundation
3. WebKit
4. CoreTelephony

### Features

1. Hydra 内部使用 `WKWebView`, 并使用 `WKUserContentController` 和 JavaScript 进行交互。
2. 前端各团队默认使用 `iOSApi` 做为全局对象进行和 Native 的交互。