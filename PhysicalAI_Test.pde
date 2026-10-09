import javax.swing.JOptionPane;

OpenAIClient openAI;

volatile String userPrompt = "";
volatile String gptReply = "No response yet.";

volatile String status = "READY";
volatile boolean waiting = false;


// =========================================
// SETUP
// =========================================

void setup() {

  size(900, 600);

  surface.setTitle(
    "Physical AI - GPT MVP"
  );

  openAI = new OpenAIClient();

  textFont(
    createFont("Arial", 18)
  );

  println("==========================");
  println("GPT INPUT / OUTPUT MVP");
  println("==========================");
}


// =========================================
// DRAW
// =========================================

void draw() {

  background(25);


  // -----------------------------------------
  // Title
  // -----------------------------------------

  fill(255);

  textSize(28);

  text(
    "Physical AI - GPT MVP",
    40,
    50
  );


  // -----------------------------------------
  // Status
  // -----------------------------------------

  textSize(16);

  if (status.equals("READY")) {

    fill(200);

  } else if (
    status.equals("SENDING...")
  ) {

    fill(255, 210, 80);

  } else if (
    status.equals("RECEIVED")
  ) {

    fill(100, 255, 140);

  } else {

    fill(255, 100, 100);
  }


  text(
    "STATUS: " + status,
    40,
    85
  );


  // -----------------------------------------
  // Ask button
  // -----------------------------------------

  if (waiting) {

    fill(70);

  } else {

    fill(70, 120, 220);
  }

  rect(
    40,
    110,
    180,
    55,
    10
  );


  fill(255);

  textSize(18);

  textAlign(
    CENTER,
    CENTER
  );

  if (waiting) {

    text(
      "WAITING...",
      130,
      137
    );

  } else {

    text(
      "ASK GPT",
      130,
      137
    );
  }


  textAlign(
    LEFT,
    TOP
  );


  // -----------------------------------------
  // User input panel
  // -----------------------------------------

  fill(40);

  rect(
    40,
    190,
    820,
    120,
    10
  );


  fill(180);

  textSize(14);

  text(
    "USER INPUT",
    60,
    205
  );


  fill(255);

  textSize(17);

  text(
    userPrompt,
    60,
    235,
    780,
    60
  );


  // -----------------------------------------
  // GPT output panel
  // -----------------------------------------

  fill(40);

  rect(
    40,
    335,
    820,
    220,
    10
  );


  fill(180);

  textSize(14);

  text(
    "GPT OUTPUT",
    60,
    350
  );


  fill(255);

  textSize(17);

  text(
    gptReply,
    60,
    380,
    780,
    150
  );
}


// =========================================
// MOUSE
// =========================================

void mousePressed() {

  // Button region
  if (
    mouseX >= 40 &&
    mouseX <= 220 &&
    mouseY >= 110 &&
    mouseY <= 165 &&
    !waiting
  ) {

    openInputWindow();
  }
}


// =========================================
// USER INPUT
// =========================================

void openInputWindow() {

  String input =
    JOptionPane.showInputDialog(
      null,
      "Send a message to GPT:",
      "GPT Input",
      JOptionPane.PLAIN_MESSAGE
    );


  // Cancel pressed
  if (input == null) {

    return;
  }


  input = input.trim();


  // Empty input
  if (input.length() == 0) {

    return;
  }


  userPrompt = input;

  gptReply = "";

  status = "SENDING...";

  waiting = true;


  // API must run in another thread.
  // Otherwise Processing window freezes.
  thread("sendPrompt");
}


// =========================================
// SEND TO GPT
// =========================================

void sendPrompt() {

  println();
  println("--------------------------");
  println("USER:");
  println(userPrompt);
  println("--------------------------");


  String result =
    openAI.ask(
      userPrompt
    );


  if (
    result != null &&
    result.length() > 0
  ) {

    gptReply = result;

    status = "RECEIVED";


    println();
    println("GPT:");
    println(result);

  } else {

    gptReply =
      "GPT returned no response.";

    status =
      "ERROR";

    println(
      "ERROR: No GPT response."
    );
  }


  waiting = false;
}
