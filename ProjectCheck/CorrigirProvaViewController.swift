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
    @IBOutlet weak var gabaritoLabel: UITextView!
    
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
        
        //print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
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
        var identified: Bool = false
        let results: NSFastEnumeration = info[ZBarReaderControllerResults] as! NSFastEnumeration
        
        //print(results)
        
        for symbol in results as! ZBarSymbolSet {
            let symbolFound = symbol as? ZBarSymbol
            if let data = symbolFound?.data {
                valuesFound.append(data)
                identified = data.hasPrefix("P")
            }
        }
        
        checkForRepeats(onList: &valuesFound)
        print(valuesFound)
        
        if (identified) {
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
            
            var results = try container.viewContext.fetch(request) as [Gabarito]
            results = results.sorted {Int($0.questao!) < Int($1.questao!)}
            
            print(results)
            for questao in results {
                if let q = questao.questao, let a = questao.alternativa {
                    respostas.append("\(a),\(q)")
                }
            }
            checkForRepeats(onList: &respostas)
        } catch {
            print(error)
        }
    }
    
    func checkAnswers() -> Int {
        gabaritoLabel.text = ""
        
        var respostasCertas = 0
        var log = ""
        var respostasQuestao: [String:Int] = [:]
        
        for opcao in valuesFound {
            let questao = opcao.components(separatedBy: ",")[1]
            respostasQuestao[questao] = (respostasQuestao[questao] ?? 0) + 1
        }
        
        for opcao in respostas {
            let questao = opcao.components(separatedBy: ",")[1]
            if !valuesFound.contains(opcao) || respostasQuestao[questao]! > 1 {
                log += questao+"\t\t\t\tErrado\n"
            } else {
                //print("{\(respostasCertas)} -> {\(respostasCertas + 1)}")
                respostasCertas += 1
                log += questao+"\t\t\t\tCerto\n"
            }
        }
        
        print(respostasQuestao)
        
        log = makeLog(texto: log)
        gabaritoLabel.text = log
        
        return respostasCertas
        
    }
    
    func makeLog(texto: String) -> String {
        let linhas = texto.components(separatedBy: "\n")
        var log = "Questão\tAlternativa\n"
        for linha in linhas {
            log += linha+"\n"
        }
        return log
    }
    
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
