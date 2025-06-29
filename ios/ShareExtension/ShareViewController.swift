//
//  ShareViewController.swift
//  ShareExtension
//
//  Created by iori on 2025/05/05.
//

import UIKit
import Social
import receive_sharing_intent

class ShareViewController: RSIShareViewController {

    // ホストアプリへ自動的にリダイレクトしたくない場合は、このメソッドで false を返します。
    // デフォルトは true です。
    override func shouldAutoRedirect() -> Bool {
        return false
    }

}
