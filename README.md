## Simple E-commerce App  

This is a simple e-commerce app built with Flutter, using an API developed with Node.js, Express, and MySQL. It is deployed on Google Cloud for product management, including viewing and uploading products.  
It lets you browse products, add them to a cart, and complete purchases. 
It works on phones and the web, using BLoC for state management.  
## Screenshots
![image](https://github.com/user-attachments/assets/4d845244-e0d3-48c0-86a2-34c71baf8af8)

## Features  
- Browse products with search and filters  
- View product details  
- Add items to your cart  
- Buy products at checkout  
- Upload new products  
- Switch between light and dark mode  

## Prerequisites  
- Install Flutter from [flutter.dev](https://flutter.dev)  
- Create a `.env` file in the root folder (use `.env.example` as a template)  

## Setup  
1. Clone this project  
2. Run `flutter pub get` to install dependencies  
3. Add `API_BASE_URL` to your `.env` file (point it to your server)  

## Running the App  
- **For phone**: Connect your device and run `flutter run`  
- **For web**: Run `flutter run -d chrome`  

## Project Structure  
- `lib/main.dart`: App starting point  
- `lib/models/`: Data files (e.g., Customer, Product)  
- `lib/repositories/`: Server data handling  
- `lib/widgets/`: Reusable UI components and screens  
- `lib/services/`: Tools like storage and location  
- `lib/common/`: Shared utilities and enums  

**Note**:  
- BLoC manages state. Cubits are in feature folders or `lib/`.  
- Navigation uses named routes in `lib/routes.dart`.  

## Building for Web  
1. Run `flutter build web`  
2. Find files in `build/web`  
3. Deploy them to a web server  

## More images dark mode
![image](https://github.com/user-attachments/assets/ede30a9e-8224-48ed-b003-d531df3be30b)

## Medium Screen
![image](https://github.com/user-attachments/assets/9e6cce7c-acd6-4b34-b1d8-14261cf2f81b)

## Large Screen
![image](https://github.com/user-attachments/assets/d3478f20-010e-47dc-84d7-38b682d21917)


