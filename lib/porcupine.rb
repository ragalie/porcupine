require "lock_jar"

lockfile = File.expand_path( "../../Jarfile.lock", __FILE__ )
LockJar.load(lockfile)

require "porcupine/porcupine"
require "porcupine/exceptions"
require "porcupine/future"
require "porcupine/observable"
