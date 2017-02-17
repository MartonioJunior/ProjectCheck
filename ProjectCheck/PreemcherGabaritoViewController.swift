//
//  PreemcherGabaritoViewController.swift
//  ProjectCheck
//
//  Created by IFCE on 16/02/17.
//  Copyright © 2017 Bepid. All rights reserved.
//

import UIKit

class PreencherGabaritoCell: UITableViewCell {
    @IBOutlet weak var nQuestaoLabel: UILabel!
    @IBOutlet weak var respostaControl: UISegmentedControl!
}

class PreencherGabaritoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var gabarito: UITableView!
    
    var respostas: [String] = []
    var nOpcoes: Int = 0
    var nQuestoes: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        gabarito.delegate = self
        gabarito.dataSource = self
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
        
        cell.nQuestaoLabel.text = "\(indexPath.row+1)"
        
        cell.respostaControl.removeAllSegments()
        
        let alternativas = ["A","B","C","D","E","F"]
        
        for opcoes in alternativas[0..<nOpcoes].reversed() {
            cell.respostaControl.insertSegment(withTitle: opcoes, at: 0, animated: true)
        }
        
        return cell
    }
    
    @IBAction func returnToCriarProva(_ sender: UIBarButtonItem) {
        for cell in gabarito.visibleCells as! [PreencherGabaritoCell] {
            let opcao = cell.respostaControl.titleForSegment(at: cell.respostaControl.selectedSegmentIndex)! as String
            let questao = cell.nQuestaoLabel.text! as String
            respostas.append("\(opcao),\(questao)")
        }
        print(respostas)
        self.dismiss(animated: true, completion: nil)
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
