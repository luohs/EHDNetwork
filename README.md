# EHDNetwork

[![CI Status](http://img.shields.io/travis/luohs/EHDNetwork.svg?style=flat)](https://travis-ci.org/luohs/EHDNetwork)
[![Version](https://img.shields.io/cocoapods/v/EHDNetwork.svg?style=flat)](http://cocoapods.org/pods/EHDNetwork)
[![License](https://img.shields.io/cocoapods/l/EHDNetwork.svg?style=flat)](http://cocoapods.org/pods/EHDNetwork)
[![Platform](https://img.shields.io/cocoapods/p/EHDNetwork.svg?style=flat)](http://cocoapods.org/pods/EHDNetwork)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

EHDNetwork is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'EHDNetwork'
```

## Author

luohs, luohuasheng0225@gmail.com

## License

EHDNetwork is available under the MIT license. See the LICENSE file for more info.

## 更新说明-0.5.0
###### 罗华胜-18330
##### 1、增加用户自定义公共参数可通过实现协议动态设置到HTTP URI中。
##### 2、增加request父类属性读取。
##### 3、实现customBody参数也可以增加公共参数。
##### 4、优化双向认证时读取证书代码。

## 更新说明-0.6.0
###### 罗华胜-18330
##### 1、增加POST请求时，表单参数默认拼接到URL中。

## 更新说明-0.7.0
###### 罗华胜-18330
##### 1、增加数据回包字典模型转换。
##### 2、增加支持上传多个文件处理。

## 更新说明-0.8.0
###### 罗华胜-18330
##### 1、增加同步请求方式。

## 更新说明-0.8.1
###### 罗华胜-18330
##### 1、优化同步请求方式，解决0.8.0版本中同步请求在主线程中的block块中死锁的问题。

## 更新说明-0.8.2
###### 罗华胜-18330
##### 1、添加 TFNetResponse 类，将返回值解析成对象。

## 更新说明-0.8.4
###### 罗华胜-18330
##### 1、返回值code处理

## 更新说明-0.8.5
###### 罗华胜-18330
##### 1、增加网络回调封装

## 更新说明-0.8.6
###### 罗华胜-18330
##### 1、消除本组件引出的警告
##### 2、优化引用

## 更新说明-1.0.1
###### 罗华胜-18330
##### 1、恢复单独引用核心代码可以正常使用。
##### 2、增加屏蔽代理抓包功能。
##### 3、增加屏蔽日志打印功能。

## 更新说明-1.0.3
###### 罗华胜-18330
##### 1、增加serverMsg字段

## 更新说明-1.0.4
###### 罗华胜-18330
##### 1、获取网关时间

## 更新说明-1.0.5
###### 罗华胜-18330
##### 1、增加同步请求

## 更新说明-1.0.6
###### 罗华胜-18330
##### 1、优化对公共的鉴权数据进行分类处理，支持更多的用户自定义格式

## 更新说明-1.0.7
###### 罗华胜-18330
##### 1、优化重新请求接口，支持老的请求接口。

## 更新说明-1.0.8
###### 罗华胜-18330
##### 1、增加队列。
##### 2、增加retry功能。
##### 3、增加限定retry次数功能。
##### 4、优化重构代码。
