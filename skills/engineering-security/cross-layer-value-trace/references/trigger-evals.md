# Trigger evals

Last verified 2026-11-27

Should trigger `cross-layer-value-trace`:

1. "The dashboard says 0 alerts but the monitoring system is clearly down. How do I find where that comes from?"
2. "The revenue total on the report page differs from the one on the home page. Find out why."
3. "This CPU figure looks live but is minutes old. Trace where the timestamp gets lost."

Near misses (expected owner in parentheses):

1. "The API throws a NullPointerException on this request." (`diagnosing-bugs`)
2. "The dashboard takes eight seconds to load." (`application-performance`)
3. "Review my whole app for the usual AI-built mistakes." (`fundamentals-audit`)
