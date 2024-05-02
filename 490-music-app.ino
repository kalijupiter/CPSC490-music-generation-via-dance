#include "I2Cdev.h"
#include <WiFi.h>
#include <WiFiUdp.h>
#include <Adafruit_MPU6050.h>
#include <Adafruit_Sensor.h>
#include <Wire.h>
#include <AsyncTCP.h>
#include <ESPAsyncWebServer.h>
#include <WebSerial.h>

//offsets to be applied to gyroscope readings. these can and should be replaced based on the needs of the individual MPU6050
#define offsetX 0.07
#define offsetY -0.01
#define offsetZ 0.02

/*
  Rui Santos
  Complete project details at https://RandomNerdTutorials.com/esp32-i2c-communication-arduino-ide/
  
  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files.
  
  The above copyright notice and this permission notice shall be included in all
  copies or substantial portions of the Software.
*/
#define I2C_SDA 32
#define I2C_SCL 33

TwoWire I2CMPU = TwoWire(0);

/*
  Rui Santos
  Complete project details at https://RandomNerdTutorials.com/esp32-webserial-library/
  
  This sketch is based on the WebSerial library example: ESP32_Demo
  https://github.com/ayushsharma82/WebSerial
*/
AsyncWebServer server(80);

// WiFi network name and password:
const char * networkName = "yale wireless";
const char * networkPswd = "";

//IP address to send UDP data to:
// either use the ip address of the server or 
// a network broadcast address
const char * udpAddress = "172.29.33.198";
const int udpPort = 8092;

//Are we currently connected?
boolean connected = false;

//The udp library class
WiFiUDP udp;

// class default I2C address is 0x68
// specific I2C addresses may be passed as a parameter here
// AD0 low = 0x68 (default for InvenSense evaluation board)
// AD0 high = 0x69
Adafruit_MPU6050 accelgyro;


void setup() {
  // Initilize hardware serial:
  Serial.begin(115200);
  while (!Serial)
    delay(10); // will pause Zero, Leonardo, etc until serial console opens

  //Connect to the WiFi network
  connectToWiFi(networkName, networkPswd);

  // join I2C bus (I2Cdev library doesn't do this automatically)
  I2CMPU.begin(I2C_SDA, I2C_SCL, 100000);
  
  bool status;
  status = accelgyro.begin(0x68, &I2CMPU);

  if (!status) {
    Serial.println("Could not find a valid MPU6050 sensor, check wiring!");
    while (1);
  }
  
  WebSerial.begin(&server);
  server.begin();

  Serial.println("IP Address: " + WiFi.localIP().toString());
}

void loop() {
  
    sensors_event_t a, g, temp;
    accelgyro.getEvent(&a, &g, &temp);

    String msg = String(g.gyro.x + offsetX);
    msg += " " + String(g.gyro.y + offsetY);
    msg += " " + String(g.gyro.z + offsetZ);

    //only send data when connected
  if(connected){
      //Send a packet
      udp.beginPacket(udpAddress,udpPort);
      udp.print(msg); 
      udp.endPacket();
      WebSerial.println(msg);
      Serial.println(msg);
  }

  //Wait for .1 seconds
  delay(100);
}

void connectToWiFi(const char * ssid, const char * pwd){
  Serial.println("Connecting to WiFi network: " + String(ssid));

  // delete old config
  WiFi.disconnect(true);
  //register event handler
  WiFi.onEvent(WiFiEvent);

  WiFi.mode(WIFI_STA);

  //Initiate connection
  WiFi.begin(ssid, pwd);

  Serial.println("Waiting for WIFI connection...");
}

//wifi event handler
void WiFiEvent(WiFiEvent_t event){
    switch(event) {
      case SYSTEM_EVENT_STA_GOT_IP:
          //When connected set 
          Serial.print("WiFi connected! IP address: ");
          Serial.println(WiFi.localIP());  
          //initializes the UDP state
          //This initializes the transfer buffer
          udp.begin(WiFi.localIP(),udpPort);
          connected = true;
          break;
      case SYSTEM_EVENT_STA_DISCONNECTED:
          Serial.println("WiFi lost connection");
          connected = false;
          break;
    }
}


