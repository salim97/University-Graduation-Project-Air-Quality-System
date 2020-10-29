# University-Graduation-Project-Air-Quality-System
University Graduation Project Air Quality System
this is a contributed air quality system made in algeria from people to people, inspired from other ready to use solution
- https://cityair.io/
- https://kiel.maps.sensor.community/

# Short Screenshot Preview
[![Alt text](https://img.youtube.com/vi/wNRK7oKOohI/0.jpg)](https://www.youtube.com/watch?v=wNRK7oKOohI)

# Contents
 - [How it works](#how-it-works)
   - [Device](#device)
   - [Backend](#backend)
   - [Frontend](#frontend)

# How It Works
- once device is configured in user environement, the device will send data periodically to backend
- backend will store data recieved from devices and provide a way to secure writing data into database using user authentication using SMS OTP
- frontend will display data stored in backend for mobile ( Android / IOS ) and Web 
![](/Doc/project_overview.png)

## Device
we managed to create two devices one based on ESP8266 for low cost, and other based on ESP32 for maximum features
- [ESP32](https://github.com/salim97/University-Graduation-Project-Air-Quality-System/tree/master/ESP32%20Air%20Quality)
- [ESP8266](https://github.com/salim97/University-Graduation-Project-Air-Quality-System/tree/master/ESP8266%20Air%20Quality)

## Backend
we chosse firebase for [free plan offer](https://firebase.google.com/pricing), and since it's a serverless approach that mean it's durable and flexible
- [Firebase](https://github.com/salim97/University-Graduation-Project-Air-Quality-System/tree/master/Firebase)

## Frontend
we chosse flutter for cross platfrom user expirance mobile and web
- [Flutter App](https://github.com/salim97/University-Graduation-Project-Air-Quality-System/tree/master/Front-End%20Application/air_quality_system)


# Copyright © 2018-2019

[Benabadji Mohammed Salim](https://github.com/salim97)

[Amine Houari](https://github.com/AmineHouari98)
