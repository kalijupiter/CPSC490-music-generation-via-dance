# Music Generation Via Dance
The following file explains how to run the application. The application uses the following platforms and programming languages: Arduino, Python, Wekinator, and SuperCollider.

### Step 0: Setup
The following materials are needed for minimal functionality:
1. ESP32 board
2. MPU 6050 sensor
3. jumper wires
4. USB chord

Instructions for setting up the hardwar can be found here: https://randomnerdtutorials.com/esp32-mpu-6050-accelerometer-gyroscope-arduino/. **Important**: for this application, the following connections should be made instead of the defaults described in the tutorial: SCL -- GPIO33, SDA -- GPIO32.

Additionally, the following applications need to be installed if they have not been already:
1. Arduino IDE: https://www.arduino.cc/en/software
2. Python: https://www.python.org/downloads/
3. Wekinator: http://www.wekinator.org/downloads/
4. SuperCollider: https://supercollider.github.io/downloads.html

Lastly, the following libraries need to be installed if they have not been already:
1. Installed with Arduino Library Manager: Adafruit MPU6050, WebSerial.h
2. The following tutorial includes instructions for installing ESPAsyncWebServer.h and AsyncTCP.h: https://randomnerdtutorials.com/esp32-webserial-library/
3. For Python, oscpy: `pip install oscpy`

Some files need to be updated with user specifications before running:
1. **490-music-app.ino**: Enter the current WiFi network + password, IP address + port. The offsets also might need to be updated to fit the current sensor. These can be found by running the sketch as is, observing the outputs when the sensor is at rest, and updating the offsets as necessary so that the outputs are 0.0. Also make sure that the `I2C_SDA` and `I2C_SCL` variables reflect the pins being used.
2. **490-music-app.py**: Enter the IP address + port; these should be the same as the ones specefied in 490-music-app.ino.

### Step 1: Data Retrieval
Once the .ino file is updated as necessary, upload the sketch to the ESP32 board. Visit the WebSerial to make sure data is beng read from the sensor. Also run the .py file, which will recieve the data from .ino, clean it, and send it to Wekinator.

### Step 2: Wekinator
There is a default Wekinator project uploaded to this repo, trained on up, down, left, and right movements. The user can also run their own Wekinator project. To do so follow these instructions:
1. Open a new project. Make sure the listening port is 6448. In the inputs section, change '# of inputs' to 3. In the outputs section, change 'Port' to 57120, 'Type' to all dynamic time warping, and 'gesture types' to 4. These specifications ensure that the project will receive messages from Python and send them to SuperCollider. Press next.
2. The next page is allows you to train the model. Detailed instructions on how to record movements can be found here: http://www.wekinator.org/detailed-instructions/#Dynamic_time_warping_in_Wekinator. For the application to work well, it is recommended that the movements are distinct and relatively simple.

### Step 3: SuperCollider
Before running the .scd code, the .sc file needs to be saved as an Extension file. See the instructions at the top of this file for further details. Once this is set up, run each section of the scd file by placing the cursor somewhere within the parenthesized block and pressing CMD + Return. The program is now listening for OSC messages from Wekinator. Using the sensor, perform the different movements that Wekinator was trained to recognize, and listen as the music starts and evolves!

### Areas for Further Creativity
1. Changing the recognized movements in Wekinator
2. Changing the SynthDefs and/or PBinds in SuperCollider. This will change the sound of the music that is played.
3. Changing the ordered pairs of movements that control each music variation in the MoveClasses.
