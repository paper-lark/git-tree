//
//  RepositoryError.swift
//  git-tree
//
//  Created by Max Zhuravsky on 27.08.2024.
//

import Foundation

enum RepositoryError: Error {
    case cloneError(String)
    case filePathUnavailable
}
