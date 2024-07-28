#include <Encoder.h>
Encoder myEnc1(2, 4);
Encoder myEnc2(3, 5);

// Declare pin
#define S11 4
#define S12 2
#define S21 5
#define S22 3

#define M11 8
#define M12 9
#define M21 12
#define M22 13

#define ENA 10
#define ENB 11

#define PPR 82.77 //Pulses per Revolution of outer shaft
#define GR 100 //Gear Ratio

// Cut off value for homing
volatile float motor_2_homing_limit = 5.5; //2.5 for un loaded
volatile float motor_1_homing_limit = 6.5; //2.5 for un loaded

// Cut off value for object detection
volatile float object_detection_cut_off = 5; //2.5 for un loaded
volatile float object_detection_cycles_cut_off = 7; //2.5 for un loaded

// Cut off value for PWM and error
volatile int PWM1_cutoff = 35;
volatile int PWM2_cutoff = 30;
volatile float acceptable_error = 0.5;

// Declare variable to read current
// volatile float sensorValue;   // Variable to store value from analog read
volatile float current;       // Calculated current value
volatile float max_current = 0;       // Calculated current value

// Declare PID OlD: 4 8 1.2 for M1 and M2
volatile float kp1 = 5;
volatile float ki1 = 5;
volatile float kd1 = 0.5;

volatile float kp2 = 3;
volatile float ki2 = 4;
volatile float kd2 = 0.5;

volatile int N = 10;

// Declare variable to calculate PID component
volatile double time;
volatile double otime = -1;
volatile double dt;

volatile double de1;
volatile double err1;
volatile double sum_err1 = 0;
volatile double pre_err1 = 0;
volatile double de2;
volatile double err2;
volatile double sum_err2 = 0;
volatile double pre_err2 = 0;
volatile double sum_derivative1 = 0;
volatile double sum_derivative2 = 0;

// Declare angle variable
volatile long pos1;
volatile double angle1;
volatile double old_angle1 = 0;
volatile double speed1;

volatile long pos2;
volatile double angle2;
volatile double old_angle2 = 0;
volatile double speed2;

// Declare speed variable
volatile int PWM1;
volatile int PWM2;

// Declare target angle variable
volatile double tangle1 = 0;
volatile double tangle2 = 0;

// Declare variables to communicate with matlab
char c;                   // characters received from matlab
volatile float val1 = 0.0;         // input1 from matlab
volatile float val2 = 0.0;         // input2 from matlab
String matlabStr = "";    // receives the string from matlab, it is empty at first

// Declare variables for loop and logic
bool readyToSend = false; // flag to indicate a command was received and now ready to send back to matlab
int i = 1;                // counter
volatile int object_detection_cycles = 0;
volatile bool Collision_condition = 0;
volatile bool keep_rotating = 1;

// Clamping
volatile bool Saturation_1 = 0;
volatile bool Saturation_2 = 0;

void setup() {
  // configure serial communication speed
  Serial.begin(9600);
  //Set pins as inputs (sensor)
  pinMode(S11, INPUT);
  pinMode(S12, INPUT);
  pinMode(S21, INPUT);
  pinMode(S22, INPUT);
  //Set pins as outputs (motor)
  pinMode(M11, OUTPUT);
  pinMode(M12, OUTPUT);
  pinMode(ENA,OUTPUT); 

  pinMode(M21, OUTPUT);
  pinMode(M22, OUTPUT);
  pinMode(ENB,OUTPUT); 
  // Serial.println("Begin");
  // delay(1000);
  while (Serial.available()==0) {};
  while (Serial.available()>0) {Serial.read();};

  // Homing motor 2
  digitalWrite(M21, 1);
  digitalWrite(M22, 0);
  current = analogRead(A5);
  while (current < motor_2_homing_limit) {
    analogWrite(ENB, 30);
    current = analogRead(A5);
  }
  analogWrite(ENB, 0);
  // Homing motor 1
  digitalWrite(M11, 1);
  digitalWrite(M12, 0);
  current = analogRead(A5);
  while (current < motor_1_homing_limit) {
    analogWrite(ENA, 30);
    current = analogRead(A5);
  }
  analogWrite(ENA, 0);
  delay(1000);

  // Reset the position
  myEnc1.write(0);
  myEnc2.write(0);
}

/* Continuous loop function in Arduino */
void loop() {
  if (keep_rotating == 1)  {
    // Receive data from matlab to arduino
    // if (readyToSend == false) {
      if (Serial.available()>0)       // is there anything received?
      {
        c = Serial.read();            // read characters
        matlabStr = matlabStr + char(c);    // append characters to string as these are received
        
        if (matlabStr.indexOf(";") != -1) // have we received a semi-colon (indicates end of command from matlab)?
        {
          readyToSend = true;         // then set flag to true since we have received the full command

          // parse incomming data, e.g. C40.0,3.5;
          int posComma1 = matlabStr.indexOf(",");                     // position of comma in string
          tangle1 = -matlabStr.substring(1, posComma1).toFloat();         // float from substring from character 1 to comma position
          int posEnd = matlabStr.indexOf(";");                        // position of last character
          tangle2 = -matlabStr.substring(posComma1+1, posEnd).toFloat();  // float from substring from comma+1 to end-1
          matlabStr = "";

          // Reset the variable
          sum_err1 = 0;      
          sum_err2 = 0;
          sum_derivative1 = 0;
          sum_derivative2 = 0;
          Saturation_1 = 0;
          Saturation_2 = 0;

          pos1 = myEnc1.read();
          angle1 = pos1*360/(PPR*GR);
          if ((angle1 >=180) || (angle1 <-180)) {
          pos1 = pos1 - PPR*GR*int (angle1 / 360);
          myEnc1.write(pos1);
          angle1 = pos1*360/(PPR*GR);
          }
          pre_err1 = tangle1 - angle1;


          pos2 = myEnc2.read();
          angle2 = pos2*360/(PPR*GR);
          if ((angle2 >=180) || (angle2 <-180)) {
          pos2 = pos2 - PPR*GR*int (angle2 / 360);
          myEnc2.write(pos2);
          angle2 = pos2*360/(PPR*GR);
          }
          pre_err2 = tangle2 - angle2;

        }
      }
    // }
    
    // Get sample time
    time=micros();  
    dt = time - otime;
    otime = time;

    // PID controlling

    // Read angle 1
    pos1 = myEnc1.read();
    angle1 = pos1*360/(PPR*GR);
    if ((angle1 >=180) || (angle1 <-180)) {
    pos1 = pos1 - PPR*GR*int (angle1 / 360);
    myEnc1.write(pos1);
    angle1 = pos1*360/(PPR*GR);
    }
    // Calculate PID component 1
    err1 = tangle1 - angle1;
    de1 = (err1 * kd1 - sum_derivative1) * N;
    // de1 = (err1 - pre_err1)*1000000/dt;
    pre_err1 = err1;
    // sum_err1 = sum_err1 + err1 * dt;  
    PWM1 = kp1 * err1 + ki1 * sum_err1 / 1000000 + de1;

    // Limit voltage output 1
    Saturation_1 = 0;
    if (PWM1 >PWM1_cutoff) {
      PWM1 = PWM1_cutoff;
      Saturation_1 = 1;};
    if (PWM1 <-PWM1_cutoff) {
      PWM1 = -PWM1_cutoff;
      Saturation_1 = 1;};

    // Intergrator clamping
    sum_err1 = sum_err1 + err1 * dt * !(Saturation_1 & ((err1 > 0) == (PWM1 > 0)));
    // Derivative noise filtering
    sum_derivative1 = sum_derivative1 + de1 * dt / 1000000;
    // Stop when motor reach certain error 1
    if (abs(err1) < acceptable_error) {PWM1 = 0;};

    // Rotating the motor 1
    if (PWM1 >= 0) {
      analogWrite(ENA, round(PWM1));
      digitalWrite(M11, 1);
      digitalWrite(M12, 0);
    } else {
      analogWrite(ENA, abs(round(PWM1)));
      digitalWrite(M11, 0);
      digitalWrite(M12, 1);
    }

    // Read angle 2
    pos2 = myEnc2.read();
    angle2 = pos2*360/(PPR*GR);
    if ((angle2 >=180) || (angle2 <-180)) {
    pos2 = pos2 - PPR*GR*int (angle2 / 360);
    myEnc2.write(pos2);
    angle2 = pos2*360/(PPR*GR);
    }
    // Calculate PID component 2
    err2 = tangle2 - angle2;
    de2 = (err2 * kd2 - sum_derivative2) * N;
    // de2 = (err2 - pre_err2)*1000000/dt;
    pre_err2 = err2;
    // sum_err2 = sum_err2 + err2 * dt;
    PWM2 = kp2 * err2 + ki2 * sum_err2 / 1000000 + de2;
    
    // Limit voltage output 2
    Saturation_2 = 0;
    if (PWM2 >PWM2_cutoff) {
      PWM2 = PWM2_cutoff;
      Saturation_2 = 1;};
    if (PWM2 <-PWM2_cutoff) {
      PWM2 = -PWM2_cutoff;
      Saturation_2 = 1;};

    // Intergrator clamping
    sum_err2 = sum_err2 + err2 * dt * !(Saturation_2 & ((err2 > 0) == (PWM2 > 0)));
    // Derivative noise filtering
    sum_derivative2 = sum_derivative2 + de2 * dt / 1000000;
    // Stop when motor reach certain error 1
    if (abs(err2) < acceptable_error) {PWM2 = 0;};

    // Rotating the motor 2
    if (PWM2 >= 0) {
    digitalWrite(M21, 1);
    digitalWrite(M22, 0);
    analogWrite(ENB, round(PWM2));
    } else {
    analogWrite(ENB, abs(round(PWM2)));
    digitalWrite(M21, 0);
    digitalWrite(M22, 1);
    }

    // Read current for object detection
    current = analogRead(A5);
    speed1 = abs(angle1 - old_angle1) * 1000000/dt;
    speed2 = abs(angle2 - old_angle2) * 1000000/dt;
    old_angle1 = angle1;
    old_angle2 = angle2;

    Collision_condition = (((PWM1_cutoff - abs(PWM1)) < 10) & (speed1 < 5)) || (((PWM2_cutoff - abs(PWM2)) < 10) & (speed2 < 5));
    if (Collision_condition) {
      object_detection_cycles = object_detection_cycles + 1;
      if (object_detection_cycles > object_detection_cycles_cut_off) {
        keep_rotating = 0;
      }
    } else {
      object_detection_cycles = 0;
    }
    

    // Sending data from Ardiono to matlab
    // if (readyToSend)  // arduino has received command form matlab and now is ready to send
    // {
      // e.g. c1,100
      Serial.print("c");                    // command
      Serial.print(0);                      // series
      // Serial.print(i);                      // series 1
      Serial.print(":");                    // delimiter
      Serial.print(-angle1); // series 1
      Serial.print("-"); // delimiter
      Serial.print(-angle2); // series 2
      Serial.print("-"); // delimiter
      Serial.print(-err1); // error 1
      Serial.print("-"); // delimiter
      Serial.print(-err2); // error 2
      Serial.print("-"); // delimiter
      Serial.print(time/1000); // time
      Serial.print("-"); // delimiter
      Serial.print(dt/1000); // dt
      Serial.print("-"); // delimiter
      Serial.print(speed1); // dt
      Serial.print("-"); // delimiter
      Serial.print(speed2); // dt
      Serial.print("-"); // delimiter
      Serial.print(PWM1); // dt
      Serial.print("-"); // delimiter
      Serial.print(PWM2); // dt
      Serial.print("-"); // delimiter
      Serial.print(object_detection_cycles); // dt
      // Serial.print("-"); // delimiter
      // Serial.print(-sum_err2 / 1000000); // error 1
      Serial.write(13);                     // carriage return (CR)
      Serial.write(10);                     // new line (NL)
      // i += 1;
    // }
  } else {
    analogWrite(ENA, 0);
    analogWrite(ENB, 0);
    delay(3000);
    sum_err1 = 0;
    sum_err2 = 0;
    object_detection_cycles = 0;
    keep_rotating = 1;
  }

}
