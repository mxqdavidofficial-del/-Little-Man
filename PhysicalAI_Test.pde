import javax.swing.*;
import java.awt.Font;

import java.net.*;
import java.io.*;
import java.nio.charset.StandardCharsets;


// ============================================================
// PHYSICAL AI LAB
// MVP 01
//
// Human
//   ↓
// GPT Trainer
//   ↓
// Action Command
//   ↓
// Stickman Controller
//   ↓
// Joint Motor
//   ↓
// Physics World
//   ↓
// Telemetry
//   ↓
// GPT Summary
//
// ============================================================


PFont uiFont;

PhysicsWorld world;
OpenAIClient openAI;
AITrainer trainer;


int lastFrameMillis;


// ------------------------------------------------------------
// UI
// ------------------------------------------------------------

float panelX = 880;

float askButtonX = 910;
float askButtonY = 90;
float askButtonW = 320;
float askButtonH = 55;


// ============================================================
// SETUP
// ============================================================

void setup() {

  size(1280, 760, P2D);

  surface.setTitle(
    "Physical AI Laboratory"
  );


  // ----------------------------------------------------------
  // Chinese Font
  // ----------------------------------------------------------

  uiFont =
    createFont(
      "Microsoft YaHei",
      17,
      true
    );

  textFont(uiFont);


  // Swing Chinese font
  Font swingFont =
    new Font(
      "Microsoft YaHei",
      Font.PLAIN,
      16
    );

  UIManager.put(
    "OptionPane.messageFont",
    swingFont
  );

  UIManager.put(
    "TextField.font",
    swingFont
  );

  UIManager.put(
    "Button.font",
    swingFont
  );


  // ----------------------------------------------------------
  // Systems
  // ----------------------------------------------------------

  world =
    new PhysicsWorld();

  openAI =
    new OpenAIClient();

  trainer =
    new AITrainer(
      world,
      openAI
    );


  lastFrameMillis =
    millis();


  println();
  println("======================================");
  println("PHYSICAL AI LABORATORY");
  println("MVP 01");
  println("======================================");
  println();

  println("World: ONLINE");
  println("Physics: ONLINE");
  println("Stickman ID: 001");
  println("OpenAI Trainer: READY");

  println();
  println("Controls:");
  println("G = Ask GPT");
  println("1 = Raise Left Arm");
  println("2 = Raise Right Arm");
  println("3 = Raise Both Arms");
  println("4 = Wave Right Arm");
  println("0 = Neutral");
  println("H = Toggle Training Harness");
  println("R = Reset Body");
  println("T = Print Telemetry");
  println();
}


// ============================================================
// DRAW
// ============================================================

void draw() {

  int now =
    millis();

  float deltaTime =
    (now - lastFrameMillis)
    / 1000.0;

  lastFrameMillis =
    now;


  deltaTime =
    constrain(
      deltaTime,
      0,
      0.05
    );


  // ----------------------------------------------------------
  // Update
  // ----------------------------------------------------------

  world.update(
    deltaTime
  );

  trainer.update();


  // ----------------------------------------------------------
  // Draw
  // ----------------------------------------------------------

  background(22);

  drawLaboratory();

  world.drawWorld();

  drawControlPanel();
}


// ============================================================
// LAB BACKGROUND
// ============================================================

void drawLaboratory() {

  // Physical world area
  noStroke();

  fill(28);
  rect(
    0,
    0,
    panelX,
    height
  );


  // Side panel
  fill(18);

  rect(
    panelX,
    0,
    width - panelX,
    height
  );


  stroke(65);

  line(
    panelX,
    0,
    panelX,
    height
  );


  fill(255);

  textSize(24);

  text(
    "PHYSICAL AI LAB",
    30,
    35
  );


  fill(150);

  textSize(13);

  text(
    "Embodied Agent Testbed / MVP 01",
    30,
    65
  );
}


// ============================================================
// CONTROL PANEL
// ============================================================

void drawControlPanel() {

  fill(255);

  textSize(22);

  text(
    "AI TRAINER",
    910,
    42
  );


  fill(145);

  textSize(12);

  text(
    "GPT → Controller → Body → Telemetry → GPT",
    910,
    67
  );


  // ----------------------------------------------------------
  // Ask GPT Button
  // ----------------------------------------------------------

  if (
    trainer.busy
  ) {

    fill(60);

  } else {

    fill(
      65,
      115,
      210
    );
  }


  noStroke();

  rect(
    askButtonX,
    askButtonY,
    askButtonW,
    askButtonH,
    9
  );


  fill(255);

  textSize(17);

  textAlign(
    CENTER,
    CENTER
  );


  if (
    trainer.busy
  ) {

    text(
      "GPT 正在工作...",
      askButtonX + askButtonW / 2,
      askButtonY + askButtonH / 2
    );

  } else {

    text(
      "发送指令给 GPT",
      askButtonX + askButtonW / 2,
      askButtonY + askButtonH / 2
    );
  }


  textAlign(
    LEFT,
    BASELINE
  );


  // ----------------------------------------------------------
  // Status
  // ----------------------------------------------------------

  fill(38);

  rect(
    910,
    170,
    320,
    105,
    8
  );


  fill(160);

  textSize(12);

  text(
    "SYSTEM STATUS",
    930,
    195
  );


  if (
    trainer.busy
  ) {

    fill(
      255,
      200,
      80
    );

  } else {

    fill(
      100,
      240,
      140
    );
  }


  textSize(15);

  text(
    trainer.status,
    930,
    223
  );


  fill(190);

  textSize(13);

  text(
    "Action: "
    + world.stickman.controller.currentAction,
    930,
    250
  );


  // ----------------------------------------------------------
  // User Command
  // ----------------------------------------------------------

  fill(38);

  rect(
    910,
    292,
    320,
    105,
    8
  );


  fill(150);

  textSize(12);

  text(
    "USER COMMAND",
    930,
    317
  );


  fill(230);

  textSize(14);

  textLeading(21);

  text(
    trainer.lastUserCommand,
    930,
    338,
    280,
    50
  );


  // ----------------------------------------------------------
  // GPT Plan
  // ----------------------------------------------------------

  fill(38);

  rect(
    910,
    414,
    320,
    125,
    8
  );


  fill(150);

  textSize(12);

  text(
    "GPT PLAN",
    930,
    439
  );


  fill(230);

  textSize(14);

  textLeading(20);

  text(
    trainer.lastPlanMessage,
    930,
    462,
    280,
    60
  );


  // ----------------------------------------------------------
  // GPT Summary
  // ----------------------------------------------------------

  fill(38);

  rect(
    910,
    556,
    320,
    170,
    8
  );


  fill(150);

  textSize(12);

  text(
    "GPT OBSERVATION",
    930,
    581
  );


  fill(230);

  textSize(14);

  textLeading(20);

  text(
    trainer.lastSummary,
    930,
    605,
    280,
    100
  );


  // ----------------------------------------------------------
  // Telemetry panel
  // ----------------------------------------------------------

  drawTelemetryPanel();
}


// ============================================================
// TELEMETRY PANEL
// ============================================================

void drawTelemetryPanel() {

  Stickman s =
    world.stickman;


  fill(38);

  rect(
    30,
    555,
    820,
    170,
    8
  );


  fill(160);

  textSize(12);

  text(
    "LIVE TELEMETRY",
    50,
    580
  );


  fill(220);

  textSize(13);


  float torsoTilt =
    s.getTorsoTiltDegrees();


  text(
    "Torso Tilt: "
    + nf(torsoTilt, 1, 2)
    + "°",
    50,
    610
  );


  text(
    "Left Shoulder: "
    + nf(
      degrees(
        s.leftShoulderMotor.currentAngle()
      ),
      1,
      2
    )
    + "°",
    50,
    635
  );


  text(
    "Right Shoulder: "
    + nf(
      degrees(
        s.rightShoulderMotor.currentAngle()
      ),
      1,
      2
    )
    + "°",
    50,
    660
  );


  text(
    "Left Hand: "
    + nf(
      s.leftHand.pos.x,
      1,
      1
    )
    + ", "
    + nf(
      s.leftHand.pos.y,
      1,
      1
    ),
    330,
    610
  );


  text(
    "Right Hand: "
    + nf(
      s.rightHand.pos.x,
      1,
      1
    )
    + ", "
    + nf(
      s.rightHand.pos.y,
      1,
      1
    ),
    330,
    635
  );


  text(
    "Harness: "
    + world.trainingHarness,
    330,
    660
  );


  text(
    "Left Foot Contact: "
    + s.leftFootOnGround(),
    610,
    610
  );


  text(
    "Right Foot Contact: "
    + s.rightFootOnGround(),
    610,
    635
  );


  text(
    "FPS: "
    + nf(
      frameRate,
      1,
      1
    ),
    610,
    660
  );
}


// ============================================================
// INPUT
// ============================================================

void mousePressed() {

  if (
    mouseX >= askButtonX
    &&
    mouseX <= askButtonX + askButtonW
    &&
    mouseY >= askButtonY
    &&
    mouseY <= askButtonY + askButtonH
  ) {

    trainer.askUserForCommand();
  }
}


// ============================================================
// KEYBOARD
// ============================================================

void keyPressed() {

  if (
    key == 'g'
    ||
    key == 'G'
  ) {

    trainer.askUserForCommand();
  }


  if (
    key == '1'
  ) {

    world.stickman.controller.commandAction(
      "RAISE_LEFT_ARM"
    );
  }


  if (
    key == '2'
  ) {

    world.stickman.controller.commandAction(
      "RAISE_RIGHT_ARM"
    );
  }


  if (
    key == '3'
  ) {

    world.stickman.controller.commandAction(
      "RAISE_BOTH_ARMS"
    );
  }


  if (
    key == '4'
  ) {

    world.stickman.controller.commandAction(
      "WAVE_RIGHT"
    );
  }


  if (
    key == '0'
  ) {

    world.stickman.controller.commandAction(
      "IDLE"
    );
  }


  if (
    key == 'h'
    ||
    key == 'H'
  ) {

    world.trainingHarness =
      !world.trainingHarness;
  }


  if (
    key == 'r'
    ||
    key == 'R'
  ) {

    world.reset();
  }


  if (
    key == 't'
    ||
    key == 'T'
  ) {

    println();
    println("========== TELEMETRY ==========");
    println(
      world.getTelemetry().toString()
    );
    println("===============================");
  }
}
