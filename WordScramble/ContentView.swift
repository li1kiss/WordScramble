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
    
    @State private var point = 0
    var body: some View {
        NavigationStack{
            List{
                Section{
                    TextField("Enter your word", text: $newWord)
                        .textInputAutocapitalization(.never)
                }
                Section("Point"){
                    Text("\(point)")
                }
                
                Section{
                    ForEach(usedWord, id: \.self){word in
                        HStack{
                            Image(systemName: word == rootWord ? "\(word.count).circle" : "checkmark.circle")
                            Text(word)
                        }
                    }
                }
            }
            .navigationTitle(rootWord)
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
            .toolbar{
                Button("Restart", action: addrootword)
            }
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
        
        guard isSame(word: answer) else{
            wordError(title: "Oh", message: "Its the same word, try samething else")
            return
        }
        
        withAnimation{
            usedWord.insert(answer, at: 0)
        }
            newWord = ""
        addthescore(word: answer)
    }
    
    func startGame(){
        if let wordsInLink = Bundle.main.url(forResource: "start", withExtension: "txt"){
            if let startWords = try? String(contentsOf: wordsInLink){
                let allStartWords = startWords.components(separatedBy: "\n")
                rootWord = allStartWords.randomElement() ?? "bruh"
                rootWordItem = WordItem(word: rootWord, icon: "checkmark.circle")
                
                if showingrootword == true{
                    if let previousRootWordItem = previousRootWordItem {
                        withAnimation {
                            usedWords.insert(previousRootWordItem, at: 0)
                        }
                    }
                }
                previousRootWordItem = rootWordItem
                showingrootword = true
                
                
                return
            }
        }
        
        fatalError("Could not install start.txt file")
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
    
    func isSame(word: String) -> Bool{
        
        if word.count < 3 || word == rootWord {
                return false
            }
        return true
    }
    
    func addthescore(word: String){
        if word.count > 7 {
            point += 50
        }
        else if word.count < 7 && word.count >= 5{
            point += 30
        }
        else {
            point += 10
        }
        
    }
}
    

#Preview {
    ContentView()
}
