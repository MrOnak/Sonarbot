#ifndef HCSR04_H_TVZMT
#define HCSR04_H_TVZMT

/** A distance measurement class using ultrasonic sensor HC-SR04.
 *  
 * Example of use:
 * @code
 * #include "mbed.h"
 * #include "HCSR04.h"
 *
 * Serial pc(USBTX, USBRX);    // communication with terminal
 * 
 * int main() {
 *     HCSR04 sensor(p5, p7);     // instantiate the sensor object
 *     while(1) {
 *         pc.printf("Distance: %5.1f cm\r", sensor.getDistance_cm());
 *         wait_ms(975); // print the result every 1 second
 *     }
 * }
 * @endcode
 */
class HCSR04 {
    
    public:
    
    /** Receives two PinName variables.
     * @param echoPin mbed pin to which the echo signal is connected to
     * @param triggerPin mbed pin to which the trigger signal is connected to
     */
    HCSR04(PinName echoPin, PinName triggerPin);
    
    /** Calculates the distance in cm, with the calculation time of 25 ms.
     * @returns distance of the measuring object in cm.
     */
    float getDistance_cm();
    
    private:
    
    InterruptIn echo;       // echo pin
    DigitalOut trigger;     // trigger pin
    Timer timer;            // echo pulsewidth measurement
    float distance;         // store the distance in cm
    
    /** Start the timer. */
    void startTimer();
    
    /** Stop the timer. */
    void stopTimer();
    
    /** Initialization. */
    void init();
    
    /** Start the measurement. */
    void startMeasurement();
};

#endif