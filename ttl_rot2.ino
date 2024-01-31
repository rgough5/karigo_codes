// #include <LiquidCrystal.h>
// const int rs = 8, en = 9, d4 = 4, d5 = 5, d6 = 6, d7 = 7;
// LiquidCrystal lcd(rs, en, d4, d5, d6, d7);

int CLK = 2;
int DT = 3;
int knobButt = 10, buttButt = 12;
//shutter = shutter, onLite = stim light, shamLite = sham light
// from left to right, the BNC's connect to ports 4, 5, 6, 7
int shutter = 7, extra = 4, onLite = 5, shamLite = 6;
int opt = 0;
int currentCLK = LOW;
int lastCLK = LOW;
int r_val = 2;

String topTxt = "#";
String botTxt = "";

const int numOpt = 5; // IMPORTANT, this needs to be the same as the rows of options
// format as:
// {flip(t/f) [0 = Certain, 1 = Flip, 2 = Sham], run time (in ms), pulse0 (closed shutter), pulse1 (open shutter)},
// all times are in ms
int options[numOpt][4] = {
  { 1, 30000, 0, 50 }, //#0 30sec cont
  { 2, 30000, 0, 50 }, //#1 30sec cont
  { 0, 5000, 0, 50}, //#2 5sec cont
  { 0, 30000, 40, 10 }, //#3 30sec 20Hz
  { 2, 30000, 40, 10 }, //#4 30sec 20Hz
};

void stim() {
  int F = options[opt][0];
  int T = options[opt][1];
  int P0 = options[opt][2];
  int P1 = options[opt][3];

  if (F == 1){
    r_val = random(100);
  } else if (F==2){
    r_val = 98;
  } else{
    r_val = 2; //value is arbitrary, just needs to be less than 50
  }

  Serial.println("running " + String(r_val < 50));

  unsigned long startT = millis();

  if (r_val < 50) {
    digitalWrite(onLite, HIGH);
    while (millis() < (startT + T)) {
      if (digitalRead(knobButt) == LOW){
        digitalWrite(shutter, LOW);
        digitalWrite(onLite, LOW);
        break;
      }

      //Stage 1 (open shutter)
      if (P1 != 0){
        digitalWrite(shutter, HIGH);
        delay(P1);
      }
      //Stage 2 (close shutter)
      if (P0 != 0){
        digitalWrite(shutter, LOW);
        delay(P0);
      }
    }
    digitalWrite(shutter, LOW);
    digitalWrite(onLite, LOW);
  } else { //sham
    digitalWrite(shamLite, HIGH);
    while (millis() < (startT + T)){
      if (digitalRead(knobButt) == LOW){
        digitalWrite(shamLite, LOW);
        break;
      }
      delay(50);
    }
    digitalWrite(shamLite, LOW);
  }
  // digitalWrite(shutter, LOW);
  // digitalWrite(onLite, LOW);
  // digitalWrite(shamLite, LOW);
  Serial.println("finished");
}

void setup() {
  pinMode(CLK, INPUT_PULLUP);
  pinMode(DT, INPUT_PULLUP);
  pinMode(knobButt, INPUT_PULLUP);
  pinMode(buttButt, INPUT_PULLUP);
  pinMode(shutter, OUTPUT);
  pinMode(extra, OUTPUT);
  pinMode(onLite, OUTPUT);
  pinMode(shamLite, OUTPUT);

  Serial.begin(9600);
}

void loop() {
  currentCLK = digitalRead(CLK);
  if ((lastCLK == LOW) && (currentCLK == HIGH)) {
    if (digitalRead(DT) == currentCLK) {
      if ((opt + 2) > numOpt){
        opt = 0;
      } else{
        opt++;
      }
    } else {
      if (opt == 0){
        opt = numOpt - 1;
      }else{
        opt--;
      }
    }
    // better, but still awful way to handle text
    topTxt = "#" + String(opt);
    if (options[opt][0] == 1){
      topTxt += " F "; //F for coin Flip
    } else if (options[opt][0] == 2){
      topTxt += " S "; //S for Sham stimulation
    } else{
      topTxt += " C "; //C for Certain stimulation
    }
    topTxt += String(options[opt][1] / 1000) + "s ";
    if (options[opt][2] == 0 || options[opt][3] == 0){
      topTxt += "static";
      botTxt = "   --";
    } else{
      topTxt += String(1000 / (options[opt][2] + options[opt][3])) + "Hz";
      botTxt = "   p1=" + String(options[opt][3]) + " p0=" + String(options[opt][2]);
    }
    Serial.println(topTxt);
    Serial.println(botTxt);
  }
  lastCLK = currentCLK;
  if (digitalRead(buttButt) == LOW){
    stim();
  }
  delay(2);
}