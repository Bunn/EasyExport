//
//  EasyExport.swift
//
//  Created by Fernando Bunn on 26/10/18.
//  Copyright © 2018 Fernando Bunn. All rights reserved.
//

import Foundation

class Runner {
    private var counter = 0
    
    func unlock() {
        counter -= 1
    }
    
    func lock() {
        counter += 1
    }
    
    func run() {
        let runLoop = RunLoop.current
        while counter > 0 &&
            runLoop.run(mode: RunLoop.Mode.default, before: Date(timeIntervalSinceNow: 0.1)) {
        }
    }
}

struct Investment: Codable {
    let financialValueCurrent: Decimal
    var fixedIncomeSecurityType: String?
    let grossValue: Decimal
    let investedCapital: Decimal
    let nickName: String
    let priceCurrent: Decimal
    let netValue: Decimal
    var index: String?
    var profit: Decimal {
        return netValue - investedCapital
    }
}

struct Custody: Codable {
    let id: String
    let result: [Investment]
}

struct Token: Codable {
    let accessToken: String
    let tokenType: String
    
    func authorizationToken() -> String {
        return "\(tokenType) \(accessToken)"
    }
}

extension String {
    func trim() -> String {
        return self.trimmingCharacters(in: NSCharacterSet.whitespaces)
    }
}

struct Printer {
    func printData(data: Data?) {
        if let data = data {
            do {
                let decoder = JSONDecoder()
                let custody = try decoder.decode(Custody.self, from: data)
                var totalNetValue: Decimal = 0.0
                var totalProfit: Decimal = 0.0

                let formatter = NumberFormatter()
                formatter.locale = Locale.current
                formatter.numberStyle = .currency
                print("")
                
                for item in custody.result {
                    let netValue = formatter.string(for: item.netValue) ?? "--"
                    let invested = formatter.string(for: item.investedCapital) ?? "--"
                    let profit = formatter.string(for: (item.profit)) ?? "--"
                    print("""
                        * \(item.nickName.trim()) *
                        Invested: \(invested)
                        NetValue: \(netValue)
                        Profit: \(profit)
                        Index: \(item.index ?? "--")
                        Type: \(item.fixedIncomeSecurityType ?? "--")
                        
                        """)
                    totalNetValue += item.netValue
                    totalProfit += item.profit
                }
                print("""
                    Total NetValue: \(formatter.string(for: totalNetValue) ?? "--")
                    Total Profit: \(formatter.string(for: totalProfit) ?? "--")
                    """)
            } catch {
                print("Error \(error)")
            }
        }
    }
}

struct Network {
    private let custodyURL = "https://api.easynvest.com.br/legacy/v1/balance/financialcustody"
    private let tokenURL = "https://api.easynvest.com.br/auth/v2/security/token"
    private let credentials = ""
    private let sessionConfig = URLSessionConfiguration.default
    
    private func fetchToken(completion: @escaping (Token?) -> ()) {
        print("Fetching auth token...");
        
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        guard let URL = URL(string: tokenURL) else {
            completion(nil)
            return
        }
        
        var request = URLRequest(url: URL)
        request.httpMethod = "POST"
        request.addValue("text/plain; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = credentials.data(using: .utf8, allowLossyConversion: true)
        
        let task = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            if (error == nil) {
                if let data = data {
                    do {
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        let token = try decoder.decode(Token.self, from: data)
                        completion(token)
                    } catch {
                        print("Error \(error)")
                        completion(nil)
                    }
                } else {
                    completion(nil)
                }
            }
            else {
                completion(nil)
                print("URL Session Task Failed: %@", error!.localizedDescription);
            }
        })
        task.resume()
        session.finishTasksAndInvalidate()
    }
    
    private func fetchInvestments(token: Token, completion:@escaping ()->()) {
        print("Fetching investments...");
        
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        guard let URL = URL(string: custodyURL) else {
            completion()
            return
        }
        
        var request = URLRequest(url: URL)
        request.httpMethod = "GET"
        request.addValue(token.authorizationToken(), forHTTPHeaderField: "Authorization")
        
        let task = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            if (error == nil) {
                Printer().printData(data: data)
            }
            else {
                print("URL Session Task Failed: %@", error!.localizedDescription);
            }
            completion()
        })
        task.resume()
        session.finishTasksAndInvalidate()
    }
    
    func printInvestments(completion:@escaping ()->()) {
        fetchToken { token in
            if let token = token {
                self.fetchInvestments(token: token, completion: completion)
            } else {
                completion()
            }
        }
    }
}

let runner = Runner()
runner.lock()

Network().printInvestments {
    runner.unlock()
}

runner.run()
