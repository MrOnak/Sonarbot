#include "mbed.h"
#include "m3pi.h"
#include "HCSR04.h"
#include "Servo.h"

m3pi m3pi;
Serial wixel(p28, p27);
DigitalOut wixelReset(p26);
InterruptIn wixelResetButton(p21);
HCSR04 sonar(p15, p16);
Servo servo(p22);

DigitalOut led(LED1);

//---- commands ---------------------------------------------------------------
#define SRLCMD_CMD_NOOP 0x00
/** 
 * request for battery status.
 *
 * the battery response parameter is a float (4 byte), MSB first
 *
 * request syntax:  #b:\n
 * response syntax: #B:[battery]\n
 */
#define SRLCMD_CMD_BATTERY 'b'

/** 
 * request to turn left by a given number of degrees.
 *
 * angle is an int (4 bytes)
 *
 * request syntax:  #l:[angle]\n
 * response syntax: #K\n
 */
#define SRLCMD_CMD_TURNLEFT 'l'

/** 
 * request to turn right by a given number of degrees.
 *
 * angle is an int (4 bytes)
 *
 * request syntax:  #r:[angle]\n
 * response syntax: #K\n
 */
#define SRLCMD_CMD_TURNRIGHT 'r'

/** 
 * request to drive forward by a given number of milimeters.
 *
 * distance is an int (4 byte)
 *
 * request syntax:  #m:[distance]\n
 * response syntax: #K\n
 */
#define SRLCMD_CMD_MOVEFORWARD 'm'

/** 
 * request to drive backward by a given number of milimeters.
 *
 * distance is an int (4 byte)
 *
 * request syntax:  #e:[distance]\n
 * response syntax: #K\n
 */
#define SRLCMD_CMD_MOVEBACKWARD 'e'

/** 
 * request to clear the LCD screen.
 *
 * request syntax:  #c:\n
 * response syntax: #K\n
 */
#define SRLCMD_CMD_LCDCLEAR 'c'

/** 
 * request to write something on the LCD screen at the given position.
 *
 * x and y are ints (4 byte), the text is an array of char
 *
 * request syntax:  #w:[x],[y],[cext]\n
 * response syntax: #K\n
 */
#define SRLCMD_CMD_LCDWRITE 'w'

/** 
 * request to perform a single sonar 'ping' at the given sensor angle
 *
 * Please note that an angle of 90 degrees points the sensor straight ahead of the robot.
 * Angles less than 90 degrees point it left, larger values point it right.
 *
 * request parameter angle is an int (4 byte)
 * response parameters: angle and range are int (4 byte)
 *
 * request syntax:  #p:[angle]\n
 * response syntax: #P:[angle],[range]\n
 */
#define SRLCMD_CMD_SONARPING 'p'

/** 
 * request to perform a sonar sweep from the given startAngle to the endAngle, in stepSize intervals
 *
 * request parameters: startAngle and endAngle are int (4 byte), stepSize is char (1 byte)
 * response parameters: angle and range are int (4 byte)
 *
 * request syntax:  #s:[startAngle],[endAngle],[stepSize]\n
 * response syntax:
 *   sends one line per angle: #P:[angle],[range]\n
 *   followed by a final:      #K\n
 */
 #define SRLCMD_CMD_SONAR_SWEEP 's'

//---- scaling constants ------------------------------------------------------
#define TURNRATE_LEFT 440.0 / 45.0      
#define TURNRATE_RIGHT 460.0 / 45.0

#define FORWARD_DELAY 2730.0 / 200.0
#define BACKWARD_DELAY 2550.0 / 200.0

//---- char assignments to tweak SerialCmd to your need -----------------------
/*
  all command strings are expected to have the following format:
  (SRLCMD_CHAR_START)(command char)(SRLCMD_CHAR_CMDSEP)[(payload chars)[(SRLCMD_CHAR_PAYLOADSEP)(payload chars)[...]]](SRLCMD_CHAR_END)
  
  i.e.  "#a:\n"      for a command 'a' without any parameters - NOTE that the CMDSEP char is mandatory
  i.e.  "#b:P\n"     for a command 'b' with a single byte, single argument payload "P"
  i.e.  "#c:O,V\n"   for a command 'c' with payload consisting of two arguments of one byte each, 'O' and 'V'
*/
#define SRLCMD_CHAR_START '#'               // sent on the beginning of each new command
#define SRLCMD_CHAR_CMDSEP ':'              // separates the command char from the payload
#define SRLCMD_CHAR_PAYLOADSEP ','          // separates individual payload arguments
#define SRLCMD_CHAR_END '\n'                // terminates a command string 

//---- states for the state machine -------------------------------------------
#define SRLCMD_STATE_IDLE 0                 // ready to receive new command
#define SRLCMD_STATE_WAITINGFORCMDBYTE 1    // reveived the '#' start char, waiting for command byte
#define SRLCMD_STATE_CMDBYTERECEIVED 2      // received command char (is expecting a ':' separator char now)
#define SRLCMD_STATE_WAITINGFORPAYLOAD 3    // received separator ':' char, expects payload or terminator now
#define SRLCMD_STATE_CMDAVAILABLE 4         // received '\n' terminator char (possibly preceeded by payload chars)
#define SRLCMD_STATE_PROCESSED 5            // post processing payload is finished and command can now be executed
#define SRLCMD_STATE_FINISHED 6             // execution is done, clean up is required
#define SRLCMD_STATE_ERR 10                 // unexpected char over Serial. this error is irrecoverable at the moment

// serial command related variables
const int cmdPayloadSize = 20;
int cmdPayloadPos = 0;
char cmdPayload[cmdPayloadSize];
char command = SRLCMD_CMD_NOOP;
char cmdState = SRLCMD_STATE_IDLE;

typedef union _serialfloat {
  float f;
  char  c[4];
} SerialFloat;

typedef union _serialint {
  int i;
  char  c[4];
} SerialInt;

float batteryVoltage = 0.0;
int turnAngle = 0;
int moveDistance = 0;
char lcdX = 0;
char lcdY = 0;
char lcdText[20];
int sonarStartAngle = 0;
int sonarEndAngle = 0;
int sonarCurrentAngle = 0;
char sonarStepSize = 0;
int sonarRange = 0; // in mm
char sonarMeasurementsPerPing = 5;





/** 
 * sends a single K\n over serial to confirm that a queued command has been executed
 */
void reportCmdComplete() {
    wixel.printf("#K\n");
}

/**
 * sends ranging information over Serial
 * 
 * @param int angle   in degrees
 * @param int range     in mm
 */
void reportPing(int angle, int range) {
    SerialInt a;
    SerialInt r;
    
    a.i = angle;
    r.i = range;
    
    wixel.printf("#P:%c%c%c%c,%c%c%c%c\n", a.c[3], a.c[2], a.c[1], a.c[0], r.c[3], r.c[2], r.c[1], r.c[0]);
}

/**
 *
 */
void reportBattery(float voltage) {
    SerialFloat v;
    
    v.f = voltage;
    
    wixel.printf("#B:%c%c%c%c\n", v.c[3], v.c[2], v.c[1], v.c[0]); 
    reportCmdComplete();
}

/** 
 * sent after the serial connection has been reset
 */
void reportSerialReset() {
    wixel.printf("#RST\n");
}
    
    
    
    
    
    

/**
 * measures the battery voltage and sends the millivolts value back over wixel
 *
 * response syntax:    #B:[float]\n                     where [float] is the battery voltage in mV
 */
void cmdBattery() {
    batteryVoltage = m3pi.battery();
    reportBattery(batteryVoltage);
}

/**
 * makes the m3pi turn left by the amount of degrees given
 *
 * will send a confirmation over serial when the turn is completed: #K\n
 *
 * @param int degrees
 */
void cmdTurnLeft(int degrees) {
    m3pi.left(0.1);
    wait_ms(TURNRATE_LEFT * degrees);         // @todo do the math to calculate travel distance by time and adjust delay accordingly
    m3pi.stop();
        
    reportCmdComplete();
}

/**
 * makes the m3pi turn right by the amount of degrees given
 *
 * will send a confirmation over serial when the turn is completed: #K\n
 *
 * @param int degrees
 */
void cmdTurnRight(int degrees) {
    m3pi.right(0.1);
    wait_ms(TURNRATE_RIGHT * degrees);         // @todo do the math to calculate travel distance by time and adjust delay accordingly
    m3pi.stop();    
        
    reportCmdComplete();
}

/**
 * Makes the m3pi move in a forward line for the amount of mm given.
 *
 * will send a confirmation over serial when the turn is completed: #K\n
 *
 * @param int distance    distance to travel in mm
 */
void cmdMoveForward(int distance) {
    //m3pi.forward(0.1);
    m3pi.left_motor(0.096);  // for some reason left_motor actually controls the right one
    m3pi.right_motor(0.1);
    
    // @todo do the math to calculate travel distance by time and adjust delay accordingly
    wait_ms(FORWARD_DELAY * distance);
    m3pi.stop();    
    
    reportCmdComplete();
}

/**
 * Makes the m3pi move in a backward line for the amount of mm given.
 *
 * will send a confirmation over serial when the turn is completed: #K\n
 *
 * @param int distance    distance to travel in mm
 */
void cmdMoveBackward(int distance) {
    //m3pi.backward(0.1);    
    m3pi.left_motor(-0.095);
    m3pi.right_motor(-0.1);
    
    // @todo do the math to calculate travel distance by time and adjust delay accordingly
    wait_ms(BACKWARD_DELAY * distance);
    m3pi.stop();    
    
    reportCmdComplete();
}

/**
 * clears the LCD on the m3pi
 *
 * will send a confirmation over serial when the turn is completed: #K\n
 */
void cmdLcdClear() {
    m3pi.cls();
    
    reportCmdComplete();
}

/**
 * writes the given text at the x/y position on the LCD
 *
 * will send a confirmation over serial when the turn is completed: #K\n
 *
 * @param int x    x        position on the LCD
 * @param int y    y        position on the LCD
 * @param char * text       text to write
 */
void cmdLcdWrite(int x, int y, char * text) {
    m3pi.locate(x, y);
    m3pi.printf(text);
        
    reportCmdComplete();
}

/**
 * Will move the servo on which the sonar is mounted to the given angle and take a single ranging measurement
 *
 * Note that an angle of 90° points the sensor straight ahead. So if you want to take a scan to the left side
 * you need to pick a value between [servoMinAngle] and 90° and a value within 90°|[servoMaxAngle] for scans
 * to the right.
 *
 * will respond over serial like this: #P:[short],[int]\n      where [short] is the servo angle and [int] is the sonar range in mm.
 *
 * @param int angle
 */
void cmdSonarPing(int angle) {
    // move servo
    servo.position((float) angle);
    wait_ms(10); // prevent servo noise from disturbing the sonar
    
    float range = 0;
    // take multiple samples and calculate the average
    for (char i = 0; i < sonarMeasurementsPerPing; i++) {
        range += 10 * sonar.getDistance_cm();
    }
    
    range /= sonarMeasurementsPerPing;
    sonarRange = (int) range;
    
    reportPing(angle, sonarRange);
    
    m3pi.locate(0, 0);
    m3pi.printf("%d %d mm ", angle, sonarRange);
}

/**
 * Will perform a sonar sweep from startAngle to endAngle and take a sonar measurement every stepSize degrees
 *
 * Will respond over serial and send one line per measurement:
 *     #P:[int],[int]\n      where [short] is the servo angle and [int] is the sonar range in mm.
 * followed by a single #K\n when the sweep is completed
 */
void cmdSonarSweep(int startAngle, int endAngle, char stepSize) {
    int steps = 1 + (endAngle - startAngle) / stepSize;
    int servoPos = startAngle;
    
    for (int i = 0; i < steps; i++) {
        cmdSonarPing(servoPos);
        servoPos += stepSize;
    }

    reportCmdComplete();
}





/**
 * processes serial-in character by character and assigns a new state to
 * the state-machine according to what is found.
 */
void serialCallback() {
    char inChar;
    
    // only read Serial data when there is no current command
    if (cmdState < SRLCMD_STATE_CMDAVAILABLE 
        && wixel.readable()) {
    
        inChar = wixel.getc();
        //serialPort.printf("received: %c\n", inChar);
                
        switch (cmdState) {
            case SRLCMD_STATE_IDLE:
                if (inChar == SRLCMD_CHAR_START) {
                    cmdState = SRLCMD_STATE_WAITINGFORCMDBYTE;
                } else {
                    cmdState = SRLCMD_STATE_ERR;
                }
                break; 
            
            case SRLCMD_STATE_WAITINGFORCMDBYTE:
                command = inChar;
                cmdState = SRLCMD_STATE_CMDBYTERECEIVED;
                break;
            
            case SRLCMD_STATE_CMDBYTERECEIVED:
                if (inChar == SRLCMD_CHAR_CMDSEP) {
                    cmdState = SRLCMD_STATE_WAITINGFORPAYLOAD;
                } else {
                    cmdState = SRLCMD_STATE_ERR;
                }
                break;
            
            case SRLCMD_STATE_WAITINGFORPAYLOAD:
                if (inChar == SRLCMD_CHAR_END) {
                    // payload end has been reached
                    cmdState = SRLCMD_STATE_CMDAVAILABLE;
                } else {
                    // add inChar to payload for later processing
                    cmdPayload[cmdPayloadPos] = inChar;
                    cmdPayloadPos++;
                }
                break;
        }
    }
}


/**
 * will take the stream of input payload chars and convert it to meaningful
 * payload variables (int, long, float, ...)
 *
 * must return SRLCMD_STATE_ERR on error or SRLCMD_STATE_PROCESSED when finished
 *
 * @param char cmd
 * @param char * payload
 * @param int payloadSize
 * @return char
 */
char processPayload(char cmd, char * payload, int payloadPos) {
    char processed = SRLCMD_STATE_ERR;
    
    // these are test commands to verify variable-type unpacking
    switch (cmd) {
        case SRLCMD_CMD_BATTERY:
        case SRLCMD_CMD_LCDCLEAR:
            // no params at all
            if (payloadPos == 0) {
                processed = SRLCMD_STATE_PROCESSED;
            }
            break;
        case SRLCMD_CMD_TURNLEFT:
        case SRLCMD_CMD_TURNRIGHT:
            // expecting four bytes payload
            if (payloadPos == 4) {
                turnAngle = (static_cast<uint32_t>(payload[0]) << 24) 
                          | (static_cast<uint32_t>(payload[1]) << 16) 
                          | (static_cast<uint32_t>(payload[2]) << 8) 
                          | payload[3];
                processed = SRLCMD_STATE_PROCESSED;
            }  
            break;
        case SRLCMD_CMD_MOVEFORWARD:
        case SRLCMD_CMD_MOVEBACKWARD:
            // expecting four bytes payload
            if (payloadPos == 4) {
                moveDistance = (static_cast<uint32_t>(payload[0]) << 24) 
                             | (static_cast<uint32_t>(payload[1]) << 16) 
                             | (static_cast<uint32_t>(payload[2]) << 8) 
                             | payload[3];
                processed = SRLCMD_STATE_PROCESSED;
            }  
            break;
        case SRLCMD_CMD_LCDWRITE:
            // expecting over 10 bytes payload: 2x4 bytes for position x/y, two separators, followed by chars
            if (payloadPos > 10 && payload[4] == SRLCMD_CHAR_PAYLOADSEP && payload[9] == SRLCMD_CHAR_PAYLOADSEP) {
                lcdX = (static_cast<uint32_t>(payload[0]) << 24) 
                     | (static_cast<uint32_t>(payload[1]) << 16) 
                     | (static_cast<uint32_t>(payload[2]) << 8) 
                     | payload[3];
                lcdY = (static_cast<uint32_t>(payload[5]) << 24) 
                     | (static_cast<uint32_t>(payload[6]) << 16) 
                     | (static_cast<uint32_t>(payload[7]) << 8) 
                     | payload[8];
                     
                for (int i = 10; i < payloadPos; i++) {
                    lcdText[i-10] = payload[i];
                }
                processed = SRLCMD_STATE_PROCESSED;
            } 
            break;
        case SRLCMD_CMD_SONARPING:
            // expecting four bytes payload
            if (payloadPos == 4) {
                sonarStartAngle = (static_cast<uint32_t>(payload[0]) << 24) 
                                | (static_cast<uint32_t>(payload[1]) << 16) 
                                | (static_cast<uint32_t>(payload[2]) << 8) 
                                | payload[3];
                processed = SRLCMD_STATE_PROCESSED;
            }  
            break;
        case SRLCMD_CMD_SONAR_SWEEP:
            // expecting eleven bytes payload: 4 byte start angle, comma, 4 byte end angle, comma, 1 byte stepSize
            if (payloadPos == 11) {
                sonarStartAngle = (static_cast<uint32_t>(payload[0]) << 24)
                                | (static_cast<uint32_t>(payload[1]) << 16)
                                | (static_cast<uint32_t>(payload[2]) << 8) 
                                | payload[3];
                sonarEndAngle   = (static_cast<uint32_t>(payload[5]) << 24) 
                                | (static_cast<uint32_t>(payload[6]) << 16) 
                                | (static_cast<uint32_t>(payload[7]) << 8) 
                                | payload[8];
                sonarStepSize   = payload[10];
                processed = SRLCMD_STATE_PROCESSED;
            }  
            break;
    }
    
    //serialPort.printf("processing payload for %c complete. result: %d\n", cmd, processed);
    return processed;
}

/**
 * will return true when the given command char is a recognized command,
 * false otherwise
 *
 * @param char cmd
 * @return bool
 */
bool verifyCommand(char cmd) {
    //serialPort.printf("verifying command: %c\n", cmd);
    
    bool verification = false;
    // @todo return true here for every command that your program accepts
    // you can also extend this to validate the parameters associated with each command
    switch (cmd) {
        case SRLCMD_CMD_BATTERY:
        case SRLCMD_CMD_TURNLEFT:
        case SRLCMD_CMD_TURNRIGHT:
        case SRLCMD_CMD_MOVEFORWARD:
        case SRLCMD_CMD_MOVEBACKWARD:
        case SRLCMD_CMD_LCDCLEAR:
        case SRLCMD_CMD_LCDWRITE:
        case SRLCMD_CMD_SONARPING:
        case SRLCMD_CMD_SONAR_SWEEP:
            verification = true;
            break;
    }
    
    //serialPort.printf("verifying command %c complete, result: %b\n", cmd, verification);
    return verification;
}

/**
 * will execute the given command by calling the appropriate handler function
 *
 * handler functions must 
 * - require zero input parameters 
 * - return either SRLCMD_STATE_ERR on error 
 *   or SRLCMD_STATE_FINISHED when execution completed successfully
 *
 * @param char command
 * @return char
 */
char executeCommand(char cmd) {
    char execution = SRLCMD_STATE_ERR;
    // @todo implement executeCommand() by calling your custom handlers here
    //m3pi.locate(0, 0);
    //serialPort.printf("executing command: %c\n", cmd);
    
    switch (cmd) {
        case SRLCMD_CMD_BATTERY:
            cmdBattery();
            execution = SRLCMD_STATE_FINISHED;
            break;
        case SRLCMD_CMD_TURNLEFT:
            cmdTurnLeft(turnAngle);
            execution = SRLCMD_STATE_FINISHED;
            break;
        case SRLCMD_CMD_TURNRIGHT:
            cmdTurnRight(turnAngle);
            execution = SRLCMD_STATE_FINISHED;
            break;
        case SRLCMD_CMD_MOVEFORWARD:
            cmdMoveForward(moveDistance);
            execution = SRLCMD_STATE_FINISHED;
            break;
        case SRLCMD_CMD_MOVEBACKWARD:
            cmdMoveBackward(moveDistance);
            execution = SRLCMD_STATE_FINISHED;
            break;
        case SRLCMD_CMD_LCDCLEAR:
            cmdLcdClear();
            execution = SRLCMD_STATE_FINISHED;
            break;
        case SRLCMD_CMD_LCDWRITE:
            cmdLcdWrite(lcdX, lcdY, lcdText);
            execution = SRLCMD_STATE_FINISHED;
            break;
        case SRLCMD_CMD_SONARPING:
            cmdSonarPing(sonarStartAngle);
            reportCmdComplete();
            execution = SRLCMD_STATE_FINISHED;
            break;
        case SRLCMD_CMD_SONAR_SWEEP:
            cmdSonarSweep(sonarStartAngle, sonarEndAngle, sonarStepSize);
            execution = SRLCMD_STATE_FINISHED;
            break;
    }
    
    //serialPort.printf("executing command %c complete. result: %d\n", cmd, execution);
    return execution;
}



/**
 * interrupt callback function that resets the wixel
 */
void resetWixelStart() {
    led        = 1;
    wixelReset = 0;
}

void resetWixelEnd() {
    led        = 0;
    wixelReset = 1;
    
    reportSerialReset();
}
    

/**
 * main program loop
 */
int main() {
    
    m3pi.reset();
    
    wixelResetButton.mode(PullUp);
    wixelResetButton.fall(&resetWixelStart);
    wixelResetButton.rise(&resetWixelEnd);
    
    wait(0.5);
    wixel.baud(115200);
    wixel.attach(serialCallback);

    wait(0.5);
    servo.calibrate(0.0005, 60.0);
    
    m3pi.cls();
    m3pi.printf("SonarBot"); // need to send something to the m3pi just to stop it running the demo app...
    
    while (1) {
//        cmdSonarSweep(-60, 60, 2);
//        wait(1);
        
        switch (cmdState) {
            case SRLCMD_STATE_CMDAVAILABLE:
                // new command is ready for post processing
                cmdState = processPayload(command, cmdPayload, cmdPayloadPos);
                break;
            
            case SRLCMD_STATE_PROCESSED:
                // execute
                if (verifyCommand(command)) {
                    cmdState = executeCommand(command);
                } else {
                    cmdState = SRLCMD_STATE_ERR;
                }
                break;
            
            case SRLCMD_STATE_FINISHED:
                // reset all variables
                command = SRLCMD_CMD_NOOP;
                cmdPayloadPos = 0;
                cmdState = SRLCMD_STATE_IDLE;
                //serialPort.printf("cleaned up after command. new cmdState is now %c\n", cmdState);
                break;
            
            case SRLCMD_STATE_ERR:
                // display something useful on the LCD
                wait(5);
                cmdState = SRLCMD_STATE_FINISHED;
            break;
            
            // all other states are input-related and can be ignored here
        }
        
        m3pi.locate(0, 1);
        m3pi.printf("%d:%c   ", cmdState, command);
        
    }
}
