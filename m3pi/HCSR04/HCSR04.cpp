#include "mbed.h"
#include "HCSR04.h"

HCSR04::HCSR04(PinName echoPin, PinName triggerPin) : echo(echoPin), trigger(triggerPin) {
    init();
}

void HCSR04::init() {
    /** configure the rising edge to start the timer */
    echo.rise(this, &HCSR04::startTimer);
    
    /** configure the falling edge to stop the timer */
    echo.fall(this, &HCSR04::stopTimer);
    
    distance = -1; // initial distance
}

void HCSR04::startTimer() {
    timer.start(); // start the timer
}

void HCSR04::stopTimer() {
    timer.stop(); // stop the timer
}

void HCSR04::startMeasurement() {
    /** Start the measurement by sending the 10us trigger pulse. */
    trigger = 1;
    wait_us(10);
    trigger = 0;
    
    /** Wait for the sensor to finish measurement (generate rise and fall interrupts).
     *  Minimum wait time is determined by maximum measurement distance of 400 cm.
     *  t_min = 400 * 58 = 23200 us = 23.2 ms */
    wait_ms(25); 
    
    /** calculate the distance in cm */
    distance = timer.read() * 1e6 / 58;
    timer.reset(); // reset the timer to 0 after storing the distance
}

float HCSR04::getDistance_cm() {
    startMeasurement();
    return distance;
}