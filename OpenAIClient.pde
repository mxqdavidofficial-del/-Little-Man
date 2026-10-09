// ============================================================
// OPENAI CLIENT
// ============================================================

class OpenAIClient {

  String endpoint =
    "https://api.openai.com/v1/responses";


  String model =
    "gpt-6-astra";


  String apiKey;


  OpenAIClient() {

    apiKey =
      System.getenv(
        "OPENAI_API_KEY"
      );


    if (
      apiKey == null
      ||
      apiKey.length() == 0
    ) {

      println();
      println(
        "[OPENAI] API KEY NOT FOUND"
      );

    } else {

      println(
        "[OPENAI] API KEY FOUND"
      );
    }
  }


  // ==========================================================
  // PLAN ACTION
  // ==========================================================

  ActionPlan planAction(
    String userCommand,
    String telemetry
  ) throws Exception {

    String prompt =
      "You are the trainer of a physical stickman simulation.\n"
      +
      "\n"
      +
      "IMPORTANT RULES:\n"
      +
      "- You do NOT draw or animate the body.\n"
      +
      "- You can only choose one action supported by the controller.\n"
      +
      "- The Processing physics engine controls all joints.\n"
      +
      "- Choose the closest supported action to the user's request.\n"
      +
      "- If the request is currently unsupported, choose IDLE.\n"
      +
      "- If the user says simply 抬手 / raise hand without specifying a side, use RAISE_RIGHT_ARM.\n"
      +
      "- Keep duration between 1 and 4 seconds.\n"
      +
      "- message must be a short Chinese sentence explaining what you decided.\n"
      +
      "\n"
      +
      "SUPPORTED ACTIONS:\n"
      +
      "IDLE\n"
      +
      "RAISE_LEFT_ARM\n"
      +
      "RAISE_RIGHT_ARM\n"
      +
      "RAISE_BOTH_ARMS\n"
      +
      "LOWER_ARMS\n"
      +
      "WAVE_RIGHT\n"
      +
      "\n"
      +
      "USER COMMAND:\n"
      +
      userCommand
      +
      "\n\n"
      +
      "CURRENT BODY TELEMETRY:\n"
      +
      telemetry;


    JSONObject body =
      new JSONObject();


    body.setString(
      "model",
      model
    );


    body.setString(
      "input",
      prompt
    );


    body.setBoolean(
      "store",
      false
    );


    body.setInt(
      "max_output_tokens",
      180
    );


    // ========================================================
    // STRUCTURED OUTPUT SCHEMA
    // ========================================================

    JSONObject schema =
      new JSONObject();


    schema.setString(
      "type",
      "object"
    );


    JSONObject properties =
      new JSONObject();


    // Action
    JSONObject action =
      new JSONObject();


    action.setString(
      "type",
      "string"
    );


    JSONArray actions =
      new JSONArray();


    actions.append(
      "IDLE"
    );

    actions.append(
      "RAISE_LEFT_ARM"
    );

    actions.append(
      "RAISE_RIGHT_ARM"
    );

    actions.append(
      "RAISE_BOTH_ARMS"
    );

    actions.append(
      "LOWER_ARMS"
    );

    actions.append(
      "WAVE_RIGHT"
    );


    action.setJSONArray(
      "enum",
      actions
    );


    properties.setJSONObject(
      "action",
      action
    );


    // Duration
    JSONObject duration =
      new JSONObject();


    duration.setString(
      "type",
      "number"
    );


    properties.setJSONObject(
      "duration",
      duration
    );


    // Message
    JSONObject message =
      new JSONObject();


    message.setString(
      "type",
      "string"
    );


    properties.setJSONObject(
      "message",
      message
    );


    schema.setJSONObject(
      "properties",
      properties
    );


    JSONArray required =
      new JSONArray();


    required.append(
      "action"
    );

    required.append(
      "duration"
    );

    required.append(
      "message"
    );


    schema.setJSONArray(
      "required",
      required
    );


    schema.setBoolean(
      "additionalProperties",
      false
    );


    JSONObject format =
      new JSONObject();


    format.setString(
      "type",
      "json_schema"
    );


    format.setString(
      "name",
      "stickman_action"
    );


    format.setBoolean(
      "strict",
      true
    );


    format.setJSONObject(
      "schema",
      schema
    );


    JSONObject textConfig =
      new JSONObject();


    textConfig.setJSONObject(
      "format",
      format
    );


    body.setJSONObject(
      "text",
      textConfig
    );


    // ========================================================
    // REQUEST
    // ========================================================

    String response =
      sendRequest(
        body
      );


    String outputText =
      extractOutputText(
        response
      );


    if (
      outputText == null
    ) {

      throw new Exception(
        "OpenAI returned no output text."
      );
    }


    JSONObject result =
      parseJSONObject(
        outputText
      );


    if (
      result == null
    ) {

      throw new Exception(
        "Could not parse action JSON:\n"
        + outputText
      );
    }


    String actionName =
      result.getString(
        "action"
      );


    float durationValue =
      result.getFloat(
        "duration"
      );


    String messageValue =
      result.getString(
        "message"
      );


    durationValue =
      constrain(
        durationValue,
        1.0,
        4.0
      );


    return new ActionPlan(
      actionName,
      durationValue,
      messageValue
    );
  }


  // ==========================================================
  // SUMMARIZE MOVEMENT
  // ==========================================================

  String summarizeMovement(
    String command,
    String before,
    String after
  ) throws Exception {

    String prompt =
      "你是 Physical AI 实验室的观察员。\n"
      +
      "用户刚刚向一个真实运行在 Processing 物理世界中的火柴人发送了动作指令。\n"
      +
      "\n"
      +
      "请比较动作前后的 telemetry。\n"
      +
      "\n"
      +
      "要求：\n"
      +
      "1. 用中文。\n"
      +
      "2. 最多三句话。\n"
      +
      "3. 根据数据描述发生了什么。\n"
      +
      "4. 可以引用肩关节角度、手的位置、身体倾斜等数据。\n"
      +
      "5. 如果数据不能证明成功，不要声称成功。\n"
      +
      "6. 不要解释代码。\n"
      +
      "\n"
      +
      "用户指令：\n"
      +
      command
      +
      "\n\n"
      +
      "BEFORE:\n"
      +
      before
      +
      "\n\n"
      +
      "AFTER:\n"
      +
      after;


    JSONObject body =
      new JSONObject();


    body.setString(
      "model",
      model
    );


    body.setString(
      "input",
      prompt
    );


    body.setBoolean(
      "store",
      false
    );


    body.setInt(
      "max_output_tokens",
      220
    );


    String response =
      sendRequest(
        body
      );


    return extractOutputText(
      response
    );
  }


  // ==========================================================
  // SEND REQUEST
  // ==========================================================

  String sendRequest(
    JSONObject body
  ) throws Exception {

    if (
      apiKey == null
      ||
      apiKey.length() == 0
    ) {

      throw new Exception(
        "OPENAI_API_KEY is missing."
      );
    }


    URL url =
      new URL(
        endpoint
      );


    HttpURLConnection connection =
      (
        HttpURLConnection
      )
      url.openConnection();


    connection.setRequestMethod(
      "POST"
    );


    connection.setRequestProperty(
      "Authorization",
      "Bearer " + apiKey
    );


    connection.setRequestProperty(
      "Content-Type",
      "application/json"
    );


    connection.setDoOutput(
      true
    );


    connection.setConnectTimeout(
      15000
    );


    connection.setReadTimeout(
      90000
    );


    byte[] requestData =
      body
      .toString()
      .getBytes(
        StandardCharsets.UTF_8
      );


    OutputStream output =
      connection
      .getOutputStream();


    output.write(
      requestData
    );


    output.flush();
    output.close();


    int status =
      connection
      .getResponseCode();


    println(
      "[OPENAI] HTTP "
      + status
    );


    InputStream stream;


    if (
      status >= 200
      &&
      status < 300
    ) {

      stream =
        connection
        .getInputStream();

    } else {

      stream =
        connection
        .getErrorStream();
    }


    String response =
      readStream(
        stream
      );


    connection.disconnect();


    if (
      status < 200
      ||
      status >= 300
    ) {

      throw new Exception(
        "OpenAI API Error "
        + status
        + "\n"
        + response
      );
    }


    return response;
  }


  // ==========================================================
  // READ STREAM
  // ==========================================================

  String readStream(
    InputStream stream
  ) throws Exception {

    if (
      stream == null
    ) {

      return "";
    }


    BufferedReader reader =
      new BufferedReader(
        new InputStreamReader(
          stream,
          StandardCharsets.UTF_8
        )
      );


    StringBuilder builder =
      new StringBuilder();


    String line;


    while (
      (
        line =
        reader.readLine()
      )
      != null
    ) {

      builder.append(
        line
      );
    }


    reader.close();


    return builder.toString();
  }


  // ==========================================================
  // RESPONSE PARSER
  // ==========================================================

  String extractOutputText(
    String rawJSON
  ) {

    JSONObject response =
      parseJSONObject(
        rawJSON
      );


    if (
      response == null
      ||
      !response.hasKey(
        "output"
      )
    ) {

      return null;
    }


    JSONArray output =
      response.getJSONArray(
        "output"
      );


    for (
      int i = 0;
      i < output.size();
      i++
    ) {

      JSONObject item =
        output.getJSONObject(
          i
        );


      if (
        item == null
        ||
        !item.hasKey(
          "content"
        )
      ) {

        continue;
      }


      JSONArray content =
        item.getJSONArray(
          "content"
        );


      for (
        int j = 0;
        j < content.size();
        j++
      ) {

        JSONObject part =
          content.getJSONObject(
            j
          );


        if (
          part == null
        ) {

          continue;
        }


        if (
          part.hasKey(
            "type"
          )
        ) {

          String type =
            part.getString(
              "type"
            );


          if (
            type.equals(
              "output_text"
            )
          ) {

            return part.getString(
              "text"
            );
          }
        }
      }
    }


    return null;
  }
}
