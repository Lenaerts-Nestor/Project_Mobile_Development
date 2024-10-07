# ParkFlow

**ParkFlow** is een Flutter-app waarmee gebruikers parkeerplekken kunnen reserveren, bekijken, verlengen of annuleren. Gebruikers kunnen ook hun voertuig selecteren uit een lijst van automerken. Dit project maakt gebruik van **Flutter** en **Firebase** voor gebruikersauthenticatie, database-opslag en locatiegebaseerde functies.

## Features

* **Parkingspot Reserveren**: Gebruikers kunnen eenvoudig een parkeerplek reserveren en beheren.
* **Auto Kiezen**: Selecteer je voertuig uit een lijst van populaire automerken.
* **Parkingspot Wijzigen**: Verleng of annuleer een bestaande reservering.
* **Realtime Locatie**: Beschikbare parkeerplekken in jouw omgeving worden weergegeven op een kaart.
* **Firebase-integratie**: Gebruikersauthenticatie en databaseopslag via Firebase.

## Updates en Bugs

Vanwege recente **Android-updates** en wijzigingen in de **Geolocator**-package kunnen er bugs optreden met de locatiefunctionaliteit. Deze bugs worden momenteel aangepakt.

## Installatiehandleiding

Volg deze stappen om het project te installeren en uit te voeren:

### 1. Vereisten

Zorg ervoor dat je de volgende software hebt geïnstalleerd:
* Flutter SDK
* Android Studio of Visual Studio Code
* Firebase account

### 2. Project Klonen

Clone het project naar je lokale machine:

```bash
git clone https://github.com/Lenaerts-Nestor/ParkFlow.git
cd ParkFlow
```

### 3. Firebase Configuratie

1. Maak een Firebase-project aan in de Firebase Console.
2. Voeg een Android-app toe aan je Firebase-project.
3. Download het **google-services.json**-bestand en plaats dit in de map `android/app/` van je Flutter-project.
4. Schakel Firebase Authentication en Cloud Firestore in via de Firebase Console.

### 4. Packages Installeren

Installeer de benodigde dependencies:

```bash
flutter pub get
```

### 5. Android Instellingen

Voeg de volgende permissies toe aan het bestand `android/app/src/main/AndroidManifest.xml` voor locatiefunctionaliteit:

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.INTERNET" />
```

### 6. Project Bouwen en Uitvoeren

Start de app op een emulator of fysiek apparaat:

```bash
flutter run
```

### 7. Firebase Emulators (Optioneel)

Voor lokaal testen met Firebase Emulators:
1. Start de emulators:

```bash
firebase emulators:start
```

2. Pas de Firebase-configuratie aan om verbinding te maken met de emulator in plaats van de live-database.

## Gebruikte Technologieën

* **Flutter** voor de frontend en mobiele ontwikkeling.
* **Firebase** voor authenticatie en database.
* **Geolocator** voor locatiebepaling.
* **Flutter Map** voor het tonen van kaarten en locaties.
* **Provider** voor state management.
* **RxDart** voor reactief programmeren.

## Problemen en Verbeteringen

Er kunnen bugs optreden door recente Android-updates en wijzigingen in de **Geolocator**-package. Dit probleem wordt momenteel onderzocht en een oplossing is onderweg.
