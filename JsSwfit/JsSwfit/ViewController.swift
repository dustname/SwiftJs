//
//  ViewController.swift
//  JsSwfit
//
//  Created by dust on 2017/8/8.
//  Copyright © 2017年 dust. All rights reserved.
//

import UIKit
import JavaScriptCore

/// 定义全局变量
var backUrl: String?

@objc protocol JavaScriptSwiftDelegate: JSExport {
    /// 登录
    func login()
    /// 获取版本
    func getVersion() -> String
    /// 获取系统
    func getOS() -> String
    /// 设置标题
    func setTitle(_ title: String)
    /// 设置返回按钮
    func setBackUrl(_ flag: String)
    /// 获取系统定位
    func requestLocation()
}

@objc class JSSwiftModel: NSObject, JavaScriptSwiftDelegate {

    weak var controller: UIViewController?
    weak var jsContext: JSContext?
    weak var webView: UIWebView?
    
    /// 登录
    func login() {
        DispatchQueue.main.async { () -> Void in
            let alertVc = UIAlertController(title: "", message: "是否登录", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.cancel, handler: nil)
            let loginAction = UIAlertAction(title: "登录", style: .default, handler: { (action) in
                self.webView?.stringByEvaluatingJavaScript(from:
                    "javascript:otosaas.loginSuccess('appkey123', '456', '789', '13777777777')")
            })
            alertVc.addAction(cancelAction)
            alertVc.addAction(loginAction)
            self.controller?.present(alertVc, animated: true, completion: nil)
        }
    }
    
    /// 设置标题
    func setTitle(_ title: String) {
        controller?.title = title
    }
    
    /// 获取平台
    func getOS() -> String {
        return "iPhone"
    }
    
    /// 获取版本
    func getVersion() -> String {
        return "1.0.0-debug"
    }
    
    /// 设置backURL
    func setBackUrl(_ flag: String) {
        if flag.contains("root") {
            backUrl = "http://action.boluomeet.cn/demo/demo2.html"
        } else if flag.contains("close") {
            backUrl = ""
        }
    }

    /// 获取系统定位
    func requestLocation() {
        DispatchQueue.main.async {  /// swift -> js receiveLocation
            self.webView?.stringByEvaluatingJavaScript(from: "javascript:otosaas.receiveLocation('我是经度', '我是纬度')")
        }
    }
}

class ViewController: UIViewController {
    
    var webView: UIWebView!
    var jsContext: JSContext?
    var model = JSSwiftModel()
    var shouldIntercept = true

    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView = UIWebView(frame: view.bounds)
        view.addSubview(webView)
        webView.delegate = self
        self.webView.scalesPageToFit = true
        let url = NSURL(string: "http://action.boluomeet.cn/demo/demo2.html")
        let request = URLRequest(url: url! as URL)
        self.webView.loadRequest(request)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "后退", style: .done,
                                                           target: self, action: #selector(clickBackBtn))
    }
    
    // 点击返回按钮
    func clickBackBtn() {
        if backUrl == nil {
            if webView.canGoBack {
                webView.goBack()
                return
            }
            self.navigationController?.popViewController(animated: true)
        } else if backUrl == "" {
            // 正常返回
            self.navigationController?.popViewController(animated: true)
        } else {
            let request = URLRequest(url: NSURL(string: backUrl!)! as URL)
            webView.loadRequest(request)
            backUrl = nil
        }
    }
}
//MARK: - UIWebViewDelegate
extension ViewController: UIWebViewDelegate {
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        let context = webView.value(forKeyPath: "documentView.webView.mainFrame.javaScriptContext") as? JSContext
        self.model.controller = self
        self.model.jsContext = context
        self.jsContext = context
        self.model.webView = webView
        
        self.jsContext?.setObject(model, forKeyedSubscript: "otosaas" as NSCopying & NSObjectProtocol)
        
        self.jsContext?.exceptionHandler = {
            (context, exception) in
            print(exception ?? "")
        }
    }

    // 注册jsContext
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest,
            navigationType: UIWebViewNavigationType) -> Bool {
        
        if self.jsContext != nil && shouldIntercept { /// 解决UIWebView重定向, JSContext注入失败问题
            self.webView.stopLoading()
            self.webView.removeFromSuperview()
            self.webView = nil
            self.webView = UIWebView(frame: view.bounds)
            self.webView.delegate = self
            self.webView.scalesPageToFit = true
            self.view.addSubview(self.webView)
            self.webView.loadRequest(request)
            if let interGesture = self.navigationController?.interactivePopGestureRecognizer {
                self.webView.scrollView.panGestureRecognizer.require(toFail: interGesture)
            }
            self.jsContext = webView.value(forKeyPath: "documentView.webView.mainFrame.javaScriptContext") as? JSContext
            self.jsContext?.setObject(model, forKeyedSubscript: "otosaas" as (NSCopying & NSObjectProtocol)!)
            shouldIntercept = false
            return false
        }
        let context = webView.value(forKeyPath: "documentView.webView.mainFrame.javaScriptContext") as? JSContext
        self.jsContext = context
        self.jsContext?.setObject(model, forKeyedSubscript: "otosaas" as (NSCopying & NSObjectProtocol)!)
        
        return true
    }
}
