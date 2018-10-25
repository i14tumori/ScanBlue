//
//  main.swift
//  ScanBlue
//
//  Created by 津森智己 on 2018/10/25.
//  Copyright © 2018 津森智己. All rights reserved.
//

import Foundation
import CoreBluetooth

class RN4020: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    // Bluetooth関連変数
    var centralManager: CBCentralManager!
    var peripheral: CBPeripheral!
    // MLDPのサービスのUUID
    let target_service_uuid = CBUUID(string: "00035B03-58E6-07DD-021A-08123A000300")
    let target_charactaristic_uuid = CBUUID(string: "00035B03-58E6-07DD-021A-08123A000301")
    let target_charactaristic_uuid2 = CBUUID(string: "00035B03-58E6-07DD-021A-08123A0003FF")
    
    var discoverDevice = [CBPeripheral]()
    
    let standardOutput = FileHandle.standardOutput

    // インスタンスの生成および初期化
    func generation() {
        centralManager = CBCentralManager(delegate: self as CBCentralManagerDelegate, queue: nil, options: nil)
    }
    
    // BLEデバイスの検出を開始
    func startScan() {
        // 第一引数でMLDPのサービスを指定
        centralManager.scanForPeripherals(withServices:[target_service_uuid], options: nil)
    }
    
    // セントラルマネージャの状態が変化すると呼ばれる
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOff:
            standardOutput.write("Bluetooth 電源 OFF\r\n".data(using: .utf8)!)
            exit(0)
        case .poweredOn:
            standardOutput.write("Bluetooth 電源 ON\r\n".data(using: .utf8)!)
            // スキャン開始
            startScan()
        case .resetting:
            standardOutput.write("レスティング状態\r\n".data(using: .utf8)!)
            exit(0)
        case .unauthorized:
            standardOutput.write("非認証状態\r\n".data(using: .utf8)!)
            exit(0)
        case .unknown:
            standardOutput.write("不明\r\n".data(using: .utf8)!)
            exit(0)
        case .unsupported:
            standardOutput.write("非対応\r\n".data(using: .utf8)!)
            exit(0)
        }
    }
    
    // ペリフェラルを発見すると呼ばれる
    // CBPeripheralオブジェクトの形で発見したPeripheralを受け取る
    func centralManager(_ central: CBCentralManager,didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if peripheral.name != nil && !discoverDevice.contains(peripheral) {
            print("discover peripheral : \(peripheral.name!)")
            discoverDevice.append(peripheral)
        }
    }
}

func endProcess() {
    // 終了合図を待ち続ける
    while true {
        let standardInput = FileHandle.standardInput
        // 改行を取り除く
        let input = String(data: standardInput.availableData, encoding: .utf8)!.prefix(2)
        // 終了合図ならexitで終わる
        if input == "~." {
            exit(0)
        }
    }
}

/* プログラム開始 */

// インスタンス生成
var rn = RN4020()
rn.generation()

let runLoop = RunLoop.current
let distantFuture = Date.distantFuture
var running = true

var flag = true

// ループ
while running == true && runLoop.run(mode: RunLoop.Mode.default, before: distantFuture) {
    if flag == true {
        // 別スレッドでキーボード入力を待つ
        let dispatchQueue = DispatchQueue.global(qos: .default)
        dispatchQueue.async {
            endProcess()
        }
        flag = false
    }
}

