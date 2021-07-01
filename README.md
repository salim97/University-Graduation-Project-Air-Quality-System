# University-Graduation-Project-Air-Quality-System

A contributed air quality system deployed in algeria, inspired from other ready to use solutions.
- https://cityair.io/
- https://kiel.maps.sensor.community/

# Showcase video
[![Alt text](https://img.youtube.com/vi/wNRK7oKOohI/0.jpg)](https://www.youtube.com/watch?v=wNRK7oKOohI)

# User Applications
[Link to Web Application](https://pfe-air-quality.firebaseapp.com/)

[Link to Android Mobile Application](https://drive.google.com/file/d/1Tg73RzL-FEw4-oOlm1jPUTIAzaZBC5hw/view?usp=sharing) 


## Android Mobile Application Screenshot

| Home View| Home Menu | Home Guide | Home Drawer Menu |
|--|--|--|--|
| ![home view](Screenshots/home_page_temperature.jpg) | ![home menu view](Screenshots/home_page_temperature.jpg) | ![home menu view](Screenshots/home_page_guide.jpg) |![home menu view](Screenshots/home_page_drawer.jpg) |


| Phone Auth | Device location | Sync data from mobile to Air Quality Device | 
|--|--|--|
| ![Phone Auth](Screenshots/phone_auth.jpg) | ![Device location](Screenshots/device_location_GPS.jpg) | ![Sync data from mobile to Air Quality Device](Screenshots/esp-touch.jpg) |


| Weather Forecast  | Weather details |  
|--|--|
| ![ Weather Forecast ](Screenshots/home_page_weather.jpg) | ![ Weather details ](Screenshots/home_page_weather_details.jpg) | 

## Android Mobile Application Screenshot

| Web Version  |
|--|
| ![ Weather Forecast ](Screenshots/home_page_web.png) | 



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


# Copyright © 2019-2021

[Benabadji Mohammed Salim](https://github.com/salim97)

[Amine Houari](https://github.com/AmineHouari98)

<a href="https://www.buymeacoffee.com/salimbenabadji" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" style="height: 60px !important;width: 217px !important;" ></a>

