## 注意点
### UIWebView重定向, JSContext注入失败, 解决方法为重新生成UIWebView, 再次注入.

# OTOSaaS SDK JS Bridge
## 1、设置标题
	func setTitle(_ title: String)
	
## 2、toast一句提示
	func toast(_ message: String)
	
## 3、获取系统版本号
	String getVersion()
	
## 4、获取系统类型，返回 "Android" 或 “iOS”
	func getOS() -> String
	
## 5、设置返回按钮action
	func setBackUrl(_ flag: String)
	flag="root":返回首页
	flag="close":关闭
	
## 6、拉起APP的登录和获取APP的用户信息
	func login()
	
	APP判断用户是否已登录，若已登录直接返回用户信息给h5，若没有登录，打开登录界面让用户登录并调用OTOSaaS的绑定用户接口，成功后把用户信息返回给h5\n
	返回方式调用js的otosaas.loginSuccess方法："javascript:otosaas.loginSuccess('" + appKey + "', '" + sign + "', '" + userId + "', '" + userPhone + "')"

## 7. 请求定位
  func requestLocation()
	web在需要时会调用一下方法通知APP返回定位信息
	
	web会调用otosaas.requestLocation（）方法请求定位；定位有	结果或是位置变换 app调用js方法回传给web
	javascript:otosaas.receiveLocation('" + 经度 + "', 	'" + 纬度 + "'), 传入对应的经纬度值
  
