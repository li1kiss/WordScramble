//
//  ContentView.swift
//  WordScramble
//
//  Created by Mykhailo Kravchuk on 04/04/2024.
//

import SwiftUI

struct ContentView: View {
    @State private var newWord = ""
    @State private var rootWord = ""
    @State private var usedWord = [String]()
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    var body: some View {
        NavigationStack{
            List{
                Section{
                    TextField("Enter your word", text: $newWord)
                        .textInputAutocapitalization(.never)
                }
                Section{
                    ForEach(usedWord, id: \.self){word in
                        HStack{
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                }
            }
            .navigationTitle(rootWord)
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $showingError){ } message:{
                Text(errorMessage)
            }
        }
    }
    
    func addNewWord(){
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard answer.count > 0 else {return}
        
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original!")
            return
        }
        
        guard isPosible(word: answer) else {
            wordError(title: "Word not possible", message: "Please write true word, spell that word from \(rootWord)")
            return
        }
        
        guard isReal(word: answer) else{
            wordError(title: "What is that word", message: "You can't just make them uo, you know!")
            return
        }
        
        
        withAnimation{
            usedWord.insert(answer, at: 0)
        }
            newWord = ""
    }
    
    func startGame(){
        if let wordsInLink = Bundle.main.url(forResource: "start", withExtension: "txt"){
            if let startWords = try? String(contentsOf: wordsInLink){
                let allStartWords = startWords.components(separatedBy: "\n")
                rootWord = allStartWords.randomElement() ?? "bruh"
                return
            }
        }
        
        fatalError("Could net instal start.txt file")
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWord.contains(word)
    }
    
    func  isPosible(word: String) -> Bool{
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter){
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
    return true
    }
    
    
    func isReal(word: String) -> Bool{
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        
        let misspelleRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelleRange.location == NSNotFound
    }
    
    func wordError(title: String, message:String){
        errorTitle = title
        errorMessage = message
        showingError = true
    }
}
    

#Preview {
    ContentView()
}