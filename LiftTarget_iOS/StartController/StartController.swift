//
//  StartController.swift
//  LiftTarget_iOS
//
//  Created by Игорь Андрианов on 02.07.2022.
//

import UIKit
import CoreBluetooth

class StartController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate, CBPeripheralManagerDelegate, UITextFieldDelegate {
    //MARK: Properties
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var scanButton: UIButton!
    @IBOutlet weak var disconnectButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    
    var watchers: [BluetoothWatcher?] = []
    var centralBluetoothManager: CBCentralManager!
    var peripherals: Set<CBPeripheral> = [] {
        didSet {
            peripheralsArray = Array(peripherals)
                .sorted { $0.name! > $1.name!
            }
        }
    }
    var peripheralsArray = [CBPeripheral]() {
        didSet {
            searchVC?.peripheralsInfoList = peripheralsArray.map{
                ($0.name ?? "" ,$0.identifier.uuidString)
            }
        }
    }
    
    var peripheralBluetoothManager: CBPeripheralManager!
    var myPeripheral: CBPeripheral? {
        willSet {
            if newValue != nil {
                disconnectButton.isEnabled = true
                scanButton.isEnabled = false
                playButton.isEnabled = true
            } else {
                disconnectButton.isEnabled = false
                scanButton.isEnabled = true
                playButton.isEnabled = false
            }
        }
    }
    var myCharactericric: CBCharacteristic? {
        willSet {
            if newValue != nil {
                sendButton.isEnabled = true
            } else {
                sendButton.isEnabled = false
            }
        }
    }
    var myDescriptor: CBDescriptor?
    var searchVC: SearchController?
    var gameVC: GameController?
    
    let systemText = "system:    "
    let incomingText = "incoming:  "
    let outputText = "outcoming: "

    //MARK: ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        centralBluetoothManager = CBCentralManager(delegate:self, queue:nil, options: nil)
        peripheralBluetoothManager = CBPeripheralManager(delegate: self, queue: nil)
        scanButton.isEnabled = false
        sendButton.isEnabled = false
        disconnectButton.isEnabled = false
        //TODO: TEST!!! CHANGE TO FALSE WHEN REAL USE
        playButton.isEnabled = true
        
        configureTextView()
        configureKeyboard()
    }
    
    @IBAction func playTapped(_ sender: Any) {
        performSegue(withIdentifier: "showGameConfig", sender: nil)
    }
    
    //MARK: TextViews
    private func configureTextView() {
        textView.isEditable = false
        textView.textAlignment = .left
        textView.text = systemText + "Hello!"
        let range = NSRange(location: textView.text.count - 1, length: 0)
        textView.scrollRangeToVisible(range)
    }
    
    @IBAction func clearTextViewTapped(_ sender: Any) {
        textView.text = ""
    }
    
    private func showMessage(message: String) {
        guard let text = textView.text else { return }
        textView.text = text + "\n" + message
    }
    
    private func errorHandler(error: Error?) {
        showMessage(message: systemText + error.debugDescription)
        disconnect()
        clearCBObjects()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendMessageToPeripheral()
        return true
    }
    
    func configureKeyboard() {
        textField.delegate = self
        textField.autocorrectionType = .no
        textField.keyboardType = .asciiCapable
        textField.returnKeyType = .send
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        recognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(recognizer)
    }
    
    @objc
    func hideKeyboard() {
        view.endEditing(true)
    }
    
    //MARK: SendMessage
    
    private func sendMessageToPeripheral() {
        guard myCharactericric != nil,
              let text = textField.text
        else {
            showMessage(message: systemText + "error sending - not connected")
            view.endEditing(true)
            textField.text = ""
            return
        }
        if text != "" {
            let finalText = text + "\0"
            guard let chatacteristic = myCharactericric,
                  let data = (finalText.data(using: .ascii))
            else {
                showMessage(message: systemText + "some sending error")
                return
            }
            let array = [UInt8](data)
            print(array.description)
            
            showMessage(message: outputText + finalText)

            myPeripheral?.writeValue(data , for: chatacteristic, type: .withResponse)
        }
    }
    
    //MARK: IBActions
    
    @IBAction func buttonTapped(_ sender: Any) {
        sendMessageToPeripheral()
    }
    
    @IBAction func scanButton(_ sender: Any) {
        performSegue(withIdentifier: "showScan", sender: nil)
    }
    
    @IBAction func disconnectButton(_ sender: Any) {
        disconnect()
    }
    
    private func disconnect() {
        if let peripheral = myPeripheral { centralBluetoothManager.cancelPeripheralConnection(peripheral)
        }
    }
    
    //MARK: PrepareForSegue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let searchVC = segue.destination as? SearchController
        {
            searchVC.startVC = self as StartControllerProtocol
            self.searchVC = searchVC
        } else if let configVC = segue.destination as? ConfigureGameController {
            configVC.startVC = self as BluetoothManager
        }
    }
    
    //MARK: CentralManager
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn && myPeripheral == nil {
            scanButton.isEnabled = true
        } else {
            scanButton.isEnabled = false
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        peripherals.insert(peripheral)
    }
    
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        showMessage(message: systemText + "connected")
        myPeripheral = peripheral
        myPeripheral?.delegate = self
        myPeripheral?.discoverServices(nil)
    }
    
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        guard error == nil else {
            errorHandler(error: error)
            return
        }
        showMessage(message: systemText + "disconnected")
        clearCBObjects()
    }
    
    func clearCBObjects() {
        myPeripheral = nil
        myCharactericric = nil
        myDescriptor = nil
    }
    
    //MARK: PeripheralManager
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        var message = systemText + "peripheral manager "
        switch peripheral.state {
        case .poweredOn:
            message += "poweredOn"
        case .poweredOff:
            message += "poweredOff"
            clearCBObjects()
        case .resetting:
            message += "resetting"
        case .unauthorized:
            message += "unauthorized"
        case .unsupported:
            message += "unsupported"
        default:
            message += "unknown"
        }
        showMessage(message: message)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard error == nil else {
            errorHandler(error: error)
            return
        }
        guard let services = peripheral.services else {
            showMessage(message: systemText + "no services finded")
            return
        }
        for service in services {
            if service.uuid == CBUUID(string: "FFE0") {
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard error == nil else {
            errorHandler(error: error)
            return
        }
        guard let characteristics = service.characteristics else {
            showMessage(message: systemText + "no characteristics finded")
            return
        }
        for characteristic in characteristics {
            if characteristic.uuid == CBUUID(string: "FFE1") {
                myCharactericric = characteristic
                peripheral.discoverDescriptors(for: characteristic)
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil else {
            errorHandler(error: error)
            return
        }
        guard let descriptors = characteristic.descriptors
        else {
            showMessage(message: systemText + "no descriptors finded")
            return
        }
        for descriptor in descriptors {
            myDescriptor = descriptor
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil else {
            errorHandler(error: error)
            return
        }
        showMessage(message: systemText + "ready for incomming")
        print(characteristic.description + "\(characteristic.isNotifying)")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil else {
            errorHandler(error: error)
            return
        }
        guard let value = characteristic.value else { return }
        let array = [UInt8](value)
        print(array.description)
        let newArray = array.dropLast()
        guard let text = String(bytes: newArray, encoding: .ascii)
        else {
            showMessage(message: systemText + "decoding error")
            return
        }
        showMessage(message: incomingText + text)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil else {
            errorHandler(error: error)
            return
        }
        showMessage(message: systemText + "sended")
    }
    
}
