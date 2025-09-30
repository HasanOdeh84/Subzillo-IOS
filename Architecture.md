## MVVM Architecture

The **MVVM (Model-View-ViewModel)** architecture is a design pattern used in mobile app development to promote separation of concerns and facilitate easier management of application code.  
It separates the data layer (**Model**), the presentation layer (**View**), and the business or presentation logic (**ViewModel**). This results in more **maintainable, testable, and scalable code**.

---

### 1. Core Components

- **Model**:  
  Represents simple data and contains no business logic. It is essentially the plain structure of data expected from an API.

- **View**:  
  The UI layer that the user sees and interacts with. Its only job is to display data and forward user actions to the ViewModel. It contains **no business logic**.

- **ViewModel**:  
  Connects the Model and the View. It exposes data from the Model in a format that the View can display, handles UI logic (e.g., formatting data, handling user input), and is **independent of the View**, making it reusable.

---

### 2. How it Works

The communication flow in MVVM is based on **data binding** or **reactive programming**:

1. **User Interaction**: A user taps a button on the View.  
2. **Action to ViewModel**: The View informs the ViewModel about the action (e.g., "login button tapped").  
3. **ViewModel Logic**: The ViewModel handles the action, possibly calling the Model to fetch data or perform calculations.  
4. **Model Update**: The Model updates its data.  
5. **ViewModel Notified**: The ViewModel is notified of the Model's change.  
6. **ViewModel Prepares Data**: Updates its properties with the new data.  
7. **View is Notified**: Via data binding, the View observes changes in the ViewModel's data.  
8. **View Updates UI**: The View updates its UI to reflect the new data.

---

### 3. Communication and Data Flow

- **View → ViewModel**: User actions are sent from the View to the ViewModel.  
- **ViewModel → Model**: The ViewModel requests data or commands from the Model.  
- **Model → ViewModel**: The Model sends updated data back to the ViewModel.  
- **ViewModel → View**: The ViewModel exposes data for the View to consume (data binding).

---

### MVVM Interaction Diagram

![unnamed (1)](https://github.com/user-attachments/assets/8fc56025-33be-4256-b75d-60d7bf4347c1)
