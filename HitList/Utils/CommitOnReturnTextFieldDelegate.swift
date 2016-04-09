//
//  CommitOnReturnTextFieldDelegate.swift
//  HitList
//
//  Created by Turzion, Avihu on 4/9/16.
//  Copyright © 2016 Avihu Turzion. All rights reserved.
//

import UIKit

typealias TextFieldCommitHandler = (UITextField) -> ()

class CommitOnReturnTextFieldDelegate: NSObject {

  private let handler: TextFieldCommitHandler?

  init(handler: TextFieldCommitHandler?) {
    self.handler = handler
  }

}

extension CommitOnReturnTextFieldDelegate: UITextFieldDelegate {

  func textFieldShouldReturn(textField: UITextField) -> Bool {
    handler?(textField)
    return true
  }

}