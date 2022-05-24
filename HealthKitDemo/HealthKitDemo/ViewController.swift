//
//  ViewController.swift
//  HealthKitDemo
//
//  Created by ios on 2022/3/11.
//

import UIKit
import HealthKit

/*
 
            HKObjectType.workoutType() //步行+跑步距离
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) //活动能量
          HKObjectType.quantityType(forIdentifier: .distanceCycling) //  骑车距离
           HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate) //心率
 
           HKObjectType.quantityType(forIdentifier: .oxygenSaturation) //血氧
          HKObjectType.quantityType(forIdentifier: .bloodPressureSystolic) //血压
          HKObjectType.quantityType(forIdentifier: .bloodPressureDiastolic) //血压
 
           let allTypes = Set([HKObjectType.workoutType(),
                              HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
                              HKObjectType.quantityType(forIdentifier: .distanceCycling)!,
                               HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
                               HKObjectType.quantityType(forIdentifier: .heartRate)!,
                              HKObjectType.quantityType(forIdentifier: .stepCount)!])
 
           HKObjectType.quantityType(forIdentifier: <#T##HKQuantityTypeIdentifier#>)
           HKSampleType
           HKQuantityType：store numerical values.数量类型的 识存储数值的样本的类型 心率 收缩压 舒张压 用户体温 氧饱和度 心跳间隔 体重的数量
          HKQuantityType(<#T##identifier: HKQuantityTypeIdentifier##HKQuantityTypeIdentifier#>)
 
           HKCharacteristicType:用于不会随时间变化的，血型 出生时间 胜利性别等 biological sex, blood type, birthdate, Fitzpatrick skin type, and wheelchair use
           HKCharacteristicType(<#T##identifier: HKCharacteristicTypeIdentifier##HKCharacteristicTypeIdentifier#>)
 
 识别样本的类型，这些样本包含一小组可能值中的一个值
          HKCategoryType(<#T##identifier: HKCategoryTypeIdentifier##HKCategoryTypeIdentifier#>)
 
         HKWorkoutType 标识存储有关锻炼信息的样本的类型
          HKWorkoutType
 
          HKCorrelationType 血压 食物 标识将多个子样本分组的样本的类型
          HKCorrelationType(<#T##identifier: HKCorrelationTypeIdentifier##HKCorrelationTypeIdentifier#>)
 
          HKActivitySummaryType 标识活动摘要对象的类型
 
         HKAudiogramSampleType别包含听力图数据的样本的类型
 
          HKClinicalType识别包含临床记录数据的样本的类型
         HKClinicalType(<#T##identifier: HKClinicalTypeIdentifier##HKClinicalTypeIdentifier#>)
 
           HKElectrocardiogramType识别包含心电图数据的样本的类型
 
 
 HKSeriesType() 存储在系列样本中的数据的类型
 
 
 
 */

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.red
                
        
    }
}

fileprivate weak var AlertController: UIAlertController?

public extension UIViewController {
    
    func bk_presentAlertController(
        title: String?,
        message: String?,
        preferredStyle: UIAlertController.Style,
        actions: [UIAlertAction])
        -> Void
    {
        DispatchQueue.main.async {
            let closure = { () in
                let temp = UIAlertController.init(title: title, message: message, preferredStyle: preferredStyle)
                for action in actions {
                    temp.addAction(action)
                }
                temp.popoverPresentationController?.sourceView = self.view
                temp.popoverPresentationController?.sourceRect = CGRect.init(x: 0, y: self.view.height/2, width: self.view.width, height: 1)
                self.present(temp, animated: true, completion: nil)
                AlertController = temp
            }
            if let alert = AlertController, let _ = alert.presentingViewController {
                
                alert.dismiss(animated: true, completion: closure)
            }else {
                closure()
            }
        }
    }
    
    func bk_presentWarningAlertController(
        title: String,
        message: String,
        style: UIAlertAction.Style = .default,
        closure: ((UIAlertAction) -> Void)? = nil)
        -> Void
    {
        DispatchQueue.main.async {
            let action = UIAlertAction.init(title: "确定".localized, style: style, handler: closure)
            self.bk_presentAlertController(title: title, message: message, preferredStyle: .alert, actions: [action])
        }
    }
    
    /** 返回结果 */
    func bk_presentResultAlertController(
        title: String,
        message: String,
        style: UIAlertAction.Style = .default,
        decisionTitle: String?,
        closure: ((UIAlertAction) -> Void)? = nil)
        -> Void
    {
        DispatchQueue.main.async {
            let action = UIAlertAction.init(title: decisionTitle ?? "确定".localized, style: style, handler: closure)
            action.setValue(Colors.theme, forKey: "_titleTextColor")
            self.bk_presentAlertController(title: title, message: message, preferredStyle: .alert, actions: [action])
        }
    }
    
    func bk_presentDecisionAlertController(
        title: String?,
        message: String?,
        decisionTitle: String?,
        isNeedRed: Bool = false,
        decisionClosure: @escaping (UIAlertAction) -> Void,
        cancelClosure: ((UIAlertAction) -> Void)? = nil)
        -> Void
    {
        DispatchQueue.main.async {
            let action1 = UIAlertAction.init(title: decisionTitle ?? "确定".localized, style: .default, handler: decisionClosure)
            let action2 = UIAlertAction.init(title: "取消".localized, style: .cancel, handler: cancelClosure)
            if isNeedRed {
                action1.setValue(UIColor.red, forKey: "_titleTextColor")
            }
            self.bk_presentAlertController(title: title, message: message, preferredStyle: .alert, actions: [action1, action2])
        }
    }
    
    func bk_presentInputAlertController(title: String?, msg: String?, inputDesc: String, keyboardType: UIKeyboardType, closure: @escaping ((String) -> Void)) -> Void {
        
        DispatchQueue.main.async {
            let temp = UIAlertController(title: title, message: msg, preferredStyle: .alert)
            temp.addTextField {
                $0.placeholder = inputDesc
                $0.keyboardType = keyboardType
            }
            let confirm = UIAlertAction(title: "确定".localized, style: .default) { [weak temp] (_) in
                
                guard let textField = temp?.textFields?[0] else { return }
                guard let text = textField.text, !text.isEmpty else { return }
                self.view.endEditing(true)
                closure(text)
            }
            let cancel = UIAlertAction(title: "取消".localized, style: .cancel, handler: nil)
            temp.addAction(confirm)
            temp.addAction(cancel)
            self.present(temp, animated: true, completion: nil)
        }
        
    }
}
