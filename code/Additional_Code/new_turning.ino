#define LOG_OUT 1 // use the log output function
#define FFT_N 128 // set to 256 point fft
#include <Servo.h>
#include <FFT.h> // include the library

volatile int ls_l; //left light sensor
volatile int ls_ll; //edge left light sensor //6
volatile int ls_r; //right light sensor
volatile int ls_rr; //edge right sensor //4

//servo pins/setup
Servo left;
Servo right;
int s_r_pin = 6;
int s_l_pin = 7;

//line follower sensor
int mux_pin = 2;
int ls_l_pin = 1;
int ls_r_pin = 2;

int mux_a_pin = 4;
int mux_b_pin = 3;
int mux_c_pin = 2;

int thrs = 200;
int wht = 200;

// for code
volatile unsigned int thrs_ll = 0;
volatile unsigned int thrs_l = 0;
volatile unsigned int thrs_r = 0;
volatile unsigned int thrs_rr = 0;


volatile int turn_counter = 0;

void setup() {
  Serial.begin(9600);
  //pinMode(frontLED, OUTPUT);
  pinMode(mux_a_pin, OUTPUT);
  pinMode(mux_b_pin, OUTPUT);
  pinMode(mux_c_pin, OUTPUT);
  pinMode(0, INPUT_PULLUP);
  //pinMode(pin, OUTPUT);
  Serial.println("starting");
  threshold_setup();
  
  while((!microphone())&(!button_press())){
  }
  left.attach(s_l_pin);
  right.attach(s_r_pin);
  
}
void loop() {
 
 // ***right turn*** 
  check_sensors();
  if((ls_rr <= 300) && (ls_ll <= 300)){
    go_straight();
    delay(350);   
  stand_still();
    check_sensors();
    while(ls_rr >= thrs_rr){
      turn_right();
      check_sensors();
      }
      check_sensors();
    while(ls_r >= thrs_r){
      turn_right();
      check_sensors();
    }
    stand_still();
    while(ls_l >= thrs_l){
      turn_right();
      check_sensors();
    }
     stand_still();
      delay(100);
    go_straight();
    }
  

  //   ***left turn***
  check_sensors();
  if((ls_rr <= thrs_rr) && (ls_ll <= thrs_ll)){
    go_straight();
    delay(350);   
  stand_still();
  delay(2000);
    check_sensors();
    while(ls_ll >= thrs_ll){
      turn_left();
      check_sensors();
      }
      check_sensors();
    while(ls_l >= thrs_l){
      turn_left();
      check_sensors();
    }
    while(ls_r >= thrs_r){
      turn_left();
      check_sensors();
    }
     stand_still();
      delay(100);
    go_straight();
   }   


  
  //black condition
  if((ls_l > thrs_l) && (ls_r > thrs_r)){
    go_straight();
    check_sensors();
  }
  //ls_c on white and ls_r or ls_l on white
  if(((ls_l <= thrs_l) || (ls_r <= thrs_r))){
    go_straight();
    check_sensors();
    if(ls_l <= thrs_l){ //left on white
     shift_left();
     check_sensors();
  }
  if(ls_r <= thrs_r){ // right on white
      shift_right();
      check_sensors();
  }
}

}

void threshold_setup(){
int thrs_ll_b = 0;
int thrs_l_b = 0;
int thrs_r_b = 0;
int thrs_rr_b = 0;

int thrs_ll_w = 0;
int thrs_l_w = 0;
int thrs_r_w = 0;
int thrs_rr_w = 0;
Serial.println("Place robot on black");
  while(!button_press()){};
  //on all black
  for(int i = 0; i < 10; i ++){
    check_sensors();
    thrs_ll_b += ls_ll;
    thrs_l_b += ls_l;
    thrs_r_b += ls_r;
    thrs_rr_b += ls_rr;
  }
Serial.println("black measurements taken");
  //average values to determine the values when they are on all black
  thrs_ll_b = thrs_ll_b / 10;
  thrs_l_b = thrs_l_b / 10;
  thrs_r_b = thrs_r_b /10;
  thrs_rr_b = thrs_rr_b / 10;
  
Serial.println("place robot on white");
  while(!button_press()){};
  //on all whire
  for(int i = 0; i < 10; i ++){
    check_sensors();
    thrs_ll_w += ls_ll;
    thrs_l_w += ls_l;
    thrs_r_w += ls_r;
    thrs_rr_w += ls_rr;
  }
Serial.println("white measurements taken");
  //average values to determine the values then the sensors are on all white
  thrs_ll_w = thrs_ll_w / 10;
  thrs_l_w = thrs_l_w / 10;
  thrs_r_w = thrs_r_w /10;
  thrs_rr_w = thrs_rr_w / 10;

  //final threshold: Lower threshold (white) + 200
  thrs_ll = thrs_ll_w + 200;
  thrs_l = thrs_l_w + 200;
  thrs_r = thrs_r_w + 200;
  thrs_rr = thrs_rr_w + 200;

  Serial.println("thrs_ll : ");
  Serial.println(thrs_ll);
  Serial.println("thrs_l : ");
  Serial.println(thrs_l);
  Serial.println("thrs_r : ");
  Serial.println(thrs_r);
  Serial.println("thrs_rr : ");
  Serial.println(thrs_rr);
}

void check_sensors(){
  digitalWrite(mux_c_pin, HIGH);
  digitalWrite(mux_b_pin, LOW);
  digitalWrite(mux_a_pin, LOW);
  
  ls_r = analogRead(ls_r_pin); //right
  ls_l = analogRead(ls_l_pin); //left
  
  Serial.print("ls_r: ");
  Serial.println(ls_r);
  Serial.print("ls_l: ");
  Serial.println(ls_l);

  ls_rr = analogRead(5); //to detect intersections
  Serial.print("ls_rr: ");
  Serial.println(ls_rr);  
  ls_ll = analogRead(2);
  Serial.print("ls_ll: ");
  Serial.println(ls_ll);
}

void stand_still(){
  right.write(90);
  left.write(90);
}

void shift_right(){
  right.write(96);
  left.write(180);
  //r120/l180
}

void shift_left(){
  right.write(0);
  left.write(84);
}

void turn_right(){
  right.write(100);
  left.write(180);
}

void turn_left(){
  right.write(0);
  left.write(0);
}

void go_straight_delay(){
  right.write(0);
  left.write(180);
  delay(50);
}

void go_straight(){
  right.write(0);
  left.write(180);
}

int microphone(){
  
    cli();
    for (int i = 0 ; i < FFT_N/2 ; i += 2) {
      fft_input[i] = analogRead(A3); // <-- NOTE THIS LINE
      fft_input[i+1] = 0;
    }
    fft_window();
    fft_reorder();
    fft_run();
    fft_mag_log();
    sei();
    int test = fft_log_out[9];
    if(test >= 55) {
      return 1;
    }
    else{
      return 0;
    }

}

int button_press(){
  int temp = digitalRead(0);
  if(temp == LOW){
    return 1;
  }else{
    return 0;
  }
}
