//
//  ViewController.swift
//  NetologiyaFinalWork
//
//  Created by Александр Мосолов on 01.12.2025.
//

import UIKit
import CoreData

class MainScreenViewController: UIViewController {
    
    
    let rootStack = UIStackView()
    
    let upperMainStack = UIStackView()
    let upperMainWhiteStack1 = UIStackView()
    let upperMainWhiteStack2 = UIStackView()
    
    let activeTasksStack = UIStackView()
    let activeTasksTitle = UILabel()
    let activeTasksLabel = UILabel()
    let whiteStackForActiveTasksStack = UIStackView()
    
    let completedTasksStack = UIStackView()
    let completedTasksTitle = UILabel()
    let completedTasksLabel = UILabel()
    let whiteStackForCompletedTaskStack = UIStackView()
    
    let collectedPointsStack = UIStackView()
    let collectedPointsTitle = UILabel()
    let collectedPointsLabel = UILabel()
    let whiteStackForCollectedPointsStack = UIStackView()
    
    let upperToMidleMainWhiteStack = UIStackView()
    let middleToBottomWhiteStack = UIStackView()
    
    let midleMainStack = UIStackView()
    let achievmentsStack = UIStackView()
    let whiteStackForMidleMainStack = UIStackView()
    
    let achievmentTitle = UILabel()
    
    let achievment1Stack = UIStackView()
    let achievment2Stack = UIStackView()
    let achievment3Stack = UIStackView()
    let achievment4Stack = UIStackView()
    let achievment5Stack = UIStackView()
    
    var achievment1View = UIImageView()
    var achievment2View = UIImageView()
    var achievment3View = UIImageView()
    var achievment4View = UIImageView()
    var achievment5View = UIImageView()
    
    let whiteStackForAchievmentStack = UIStackView()
    let whiteViewForAchievment1Stack = UIView()
    let whiteViewForAchievment2Stack = UIView()
    let whiteViewForAchievment3Stack = UIView()
    let whiteViewForAchievment4Stack = UIView()
    let whiteViewForAchievment5Stack = UIView()
    
    let achievmentVerMainSubStack = UIStackView()
    let achievmentVerSecondarySubStack = UIStackView()
    let achievmentVerWhiteStack = UIStackView()
    let achievmentVerSubStack1 = UIStackView()
    let achievmentVerSubStack2 = UIStackView()
    let achievmentVerSubStack3 = UIStackView()
    let achievmentVerSubStack4 = UIStackView()
    let achievmentVerSubStack5 = UIStackView()
    
    let achievment1Title = UILabel()
    let achievment2Title = UILabel()
    let achievment3Title = UILabel()
    let achievment4Title = UILabel()
    let achievment5Title = UILabel()
    
    var activeTasksToWin = Int()
    var completedTasksToWin = Int()
    var collectedPointsToWin = Int()
    var regimeComplianceToWin = Int()
    var countOfAchievmentsToWin = Int()
    
    var countOfAchievments = [0, 0, 0, 0]
    
    let achievment1Label = UILabel()
    let achievment2Label = UILabel()
    let achievment3Label = UILabel()
    let achievment4Label = UILabel()
    let achievment5Label = UILabel()
    
    let batteryStack = UIStackView()
    let batterySubStack1 = UIStackView()
    let batterySubStack2 = UIStackView()
    let batteryWhiteStack1 = UIStackView()
    let batteryWhiteStack2 = UIStackView()
    
    let middleToBottomMainWhiteStack = UIStackView()
    
    let bottomMainStack = UIStackView()
    let bottomMainRowStack = UIStackView()
    
    var batteryTitle = UILabel()
    var batteryLabel = UILabel()
    
    let batteryElement1 = UIView()
    let batteryElement2 = UIView()
    let batteryWhiteElement1 = UIView()
    let batteryWhiteElement2 = UIView()
    let batteryWhiteElement3 = UIView()
    let batteryLevel1 = UIView()
    let batteryLevel2 = UIView()
    let batteryLevel3 = UIView()
    let batteryLevel4 = UIView()
    let batteryLevel5 = UIView()
    let batteryLevel6 = UIView()
    let batteryLevel7 = UIView()
    let batteryLevel8 = UIView()
    let batteryLevel9 = UIView()
    let batteryLevel10 = UIView()
    
    private var fillTimer: Timer?
    private var targetFilled: Int = 0
    private var currentIndex: Int = 0
    private let stepDelay: TimeInterval = 0.2
    private let stepInterval: TimeInterval = 0.5
    private lazy var batteryLevels: [UIView] = [batteryLevel10, batteryLevel9, batteryLevel8, batteryLevel7, batteryLevel6, batteryLevel5, batteryLevel4, batteryLevel3, batteryLevel2, batteryLevel1]
    
    private var isAnimating = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateAllStats()
        updateAllAchievements()
        
        NotificationCenter.default.addObserver(self,
                    selector: #selector(settingsChanged),
                    name: NSNotification.Name("SettingsDidChange"),
                    object: nil)
        
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        loadSettingsFromDefaults()
        updateAllStats()
        updateAllAchievements()
        updateBatteryDisplay(percent: calculateRegimeCompliance())
    }
    
    @objc private func settingsChanged() {
        DispatchQueue.main.async {
            self.loadSettingsFromDefaults()
            self.updateAllStats()
            self.updateAllAchievements()
        }
    }
    deinit {
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name("SettingsDidChange"), object: nil)
        }

    
    
    
    private func updateAllStats() {
        activeTasksLabel.text = String(fetchNumbersOfTaskWithSpecialStatus().active)
        completedTasksLabel.text = String(fetchNumbersOfCompletedTaskLogs())
        collectedPointsLabel.text = String(fetchSumFactAndPlanTaskLogs().sumFact)
        batteryLabel.text = updateRegimeComplianceLabel().forLabel
        updateBatteryDisplay(percent: calculateRegimeCompliance())
    }
    
    
    private func fetchNumbersOfTaskWithSpecialStatus() -> (total: Int, active: Int, inactive: Int) {
        let ctx = TaskCoreDataManager.shared.viewContext
        let req: NSFetchRequest<Task> = Task.fetchRequest()
        do {
            let tasks = try ctx.fetch(req)
            let total = tasks.count
            let active = tasks.filter { $0.status == TaskStatus.launched.rawValue || $0.status == TaskStatus.run.rawValue }.count
            let inactive = tasks.filter { $0.status == TaskStatus.created.rawValue || $0.status == TaskStatus.stopped.rawValue }.count
            return (total, active, inactive)
        } catch {
            print("!!!Fetch error: \(error)")
            return (0, 0, 0)
        }
    }
    
    private func fetchNumbersOfCompletedTaskLogs() -> Int {
        // используем ваш TaskLogsCoreDataManager
        return TaskLogsCoreDataManager.shared.countLogs(withStatuses: [TaskStatus.launched.rawValue, TaskStatus.run.rawValue, TaskStatus.completed.rawValue])
    }
    
    private func fetchSumFactAndPlanTaskLogs() -> (sumFact: Int, sumPlan: Int) {
        return TaskLogsCoreDataManager.shared.sumFactAndPlanValues()
    }
    
    
    private func calculateRegimeCompliance() -> Double {
        let sums = fetchSumFactAndPlanTaskLogs()
        guard sums.sumPlan != 0 else { return 0.0 }
        let result = (Double(sums.sumFact) / Double(sums.sumPlan))
        updateBatteryDisplay(percent: result)
        return result
    }
    

    
//    private func updateBatteryDisplay(percent: Double) {
//        let clamped = max(0.0, min(1.0, percent))
//        // если новая величина не выше текущего прогресса, выход
//        let currentProgress = Double(currentIndex) / 10.0
//        if clamped <= currentProgress {
//            return
//        }
//
//        // вычисляем целевое количество уровней
//        let filled = filledLevelsCount(for: clamped)
//        targetFilled = filled
//        currentIndex = 0
//        fillTimer?.invalidate()
//        fillTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] t in
//            guard let self = self else { t.invalidate(); return }
//            if self.currentIndex < self.targetFilled {
//                self.batteryLevels[self.currentIndex].backgroundColor = .systemBlue.withAlphaComponent(0.5)
//                self.currentIndex += 1
//            } else {
//                t.invalidate()
//            }
//        }
//    }
    
    private func updateBatteryDisplay(percent: Double) {
        let clamped = max(0.0, min(1.0, percent))
        // текущее значение по индексу
        
        // целевой уровень
        let newTarget = filledLevelsCount(for: clamped)

        // если новая цель та же, выходим
        if newTarget == currentIndex { return }

        // если цель выше — анимация вверх
        if newTarget > currentIndex {
            targetFilled = newTarget
            startAnimation(upward: true)
            return
        }

        // если цель ниже — анимация вниз (закрашиваем серым)
        targetFilled = newTarget
        startAnimation(upward: false)
    }
    
    private func startAnimation(upward: Bool) {
        fillTimer?.invalidate()
        fillTimer = Timer.scheduledTimer(withTimeInterval: stepInterval, repeats: true) { [weak self] t in
            guard let self = self else { t.invalidate(); return }
            if upward {
                if self.currentIndex < self.targetFilled {
                    // окрашиваем следующий элемент
                    DispatchQueue.main.asyncAfter(deadline: .now() + self.stepDelay) {
                        self.batteryLevels[self.currentIndex].backgroundColor = .systemBlue.withAlphaComponent(0.5)
                        self.currentIndex += 1
                    }
                } else {
                    t.invalidate()
                }
            } else {
                // вниз: уменьшаем
                if self.currentIndex > self.targetFilled {
                    let idxToClear = self.currentIndex - 1
                    if idxToClear >= 0 {
                        // серый
                        DispatchQueue.main.asyncAfter(deadline: .now() + self.stepDelay) {
                            self.batteryLevels[idxToClear].backgroundColor = .lightGray
                            self.currentIndex -= 1
                        }
                    } else {
                        t.invalidate()
                    }
                } else {
                    t.invalidate()
                }
            }
            // завершение
            if self.currentIndex == self.targetFilled && upward {
                t.invalidate()
            }
        }
    }
    

    private func filledLevelsCount(for percent: Double) -> Int {
        let p = max(0.0, min(1.0, percent))
        return Int(ceil(p * 10.0))
    }
    
    private func updateRegimeComplianceLabel() -> (forLabel: String, forCalculation: Int) {
        let resultInt = Int(round(calculateRegimeCompliance() * 100))
        let resultString = "\(resultInt)%"
        return (resultString, resultInt)
    }
    
    private func loadSettingsFromDefaults() {
        let defaults = UserDefaults.standard
        activeTasksToWin = defaults.integer(forKey: "activeTasksToWin")
        completedTasksToWin = defaults.integer(forKey: "completedTasksToWin")
        collectedPointsToWin = defaults.integer(forKey: "collectedPointsToWin")
        regimeComplianceToWin = defaults.integer(forKey: "regimeComplianceToWin")
        countOfAchievmentsToWin = defaults.integer(forKey: "countOfAchievmentsToWin")
    }
    
    //MARK: - Achievments
    
    private func updateAllAchievements() {
        checkActiveTasksToWin()
        checkCompletedTasks()
        checkCollectedPoints()
        checkRegimeCompliance()
        checkCountOfAchievments()
        updateAchievmentLabels()
    }
    
    private func checkActiveTasksToWin() {
        
        let activeTasks = fetchNumbersOfTaskWithSpecialStatus().active
        
        if activeTasks >= activeTasksToWin {
            achievment1View.image = UIImage(named: "ActiveTasksColor")
            achievment1Title.textColor = .systemBlue.withAlphaComponent(0.75)
            achievment1Label.textColor = .black
            countOfAchievments[0] = 1
        } else {
            achievment1View.image = UIImage(named: "ActiveTasksGray")
            achievment1Title.textColor = .lightGray
            achievment1Label.textColor = .lightGray
            countOfAchievments[0] = 0
        }
    }
    
    private func checkCompletedTasks() {
        
        let completedTasks = fetchNumbersOfCompletedTaskLogs()
        
        if completedTasks >= completedTasksToWin {
            achievment2View.image = UIImage(named: "CompletedTasksColor")
            achievment2Title.textColor = .systemBlue.withAlphaComponent(0.75)
            achievment2Label.textColor = .black
            countOfAchievments[1] = 1
        } else {
            achievment2View.image = UIImage(named: "CompletedTasksGray")
            achievment2Title.textColor = .lightGray
            achievment2Label.textColor = .lightGray
            countOfAchievments[1] = 0
        }
    }
    
    private func checkCollectedPoints() {
        
        let collectedPoints = fetchSumFactAndPlanTaskLogs().sumFact
        
        if collectedPoints >= collectedPointsToWin {
            achievment3View.image = UIImage(named: "CollectedPointsColor")
            achievment3Title.textColor = .systemBlue.withAlphaComponent(0.75)
            achievment3Label.textColor = .black
            countOfAchievments[2] = 1
        } else {
            achievment3View.image = UIImage(named: "CollectedPointsGray")
            achievment3Title.textColor = .lightGray
            achievment3Label.textColor = .lightGray
            countOfAchievments[2] = 0
        }
    }
    
    private func checkRegimeCompliance() {
        let regimeCompliance = updateRegimeComplianceLabel().forCalculation
        if regimeCompliance > regimeComplianceToWin {
            achievment4View.image = UIImage(named: "RegimeColor")
            achievment4Title.textColor = .systemBlue.withAlphaComponent(0.75)
            achievment4Label.textColor = .black
            countOfAchievments[3] = 1
        } else {
            achievment4View.image = UIImage(named: "RegimeGray")
            achievment4Title.textColor = .lightGray
            achievment4Label.textColor = .lightGray
            countOfAchievments[3] = 0
        }
    }
    
    private func checkCountOfAchievments() {
        
        let sum = countOfAchievments.reduce(0, +)
        
        if sum == 4 {
            achievment5View.image = UIImage(named: "AllAchievmentsColor")
            achievment5Title.textColor = .systemBlue.withAlphaComponent(0.75)
            achievment5Label.textColor = .black
        } else {
            achievment5View.image = UIImage(named: "AllAchievmentsGray")
            achievment5Title.textColor = .lightGray
            achievment5Label.textColor = .lightGray
        }
    }
    
    private func updateAchievmentLabels() {
        achievment1Title.text = "\(activeTasksToWin)"
        achievment2Title.text = "\(completedTasksToWin)"
        achievment3Title.text = "\(collectedPointsToWin)"
        achievment4Title.text = "\(regimeComplianceToWin)%"
        achievment5Title.text = "Все"
    }
    
    // MARK: - SetupUI
    
    private func setupUI() {
        
        view.backgroundColor = .white
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        title = "Мой режим"
        navigationController?.navigationBar.largeTitleTextAttributes = [.foregroundColor: UIColor.black]
        
        batteryTitle.text = "Режим"
        batteryTitle.textAlignment = .center
        batteryTitle.font = UIFont.systemFont(ofSize: 12)
        batteryLabel.text = String(updateRegimeComplianceLabel().forLabel)
        batteryLabel.textAlignment = .center
        batteryLabel.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
        batteryLabel.textColor = .systemBlue.withAlphaComponent(0.75)
        
        activeTasksLabel.text = String(fetchNumbersOfTaskWithSpecialStatus().active)
        activeTasksLabel.textAlignment = .center
        activeTasksLabel.font = UIFont.systemFont(ofSize: 50, weight: .heavy)
        activeTasksLabel.textColor = .systemBlue.withAlphaComponent(0.75)
        activeTasksLabel.adjustsFontSizeToFitWidth = true
        activeTasksTitle.text = "Задачи 🌀"
        activeTasksTitle.textAlignment = .center
        activeTasksTitle.font = UIFont.systemFont(ofSize: 12)
        activeTasksTitle.lineBreakMode = .byWordWrapping
        activeTasksTitle.numberOfLines = 2
        
        completedTasksLabel.text = String(fetchNumbersOfCompletedTaskLogs())
        completedTasksLabel.textAlignment = .center
        completedTasksLabel.font = UIFont.systemFont(ofSize: 50, weight: .heavy)
        completedTasksLabel.textColor = .systemBlue.withAlphaComponent(0.75)
        completedTasksLabel.adjustsFontSizeToFitWidth = true
        completedTasksTitle.text = "Повторений ✔️"
        completedTasksTitle.textAlignment = .center
        completedTasksTitle.font = UIFont.systemFont(ofSize: 12)
        completedTasksTitle.lineBreakMode = .byWordWrapping
        completedTasksTitle.numberOfLines = 2
        
        collectedPointsLabel.text = String(fetchSumFactAndPlanTaskLogs().sumFact)
        collectedPointsLabel.textAlignment = .center
        collectedPointsLabel.font = UIFont.systemFont(ofSize: 50, weight: .heavy)
        collectedPointsLabel.textColor = .systemBlue.withAlphaComponent(0.75)
        collectedPointsLabel.adjustsFontSizeToFitWidth = true
        collectedPointsTitle.text = "Баллов ⭐️"
        collectedPointsTitle.textAlignment = .center
        collectedPointsTitle.font = UIFont.systemFont(ofSize: 12)
        collectedPointsTitle.lineBreakMode = .byWordWrapping
        collectedPointsTitle.numberOfLines = 2
        
        activeTasksToWin = 2
        completedTasksToWin = 10
        collectedPointsToWin = 10
        regimeComplianceToWin = 75
        countOfAchievmentsToWin = 5
        countOfAchievments = [0, 0, 0, 0]
        loadSettingsFromDefaults()
        
        achievment1View = UIImageView(image: UIImage(named: "ActiveTasksGray"))
        achievment2View = UIImageView(image: UIImage(named: "CompletedTasksGray"))
        achievment3View = UIImageView(image: UIImage(named: "CollectedPointsGray"))
        achievment4View = UIImageView(image: UIImage(named: "RegimeGray"))
        achievment5View = UIImageView(image: UIImage(named: "AllAchievmentsGray"))
        achievmentTitle.text = "Достижения 🏆"
        achievmentTitle.textAlignment = .center
        achievmentTitle.font = UIFont.systemFont(ofSize: 12)
        achievmentTitle.lineBreakMode = .byWordWrapping
        achievmentTitle.numberOfLines = 2
        
        achievment1Title.text = "\(activeTasksToWin)"
        achievment2Title.text = "\(completedTasksToWin)"
        achievment3Title.text = "\(collectedPointsToWin)"
        achievment4Title.text = "\(regimeComplianceToWin)%"
        achievment5Title.text = "\(countOfAchievmentsToWin)"
        
        achievment1Title.textColor = UIColor.lightGray
        achievment2Title.textColor = UIColor.lightGray
        achievment3Title.textColor = UIColor.lightGray
        achievment4Title.textColor = UIColor.lightGray
        achievment5Title.textColor = UIColor.lightGray
        achievment1Title.textAlignment = .left
        achievment2Title.textAlignment = .left
        achievment3Title.textAlignment = .left
        achievment4Title.textAlignment = .left
        achievment5Title.textAlignment = .left
        achievment1Title.font = UIFont.systemFont(ofSize: 25, weight: .bold)
        achievment2Title.font = UIFont.systemFont(ofSize: 25, weight: .bold)
        achievment3Title.font = UIFont.systemFont(ofSize: 25, weight: .bold)
        achievment4Title.font = UIFont.systemFont(ofSize: 25, weight: .bold)
        achievment5Title.font = UIFont.systemFont(ofSize: 25, weight: .bold)
        achievment1Label.text = "кол-во активных задач"
        achievment2Label.text = "выполненных повторений"
        achievment3Label.text = "набранных баллов"
        achievment4Label.text = "в режиме"
        achievment5Label.text = "Достижения открыты"
        achievment1Label.adjustsFontSizeToFitWidth = true
        achievment2Label.adjustsFontSizeToFitWidth = true
        achievment3Label.adjustsFontSizeToFitWidth = true
        achievment4Label.adjustsFontSizeToFitWidth = true
        achievment5Label.adjustsFontSizeToFitWidth = true
        achievment1Label.textColor = UIColor.lightGray
        achievment2Label.textColor = UIColor.lightGray
        achievment3Label.textColor = UIColor.lightGray
        achievment4Label.textColor = UIColor.lightGray
        achievment5Label.textColor = UIColor.lightGray
        achievment1Label.textAlignment = .left
        achievment2Label.textAlignment = .left
        achievment3Label.textAlignment = .left
        achievment4Label.textAlignment = .left
        achievment5Label.textAlignment = .left
        achievment1Label.font = UIFont.systemFont(ofSize: 15)
        achievment2Label.font = UIFont.systemFont(ofSize: 15)
        achievment3Label.font = UIFont.systemFont(ofSize: 15)
        achievment4Label.font = UIFont.systemFont(ofSize: 15)
        achievment5Label.font = UIFont.systemFont(ofSize: 15)
        achievment1Label.lineBreakMode = .byWordWrapping
        achievment2Label.lineBreakMode = .byWordWrapping
        achievment3Label.lineBreakMode = .byWordWrapping
        achievment4Label.lineBreakMode = .byWordWrapping
        achievment5Label.lineBreakMode = .byWordWrapping
        achievment1Label.numberOfLines = 2
        achievment2Label.numberOfLines = 2
        achievment3Label.numberOfLines = 2
        achievment4Label.numberOfLines = 2
        achievment5Label.numberOfLines = 2
        let achievmentViews = [achievment1View, achievment2View, achievment3View, achievment4View, achievment5View]
        for a in achievmentViews {
            a.translatesAutoresizingMaskIntoConstraints = false
            a.layer.cornerRadius = 10
            a.layer.masksToBounds = true
            a.layer.shadowColor = UIColor.black.cgColor
            a.layer.shadowOpacity = 0.3 // 0...1
            a.layer.shadowRadius = 4.0  // радиус размытия
            a.layer.shadowOffset = CGSize(width: 5, height: 5)
        }
        
        
        let stacks = [rootStack, upperMainStack, activeTasksStack, midleMainStack, achievmentsStack, batteryStack, batterySubStack1, batterySubStack2, batteryWhiteStack1, batteryWhiteStack2, bottomMainStack, completedTasksStack, collectedPointsStack, upperToMidleMainWhiteStack, middleToBottomMainWhiteStack, whiteStackForMidleMainStack, achievment1Stack, achievment2Stack, achievment3Stack, achievment4Stack, achievment5Stack, achievmentVerSubStack1, achievmentVerSubStack2, achievmentVerSubStack3, achievmentVerSubStack4, achievmentVerSubStack5, whiteStackForActiveTasksStack, whiteStackForCompletedTaskStack, whiteStackForCollectedPointsStack, achievmentVerSecondarySubStack, whiteStackForAchievmentStack, achievmentVerMainSubStack, achievmentVerWhiteStack]
        for s in stacks {
            s.translatesAutoresizingMaskIntoConstraints = false
            s.axis = .vertical
            s.distribution = .fillEqually
            s.spacing = 0
        }
        
        
        upperMainStack.axis = .horizontal
        midleMainStack.axis = .horizontal
        bottomMainStack.axis = .horizontal
        bottomMainRowStack.axis = .horizontal
        achievmentsStack.axis = .horizontal
        achievment1Stack.axis = .horizontal
        achievment2Stack.axis = .horizontal
        achievment3Stack.axis = .horizontal
        achievment4Stack.axis = .horizontal
        achievment5Stack.axis = .horizontal

        achievmentVerMainSubStack.distribution = .fill
        achievmentVerSecondarySubStack.distribution = .fillEqually
        achievmentsStack.distribution = .fill
        achievment1Stack.distribution = .fill
        achievment2Stack.distribution = .fill
        achievment3Stack.distribution = .fill
        achievment4Stack.distribution = .fill
        achievment5Stack.distribution = .fill
        achievmentVerSubStack1.distribution = .fill
        achievmentVerSubStack2.distribution = .fill
        achievmentVerSubStack3.distribution = .fill
        achievmentVerSubStack4.distribution = .fill
        achievmentVerSubStack5.distribution = .fill
        activeTasksStack.distribution = .fill
        completedTasksStack.distribution = .fill
        collectedPointsStack.distribution = .fill
        bottomMainStack.distribution = .fill
        bottomMainRowStack.distribution = .fillEqually
        batteryStack.axis = .horizontal
        batteryStack.distribution = .fill
        batterySubStack2.axis = .horizontal
        batterySubStack2.distribution = .fill
        
        midleMainStack.spacing = 10
        bottomMainRowStack.spacing = 10
        batteryStack.spacing = 0
        achievmentVerSecondarySubStack.spacing = 10
        achievmentsStack.spacing = 5
        
        batterySubStack1.spacing = 0.5
        
        view.addSubview(rootStack)
        rootStack.addArrangedSubview(upperMainStack)
        rootStack.addArrangedSubview(upperToMidleMainWhiteStack)
        rootStack.addArrangedSubview(midleMainStack)
        rootStack.addArrangedSubview(middleToBottomMainWhiteStack)
        rootStack.addArrangedSubview(bottomMainStack)
        
        upperMainStack.addArrangedSubview(activeTasksStack)
        activeTasksStack.addArrangedSubview(whiteStackForActiveTasksStack)
        activeTasksStack.addArrangedSubview(activeTasksTitle)
        activeTasksStack.addArrangedSubview(activeTasksLabel)
        upperMainStack.addArrangedSubview(upperMainWhiteStack1)
        upperMainStack.addArrangedSubview(completedTasksStack)
        completedTasksStack.addArrangedSubview(whiteStackForCompletedTaskStack)
        completedTasksStack.addArrangedSubview(completedTasksTitle)
        completedTasksStack.addArrangedSubview(completedTasksLabel)
        upperMainStack.addArrangedSubview(upperMainWhiteStack2)
        upperMainStack.addArrangedSubview(collectedPointsStack)
        collectedPointsStack.addArrangedSubview(whiteStackForCollectedPointsStack)
        collectedPointsStack.addArrangedSubview(collectedPointsTitle)
        collectedPointsStack.addArrangedSubview(collectedPointsLabel)
        
        midleMainStack.addArrangedSubview(achievmentsStack)
        midleMainStack.addArrangedSubview(whiteStackForMidleMainStack)
        midleMainStack.addArrangedSubview(batteryStack)
        
        achievmentsStack.addArrangedSubview(whiteStackForAchievmentStack)
        achievmentsStack.addArrangedSubview(achievmentVerMainSubStack)
        
        achievmentVerMainSubStack.addArrangedSubview(achievmentTitle)
        achievmentVerMainSubStack.addArrangedSubview(achievmentVerSecondarySubStack)
        achievmentVerMainSubStack.addArrangedSubview(achievmentVerWhiteStack)
        
        achievmentVerSecondarySubStack.addArrangedSubview(achievment1Stack)
        achievmentVerSecondarySubStack.addArrangedSubview(achievment2Stack)
        achievmentVerSecondarySubStack.addArrangedSubview(achievment3Stack)
        achievmentVerSecondarySubStack.addArrangedSubview(achievment4Stack)
        achievmentVerSecondarySubStack.addArrangedSubview(achievment5Stack)
        
        achievment1Stack.addArrangedSubview(achievment1View)
        achievment1Stack.addArrangedSubview(whiteViewForAchievment1Stack)
        achievment1Stack.addArrangedSubview(achievmentVerSubStack1)
        achievmentVerSubStack1.addArrangedSubview(achievment1Title)
        achievmentVerSubStack1.addArrangedSubview(achievment1Label)
        achievment2Stack.addArrangedSubview(achievment2View)
        achievment2Stack.addArrangedSubview(whiteViewForAchievment2Stack)
        achievment2Stack.addArrangedSubview(achievmentVerSubStack2)
        achievmentVerSubStack2.addArrangedSubview(achievment2Title)
        achievmentVerSubStack2.addArrangedSubview(achievment2Label)
        achievment3Stack.addArrangedSubview(achievment3View)
        achievment3Stack.addArrangedSubview(whiteViewForAchievment3Stack)
        achievment3Stack.addArrangedSubview(achievmentVerSubStack3)
        achievmentVerSubStack3.addArrangedSubview(achievment3Title)
        achievmentVerSubStack3.addArrangedSubview(achievment3Label)
        achievment4Stack.addArrangedSubview(achievment4View)
        achievment4Stack.addArrangedSubview(whiteViewForAchievment4Stack)
        achievment4Stack.addArrangedSubview(achievmentVerSubStack4)
        achievmentVerSubStack4.addArrangedSubview(achievment4Title)
        achievmentVerSubStack4.addArrangedSubview(achievment4Label)
        achievment5Stack.addArrangedSubview(achievment5View)
        achievment5Stack.addArrangedSubview(whiteViewForAchievment5Stack)
        achievment5Stack.addArrangedSubview(achievmentVerSubStack5)
        achievmentVerSubStack5.addArrangedSubview(achievment5Title)
        achievmentVerSubStack5.addArrangedSubview(achievment5Label)
    
        batteryStack.addArrangedSubview(batteryWhiteStack1)
        batteryStack.addArrangedSubview(batterySubStack1)
        batteryStack.addArrangedSubview(batteryWhiteStack2)
        
        batterySubStack1.addArrangedSubview(batteryTitle)
        batterySubStack1.addArrangedSubview(batteryLabel)
        batterySubStack1.addArrangedSubview(batterySubStack2)
        
        batterySubStack2.addArrangedSubview(batteryWhiteElement1)
        batterySubStack2.addArrangedSubview(batteryElement1)
        batterySubStack2.addArrangedSubview(batteryWhiteElement2)
        
        let batteryLevels = [batteryLevel1, batteryLevel2, batteryLevel3, batteryLevel4, batteryLevel5, batteryLevel6, batteryLevel7, batteryLevel8, batteryLevel9, batteryLevel10]
        for l in batteryLevels {
            l.backgroundColor = .lightGray
            l.layer.borderColor = UIColor.darkGray.cgColor
            l.layer.borderWidth = 1
            l.layer.cornerRadius = 1
            batterySubStack1.addArrangedSubview(l)
        }
        batterySubStack1.addArrangedSubview(batteryElement2)
        batterySubStack1.addArrangedSubview(batteryWhiteElement3)
        
        bottomMainStack.addArrangedSubview(bottomMainRowStack)
        
        batteryElement1.backgroundColor = .darkGray
        batteryElement2.backgroundColor = .darkGray
      
        activeTasksStack.layer.cornerRadius = 10
        activeTasksStack.layer.borderColor = UIColor.darkGray.cgColor
        activeTasksStack.layer.borderWidth = 0.5
        
        completedTasksStack.backgroundColor = .clear
        completedTasksStack.layer.cornerRadius = 10
        completedTasksStack.layer.borderColor = UIColor.darkGray.cgColor
        completedTasksStack.layer.borderWidth = 0.5
        
        collectedPointsStack.backgroundColor = .clear
        collectedPointsStack.layer.cornerRadius = 10
        collectedPointsStack.layer.borderColor = UIColor.darkGray.cgColor
        collectedPointsStack.layer.borderWidth = 0.5
        
        achievmentsStack.layer.cornerRadius = 10
        achievmentsStack.layer.borderColor = UIColor.darkGray.cgColor
        achievmentsStack.layer.borderWidth = 0.5
        
        let achievmentStacks = [achievment1Stack, achievment2Stack, achievment3Stack, achievment4Stack, achievment5Stack]
        for s in achievmentStacks {
            s.layer.cornerRadius = 10
            s.layer.borderColor = UIColor.darkGray.cgColor
            s.layer.borderWidth = 0.0
        }
        
        batteryStack.backgroundColor = .clear
        batteryStack.layer.cornerRadius = 10
        batteryStack.layer.borderColor = UIColor.darkGray.cgColor
        batteryStack.layer.borderWidth = 0.5
        
//        achievmentVerWhiteStack.backgroundColor = .yellow
//        achievmentVerSecondarySubStack.backgroundColor = .red
//        achievmentTitle.backgroundColor = .blue
        
        bottomMainStack.layer.cornerRadius = 10
        bottomMainStack.layer.cornerRadius = 10
        bottomMainStack.layer.borderColor = UIColor.darkGray.cgColor
        bottomMainStack.layer.borderWidth = 0.5
        
        
        let padding: CGFloat = 10
        
        NSLayoutConstraint.activate([
            rootStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: padding),
            rootStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -padding),
            rootStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: padding),
            rootStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -padding),
            
            
            upperMainStack.heightAnchor.constraint(equalTo: rootStack.heightAnchor, multiplier: 0.14),
            upperToMidleMainWhiteStack.heightAnchor.constraint(equalTo: rootStack.heightAnchor, multiplier: 0.01),
            midleMainStack.heightAnchor.constraint(equalTo: rootStack.heightAnchor, multiplier: 0.55),
            middleToBottomMainWhiteStack.heightAnchor.constraint(equalTo: rootStack.heightAnchor, multiplier: 0.01),
            bottomMainStack.heightAnchor.constraint(equalTo: rootStack.heightAnchor, multiplier: 0.29),
            
            activeTasksStack.widthAnchor.constraint(equalTo: upperMainStack.widthAnchor, multiplier: 0.28),
            upperMainWhiteStack1.widthAnchor.constraint(equalTo: upperMainStack.widthAnchor, multiplier: 0.02),
            completedTasksStack.widthAnchor.constraint(equalTo: upperMainStack.widthAnchor, multiplier: 0.28),
            upperMainWhiteStack2.widthAnchor.constraint(equalTo: upperMainStack.widthAnchor, multiplier: 0.02),
            collectedPointsStack.widthAnchor.constraint(equalTo: upperMainStack.widthAnchor, multiplier: 0.40),
            
            
            
            achievmentsStack.widthAnchor.constraint(equalTo: midleMainStack.widthAnchor, multiplier: 0.68),
            whiteStackForMidleMainStack.widthAnchor.constraint(equalTo: midleMainStack.widthAnchor, multiplier: 0.02),
            batteryStack.widthAnchor.constraint(equalTo: midleMainStack.widthAnchor, multiplier: 0.3),
            
            whiteStackForActiveTasksStack.heightAnchor.constraint(equalTo: activeTasksStack.heightAnchor, multiplier: 0.03),
            whiteStackForCompletedTaskStack.heightAnchor.constraint(equalTo: completedTasksStack.heightAnchor, multiplier: 0.03),
            whiteStackForCollectedPointsStack.heightAnchor.constraint(equalTo: collectedPointsStack.heightAnchor, multiplier: 0.03),
            
            
            achievmentTitle.heightAnchor.constraint(equalTo: achievmentVerMainSubStack.heightAnchor, multiplier: 0.07),
            achievmentVerSecondarySubStack.heightAnchor.constraint(equalTo: achievmentVerMainSubStack.heightAnchor, multiplier: 0.90),
            achievmentVerWhiteStack.heightAnchor.constraint(equalTo: achievmentVerMainSubStack.heightAnchor, multiplier: 0.03),
            
//            achievmentTitle.centerYAnchor.constraint(equalTo: achievmentVerMainSubStack.centerYAnchor),
            
            whiteStackForAchievmentStack.widthAnchor.constraint(equalTo: achievmentsStack.widthAnchor, multiplier: 0.01),
            
            
            batteryElement1.widthAnchor.constraint(equalTo: batterySubStack2.widthAnchor, multiplier: 0.4),
            batteryWhiteElement1.widthAnchor.constraint(equalTo: batterySubStack2.widthAnchor, multiplier: 0.3),
            batteryWhiteElement2.widthAnchor.constraint(equalTo: batterySubStack2.widthAnchor, multiplier: 0.3),
            
            batterySubStack1.widthAnchor.constraint(equalTo: batteryStack.widthAnchor, multiplier: 0.90),
            batteryWhiteStack1.widthAnchor.constraint(equalTo: batteryStack.widthAnchor, multiplier: 0.05),
            batteryWhiteStack2.widthAnchor.constraint(equalTo: batteryStack.widthAnchor, multiplier: 0.05),
            

            achievment1View.widthAnchor.constraint(equalTo: achievment1Stack.widthAnchor, multiplier: 0.2),
            achievment2View.widthAnchor.constraint(equalTo: achievment2Stack.widthAnchor, multiplier: 0.2),
            achievment3View.widthAnchor.constraint(equalTo: achievment3Stack.widthAnchor, multiplier: 0.2),
            achievment4View.widthAnchor.constraint(equalTo: achievment4Stack.widthAnchor, multiplier: 0.2),
            achievment5View.widthAnchor.constraint(equalTo: achievment4Stack.widthAnchor, multiplier: 0.2),
            
            whiteViewForAchievment1Stack.widthAnchor.constraint(equalTo: achievment1Stack.widthAnchor, multiplier: 0.02),
            whiteViewForAchievment2Stack.widthAnchor.constraint(equalTo: achievment2Stack.widthAnchor, multiplier: 0.02),
            whiteViewForAchievment3Stack.widthAnchor.constraint(equalTo: achievment3Stack.widthAnchor, multiplier: 0.02),
            whiteViewForAchievment4Stack.widthAnchor.constraint(equalTo: achievment4Stack.widthAnchor, multiplier: 0.02),
            whiteViewForAchievment5Stack.widthAnchor.constraint(equalTo: achievment5Stack.widthAnchor, multiplier: 0.02),
            
            achievment1Title.heightAnchor.constraint(equalTo: achievmentVerSubStack1.heightAnchor, multiplier: 0.7),
            achievment2Title.heightAnchor.constraint(equalTo: achievmentVerSubStack2.heightAnchor, multiplier: 0.7),
            achievment3Title.heightAnchor.constraint(equalTo: achievmentVerSubStack3.heightAnchor, multiplier: 0.7),
            achievment4Title.heightAnchor.constraint(equalTo: achievmentVerSubStack4.heightAnchor, multiplier: 0.7),
            achievment5Title.heightAnchor.constraint(equalTo: achievmentVerSubStack5.heightAnchor, multiplier: 0.7),
            
            achievment1Label.heightAnchor.constraint(equalTo: achievmentVerSubStack1.heightAnchor, multiplier: 0.3),
            achievment2Label.heightAnchor.constraint(equalTo: achievmentVerSubStack2.heightAnchor, multiplier: 0.3),
            achievment3Label.heightAnchor.constraint(equalTo: achievmentVerSubStack3.heightAnchor, multiplier: 0.3),
            achievment4Label.heightAnchor.constraint(equalTo: achievmentVerSubStack4.heightAnchor, multiplier: 0.3),
            achievment5Label.heightAnchor.constraint(equalTo: achievmentVerSubStack5.heightAnchor, multiplier: 0.3),

            
        ])
        
    }
    
}
