//
//  PreemcherGabaritoViewController.swift
//  ProjectCheck
//
//  Created by IFCE on 16/02/17.
//  Copyright © 2017 Bepid. All rights reserved.
//

import UIKit
import CoreData

class PreencherGabaritoCell: UITableViewCell {
    @IBOutlet weak var nQuestaoLabel: UILabel!
    @IBOutlet weak var respostaControl: UISegmentedControl!
    
    var id: Int = -1
    
    @IBAction func selectedOption(_ sender: UISegmentedControl) {
        PreencherGabaritoViewController.controleRespostas[id] = respostaControl.selectedSegmentIndex
    }
}

protocol RetornarRespostas: class {
    func sendAnswersBack(_ answers: [String:String])
}

class PreencherGabaritoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var gabarito: UITableView!
    weak var mDelegate: RetornarRespostas?
    
    var respostas: [String:String] = [:]
    var nOpcoes: Int = 4
    var nQuestoes: Int = 0
    static var controleRespostas = [Int]()
    
    let alternativas = ["A","B","C","D","E","F"]

    override func viewDidLoad() {
        super.viewDidLoad()
        gabarito.delegate = self
        gabarito.dataSource = self
        gabarito.allowsSelection = false
        
        PreencherGabaritoViewController.controleRespostas = Array.init(repeating: -1, count: nQuestoes)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.gabarito.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nQuestoes
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PreencherGabaritoCell
        
        cell.id = indexPath.row
        cell.nQuestaoLabel.text = "\(cell.id+1)"
        cell.respostaControl.removeAllSegments()
        
        for opcoes in alternativas[0..<nOpcoes].reversed() {
            cell.respostaControl.insertSegment(withTitle: opcoes, at: 0, animated: true)
        }
        
        if let marcada = respostas["\(cell.id+1)"] {
            cell.respostaControl.selectedSegmentIndex = alternativas.index(of: marcada)!
        } else {
            cell.respostaControl.selectedSegmentIndex = PreencherGabaritoViewController.controleRespostas[cell.id]
        }
        
        return cell
    }
    
    
    @IBAction func returnToCriarProva(_ sender: UIBarButtonItem) {
        var count = 0
        
        while count < nQuestoes {
            if PreencherGabaritoViewController.controleRespostas[count] != -1 {
                respostas[String.init(format: "%d", count+1)] = alternativas[PreencherGabaritoViewController.controleRespostas[count]]
            }
            
            count += 1
        }
        
//        for cell in getAllCells() as! [PreencherGabaritoCell] {
//            if cell.respostaControl.selectedSegmentIndex == -1 {
//                continue
//            }
//            guard let opcao = cell.respostaControl.titleForSegment(at: cell.respostaControl.selectedSegmentIndex) else {
//                return
//            }
//            let questao = cell.nQuestaoLabel.text! as String
//            respostas[questao] = opcao
//        }
        
        mDelegate?.sendAnswersBack(respostas)
        
        dismiss(animated: true, completion: nil)
    }
    
    func getAllCells() -> [UITableViewCell] {
        
        var cells = [UITableViewCell]()
        // assuming tableView is your self.tableView defined somewhere
        for i in 0...gabarito.numberOfSections-1 {
            if gabarito.numberOfRows(inSection: i) == 0 {
                break
            }
            for j in 0...gabarito.numberOfRows(inSection: i)-1 {
                if let cell = gabarito.cellForRow(at: IndexPath(row: j, section: i)) {
                    cells.append(cell)
                }
            }
        }
        return cells
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
