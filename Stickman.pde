// ============================================================
// PHYSICS WORLD
// ============================================================

class PhysicsWorld {

  PVector gravity;


  float floorY;


  float fixedDelta =
    1.0 / 120.0;


  float accumulator =
    0;


  int solverIterations =
    10;


  boolean trainingHarness =
    true;


  Stickman stickman;


  PhysicsWorld() {

    gravity =
      new PVector(
        0,
        1250
      );


    floorY =
      530;


    reset();
  }


  // ----------------------------------------------------------
  // Reset
  // ----------------------------------------------------------

  void reset() {

    stickman =
      new Stickman(
        420,
        floorY
      );


    println(
      "[WORLD] Stickman reset."
    );
  }


  // ----------------------------------------------------------
  // Update
  // ----------------------------------------------------------

  void update(
    float deltaTime
  ) {

    accumulator +=
      deltaTime;


    int safety =
      0;


    while (
      accumulator >= fixedDelta
      &&
      safety < 8
    ) {

      stepPhysics(
        fixedDelta
      );


      accumulator -=
        fixedDelta;


      safety++;
    }
  }


  // ----------------------------------------------------------
  // Physics Step
  // ----------------------------------------------------------

  void stepPhysics(
    float dt
  ) {

    stickman.controller.update(
      dt
    );


    // Integrate particles
    for (
      Particle p
      :
      stickman.particles
    ) {

      p.integrate(
        dt,
        gravity
      );
    }


    // Solve physical constraints
    for (
      int iteration = 0;
      iteration < solverIterations;
      iteration++
    ) {

      // Bone lengths
      for (
        DistanceConstraint constraint
        :
        stickman.distanceConstraints
      ) {

        constraint.solve();
      }


      // Joint motors
      stickman.solveMotors();


      // Temporary body harness
      if (
        trainingHarness
      ) {

        stickman.neckAnchor.solve();
        stickman.pelvisAnchor.solve();
      }


      // Ground
      solveGroundCollision();
    }
  }


  // ----------------------------------------------------------
  // Ground
  // ----------------------------------------------------------

  void solveGroundCollision() {

    for (
      Particle p
      :
      stickman.particles
    ) {

      float bottom =
        floorY
        - p.radius;


      if (
        p.pos.y > bottom
      ) {

        p.pos.y =
          bottom;


        // Horizontal friction
        float velocityX =
          p.pos.x
          - p.prev.x;


        p.prev.x =
          p.pos.x
          -
          velocityX * 0.65;


        // Remove downward velocity
        if (
          p.prev.y < p.pos.y
        ) {

          p.prev.y =
            p.pos.y;
        }
      }
    }
  }


  // ----------------------------------------------------------
  // Draw
  // ----------------------------------------------------------

  void drawWorld() {

    // Floor
    stroke(
      100
    );

    strokeWeight(
      2
    );


    line(
      0,
      floorY,
      panelX,
      floorY
    );


    fill(
      130
    );

    textSize(
      12
    );


    text(
      "GROUND",
      25,
      floorY + 22
    );


    // Gravity arrow
    stroke(
      100
    );

    line(
      70,
      110,
      70,
      170
    );


    line(
      70,
      170,
      62,
      158
    );


    line(
      70,
      170,
      78,
      158
    );


    fill(
      150
    );

    text(
      "GRAVITY",
      42,
      95
    );


    // Stickman
    stickman.draw();
  }


  // ----------------------------------------------------------
  // Telemetry
  // ----------------------------------------------------------

  JSONObject getTelemetry() {

    return stickman.getTelemetry(
      trainingHarness
    );
  }
}


// ============================================================
// STICKMAN
// ============================================================

class Stickman {

  int id =
    1;


  ArrayList<Particle>
    particles;


  ArrayList<DistanceConstraint>
    distanceConstraints;


  // ----------------------------------------------------------
  // Body
  // ----------------------------------------------------------

  Particle head;

  Particle neck;

  Particle leftShoulder;
  Particle rightShoulder;

  Particle pelvis;

  Particle leftElbow;
  Particle rightElbow;

  Particle leftHand;
  Particle rightHand;

  Particle leftKnee;
  Particle rightKnee;

  Particle leftFoot;
  Particle rightFoot;


  // ----------------------------------------------------------
  // Motors
  // ----------------------------------------------------------

  JointMotor leftShoulderMotor;
  JointMotor rightShoulderMotor;

  JointMotor leftElbowMotor;
  JointMotor rightElbowMotor;

  JointMotor leftHipMotor;
  JointMotor rightHipMotor;

  JointMotor leftKneeMotor;
  JointMotor rightKneeMotor;


  // ----------------------------------------------------------
  // Harness
  // ----------------------------------------------------------

  AnchorConstraint neckAnchor;

  AnchorConstraint pelvisAnchor;


  // ----------------------------------------------------------
  // Controller
  // ----------------------------------------------------------

  StickmanController controller;


  Stickman(
    float centerX,
    float groundY
  ) {

    particles =
      new ArrayList<Particle>();


    distanceConstraints =
      new ArrayList<DistanceConstraint>();


    // ========================================================
    // Initial body
    // ========================================================

    head =
      createParticle(
        centerX,
        groundY - 360,
        16
      );


    neck =
      createParticle(
        centerX,
        groundY - 325,
        5
      );


    leftShoulder =
      createParticle(
        centerX - 32,
        groundY - 300,
        5
      );


    rightShoulder =
      createParticle(
        centerX + 32,
        groundY - 300,
        5
      );


    pelvis =
      createParticle(
        centerX,
        groundY - 220,
        7
      );


    leftElbow =
      createParticle(
        centerX - 67,
        groundY - 255,
        5
      );


    rightElbow =
      createParticle(
        centerX + 67,
        groundY - 255,
        5
      );


    leftHand =
      createParticle(
        centerX - 72,
        groundY - 195,
        7
      );


    rightHand =
      createParticle(
        centerX + 72,
        groundY - 195,
        7
      );


    leftKnee =
      createParticle(
        centerX - 20,
        groundY - 115,
        6
      );


    rightKnee =
      createParticle(
        centerX + 20,
        groundY - 115,
        6
      );


    leftFoot =
      createParticle(
        centerX - 24,
        groundY - 12,
        8
      );


    rightFoot =
      createParticle(
        centerX + 24,
        groundY - 12,
        8
      );


    // ========================================================
    // Bone constraints
    // ========================================================

    addBone(
      head,
      neck
    );


    // Torso structure
    addBone(
      neck,
      leftShoulder
    );

    addBone(
      neck,
      rightShoulder
    );

    addBone(
      leftShoulder,
      rightShoulder
    );

    addBone(
      neck,
      pelvis
    );

    addBone(
      leftShoulder,
      pelvis
    );

    addBone(
      rightShoulder,
      pelvis
    );


    // Left arm
    addBone(
      leftShoulder,
      leftElbow
    );

    addBone(
      leftElbow,
      leftHand
    );


    // Right arm
    addBone(
      rightShoulder,
      rightElbow
    );

    addBone(
      rightElbow,
      rightHand
    );


    // Left leg
    addBone(
      pelvis,
      leftKnee
    );

    addBone(
      leftKnee,
      leftFoot
    );


    // Right leg
    addBone(
      pelvis,
      rightKnee
    );

    addBone(
      rightKnee,
      rightFoot
    );


    // ========================================================
    // Joint Motors
    // ========================================================

    leftShoulderMotor =
      new JointMotor(
        pelvis,
        leftShoulder,
        leftElbow,
        0.22
      );


    rightShoulderMotor =
      new JointMotor(
        pelvis,
        rightShoulder,
        rightElbow,
        0.22
      );


    leftElbowMotor =
      new JointMotor(
        leftShoulder,
        leftElbow,
        leftHand,
        0.18
      );


    rightElbowMotor =
      new JointMotor(
        rightShoulder,
        rightElbow,
        rightHand,
        0.18
      );


    leftHipMotor =
      new JointMotor(
        neck,
        pelvis,
        leftKnee,
        0.12
      );


    rightHipMotor =
      new JointMotor(
        neck,
        pelvis,
        rightKnee,
        0.12
      );


    leftKneeMotor =
      new JointMotor(
        pelvis,
        leftKnee,
        leftFoot,
        0.10
      );


    rightKneeMotor =
      new JointMotor(
        pelvis,
        rightKnee,
        rightFoot,
        0.10
      );


    // ========================================================
    // Harness
    // ========================================================

    neckAnchor =
      new AnchorConstraint(
        neck,
        0.045
      );


    pelvisAnchor =
      new AnchorConstraint(
        pelvis,
        0.055
      );


    // ========================================================
    // Controller
    // ========================================================

    controller =
      new StickmanController(
        this
      );
  }


  // ----------------------------------------------------------
  // Particle
  // ----------------------------------------------------------

  Particle createParticle(
    float x,
    float y,
    float radius
  ) {

    Particle particle =
      new Particle(
        x,
        y,
        radius
      );


    particles.add(
      particle
    );


    return particle;
  }


  // ----------------------------------------------------------
  // Bone
  // ----------------------------------------------------------

  void addBone(
    Particle a,
    Particle b
  ) {

    distanceConstraints.add(
      new DistanceConstraint(
        a,
        b,
        1.0
      )
    );
  }


  // ----------------------------------------------------------
  // Motor solver
  // ----------------------------------------------------------

  void solveMotors() {

    leftShoulderMotor.solve();
    rightShoulderMotor.solve();

    leftElbowMotor.solve();
    rightElbowMotor.solve();

    leftHipMotor.solve();
    rightHipMotor.solve();

    leftKneeMotor.solve();
    rightKneeMotor.solve();
  }


  // ----------------------------------------------------------
  // Torso tilt
  // ----------------------------------------------------------

  float getTorsoTiltDegrees() {

    float dx =
      pelvis.pos.x
      - neck.pos.x;


    float dy =
      pelvis.pos.y
      - neck.pos.y;


    return degrees(
      atan2(
        dx,
        dy
      )
    );
  }


  // ----------------------------------------------------------
  // Foot contacts
  // ----------------------------------------------------------

  boolean leftFootOnGround() {

    return leftFoot.pos.y
      >= world.floorY
      - leftFoot.radius
      - 2;
  }


  boolean rightFootOnGround() {

    return rightFoot.pos.y
      >= world.floorY
      - rightFoot.radius
      - 2;
  }


  // ----------------------------------------------------------
  // Draw
  // ----------------------------------------------------------

  void draw() {

    stroke(
      235
    );

    strokeWeight(
      6
    );

    strokeCap(
      ROUND
    );


    // Torso
    lineBetween(
      neck,
      pelvis
    );


    lineBetween(
      leftShoulder,
      rightShoulder
    );


    // Arms
    lineBetween(
      leftShoulder,
      leftElbow
    );

    lineBetween(
      leftElbow,
      leftHand
    );


    lineBetween(
      rightShoulder,
      rightElbow
    );

    lineBetween(
      rightElbow,
      rightHand
    );


    // Legs
    lineBetween(
      pelvis,
      leftKnee
    );

    lineBetween(
      leftKnee,
      leftFoot
    );


    lineBetween(
      pelvis,
      rightKnee
    );

    lineBetween(
      rightKnee,
      rightFoot
    );


    // Head connection
    lineBetween(
      head,
      neck
    );


    // Head
    noFill();

    stroke(
      235
    );

    strokeWeight(
      5
    );


    ellipse(
      head.pos.x,
      head.pos.y,
      38,
      38
    );


    // Joints
    drawJoint(
      leftShoulder
    );

    drawJoint(
      rightShoulder
    );

    drawJoint(
      leftElbow
    );

    drawJoint(
      rightElbow
    );

    drawJoint(
      pelvis
    );

    drawJoint(
      leftKnee
    );

    drawJoint(
      rightKnee
    );


    // ID
    fill(
      110,
      220,
      255
    );

    noStroke();

    textSize(
      14
    );


    text(
      "ID 001",
      head.pos.x - 25,
      head.pos.y - 40
    );


    // Harness visualization
    if (
      world.trainingHarness
    ) {

      stroke(
        90,
        140,
        200,
        80
      );

      strokeWeight(
        1
      );


      line(
        neck.pos.x,
        80,
        neck.pos.x,
        neck.pos.y
      );


      line(
        pelvis.pos.x,
        80,
        pelvis.pos.x,
        pelvis.pos.y
      );
    }
  }


  void lineBetween(
    Particle a,
    Particle b
  ) {

    line(
      a.pos.x,
      a.pos.y,
      b.pos.x,
      b.pos.y
    );
  }


  void drawJoint(
    Particle particle
  ) {

    noStroke();

    fill(
      90,
      190,
      255
    );


    ellipse(
      particle.pos.x,
      particle.pos.y,
      9,
      9
    );
  }


  // ==========================================================
  // TELEMETRY
  // ==========================================================

  JSONObject getTelemetry(
    boolean harnessEnabled
  ) {

    JSONObject root =
      new JSONObject();


    root.setInt(
      "agent_id",
      id
    );


    root.setInt(
      "time_ms",
      millis()
    );


    root.setString(
      "current_action",
      controller.currentAction
    );


    root.setBoolean(
      "training_harness",
      harnessEnabled
    );


    root.setFloat(
      "torso_tilt_deg",
      getTorsoTiltDegrees()
    );


    // --------------------------------------------------------
    // Joint angles
    // --------------------------------------------------------

    JSONObject joints =
      new JSONObject();


    joints.setFloat(
      "left_shoulder_deg",
      degrees(
        leftShoulderMotor.currentAngle()
      )
    );


    joints.setFloat(
      "right_shoulder_deg",
      degrees(
        rightShoulderMotor.currentAngle()
      )
    );


    joints.setFloat(
      "left_elbow_deg",
      degrees(
        leftElbowMotor.currentAngle()
      )
    );


    joints.setFloat(
      "right_elbow_deg",
      degrees(
        rightElbowMotor.currentAngle()
      )
    );


    joints.setFloat(
      "left_hip_deg",
      degrees(
        leftHipMotor.currentAngle()
      )
    );


    joints.setFloat(
      "right_hip_deg",
      degrees(
        rightHipMotor.currentAngle()
      )
    );


    joints.setFloat(
      "left_knee_deg",
      degrees(
        leftKneeMotor.currentAngle()
      )
    );


    joints.setFloat(
      "right_knee_deg",
      degrees(
        rightKneeMotor.currentAngle()
      )
    );


    root.setJSONObject(
      "joints",
      joints
    );


    // --------------------------------------------------------
    // Positions
    // --------------------------------------------------------

    JSONObject positions =
      new JSONObject();


    positions.setJSONObject(
      "left_hand",
      vectorJSON(
        leftHand.pos
      )
    );


    positions.setJSONObject(
      "right_hand",
      vectorJSON(
        rightHand.pos
      )
    );


    positions.setJSONObject(
      "left_foot",
      vectorJSON(
        leftFoot.pos
      )
    );


    positions.setJSONObject(
      "right_foot",
      vectorJSON(
        rightFoot.pos
      )
    );


    positions.setJSONObject(
      "head",
      vectorJSON(
        head.pos
      )
    );


    root.setJSONObject(
      "positions",
      positions
    );


    // --------------------------------------------------------
    // Contact
    // --------------------------------------------------------

    JSONObject contact =
      new JSONObject();


    contact.setBoolean(
      "left_foot_ground",
      leftFootOnGround()
    );


    contact.setBoolean(
      "right_foot_ground",
      rightFootOnGround()
    );


    root.setJSONObject(
      "contact",
      contact
    );


    return root;
  }


  JSONObject vectorJSON(
    PVector value
  ) {

    JSONObject json =
      new JSONObject();


    json.setFloat(
      "x",
      value.x
    );


    json.setFloat(
      "y",
      value.y
    );


    return json;
  }
}
