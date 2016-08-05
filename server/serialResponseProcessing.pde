void processCmdCompletion(String[] list) {
  if (list[0].charAt(1) == 'K') {
    println("processing for command " + command + " complete");
    command = CMD_NOOP;
  }
}

void processCmdBatteryResponse(String[] list) {
  if (list[0].charAt(1) == 'B') {
    float v = convertStringToFloat(list[1]);
    println(v);
    bot.setVoltage(v);
  }
}

void processCmdSonarPingResponse(String[] list) {  
  if (list[0].charAt(1) == 'P') {
    int angle = convertStringToInt(list[1]);
    int range = convertStringToInt(list[2]);
    println("angle: "+ angle + " range: " + range);
    
    if (command == CMD_SONARPING) {
      command = CMD_NOOP;
    }
  } else if (list[0].charAt(1) == 'K' && command == CMD_SONARSWEEP) {
    command = CMD_NOOP;
  }
}

void processReset(String[] list) {
  if (list[0].equals("#RST")) {
    command = CMD_NOOP;
  }
  println("processReset(): '" + list[0] + "'");
}