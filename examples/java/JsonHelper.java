import java.util.ArrayList;
import java.util.List;
import java.util.regex.Pattern;

/**
 * Minimal JSON helpers using regex — no external dependencies.
 * For production use, prefer Jackson or Gson for typed deserialization.
 */
public class JsonHelper {

    public static String getString(String json, String key) {
        var pattern = "\"" + key + "\"\\s*:\\s*\"([^\"]*?)\"";
        var m = Pattern.compile(pattern).matcher(json);
        return m.find() ? m.group(1) : "";
    }

    public static long getLong(String json, String key) {
        var pattern = "\"" + key + "\"\\s*:\\s*(-?[0-9]+)";
        var m = Pattern.compile(pattern).matcher(json);
        return m.find() ? Long.parseLong(m.group(1)) : 0;
    }

    public static Double getNullableDouble(String json, String key) {
        var pattern = "\"" + key + "\"\\s*:\\s*(null|-?[0-9.]+)";
        var m = Pattern.compile(pattern).matcher(json);
        if (m.find()) {
            var val = m.group(1);
            return "null".equals(val) ? null : Double.parseDouble(val);
        }
        return null;
    }

    public static double getDouble(String json, String key) {
        var pattern = "\"" + key + "\"\\s*:\\s*(-?[0-9.]+)";
        var m = Pattern.compile(pattern).matcher(json);
        return m.find() ? Double.parseDouble(m.group(1)) : 0.0;
    }

    /**
     * Returns the nested JSON object bound to {@code key}, or {@code null} when the key is
     * absent or its value is {@code null}. Used to tell "section not present" from real data.
     */
    public static String extractObject(String json, String key) {
        return extractContainer(json, key, '{', '}');
    }

    /** Returns the JSON array bound to {@code key}, or {@code null} when absent / null. */
    public static String extractArray(String json, String key) {
        return extractContainer(json, key, '[', ']');
    }

    private static String extractContainer(String json, String key, char open, char close) {
        // Match the key only where it is immediately followed by a colon, i.e. a real
        // object member. This skips bare string occurrences such as the section names
        // listed inside the includedSections array, which otherwise match first.
        var m = Pattern.compile("\"" + Pattern.quote(key) + "\"\\s*:").matcher(json);
        if (!m.find()) return null;

        int i = m.end();
        while (i < json.length() && Character.isWhitespace(json.charAt(i))) i++;
        if (i >= json.length() || json.charAt(i) != open) return null; // null or other scalar

        int depth = 0;
        for (int j = i; j < json.length(); j++) {
            char c = json.charAt(j);
            if (c == open) depth++;
            else if (c == close) {
                depth--;
                if (depth == 0) return json.substring(i, j + 1);
            }
        }
        return null;
    }

    /** Parses a flat JSON array of strings (e.g. includedSections) into a list. */
    public static List<String> getStringArray(String json, String key) {
        var result = new ArrayList<String>();
        var array = extractArray(json, key);
        if (array == null) return result;
        var m = Pattern.compile("\"([^\"]*)\"").matcher(array);
        while (m.find()) result.add(m.group(1));
        return result;
    }

    public static List<String> getObjectsInArray(String json) {
        var items = new ArrayList<String>();
        int depth = 0;
        int start = -1;
        for (int i = 0; i < json.length(); i++) {
            char c = json.charAt(i);
            if (c == '{') {
                if (depth == 0) start = i;
                depth++;
            } else if (c == '}') {
                depth--;
                if (depth == 0 && start >= 0) {
                    items.add(json.substring(start, i + 1));
                    start = -1;
                }
            }
        }
        return items;
    }

    public static String extractJobsArray(String body) {
        int arrStart = body.indexOf("\"jobs\"");
        int bracket = body.indexOf('[', arrStart);
        int depth = 0;
        int end = bracket;
        for (int i = bracket; i < body.length(); i++) {
            if (body.charAt(i) == '[') depth++;
            if (body.charAt(i) == ']') depth--;
            if (depth == 0) { end = i + 1; break; }
        }
        return body.substring(bracket, end);
    }

    public static String extractFirstSalary(String jobJson) {
        int salaryStart = jobJson.indexOf("\"salary\"");
        if (salaryStart < 0) return "{}";
        int brace = jobJson.indexOf('{', salaryStart);
        int depth = 0;
        int end = brace;
        for (int i = brace; i < jobJson.length(); i++) {
            if (jobJson.charAt(i) == '{') depth++;
            if (jobJson.charAt(i) == '}') depth--;
            if (depth == 0) { end = i + 1; break; }
        }
        return jobJson.substring(brace, end);
    }

    public static String formatSalary(String jobJson) {
        var salary = extractFirstSalary(jobJson);
        var from = getNullableDouble(salary, "from");
        var to = getNullableDouble(salary, "to");
        var currency = getString(salary, "currency");
        var period = getString(salary, "period");
        if (from == null && to == null) return "no range (" + currency + ")";
        return String.format("%.0f-%.0f %s/%s", from, to, currency, period);
    }
}
