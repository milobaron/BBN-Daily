//
//  LunchMenuVC.swift
//  BBNDaily
//
//  Created by Mike Veson on 7/22/22.
//

import Foundation
import UIKit
import WebKit

class LunchMenuVC: CustomLoader, WKNavigationDelegate {
    private let webView: WKWebView = {
        let webview = WKWebView(frame: .zero)
        return webview
    }()
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        hideLoaderView()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let urlstring = "http://docs.google.com/document/d/1QL-uIHSCOC5oZV3tOthRAuGEjmDjGIl-hlMdzcrpwIk/edit?usp=sharing"
//                webView.load
        webView.backgroundColor = UIColor.white
        view.addSubview(webView)
        webView.frame = view.bounds
        webView.navigationDelegate = self
        guard let url = URL(string: urlstring) else {
            return
        }
        webView.load(URLRequest(url: url))
        showLoaderView()
//        let storage = FirebaseStorage.Storage.storage()
//        let reference = storage.reference(withPath: "lunchmenus/lunchmenu-allergy.docx")
//        reference.downloadURL(completion: { [self] (url, error) in
//            if let error = error {
//                print(error)
//            }
//            else {
//                print("the url is: \(url!.absoluteString)")
////                let urlstring = url!.absoluteString
//
//            }
//        })
        view.backgroundColor = UIColor.white
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.revealViewController()?.gestureEnabled = false
    }
}