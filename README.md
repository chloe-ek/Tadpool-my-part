## 📱 TadPool – A Real-World Dating App for Safe, Verified Connections

TadPool is a mobile dating and networking app built to solve common online dating problems — ghosting, fake profiles, and unsafe meetups — by focusing on **verified, location-based matches** that encourage **real-life connections**.

<p align="center">
  <img src="https://github.com/user-attachments/assets/945ee114-4393-497e-8e7e-e24fbd4417b1" alt="TadPool Logo" width="360" />
</p>


---

## 🚀 Project Overview

- 🗓️ **Timeline:** 4-week sprint (April 28 – May 21, 2025)  
- 👥 **Team:** 5 developers for BCIT's COMP 3800 Capstone  
- 🧠 **Scope:** Inherited and refactored a legacy codebase from multiple past teams  
- 📂 **This Repo:** Contains **only the files I personally worked on**, extracted from the private team repo

---

## ✨ Key Features (Team-wide)

- 🧠 **Facial Verification with AWS Rekognition**  
  Users verify their identity by taking a selfie after creating the profile.

- 🗺️ **Real-Time Map Integration**  
  Track user location and enable proximity-based match invites.

- 🔔 **In-App Notification System**  
  All interactions (date invites, responses) are handled through custom push notifications.


---

## 🛠 Tech Stack

- **Frontend:** Flutter  
- **Backend:** Django + PostgreSQL  
- **Cloud Services:** AWS S3, AWS Rekognition, Firebase Cloud Messaging  
- **DevOps:** Docker, EC2, GitHub, Jira

---

## 👩‍💻 My Contributions

I worked across both the frontend and backend, focusing on:

- 📸 Building the full image upload flow: from Flutter → Django API → AWS S3
- 🧠 Integrating AWS Rekognition for selfie-based facial verification
- 🐳 Dockerizing the backend and deploying services to EC2 via Docker Compose
- 🔑 Refactoring Django’s auth system to support email login with a custom `EmailBackend`
- 🧼 Modernizing legacy code by upgrading dependencies and reorganizing the structure

---

## 🖼️ Screenshots

### 🔐 Login & Onboarding
<p>
  <img src="./screenshots/intro.png" width="160" style="vertical-align: top; margin-right:10px;" />
  <img src="./screenshots/login.png" width="160" style="vertical-align: top;" />
</p>

### 🧠 Facial Verification
<p>
  <img src="./screenshots/rekognition.png" width="160" style="vertical-align: top; margin-right:10px;" />
  <img src="./screenshots/verified.png" width="160" style="vertical-align: top; margin-right:10px;" />
  <img src="./screenshots/verified_user.png" width="160" style="vertical-align: top;" />
</p>

### 🤝 Matching Flow
<p>
  <img src="./screenshots/discover.png" width="160" style="vertical-align: top; margin-right:10px;" />
  <img src="./screenshots/personal.png" width="160" style="vertical-align: top; margin-right:10px;" />
  <img src="./screenshots/map_matching.png" width="160" style="vertical-align: top;" />
</p>

### 📍 Map Features
<p>
  <img src="./screenshots/map.png" width="160" style="vertical-align: top; margin-right:10px;" />
  <img src="./screenshots/livemap.png" width="160" style="vertical-align: top;" />
</p>

---

## 🔧 Codw Showcase**

> This repository highlights the core components and APIs I developed. The complete application includes additional team-contributed features and requires private API keys for full functionality.

---

## 💡 Repository Purpose**

This repository demonstrates my specific contributions to our team's capstone project, showcasing the image upload pipeline, facial verification system, and deployment infrastructure I designed and implemented.

---

## 📝 Project Contect**

Developed as part of BCIT's COMP 3800 capstone course. This showcase highlights my individual contributions to our collaborative team project.

---
