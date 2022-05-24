//
//  MainViewController.swift
//  HealthKitDemo
//
//  Created by ios on 2022/3/11.
//

import UIKit
import HealthKit
import SwiftUI
import SVProgressHUD
import SnapKit
import SwifterBaseKit

struct Colors {
    static let theme = UIColor.color(hexString: "#00CF91")
}

class MainViewController: UIViewController {
    
    public let healthStore = HKHealthStore()
    
    private lazy var requestButton: UIButton = {
        let sn = UIButton(type: .custom)
        sn.backgroundColor = Colors.theme
        sn.titleColorForNormal = UIColor.white
        sn.setTitle("首次需要授权", for: .normal)
        sn.layer.cornerRadius = 5
        sn.addTarget(self, action: #selector(self.requestAuthorization), for: .touchUpInside)
        view.addSubview(sn)
        return sn
    }()
    
    private lazy var rateButton: UIButton = {
        let sn = UIButton(type: .custom)
        sn.backgroundColor = Colors.theme
        sn.titleColorForNormal = UIColor.white
        sn.setTitle("获取心率", for: .normal)
        sn.layer.cornerRadius = 5
        sn.addTarget(self, action: #selector(self.queryHeartRate), for: .touchUpInside)
        view.addSubview(sn)
        return sn
    }()
    
    private lazy var bloodButton: UIButton = {
        let sn = UIButton(type: .custom)
        sn.backgroundColor = Colors.theme
        sn.titleColorForNormal = UIColor.white
        sn.setTitle("获取血压", for: .normal)
        sn.layer.cornerRadius = 5
        sn.addTarget(self, action: #selector(self.queryBloodPressure), for: .touchUpInside)
        view.addSubview(sn)
        return sn
    }()
    
    private lazy var oxygenButton: UIButton = {
        let sn = UIButton(type: .custom)
        sn.backgroundColor = Colors.theme
        sn.titleColorForNormal = UIColor.white
        sn.setTitle("获取血氧", for: .normal)
        sn.layer.cornerRadius = 5
        sn.addTarget(self, action: #selector(self.queryBloodOxygen), for: .touchUpInside)
        view.addSubview(sn)
        return sn
    }()
    
    private lazy var stepButton: UIButton = {
        let sn = UIButton(type: .custom)
        sn.backgroundColor = Colors.theme
        sn.titleColorForNormal = UIColor.white
        sn.setTitle("获取步数", for: .normal)
        sn.layer.cornerRadius = 5
        sn.addTarget(self, action: #selector(self.queryStepCount), for: .touchUpInside)
        view.addSubview(sn)
        return sn
    }()
    
    var info = [(key: String,value: String)]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Health Data"
        view.backgroundColor = UIColor.color(hexString: "#F6F6F6")
        
        if #available(iOS 13, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            //            appearance.backgroundImage = UIColor.white
            appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
            appearance.shadowImage = UIImage()
            /// 不设置会出现一条黑线
            appearance.shadowColor = UIColor.clear
            /// 去掉半透明
            appearance.backgroundEffect = nil
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
            
            navigationController?.navigationBar.isTranslucent = false
            navigationController?.navigationBar.barStyle = .default
            navigationController?.navigationBar.tintColor = .white
            
        }
        
        requestButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(60)
            make.size.equalTo(CGSize(width: 150, height: 45))
        }
        
        rateButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(requestButton.snp.bottom).offset(30)
            make.size.equalTo(CGSize(width: 150, height: 45))
        }
        
        bloodButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(rateButton.snp.bottom).offset(30)
            make.size.equalTo(CGSize(width: 150, height: 45))
        }
        
        oxygenButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(bloodButton.snp.bottom).offset(30)
            make.size.equalTo(CGSize(width: 150, height: 45))
        }
        
        stepButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(oxygenButton.snp.bottom).offset(30)
            make.size.equalTo(CGSize(width: 150, height: 45))
        }
    }
}

//MARK: - 授权
extension MainViewController {
    
    @objc private func requestAuthorization() {
        if HKHealthStore.isHealthDataAvailable() {
            guard HKHealthStore.isHealthDataAvailable() else {
                SVProgressHUD.showError(withStatus: "健康数据不可用")
                return
            }
            
            guard
                let heartRateData = HKObjectType.quantityType(forIdentifier: .heartRate),
                let bloodPressureDataSystolic = HKObjectType.quantityType(forIdentifier: .bloodPressureSystolic),
                let bloodPressureDataDiastolic = HKObjectType.quantityType(forIdentifier: .bloodPressureDiastolic),
                let stepCount = HKObjectType.quantityType(forIdentifier: .stepCount),
                let bloodOxygen = HKObjectType.quantityType(forIdentifier: .oxygenSaturation)
            else {
                SVProgressHUD.showError(withStatus: "无法读取健康数据")
                return
            }
            
            let writing: Set<HKSampleType> = [heartRateData, bloodPressureDataSystolic, bloodPressureDataDiastolic, stepCount, bloodOxygen]
            let reading: Set<HKObjectType> = [heartRateData, bloodPressureDataSystolic, bloodPressureDataDiastolic, stepCount, bloodOxygen]
            HKHealthStore().requestAuthorization(toShare: writing, read: reading) { result, error in
                if !result {
                    SVProgressHUD.showError(withStatus: "健康数据不可用")
                }
            }
        }
    }
}

//MARK: - 心率
extension MainViewController {
    
    @objc private func queryHeartRate() {
        let status = healthStore.authorizationStatus(for: HKObjectType.quantityType(forIdentifier: .heartRate)!)
        switch status {
            case .notDetermined:
                SVProgressHUD.showError(withStatus: "未授权获取心率数据")
            case .sharingDenied:
                SVProgressHUD.showError(withStatus: "未授权保存心率数据")
            case .sharingAuthorized:
                print("sharingAuthorized")
                self.getHeartRate()
            @unknown default:
                fatalError()
        }
    }
    
    private func getHeartRate() {
        var rateDatas = [HealthKitMeasurement]()
        
        guard let fvcType = HKSampleType.quantityType(forIdentifier: .heartRate) else {
            print("Sample type not available")
            return
        }
        
        let lastWeekPredicate = HKQuery.predicateForSamples(withStart: Date().lastMonth, end: Date(), options: .strictEndDate)
        let bpmUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
        
        let heartRateQuery = HKSampleQuery.init(sampleType: fvcType,
                                                predicate: lastWeekPredicate,
                                                limit: HKObjectQueryNoLimit,
                                                sortDescriptors: nil) { [weak self](query, results, error) in
            guard let self = self else { return }
            guard error == nil, let quantitySamples = results as? [HKQuantitySample]  else {
                print("error is store")
                return
            }
            DispatchQueue.global().async {
                for values in quantitySamples {
                    let model = HealthKitMeasurement(id: values.uuid.uuidString, quantityString: String(format: "%.0f", values.quantity.doubleValue(for: bpmUnit)), quantityDouble: values.quantity.doubleValue(for: bpmUnit), date: values.endDate, dateString: "", deviceName: values.device?.name, type: "心率", icon: "Rate", unit: "bpm")
                    rateDatas.append(model)
                }
                DispatchQueue.main.async {
                    if rateDatas.count > 0 {
                        self.bk_presentWarningAlertController(title: "心率", message: rateDatas.last!.quantityString)
                    }
                }
            }
            
        }
        healthStore.execute(heartRateQuery)
    }
}

//MARK: - 血压
extension MainViewController {
    
    @objc private func queryBloodPressure() {
        let status = healthStore.authorizationStatus(for: HKObjectType.quantityType(forIdentifier: .bloodPressureSystolic)!)
        switch status {
            case .notDetermined:
                SVProgressHUD.showError(withStatus: "未授权获取血压数据")
            case .sharingDenied:
                SVProgressHUD.showError(withStatus: "未授权保存血压数据")
            case .sharingAuthorized:
                print("sharingAuthorized")
                self.getBlood()
            @unknown default:
                fatalError()
        }
        
    }
    
    private func getBlood() {
        var bloodDatas = [HealthKitCorrelationMeasurement]()
        guard
            let bloodPressureType = HKQuantityType.correlationType(forIdentifier: .bloodPressure),
            let systolicType = HKObjectType.quantityType(forIdentifier: .bloodPressureSystolic),
            let diastolicType = HKObjectType.quantityType(forIdentifier: .bloodPressureDiastolic)
        else {
            print("Sample type not available")
            return
        }
        
        let lastWeekPredicate = HKQuery.predicateForSamples(withStart: Date().lastMonth, end: Date(), options: .strictEndDate)
        
        let query = HKSampleQuery(sampleType: bloodPressureType, predicate: lastWeekPredicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { [weak self] query, results, error in
            
            guard let self = self else { return }
            guard error == nil, let correlationSamples = results as? [HKCorrelation]  else {
                print("error is store")
                return
            }
            DispatchQueue.global().async {
                for values in correlationSamples {
                    if let systolicData = values.objects(for: systolicType).first as? HKQuantitySample,
                       let diastolicData = values.objects(for: diastolicType).first as? HKQuantitySample {
                        
                        let systolicValue = systolicData.quantity.doubleValue(for: HKUnit.millimeterOfMercury())
                        let diastolicValue = diastolicData.quantity.doubleValue(for: HKUnit.millimeterOfMercury())
                        
                        let systolicModel = HealthKitMeasurement(id: values.uuid.uuidString, quantityString: String(format: "%.0f", systolicValue), quantityDouble: systolicValue, date: values.endDate, dateString: values.endDate.dateString(), deviceName: "收缩压", type: "systolicBloodPressure", icon: "systolicBloodPressure", unit: "mmHg")
                        
                        let diastolicModel = HealthKitMeasurement(id: "DBP" + values.uuid.uuidString, quantityString: String(format: "%.0f", diastolicValue), quantityDouble: diastolicValue, date: values.endDate, dateString: values.endDate.dateString(), deviceName: "舒张压", type: "diastolicBloodPressure", icon: "diastolicBloodPressure", unit: "mmHg")
                        
                        let model = HealthKitCorrelationMeasurement(id: "SBP"+values.uuid.uuidString, type: "BloodPressure", icon: "BloodPressure", unit: "mmHg", date: values.endDate, dateString: values.endDate.dateString(), measurement1: systolicModel, measurement2: diastolicModel)
                        bloodDatas.append(model)
                    }
                }
                
                DispatchQueue.main.async {
                    if bloodDatas.count > 0 {
                        self.info.append(("收缩压", bloodDatas.last!.measurement1.quantityString))
                        self.info.append(("舒张压", bloodDatas.last!.measurement2.quantityString))
                        self.showInfo()
                    }else {
                        SVProgressHUD.showInfo(withStatus: "暂无血压数据")
                    }
                }
            }
            
        }
        healthStore.execute(query)
    }
    
    private func showInfo() {
        if info.count > 0 {
            let message = info.map({ "\($0.key): \($0.value)" }).joined(separator: "\n")
            self.bk_presentWarningAlertController(title: "血压", message: message, style: .default)
        }
        info = []
    }
}

//MARK: - 血氧
extension MainViewController {
    
    @objc private func queryBloodOxygen() {
        let status = healthStore.authorizationStatus(for: HKObjectType.quantityType(forIdentifier: .oxygenSaturation)!)
        switch status {
            case .notDetermined:
                SVProgressHUD.showError(withStatus: "未授权获取血氧数据")
            case .sharingDenied:
                SVProgressHUD.showError(withStatus: "未授权保存血氧数据")
            case .sharingAuthorized:
                print("sharingAuthorized")
                self.getBloodOxygen()
            @unknown default:
                fatalError()
        }
        
    }
    
    private func getBloodOxygen() {
        var oxygenDatas = [HealthKitMeasurement]()
        guard let fvcType = HKSampleType.quantityType(forIdentifier: .oxygenSaturation) else {
            print("Sample type not available")
            return
        }
        
        let lastWeekPredicate = HKQuery.predicateForSamples(withStart: Date().lastMonth, end: Date(), options: .strictEndDate)
        
        let query = HKSampleQuery.init(sampleType: fvcType,
                                       predicate: lastWeekPredicate,
                                       limit: HKObjectQueryNoLimit,
                                       sortDescriptors: nil) { [weak self](query, results, error) in
            guard let self = self else { return }
            guard error == nil, let quantitySamples = results as? [HKQuantitySample]  else {
                print("error is store")
                return
            }
            DispatchQueue.global().async {
                for values in quantitySamples {
                    let model = HealthKitMeasurement(id: values.uuid.uuidString, quantityString: String(format: "%zd", (values.quantity.doubleValue(for: HKUnit.count()) * 100).int), quantityDouble: values.quantity.doubleValue(for: HKUnit.count()), date: values.endDate, dateString: "", deviceName: values.device?.name, type: "血氧", icon: "Oxygen", unit: "HbO2")
                    oxygenDatas.append(model)
                }
                DispatchQueue.main.async {
                    if oxygenDatas.count > 0 {
                        self.bk_presentWarningAlertController(title: "血氧浓度", message: "\(oxygenDatas.last!.quantityString)%")
                    }
                }
            }
        }
        
        healthStore.execute(query)
    }
}

//MARK: - 步数
extension MainViewController {
    
    @objc private func queryStepCount() {
        let status = healthStore.authorizationStatus(for: HKObjectType.quantityType(forIdentifier: .stepCount)!)
        switch status {
            case .notDetermined:
                SVProgressHUD.showError(withStatus: "未授权获取步数数据")
            case .sharingDenied:
                SVProgressHUD.showError(withStatus: "未授权保存步数数据")
            case .sharingAuthorized:
                print("sharingAuthorized")
                self.getStepCount()
            @unknown default:
                fatalError()
        }
        
    }
    
    private func getStepCount() {
        var stepCount = 0
        guard let fvcType = HKSampleType.quantityType(forIdentifier: .stepCount) else {
            print("Sample type not available")
            return
        }
        
        let start_sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let end_sort  = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        var dataCom = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: Date())
        let endDate = calendar.date(from: dataCom)    //设置查询的截止时间(当前)
        dataCom.hour = 0
        dataCom.minute = 0
        dataCom.second = 0
        let startDate = calendar.date(from: dataCom)    //设置查询的起始时间(当天0点)
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: HKQueryOptions.strictStartDate)
        
        
        let heartRateQuery = HKSampleQuery.init(sampleType: fvcType,
                                                predicate: predicate,
                                                limit: HKObjectQueryNoLimit,
                                                sortDescriptors: [start_sort, end_sort]) { [weak self](query, results, error) in
            guard let self = self else { return }
            guard error == nil, let quantitySamples = results as? [HKQuantitySample]  else {
                print("error is store")
                return
            }
            DispatchQueue.global().async {
                for values in quantitySamples {
                    if values.sourceRevision.source.bundleIdentifier != Bundle.main.bundleIdentifier  {
                        stepCount += values.quantity.doubleValue(for: HKUnit.count()).int
                    }
                }
                DispatchQueue.main.async {
                    self.bk_presentWarningAlertController(title: "当天步数", message: "\(stepCount)")
                }
            }
        }
        healthStore.execute(heartRateQuery)
    }
}

