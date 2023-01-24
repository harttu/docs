//L293D
//Motor A
const int motorPin1  = 5;  // Pin 14 of L293
const int motorPin2  = 6;  // Pin 10 of L293


// Some other Variables we need
int SoundInPin = A1;
int LedPin = 11; //in case you want an LED to activate while mouth moves

boolean running = false;

// the setup routine runs once when you press reset:
void setup() {
  Serial.begin(9600);           // set up Serial library at 9600 bps


    //Set pins as outputs
    pinMode(motorPin1, OUTPUT);
    pinMode(motorPin2, OUTPUT);

pinMode(LedPin,OUTPUT);
/*
  AFMS.begin();  // create with the default frequency 1.6KHz
  //AFMS.begin(1000);  // OR with a different frequency, say 1KHz
  
  // Set the speed to start, from 0 (off) to 255 (max speed)
  myMotor->setSpeed(0); //mouth motor
  myMotor->run(FORWARD);
  // turn on motor
  myMotor->run(RELEASE);
     pinMode(SoundInPin, INPUT);
     pinMode(LedPin, OUTPUT);
  myOtherMotor->setSpeed(0); //tail motor
  myOtherMotor->run(FORWARD);
  // turn on motor
  myOtherMotor->run(RELEASE);
     pinMode(SoundInPin, INPUT);  
     */
  running = false;
}

// the loop routine runs over and over again forever:
void loop() {
//analogWrite(LedPin,255);
    if (Serial.available() > 0) 
    {
        switch(Serial.read())
        {
        case '1':
            running = true;
            Serial.print('\n');
            break;
        case '2':
            running = false;
            Serial.print("stopped");
            break;
        }
    }

    if (running)
    {
   
    
    uint8_t i;
    
    // read the input on analog pin 0:
    int sensorValue = analogRead(SoundInPin);
  // we Map another value of this for LED that can be a integer betwen 0..255 
    int LEDValue = map(sensorValue,0,512,0,255);

Serial.println("LEDvalue");
Serial.println(LEDValue);
Serial.println(255 - LEDValue);

boolean suunta = 255 - LEDValue > 0;
int magnitudi = abs(255- LEDValue);    
    // We Map it here down to the possible range of  mov)ement.
  //  sensorValue = map(sensorValue,0,512,0,180);
    // note normally the 512 is 1023 because of analog reading should go so far, but I changed that to get better readings.
    int MoveDelayValue = map(sensorValue,0,255,0,sensorValue);

  
  //sleep(50);
  
  Serial.println(sensorValue);
  //Serial.println(sensorValue);
  
  analogWrite(LedPin,LEDValue);

    int nopeus = 105;
    int aika = 30;

if( magnitudi > 1 ) {
  if( suunta) {
  
          Serial.println("Turning motor");
           digitalWrite(motorPin1, HIGH);   
           digitalWrite(motorPin2, LOW);
  
           analogWrite(motorPin1, nopeus);
           delay(aika);
  
           digitalWrite(motorPin1, LOW);   
           digitalWrite(motorPin2, LOW);
  } else {
           digitalWrite(motorPin1, LOW);   
           digitalWrite(motorPin2, HIGH);
  
           analogWrite(motorPin2, nopeus);
          delay(aika);
  
           digitalWrite(motorPin1, LOW);   
           digitalWrite(motorPin2, LOW);
  }
}  
  }
}
