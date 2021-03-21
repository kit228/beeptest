//
//  TalkPageViewController.swift
//  beep test
//
//  Created by Вениамин Китченко on 22/07/2018.
//  Copyright © 2018 Вениамин Китченко. All rights reserved.
//

import UIKit
import Speech // импортируем speechframework
import AudioToolbox // импортируем библиотеку для вибро
import AVFoundation // импорт для "пика"


class TalkPageViewController: UIViewController, SFSpeechRecognizerDelegate { // добавили SFSpeechRecognizerDelegate
    
    var isPaused: Bool? // индикатор паузы - НИКАК НЕ ИСПОЛЬЗОВАЛ
    
    @IBOutlet weak var recognizerLabel: UILabel! // лэйбл вывода распознанного текста
    
    let audioEngine: AVAudioEngine? = AVAudioEngine() // will process audio streamю This will process the audio stream. It will give updates when the mic is receiving audio
    let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer(locale: Locale.init(identifier: "ru-RU"))// speech recoginzer в русской локализации
    //let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ru-RU"))!
    let request = SFSpeechAudioBufferRecognitionRequest() // This allocates speech as the user speaks in real-time and controls the buffering
    var recognitionTask: SFSpeechRecognitionTask? //This will be used to manage, cancel, or stop the current recognition task.
    
    
    
    func recordAndRecognizeSpeech() {
        guard let node = audioEngine?.inputNode else {
            return
        }
        let recordingFormat = node.outputFormat(forBus: 0)
        node.removeTap(onBus: 0) // удаляет Tap до создания нового
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer,_ in
            self.request.append(buffer)
        }
        audioEngine?.prepare() //prepare and start recording using the auudio engine
        do {
            try audioEngine?.start()
        } catch {
            return print(error)
        }
        
        guard let myRecogniaer = SFSpeechRecognizer() else { // дополнительные проверки доступноси рекогнайзера для устройства и локали
            // a recognize is not suported for this current locale
            return
        }
        if !myRecogniaer.isAvailable {
            // a recognize is not avaiable fo right now
        }
        
        recognitionTask = speechRecognizer?.recognitionTask(with: request, resultHandler: {result, error in
            if let result = result {
                let bestString = result.bestTranscription.formattedString //.lowercased() // с помощью lowercased() делаем все символы строчными
                self.recognizerLabel.text = "..." + bestString + "..."  // выводим в лэйбл распозанный текст
                print("**ЗАПРОС**")
                var lastString: String = ""
                for segment in result.bestTranscription.segments { //makes a loop to analyze each new segment/result string
                    let indexTo = bestString.index(bestString.startIndex, offsetBy: segment.substringRange.location) //makes a substring range that is everything up until beginning of the last spoken word
                    lastString = bestString.substring(from: indexTo) //makes a substring that is from that index to the end of the result
                    print("**-второй запрос--**")
                    }
                
                //self.checkForBadWord(badWord: lastString) // проверка на "плохое" слово
                self.checkBad(recWord: lastString, from: self.badWords) // обновленная проверка на плохое слово
                
                } else if let error = error {
                print(error)
            }
        })
        
    }
    
    //let systemPeek: SystemSoundID = 1016
    var BeepAudioPlayer: AVAudioPlayer?
    func playBeep(for nameOfFile: String, type: String) {
        guard let putKFailu = Bundle.main.path(forResource: nameOfFile, ofType: type) else {return}  // Prevent a crash in the event that the resource or type is invalid
        let beepZvuk = URL(fileURLWithPath: putKFailu) //// Convert path to URL for audio player
        do {
            BeepAudioPlayer = try AVAudioPlayer(contentsOf: beepZvuk)
            BeepAudioPlayer?.prepareToPlay()
            BeepAudioPlayer?.play()
        } catch {
            assert(false, error.localizedDescription) // // Create an assertion crash in the event that the app fails to play the sound
        }
    }
    
    var tempBad: String = ""
    
    func checkBad(recWord: String, from badMassiv: [String]) { //функция, выполняющая проверку слова с массивом плохих слов
        
        guard tempBad == recWord.lowercased() else { // защита от черезмерных сообщений на одно и то же слово)
            for badMassiv in badMassiv {
                if badMassiv == recWord.lowercased() {
                    tempBad = recWord.lowercased()
                    print ("tempbad-", tempBad)
                    print("Плохое слово:", recWord)
                    //AudioServicesPlaySystemSound(systemPeek)
                    playBeep(for: "beep-24", type: "mp3")
                    }
                    }
        return }
    }
    
    func stopSpeechRecognition() { // функция стоп-записи
        //let node = audioEngine?.outputNode
        if (audioEngine?.isRunning)! {
            audioEngine?.stop()
            request.endAudio()
            recognitionTask?.cancel()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //startTimer() //включаем таймер
        NotificationCenter.default.addObserver(self, selector: #selector(GoToPause), name:NSNotification.Name.UIApplicationDidEnterBackground, object: nil) // добавляем observer listening, чтобы узнать когда приложение уходит в background
        isPaused = false
    }
    
    override func viewWillAppear(_ animated: Bool) { // вызывает UI контроллера каждый раз, когда появляется на экране
        startTimer() //включаем таймер
        recordAndRecognizeSpeech() //  записываем и распознаем текст
        UIApplication.shared.isIdleTimerDisabled = true // запрещаем гасить экран
        isPaused = false // после вызова UI контроллера снимаем индикатор паузы
    }
    
    @objc func GoToPause(notification : NSNotification) { // внутри этой функции вызывается все, что нужно, когда приложение переходит в background через observer listener
        print("Переход в экран паузы при выходе в background")
        pauseTimer() // таймер на паузу
        self.performSegue(withIdentifier: "PauseSegue", sender: nil) // переход на экран паузы через сегвей PauseSegue
        isPaused = true // в паузе
        stopSpeechRecognition()
        
    }
    
    @IBAction func PauseButton(_ sender: UIButton) { // нажатие на кнопку "пауза"
        print("Переход на экран паузы после нажатия кнопки Пауза")
        pauseTimer() // таймер на паузу
        UIApplication.shared.isIdleTimerDisabled = false // разрешаем гасить экран
        stopSpeechRecognition()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { // передаем время в PauseViewController
        if segue.identifier == "PauseSegue" {
            if let toPause = segue.destination as? PausePageViewController {
                toPause.storageTimeValue = timeString(timeForUI: TimeInterval(timerCounter))
            }
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //начинаем работу с таймером
    @IBOutlet weak var TimerLabel: UILabel! // поле таймера
    var timerCounter = 0
    var timer = Timer()
    
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer() {
        timerCounter = timerCounter + 1
        TimerLabel.text = timeString(timeForUI: TimeInterval(timerCounter))
        //TimerLabel?.text = String(timerCounter)
    }
    
    func timeString(timeForUI: TimeInterval) -> String {
        let minutes = Int(timeForUI) / 60 % 60
        let seconds = Int(timeForUI) % 60
        if seconds == 58 { // в эти секунды мы рестартуем запись
            stopSpeechRecognition()
        } else if seconds == 59 {
            recordAndRecognizeSpeech()
        }
        return String(format:"%02d : %02d", minutes, seconds)
    }
    
    func pauseTimer() {
        timer.invalidate()
    }
    
    let badWords: [String] = [ // массив плохих слов
    "привет", // для теста используем "хорошее" слово как плохое
    "жопа",
    "дурак",
    "чо",
    "че",
    "мудак",
    "пидор",
    "хуй",
    "нахуй",
    "похуй",
    "пизда",
    "пизду",
    "уебок",
    "шлюха"
    ]
    
    /*func checkForBadWord(badWord: String) {
        switch badWord {
        case "че":
            AudioServicesPlaySystemSound(1519)
        case "привет":
            print("Плохое слово:", badWord)
        
        default: break
        }
    }*/

}
