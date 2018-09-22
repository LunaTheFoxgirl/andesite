module andesite.application;
import gtk.Application;

public struct ManagedApplication(T) {
private:
	Application app_;
	StateManager!T manager_;
public:

	this(T)() {
		app_ = new Application();
		manager_ = new StateManager!T(null);
	}

	// base window alias.
	alias app_ this;
}