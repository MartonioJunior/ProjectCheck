//
//  ProvaInfoViewController.swift
//  ProjectCheck
//
//  Created by IFCE on 22/02/17.
//  Copyright © 2017 Bepid. All rights reserved.
//

import UIKit
import CoreData

class ProvaInfoViewController: UIViewController {
    
    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var gabaritoLabel: UITextView!
    
    var prova: String = ""
    var container: NSPersistentContainer!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        container = appDelegate.persistentContainer
        
        let request: NSFetchRequest<Gabarito> = Gabarito.fetchRequest()
        request.predicate = NSPredicate(format: "idProva == %@", prova)
        
        var results = try! container.viewContext.fetch(request)
        results = results.sorted {Int($0.questao!) < Int($1.questao!)}
        
        var log: String = "Questão\tAlternativa\n"
        
        for item in results {
            log += "\(item.questao!)   \t\t\t\(item.alternativa!)\n"
        }
        
        gabaritoLabel.text = makeLog(texto: log)
        navBar.title = prova
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func returnToVerProvas(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    func makeLog(texto: String) -> String {
        var log = ""
        for linha in texto.components(separatedBy: "\n") {
            log += linha+"\n"
        }
        return log
    }

}
