// ============================================================
// STICKMAN CONTROLLER
//
// GPT never moves pixels.
//
// It can only select an ACTION.
//
// This controller translates:
//
// ACTION
//   ↓
// joint target angles
//
// ============================================================

class StickmanController {

  Stickman body;


  String currentAction =
    "IDLE";


  float actionTime =
    0;


  StickmanController(
    Stickman body
  ) {

    this.body =
      body;
  }


  // ==========================================================
  // COMMAND
  // ==========================================================

  void commandAction(
    String action
  ) {

    currentAction =
      action;


    actionTime =
      0;


    println();
    println(
      "[CONTROLLER] ACTION = "
      + action
    );


    // Start from neutral
    neutralPose();


    // --------------------------------------------------------
    // Raise Left Arm
    // --------------------------------------------------------

    if (
      action.equals(
        "RAISE_LEFT_ARM"
      )
    ) {

      body.leftShoulderMotor
        .setOffsetDegrees(
          72
        );


      body.leftElbowMotor
        .setOffsetDegrees(
          -18
        );
    }


    // --------------------------------------------------------
    // Raise Right Arm
    // --------------------------------------------------------

    else if (
      action.equals(
        "RAISE_RIGHT_ARM"
      )
    ) {

      body.rightShoulderMotor
        .setOffsetDegrees(
          -72
        );


      body.rightElbowMotor
        .setOffsetDegrees(
          18
        );
    }


    // --------------------------------------------------------
    // Raise Both
    // --------------------------------------------------------

    else if (
      action.equals(
        "RAISE_BOTH_ARMS"
      )
    ) {

      body.leftShoulderMotor
        .setOffsetDegrees(
          72
        );


      body.rightShoulderMotor
        .setOffsetDegrees(
          -72
        );


      body.leftElbowMotor
        .setOffsetDegrees(
          -15
        );


      body.rightElbowMotor
        .setOffsetDegrees(
          15
        );
    }


    // --------------------------------------------------------
    // Wave Right
    // --------------------------------------------------------

    else if (
      action.equals(
        "WAVE_RIGHT"
      )
    ) {

      body.rightShoulderMotor
        .setOffsetDegrees(
          -78
        );


      body.rightElbowMotor
        .setOffsetDegrees(
          45
        );
    }


    // --------------------------------------------------------
    // Lower
    // --------------------------------------------------------

    else if (
      action.equals(
        "LOWER_ARMS"
      )
    ) {

      neutralPose();
    }


    // --------------------------------------------------------
    // Idle
    // --------------------------------------------------------

    else {

      currentAction =
        "IDLE";

      neutralPose();
    }
  }


  // ==========================================================
  // UPDATE
  // ==========================================================

  void update(
    float dt
  ) {

    actionTime +=
      dt;


    // --------------------------------------------------------
    // Dynamic wave
    // --------------------------------------------------------

    if (
      currentAction.equals(
        "WAVE_RIGHT"
      )
    ) {

      float wave =
        sin(
          actionTime
          * 7.5
        );


      body.rightElbowMotor
        .setOffsetDegrees(
          45
          +
          wave * 28
        );
    }


    // --------------------------------------------------------
    // Motor target smoothing
    // --------------------------------------------------------

    body.leftShoulderMotor
      .update(
        dt
      );


    body.rightShoulderMotor
      .update(
        dt
      );


    body.leftElbowMotor
      .update(
        dt
      );


    body.rightElbowMotor
      .update(
        dt
      );


    body.leftHipMotor
      .update(
        dt
      );


    body.rightHipMotor
      .update(
        dt
      );


    body.leftKneeMotor
      .update(
        dt
      );


    body.rightKneeMotor
      .update(
        dt
      );
  }


  // ==========================================================
  // NEUTRAL
  // ==========================================================

  void neutralPose() {

    body.leftShoulderMotor
      .setNeutral();


    body.rightShoulderMotor
      .setNeutral();


    body.leftElbowMotor
      .setNeutral();


    body.rightElbowMotor
      .setNeutral();


    body.leftHipMotor
      .setNeutral();


    body.rightHipMotor
      .setNeutral();


    body.leftKneeMotor
      .setNeutral();


    body.rightKneeMotor
      .setNeutral();
  }
}
