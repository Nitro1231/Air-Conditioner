#include <SoftwareSerial.h>

const int button = A3;
const int potentiometer = A2;
const int fan1 = 5; // D5
const int fan2 = 6; // D6
const int outLM35 = A0; // Up
const int inLM35 = A1; // Down
const int btTX = 3; // D3, HC-06(RX)
const int btRX = 2; // D2, HC-06(TX)
const int maxDiff = 10; // Max diff value btw in and out temp.
const int fanSpeedOffset = 20; // Limitation on fan speed.

int autoFanMode = LOW;
int buttonState;
int lastButtonState = LOW;
unsigned long lastDebounceTime = 0;
unsigned long debounceDelay = 50; 

SoftwareSerial BTSerial(btRX, btTX); // Somehow switched each other on my board.
// HC-06 RX -> Nano TX (D3)
// HC-06 TX -> Nano RX (D2)

void setup() {
  Serial.begin(9600);
  BTSerial.begin(9600);
  pinMode(button, INPUT);
  pinMode(potentiometer, INPUT);
  pinMode(outLM35, INPUT);
  pinMode(inLM35, INPUT);
  pinMode(fan1, OUTPUT);
  pinMode(fan2, OUTPUT);
}

void loop() {
  int reading = digitalRead(button);
  if (reading != lastButtonState) {
    lastDebounceTime = millis();
  }
  if ((millis() - lastDebounceTime) > debounceDelay) {
    if (reading != buttonState) {
      buttonState = reading;
      if (buttonState == HIGH) {
        autoFanMode = !autoFanMode;
      }
    }
  }
  //===
  
  int potentiometerSpeed = analogRead(potentiometer) / 4;

  // LM35 temp ref: temp = (5.0 * analogRead(tempPin) * 100.0) / 1024;
  float outTemp = (5.0 * analogRead(outLM35) * 100.0) / 1024;
  float inTemp = (5.0 * analogRead(inLM35) * 100.0) / 1024;
  float diff = round(abs(outTemp - inTemp));
  int autoSpeed = (255 / 10) * diff;
  int fanSpeed = 0;

  if (autoFanMode == HIGH) {
    // Manual temperature control
    fanSpeed = potentiometerSpeed;
  } else {
    // Automatic temperature control
    if (fanSpeed <= fanSpeedOffset){
      fanSpeed = fanSpeedOffset;
    } else if (fanSpeed >= (255 - fanSpeedOffset)) {
      fanSpeed = 255 - fanSpeedOffset;
    } else {
      fanSpeed = autoSpeed;
    }
  }

  if(BTSerial.available()){
    Serial.write(BTSerial.read());
  }
  if(Serial.available()){
    BTSerial.write(Serial.read());
  }

  Serial.println(fanSpeed);
  analogWrite(fan1, fanSpeed);
  analogWrite(fan2, fanSpeed);
  lastButtonState = reading;
  delay(100);
}
