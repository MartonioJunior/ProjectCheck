//
//  VerProvaViewController.swift
//  ProjectCheck
//
//  Created by IFCE on 22/02/17.
//  Copyright © 2017 Bepid. All rights reserved.
//

import UIKit
import CoreData

class VerProvaViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var provas: UITableView!
    var container: NSPersistentContainer!
    
    var listaProvas: [String: Int] = [:]
    var provaSelecionada: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        provas.delegate = self
        provas.dataSource = self

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        listaProvas.removeAll()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        container = appDelegate.persistentContainer
        
        let results = try! container.viewContext.fetch(Gabarito.fetchRequest()) as! [Gabarito]
        
        var nomeProvas: [String] = []
        
        for item in results {
            if let ID = item.idProva {
                nomeProvas.append(ID)
            }
        }
        
        for prova in nomeProvas {
            listaProvas[prova] = (listaProvas[prova] ?? 0) + 1
        }
        
        self.provas.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "VerMais" {
            let destino = segue.destination as! ProvaInfoViewController
            destino.prova = self.provaSelecionada
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listaProvas.keys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = provas.dequeueReusableCell(withIdentifier: "Prova", for: indexPath)
        
        let prova = listaProvas.keys.sorted()[indexPath.row]
        
        cell.textLabel?.text = prova
        cell.detailTextLabel?.text = "\(listaProvas[prova] ?? 0) questões"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let prova = listaProvas.keys.sorted()[indexPath.row]
            listaProvas.removeValue(forKey: prova)
            deletar(prova: prova)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        provaSelecionada = listaProvas.keys.sorted()[indexPath.row]
        performSegue(withIdentifier: "VerMais", sender: nil)
    }
    
    func deletar(prova: String) {
        let request: NSFetchRequest<Gabarito> = Gabarito.fetchRequest()
        request.predicate = NSPredicate(format: "idProva == %@", prova)
        let results = try! container.viewContext.fetch(request) 
        for item in results {
            container.viewContext.delete(item)
        }
        try! container.viewContext.save()
    }
    
    @IBAction func returnToMainMenu(_ sender: UIBarButtonItem) {
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
