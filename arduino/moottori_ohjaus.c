//L293D
//Motor A
const int motorPin1  = 5;  // Pin 14 of L293
const int motorPin2  = 6;  // Pin 10 of L293
//Motor B
const int motorPin3  = 10; // Pin  7 of L293
const int motorPin4  = 9;  // Pin  2 of L293

int incomingByte = 0; // for incoming serial data



//This will run only one time.
void setup(){
  Serial.begin(9600); // opens serial port, sets data rate to 9600 bps

 
    //Set pins as outputs
    pinMode(motorPin1, OUTPUT);
    pinMode(motorPin2, OUTPUT);
  //  pinMode(motorPin3, OUTPUT);
  //  pinMode(motorPin4, OUTPUT);
    
  
}


void loop(){
  // send data only when you receive data:
  if (Serial.available() > 0) {
    // read the incoming byte:
    incomingByte = Serial.read();

    // say what you got:
    Serial.print("I received: ");
    Serial.println(incomingByte, DEC);

    if( incomingByte == 'M' ) {
        Serial.println("Turning motor");   
       //This code  will turn Motor A clockwise for 2 sec.
 //       digitalWrite(motorPin1, HIGH);
 //       digitalWrite(motorPin2, LOW);

    int speed = 100;
    for(int i = 0; i < 5; i++) {
       //       analogWrite(motorPin1, 180);
              analogWrite(motorPin1, speed);
              analogWrite(motorPin2, 0);
      
      delay(60*i);
      
              analogWrite(motorPin1, 0);
              analogWrite(motorPin2, speed);
      
            
            //  digitalWrite(motorPin3, LOW);
           //   digitalWrite(motorPin4, LOW);
              
              delay(40*i); 
      //        digitalWrite(motorPin1, LOW);
      //        digitalWrite(motorPin2, LOW);
    
      speed = speed + 20;
    
    }  
    analogWrite(motorPin1, 0);
    analogWrite(motorPin2, 0);

    }
  }

}
