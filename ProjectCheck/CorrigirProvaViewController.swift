//
//  CorrigirProvaViewController.swift
//  ProjectCheck
//
//  Created by IFCE on 13/02/17.
//  Copyright © 2017 Bepid. All rights reserved.
//

import UIKit
import ZBarSDK
import CoreData

class CorrigirProvaViewController: UIViewController, ZBarReaderDelegate {
    
    @IBOutlet weak var provaLabel: UILabel!
    @IBOutlet weak var questoesLabel: UILabel!
    @IBOutlet weak var gabaritoLabel: UILabel!
    
    var nCorretas: Int = 0
    
    var respostas: [String] = []
    var valuesFound: [String] = []
    
    var reader = ZBarReaderViewController()
    var container: NSPersistentContainer!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        reader.readerDelegate = self
        reader.scanner.setSymbology(ZBAR_QRCODE, config: ZBAR_CFG_ENABLE, to: 1)
        reader.readerView.zoom = 1.0
        //reader.showsZBarControls = false
        reader.sourceType = UIImagePickerControllerSourceType.camera
        
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        container = appDelegate.persistentContainer
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CorrigirProva" {
            let destino = segue.destination as! CriarProvaViewController
            destino.container = self.container
        }
    }
    
    @IBAction func corrigirProva(_ sender: UIButton) {
        present(reader, animated: true, completion: nil)
    }
    
    func imagePickerController(_ reader: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let results: NSFastEnumeration = info[ZBarReaderControllerResults] as! NSFastEnumeration
        
        //print(results)
        
        for symbol in results as! ZBarSymbolSet {
            let symbolFound = symbol as? ZBarSymbol
            if let data = symbolFound?.data {
                valuesFound.append(data)
            }
        }
        
        checkForRepeats(onList: &valuesFound)
        print(valuesFound)
        
        if (valuesFound.contains("P9001")) {
            let prova = valuesFound.removeLast()
            provaLabel.text = prova
            buscarRespostas(prova: prova)
            nCorretas = checkAnswers()
            questoesLabel.text = "Questões Corretas \(nCorretas)/\(respostas.count)"
            reader.dismiss(animated: true, completion: nil)
        }
    }
    
    func buscarRespostas(prova: String) {
        let request: NSFetchRequest = Gabarito
        .fetchRequest()
        request.predicate = NSPredicate(format: "idProva == %@", prova)
        do {
            
            let results = try container.viewContext.fetch(request) as [Gabarito]
            
            print(results)
            for questao in results {
                if let q = questao.questao, let a = questao.alternativa {
                    respostas.append("\(a),\(q)")
                }
            }
        } catch {
            print(error)
        }
    }
    
//    func compareAnswers() -> Int {
//        var respostasCertas = 0
//        let mapa1 = mapSquares(fromList: valuesFound, isAnswer: false)
//        let mapa2 = mapSquares(fromList: respostas, isAnswer: true)
//        print(mapa1)
//        print(mapa2)
//        
//        for gabarito in mapa2 {
//            for resposta in mapa1 {
//                respostasCertas += resposta == gabarito ? 1 : 0
//                break
//            }
//        }
//        
//        return respostasCertas
//    }
    
    func checkAnswers() -> Int {
        gabaritoLabel.text = ""
        var respostasCertas = respostas.count
        var log = ""
        
        for opcao in respostas {
            let questao = opcao.components(separatedBy: ",")[1]
            if valuesFound.contains(opcao) {
                print("{\(respostasCertas)} -> {\(respostasCertas - 1)}")
                respostasCertas -= 1
                log += questao+"\tErrado\n"
            } else {
                log += questao+"\tCerto\n"
            }
        }
        
        gabaritoLabel.numberOfLines = respostas.count + 1
        gabaritoLabel.text = log
        
        return respostasCertas
        
    }
    
//    func mapSquares(fromList list: [String], isAnswer: Bool) -> [[Bool]] {
//        var prova: String = "-"
//        
//        var mapa: [[Bool]] = Array(repeating: [isAnswer, isAnswer, isAnswer], count: 4)
//        
//        for valueFound in valuesFound {
//            if valueFound.hasPrefix("P") {
//                prova = valueFound
//                continue
//            } else {
//                guard let questao = Int(valueFound.components(separatedBy: ",")[1]) else {
//                    continue
//                }
//                
//                if valueFound.hasPrefix("A,") {
//                    mapa[questao-1][0] = isAnswer == true
//                }
//                    
//                else if valueFound.hasPrefix("B,") {
//                    mapa[questao-1][1] = isAnswer == true
//                }
//                    
//                else if valueFound.hasPrefix("C,") {
//                    mapa[questao-1][2] = isAnswer == true
//                }
//                
//                else if valueFound.hasPrefix("D,") {
//                    mapa[questao-1][3] = isAnswer == true
//                }
//                    
//                else if valueFound.hasPrefix("E,") {
//                    mapa[questao-1][4] = isAnswer == true
//                }
//            }
//        }
//        
//        provaLabel.text = prova
//        return mapa
//    }
    
    @IBAction func cancelarOperacao(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func checkForRepeats(onList list: inout [String]) {
        var checkedList: [String] = []
        for element in list {
            if checkedList.contains(element) == false {
                checkedList.append(element)
            }
        }
        list = checkedList
    }
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ZBarSymbolSet: Sequence {
    public func makeIterator() -> NSFastEnumerationIterator {
        return NSFastEnumerationIterator(self)
    }
}
