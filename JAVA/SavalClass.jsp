create or replace and compile java source named Sav_math as
import java.math.BigInteger;
import java.io.File;
import oracle.sql.ARRAY;
import oracle.sql.ArrayDescriptor;
public class SavMath
{
  public static Long power(int x, int st)
  {
    if (st < 0) return null;
    if (st == 0) return 1L;
    if (st == 1) return (long)x;
    return x * power(x, st - 1);
  }
  
  public static String sum(String as, String bs){
     BigInteger a = new BigInteger(as);
     BigInteger b = new BigInteger(bs);
     
     return a.add(b).toString();
  }
  
  public static String minus(String as, String bs){
     BigInteger a = new BigInteger(as);
     BigInteger b = new BigInteger(bs);
     
     return a.subtract(b).toString();
  }
  
  public static String mult(String as, String bs){
     BigInteger a = new BigInteger(as);
     BigInteger b = new BigInteger(bs);
     
     return a.multiply(b).toString();
  }
  
  public static String div(String as, String bs){
     BigInteger a = new BigInteger(as);
     BigInteger b = new BigInteger(bs);
     
     return a.divide(b).toString();
  }
  
    public static String mod(String as, String bs){
     BigInteger a = new BigInteger(as);
     BigInteger b = new BigInteger(bs);
     
     return a.mod(b).toString();
  }
  
  public static String power(String as, String bs){
     BigInteger a = new BigInteger(as);
     BigInteger b = new BigInteger(bs);
     
     return a.pow(b.intValue()).toString();
  }
  
  public static String getFiles(String path, int maxDeep){
    return getFiles(path, maxDeep, 1);
  }
  
  public static String getFiles(String path, int maxDeep, int deep){
    StringBuilder sb = new StringBuilder();
    File folder = new File(path);
    File[] files = folder.listFiles();
    for (File f: files){
      for (int i = 0; i < deep - 1; i++){
        sb.append("   ");
      }
      sb.append(f.toString() + "\n");
      if (f.isDirectory()  && maxDeep <= deep){
        try{
          String s = getFiles(path + f.getName(), maxDeep, deep + 1);
          //sb.append(s);
          }catch(Exception e){
            //sb.append("error\n");
            }
        
        }
    }   
    return sb.toString();
  }
  
        
  public static long fact(long n)
  {
   if (n == 1) return 1;
   return n * fact(n-1);
  }
}
/
