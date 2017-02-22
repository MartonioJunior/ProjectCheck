//
//  CriarProvaViewController.swift
//  ProjectCheck
//
//  Created by IFCE on 13/02/17.
//  Copyright © 2017 Bepid. All rights reserved.
//

import UIKit
import CoreData

class CriarProvaViewController: UIViewController, UITextFieldDelegate, RetornarRespostas {
    
    @IBOutlet weak var nomeProvaField: UITextField!
    @IBOutlet weak var nOpcoesLabel: UILabel!
    @IBOutlet weak var nOpcoes: UIStepper!
    @IBOutlet weak var nQuestoesField: UITextField!
    @IBOutlet weak var criarProvaButton: UIButton!
    
    var container: NSPersistentContainer!
    
    var respostas: [String:String] = [:]
    
    func sendAnswersBack(_ answers: [String : String]) {
        respostas = answers
    }
    
    func resetAnswers() {
        respostas = [:]
    }
    
    func validateProva() -> Bool {
        if (nomeProvaField.text?.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty)! || nomeProvaField.text == nil {
            sendAlert(title: "Nome da Prova Vazio", message: "O campo 'Nome' é obrigatório!")
            return false
        }
        
        let provaID = nomeProvaField.text!
        
        let request: NSFetchRequest<Gabarito> = Gabarito.fetchRequest()
        request.predicate = NSPredicate(format: "idProva == %@", "P"+provaID)
        let results = try! container.viewContext.fetch(request)
        
        if results.count != 0 {
            sendAlert(title: "Nome da Prova Já Existente", message: "Por favor, escolha outro nome!")
            return false
        }
        
        guard let nQuestoes = Int(nQuestoesField.text!) else {
            sendAlert(title: "Número de questões Vazio", message: "O campo 'Quantidade de Questões' é obrigatório!")
            return false
        }
        
        if respostas.count == 0 {
            sendAlert(title: "Gabarito não preenchido", message: "Por favor, preencha o gabarito depois de escolher o número de opções e de questões!")
            return false
        }
        else if respostas.count != nQuestoes {
            sendAlert(title: "Gabarito Incompleto", message: "Por favor, preencha todo o gabarito!")
            return false
        }
        
        return true
    }
    
    func sendAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default) { action in
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func salvarProva(_ sender: UIButton) {
        if validateProva() == false {
            return
        }
        
        print(respostas)
        
        var BD: [Gabarito] = []
        
        for key in respostas.keys {
            let item: Gabarito = NSEntityDescription.insertNewObject(forEntityName: "Gabarito", into: container.viewContext) as! Gabarito
            
            item.idProva = "P"+nomeProvaField.text!
            item.questao = NSDecimalNumber(string: key)
            item.alternativa = respostas[key]
            BD.append(item)
        }
        
        try! container.viewContext.save()
        
        let request: NSFetchRequest<Gabarito> = Gabarito.fetchRequest()
        let results = try? container.viewContext.fetch(request)
        print("---")
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelarAcao(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func confirmNumQuestions(_ sender: UIButton) {
        nQuestoesField.resignFirstResponder()
    }
    
    @IBAction func changeNumOptions(_ sender: UIStepper) {
        resetAnswers()
        nOpcoesLabel.text = "\(Int(nOpcoes.value))"
    }
    
    @IBAction func changeNumQuestions(_ sender: UITextField) {
        resetAnswers()
        guard let nQuestions = Int(nQuestoesField.text!) else {
            nQuestoesField.text = ""
            return
        }
        
        if nQuestions > 180 {
            nQuestoesField.text = "180"
        } else if nQuestions < 1 {
            nQuestoesField.text = "1"
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nomeProvaField.delegate = self
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        container = appDelegate.persistentContainer
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Preencher" {
            let destino = segue.destination as! PreencherGabaritoViewController
            destino.respostas = respostas
            destino.nOpcoes = Int(nOpcoes.value)
            destino.nQuestoes = Int(nQuestoesField.text!) ?? 0
            destino.mDelegate = self
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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
