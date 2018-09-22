module andesite.app;

public class State {
public:
	int stateId;
}

enum IsState(T) = is(T : State);

public struct StateManager(T) if (IsState!T) {
public:
	T data;

	this(T data) {
		this.data = data;
	}

	/// Deserialize serialized state.
	static T deserialize()(ubyte[] data) if (IsState!T) {
		return StateManager!T(*cast(T*)(data.ptr));
	}

	/// Serialize struct (with state data) to byte array which can be deserialized later.
	ubyte[] serialize()() {
		return (cast(ubyte*)&data)[0..data.sizeof];
	}
}