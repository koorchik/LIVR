<?php
// LIVR 2.5: options.json {"now": "..."} fixes the current time of a case. The date rules of
// validator/livr read the clock with time() called without a namespace in Validator\LIVR\Rules,
// and php-validator-livr's own tests replace it there (php-mock). This is the same replacement:
// it must be defined before the first call there, otherwise PHP binds the call to the global time().
// Versions without the date rules never call it.

namespace {
    final class LivrHarnessClock
    {
        // Unix time in seconds, or null for the system clock
        public static $now = null;
    }
}

namespace Validator\LIVR\Rules {
    if (!function_exists(__NAMESPACE__ . '\time')) {
        function time()
        {
            return \LivrHarnessClock::$now === null ? \time() : \LivrHarnessClock::$now;
        }
    }
}
