//
//  HomeView.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 17/09/25.
//

import SwiftUI

struct AnalyticsView: View {
    var body: some View {
        Text("Analytics screen")
    }
}

//#Preview {
//    AnalyticsView()
//}

import SwiftUI
import SwiftData

// 1️⃣ SwiftData Task Model
@available(iOS 17, *)
@Model
class Task11: Identifiable {
    @Attribute(.unique) var id: UUID = UUID()
    var name: String
    var date: Date
    
    init(name: String, date: Date) {
        self.name = name
        self.date = date
    }
}

// 2️⃣ HomeView with FAB, Tabs, and Task List
@available(iOS 17.0, *)
struct HomeView11: View {
    @Environment(\.modelContext) private var context
//    @Query private var tasks: [Task11]
    @State private var tasks: [Task11]?
    
    @State private var selectedTab: Tab = .present
    @State private var showAddTask: Bool = false
    @State private var toastMessage: String = ""
    @State private var showToast: Bool = false
    @State private var refreshTrigger: Bool = false // triggers UI refresh
    
    enum Tab: String, CaseIterable {
        case past = "Past"
        case present = "Present"
        case future = "Future"
        
        var cardColor: Color {
            switch self {
            case .past: return Color.blue.opacity(0.7)
            case .present: return Color.green.opacity(0.7)
            case .future: return Color.pink.opacity(0.7)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.7)]),
                               startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                
                VStack {
                    // Segmented Tab Picker
                    Picker("Select Tab", selection: $selectedTab) {
                        ForEach(Tab.allCases, id: \.self) { tab in
                            Text(tab.rawValue)
                                .font(.headline)
                                .foregroundColor(selectedTab == tab ? .white : .white.opacity(0.7))
                                .tag(tab)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(12)
                    .tint(Color.orange)
                    
                    // Task List
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(filteredTasks()) { task in
                                TaskCardView(task: task, color: selectedTab.cardColor)
                            }
                        }
                        .padding()
                        .id(refreshTrigger) // <-- force refresh when new task is added
                    }
                    
                    Spacer()
                }
                .padding()
                .navigationBarBackButtonHidden(true)
                .navigationTitle("Home")
                .onAppear {
                    printAllTasks() // Print all tasks on Home appear
                }
                
                // Floating Action Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: { showAddTask = true }) {
                            Image(systemName: "plus")
                                .foregroundColor(.white)
                                .font(.title)
                                .padding()
                                .background(Color.orange)
                                .clipShape(Circle())
                                .shadow(radius: 5)
                        }
                    }
                    .padding()
                }
                
                // Toast
                if showToast {
                    VStack {
                        Spacer()
                        Text(toastMessage)
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.bottom, 50)
                    }
                    .transition(.move(edge: .bottom))
                }
            }
            // Add Task Sheet
            .sheet(isPresented: $showAddTask) {
                AddTaskView { name, date in
                    addTask(name: name, date: date)
                    showAddTask = false
                } onCancel: {
                    showAddTask = false
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .closeAllBottomSheets)) { _ in
                showAddTask = false
            }
        }
    }
    
    // Filter tasks based on tab selection
    private func filteredTasks() -> [Task11] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        switch selectedTab {
        case .past:
            return tasks?.filter { calendar.startOfDay(for: $0.date) < today }
                .sorted { $0.date > $1.date } ?? [Task11(name: "", date: Date())]
        case .present:
            return tasks?.filter { calendar.isDate($0.date, inSameDayAs: today) } ?? [Task11(name: "", date: Date())]
        case .future:
            return tasks?.filter { calendar.startOfDay(for: $0.date) > today }
                .sorted { $0.date < $1.date } ?? [Task11(name: "", date: Date())]
        }
    }
    
    // Add Task with validation
    private func addTask(name: String, date: Date) {
        if name.trimmingCharacters(in: .whitespaces).isEmpty {
            showToastMessage("Task name cannot be empty ❌")
            return
        }
        
        let newTask = Task11(name: name, date: date)
        context.insert(newTask)
        do {
            try context.save()
            showToastMessage("Task created successfully 🎉")
            print("✅ New Task Inserted: \(newTask.name) - \(newTask.date)")
//            tasks.append(newTask)
            tasks?.append(Task11(name: name, date: date))
            printAllTasks()
            refreshTrigger.toggle()
        } catch {
            showToastMessage("Failed to save task ❌")
            print("❌ Error saving task: \(error)")
        }
    }
    
    // Print all tasks for debugging
//    private func printAllTasks() {
//        print("📋 All Tasks in SwiftData:")
//        for task in tasks {
//            print("- \(task.name) | \(task.date)")
//        }
//    }
    private func printAllTasks() {
        print("📋 All Tasks in SwiftData:")
        if let tasks = tasks {   // safely unwrap
            for task in tasks {
                print("- \(task.name) | \(task.date)")
            }
        } else {
            print("No tasks available")
        }
    }

    
    // Toast helper
    private func showToastMessage(_ message: String) {
        toastMessage = message
        withAnimation { showToast = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation { showToast = false }
        }
    }
}

// 3️⃣ Task Card View
@available(iOS 17, *)
struct TaskCardView: View {
    let task: Task11
    let color: Color
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(task.name)
                    .font(.headline.bold())
                    .foregroundColor(.white)
                Text(task.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
            Spacer()
        }
        .padding()
        .background(color)
        .cornerRadius(12)
        .shadow(radius: 3)
    }
}

// 4️⃣ Add Task Sheet
struct AddTaskView: View {
    @State private var taskName: String = ""
    @State private var taskDate: Date = Date()
    
    var onSubmit: (_ name: String, _ date: Date) -> Void
    var onCancel: () -> Void
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                TextField("Task Name", text: $taskName)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                
                DatePicker("Select Date", selection: $taskDate, displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                
                HStack(spacing: 20) {
                    Button("Cancel") { onCancel() }
                        .foregroundColor(.red).bold()
                    
                    Button("Submit") { onSubmit(taskName, taskDate) }
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(8)
                        .bold()
                }
                Spacer()
            }
            .padding()
            .navigationTitle("Add Task")
        }
    }
}

//// 5️⃣ Preview
//#Preview {
//    if #available(iOS 17.0, *) {
//        HomeView11()
//            .modelContainer(for: Task11.self)
//    } else {
//        // Fallback on earlier versions
//    }
//}
