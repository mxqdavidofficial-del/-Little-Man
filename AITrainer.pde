// ============================================================
// ACTION PLAN
// ============================================================

class ActionPlan {

  String action;

  float duration;

  String message;


  ActionPlan(
    String action,
    float duration,
    String message
  ) {

    this.action =
      action;

    this.duration =
      duration;

    this.message =
      message;
  }
}


// ============================================================
// AI TRAINER
// ============================================================

class AITrainer {

  PhysicsWorld world;

  OpenAIClient openAI;


  volatile boolean busy =
    false;


  volatile String status =
    "READY";


  volatile String lastUserCommand =
    "等待用户指令";


  volatile String lastPlanMessage =
    "尚未执行任务";


  volatile String lastSummary =
    "等待第一次实验。";


  volatile ActionPlan pendingPlan =
    null;


  volatile String pendingSummary =
    null;


  String telemetryBefore =
    "";


  String telemetryAfter =
    "";


  int actionEndTime =
    0;


  boolean summaryRequested =
    false;


  AITrainer(
    PhysicsWorld world,
    OpenAIClient openAI
  ) {

    this.world =
      world;

    this.openAI =
      openAI;
  }


  // ==========================================================
  // USER COMMAND
  // ==========================================================

  void askUserForCommand() {

    if (
      busy
    ) {

      return;
    }


    String input =
      JOptionPane.showInputDialog(
        null,
        "告诉 GPT 你希望火柴人做什么：",
        "Physical AI Trainer",
        JOptionPane.PLAIN_MESSAGE
      );


    if (
      input == null
    ) {

      return;
    }


    input =
      input.trim();


    if (
      input.length() == 0
    ) {

      return;
    }


    lastUserCommand =
      input;


    requestPlan(
      input
    );
  }


  // ==========================================================
  // REQUEST PLAN
  // ==========================================================

  void requestPlan(
    final String command
  ) {

    busy =
      true;


    status =
      "GPT 正在理解指令";


    lastPlanMessage =
      "正在生成动作计划...";


    telemetryBefore =
      world
      .getTelemetry()
      .toString();


    println();
    println("======================================");
    println("[USER]");
    println(command);

    println();
    println("[TELEMETRY BEFORE]");
    println(telemetryBefore);

    println();
    println("[GPT] Planning...");
    println("======================================");


    new Thread(
      new Runnable() {

        public void run() {

          try {

            ActionPlan plan =
              openAI.planAction(
                command,
                telemetryBefore
              );


            pendingPlan =
              plan;

          }

          catch (
            Exception exception
          ) {

            exception
              .printStackTrace();


            status =
              "ERROR";


            lastPlanMessage =
              "GPT 请求失败";


            busy =
              false;
          }
        }
      }
    ).start();
  }


  // ==========================================================
  // UPDATE
  // ==========================================================

  void update() {

    // --------------------------------------------------------
    // Receive plan
    // --------------------------------------------------------

    if (
      pendingPlan != null
    ) {

      ActionPlan plan =
        pendingPlan;


      pendingPlan =
        null;


      println();
      println("[GPT PLAN]");
      println(
        "Action: "
        + plan.action
      );

      println(
        "Duration: "
        + plan.duration
      );

      println(
        "Message: "
        + plan.message
      );


      lastPlanMessage =
        plan.message;


      world
        .stickman
        .controller
        .commandAction(
          plan.action
        );


      actionEndTime =
        millis()
        +
        int(
          plan.duration
          * 1000
        );


      status =
        "执行动作";


      summaryRequested =
        false;
    }


    // --------------------------------------------------------
    // Action finished
    // --------------------------------------------------------

    if (
      busy
      &&
      status.equals(
        "执行动作"
      )
      &&
      millis() >= actionEndTime
      &&
      !summaryRequested
    ) {

      summaryRequested =
        true;


      telemetryAfter =
        world
        .getTelemetry()
        .toString();


      println();
      println("[TELEMETRY AFTER]");
      println(
        telemetryAfter
      );


      requestSummary();
    }


    // --------------------------------------------------------
    // Summary received
    // --------------------------------------------------------

    if (
      pendingSummary != null
    ) {

      lastSummary =
        pendingSummary;


      pendingSummary =
        null;


      status =
        "READY";


      busy =
        false;


      println();
      println("[GPT OBSERVATION]");
      println(
        lastSummary
      );

      println();
      println(
        "========== ROUND COMPLETE =========="
      );
    }
  }


  // ==========================================================
  // SUMMARY
  // ==========================================================

  void requestSummary() {

    status =
      "GPT 正在读取身体数据";


    new Thread(
      new Runnable() {

        public void run() {

          try {

            String result =
              openAI.summarizeMovement(
                lastUserCommand,
                telemetryBefore,
                telemetryAfter
              );


            pendingSummary =
              result;

          }

          catch (
            Exception exception
          ) {

            exception
              .printStackTrace();


            pendingSummary =
              "动作已经执行，但 GPT 总结失败。";
          }
        }
      }
    ).start();
  }
}
