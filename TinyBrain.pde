class TinyBrain {

  int inputCount;
  int hiddenCount;
  int outputCount;

  float[][] weightsInputHidden;
  float[][] weightsHiddenOutput;

  float[] biasHidden;
  float[] biasOutput;


  TinyBrain(
    int inputCount,
    int hiddenCount,
    int outputCount
  ) {

    this.inputCount = inputCount;
    this.hiddenCount = hiddenCount;
    this.outputCount = outputCount;

    weightsInputHidden =
      new float[hiddenCount][inputCount];

    weightsHiddenOutput =
      new float[outputCount][hiddenCount];

    biasHidden =
      new float[hiddenCount];

    biasOutput =
      new float[outputCount];

    randomize();
  }


  void randomize() {

    // Input → Hidden
    for (int h = 0; h < hiddenCount; h++) {

      for (int i = 0; i < inputCount; i++) {

        weightsInputHidden[h][i] =
          random(-1.0, 1.0);
      }

      biasHidden[h] =
        random(-1.0, 1.0);
    }


    // Hidden → Output
    for (int o = 0; o < outputCount; o++) {

      for (int h = 0; h < hiddenCount; h++) {

        weightsHiddenOutput[o][h] =
          random(-1.0, 1.0);
      }

      biasOutput[o] =
        random(-1.0, 1.0);
    }
  }


  float[] forward(float[] input) {

    if (input.length != inputCount) {

      println(
        "[TinyBrain Error] Expected " +
        inputCount +
        " inputs but received " +
        input.length
      );

      return null;
    }


    // --------------------------
    // Hidden Layer
    // --------------------------

    float[] hidden =
      new float[hiddenCount];

    for (int h = 0; h < hiddenCount; h++) {

      float sum = biasHidden[h];

      for (int i = 0; i < inputCount; i++) {

        sum +=
          input[i] *
          weightsInputHidden[h][i];
      }

      hidden[h] = tanh(sum);
    }


    // --------------------------
    // Output Layer
    // --------------------------

    float[] output =
      new float[outputCount];

    for (int o = 0; o < outputCount; o++) {

      float sum = biasOutput[o];

      for (int h = 0; h < hiddenCount; h++) {

        sum +=
          hidden[h] *
          weightsHiddenOutput[o][h];
      }

      output[o] = tanh(sum);
    }

    return output;
  }


  float tanh(float x) {

    return
      (float)Math.tanh(x);
  }
}
