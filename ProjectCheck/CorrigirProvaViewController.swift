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

class CorrigirProvaViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var questoesLabel: UILabel!
    @IBOutlet weak var gabaritoLabel: UITextView!
    @IBOutlet weak var provaSelector: UIPickerView!
    
    var nCorretas: Int = 0
    var provaSelecionada = ""
    
    var provas: [String] = []
    var respostas: [String] = []
    var valuesFound: [String] = []
    
    var reader = UIImagePickerController()
    var container: NSPersistentContainer!

    override func viewDidLoad() {
        super.viewDidLoad()
        reader.delegate = self
        reader.allowsEditing = false
        reader.sourceType = UIImagePickerControllerSourceType.savedPhotosAlbum
        
        provaSelector.delegate = self
        provaSelector.dataSource = self
        
        //print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        container = appDelegate.persistentContainer
        
        let results = try! container.viewContext.fetch(Gabarito.fetchRequest()) as! [Gabarito]
        
        for item in results {
            if let ID = item.idProva {
                provas.append(ID)
            }
        }
        
        checkForRepeats(onList: &provas)
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
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return provas.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return provas[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        provaSelecionada = provas[row]
    }
    
    func imagePickerController(_ reader: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        let data = image.getPixelData()
        let alternativas = ["A","B","C","D","E","F"]
        var answerData:[[String]] = Array.init()
        
        for array in data {
            var log: [String] = []
            var brightness = CGFloat()
            var alpha = CGFloat()
            for element in array {
                element.getWhite(&brightness, alpha: &alpha)
                
                if brightness >= 0.8 {
                    log.append("X")
                } else if brightness <= 0.3 {
                    log.append("O")
                } else {
                    log.append(" ")
                }
            }
            answerData.append(log)
            print(" \(log)\n")
        }
        
        var x = 0
        var y = 0
        
        for column in answerData {
            y = 0
            for line in column {
                if line == "O", x%7 != 0 {
                    self.valuesFound.append("\(alternativas[(x%7)-1]),\(y+1)")
                }
                y += 1
            }
            x += 1
        }
        
        if x != 14 || y != 48 {
            reader.dismiss(animated: true, completion: nil)
        }
        
        print("\(x) colunas x \(y) linhas")
        
        checkForRepeats(onList: &valuesFound)
        print(valuesFound)
        
        buscarRespostas(prova: provaSelecionada)
        nCorretas = checkAnswers()
        questoesLabel.text = "Questões Corretas \(nCorretas)/\(respostas.count)"
        reader.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        reader.dismiss(animated: true, completion: nil)
    }
    
    func buscarRespostas(prova: String) {
        let request: NSFetchRequest = Gabarito.fetchRequest()
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

extension UIImage {
    
    func getPixelData() -> [[UIColor]] {
        let pixelData = self.cgImage!.dataProvider!.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        // formato 3:4 largura:altura
        
        var colorMatrix: [[UIColor]] = Array.init()
        
        for x in (0..<Int(self.size.width)) where x % 110 == 55 { // .jpg x % 175 == 87
            var colorLine: [UIColor] = Array.init()
            
            for y in (0..<Int(self.size.height)) where y % 43 == 21 { // .jpg % 68 == 34
                let pixelInfo: Int = ((Int(self.size.width) * Int(y)) + Int(x)) * 4
                
                let r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
                let g = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
                let b = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
                let a = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)
                
                colorLine.append(UIColor(red: r, green: g, blue: b, alpha: a))
            }
            
            colorMatrix.append(colorLine)
        }
        
        return colorMatrix
    }
}
