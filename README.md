# 🚗 O’TO – Garage Mobile & Services Auto à Domicile

Application mobile et web permettant aux clients d’accéder à des services automobiles **à distance**, fournis par des mécaniciens professionnels en Afrique de l’Ouest.

---

## 📱 À propos du projet

**O’TO** est une application qui simplifie l’entretien automobile grâce à :

* La **demande de services auto à domicile**
* La **prise en charge du véhicule** (diagnostic, entretien, dépannage, lavage…)
* La **gestion des prestataires** (garagistes/mécanos)
* Un système de **devis, abonnements et paiements**
* Un **suivi en temps réel** grâce à la géolocalisation
* Une **interface moderne** développée en Flutter et connectée à Firebase

---

## ✨ Fonctionnalités principales

### 👤 Côté Client

* Inscription / Connexion (Firebase Auth)
* Gestion du profil
* Ajout et suivi du véhicule
* Demande de prestation (entretien, dépannage, lavage, diagnostic…)
* Paiement sécurisé (intégration prévue : FedaPay)
* Suivi de l’état du service demandé

### 🔧 Côté Mécano

* Interface séparée selon le rôle de l’utilisateur
* Réception des demandes de service
* Mise à jour du statut des prestations
* Gestion du planning
* Création d’un document *véhicule* automatique après inscription du client

### 🗺 Fonctionnalités techniques

* Géolocalisation du client & du prestataire
* Notification automatique via Cloud Functions
* Système de rôles (mécano / client)
* Architecture Firebase (Auth + Firestore + Storage)
* Application Mobile Flutter (Android / iOS)

---

## 📸 Aperçu (Screenshots)

*(À compléter quand tu seras prêt)*

---

## 🏗 Architecture du projet

```
O'TO/
├── lib/
│   ├── main.dart
│   ├── screens/
│   │   ├── accueil/
│   │   ├── prestations/
│   │   ├── vehicule/
│   │   ├── compte/
│   │   └── contact/
│   ├── services/
│   ├── models/
│   └── widgets/
├── assets/
├── firebase/
└── README.md
```

---

## 🛠 Technologies utilisées

| Technologie                    | Usage                                              |
| ------------------------------ | -------------------------------------------------- |
| **Flutter 3+**                 | App mobile multiplateforme                         |
| **Firebase Auth**              | Authentification & gestion des rôles               |
| **Cloud Firestore**            | Base de données                                    |
| **Firebase Storage**           | Images & documents                                 |
| **Cloud Functions**            | Automatisations (emails, documents, notifications) |
| **Google Maps API**            | Géolocalisation                                    |
| **FedaPay / PayTech** (option) | Paiement en ligne                                  |

---

## 🚀 Installation & Configuration

1. **Cloner le projet**

```bash
git clone https://github.com/USERNAME/oto-app.git
cd oto-app
```

2. **Installer les dépendances**

```bash
flutter pub get
```

3. **Ajouter Firebase**

* Suivre la procédure : [https://firebase.google.com/docs/flutter/setup](https://firebase.google.com/docs/flutter/setup)

4. **Lancer l'application**

```bash
flutter run
```

---

## 🧪 À venir

* 🔜 Tableau de bord web admin
* 🔜 Système de fidélité
* 🔜 Paiement in-app
* 🔜 Chat en temps réel client ⇄ mécano
* 🔜 Optimisation UI/UX

---

## 👤 Auteur

**Yoann Yamd**
Développeur Mobile & Web — Flutter | Laravel | Firebase
📧 [yoannyamd@gmail.com](mailto:yoannyamd@gmail.com)

---

## Contribution

Les contributions sont les bienvenues ! Si tu veux contribuer :

1. Fork le dépôt
2. Crée une branche : `git checkout -b feature/ma-fonctionnalite`
3. Commit tes modifications : `git commit -m "Ajout: ma fonctionnalité"`
4. Push sur ta branche : `git push origin feature/ma-fonctionnalite`
5. Ouvre une Pull Request
