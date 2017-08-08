import java.io.*;
import java.net.*;

public class HTTPGet {

   public static String getHTML(String urlToRead) throws Exception {
      StringBuilder result = new StringBuilder();
      URL url = new URL(urlToRead);
      HttpURLConnection conn = (HttpURLConnection) url.openConnection();
      conn.setRequestMethod("GET");
      BufferedReader rd = new BufferedReader(new InputStreamReader(conn.getInputStream()));
      String line;
      while ((line = rd.readLine()) != null) {
         result.append(line);
      }
      rd.close();
      return result.toString();
   }

   public static void main(String[] args) throws Exception
   {
     System.out.println(getHTML(args[0]));
   }
}

//for example(online servise for test url): https://jsonplaceholder.typicode.com/posts/1

//for another functional see docs:
//https://docs.oracle.com/javase/7/docs/api/java/net/HttpURLConnection.html
//https://docs.oracle.com/javase/7/docs/api/java/net/URLConnection.html