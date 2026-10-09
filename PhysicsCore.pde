// ============================================================
// PARTICLE
// ============================================================

class Particle {

  PVector pos;
  PVector prev;

  float radius;
  float invMass;

  Particle(
    float x,
    float y,
    float radius
  ) {

    pos =
      new PVector(
        x,
        y
      );

    prev =
      pos.copy();

    this.radius =
      radius;

    invMass =
      1.0;
  }


  void integrate(
    float dt,
    PVector gravity
  ) {

    if (
      invMass <= 0
    ) {

      return;
    }


    PVector velocity =
      PVector.sub(
        pos,
        prev
      );


    velocity.mult(
      0.994
    );


    PVector oldPosition =
      pos.copy();


    pos.add(
      velocity
    );


    pos.add(
      gravity.x * dt * dt,
      gravity.y * dt * dt
    );


    prev.set(
      oldPosition
    );
  }


  void move(
    float x,
    float y
  ) {

    pos.add(
      x,
      y
    );
  }
}


// ============================================================
// DISTANCE CONSTRAINT
// ============================================================

class DistanceConstraint {

  Particle a;
  Particle b;

  float length;
  float stiffness;


  DistanceConstraint(
    Particle a,
    Particle b,
    float stiffness
  ) {

    this.a =
      a;

    this.b =
      b;

    this.stiffness =
      stiffness;


    length =
      PVector.dist(
        a.pos,
        b.pos
      );
  }


  void solve() {

    PVector delta =
      PVector.sub(
        b.pos,
        a.pos
      );


    float distance =
      delta.mag();


    if (
      distance < 0.0001
    ) {

      return;
    }


    float error =
      (
        distance
        - length
      )
      / distance;


    float totalMass =
      a.invMass
      + b.invMass;


    if (
      totalMass <= 0
    ) {

      return;
    }


    delta.mult(
      error
      * stiffness
    );


    float aWeight =
      a.invMass
      / totalMass;


    float bWeight =
      b.invMass
      / totalMass;


    a.pos.add(
      delta.x * aWeight,
      delta.y * aWeight
    );


    b.pos.sub(
      delta.x * bWeight,
      delta.y * bWeight
    );
  }
}


// ============================================================
// ANCHOR CONSTRAINT
//
// This is the temporary training harness.
// It keeps the torso upright while we test limbs.
//
// Later:
// trainingHarness = false
//
// and the agent must learn balance by itself.
// ============================================================

class AnchorConstraint {

  Particle particle;

  PVector anchor;

  float stiffness;


  AnchorConstraint(
    Particle particle,
    float stiffness
  ) {

    this.particle =
      particle;

    this.stiffness =
      stiffness;

    anchor =
      particle.pos.copy();
  }


  void solve() {

    float dx =
      anchor.x
      - particle.pos.x;

    float dy =
      anchor.y
      - particle.pos.y;


    particle.pos.add(
      dx * stiffness,
      dy * stiffness
    );
  }
}


// ============================================================
// JOINT MOTOR
//
// IMPORTANT:
// GPT does NOT draw limbs.
//
// GPT/controller changes commandAngle.
// This motor physically rotates the connected limb.
//
// A ---- B ---- C
//
// B = joint
//
// Example:
//
// pelvis → shoulder → elbow
//
// ============================================================

class JointMotor {

  Particle a;
  Particle b;
  Particle c;


  float neutralAngle;

  float targetAngle;
  float commandAngle;


  float strength;

  float maxSpeed;

  float lastError;


  JointMotor(
    Particle a,
    Particle b,
    Particle c,
    float strength
  ) {

    this.a =
      a;

    this.b =
      b;

    this.c =
      c;


    this.strength =
      strength;


    neutralAngle =
      currentAngle();


    targetAngle =
      neutralAngle;

    commandAngle =
      neutralAngle;


    maxSpeed =
      radians(
        220
      );


    lastError =
      0;
  }


  // ----------------------------------------------------------
  // Current angle
  // ----------------------------------------------------------

  float currentAngle() {

    PVector v1 =
      PVector.sub(
        a.pos,
        b.pos
      );


    PVector v2 =
      PVector.sub(
        c.pos,
        b.pos
      );


    float cross =
      v1.x * v2.y
      -
      v1.y * v2.x;


    float dot =
      v1.dot(
        v2
      );


    return atan2(
      cross,
      dot
    );
  }


  // ----------------------------------------------------------
  // Command
  // ----------------------------------------------------------

  void setOffsetDegrees(
    float offset
  ) {

    commandAngle =
      neutralAngle
      +
      radians(
        offset
      );
  }


  void setNeutral() {

    commandAngle =
      neutralAngle;
  }


  // ----------------------------------------------------------
  // Smooth target motion
  // ----------------------------------------------------------

  void update(
    float dt
  ) {

    float difference =
      wrapAngle(
        commandAngle
        - targetAngle
      );


    float maxMove =
      maxSpeed
      * dt;


    difference =
      constrain(
        difference,
        -maxMove,
        maxMove
      );


    targetAngle +=
      difference;
  }


  // ----------------------------------------------------------
  // Physics motor
  // ----------------------------------------------------------

  void solve() {

    float current =
      currentAngle();


    float error =
      wrapAngle(
        targetAngle
        - current
      );


    lastError =
      error;


    float correction =
      error
      * strength;


    correction =
      constrain(
        correction,
        radians(-8),
        radians(8)
      );


    rotateParticleAround(
      c,
      b.pos,
      correction
    );
  }


  float getEffort() {

    return abs(
      lastError
    );
  }
}


// ============================================================
// HELPER
// ============================================================

float wrapAngle(
  float value
) {

  while (
    value > PI
  ) {

    value -=
      TWO_PI;
  }


  while (
    value < -PI
  ) {

    value +=
      TWO_PI;
  }


  return value;
}


// ============================================================
// ROTATE PARTICLE
// ============================================================

void rotateParticleAround(
  Particle particle,
  PVector center,
  float angle
) {

  float dx =
    particle.pos.x
    - center.x;

  float dy =
    particle.pos.y
    - center.y;


  float cosA =
    cos(
      angle
    );

  float sinA =
    sin(
      angle
    );


  float newX =
    dx * cosA
    -
    dy * sinA;


  float newY =
    dx * sinA
    +
    dy * cosA;


  float targetX =
    center.x
    + newX;

  float targetY =
    center.y
    + newY;


  float moveX =
    targetX
    - particle.pos.x;

  float moveY =
    targetY
    - particle.pos.y;


  // Move current and previous position together.
  // This prevents explosive artificial velocity.

  particle.pos.add(
    moveX,
    moveY
  );


  particle.prev.add(
    moveX,
    moveY
  );
}
