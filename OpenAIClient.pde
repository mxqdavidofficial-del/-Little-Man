import java.net.URL;
import java.net.HttpURLConnection;

import java.io.InputStream;
import java.io.OutputStream;
import java.io.BufferedReader;
import java.io.InputStreamReader;

import java.nio.charset.StandardCharsets;


class OpenAIClient {

  String endpoint =
    "https://api.openai.com/v1/responses";

  String model =
    "gpt-5.4-mini";

  String apiKey;


  OpenAIClient() {

    apiKey =
      System.getenv("OPENAI_API_KEY");

    if (apiKey == null || apiKey.length() == 0) {

      println();
      println("====================================");
      println("OPENAI_API_KEY NOT FOUND");
      println("====================================");
      println();
      println(
        "Please create the environment variable:"
      );
      println(
        "OPENAI_API_KEY"
      );
    }
  }


  String ask(String message) {

    if (apiKey == null || apiKey.length() == 0) {

      return null;
    }


    HttpURLConnection connection = null;

    try {

      URL url =
        new URL(endpoint);

      connection =
        (HttpURLConnection)
        url.openConnection();

      connection.setRequestMethod("POST");

      connection.setRequestProperty(
        "Authorization",
        "Bearer " + apiKey
      );

      connection.setRequestProperty(
        "Content-Type",
        "application/json"
      );

      connection.setDoOutput(true);


      // --------------------------------
      // Build JSON request
      // --------------------------------

      JSONObject body =
        new JSONObject();

      body.setString(
        "model",
        model
      );

      body.setString(
        "input",
        message
      );


      byte[] requestData =
        body
        .toString()
        .getBytes(StandardCharsets.UTF_8);


      OutputStream output =
        connection.getOutputStream();

      output.write(requestData);
      output.flush();
      output.close();


      int status =
        connection.getResponseCode();

      println(
        "OpenAI HTTP Status: " +
        status
      );


      InputStream stream;

      if (
        status >= 200 &&
        status < 300
      ) {

        stream =
          connection.getInputStream();

      } else {

        stream =
          connection.getErrorStream();
      }


      String responseText =
        readStream(stream);


      if (
        status < 200 ||
        status >= 300
      ) {

        println(
          "[OpenAI Error]"
        );

        println(
          responseText
        );

        return null;
      }


      return extractOutputText(
        responseText
      );

    }

    catch (Exception e) {

      println();
      println(
        "[OpenAI Exception]"
      );

      e.printStackTrace();

      return null;

    }

    finally {

      if (connection != null) {

        connection.disconnect();
      }
    }
  }


  String readStream(
    InputStream stream
  ) throws Exception {

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
      (line = reader.readLine())
      != null
    ) {

      builder.append(line);
    }

    reader.close();

    return builder.toString();
  }


  String extractOutputText(
    String rawJSON
  ) {

    JSONObject response =
      parseJSONObject(rawJSON);

    if (response == null) {

      return null;
    }


    JSONArray output =
      response.getJSONArray("output");

    if (output == null) {

      return null;
    }


    for (
      int i = 0;
      i < output.size();
      i++
    ) {

      JSONObject item =
        output.getJSONObject(i);

      if (item == null) {
        continue;
      }

      if (!item.hasKey("content")) {
        continue;
      }


      JSONArray content =
        item.getJSONArray("content");

      for (
        int c = 0;
        c < content.size();
        c++
      ) {

        JSONObject part =
          content.getJSONObject(c);

        if (part == null) {
          continue;
        }


        if (
          part.hasKey("type") &&
          part
          .getString("type")
          .equals("output_text")
        ) {

          return
            part.getString("text");
        }
      }
    }

    return null;
  }
}
