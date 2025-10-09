//
//  NetworkResult.swift
//  RajaKiRani
//
//  Created by KS-MACIMINI-016 on 13/03/25.
//

import Foundation

public typealias NetworkResult<T> = Result<T, APIError>
public typealias NetworkTask<T> = Task<T, Error>
